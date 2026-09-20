# Client Configuration

`TypeSafeAPISDK.Client` owns TypeSafe-specific client configuration while
Pristine owns HTTP execution.

```elixir
client = TypeSafeAPISDK.new_client(
  api_key: "...",
  base_url: "https://api.typesafe.ai",
  model: "jev-latest",
  timeout_ms: 10_000,
  retry: [max_retries: 2],
  headers: %{"X-Application" => "my-app"}
)
```

Explicit client options override application config. The top-level project
runtime config maps `TYPESAFE_API_KEY`, `TYPESAFE_BASE_URL`,
`TYPESAFE_DEFAULT_MODEL`, and `TYPESAFE_LOG_LEVEL`.

`base_url` must be HTTP(S), include a host, and contain no URL credentials,
query, or fragment. Deployment path prefixes are preserved.

Authorization, content negotiation, SDK identity, and retry-count headers are
owned by the SDK/Pristine path and cannot be replaced through `headers:` or
per-call `extra_headers:`.


## Live alternate-deployment verification

The client accepts any credential-free HTTP(S) API root implementing the TypeSafe
`/v1/models` and `/v1/systemone` contract. To prove a particular deployment, use
its own dedicated live variables rather than reusing the official key implicitly:

```bash
export TYPESAFE_LIVE_ALT_BASE_URL='https://provider.example/deployment/root'
export TYPESAFE_LIVE_ALT_API_KEY='credential-issued-for-that-root'
export TYPESAFE_LIVE_ALT_MODEL='provider-model-id' # optional
bash scripts/live_qc.sh alternate
```

The alternate live test calls both operations. If the base URL contains a path
prefix, successful calls prove that the generated operation paths were joined to
that prefix correctly.
