#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

usage() {
  cat <<'TXT'
Usage: bash scripts/live_qc.sh <official|alternate|all|example|matrix>

  official   Real api.typesafe.ai verification. Requires TYPESAFE_API_KEY.
             Exercises GET /v1/models and POST /v1/systemone through tuple and
             bang APIs, all three wire question types, explicit/default client
             configuration, and safe per-call controls.

  alternate  Real alternate TypeSafe-compatible deployment verification.
             Requires TYPESAFE_LIVE_ALT_BASE_URL and TYPESAFE_LIVE_ALT_API_KEY.
             TYPESAFE_LIVE_ALT_MODEL is optional; otherwise the first model
             returned by GET /v1/models is used.

  all        Run official verification, then alternate verification when the
             alternate environment is configured.

  example    Run examples/live.exs against TYPESAFE_BASE_URL or official default.

  matrix     Run examples/live_matrix.exs against the official endpoint and,
             when configured, the alternate deployment too.

Environment:
  TYPESAFE_API_KEY             key for the official api.typesafe.ai live tests
  TYPESAFE_LIVE_MODEL          optional explicit official model for bang test
  TYPESAFE_BASE_URL            optional endpoint used only by examples/live.exs
  TYPESAFE_DEFAULT_MODEL       optional model used only by examples/live.exs
  TYPESAFE_LIVE_ALT_BASE_URL   exact alternate TypeSafe-compatible API root
  TYPESAFE_LIVE_ALT_API_KEY    credential issued for that alternate root
  TYPESAFE_LIVE_ALT_MODEL      optional alternate model

Never reuse an official credential for an alternate host unless that credential
was explicitly issued for that host.
TXT
}

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "$name is required" >&2
    exit 1
  fi
}

case "${1:-}" in
  official)
    require_env TYPESAFE_API_KEY
    mix test --only live_official
    ;;
  alternate)
    require_env TYPESAFE_LIVE_ALT_BASE_URL
    require_env TYPESAFE_LIVE_ALT_API_KEY
    mix test --only live_alt
    ;;
  all)
    require_env TYPESAFE_API_KEY
    mix test --only live_official
    if [[ -n "${TYPESAFE_LIVE_ALT_BASE_URL:-}" || -n "${TYPESAFE_LIVE_ALT_API_KEY:-}" ]]; then
      require_env TYPESAFE_LIVE_ALT_BASE_URL
      require_env TYPESAFE_LIVE_ALT_API_KEY
      mix test --only live_alt
    else
      echo "alternate deployment not configured; skipping alternate live matrix"
    fi
    ;;
  example)
    require_env TYPESAFE_API_KEY
    mix run examples/live.exs
    ;;
  matrix)
    require_env TYPESAFE_API_KEY
    if [[ -n "${TYPESAFE_LIVE_ALT_BASE_URL:-}" || -n "${TYPESAFE_LIVE_ALT_API_KEY:-}" ]]; then
      require_env TYPESAFE_LIVE_ALT_BASE_URL
      require_env TYPESAFE_LIVE_ALT_API_KEY
    fi
    mix run examples/live_matrix.exs
    ;;
  -h|--help|help|"")
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
