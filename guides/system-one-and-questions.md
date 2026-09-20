# System One Wire API

`TypeSafeAPISDK.system_one/4` is a low-level provider API call. It does not add
the richer validation, caller-key restoration, prepared sets, or evaluation
orchestration planned for `system_one_sdk`.

## Noul

```elixir
TypeSafeAPISDK.noul(
  instructions: "Is this about billing?",
  criteria: %{"true" => "Payments", "false" => "Not payments"}
)
```

## Choice

```elixir
TypeSafeAPISDK.choice(
  %{"billing" => "Payments", "technical" => "Product behavior"},
  instructions: "Which team?"
)
```

## Score

```elixir
TypeSafeAPISDK.score(
  ["low", "medium", "high"],
  instructions: "How urgent?"
)
```

Raw question maps with a nonempty `"type"` are accepted for forward-compatible
wire experimentation. Choice and Score maps require `criteria`; Score criteria
must be a nonempty list in this low-level API.

`extra_body:` intentionally preserves the low-level TypeSafe request escape
hatch and is merged after canonical state/model/questions fields. Higher-level
System One packages may impose stronger semantic rules.
