# Extraction Boundary

`typesafe_api_sdk` is a new provider-specific package extracted from the TypeSafe
wire/runtime layer of `typesafe_sdk` 0.4.0. It is not a compatibility namespace
and contains no `TypeSafeSDK.*` aliases.

## Kept here

- TypeSafe OpenAPI snapshot and generated operations/schemas.
- TypeSafe bearer-auth client configuration.
- TypeSafe retry/status policy and Pristine execution integration.
- Noul/Choice/Score wire request structs.
- typed wire responses, usage, model metadata, request IDs, and raw HTTP retention.
- normalized TypeSafe API/transport errors.
- timeout/cancellation forwarding and capability inspection.

## Moved out of the provider package

The following belong in the new provider-neutral `system_one_sdk` rather than
this API wrapper:

- strict semantic question constructors,
- JSON semantic normalization and caller-key restoration,
- Prepared question sets and fingerprints,
- evaluate/evaluate! orchestration,
- semantic response enrichment and response contracts,
- answer ranking/gating/projections,
- batch streams and task lifecycle,
- semantic telemetry,
- OTP evaluation server,
- public fixture/scenario harness,
- decision-evaluation examples and policies,
- recursive/composite/speculative decision patterns,
- provider-neutral model selection helpers.

No legacy shim is required between the two new package names. The later
`system_one_sdk` implementation should depend on `typesafe_api_sdk` through an
explicit client-provider behaviour rather than reaching into generated modules.
