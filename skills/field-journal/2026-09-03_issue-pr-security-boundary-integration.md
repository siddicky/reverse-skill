# 2026-09-03 Multiple Issue/PR security boundary integration

## scene

 maintains a public security skills routing repository: the local main working tree contains a large number of user changes and lags behind the remote end. It needs to review multiple open PRs at the same time, resolve historical issues, supplement functions, release security reviews, and ensure GitHub status and cross-platform CI closed loops.

## reusable mode

1. **dirty worktree isolation:**first fetches the remote end, and then creates an independent worktree from `origin/main`; all PR merge, conflict resolution, testing and submission are completed in the isolation directory.
2. **retains the PR ownership:**and merges the accepted PR head into the integration branch as the merge commit parent submission; after the final fast forward push to main, GitHub automatically marks the corresponding PR as merged/closed.
3. **state freeze:**records the head SHA of each PR before merging; re-fetch before pushing, requiring the remote main to still be equal to the review baseline, and verifying that all accepted PR heads are ancestors of the final HEAD.
4. **AV Review under isolation:**does not rely on the working tree file for payload documents that may be isolated by Defender; use `git show :path` / Git index blob for hashing, linking and content boundary checking.
5. **reference/executable layering:**passive Markdown/JSON payload may be retained, but executable scripts must not reference it; CI fixed corpus hash, binary allowlist, symlinks, danger mode, and GitHub Action full-SHA.
6. **feature PR is not blindly matched:**In addition to running the original PR test, it also checks cross-instance status, path/port isolation and mainline new constraints. This time it was discovered that IDA keepalive files were not isolated by port, and this was corrected in the merge commit.
7. **Issue There is a basis for clearing:**Each Issue first returns the traceable conclusion, and then closes it with completed / duplicate / not_planned; do not omit explanations on the grounds of "batch cleaning".

## steps on

| Problem | Cause | Process |
|---|---|---|
| PR shows mergeable on GitHub, but there are still semantic conflicts when merging into the latest mainline. | PR base is lagging behind, and multiple PRs modify the same CI/routing file. | locally simulates merge, and reruns the full set of tests after resolving it according to the latest SSoT. |
| AV deletes the payload work tree file, causing normal scanning to miss detection | with the extension of Markdown will also hit the feature signature | reads from the Git index blob, prohibiting "skip if not read" |
| Binary Ninja MCP source is easily mistaken for the official | The MCP project is a community GPL plug-in, not an official Vector 35 component | Clarify the source, review the commit, bridge version, and loopback binding in the skill |
| Git Bash cannot equivalently simulate Linux Python → bash sub-process | Windows CreateProcess prioritizes parsing system `bash.exe`/WSL | runs Bash syntax and direct contract locally, ultimately subject to Ubuntu/macOS CI |

## validates

- routing return: 175/175
- Windows PowerShell 5.1 and PowerShell 7: P0, encoding, Evidence, IDA, smoke all passed
- Python: case-review, document link, repository security all passed
- Bash: syntax, case workflow, new Binary Ninja routing via
- GitHub: Windows, Ubuntu, macOS, Gradle Wrapper Validation all pass
- remote open Issue / PR: both are 0

## environment

- OS：Windows
- Git: isolate worktree + PR head ancestor verification
- CI：Windows、Ubuntu、macOS
- data processing: only expose repository metadata and redaction method records
