# Cloud/K8s checklist (lite)

## IMDS
- [ ] Is SSRF reachable 169.254.169.254
- [ ] Whether to force IMDSv2
- [ ] Returned IAM role permissions panel

## K8s high risk
- [ ] cluster-admin has too many bindings
- [ ] secrets plain text environment variables
- [ ] privileged + hostPID/hostPath combination
- [ ] Anonymous auth / insecure apiserver port

## container
- [ ] Run as root
- [ ] Loadable kernel module/docker.sock mount