# Generation and Verification

The runtime package consumes committed generated modules. OpenAPI generation is
maintenance-only source tooling.

Prepare the pinned Pristine maintenance checkout:

```bash
source scripts/ensure_tooling.sh
mix deps.get
```

Verify the current committed source/output relationship:

```bash
mix typesafe_api.prereq
mix typesafe_api.ir --project-root .
mix typesafe_api.verify --project-root .
```

Intentional upstream refresh:

```bash
mix typesafe_api.refresh --project-root .
mix typesafe_api.generate --project-root .
mix typesafe_api.verify --project-root .
```

The source plugin accepts exactly the two reviewed operations and 12 reviewed
schema components. New referenced schema names require explicit source review;
remote OpenAPI input never becomes arbitrary Elixir module names automatically.

The delivery environment used to build this repository did not provide
Elixir/Erlang/Mix, so `HANDOFF.md` requires regeneration/verification in the
target host before publication.
