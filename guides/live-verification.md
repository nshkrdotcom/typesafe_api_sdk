# Live Verification

The SDK has two different verification responsibilities:

1. **deterministic local contract tests** prove request construction, protected
   headers, path-prefix joining, retries, cancellation forwarding, decoding, and
   error behavior without spending API calls;
2. **real endpoint tests** prove that the same generated -> Pristine -> HTTP path
   interoperates with a live TypeSafe-compatible service.

Do not treat one as a substitute for the other.

## Official TypeSafe service

With a real TypeSafe key:

```bash
export TYPESAFE_API_KEY='...'
bash scripts/live_qc.sh official
```

This runs the `:live_official` ExUnit matrix against the SDK's actual default
service, `https://api.typesafe.ai`. It performs four billable/network operations:

- `GET /v1/models` through the tuple API;
- `POST /v1/systemone` through the tuple API with Noul + Choice + Score;
- `GET /v1/models` through `list_models!/2` with explicit client configuration;
- `POST /v1/systemone` through `system_one!/4` with an explicit concrete model,
  timeout, retry override, extra header, and the low-level `extra_body` escape
  hatch.

The tests validate model metadata, request IDs, raw HTTP status, usage, elapsed
metadata, Noul probability, Choice distribution, Score legend/distribution, and
response grouping helpers.

To force the second System One call to a particular official model:

```bash
TYPESAFE_LIVE_MODEL='jev-1.13.0' bash scripts/live_qc.sh official
```

Otherwise it selects the first concrete model returned by the official model
catalog.

## Alternate TypeSafe-compatible endpoint

Use a credential **issued for the alternate endpoint**. Do not send the official
TypeSafe key to a third-party host merely to see whether it works.

```bash
export TYPESAFE_LIVE_ALT_BASE_URL='https://provider.example/deployment/root'
export TYPESAFE_LIVE_ALT_API_KEY='credential-issued-for-that-root'
# Optional. If omitted, the first returned model is used.
export TYPESAFE_LIVE_ALT_MODEL='provider-model-id'

bash scripts/live_qc.sh alternate
```

The alternate test performs both operations against that exact API root. A path
prefix in `TYPESAFE_LIVE_ALT_BASE_URL` is retained; successful model discovery and
System One execution therefore verify the prefix against the live deployment.

Run the official and alternate matrices together with:

```bash
bash scripts/live_qc.sh all
```

## Runnable examples

The compact example exercises both operations plus all three question kinds:

```bash
TYPESAFE_API_KEY='...' mix run examples/live.exs
```

It honors `TYPESAFE_BASE_URL` and `TYPESAFE_DEFAULT_MODEL`, so it can also be used
against a deliberately selected compatible deployment.

The matrix example always runs the official endpoint first and then runs the
alternate deployment when its dedicated environment variables are present:

```bash
TYPESAFE_API_KEY='...' mix run examples/live_matrix.exs
```

## What is intentionally deterministic rather than forced against production

Some runtime behavior should not be manufactured against a billable public
service just to make a test fail on command:

| Capability | Verification |
| --- | --- |
| Actual retry loop | deterministic local transport test: retryable `529 -> 200` |
| Retry policy merge/disable | deterministic unit/integration tests + success-path live override |
| Protected auth/SDK headers | deterministic captured-request test |
| Per-call extra header | deterministic captured-request test + success-path live call |
| Cancellation forwarding | deterministic pre-cancelled Pristine token test |
| Forced timeout | transport/runtime contract; live calls only prove successful timeout configuration |
| Runtime capability declarations | `TypeSafeAPISDK.RuntimeCapabilities.report/1` fail-closed inspection |
| Path-prefix URL joining | deterministic captured URL + optional alternate live deployment |
| Invalid endpoint/key/model errors | deterministic validation/error tests; do not deliberately abuse production credentials |

This division keeps live evidence meaningful without making flaky latency tests,
provoking avoidable provider errors, or leaking one provider's credential to
another host.

## Expected result

A successful official run should report two tests and zero failures. The exact
latency/model/token values can change because they are live service results.

An alternate run exists only when `TYPESAFE_LIVE_ALT_BASE_URL` is present at test
compile time. If it is absent, the alternate test is not defined and no alternate
network request can occur.
