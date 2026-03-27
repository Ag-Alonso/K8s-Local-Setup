# k3d -- k3s in Docker

**k3d** is a lightweight wrapper that runs [k3s](https://k3s.io/) (Rancher's minimal Kubernetes distribution) inside Docker containers. It is the fastest way to get a Kubernetes cluster running locally.

## Table of Contents

- [How It Works](#how-it-works)
- [Pros and Cons](#pros-and-cons)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [When to Choose k3d](#when-to-choose-k3d)

## How It Works

k3d takes the same approach as kind -- Docker containers act as Kubernetes nodes -- but instead of running full upstream Kubernetes, it runs **k3s**, a stripped-down distribution:

```
Your Machine
  |
  +-- Docker
        |
        +-- Container: k3d-server-0   (runs: k3s server -- API server, scheduler, controller, SQLite)
        |
        +-- Container: k3d-agent-0    (runs: k3s agent -- kubelet)
        |
        +-- Container: k3d-agent-1    (runs: k3s agent -- kubelet)
        |
        +-- Container: k3d-serverlb   (runs: load balancer for API and services)
```

Key differences from full Kubernetes:

- **SQLite** instead of etcd (single-server mode)
- **Flannel** for networking (built-in, not pluggable)
- **Traefik** as the default ingress controller
- **Local path provisioner** for storage
- Some Kubernetes features removed or replaced for a smaller footprint

## Pros and Cons

### Pros

| Advantage | Details |
|-----------|---------|
| Fastest startup | A cluster starts in ~20 seconds. |
| Lowest resource usage | Each node uses ~300 MB of RAM. |
| Built-in load balancer | Services of type LoadBalancer work out of the box. |
| Built-in local registry | Set up a container registry alongside the cluster with one command. |
| Multi-node support | Create clusters with multiple server and agent nodes. |
| CNCF Sandbox project | Part of the CNCF ecosystem, actively maintained. |
| Simple CLI | Intuitive commands for cluster management. |

### Cons

| Limitation | Impact |
|------------|--------|
| Not full upstream Kubernetes | k3s removes or replaces some components. Behaviors may differ from production EKS/GKE/AKS. |
| SQLite instead of etcd | Fine for learning but not representative of production storage. |
| Fewer networking options | Flannel is the default; cannot easily swap to Calico or Cilium. |
| Some API differences | Certain alpha/beta features may be missing in k3s. |
| Less CI/CD adoption | kind is more commonly used in CI pipelines for Kubernetes testing. |

## Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Docker | v20.10+ | Latest stable |
| RAM | 2 GB free | 4 GB free (for multi-node) |
| Disk | 1 GB free | 5 GB free |
| CPU | 2 cores | 4 cores |
| OS | Linux, macOS, Windows (WSL2) | Linux or macOS |

## Installation

### macOS

```bash
brew install k3d

# Verify
k3d version
```

### Linux

```bash
# Install script
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Or download binary directly (AMD64)
curl -Lo ./k3d https://github.com/k3d-io/k3d/releases/latest/download/k3d-linux-amd64
chmod +x ./k3d
sudo mv ./k3d /usr/local/bin/k3d

# Verify
k3d version
```

## Quick Start

### Create a cluster

```bash
k3d cluster create my-cluster
```

Expected output:

```
INFO[0000] Prep: Network
INFO[0000] Created network 'k3d-my-cluster'
INFO[0000] Created image volume k3d-my-cluster-images
INFO[0000] Starting new tools node...
INFO[0001] Creating node 'k3d-my-cluster-server-0'
INFO[0001] Creating LoadBalancer 'k3d-my-cluster-serverlb'
INFO[0005] Cluster 'my-cluster' created successfully!
INFO[0005] You can now use it with:
kubectl config use-context k3d-my-cluster
```

### Verify the cluster

```bash
kubectl get nodes
```

Expected output:

```
NAME                       STATUS   ROLES                  AGE   VERSION
k3d-my-cluster-server-0    Ready    control-plane,master   30s   v1.31.4+k3s1
```

### Create a multi-node cluster

```bash
# 1 server + 2 agents
k3d cluster create multi --servers 1 --agents 2
```

### Create a cluster with a local registry

```bash
# Creates a registry at k3d-registry.localhost:5000
k3d cluster create dev --registry-create k3d-registry.localhost:5000
```

### Delete a cluster

```bash
k3d cluster delete my-cluster
```

## When to Choose k3d

Choose k3d if:

- You want the fastest possible startup time
- You need the lightest possible resource footprint
- You want a built-in LoadBalancer and local registry out of the box
- You are comfortable with k3s differences from upstream Kubernetes
- Your production environment uses k3s or RKE2

Consider kind instead if:

- You are learning Kubernetes for the first time (full upstream is better for understanding)
- Your production runs EKS, GKE, or AKS (kind is more representative)
- You want full Kubernetes API conformance
- You use kind in your CI/CD pipelines and want consistency

---

[Back to Tool Comparison](README.md) | [Back to main documentation](../README.md)
