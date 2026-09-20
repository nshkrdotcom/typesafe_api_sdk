#!/usr/bin/env bash
# Source this file: source scripts/ensure_tooling.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REF="04ba7b112413591f5cb9260f1d270bbbeb8a0630"
TOOLING="$ROOT/.tooling/pristine"
BOOTSTRAP="$ROOT/tmp/pristine_tools.exs"

mkdir -p "$ROOT/.tooling" "$ROOT/tmp"

if [[ ! -d "$TOOLING/.git" ]]; then
  git clone --filter=blob:none --no-checkout https://github.com/nshkrdotcom/pristine.git "$TOOLING"
  git -C "$TOOLING" checkout --detach "$REF" >/dev/null
fi

if [[ -n "$(git -C "$TOOLING" status --porcelain 2>/dev/null || true)" ]]; then
  echo "$TOOLING has local changes; refusing to mutate maintenance tooling." >&2
  return 1 2>/dev/null || exit 1
fi

if ! git -C "$TOOLING" cat-file -e "${REF}^{commit}" 2>/dev/null; then
  git -C "$TOOLING" fetch --depth=1 origin "$REF"
fi

git -C "$TOOLING" checkout --detach "$REF" >/dev/null

cat > "$BOOTSTRAP" <<'ELIXIR'
defmodule MixWorkspaceOpsBootstrap do
  def dep(committed, project_root) do
    app = elem(committed, 0)
    tooling = Path.join(System.fetch_env!("GITHUB_WORKSPACE"), ".tooling/pristine/apps")

    source =
      if app == :pristine_codegen do
        Path.join(tooling, "pristine_codegen")
      end

    packaging? = Enum.any?(System.argv(), &(&1 in ["hex.build", "hex.publish"]))

    if source && File.dir?(source) && not packaging? do
      opts = if tuple_size(committed) == 3, do: elem(committed, 2), else: []
      {app, Keyword.merge(opts, path: Path.relative_to(source, project_root, force: true), override: true)}
    else
      committed
    end
  end
end
ELIXIR

export GITHUB_WORKSPACE="$ROOT"
export MIX_WORKSPACE_OPS_BOOTSTRAP="$BOOTSTRAP"
export TYPESAFE_API_SDK_MAINTENANCE=1

echo "TypeSafe API SDK maintenance tooling ready at Pristine $REF"
echo "MIX_WORKSPACE_OPS_BOOTSTRAP=$MIX_WORKSPACE_OPS_BOOTSTRAP"
