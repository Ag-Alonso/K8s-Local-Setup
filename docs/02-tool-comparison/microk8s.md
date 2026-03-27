# MicroK8s -- Canonical's Lightweight Kubernetes

**MicroK8s** is a lightweight, production-ready Kubernetes distribution from Canonical (the company behind Ubuntu). It installs as a snap package on Linux and provides a near-full Kubernetes experience with a built-in addon system.

## Table of Contents

- [How It Works](#how-it-works)
- [Pros and Cons](#pros-and-cons)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Addons System](#addons-system)
- [When to Choose MicroK8s](#when-to-choose-microk8s)

## How It Works

Unlike kind and k3d, MicroK8s does **not** use Docker containers as nodes. Instead, it installs Kubernetes components directly on your machine (or in a VM on macOS/Windows) using snap.

```
Linux Machine
  |
  +-- snap: microk8s
        |
        +-- containerd (container runtime)
        +-- kube-apiserver
        +-- etcd (dqlite -- distributed SQLite)
        +-- kube-scheduler
        +-- kube-controller-manager
        +-- kubelet
        +-- kube-proxy
```

On macOS and Windows, MicroK8s runs inside a Multipass VM (an Ubuntu VM manager from Canonical).

Key characteristics:

- Uses **dqlite** (distributed SQLite) instead of standard etcd by default
- Can optionally use etcd for multi-node HA setups
- Ships its own container runtime (containerd), independent of Docker
- Uses its own CLI (`microk8s kubectl`) but can also configure standard `kubectl`

## Pros and Cons

### Pros

| Advantage | Details |
|-----------|---------|
| Single-command install on Ubuntu | `sudo snap install microk8s --classic` and you have Kubernetes. |
| Near-full Kubernetes | Runs most standard K8s components. Higher conformance than k3s. |
| Addon system | Enable dashboard, metrics-server, ingress, GPU support, Istio, and more. |
| Multi-node (Linux) | Can form multi-node clusters by joining Linux machines. |
| Edge and IoT ready | Designed for resource-constrained environments. |
| Automatic updates | snap handles updates automatically (can pin versions if needed). |
| Low resource usage | ~500 MB RAM for a single-node cluster. |

### Cons

| Limitation | Impact |
|------------|--------|
| Linux-focused | Best experience on Ubuntu/Linux. macOS/Windows require a Multipass VM. |
| snap dependency | Requires snap package manager. Not available on all Linux distributions natively. |
| Different CLI | Uses `microk8s kubectl` by default, which can confuse beginners. |
| Not Docker-based | Cannot use Docker workflows for cluster management. |
| dqlite vs etcd | Default storage backend differs from production clusters. |
| Networking differences | Uses Calico by default, different from some production setups. |
| Cluster formation is manual | Multi-node requires running join commands on each machine. |

## Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| RAM | 2 GB free | 4 GB free |
| Disk | 5 GB free | 20 GB free |
| OS | Ubuntu 20.04+ (snap) | Ubuntu 22.04+ |
| snap | Required on Linux | -- |
| Multipass | Required on macOS/Windows | -- |

## Installation

### Linux (Ubuntu / snap-based)

```bash
# Install MicroK8s
sudo snap install microk8s --classic

# Add your user to the microk8s group (avoids sudo for every command)
sudo usermod -a -G microk8s $USER
sudo chown -R $USER ~/.kube
newgrp microk8s

# Verify
microk8s status --wait-ready
```

### macOS

MicroK8s on macOS requires Multipass (a VM manager):

```bash
brew install ubuntu/microk8s/microk8s

# Launch
microk8s install

# Verify
microk8s status --wait-ready
```

Note: On macOS, MicroK8s runs inside a Multipass VM, which adds overhead and complexity. kind or k3d are generally better choices on macOS.

## Quick Start

### Check cluster status

```bash
microk8s status --wait-ready
```

Expected output:

```
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dns                  # CoreDNS
    ha-cluster           # Configure high availability on the current node
  disabled:
    dashboard            # The Kubernetes dashboard
    ingress              # Ingress controller for external access
    metrics-server       # K8s Metrics Server for API access to service metrics
    ...
```

### Use kubectl

```bash
# Option 1: Use MicroK8s built-in kubectl
microk8s kubectl get nodes

# Option 2: Configure standard kubectl
microk8s config > ~/.kube/config
kubectl get nodes
```

Expected output:

```
NAME          STATUS   ROLES    AGE   VERSION
my-machine    Ready    <none>   60s   v1.31.4
```

### Deploy a test workload

```bash
microk8s kubectl create deployment nginx --image=nginx
microk8s kubectl get pods
```

### Stop and start

```bash
# Stop MicroK8s (preserves state)
microk8s stop

# Start MicroK8s
microk8s start

# Full reset (removes everything)
microk8s reset
```

## Addons System

MicroK8s has a built-in addon system similar to minikube.

### List addons

```bash
microk8s status
```

### Commonly used addons

| Addon | Command | What It Does |
|-------|---------|-------------|
| dns | `microk8s enable dns` | CoreDNS for service discovery (often enabled by default) |
| dashboard | `microk8s enable dashboard` | Kubernetes Dashboard web UI |
| metrics-server | `microk8s enable metrics-server` | Resource usage metrics |
| ingress | `microk8s enable ingress` | NGINX Ingress Controller |
| storage | `microk8s enable storage` | Dynamic local storage provisioner |
| gpu | `microk8s enable gpu` | NVIDIA GPU support |
| istio | `microk8s enable istio` | Istio service mesh |

### Enable multiple addons at once

```bash
microk8s enable dns dashboard metrics-server ingress
```

## When to Choose MicroK8s

Choose MicroK8s if:

- You are on Ubuntu Linux and want a quick snap-based install
- You want a near-full Kubernetes experience with addons
- You are exploring edge computing or IoT Kubernetes
- You want to form multi-node clusters across Linux machines

Consider kind instead if:

- You are on macOS (kind runs natively in Docker, no VM needed)
- You want full upstream Kubernetes conformance
- You want Docker-based cluster management
- You need reproducible, disposable clusters
- You want consistency with CI/CD pipelines

---

[Back to Tool Comparison](README.md) | [Back to main documentation](../README.md)
