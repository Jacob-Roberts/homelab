#!/usr/bin/env bash
# Safe Infisical wrapper for agents: defaults to the staging environment and
# refuses to target production unless explicitly overridden with --i-know.
set -euo pipefail

ALLOW_PROD=false
ARGS=()
for a in "$@"; do
  if [[ "$a" == "--i-know" ]]; then
    ALLOW_PROD=true
  else
    ARGS+=("$a")
  fi
done

if printf '%s\n' "${ARGS[@]}" | grep -Eq '(^| )--env(=| )prod($| )'; then
  if [[ "$ALLOW_PROD" != true ]]; then
    echo "ERROR: refusing to target prod environment. Use staging." >&2
    echo "If you truly need prod, re-run with --i-know (requires human approval)." >&2
    exit 1
  fi
fi

if ! printf '%s\n' "${ARGS[@]}" | grep -q -- '--env'; then
  ARGS=("--env=stage" "${ARGS[@]}")
fi

exec infisical "${ARGS[@]}"
