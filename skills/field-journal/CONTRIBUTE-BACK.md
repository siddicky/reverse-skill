# Community Evolution: Contribute experience to the main repository

## Mechanism description

Each time you complete a project and generate a field-journal entry, the AI ​​will ask:

```
✅ Experience has been recorded in field-journal/

📤 Do you want to contribute this experience to the community main repository?
- The data has been desensitized as required by the template (domain name/IP/Token/PII has been replaced)
- Only new files in the field-journal/ directory will be submitted
- Your private files such as tool-index, scope, and findings will not be submitted.
- After you contribute, other users can also reuse your experience.

Reply “yes” to submit or “no” to skip.
```

## Contribution process

```text
1. AI generated field-journal entries (desensitized)
2. AI asks users if they want to contribute
3. User consent → AI performs the following steps:
   a. Verify anonymization is complete (double-check that no real domain, IP, or token remains)
   b. Check for duplicate entries in the main repository (read only _index.md, ~200 tokens)
   c. If no duplicate exists → create a PR to the main repository
   d. PR title format: [field-journal] YYYY-MM-DD scenario type - keywords
4. GitHub Actions automatic review:
   - ✓ Only field-journal/*.md has been modified
   - ✓ No prompt injection feature
   - ✓ No API key/token that has not been desensitized
   - ✓ No executable code
   - ✓ File size < 50KB
5. Approved → Automatically merged (no manual operation required by the warehouse maintainer)
6. Review failed → Automatic comment explaining the reason, PR remains open waiting for correction
```

### Security

| Threat | Protection |
|------|------|
| Modify non-journal files | Actions Check changed files Whitelist |
| Prompt injection | Regular detection of "ignore previous"/"you are now" and other features |
| Malicious Code Disguise | Detection`#!/`,`import`,`exec(`,`eval(`, etc. |
| unredacted token | Regular detection AWS key/npm token/GitHub token pattern |
| Junk data | Single file 50KB upper limit |
| A lot of rubbish PR | GitHub comes with rate limit + you can add CODEOWNERS for review |

## Technical implementation

### Option 1: GitHub CLI (recommended)

```bash
# 1. Fork the main repository (if you haven’t forked it yet)
gh repo fork &lt;your-GitHub-username&gt;/&lt;repository-name&gt; --clone=false

# 2. Create a contribution branch locally
git checkout -b contribute/journal-YYYY-MM-DD-keyword

# 3. Add only the field-journal file
git add skills/field-journal/YYYY-MM-DD_*.md
git add skills/field-journal/_index.md

# 4. Submit
git commit -m "[field-journal] scenario-type: keyword-summary"

# 5. Push to fork
git push origin contribute/journal-YYYY-MM-DD-keyword

# 6. Create a PR
gh pr create --repo &lt;your-GitHub-username&gt;/&lt;repository-name&gt; \
  --title "[field-journal] YYYY-MM-DD scenario-type - keywords" \
  --body "## Contribution\n- Scenario: xxx\n- Keywords: xxx\n- Anonymization confirmed: ✓\n\n## Data safety statement\nThis entry has been anonymized as required by the template and contains no real target information."
```

### Method 2: Push directly (if the user has write permissions to the main repository)

```bash
git checkout -b contribute/journal-YYYY-MM-DD-keyword
git add skills/field-journal/YYYY-MM-DD_*.md
git add skills/field-journal/_index.md
git commit -m "[field-journal] scenario-type: keyword-summary"
git push origin contribute/journal-YYYY-MM-DD-keyword
gh pr create --repo &lt;your-GitHub-username&gt;/&lt;repository-name&gt; \
  --title "[field-journal] YYYY-MM-DD scenario-type - keywords" \
  --body "Anonymization confirmed: ✓"
```

## Deduplication rules (low Token consumption)

AI only needs to read one file`_index.md`to remove duplicates before submitting, and does not need to read the complete content of each journal entry.

### Deduplication process

```text
1. Read field-journal/_index.md of the main repository (usually only a few dozen lines)
2. Extract this entry: scene classification + keyword list
3. Search _index.md for existing entries in similar scenarios
4. Keyword matching:
   - Overlap ≥ 3 keywords → regarded as duplicate and not submitted
   - Overlap 1-2 keywords → may be a variation, can be submitted
   - No overlap → Brand new scene, submit directly
```

### Why is this enough?

- `_index.md`format is fixed:`- [date] short name — keywords: k1, k2, k3`
- There is only one line for each item, and 100 experiences means 100 lines.
- AI only needs to do string matching and does not need to understand the complete content
- Token consumption: reading _index.md ≈ 200-500 tokens (vs reading all journals ≈ 10000+ tokens)

### If _index.md is not available

If you cannot obtain the _index.md of the main repository (network problems, etc.), submit it directly and the maintainer of the main repository will manually remove duplicates.

## Only submitted files are allowed

**Whitelist** (Only these files can appear in the PR):
- `skills/field-journal/YYYY-MM-DD_*.md`(new experience entry)
- `skills/field-journal/_index.md`(index update)

**Blacklist** (must not appear in PR):
- `tool-index.*`(contains user local path)
- `pentest-tools/templates/scope.md`(contains target information)
- `pentest-tools/templates/findings.md`(contains vulnerability details)
- `pentest-tools/templates/progress.md`(including operation records)
- `.claude/`(user configuration)
- `.kiro/`(user configuration)
- Any`.env`,`*.key`,`*.pem`file

## redaction secondary examination

AI must scan the documents to be submitted before submission to confirm that they do not contain:

- [ ] Real domain name (not`example.com`/`target.example.com`)
- [ ] Real IP (not`10.x.x.x`/`192.168.x.x`)
- [ ] Token/Cookie/API Key original text
- [ ] Mobile phone number/email/username original text
- [ ] Company name/product name (if SRC target)

If it is found that any item is not redacted, submission will be stopped and the user will be prompted to modify it.

## value to users

- The experience you contribute will help other users avoid stepping into the same pitfalls
- The richer the field-journal of the main repository, the smarter the AI ​​for all users
- Your contributions will be retained in _index.md (anonymous, only scenes and keywords)
