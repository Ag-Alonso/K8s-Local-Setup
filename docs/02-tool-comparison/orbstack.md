# OrbStack -- Fast macOS Container and Kubernetes Runtime

**OrbStack** is a macOS-only application that provides an extremely fast and resource-efficient container runtime and Kubernetes environment. It is widely regarded as the best Docker Desktop replacement on macOS in terms of speed and user experience.

## Table of Contents

- [How It Works](#how-it-works)
- [Pros and Cons](#pros-and-cons)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [When to Choose OrbStack](#when-to-choose-orbstack)

## How It Works

OrbStack uses a custom lightweight Linux VM optimized for macOS (especially Apple Silicon). It provides both a Docker-compatible runtime and a single-node Kubernetes cluster powered by k3s.

```
macOS
  |
  +-- OrbStack VM (custom lightweight Linux)
        |
        +-- Docker-compatible runtime
        +-- k3s (single-node Kubernetes)
              |
              +-- API server, SQLite, scheduler
              +-- kubelet, Traefik
```

Key technical highlights:

- Custom VM technology with near-zero idle CPU usage
- Network integration: containers get routable IP addresses on your Mac
- File sharing is fast (much faster than Docker Desktop's virtiofs/gRPC FUSE)
- Kubernetes cluster starts almost instantly since the VM is always running

## Pros and Cons

### Pros

| Advantage | Details |
|-----------|---------|
| Extremely fast | Cluster startup in ~10 seconds. Containers start near-instantly. |
| Low resource usage | Minimal CPU usage when idle. VM uses less RAM than Docker Desktop. |
| Best macOS integration | Containers get routable IPs, fast file sharing, native notifications. |
| Great UI | Clean, modern interface for managing containers and Kubernetes. |
| Docker CLI compatible | Drop-in replacement for Docker Desktop. `docker` commands work as-is. |
| Fast file I/O | File sharing between macOS and containers is significantly faster than alternatives. |
| Automatic kubectl setup | Configures kubectl context automatically when K8s is enabled. |

### Cons

| Limitation | Impact |
|------------|--------|
| macOS only | Not available on Linux or Windows. |
| Commercial product | Free for personal use; paid license required for commercial use. |
| k3s-based Kubernetes | Not full upstream K8s. Some API differences from EKS/GKE/AKS. |
| Single node only | Cannot create multi-node clusters. |
| Closed source | Not open-source. You depend on the vendor for updates and fixes. |
| Limited K8s configuration | Cannot customize the cluster as extensively as kind or k3d. |

## Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| macOS | 13.0+ (Ventura) | Latest macOS |
| Chip | Apple Silicon or Intel | Apple Silicon (M1+) |
| RAM | 4 GB free | 8 GB free |
| Disk | 2 GB free | 10 GB free |

## Installation

### macOS

```bash
brew install --cask orbstack

# Or download from: https://orbstack.dev/
```

After installation, launch OrbStack from Applications. It will set up the Docker socket and CLI automatically.

## Quick Start

### Enable Kubernetes

1. Open OrbStack
2. Click on **Kubernetes** in the sidebar
3. Toggle **Enable Kubernetes** (or it may be enabled by default)
4. The cluster is ready in seconds

Or from the CLI:

```bash
# OrbStack configures the kubectl context automatically
kubectl get nodes
```

Expected output:

```
NAME       STATUS   ROLES                  AGE   VERSION
orbstack   Ready    control-plane,master   10s   v1.31.4+k3s1
```

### Verify Docker and Kubernetes

```bash
# Docker works as expected
docker ps
docker run hello-world

# Kubernetes is configured
kubectl cluster-info
kubectl get namespaces
```

### Access services easily

One of OrbStack's standout features is that containers and Kubernetes services get routable IP addresses:

```bash
# Deploy a service
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80

# Get the service IP (OrbStack makes this routable from macOS)
kubectl get svc nginx
```

You can also access services using OrbStack's automatic DNS: `http://nginx.default.svc.cluster.local` resolves directly from your Mac.

### Reset Kubernetes

1. Open OrbStack
2. Go to **Kubernetes**
3. Click **Reset** to get a fresh cluster

## When to Choose OrbStack

Choose OrbStack if:

- You are on macOS and want the fastest, most polished experience
- You want a Docker Desktop replacement with better performance
- You need quick, single-node Kubernetes for development
- You value great macOS integration (routable IPs, fast file sharing)
- You prefer a GUI-based workflow

Consider kind instead if:

- You need full upstream Kubernetes (not k3s)
- You need multi-node clusters
- You are on Linux or Windows
- You prefer open-source, free tools
- You want reproducible, declarative cluster configuration
- You want to learn Kubernetes in depth (kind gives you more control and mirrors production)

---

[Back to Tool Comparison](README.md) | [Back to main documentation](../README.md)
