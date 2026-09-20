# Models API

```elixir
{:ok, response} = TypeSafeAPISDK.list_models(client)
Enum.map(response.models, & &1.name)
```

Each model is a `TypeSafeAPISDK.ModelMetadata` with `name`, `description`, and
`release_date`. This package intentionally performs no provider-neutral ranking,
fuzzy matching, or automatic model policy; consumers select a model explicitly.
