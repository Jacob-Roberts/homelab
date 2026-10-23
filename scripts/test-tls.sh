#!/usr/bin/env bash

# Smoke-test TLS for the auth domains on both paths:
#   1. public internet -> iad1 Traefik -> Netbird -> PBJ gateway / slc1
#   2. local workstation -> PBJ gateway over Netbird (split-horizon path)
#
# Usage:
#   ./scripts/test-tls.sh              # public checks + internal hops
#   ./scripts/test-tls.sh --no-internal # only the public iad1 path
#   ./scripts/test-tls.sh --help
#
# Overridable environment variables:
#   IAD1_IP            public IP of iad1-node-1 (default: resolve it)
#   PBJ_GATEWAY_IP     PBJ Kubernetes gateway (default: 192.168.42.200)
#   SLC1_TUNNEL_HOST   slc1 Traefik over Netbird (default: slc1-node-3.vpn.jakerob.pro)
#   EXPIRY_WARN_DAYS   warn when a cert expires within this many days (default: 30)
#   TIMEOUT            per-request timeout in seconds (default: 10)
#
# Exit codes: 0 if every check passed and nothing warned, 1 on failure,
# 2 on a warning only.

set -uo pipefail

IAD1_IP=${IAD1_IP:-$(dig +short A iad1-node-1.jakerob.pro 2>/dev/null | tail -n1)}
IAD1_IP=${IAD1_IP:-150.136.144.201}
PBJ_GATEWAY_IP=${PBJ_GATEWAY_IP:-192.168.42.200}
SLC1_TUNNEL_HOST=${SLC1_TUNNEL_HOST:-slc1-node-3.vpn.jakerob.pro}
EXPIRY_WARN_DAYS=${EXPIRY_WARN_DAYS:-30}
TIMEOUT=${TIMEOUT:-10}

FAILURES=0
WARNINGS=0
INTERNAL=1

case ${1:-} in
  --help|-h)
    sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  --no-internal)
    INTERNAL=0
    ;;
  '')
    ;;
  *)
    echo "Unknown option: $1 (try --help)" >&2
    exit 1
    ;;
esac

if [ -t 1 ]; then
  RED=$'\033[31m'
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BOLD=''
  RESET=''
fi

pass() { printf '%sPASS%s %s\n' "$GREEN" "$RESET" "$1"; }
warn() {
  WARNINGS=$((WARNINGS + 1))
  printf '%sWARN%s %s\n' "$YELLOW" "$RESET" "$1"
}
fail() {
  FAILURES=$((FAILURES + 1))
  printf '%sFAIL%s %s\n' "$RED" "$RESET" "$1"
}

# run_curl LABEL EXPECTED_CODE EXPECTED_VERIFY CURL_ARGS...
# EXPECTED_VERIFY is 0 for "must verify" or "any" for intentionally
# unverified hops (e.g. -k against a Traefik default cert).
run_curl() {
  local label=$1 expected_code=$2 expected_verify=$3
  shift 3

  local out code verify time ip url=''
  if ! out=$(curl -sS -o /dev/null --max-time "$TIMEOUT" \
      -w '%{http_code} %{ssl_verify_result} %{time_total} %{remote_ip}' "$@" 2>&1); then
    fail "$label — curl error: $out"
    return 1
  fi

  read -r code verify time ip <<< "$out"

  local arg
  for arg in "$@"; do
    case $arg in
      http://*|https://*) url=$arg ;;
    esac
  done

  if [ "$code" != "$expected_code" ]; then
    fail "$label — HTTP $code (want $expected_code) from $ip"
    return 1
  fi

  if [ "$expected_verify" != "any" ] && [ "$verify" != "$expected_verify" ]; then
    fail "$label — TLS verification failed (ssl_verify_result=$verify) from $ip"
    return 1
  fi

  case $url in
    https://*)
      if [ "$verify" = "0" ]; then
        pass "$label — HTTP $code, TLS verified, ${time}s via $ip"
      else
        pass "$label — HTTP $code, ${time}s via $ip (TLS unverified by design)"
      fi
      ;;
    *)
      pass "$label — HTTP $code, ${time}s via $ip (plain HTTP)"
      ;;
  esac
  return 0
}

