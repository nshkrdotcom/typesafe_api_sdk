# Next Phase: SystemOneSDK Adapter Boundary

Do not add `system_one_sdk` as a dependency here.

After `typesafe_api_sdk` 0.1.0 is green in the target Elixir environment, the next
repository should define the provider-neutral client behaviour in
`system_one_contracts` / `system_one_sdk` and implement a TypeSafe adapter there.

Expected direction:

```text
system_one_sdk
    |
    +-- SystemOneSDK.Providers.TypeSafe
            |
            +-- TypeSafeAPISDK.Client
            +-- TypeSafeAPISDK.list_models/2
            +-- TypeSafeAPISDK.system_one/4
```

The adapter must translate TypeSafeAPISDK response/error values into canonical
System One contract values. It must not reach into `TypeSafeAPISDK.Generated.*`.

This package should remain independently usable by callers who only want the
literal TypeSafe API client.
