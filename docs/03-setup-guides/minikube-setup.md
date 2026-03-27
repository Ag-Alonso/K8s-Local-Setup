# minikube Setup Guide (Alternative)

minikube is a popular local Kubernetes tool that creates a cluster inside a virtual machine or Docker container. It is known for its built-in dashboard, easy addon system, and broad platform support.

> **Note**: This repository is designed and tested with **kind**. If you use minikube, most exercises will work, but minor differences may apply (see [Differences from kind](#differences-from-kind) at the bottom).

## Table of Contents

- [1. Install minikube](#1-install-minikube)
- [2. Create a Cluster](#2-create-a-cluster)
- [3. Dashboard](#3-dashboard)
- [4. Addons](#4-addons)
- [5. Multi-Node Cluster](#5-multi-node-cluster)
- [6. Tunnel for LoadBalancer Services](#6-tunnel-for-loadbalancer-services)
- [7. Cluster Lifecycle](#7-cluster-lifecycle)
- [8. Differences from kind](#8-differences-from-kind)

---

## 1. Install minikube

### macOS

```bash
brew install minikube
```

### Linux

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
```

> For arm64, replace `minikube-linux-amd64` with `minikube-linux-arm64`.

### Verify

```bash
minikube version
```

Expected output:

```
minikube version: v1.35.0
commit: xxxxxxxxxxxxxxxxxxxxxxx
```

You also need Docker and kubectl installed. See [Prerequisites](prerequisites.md) if you have not set those up yet.

> **Checkpoint**: `minikube version` should display the version. Any version 1.30+ will work.

---

## 2. Create a Cluster

### Using the Repository Script

```bash
./scripts/setup-minikube.sh
```

### Manual Creation

```bash
minikube start \
  -p k8s-local \
  --driver=docker \
  --cpus=2 \
  --memory=2048
```

Expected output:

```
* [k8s-local] minikube v1.35.0 on Darwin arm64
* Using the docker driver based on user configuration
* Starting "k8s-local" primary control-plane node in "k8s-local" cluster
* Pulling base image v0.0.45 ...
* Creating docker container (CPUs=2, Memory=2048MB) ...
* Preparing Kubernetes v1.32.0 on Docker 27.5.0 ...
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring bridge CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* kubectl is now configured to use "k8s-local" cluster and "default" namespace by default
```

Verify:

```bash
kubectl get nodes
```

Expected output:

```
NAME        STATUS   ROLES           AGE   VERSION
k8s-local   Ready    control-plane   30s   v1.32.0
```

> **Checkpoint**: One node should appear in Ready status. The context is automatically set.

---

## 3. Dashboard

minikube includes a web-based Kubernetes dashboard -- useful for visually exploring your cluster.

```bash
minikube dashboard -p k8s-local
```

Expected output:

```
* Enabling dashboard ...
  - Using image docker.io/kubernetesui/dashboard:v2.7.0
  - Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
* Verifying dashboard health ...
* Launching proxy ...
* Opening http://127.0.0.1:XXXXX/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```

The dashboard opens automatically in your browser. Press `Ctrl+C` to stop the proxy when done.

> The dashboard is for exploration only. All exercises in this repository use kubectl commands to build muscle memory with the CLI.

---

## 4. Addons

minikube has a built-in addon system for common extensions. The repository setup script enables these automatically:

```bash
# List available addons
minikube addons list -p k8s-local
```

### Enable Recommended Addons

```bash
# Metrics server (needed for `kubectl top` and HPA)
minikube addons enable metrics-server -p k8s-local

# Ingress controller (NGINX)
minikube addons enable ingress -p k8s-local
```

Verify addons:

```bash
minikube addons list -p k8s-local | grep -E "metrics-server|ingress"
```

Expected output:

```
| ingress                     | minikube | enabled  |
| metrics-server              | minikube | enabled  |
```

Other useful addons:

| Addon | Purpose | Command |
|-------|---------|---------|
| `ingress-dns` | DNS for ingress hosts | `minikube addons enable ingress-dns` |
| `registry` | Local container registry | `minikube addons enable registry` |
| `dashboard` | Web UI (enabled by default with `minikube dashboard`) | `minikube addons enable dashboard` |

> **Checkpoint**: Both `metrics-server` and `ingress` should show as "enabled" in the addon list.

---

## 5. Multi-Node Cluster

```bash
# Delete existing cluster first
minikube delete -p k8s-local

# Create a 3-node cluster
minikube start \
  -p k8s-local \
  --driver=docker \
  --nodes=3 \
  --cpus=2 \
  --memory=2048
```

Or use the repository script:

```bash
./scripts/setup-minikube.sh k8s-local --multi-node
```

Verify:

```bash
kubectl get nodes
```

Expected output:

```
NAME            STATUS   ROLES           AGE   VERSION
k8s-local       Ready    control-plane   60s   v1.32.0
k8s-local-m02   Ready    <none>          45s   v1.32.0
k8s-local-m03   Ready    <none>          30s   v1.32.0
```

> **Resource note**: Each node allocates 2 CPUs and 2 GB RAM. Three nodes require 6 CPUs and 6 GB RAM from your system.

> **Checkpoint**: Three nodes should appear in Ready status.

---

## 6. Tunnel for LoadBalancer Services

In a cloud environment, LoadBalancer services get an external IP automatically. Locally, minikube provides a tunnel to simulate this:

```bash
# Run in a separate terminal (keeps running)
minikube tunnel -p k8s-local
```

Expected output:

```
Status:
  machine: k8s-local
  pid: 12345
  route: 10.96.0.0/12 -> 192.168.49.2
  minikube: Running
  services: []
    errors:
      minikube: no errors
      router: no errors
      loadbalancer emulator: no errors
```

> This command requires `sudo` on Linux. It must keep running in a separate terminal window.

With the tunnel active, LoadBalancer services will receive an external IP:

```bash
kubectl get service my-loadbalancer-service
```

```
NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
my-loadbalancer-service   LoadBalancer   10.96.100.50   10.96.100.50   80:30123/TCP   1m
```

---

## 7. Cluster Lifecycle

```bash
# Check cluster status
minikube status -p k8s-local

# Stop the cluster (preserves state)
minikube stop -p k8s-local

# Start a stopped cluster
minikube start -p k8s-local

# Delete the cluster completely
minikube delete -p k8s-local

# Delete all profiles
minikube delete --all
```

### Using Local Docker Images

minikube has its own Docker daemon. To use locally built images, point your Docker CLI to it:

```bash
eval $(minikube docker-env -p k8s-local)

# Now docker build will build inside minikube
docker build -t my-app:latest ./sample-apps/my-app/
```

> After running `eval $(minikube docker-env)`, all docker commands in that terminal affect minikube's Docker, not your host Docker. Open a new terminal to return to host Docker.

---

## 8. Differences from kind

| Feature | kind | minikube |
|---------|------|----------|
| Runtime | Docker containers | Docker containers (or VM) |
| Dashboard | Not included | Built-in (`minikube dashboard`) |
| Addons | Manual installation | Built-in addon system |
| Image loading | `kind load docker-image` | `eval $(minikube docker-env)` + build |
| LoadBalancer | Not supported natively | `minikube tunnel` |
| Node naming | `cluster-control-plane`, `cluster-worker` | `cluster`, `cluster-m02`, `cluster-m03` |
| Resource config | Via Docker Desktop settings | `--cpus` and `--memory` flags |
| Cluster start speed | Fast (seconds) | Moderate (30-60 seconds) |

### Key Implications for Exercises

1. **Ingress**: minikube uses its addon system. Use `minikube addons enable ingress` instead of installing NGINX manually.

2. **Image loading**: Use `minikube docker-env` to build images inside minikube's Docker daemon, or use `minikube image load my-app:latest`.

3. **NodePort access**: minikube provides `minikube service <name> -p k8s-local` to open NodePort services in your browser.

## Next Steps

Run the verification script to confirm your cluster is working:

```bash
./scripts/verify-cluster.sh
```

If you encounter issues, check the [Troubleshooting Guide](troubleshooting.md).
