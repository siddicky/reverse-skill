# Publish Checklist

> Check each item before each release. Version source of truth: The VERSION file must be consistent with the latest released version of CHANGELOG.md (CI
The version-check job automatically verifies, and any inconsistencies will be red).

## Release steps

1. [ ] Confirm that the [Unreleased] section of CHANGELOG.md is complete (Keep a Changelog group: Added / Fixed / Security / Removed)
2. [ ] Change ## [Unreleased] to ## [x.y.z] — YYYY-MM-DD, and update the comparison link from ...HEAD to the new tag
3. [ ] Synchronously update the VERSION file to x.y.z
4. [ ] Milestone versions (such as v1.0.0 / v1.1.0) are updated simultaneously in docs/RELEASE_NOTES_v<x.y.z>.md
5. [ ] Tag: git tag v<x.y.z> + git push --tags
6. [ ] Confirm that CI is all green after pushing (routing 173 benchmark + coherence + pin gate + version-check)

## Metadata synchronization (handy items for publishing)

- Add/delete bootstrap capabilities → Synchronize the capability list of RULES.md / RULES_zh.md / skills/SKILL.md (with skills/scripts/bootstrap-manifest.json as the only source of truth, currently 25 items)
- Added field-journal entry → Updated skills/field-journal/_index.md (scene classification/high frequency mode/entity inversion) and statistics
- Routing rule changes → only skills/config/routing.json (the document is maintained by the generation script or at least consistent)

> Note: The bottom of the journal entry is no longer manually maintained <!-- [Evolutionary Statistics] --> Cumulative comments (removed on 2026-08-10, the number cannot be reliably maintained), the item count is based on _index.md.
