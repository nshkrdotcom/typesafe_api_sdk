# Errors and Retries

Ordinary API failures return `{:error, %TypeSafeAPISDK.Error{}}`.

HTTP errors are normalized into TypeSafe-specific categories for 400, 401, 403,
404, 422, 429, and 5xx. Connection, timeout, cancellation, and response-decoding
failures remain distinct.

The default retry policy follows the existing TypeSafe client behavior:

- at most two retries,
- HTTP 429 and 500..599 eligible by default,
- connection and timeout failures eligible by default,
- `Retry-After` honored by default.

Per-call overrides are merged structurally:

```elixir
TypeSafeAPISDK.system_one(client, state, questions,
  retry: [max_retries: 1, backoff_jitter: 0]
)
```

Use `retry: false` to disable retries for a client or one call. Pristine executes
the retries; this package only supplies the TypeSafe provider policy.
