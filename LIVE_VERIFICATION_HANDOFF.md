# Live Verification Overlay Handoff

This overlay expands `typesafe_api_sdk` 0.1.0 verification without changing the
production client/runtime modules.

## Apply

Unzip the overlay at the repository root, then run:

```bash
elixir scripts/apply_live_overlay.exs
mix format
bash scripts/refresh_manifest.sh
bash scripts/check_handoff.sh
```

The manifest refresh is intentionally performed on the target checkout because
that checkout already contains post-extraction fixes and the redesigned SVG. A
precomputed manifest from another checkout would be incorrect.

## Official TypeSafe live gate

```bash
export TYPESAFE_API_KEY='...'
bash scripts/live_qc.sh official
```

Expected network budget: **four calls** total (two model-list + two System One).
Both System One calls contain Noul, Choice, and Score questions.

For one explicit concrete model:

```bash
TYPESAFE_LIVE_MODEL='jev-1.13.0' bash scripts/live_qc.sh official
```

Otherwise the bang-path test selects the first model returned by the catalog.

## Alternate endpoint gate

Only run this with a credential issued for the exact alternate endpoint:

```bash
export TYPESAFE_LIVE_ALT_BASE_URL='https://provider.example/deployment/root'
export TYPESAFE_LIVE_ALT_API_KEY='...'
# optional:
export TYPESAFE_LIVE_ALT_MODEL='provider-model-id'

bash scripts/live_qc.sh alternate
```

Expected network budget: **two calls** (one model-list + one System One).

## Examples

```bash
TYPESAFE_API_KEY='...' mix run examples/live.exs
TYPESAFE_API_KEY='...' mix run examples/live_matrix.exs
```

`live.exs` honors the established `TYPESAFE_BASE_URL` and
`TYPESAFE_DEFAULT_MODEL` example variables. `live_matrix.exs` uses dedicated
alternate credentials when configured so the official credential is never
silently redirected to another host.

## Coverage added

Real official endpoint:

- `GET /v1/models`
- `POST /v1/systemone`
- Noul, Choice, Score
- tuple APIs
- bang APIs
- default endpoint/model
- explicit endpoint/model/client headers/timeout/retry configuration
- per-call model, timeout, retry, extra headers, `extra_body`
- request ID, raw HTTP response, token usage, elapsed/retry metadata
- response grouping helpers

Optional real alternate endpoint:

- separate arbitrary API key
- arbitrary HTTP(S) TypeSafe-compatible root
- deployment path prefix
- explicit or discovered model
- both operations
- all three question kinds

Deterministic local tests:

- protected per-call auth/identity headers
- custom per-call header forwarding
- actual Pristine retry sequence (`529 -> 200`)
- pre-cancelled token forwarding through a dedicated test-only cancellation transport/normalization without egress
- fail-closed runtime capability report

The suite intentionally does not manufacture a production timeout, rate limit, or
5xx merely to observe failure. Those conditions are controlled deterministically.

## Final target-host commands

```bash
mix format --check-formatted
mix test --warnings-as-errors
mix credo --strict
mix dialyzer
mix docs --warnings-as-errors
bash scripts/check_handoff.sh

export TYPESAFE_API_KEY='...'
bash scripts/live_qc.sh official

# Optional compatible alternate deployment:
# bash scripts/live_qc.sh alternate

git diff --check
git status --short
```

Review the diff, update `VERIFICATION.md` with the observed live model/request/token
results if desired, then commit and push. No version bump is required merely for
this pre-release verification expansion unless 0.1.0 has already been published.
