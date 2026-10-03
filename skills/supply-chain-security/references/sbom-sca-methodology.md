# SBOM + SCA methodology

## SBOM Standard Comparison

| standard | format | ecological | recommended scenario |
|------|------|------|---------|
| SPDX | JSON/YAML/tag-value | Linux Foundation, Yocto | License compliance priority |
| CycloneDX | JSON/XML | OWASP, Kubernetes | Security analysis is preferred |
| SWID | XML | ISO standard | Enterprise asset management |

## SBOM generation tool chain

```bash
# cdxgen: Generate CycloneDX SBOM from source code
cdxgen -o bom.json -t cyclonedx

# Syft: Generate from container/filesystem
syft nginx:latest -o spdx-json > sbom.spdx.json

# SBOM-Tool: Microsoft Toolchain
sbom-tool generate -b ./build -bc ./src -pn MyApp -pv 1.0
```

## SCA tool comparison

| Tools | Free | Speed ​​| Database | Reachability |
|------|:--:|------|--------|:--:|
| OSV-Scanner | ✅ | Extremely fast | OSV.dev | ❌ |
| Trivy | ✅ | Fast | Multi Source | ❌ |
| Dependency-Track | ✅ | Medium | NVD+OSV+GitHub | ❌ (plug-in required) |
| Snyk | ❌ | Medium | Proprietary | ✅ |
| CodeQL | ✅ | slow | code level | ✅ |

## Vulnerability prioritization strategy

```
CVSS ≥ 9.0 + Public PoC + Reachable → P0 Fixed immediately
CVSS ≥ 7.0 + PoC available + Reachable → P1 Fixed this week
CVSS ≥ 7.0 + No PoC or unreachable → P2 fixed in next iteration
The rest → follow the normal process
```

## Manual verification three-step method

```bash
# 1. Confirm the version (do not blindly trust the SBOM field)
# Within the container: dpkg -l | grep <package>
# Node: cat node_modules/<pkg>/package.json | jq .version
# Python: pip show <package>

# 2. Confirm the vulnerability
# Search CVE: https://osv.dev / https://nvd.nist.gov
# Check the affected version range
# Find the GitHub Advisory/oss-security mailing list

# 3. Verify the impact
# Search public PoC: GitHub/Exploit-DB
# Analyze utilization conditions: whether authentication/local access/specific configuration is required
# Verify in an isolated environment: docker run --rm -it vulnerable-image bash
```

## Continuous monitoring

```yaml
# Daily SBOM updates + scans
schedule:
  - cron: "0 6 * * *"  # every day at 6 o’clock
    steps:
      - cdxgen -o bom.json
      - osv-scanner scan --sbom bom.json
      - trivy fs --exit-code 1 --severity CRITICAL .
```

Source: OWASP CycloneDX, SPDX, Google OSV, CISA SBOM Guidance
