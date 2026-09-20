# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-09-19

### Added

- Initial standalone `typesafe_api_sdk` release candidate extracted from the
  provider-specific wire/runtime layer of `typesafe_sdk` 0.4.0.
- TypeSafe `POST /v1/systemone` and `GET /v1/models` operations over Pristine.
- TypeSafe bearer authentication, endpoint/model configuration, retries,
  timeouts, cancellation forwarding, and runtime capability inspection.
- Wire-oriented Noul, Choice, and Score request structs and typed answer models.
- TypeSafe response/error normalization with request IDs and raw HTTP retention.
- Committed generated operations/schemas plus TypeSafe OpenAPI maintenance tasks.
- Offline tests, optional real-service live test, CI, Hex packaging metadata,
  detailed guides, and target-host handoff procedures.

### Intentionally excluded

- Prepared/evaluate semantic APIs.
- batch/stream orchestration.
- OTP evaluation server.
- semantic answer helpers and policy/evaluation workflows.
- public fixture/test harness.
- local/self-hosted model inference.

Those concerns move to the provider-neutral System One ecosystem rather than this
provider-specific API package.
