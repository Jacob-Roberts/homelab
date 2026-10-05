#!/bin/bash

# Wrapper around `tofu` for the Cloudflare zones.
#
# Two reasons to use this instead of calling `tofu` directly:
#
#   1. It pins -parallelism low. The Cloudflare API allows 1,200 requests per
#      five minutes per token, and every DNS record costs at least one GET on
#      refresh plus one write per change. A zone here has ~90 records, so the
#      default parallelism of 10 bursts enough requests to trip a 429 and stall
#      the apply.
#   2. It lets you apply a subset of records. Records live in a single
#      cloudflare_dns_record.records resource keyed by record identifier (see
#      records.tf in the zone directory), so a subset is selected with -target.
#      Targeting never removes anything from the plan, so nothing is destroyed.
#
# Run it from inside a zone directory, e.g.
#
#   ../tofu.sh plan
#   ../tofu.sh apply
#   ../tofu.sh plan --batch jellyfin,karakeep
#   ../tofu.sh apply --batch MX_1,MX_2,SPF --no-refresh
#
# Record identifiers are the map keys in records.tf; `tofu state list` shows
# the same names.

set -euo pipefail

PARALLELISM="${TF_PARALLELISM:-1}"
LOCK_TIMEOUT="${TF_LOCK_TIMEOUT:-15m}"

usage() {
    sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'
}

if [[ $# -eq 0 ]]; then
    usage
    exit 1
fi

subcommand="$1"
shift

case "$subcommand" in
    -h | --help | help)
        usage
        exit 0
        ;;
    plan | apply | destroy | refresh | show | import | state | output)
        ;;
    *)
        echo "tofu.sh: unknown subcommand '$subcommand'" >&2
        usage >&2
        exit 1
        ;;
esac

args=()
targets=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --batch)
            if [[ $# -lt 2 ]]; then
                echo "tofu.sh: --batch needs a comma separated list of record keys" >&2
                exit 1
            fi
            IFS=',' read -r -a keys <<<"$2"
            for key in "${keys[@]}"; do
                key="${key// /}"
                [[ -z "$key" ]] && continue
                targets+=("-target=cloudflare_dns_record.records[\"$key\"]")
            done
            shift 2
            ;;
        --no-refresh)
            # Skips the per-record GETs; only safe when you know Cloudflare's
            # copy already matches the config.
            args+=("-refresh=false")
            shift
            ;;
        --)
            shift
            args+=("$@")
            break
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done

if [[ ${#targets[@]} -eq 0 && "$subcommand" == "apply" ]]; then
    echo "tofu.sh: no --batch given, applying every record in this zone at -parallelism=${PARALLELISM}" >&2
fi

exec tofu "$subcommand" \
    -parallelism="$PARALLELISM" \
    -lock-timeout="$LOCK_TIMEOUT" \
    "${targets[@]}" \
    "${args[@]}"