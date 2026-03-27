# minikube -- Official Kubernetes Learning Tool

**minikube** is the official tool from the Kubernetes project for running a local cluster. It has the richest addon ecosystem and is the most documented option for beginners.

## Table of Contents

- [How It Works](#how-it-works)
- [Pros and Cons](#pros-and-cons)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Addons System](#addons-system)
- [When to Choose minikube](#when-to-choose-minikube)

## How It Works

minikube can run Kubernetes using different **drivers** (backends):

| Driver | How It Runs Nodes | Best For |
|--------|-------------------|----------|
| docker | Docker containers (like kind) | Linux, macOS, Windows |
| qemu / hyperkit / hyperv | Virtual machines | Full OS isolation |
| podman | Podman containers | Docker-free setups |
| none | Directly on host (Linux only) | CI/CD on Linux |

By default on most systems, minikube uses the **docker** driver, which is the fastest option.

```
Your Machine
  |
  +-- Docker (or VM hypervisor)
        |
        +-- Container/VM: minikube  (runs: full Kubernetes control plane + kubelet)
        |
        +-- Container/VM: minikube-m02  (optional additional node)
```

minikube bundles a full upstream Kubernetes distribution and uses **kubeadm** for bootstrapping, similar to kind.

## Pros and Cons

### Pros

| Advantage | Details |
|-----------|---------|
| Official Kubernetes project | Maintained by kubernetes-sigs, widely documented, well-tested. |
| Rich addon system | One-command install for dashboard, metrics-server, ingress, and 30+ more. |
| Built-in dashboard | `minikube dashboard` opens the Kubernetes Dashboard in your browser. |
| Multiple drivers | Choose between Docker, VMs, or direct host. |
| Full upstream Kubernetes | Runs the same K8s as production when using docker or VM driver. |
| Built-in tunnel | `minikube tunnel` exposes LoadBalancer services to your host. |
| Cross-platform | Works on Linux, macOS, and Windows. |

### Cons

| Limitation | Impact |
|------------|--------|
| Heavier resource usage | Minimum ~2 GB RAM per node. Addons increase this. |
| Slower startup | Takes ~60 seconds for a single node. |
| Multi-node is newer | Multi-node support works but is less mature than kind. |
| Single profile complexity | Managing multiple clusters requires separate profiles. |
| VM drivers add overhead | VM-based drivers are slower and use more resources than container-based. |

## Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Docker (for docker driver) | v20.10+ | Latest stable |
| RAM | 4 GB free | 8 GB free |
| Disk | 5 GB free | 20 GB free |
| CPU | 2 cores | 4 cores |
| OS | Linux, macOS, Windows | Any |

## Installation

### macOS

```bash
brew install minikube

# Verify
minikube version
```

### Linux

```bash
# AMD64
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# ARM64
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
sudo install minikube-linux-arm64 /usr/local/bin/minikube
rm minikube-linux-arm64

# Verify
minikube version
```

## Quick Start

### Create a cluster

```bash
# Start with default settings (docker driver, single node)
minikube start
```

Expected output:

```
* minikube v1.34.0 on Darwin
* Automatically selected the docker driver
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.45 ...
* Creating docker container (CPUs=2, Memory=4096MB) ...
* Preparing Kubernetes v1.32.0 on Docker ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* kubectl is now configured to use "minikube" cluster
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace
```

### Verify the cluster

```bash
kubectl get nodes
```

Expected output:

```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   60s   v1.32.0
```

### Open the dashboard

```bash
# Opens the Kubernetes Dashboard in your browser
minikube dashboard
```

### Delete the cluster

```bash
minikube delete
```

## Addons System

minikube's addon system lets you enable cluster features with a single command. This is one of its biggest strengths.

### List available addons

```bash
minikube addons list
```

### Commonly used addons

| Addon | Command | What It Does |
|-------|---------|-------------|
| dashboard | `minikube addons enable dashboard` | Web-based Kubernetes UI |
| metrics-server | `minikube addons enable metrics-server` | Enables `kubectl top` for resource usage |
| ingress | `minikube addons enable ingress` | NGINX Ingress Controller |
| ingress-dns | `minikube addons enable ingress-dns` | DNS for ingress hostnames |
| registry | `minikube addons enable registry` | Local container registry |
| storage-provisioner | Enabled by default | Dynamic volume provisioning |

### Example: enabling metrics-server

```bash
minikube addons enable metrics-server

# Wait a moment, then check resource usage
kubectl top nodes
kubectl top pods -A
```

## When to Choose minikube

Choose minikube if:

- You want built-in addons and a dashboard with zero manual setup
- You are following tutorials that use minikube (many official K8s docs do)
- You want a VM-based option for full OS isolation
- You want `minikube tunnel` for easy LoadBalancer access

Consider kind instead if:

- You want lower resource usage (~500 MB vs ~2 GB per node)
- You need reliable multi-node clusters
- You want faster startup times
- You want consistency with CI/CD pipelines

---

[Back to Tool Comparison](README.md) | [Back to main documentation](../README.md)
