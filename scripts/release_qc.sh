#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="$(sed -n 's/^[[:space:]]*@version "\([^"]*\)".*/\1/p' mix.exs | head -n 1)"
PACKAGE_DIR="typesafe_api_sdk-${VERSION}"

usage() {
  cat <<'TXT'
Usage: bash scripts/release_qc.sh <offline|package-dry-run|live>

  offline          Run the full non-live source/maintenance gate.
  package-dry-run  Build/unpack the package and run hex.publish --dry-run.
  live             Run the two-request real TypeSafe example. Requires TYPESAFE_API_KEY.

This script never publishes, tags, commits, or pushes.
TXT
}

case "${1:-}" in
  offline)
    bash -n scripts/*.sh
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git diff --check
    fi
    bash scripts/check_handoff.sh
    ;;
  package-dry-run)
    # shellcheck source=/dev/null
    source scripts/ensure_tooling.sh
    rm -rf "$PACKAGE_DIR"
    mix hex.build --unpack
    test -d "$PACKAGE_DIR"
    cp mix.lock "$PACKAGE_DIR/mix.lock"
    (
      cd "$PACKAGE_DIR"
      unset MIX_WORKSPACE_OPS_BOOTSTRAP TYPESAFE_API_SDK_MAINTENANCE GITHUB_WORKSPACE
      rm -rf _build deps
      mix deps.get
      mix hex.publish --dry-run --yes
    )
    ;;
  live)
    test -n "${TYPESAFE_API_KEY:-}" || { echo "TYPESAFE_API_KEY is required" >&2; exit 1; }
    mix run examples/live.exs
    ;;
  -h|--help|help|"") usage ;;
  *) usage >&2; exit 2 ;;
esac
