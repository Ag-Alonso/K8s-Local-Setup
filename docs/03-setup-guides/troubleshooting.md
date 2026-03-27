# Troubleshooting Guide

This guide covers common issues you may encounter during setup and daily use. Each issue includes a description, symptoms, and step-by-step resolution.

## Table of Contents

- [Docker Issues](#docker-issues)
- [kind Issues](#kind-issues)
- [kubectl Issues](#kubectl-issues)
- [Network Issues](#network-issues)
- [macOS-Specific Issues](#macos-specific-issues)
- [Linux-Specific Issues](#linux-specific-issues)

---

## Docker Issues

### Docker Daemon Not Running

**Symptoms:**

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

**Solution:**

**Linux:**

```bash
# Check Docker service status
sudo systemctl status docker

# Start Docker if stopped
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker
```

**macOS (Docker Desktop):**

1. Open Docker Desktop from Applications
2. Wait for the whale icon in the menu bar to stop animating
3. Verify with:

```bash
docker info
```

**macOS (Colima):**

```bash
# Check Colima status
colima status

# Start if not running
colima start
```

---

### Permission Denied (Linux)

**Symptoms:**

```
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock
```

**Solution:**

```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Apply the group change (or log out and back in)
newgrp docker

# Verify
docker run --rm hello-world
```

> You must log out and log back in for the group change to take full effect. The `newgrp` command is a temporary workaround for your current terminal.

---

### Not Enough Resources

**Symptoms:**

- Docker commands are extremely slow
- Containers are killed unexpectedly (OOMKilled)
- `docker info` shows very low available memory

**Solution:**

Check available resources:

```bash
docker info | grep -E "CPUs|Total Memory"
```

Expected minimum:

```
CPUs: 2
Total Memory: 3.844GiB
```

**If resources are too low:**

- **Docker Desktop (macOS)**: Settings > Resources > increase CPUs to 4 and Memory to 8 GB
- **Colima (macOS)**: Stop and restart with more resources:

  ```bash
  colima stop
  colima start --cpu 4 --memory 8
  ```

- **Linux**: Docker uses host resources directly. Check system RAM with `free -h` and close unnecessary applications.

---

## kind Issues

### Cluster Creation Fails

**Symptoms:**

```
ERROR: failed to create cluster: failed to init node with kubeadm
```

**Possible causes and solutions:**

**Port conflict:**

```bash
# Check if ports 80 or 443 are already in use
sudo lsof -i :80
sudo lsof -i :443
```

If occupied, either stop the conflicting process or modify the kind config to use different host ports:

```yaml
extraPortMappings:
  - containerPort: 80
    hostPort: 8080    # Use 8080 instead of 80
    protocol: TCP
```

**Docker version too old:**

```bash
docker --version
```

kind requires Docker 20.10 or later. If your version is older, update Docker.

**Leftover from a previous cluster:**

```bash
# Delete any existing cluster with the same name
kind delete cluster --name k8s-local

# Clean up Docker resources
docker system prune -f

# Try creating again
./scripts/setup-kind.sh
```

---

### Nodes Not Ready

**Symptoms:**

```bash
kubectl get nodes
```

```
NAME                      STATUS     ROLES           AGE   VERSION
k8s-local-control-plane   NotReady   control-plane   10s   v1.32.2
```

**Solution:**

1. **Wait**: Nodes can take 30-60 seconds to become Ready after creation. Check again:

   ```bash
   # Wait up to 2 minutes for nodes to be ready
   kubectl wait --for=condition=Ready nodes --all --timeout=120s
   ```

2. **Check Docker resources**: The node container may not have enough resources.

   ```bash
   docker stats --no-stream
   ```

3. **Check node conditions**:

   ```bash
   kubectl describe node k8s-local-control-plane | grep -A 5 "Conditions:"
   ```

4. **Check kind node logs**:

   ```bash
   docker logs k8s-local-control-plane
   ```

5. **Export full logs for debugging**:

   ```bash
   kind export logs --name k8s-local ./kind-debug-logs/
   ```

---

### Image Pull Failures

**Symptoms:**

Pods stuck in `ImagePullBackOff` or `ErrImagePull` status:

```
NAME       READY   STATUS             RESTARTS   AGE
my-pod     0/1     ImagePullBackOff   0          2m
```

**Solution:**

1. **Check the error details**:

   ```bash
   kubectl describe pod my-pod | grep -A 10 "Events:"
   ```

2. **DNS resolution inside the cluster**:

   ```bash
   # Test DNS from inside the cluster
   kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup registry-1.docker.io
   ```

3. **For local images**, use `kind load` instead of trying to pull:

   ```bash
   kind load docker-image my-app:latest --name k8s-local
   ```

4. **Behind a proxy**, configure Docker to use your proxy settings.

---

### Pod Stuck in Pending

**Symptoms:**

```
NAME       READY   STATUS    RESTARTS   AGE
my-pod     0/1     Pending   0          5m
```

**Solution:**

```bash
# Check why the pod cannot be scheduled
kubectl describe pod my-pod | grep -A 10 "Events:"
```

Common causes:

| Event Message | Cause | Fix |
|---------------|-------|-----|
| `Insufficient cpu` | Not enough CPU on nodes | Reduce pod CPU requests or add nodes |
| `Insufficient memory` | Not enough memory on nodes | Reduce pod memory requests or increase Docker resources |
| `no nodes available to schedule pods` | Node is tainted or not ready | Check node status with `kubectl get nodes` |
| `node(s) had untolerated taint` | Pod does not tolerate node taints | Add tolerations or use worker nodes |

For the control-plane taint (common in single-node clusters):

```bash
# Check taints on the node
kubectl describe node k8s-local-control-plane | grep Taints

# kind automatically removes the control-plane taint for single-node clusters
# If it persists, remove it manually:
kubectl taint nodes k8s-local-control-plane node-role.kubernetes.io/control-plane:NoSchedule-
```

---

## kubectl Issues

### Connection Refused

**Symptoms:**

```
The connection to the server 127.0.0.1:PORT was refused - did you specify the right host or port?
```

**Solution:**

1. **Check if the cluster is running**:

   ```bash
   docker ps | grep k8s-local
   ```

   If no containers are listed, the cluster is not running. Start it:

   ```bash
   docker start k8s-local-control-plane
   # Wait 30-60 seconds, then retry
   ```

2. **Check your kubectl context**:

   ```bash
   kubectl config current-context
   ```

   If it points to a different cluster, switch:

   ```bash
   kubectl config use-context kind-k8s-local
   ```

---

### Wrong Context

**Symptoms:**

kubectl commands return unexpected results, or you see resources you did not create.

**Solution:**

```bash
# List all contexts
kubectl config get-contexts

# Switch to the correct context
kubectl config use-context kind-k8s-local

# Verify
kubectl config current-context
```

Expected output:

```
kind-k8s-local
```

> If you have kubectx installed, you can use `kubectx kind-k8s-local` for quicker switching.

---

### Permission Errors

**Symptoms:**

```
Error from server (Forbidden): pods is forbidden: User "system:anonymous" cannot list resource "pods"
```

**Solution:**

This usually means your kubeconfig credentials are incorrect or expired.

```bash
# Check kubeconfig
kubectl config view

# For kind, re-export the kubeconfig
kind export kubeconfig --name k8s-local

# Verify access
kubectl auth whoami
```

---

## Network Issues

### DNS Resolution Inside Pods

**Symptoms:**

Pods cannot resolve external hostnames. Services like `curl https://example.com` fail from inside pods.

**Solution:**

1. **Check CoreDNS is running**:

   ```bash
   kubectl get pods -n kube-system -l k8s-app=kube-dns
   ```

   Expected:

   ```
   NAME                       READY   STATUS    RESTARTS   AGE
   coredns-xxxxxxxxx-xxxxx    1/1     Running   0          10m
   coredns-xxxxxxxxx-yyyyy    1/1     Running   0          10m
   ```

2. **Test DNS from a pod**:

   ```bash
   kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default
   ```

   Expected:

   ```
   Server:    10.96.0.10
   Address:   10.96.0.10:53

   Name:      kubernetes.default
   Address:   10.96.0.1
   ```

3. **Check CoreDNS logs**:

   ```bash
   kubectl logs -n kube-system -l k8s-app=kube-dns
   ```

---

### Service Not Reachable

**Symptoms:**

`curl` or `wget` to a Service ClusterIP times out from another pod.

**Solution:**

```bash
# Verify the service exists and has endpoints
kubectl get service my-service
kubectl get endpoints my-service
```

If endpoints are empty, the service selector does not match any running pods:

```bash
# Check service selector
kubectl describe service my-service | grep Selector

# Check pod labels
kubectl get pods --show-labels
```

The service selector labels must match the pod labels exactly.

---

### Ingress Not Working

**Symptoms:**

HTTP requests to your Ingress host return connection refused or 404.

**Solution:**

1. **Check the Ingress controller is running**:

   ```bash
   kubectl get pods -n ingress-nginx
   ```

2. **Check the Ingress resource**:

   ```bash
   kubectl describe ingress my-ingress
   ```

   Look for the `Address` field and any errors in events.

3. **Verify port mappings** (kind):

   ```bash
   docker ps --format "table {{.Names}}\t{{.Ports}}" | grep k8s-local
   ```

   Ports 80 and 443 should be mapped.

4. **Test directly on the node**:

   ```bash
   docker exec k8s-local-control-plane curl -s localhost:80
   ```

---

## macOS-Specific Issues

### Docker Desktop Resource Limits

**Symptoms:**

Slow cluster creation, pods being OOMKilled, Docker Desktop becoming unresponsive.

**Solution:**

1. Open Docker Desktop
2. Click the gear icon (Settings)
3. Go to Resources
4. Set at least:
   - CPUs: **4**
   - Memory: **8 GB**
   - Disk image size: **20 GB**
5. Click "Apply & Restart"

Verify after restart:

```bash
docker info | grep -E "CPUs|Total Memory"
```

---

### Apple Silicon Compatibility

**Symptoms:**

Image pull errors mentioning `linux/amd64` platform mismatch.

**Solution:**

Most images now support arm64. If you encounter a specific image that does not:

```bash
# Check available platforms for an image
docker manifest inspect <image>:<tag> | grep architecture
```

For images without arm64 support, run under emulation:

```yaml
spec:
  containers:
    - name: my-container
      image: my-amd64-only-image:tag
  # Docker Desktop handles emulation automatically
```

> Docker Desktop on Apple Silicon includes Rosetta emulation. Performance may be slower for amd64 images.

---

### File Sharing Performance

**Symptoms:**

Volume mounts from macOS to containers are extremely slow.

**Solution:**

This is a known limitation of macOS <-> Linux filesystem bridging. Mitigations:

1. **Use VirtioFS** (Docker Desktop): Settings > General > enable "Use VirtioFS for file sharing"
2. **Colima with virtiofs**:

   ```bash
   colima start --mount-type virtiofs
   ```

3. **Avoid mounting large directories** -- mount only what you need.

---

## Linux-Specific Issues

### cgroup v2 Issues

**Symptoms:**

```
ERROR: failed to create cluster: failed to ensure docker network
```

Or kind containers fail to start properly.

**Solution:**

Check your cgroup version:

```bash
stat -fc %T /sys/fs/cgroup/
```

- `cgroup2fs` = cgroup v2 (modern, supported by Docker 20.10+)
- `tmpfs` = cgroup v1

If using cgroup v2, ensure Docker is up to date:

```bash
docker --version  # Must be 20.10+
```

If you must use cgroup v1 temporarily, add to your kernel boot parameters:

```
systemd.unified_cgroup_hierarchy=0
```

> Modern Docker and kind versions fully support cgroup v2. This issue primarily affects older installations.

---

### SELinux / AppArmor

**Symptoms:**

Permission denied errors when kind tries to create containers, or pods fail to start with security-related errors.

**Solution:**

**SELinux (Fedora/RHEL):**

```bash
# Check SELinux status
getenforce

# Temporarily set to permissive for testing
sudo setenforce 0

# If that fixes the issue, create a proper SELinux policy instead of disabling it
```

> Do not permanently disable SELinux. Use permissive mode only for testing, then create appropriate policies.

**AppArmor (Ubuntu/Debian):**

```bash
# Check AppArmor status
sudo aa-status

# If Docker profile is causing issues
sudo aa-complain /etc/apparmor.d/usr.bin.dockerd
```

---

### Firewall Rules

**Symptoms:**

Cluster creates successfully but pods cannot communicate with each other or with the API server.

**Solution:**

kind uses a Docker bridge network. Ensure your firewall allows traffic on the Docker bridge:

```bash
# Check Docker network
docker network inspect kind

# For iptables-based firewalls
sudo iptables -L -n | grep docker

# For firewalld (Fedora/RHEL)
sudo firewall-cmd --zone=trusted --add-interface=docker0 --permanent
sudo firewall-cmd --zone=trusted --add-interface=br-$(docker network inspect kind -f '{{.Id}}' | head -c 12) --permanent
sudo firewall-cmd --reload
```

**For ufw (Ubuntu):**

```bash
# Allow Docker bridge traffic
sudo ufw allow in on docker0
sudo ufw allow in on br-$(docker network inspect kind -f '{{.Id}}' | head -c 12)
```

---

## General Tips

### Reset Everything

When all else fails, start completely fresh:

```bash
# Delete all kind clusters
kind delete clusters --all

# Clean up Docker
docker system prune -af --volumes

# Recreate the cluster
./scripts/setup-kind.sh
./scripts/verify-cluster.sh
```

> **Warning**: `docker system prune -af --volumes` removes ALL Docker images, containers, and volumes. Use only if you are comfortable re-downloading everything.

### Getting More Information

When troubleshooting, gather as much information as possible:

```bash
# Cluster events (shows recent activity and errors)
kubectl get events --sort-by='.lastTimestamp' -A

# Describe a problematic resource for details
kubectl describe <resource-type> <resource-name>

# Check logs for a specific pod
kubectl logs <pod-name> -n <namespace>

# Export full kind cluster logs
kind export logs --name k8s-local ./debug-logs/
```

### Asking for Help

If you cannot resolve an issue, include this information when asking for help:

```bash
# System info
uname -a
docker --version
kubectl version --client
kind version

# Cluster state
kind get clusters
kubectl get nodes
kubectl get pods -A
kubectl get events --sort-by='.lastTimestamp' -A | tail -20
```