check_redirect() {
  local label=$1 url=$2 resolve=$3

  local out code target
  if ! out=$(curl -sS -o /dev/null --max-time "$TIMEOUT" --resolve "$resolve" \
      -w '%{http_code} %{redirect_url}' "$url" 2>&1); then
    fail "$label — curl error: $out"
    return 1
  fi

  read -r code target <<< "$out"
  case $code in
    301|302|307|308)
      case $target in
        https://*)
          pass "$label — HTTP $code to $target"
          return 0
          ;;
      esac
      fail "$label — HTTP $code but redirect target is '$target'"
      return 1
      ;;
  esac

  fail "$label — HTTP $code (want a redirect to https)"
  return 1
}

check_cert() {
  local label=$1 connect=$2 sni=$3

  local pem info subject issuer enddate san
  pem=$(printf '' | openssl s_client -connect "$connect" -servername "$sni" 2>/dev/null \
    | openssl x509 2>/dev/null)
  if [ -z "$pem" ]; then
    fail "$label — could not fetch certificate from $connect (SNI $sni)"
    return 1
  fi

  info=$(printf '%s\n' "$pem" | openssl x509 -noout -subject -issuer -enddate -text 2>/dev/null)
  subject=$(printf '%s\n' "$info" | sed -n 's/^subject= *//p')
  issuer=$(printf '%s\n' "$info" | sed -n 's/^issuer= *//p')
  enddate=$(printf '%s\n' "$info" | sed -n 's/^notAfter= *//p')
  san=$(printf '%s\n' "$info" \
    | awk '/X509v3 Subject Alternative Name/{getline; gsub(/^ +/, ""); print; exit}')

  pass "$label — $subject"
  printf '     issuer: %s\n' "$issuer"
  printf '     expires: %s\n' "$enddate"
  printf '     SAN: %s\n' "$san"

  if ! printf '%s\n' "$pem" | openssl x509 -noout -checkend $((EXPIRY_WARN_DAYS * 86400)) >/dev/null 2>&1; then
    warn "$label — expires within ${EXPIRY_WARN_DAYS} days ($enddate)"
  fi

  return 0
}

printf '%sPublic path: internet -> iad1 (%s) -> Netbird%s\n' "$BOLD" "$IAD1_IP" "$RESET"

check_redirect "auth.jakerob.pro :80 redirect" \
  "http://auth.jakerob.pro/" "auth.jakerob.pro:80:$IAD1_IP"
check_redirect "auth.autovation.com :80 redirect" \
  "http://auth.autovation.com/" "auth.autovation.com:80:$IAD1_IP"

run_curl "auth.jakerob.pro via iad1" 200 0 \
  --resolve "auth.jakerob.pro:443:$IAD1_IP" "https://auth.jakerob.pro/"
run_curl "auth.autovation.com via iad1" 200 0 \
  --resolve "auth.autovation.com:443:$IAD1_IP" "https://auth.autovation.com/"

printf '\n%sCertificates served by iad1%s\n' "$BOLD" "$RESET"
check_cert "auth.jakerob.pro @ iad1" "$IAD1_IP:443" "auth.jakerob.pro"
check_cert "auth.autovation.com @ iad1" "$IAD1_IP:443" "auth.autovation.com"

if [ "$INTERNAL" = "1" ]; then
  printf '\n%sInternal path: local workstation -> Netbird%s\n' "$BOLD" "$RESET"

  run_curl "auth.jakerob.pro direct to PBJ gateway" 200 0 \
    --resolve "auth.jakerob.pro:443:$PBJ_GATEWAY_IP" "https://auth.jakerob.pro/"
  run_curl "PBJ gateway hop replay (HTTP + Host)" 200 0 \
    -H "Host: auth.jakerob.pro" "http://$PBJ_GATEWAY_IP/"
  run_curl "slc1 tunnel hop replay (TLS + Host)" 200 any \
    -k -H "Host: auth.autovation.com" "https://$SLC1_TUNNEL_HOST/"

  printf '\n%sCertificates served over the tunnel%s\n' "$BOLD" "$RESET"
  check_cert "auth.jakerob.pro @ PBJ gateway" "$PBJ_GATEWAY_IP:443" "auth.jakerob.pro"
fi

printf '\n'
if [ "$FAILURES" -ne 0 ]; then
  printf '%s%d check(s) failed%s, %d warning(s)\n' "$RED" "$FAILURES" "$RESET" "$WARNINGS"
  exit 1
fi

if [ "$WARNINGS" -ne 0 ]; then
  printf '%sAll checks passed%s with %d warning(s)\n' "$YELLOW" "$RESET" "$WARNINGS"
  exit 2
fi

printf '%sAll checks passed%s\n' "$GREEN" "$RESET"
exit 0
