# AGENTS.md

## Scope

`typesafe_api_sdk` is the provider-specific TypeSafe HTTP/wire SDK. Keep it small.

## Ownership rules

This repository owns:

- TypeSafe OpenAPI source review and committed generated operations/schemas;
- TypeSafe bearer authentication and endpoint/model defaults;
- TypeSafe wire question/answer models;
- TypeSafe retry/status/error normalization above Pristine;
- request timeout/cancellation forwarding to Pristine.

This repository does not own:

- provider-neutral System One semantics;
- prepared questions, semantic evaluation, batching, policy, or OTP workflows;
- self-hosted inference;
- generic HTTP/retry/cancellation implementations already owned by Pristine.

Do not add `TypeSafeSDK.*` compatibility aliases. This is a new package/namespace.

## Quality gate

Run:

```bash
bash scripts/check_handoff.sh
```

For a deliberate live check:

```bash
TYPESAFE_API_KEY=... mix test --only live
```

Never claim live or BEAM checks passed unless they were executed in the current
checkout and recorded in `VERIFICATION.md`.
