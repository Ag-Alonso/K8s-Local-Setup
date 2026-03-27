# kind -- Kubernetes IN Docker (Recommended)

**kind** is a tool for running local Kubernetes clusters using Docker containers as nodes. It was primarily designed for testing Kubernetes itself, but it works perfectly for local development and learning.

This is the **recommended tool** for this course because it runs full upstream Kubernetes -- everything you learn transfers directly to production clusters.

## Table of Contents

- [How It Works](#how-it-works)
- [Pros and Cons](#pros-and-cons)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Advanced Configuration](#advanced-configuration)
- [When to Choose kind](#when-to-choose-kind)

## How It Works

kind creates Kubernetes clusters by running each node as a Docker container. Inside each container, it uses **kubeadm** to bootstrap a full Kubernetes cluster -- the same tool used to set up production clusters.

```
Your Machine
  |
  +-- Docker
        |
        +-- Container: kind-control-plane  (runs: kubelet, API server, etcd, scheduler, controller-manager)
        |
        +-- Container: kind-worker         (runs: kubelet, kube-proxy)
        |
        +-- Container: kind-worker2        (runs: kubelet, kube-proxy)
```

Key points:

- Each Docker container acts as a Kubernetes "node"
- The control plane runs full **etcd**, **kube-apiserver**, **kube-scheduler**, and **kube-controller-manager**
- Worker nodes run a real **kubelet** and **kube-proxy**
- Networking between nodes uses Docker's internal network
- Container images are loaded into the cluster using `kind load docker-image`

## Pros and Cons

### Pros

| Advantage | Details |
|-----------|---------|
| Full upstream Kubernetes | Runs the exact same K8s that EKS, GKE, and AKS use. No surprises in production. |
| Lightweight | Each node uses ~500 MB of RAM. A 3-node cluster fits in ~2 GB. |
| Fast startup | A single-node cluster starts in ~40 seconds. |
| Multi-node clusters | Easily create clusters with multiple control plane and worker nodes. |
| CI/CD standard | Widely used in GitHub Actions, GitLab CI, and other CI systems for K8s testing. |
| kubernetes-sigs project | Maintained by the Kubernetes Special Interest Groups. Active development, reliable releases. |
| Multiple clusters | Run several independent clusters simultaneously for different projects. |
| Reproducible | Configuration is declarative YAML. Share configs with your team. |

### Cons

| Limitation | Workaround |
|------------|------------|
| No built-in GUI or dashboard | Install the Kubernetes Dashboard manually, or use tools like Lens/k9s. |
| Requires Docker | Docker must be installed and running. Podman support is experimental. |
| No built-in LoadBalancer | Use MetalLB or port mappings for exposing services. |
| No persistent storage by default | Mount host directories or use a CSI driver for persistence. |
| Container-based, not VM-based | Cannot test kernel-level features or custom kernel modules. |

## Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Docker | v20.10+ | Latest stable |
| RAM | 4 GB free | 8 GB free (for multi-node) |
| Disk | 2 GB free | 10 GB free |
| CPU | 2 cores | 4 cores |
| OS | Linux, macOS, Windows (WSL2) | Linux or macOS |

## Installation

### macOS

```bash
# Using Homebrew (recommended)
brew install kind

# Verify installation
kind --version
```

### Linux

```bash
# Download the latest binary
# For AMD64
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# For ARM64
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify installation
kind --version
```

### Also install kubectl

kubectl is the command-line tool for interacting with Kubernetes. You will need it regardless of which local K8s tool you use.

```bash
# macOS
brew install kubectl

# Linux (AMD64)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# Verify
kubectl version --client
```

## Quick Start

### Create a cluster

```bash
# Create a cluster with default settings (single control-plane node)
kind create cluster --name my-cluster
```

Expected output:

```
Creating cluster "my-cluster" ...
 ✓ Ensuring node image (kindest/node:v1.32.0) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-my-cluster"
You can now use your cluster with:

kubectl cluster-info --context kind-my-cluster
```

### Verify the cluster

```bash
# Check cluster info
kubectl cluster-info

# List nodes
kubectl get nodes
```

Expected output:

```
NAME                       STATUS   ROLES           AGE   VERSION
my-cluster-control-plane   Ready    control-plane   60s   v1.32.0
```

### Run a test workload

```bash
# Deploy nginx
kubectl create deployment nginx --image=nginx

# Check pod status
kubectl get pods
```

Expected output:

```
NAME                     READY   STATUS    RESTARTS   AGE
nginx-676b6c5db-abc12    1/1     Running   0          30s
```

### Delete the cluster

```bash
kind delete cluster --name my-cluster
```

## Advanced Configuration

### Multi-node cluster

Create a file called `kind-config.yaml`:

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

```bash
kind create cluster --name multi-node --config kind-config.yaml
```

Verify:

```bash
kubectl get nodes
```

Expected output:

```
NAME                       STATUS   ROLES           AGE   VERSION
multi-node-control-plane   Ready    control-plane   60s   v1.32.0
multi-node-worker          Ready    <none>          40s   v1.32.0
multi-node-worker2         Ready    <none>          40s   v1.32.0
```

### Port mappings

To access services running in the cluster from your host machine, configure port mappings on the control-plane node:

```yaml
# kind-config-with-ports.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30000   # NodePort on the K8s node
        hostPort: 30000        # Port on your machine
        protocol: TCP
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
  - role: worker
  - role: worker
```

### Ingress controller setup

To use Ingress resources, install an ingress controller after creating the cluster with port mappings:

```bash
# Create cluster with port 80 and 443 mapped
kind create cluster --name ingress-demo --config kind-config-with-ports.yaml

# Install NGINX Ingress Controller for kind
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for the controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

### Loading local Docker images

If you build Docker images locally, you need to load them into the kind cluster:

```bash
# Build your image
docker build -t my-app:latest .

# Load it into the kind cluster
kind load docker-image my-app:latest --name my-cluster

# Now you can reference it in your manifests (set imagePullPolicy: Never or IfNotPresent)
```

### Managing multiple clusters

```bash
# Create two separate clusters
kind create cluster --name dev
kind create cluster --name staging

# List all kind clusters
kind get clusters

# Switch between clusters
kubectl config use-context kind-dev
kubectl config use-context kind-staging

# Delete a specific cluster
kind delete cluster --name dev
```

## When to Choose kind

Choose kind if:

- You are learning Kubernetes and want to understand the real thing
- You need multi-node clusters on a laptop
- You want your local setup to match production behavior
- You use CI/CD and want the same tool locally and in pipelines
- You want a lightweight, fast, and reproducible setup

Consider alternatives if:

- You need a GUI-based experience (see [OrbStack](orbstack.md) or [Rancher Desktop](rancher-desktop.md))
- You want built-in addons like a dashboard out of the box (see [minikube](minikube.md))
- You need the absolute fastest startup time (see [k3d](k3d.md) or [OrbStack](orbstack.md))

## Next Steps

Follow the detailed setup guide for this course: [kind Setup Guide](../03-setup-guides/kind-setup.md)

---

[Back to Tool Comparison](README.md) | [Back to main documentation](../README.md)
