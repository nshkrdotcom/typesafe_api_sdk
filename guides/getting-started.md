# Getting Started

Create a client with a TypeSafe API key:

```elixir
client = TypeSafeAPISDK.new_client(api_key: System.fetch_env!("TYPESAFE_API_KEY"))
```

Ask one or more System One questions:

```elixir
questions = %{
  relevant: TypeSafeAPISDK.noul(instructions: "Is this relevant?"),
  class: TypeSafeAPISDK.choice(%{"a" => nil, "b" => nil}),
  score: TypeSafeAPISDK.score(["low", "medium", "high"])
}

{:ok, response} = TypeSafeAPISDK.system_one(client, "state", questions)
```

Use `list_models/2` to discover model names accepted by the selected TypeSafe
endpoint. The default alias is `jev-latest`, but callers may select any model
returned by the provider.


## Verify against the real service

After offline tests are green, use a real TypeSafe key to exercise the complete
official live matrix:

```bash
export TYPESAFE_API_KEY='...'
bash scripts/live_qc.sh official
```

This hits both official operations and includes Noul, Choice, Score, tuple and
bang API forms, concrete model selection, response metadata, and safe per-call
runtime controls. See [Live Verification](live-verification.md) for alternate
endpoint verification and the deterministic failure/control matrix.
