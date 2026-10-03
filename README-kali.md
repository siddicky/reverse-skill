# Kali Linux entry (short jump)

> **Please refer to [kali/README-kali.md](kali/README-kali.md)for detailed instructions.**  
> This file is only used as a quick access to Kali in the root directory of the repository to avoid repeated maintenance with the main text under`kali/`.

## AI: execute immediately after reading

```text
1. Detection package root directory (directory containing README.md/skills/)
2. Read kali/README-kali.md → read kali/RULES-kali.md and execute
3. bash kali/scripts/refresh-tool-index.sh
4. Task routing is shared with Windows: skills/MASTER-ROUTING.md, skills/ops/ (scope gate)
5. Report configuration results to users
```

## Human: 30 seconds to get started

```bash
cd /path/to/reverse-skill
bash kali/scripts/refresh-tool-index.sh
# For detailed bootstrap/MCP see kali/README-kali.md
```

## Relationship with main package

| content | location |
|------|------|
| shared skill/routing/ops |`skills/`,`RULES.md`|
| Kali script and manifest |`kali/scripts/`|
| Complete Kali documentation | **[kali/README-kali.md](kali/README-kali.md)** |

For general AI guidance, please see [README_AI.md](README_AI.md)(redirect to this directory document when selecting the Kali branch).
