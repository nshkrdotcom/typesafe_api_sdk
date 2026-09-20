# Upstream TypeSafe API source

`openapi.json` is carried from the reviewed TypeSafe API snapshot used by the
supplied `typesafe_sdk` 0.4.0 baseline. That baseline recorded a refresh from
`https://api.typesafe.ai/openapi.json` on 2026-09-16 and review against the
supplied Python `typesafe-sdk` 0.6.0 public surface.

This repository intentionally supports the two reviewed operations:

- `POST /v1/systemone`
- `GET /v1/models`

Refresh is explicit maintenance work:

```bash
source scripts/ensure_tooling.sh
mix typesafe_api.refresh --project-root .
mix typesafe_api.generate --project-root .
mix typesafe_api.verify --project-root .
```

Review the upstream document and generated diff together. New referenced schema
names require an explicit mapping in the source plugin.
