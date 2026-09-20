# Runtime Controls

Timeouts may be configured in milliseconds or seconds:

```elixir
client = TypeSafeAPISDK.new_client(api_key: key, timeout_ms: 10_000)

TypeSafeAPISDK.system_one(client, state, questions, timeout: 2.5)
```

Cancellation uses `Pristine.Cancellation` directly:

```elixir
cancel = Pristine.Cancellation.new()

request = Task.async(fn ->
  TypeSafeAPISDK.system_one(client, state, questions, cancellation: cancel)
end)

:ok = Pristine.Cancellation.cancel(cancel)
Task.await(request)
```

Inspect transport capability declarations without issuing a TypeSafe request:

```elixir
TypeSafeAPISDK.RuntimeCapabilities.report(client)
```

A local cancellation result does not establish that a remote service never
received or began processing the request.
