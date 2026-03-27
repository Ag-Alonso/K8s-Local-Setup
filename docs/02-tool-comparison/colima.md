# Colima -- Lightweight Container Runtime for macOS and Linux

**Colima** is a lightweight container runtime for macOS and Linux. It provides Docker (and containerd) with minimal overhead and includes optional Kubernetes support powered by k3s.

## Table of Contents

- [How It Works](#how-it-works)
- [Pros and Cons](#pros-and-cons)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [When to Choose Colima](#when-to-choose-colima)

## How It Works

Colima runs a lightweight Linux VM using Lima (Linux Machines) and exposes the Docker socket to your host. Kubernetes is an optional feature that runs k3s inside the same VM.

```
Your Machine
  |
  +-- Colima VM (Lima)
        |
        +-- Docker daemon (or containerd)
        +-- k3s (optional, single-node Kubernetes)
              |
              +-- API server, SQLite, scheduler
              +-- kubelet, Traefik
```

The key idea behind Colima is simplicity: it replaces Docker Desktop as a container runtime with much lower overhead, and Kubernetes is available as an add-on if you need it.

## Pros and Cons

### Pros

| Advantage | Details |
|-----------|---------|
| Lightweight | Uses less RAM and CPU than Docker Desktop. Typical idle usage ~1 GB. |
| Free and open-source | No licensing concerns. Community maintained. |
| Docker Desktop replacement | Provides the Docker socket -- all Docker CLI commands work as normal. |
| Simple CLI | `colima start`, `colima stop` -- that is the entire workflow. |
| Optional Kubernetes | K8s is not loaded unless you ask for it. |
| macOS and Linux | Works on both platforms (Linux support is useful for VMs). |
| Apple Silicon native | Excellent performance on M1/M2/M3 Macs. |

### Cons

| Limitation | Impact |
|------------|--------|
| k3s-based Kubernetes | Not full upstream K8s. Some API features may be missing or different. |
| Single node only | Cannot create multi-node clusters. |
| Limited K8s features | No addons system, no built-in dashboard, minimal configuration options. |
| No Windows support | macOS and Linux only. |
| No GUI | CLI-only tool. No visual management. |
| K8s is secondary | Colima's primary purpose is container runtime, not Kubernetes. K8s support is basic. |

## Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| RAM | 2 GB free | 4 GB free (with K8s) |
| Disk | 5 GB free | 20 GB free |
| OS | macOS 12+ or Linux | macOS (Apple Silicon) |
| Docker CLI | Installed separately | `brew install docker` |

## Installation

### macOS

```bash
# Install Colima
brew install colima

# Install Docker CLI (Colima provides the daemon, not the CLI)
brew install docker

# Verify
colima version
```

### Linux

```bash
# Install Lima (Colima's backend)
brew install colima  # if using Homebrew on Linux

# Or install manually
curl -LO https://github.com/abiosoft/colima/releases/latest/download/colima-Linux-x86_64
sudo install colima-Linux-x86_64 /usr/local/bin/colima
rm colima-Linux-x86_64

# Verify
colima version
```

## Quick Start

### Start Colima with Kubernetes

```bash
# Start with Docker runtime and Kubernetes enabled
colima start --kubernetes

# Or start with specific resources
colima start --kubernetes --cpu 4 --memory 4 --disk 20
```

Expected output:

```
INFO[0000] starting colima
INFO[0000] runtime: docker
INFO[0001] creating and starting ... done
INFO[0030] starting kubernetes ... done
INFO[0045] kubernetes is running
INFO[0045] done
```

### Verify the cluster

```bash
kubectl get nodes
```

Expected output:

```
NAME     STATUS   ROLES                  AGE   VERSION
colima   Ready    control-plane,master   30s   v1.31.4+k3s1
```

### Stop and restart

```bash
# Stop Colima (preserves state)
colima stop

# Start again (resumes)
colima start --kubernetes

# Delete everything and start fresh
colima delete
colima start --kubernetes
```

### Use Docker without Kubernetes

If you just need Docker (no K8s):

```bash
colima start   # No --kubernetes flag
docker ps      # Docker works normally
```

## When to Choose Colima

Choose Colima if:

- You primarily need a lightweight Docker Desktop replacement on macOS
- You sometimes need a quick, single-node K8s cluster for testing
- You want to minimize resource usage on your Mac
- You have Docker Desktop licensing restrictions
- You prefer a CLI-only, no-frills approach

Consider kind instead if:

- You need full upstream Kubernetes
- You need multi-node clusters
- Kubernetes is your primary use case (not just an add-on)
- You want reproducible, declarative cluster configuration
- You want to learn Kubernetes in depth

Note: Colima and kind work well together. You can use Colima as your Docker runtime and kind to create Kubernetes clusters on top of it.

---

[Back to Tool Comparison](README.md) | [Back to main documentation](../README.md)
