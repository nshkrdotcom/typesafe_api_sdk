<p align="center">
  <img src="assets/typesafe_api_sdk.svg" width="200" alt="TypeSafe API SDK logo" />
</p>

# TypeSafe API SDK

`typesafe_api_sdk` is the minimal Elixir client for the TypeSafe System One API.
It is generated from the reviewed TypeSafe OpenAPI surface and executes through
[Pristine](https://github.com/nshkrdotcom/pristine).

This package deliberately owns **provider-specific API mechanics only**:

- `POST /v1/systemone`
- `GET /v1/models`
- TypeSafe bearer authentication
- TypeSafe endpoint/model configuration
- Noul, Choice, and Score wire structs
- typed response decoding and raw-response retention
- normalized API/transport errors
- TypeSafe retry policy, timeouts, `Retry-After`, and Pristine cancellation forwarding
- committed OpenAPI-generated operation/schema modules
- explicit OpenAPI refresh/generate/verify maintenance tasks

It deliberately does **not** own higher-level System One semantics, prepared
question sets, evaluation orchestration, batching, OTP workflow helpers,
decision policy, local model inference, or a public fixture harness. Those belong
in the provider-neutral `system_one_sdk` and the self-hosted System One runtime.

## Installation

```elixir
def deps do
  [
    {:typesafe_api_sdk, "~> 0.1.0"}
  ]
end
```

Before publication, use a local path:

```elixir
{:typesafe_api_sdk, path: "../typesafe_api_sdk"}
```

## Quick start

```elixir
client = TypeSafeAPISDK.new_client(api_key: System.fetch_env!("TYPESAFE_API_KEY"))

questions = %{
  billing: TypeSafeAPISDK.noul(instructions: "Is this about billing?"),
  team: TypeSafeAPISDK.choice(
    %{"billing" => "Payments and invoices", "technical" => "Product behavior"},
    instructions: "Which team should inspect this?"
  ),
  urgency: TypeSafeAPISDK.score(
    ["can wait", "this week", "today"],
    instructions: "How urgent is this?"
  )
}

{:ok, response} = TypeSafeAPISDK.system_one(client, "I was charged twice.", questions)

response.answers["billing"].noul
response.answers["team"].choice
response.answers["urgency"].score
response.usage.input_tokens
```

List provider models:

```elixir
{:ok, catalog} = TypeSafeAPISDK.list_models(client)
Enum.map(catalog.models, & &1.name)
```

## Configuration

The TypeSafe provider defaults are:

```text
base URL       https://api.typesafe.ai
default model  jev-latest
timeout         10000 ms
```

Client options override application config. When this repository is the top-level
Mix project, `config/runtime.exs` recognizes:

```text
TYPESAFE_API_KEY
TYPESAFE_BASE_URL
TYPESAFE_DEFAULT_MODEL
TYPESAFE_LOG_LEVEL
```

The API key is required. `base_url` accepts credential-free HTTP(S) roots and
preserves a deployment path prefix.

## Runtime controls

Per-call request options are forwarded through the same Pristine execution path:

```elixir
TypeSafeAPISDK.system_one(client, state, questions,
  model: "jev-latest",
  timeout_ms: 5_000,
  retry: [max_retries: 1],
  extra_headers: %{"X-Trace-ID" => "trace-123"},
  cancellation: cancellation
)
```

TypeSafe authentication and SDK identity headers remain protected from caller
replacement. Pristine remains the HTTP, retry, serializer, and cancellation
runtime; this package does not implement a second transport stack.

## Architecture

```text
TypeSafeAPISDK
    |
    +-- Client / RetryPolicy / Error
    |
    +-- SystemOne ---------> Generated.SystemOne ----+
    |                                              |
    +-- Models ------------> Generated.Models ------+--> Pristine --> TypeSafe API
    |
    +-- wire structs / response decoders

maintenance only:
OpenAPI snapshot -> PristineCodegen -> committed Generated.* modules
```

See [`guides/extraction-boundary.md`](guides/extraction-boundary.md) for the
precise boundary from `typesafe_sdk` 0.4.0.

## Development

Normal runtime/test development uses the committed generated modules:

```bash
mix deps.get
mix test
mix ci
```

OpenAPI maintenance uses the pinned Pristine source checkout because
`PristineCodegen` is checkout-only tooling:

```bash
source scripts/ensure_tooling.sh
mix deps.get
mix typesafe_api.prereq
mix typesafe_api.verify --project-root .
```

To intentionally refresh upstream TypeSafe OpenAPI:

```bash
source scripts/ensure_tooling.sh
mix typesafe_api.refresh --project-root .
mix typesafe_api.generate --project-root .
mix typesafe_api.verify --project-root .
```

Review all source and generated diffs before committing a refresh.

## Project role

The intended ecosystem layering is:

```text
system_one_sdk
      |
      +-- provider adapter
              |
              v
typesafe_api_sdk
      |
      v
TypeSafe hosted System One API
```

The reverse dependency must never be introduced: `typesafe_api_sdk` must not
depend on `system_one_sdk`.

## License

MIT License. Copyright (c) 2026 nshkrdotcom.
