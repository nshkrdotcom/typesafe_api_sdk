# Provider Wire Parity

This package targets the reviewed TypeSafe provider surface present in the
supplied 0.4.0 baseline:

| Operation | Method | Path | Status |
| --- | --- | --- | --- |
| System One | POST | `/v1/systemone` | implemented |
| Models | GET | `/v1/models` | implemented |

Reviewed generated component set: 12 schemas.
Authentication profile: bearer API key.
Provider runtime: Pristine.

The package is intentionally narrower than the old `typesafe_sdk` 0.4.0. Feature
parity with its provider-neutral semantic/evaluation layer is neither required
nor desired here; that work continues in `system_one_sdk`.
