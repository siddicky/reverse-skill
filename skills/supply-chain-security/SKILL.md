---
name: supply-chain-security
description: Use for software supply-chain security assessment covering SBOM, SCA, CI/CD pipelines, container images, build integrity, dependency provenance, and vulnerability reachability.
---
# Supply Chain Security Testing

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` - Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, do not guess the path
5. `ACT`: Enter the first step of "workflow" and execute it, do not stop in the confirmation state

> SBOM / SCA / CI/CD pipeline / dependency traceability
> Regulation driven: US Executive Order SBOM, Chinese National Standards, EU CRA

## Applicable scenarios

- Software supply chain security assessment
- Open source dependency vulnerability scanning and verification
- CI/CD Pipeline Security Audit
- Container image security analysis
- Third-party component compliance review
- Build product traceability and integrity verification

## Six-layer supply chain governance framework

```text
Layer 1: Source code trust assessment → Upstream repository/maintainer/release history review
Layer 2: Build pipeline integration → CI/CD security access control, signature verification
Layer 3: Artifact Distribution Integrity → Signatures, Checksums, SBOM Attachments
Layer 4: Runtime protection → Container scanning, admission control
Layer 5: Continuous monitoring → real-time CVE tracking, vulnerability accessibility analysis
Layer 6: Incident response → Supply chain attack contingency and rollback strategy
```

## Workflow

### 1. SBOM generation and auditing

```text
Generate SBOM:
□ CycloneDX format: cdxgen → bom.json
□ SPDX format: sbom-tool generate
□ Syft: syft <image|dir> -o spdx-json

Audit points:
□ Are there any unknown/unauthorized dependencies?
□ Are there any packages that have been abandoned/stopped maintenance?
□ License conflict detection
□ Direct dependency vs transitive dependency list
□ Release timeline and maintainer status of each component
```

### 2. Software composition analysis (SCA)

```bash
# OSV-Scanner (free, maintained by Google)
osv-scanner scan -r . --format json

# OWASP Dependency-Track (Enterprise Level Continuous Monitoring)
docker run -p 8080:8080 dependencytrack/apiserver
# → Upload SBOM → Automatically match NVD/OSV/GitHub Advisory

# Snyk (Business)
snyk test --all-projects
snyk monitor  # Continuous monitoring

# Trivy (Container + Dependencies + IaC)
trivy fs .          # File system scan
trivy image nginx   # container image
trivy config .      # IaC configuration
```

### 3. Vulnerability reachability verification

```text
SCA alert ≠ actual risk! Most SCA tools only have ~15% of alerts that are actually reachable.

Verification steps:
1. Use Dependency-Track or Trivy to obtain the CVE list
2. Screen for vulnerabilities with CVSS ≥ 7.0
3. Conduct reachability analysis on CVEs with PoC
- Code Property Graph slice: trace the path of user input to the vulnerable function
- DEPTEX method: EPD (Execution Path Dominance) + LLM semantic verification
4. Validate the PoC in an isolated environment
5. Prioritize the repair of accessible vulnerabilities according to their actual impact
```

Tool reference:
- CodeQL: GitHub code query → data flow analysis
- Snyk Code: Reachability Markers
- DEPTEX: LLM-assisted context-aware risk assessment

### 4. CI/CD Pipeline Security

```text
Security checkpoints:
□ Code submission → pre-commit hook: gitleaks (key scanning)
□ PR stage → SCA scan (Trivy/OSV-Scanner)
□ Build phase → Artifact signature (cosign)
□ Push phase → SBOM attach (syft + attest)
□ Deployment phase → Admission control (OPA/Kyverno + image scanning)
□ Runtime → Continuous vulnerability monitoring (Dependency-Track)

Pipeline safety:
□ Pipeline as Code audit (GitHub Actions / GitLab CI configuration injection)
□ Runner isolation (to prevent malicious builds from breaking through the container)
□ Key management (Actions Secrets/Vault, hard coding is prohibited)
□ Third-party action review (lock commit SHA, non-tag)
```

### 5. Container image security

```bash
# Dockerfile audit
hadolint Dockerfile

# Image scanning (multi-layer: OS + application dependencies + configuration)
trivy image --severity HIGH,CRITICAL nginx:latest

# Minimal base image
# Priority: distroless → alpine → slim → avoid latest
docker scout quickview nginx:latest

# Image signature
cosign sign --key cosign.key myimage:tag
cosign verify --key cosign.pub myimage:tag
```

### 6. Third-party dependency review

```text
Add new dependency Checklist:
□ Maintenance status: Submitted in the last 6 months? Maintainer activity?
□ Security history: Has any malicious code been implanted in the past?
□ Dependency tree: How many transitive dependencies are added after the introduction?
□ License: Compatible with project license?
□ Alternatives: Are there any safer alternatives (Snyk Advisor / Socket.dev ratings)?

Risk assessment matrix:
High maintenance × low number of dependencies × compatible license → low risk
Low maintenance × high number of dependencies × license conflicts → high risk
```

## tool chain

| Tool | Purpose | Get |
|------|------|------|
| OWASP Dependency-Track | Enterprise-level continuous SCA | `docker pull dependencytrack/apiserver` |
| OSV-Scanner | Free SCA (OSV.dev Ecosystem) | `go install github.com/google/osv-scanner` |
| Trivy | Mirror + dependency + IaC scan | `apt install trivy` |
| Syft | SBOM generates | `curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh` |
| cdxgen | CycloneDX SBOM generation | `npm install -g @cyclonedx/cdxgen` |
| Cosign | Container signature | `go install github.com/sigstore/cosign/v2/cmd/cosign` |
| Gitleaks | Key/Credential Scan | `go install github.com/gitleaks/gitleaks/v8` |
| Snyk | Commercial SCA + Reachability | `npm install -g snyk` |
| CodeQL | code query + data flow | GitHub Actions built-in |

## refer to

- `references/sbom-sca-methodology.md` — SBOM + SCA Methodology
- `references/cicd-pipeline-security.md` — CI/CD Pipeline Security Audit


## Task completion self-check (MUST passes before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real toolpaths based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?
