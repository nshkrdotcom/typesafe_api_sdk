#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=/dev/null
source scripts/ensure_tooling.sh

mix deps.get
mix typesafe_api.prereq
mix format --check-formatted
mix compile --warnings-as-errors
mix test --warnings-as-errors
mix credo --strict
mix dialyzer
mix docs --warnings-as-errors
mix typesafe_api.verify --project-root .
mix hex.build --unpack
