#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# MANIFEST.sha256 is repository integrity metadata, not a package input. Rebuild
# it from the current checkout after applying an overlay so locally modified
# files are represented accurately. Build into a temp file outside the checkout
# so the output can never be discovered by the find pipeline itself.
tmp_manifest="$(mktemp)"
trap 'rm -f "$tmp_manifest"' EXIT

find . -type f \
  ! -path './.git/*' \
  ! -path './.tooling/*' \
  ! -path './_build/*' \
  ! -path './deps/*' \
  ! -path './doc/*' \
  ! -path './tmp/*' \
  ! -path './typesafe_api_sdk-*/*' \
  ! -name 'MANIFEST.sha256' \
  ! -name 'MANIFEST.sha256.new' \
  -print0 \
  | sort -z \
  | xargs -0 sha256sum \
  | sed 's#  \./#  #' \
  > "$tmp_manifest"

mv "$tmp_manifest" MANIFEST.sha256
trap - EXIT
sha256sum -c MANIFEST.sha256
