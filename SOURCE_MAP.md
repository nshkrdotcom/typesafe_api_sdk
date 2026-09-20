# Source Extraction Map

This table records how the supplied `typesafe_sdk` 0.4.0 implementation was split.

| Original area | TypeSafeAPISDK disposition |
| --- | --- |
| `Client` | kept, reduced to provider/runtime configuration |
| `Constants` | kept |
| `RetryPolicy` | kept |
| `ProviderProfile` | kept |
| `ResultClassifier` | kept |
| `TransportError` / `TransportResponse` | kept |
| `Error` | kept, semantic/evaluation error families removed |
| `Noul` / `Choice` / `Score` | kept as low-level wire structs |
| answer structs | kept as wire answer structs + raw/id metadata |
| `Question` | kept only for legacy/wire normalization |
| `SystemOne` | kept, request-budget/semantic policy removed |
| `SystemOneResponse` | kept, batch/prepared/semantic enrichment fields removed |
| `Models` | kept only for `list`; automatic catalog-selection policy removed |
| `ListModelsResponse` / `ModelMetadata` | kept |
| `Generated.*` | kept and renamed |
| codegen provider/OpenAPI source | kept and renamed |
| upstream OpenAPI snapshot | kept byte-identical |
| `JSON` | removed |
| `Question.Noul/Choice/Score/Validation` | removed |
| `Prepared` | removed |
| `Evaluation` | removed |
| `SemanticResponse` | removed |
| `ResponseContract` | removed |
| `RequestBudget` | removed from this package |
| `Answer.*` helpers | removed |
| `Response` projection/helpers | removed |
| `Batch*` | removed |
| semantic `Telemetry` | removed |
| `OTP.Server` | removed |
| public `Test*` harness | removed |
| `Schema` export helpers | removed |
| decision/evaluation examples | removed |

The removed provider-neutral features are input to the subsequent
`system_one_sdk` surgical rename/refactor, not lost functionality.
