<p align="center">
  <img src="assets/typesafe_api_sdk.svg" alt="TypeSafe API SDK" width="200" height="200"/>
</p>

<p align="center">
  <a href="https://hex.pm/packages/typesafe_api_sdk"><img src="https://img.shields.io/hexpm/v/typesafe_api_sdk.svg" alt="Hex.pm"/></a>
  <a href="https://hexdocs.pm/typesafe_api_sdk"><img src="https://img.shields.io/badge/hex-docs-blue.svg" alt="HexDocs"/></a>
  <a href="https://github.com/nshkrdotcom/typesafe_api_sdk"><img src="https://img.shields.io/badge/GitHub-repo-black?logo=github" alt="GitHub"/></a>
  <a href="https://hex.pm/packages/typesafe_api_sdk"><img src="https://img.shields.io/hexpm/l/typesafe_api_sdk.svg" alt="License"/></a>
</p>

# TypeSafe API SDK

> **Building with System One semantics?** New application code should use
> [`system_one_sdk`](https://github.com/nshkrdotcom/system_one_sdk), the
> provider-neutral Elixir/BEAM SDK. `typesafe_api_sdk` is the TypeSafe-specific
> API/provider SDK used by its built-in TypeSafe provider.
>

**Fast, reliable, and strongly typed Elixir client for TypeSafe AI's System One API.**

Instead of writing fragile string prompts, wrestling with token limits, or parsing unstructured JSON out of an LLM, `typesafe_api_sdk` gives you direct, probabilistic machine intelligence over structured data:

1. Provide your application state (a customer message, document, or structured map).
2. Ask targeted questions using typed primitives (`Noul`, `Choice`, and `Score`).
3. Receive validated Elixir structs with exact probabilities and answers.

Execution is powered by [Pristine](https://github.com/nshkrdotcom/pristine) for rock-solid HTTP/2 connection pooling, automatic retries with exponential backoff, and cooperative request cancellation.

---

## Quick Example

```elixir
# 1. Initialize your client
client = TypeSafeAPISDK.new_client(api_key: System.fetch_env!("TYPESAFE_API_KEY"))

# 2. Define questions with native wire primitives
questions = %{
  billing: TypeSafeAPISDK.noul(
    instructions: "Is this inquiry primarily about billing, invoices, or payment methods?"
  ),
  routing: TypeSafeAPISDK.choice(
    %{
      "tier1" => "Standard questions, password resets, basic FAQ",
      "engineering" => "Bug reports, API failures, infrastructure outages",
      "finance" => "Charge disputes, refunds, tax inquiries"
    },
    instructions: "Which team is best equipped to resolve this?"
  ),
  urgency: TypeSafeAPISDK.score(
    ["low", "medium", "critical"],
    instructions: "How urgent is the customer's request?"
  )
}

# 3. Query the model with your context
{:ok, response} = TypeSafeAPISDK.system_one(
  client,
  "Customer reports: 'Our production webhook endpoint received 500s during checkout.'",
  questions
)

# 4. Access typed answers directly
response.answers["billing"].noul           #=> false
response.answers["routing"].choice         #=> "engineering"
response.answers["urgency"].score          #=> "critical"
response.usage.input_tokens                #=> 42
```

---

## Key Highlights

- **Typed Wire Primitives**: First-class structs for every question type (`Noul`, `Choice`, `Score`) and answer type (`NoulAnswer`, `ChoiceAnswer`, `ScoreAnswer`). No string extraction or schema guessing.
- **Production-Ready HTTP Substrate**: Executes on [Pristine](https://github.com/nshkrdotcom/pristine) using Finch connection pools, HTTP/2 multiplexing, and jittered exponential backoff.
- **Resilient Retry Handling**: Automatic handling of transient 429 rate limits, 5xx server errors, and explicit server `Retry-After` headers.
- **Cooperative Cancellation**: Full integration with `Pristine.Cancellation` tokens so you can safely cancel running requests when client timeouts fire or callers disconnect.
- **Committed OpenAPI Code Generation**: Core operations and schemas are generated from reviewed TypeSafe OpenAPI specifications for exact wire fidelity.

---

## Installation

Add `typesafe_api_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:typesafe_api_sdk, "~> 0.1.0"}
  ]
end
```

Before Hex publication or in local development, use a path dependency:

```elixir
def deps do
  [
    {:typesafe_api_sdk, path: "../typesafe_api_sdk"}
  ]
end
```

---

## Question Types

TypeSafe System One answers questions probabilistically over your input state. Three fundamental primitives cover virtually any operational decision:

### 1. Noul (Boolean / Binary Decision)
Use `noul/1` when you need a definitive yes/no or true/false answer:

```elixir
question = TypeSafeAPISDK.noul(
  instructions: "Does this message contain a request to cancel an account?"
)
```

### 2. Choice (Categorical Routing)
Use `choice/2` when selecting one category from a defined set of options:

```elixir
question = TypeSafeAPISDK.choice(
  %{
    "en" => "English language text",
    "es" => "Spanish language text",
    "fr" => "French language text"
  },
  instructions: "What language is this text written in?"
)
```

### 3. Score (Ordered Spectrum)
Use `score/2` when evaluating quality, urgency, or sentiment along an ordered scale:

```elixir
question = TypeSafeAPISDK.score(
  ["minor", "moderate", "severe"],
  instructions: "Assess the severity of the reported issue."
)
```

---

## Discovering Models

TypeSafe regularly updates and optimizes its System One models. You can query available models at runtime:

```elixir
{:ok, catalog} = TypeSafeAPISDK.list_models(client)

for model <- catalog.models do
  IO.puts("#{model.name}: #{model.description} (released: #{model.release_date})")
end
```

By default, the SDK targets the `jev-latest` alias. You can override the default model on the client or per-request.

---

## Configuration

Clients can be configured with an explicit options keyword list or via application environment:

```elixir
client = TypeSafeAPISDK.new_client(
  api_key: "ts_live_...",
  base_url: "https://api.typesafe.ai",    # default
  model: "jev-latest",                   # default
  timeout_ms: 10_000,                     # 10s default
  retry: [max_retries: 2]                 # 2 retries default
)
```

### Environment Variables

When running as the root Mix application, `config/runtime.exs` automatically picks up:

| Variable | Description | Default |
|:---------|:------------|:--------|
| `TYPESAFE_API_KEY` | Your TypeSafe bearer API key | **Required** |
| `TYPESAFE_BASE_URL` | Root URL for the TypeSafe API | `https://api.typesafe.ai` |
| `TYPESAFE_DEFAULT_MODEL` | Default model alias | `jev-latest` |
| `TYPESAFE_LOG_LEVEL` | Logger level for API operations | `:info` |

---

## Runtime Controls & Resiliency

Every API call accepts per-request overrides for timeouts, custom retries, and cancellation:

```elixir
# Create a cancellation token
cancellation = Pristine.Cancellation.new()

# Execute request with custom overrides
task = Task.async(fn ->
  TypeSafeAPISDK.system_one(
    client,
    order_data,
    questions,
    model: "jev-latest",
    timeout_ms: 3_000,
    retry: [max_retries: 1],
    extra_headers: %{"X-Trace-ID" => "req_abc123"},
    cancellation: cancellation
  )
end)

# Cooperatively cancel if needed
# Pristine.Cancellation.cancel(cancellation)
result = Task.await(task)
```

---

## Architecture & Ecosystem Role

`typesafe_api_sdk` is intentionally designed as a lean, focused provider client. It sits directly on the Pristine runtime:

```text
       ┌──────────────────────────────┐
       │      Application / Domain    │
       └──────────────┬───────────────┘
                      │
                      ▼
       ┌──────────────────────────────┐
       │   system_one_sdk (Planned)   │  ◄── Orchestration, batching, OTP workflows
       └──────────────┬───────────────┘
                      │
                      ▼
 ┌──────────────────────────────────────────┐
 │             typesafe_api_sdk             │  ◄── Wire models, bearer auth,
 │  ┌────────────────────────────────────┐  │      OpenAPI schemas, status normalization
 │  │        Pristine HTTP Engine        │  │
 │  └─────────────────┬──────────────────┘  │
 └────────────────────┼─────────────────────┘
                      │
                      ▼
         [ TypeSafe System One API ]
```

- **`typesafe_api_sdk` owns**: TypeSafe OpenAPI operations, schemas, bearer authentication, wire structs (`Noul`, `Choice`, `Score`), response decoding, and status normalization.
- **Higher-level libraries own**: Domain-specific decision workflows, evaluation harnesses, speculative fan-out, batch pipelines, and OTP GenServers.

---

## Live Verification

The real-service matrix deliberately separates official TypeSafe credentials from
alternate-deployment credentials:

```bash
export TYPESAFE_API_KEY='...'
bash scripts/live_qc.sh official
```

The official matrix exercises both `/v1/models` and `/v1/systemone`, Noul, Choice,
Score, tuple and bang APIs, explicit/default model selection, request metadata,
and safe per-call controls. A separate opt-in alternate matrix verifies arbitrary
TypeSafe-compatible API roots (including deployment path prefixes) with a
credential issued for that exact root.

```bash
export TYPESAFE_LIVE_ALT_BASE_URL='https://provider.example/deployment/root'
export TYPESAFE_LIVE_ALT_API_KEY='...'
bash scripts/live_qc.sh alternate
```

See [`guides/live-verification.md`](guides/live-verification.md) for the complete
coverage matrix, including which failure/control paths are tested deterministically
rather than manufactured against a billable production service.

---

## Development & Maintenance

Clone the repository and fetch dependencies:

```bash
mix deps.get
mix test
```

### Running the Quality Gate

The quality gate validates formatting, strict Credo linter rules, Dialyzer types, documentation generation, and Hex packaging:

```bash
bash scripts/check_handoff.sh
```

### OpenAPI Refresh & Codegen

Generated code is committed directly to source control. To regenerate or verify the OpenAPI definitions against Pristine's codegen tools:

```bash
source scripts/ensure_tooling.sh
mix typesafe_api.verify --project-root .
```

---

## License

`typesafe_api_sdk` is open source software released under the [MIT License](LICENSE).
