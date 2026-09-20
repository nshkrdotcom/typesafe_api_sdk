# TypeSafe API SDK 0.1.0 Handoff

## Status

This repository was reconstructed from the supplied complete `typesafe_sdk`
0.4.0 Repomix baseline and surgically reduced to the TypeSafe-specific API layer.
The delivery environment used for this handoff did **not** have Elixir/Erlang/Mix,
so no BEAM compilation, ExUnit, Dialyzer, Hex build, generated-artifact verify, or
real TypeSafe request is represented as passed here.

The implementation is intentionally much smaller than `typesafe_sdk` 0.4.0.
There are no backwards-compatibility aliases and no attempt to preserve the old
semantic SDK under the new package name.

## Source boundary implemented

Kept:

- `TypeSafeAPISDK.Client`
- TypeSafe constants/configuration
- Noul / Choice / Score wire request structs
- Noul / Choice / Score typed answers
- System One and Models resources
- response metadata/raw response retention
- TypeSafe error/retry/provider policy
- Pristine result classification and transport response wrapping
- runtime capability inspection
- generated TypeSafe OpenAPI operations/schemas
- source OpenAPI refresh/generate/verify tooling

Removed from this package:

- semantic Question.* constructors and validation framework
- JSON semantic layer
- Prepared
- Evaluation
- SemanticResponse
- ResponseContract
- RequestBudget policy layer
- Batch and Batch.Lifecycle
- Answer.* decision helpers / Response projection helpers
- semantic Telemetry
- OTP.Server
- public TypeSafeSDK.Test scenario harness
- evaluation datasets/workflow
- recursive/composite/speculative application patterns
- provider-neutral Models.find/latest policy helpers
- JSON Schema export surface

## Target checkout

Unzip from `~/p/g/n` so the repository lands at:

```text
~/p/g/n/typesafe_api_sdk
```

Then:

```bash
cd ~/p/g/n/typesafe_api_sdk
```

## First target-host pass

Normal runtime tests do not require codegen tooling:

```bash
mix deps.get
mix format
mix compile --warnings-as-errors
mix test --warnings-as-errors
mix credo --strict
mix dialyzer
mix docs --warnings-as-errors
mix hex.build --unpack
```

Fix all compile/static/test failures in this repository before changing scope.
Likely issues, if any, should be surgical namespace/API adjustments rather than
reintroducing removed semantic modules.

## Generated-artifact maintenance pass

The committed generated modules and `priv/generated/*.json` were transformed
from the current TypeSafe source as a seed. They **must** be regenerated and
verified on the target host before release:

```bash
source scripts/ensure_tooling.sh
mix deps.get
mix typesafe_api.prereq
mix typesafe_api.ir --project-root .
mix typesafe_api.generate --project-root .
mix typesafe_api.verify --project-root .
git diff -- lib/typesafe_api_sdk/generated priv/generated
```

Expected outcome: generated output should confirm the `TypeSafeAPISDK` namespace,
`typesafe_api_sdk` package identity, exactly two operations, and 12 reviewed
schema components. Review any non-mechanical differences instead of accepting
them blindly.

Do **not** refresh `priv/upstream/openapi.json` merely to make verification green.
Only refresh intentionally after reviewing current TypeSafe upstream changes.

## Pristine contract gate

Run:

```bash
source scripts/ensure_tooling.sh
mix typesafe_api.prereq
```

This checks the status-range and default transport cancellation contracts used by
the extracted client.

## Optional real TypeSafe gate

With a valid credential:

```bash
TYPESAFE_API_KEY='...' mix test --only live --warnings-as-errors
TYPESAFE_API_KEY='...' mix run examples/live.exs
```

This is billable/remote execution. Do not fabricate results if credentials are
not available.

## Package/release gate

After all offline checks are green:

```bash
bash scripts/release_qc.sh offline
bash scripts/release_qc.sh package-dry-run
```

Inspect the unpacked `typesafe_api_sdk-0.1.0/` package. It must not contain the
old semantic/evaluation/OTP/test-harness modules.

## GitHub creation

Recommended repository:

```text
https://github.com/nshkrdotcom/typesafe_api_sdk
```

Recommended description:

> Minimal Elixir SDK for the TypeSafe System One API, generated from TypeSafe OpenAPI and executed through Pristine.

Recommended topics, in this order (20 total; keep `nshkr-ai-infra` last):

```text
elixir
beam
otp
api-client
sdk
typesafe
system-one
pristine
openapi
code-generation
rest-api
typed-api
noul
choice
score
inference
decision-models
hex
hexpm
nshkr-ai-infra
```

Example creation after local verification:

```bash
git init
git add .
git commit -m 'feat: initial TypeSafe API SDK 0.1.0'
gh repo create nshkrdotcom/typesafe_api_sdk \
  --public \
  --source=. \
  --remote=origin \
  --description 'Minimal Elixir SDK for the TypeSafe System One API, generated from TypeSafe OpenAPI and executed through Pristine.'
git branch -M main
git push -u origin main
```

Set topics through `gh repo edit --add-topic ...` or the GitHub UI after creation.

## Release evidence to update

Before publication, replace `VERIFICATION.md`'s pending sections with exact:

- Elixir / OTP / Mix versions;
- commands executed;
- test counts;
- generated-artifact diff status;
- package contents check;
- live gate status, if run;
- Git SHA used for the release candidate.

Do not publish until `mix typesafe_api.verify`, the normal quality gate, and Hex
package dry-run all pass in the target environment.
