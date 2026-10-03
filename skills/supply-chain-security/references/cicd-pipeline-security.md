# CI/CD Pipeline Security Audit

## Pipeline attack surface

```text
Threat model (STRIDE):
□ Spoofing: Forging builds/signatures/sources
□ Tampering: Modifying source code/build products/dependencies
□ Denial: Malicious operations without audit logs
□ Information leakage: Pipeline logs/build products leak keys
□ Denial of service: exhausting CI resources/breaking builds
□ Privilege escalation: Runner escape/key theft
```

## Audit Checklist

### 1. Pipeline as Code configuration

```yaml
# GitHub Actions audit highlights
# ❌ Danger Mode
on:
  pull_request_target:  # PR trigger for accessible secrets
    types: [opened]

# ❌ Script injection
- run: echo "${{ github.event.issue.title }}"  # user input → shell

# ❌ Unrestricted token permissions
permissions: write-all

# ✅ Safe mode
on:
  pull_request:  # No secrets access
    types: [opened]

# ✅ Pin to SHA
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683

# ✅ Minimum permissions
permissions:
  contents: read
```

### 2. Key management

```bash
# Scan historical commits for keys
gitleaks detect --source . --verbose
trufflehog git file://. --only-verified

# Check Actions Secrets usage
gh secret list
# Confirmation: No hardcoded keys, regular rotation, minimum privileges

# Runtime key injection
# ✅ Use OIDC instead of long-term keys
# ✅ Secrets are exposed to specific steps only when needed
```

### 3. Build integrity

```bash
# Build traceability
# Generate immutable build records (SLSA L2+)
slsa-provenance generate --source . --output provenance.json

# Product signature
cosign sign-blob --key cosign.key artifact.tar.gz

# verify
cosign verify-blob --key cosign.pub --signature artifact.tar.gz.sig artifact.tar.gz
```

### 4. Runner security

```text
□ Do you use GitHub-hosted runner? (Recommended, new environment every time)
□ Self-hosted runner: Running in an isolated VM/container?
□ Have you ever run a fork PR? (Self-hosted runner is extremely risky)
□ Does the Runner have any network outbound restrictions?
□ Is it possible for the build cache to leak across builds?
```

### 5. Dependency pull security

```text
□ npm: package-lock.json Submit? Disable --force / --legacy-peer-deps
□ pip: requirements.txt Is the version frozen? Disable pip install <unverified source>
□ Docker: Is FROM fixed digest? disable latest tag
□ Go: go.sum Submit?
□ Private package: Is short-term token used for registry authentication?
```

## Automated inspection Pipeline

```yaml
# .github/workflows/supply-chain.yml
name: Supply Chain Security
on: [push, pull_request]

jobs:
  sca:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: SBOM Generate
        run: |
          npm install -g @cyclonedx/cdxgen
          cdxgen -o sbom.json
      
      - name: OSV Scan
        run: |
          go install github.com/google/osv-scanner/cmd/osv-scanner@latest
          osv-scanner scan --sbom sbom.json --format sarif > osv-results.sarif
      
      - name: Trivy Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs
          severity: CRITICAL,HIGH
          exit-code: 1
      
      - name: Secret Scan
        run: |
          docker run --rm -v $PWD:/src ghcr.io/gitleaks/gitleaks:latest \
            detect --source /src --verbose
      
      - name: Dependency-Track Upload
        run: |
          curl -X POST https://dtrack.example.com/api/v1/bom \
            -H "X-Api-Key: ${{ secrets.DTRACK_API_KEY }}" \
            -F "autoCreate=true" -F "project=myapp" -F "bom=@sbom.json"
```

Source: SLSA Framework, OWASP CI/CD Top 10, GitHub Security Lab
