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
