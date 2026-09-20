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
