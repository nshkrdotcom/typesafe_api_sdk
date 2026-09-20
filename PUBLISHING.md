# Publishing TypeSafeAPISDK 0.1.0

Publication is an explicit maintainer action after target-host verification.

Required order:

1. all offline quality checks green;
2. generated output regenerated/verified with pinned maintenance tooling;
3. `mix hex.build --unpack` inspected;
4. `mix hex.publish --dry-run --yes` green from the unpacked package;
5. optional live TypeSafe smoke recorded if credentials are available;
6. clean Git worktree and pushed CI green for the exact release SHA;
7. create `v0.1.0` tag;
8. publish to Hex;
9. create GitHub release.

Never refresh upstream OpenAPI or generated source as an incidental publishing
step. Those changes require their own review.


## Expanded live verification before publication

After the non-live package gates pass, verify the real official service with:

```bash
export TYPESAFE_API_KEY='...'
bash scripts/live_qc.sh official
```

This exercises both TypeSafe operations, all three wire question kinds, tuple and
bang APIs, default and explicit client configuration, concrete model selection,
request metadata, and safe per-call controls. The command makes four network/API
calls.

If an alternate TypeSafe-compatible deployment is part of the release claim, use
credentials issued specifically for that endpoint and run:

```bash
export TYPESAFE_LIVE_ALT_BASE_URL='https://provider.example/deployment/root'
export TYPESAFE_LIVE_ALT_API_KEY='...'
bash scripts/live_qc.sh alternate
```

Do not use the official credential for an alternate host unless that credential
was explicitly issued for that host. See `guides/live-verification.md` for the
full evidence matrix and the deterministic retry/cancellation/error checks that
should not be forced against a production service.
