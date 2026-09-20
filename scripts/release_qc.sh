#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="$(sed -n 's/^[[:space:]]*@version "\([^"]*\)".*/\1/p' mix.exs | head -n 1)"
PACKAGE_DIR="typesafe_api_sdk-${VERSION}"

usage() {
  cat <<'TXT'
Usage: bash scripts/release_qc.sh <offline|package-dry-run|live|live-alt|live-matrix>

  offline          Run the full non-live source/maintenance gate.
  package-dry-run  Build/unpack the package and run hex.publish --dry-run.
  live             Run comprehensive official live verification. Requires TYPESAFE_API_KEY.
  live-alt         Run alternate TypeSafe-compatible endpoint verification.
  live-matrix      Run official plus configured alternate live verification.

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
    bash scripts/live_qc.sh official
    ;;
  live-alt)
    bash scripts/live_qc.sh alternate
    ;;
  live-matrix)
    bash scripts/live_qc.sh all
    ;;
  -h|--help|help|"") usage ;;
  *) usage >&2; exit 2 ;;
esac
