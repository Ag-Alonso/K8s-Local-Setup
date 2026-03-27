# k3d Setup Guide (Alternative)

k3d is a wrapper around k3s (a lightweight Kubernetes distribution by Rancher) that runs clusters inside Docker. It is an alternative to kind with some unique features like a built-in container registry.

> **Note**: This repository is designed and tested with **kind**. If you use k3d, most exercises will work, but minor differences may apply (see [Differences from kind](#differences-from-kind) at the bottom).

## Table of Contents

- [1. Install k3d](#1-install-k3d)
- [2. Create a Cluster](#2-create-a-cluster)
- [3. Multi-Node Cluster](#3-multi-node-cluster)
- [4. Local Registry](#4-local-registry)
- [5. Port Mappings](#5-port-mappings)
- [6. Cluster Lifecycle](#6-cluster-lifecycle)
- [7. Differences from kind](#7-differences-from-kind)

---

## 1. Install k3d

### macOS

```bash
brew install k3d
```

### Linux

```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

### Verify

```bash
k3d version
```

Expected output:

```
k3d version v5.7.5
k3s version v1.30.6-k3s1 (default)
```

You also need Docker and kubectl installed. See [Prerequisites](prerequisites.md) if you have not set those up yet.

> **Checkpoint**: `k3d version` should display both the k3d and k3s versions.

---

## 2. Create a Cluster

### Using the Repository Script

```bash
./scripts/setup-k3d.sh
```

### Manual Creation

```bash
k3d cluster create k8s-local \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer" \
  --wait
```

Expected output:

```
INFO[0000] Prep: Network
INFO[0000] Created network 'k3d-k8s-local'
INFO[0000] Created image volume k3d-k8s-local-images
INFO[0000] Starting new tools node...
INFO[0001] Creating node 'k3d-k8s-local-server-0'
INFO[0001] Creating LoadBalancer 'k3d-k8s-local-serverlb'
INFO[0005] Cluster 'k8s-local' created successfully!
INFO[0005] You can now use it with: kubectl cluster-info
```

Verify:

```bash
kubectl cluster-info
kubectl get nodes
```

Expected output:

```
NAME                       STATUS   ROLES                  AGE   VERSION
k3d-k8s-local-server-0     Ready    control-plane,master   30s   v1.30.6+k3s1
```

> **Checkpoint**: You should see one node in Ready status. The version will show `k3s1` suffix, indicating this is k3s (not upstream Kubernetes).

---

## 3. Multi-Node Cluster

```bash
# Delete existing cluster first
k3d cluster delete k8s-local

# Create with 1 server + 2 agents
k3d cluster create k8s-local \
  --servers 1 \
  --agents 2 \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer" \
  --wait
```

Or use the repository script:

```bash
./scripts/setup-k3d.sh k8s-local --multi-node
```

Verify:

```bash
kubectl get nodes
```

Expected output:

```
NAME                       STATUS   ROLES                  AGE   VERSION
k3d-k8s-local-server-0     Ready    control-plane,master   30s   v1.30.6+k3s1
k3d-k8s-local-agent-0      Ready    <none>                 25s   v1.30.6+k3s1
k3d-k8s-local-agent-1      Ready    <none>                 25s   v1.30.6+k3s1
```

> **Note**: k3d uses the terms "server" (control-plane) and "agent" (worker), following k3s naming conventions.

> **Checkpoint**: Three nodes should appear in Ready status.

---

## 4. Local Registry

One of k3d's standout features is the built-in local registry, which makes it easy to use locally built images without manual loading.

### Create a Registry

```bash
k3d registry create myregistry.localhost --port 5111
```

### Create a Cluster Connected to the Registry

```bash
k3d cluster create k8s-local \
  --registry-use k3d-myregistry.localhost:5111 \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer"
```

### Push and Use Local Images

```bash
# Build and tag for the local registry
docker build -t localhost:5111/my-app:latest ./sample-apps/my-app/

# Push to the local registry
docker push localhost:5111/my-app:latest
```

Then reference in your manifests:

```yaml
spec:
  containers:
    - name: my-app
      image: k3d-myregistry.localhost:5111/my-app:latest
```

> **Checkpoint**: After pushing an image, you should be able to deploy it without any `imagePullPolicy` workarounds.

---

## 5. Port Mappings

k3d routes traffic through a built-in load balancer container. Port mappings are specified at cluster creation:

```bash
k3d cluster create k8s-local \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --port "30000-30010:30000-30010@server:0"
```

| Flag | Description |
|------|-------------|
| `8080:80@loadbalancer` | Host port 8080 -> load balancer port 80 |
| `30000-30010:30000-30010@server:0` | NodePort range on server node |

> Port mappings can only be set at cluster creation time.

---

## 6. Cluster Lifecycle

```bash
# List clusters
k3d cluster list

# Stop a cluster (keeps configuration)
k3d cluster stop k8s-local

# Start a stopped cluster
k3d cluster start k8s-local

# Delete a cluster
k3d cluster delete k8s-local

# Delete all clusters
k3d cluster delete --all
```

---

## 7. Differences from kind

Be aware of these differences when following the exercises in this repository:

| Feature | kind | k3d |
|---------|------|-----|
| Kubernetes distribution | Upstream (kubeadm) | k3s (lightweight) |
| Default CNI | kindnet | Flannel |
| Default Ingress | None (install separately) | Traefik (built-in) |
| Image loading | `kind load docker-image` | Registry or `k3d image import` |
| Load balancer | Not built-in | Built-in (via k3d proxy) |
| Node naming | `cluster-control-plane`, `cluster-worker` | `k3d-cluster-server-0`, `k3d-cluster-agent-0` |
| Kubernetes version | Matches upstream exactly | k3s version (may lag slightly) |

### Key Implications for Exercises

1. **Ingress**: k3d includes Traefik by default. Exercises that install NGINX Ingress may conflict. Disable Traefik if needed:

   ```bash
   k3d cluster create k8s-local --k3s-arg "--disable=traefik@server:0"
   ```

2. **Image loading**: Use `k3d image import` instead of `kind load docker-image`:

   ```bash
   k3d image import my-app:latest -c k8s-local
   ```

3. **Some CRDs and features**: k3s bundles certain components differently. If an exercise references a specific upstream Kubernetes component, behavior may differ slightly.

## Next Steps

Run the verification script to confirm your cluster is working:

```bash
./scripts/verify-cluster.sh
```

If you encounter issues, check the [Troubleshooting Guide](troubleshooting.md).
