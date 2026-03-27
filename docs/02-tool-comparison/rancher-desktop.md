# Rancher Desktop -- Open-Source Docker Desktop Alternative

**Rancher Desktop** is a free, open-source application that provides container management and Kubernetes on your desktop. It is a popular alternative to Docker Desktop, particularly for users who want a GUI without licensing concerns.

## Table of Contents

- [How It Works](#how-it-works)
- [Pros and Cons](#pros-and-cons)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [When to Choose Rancher Desktop](#when-to-choose-rancher-desktop)

## How It Works

Rancher Desktop runs a lightweight VM (using Lima on macOS, WSL2 on Windows) and provides:

1. A **container runtime** -- choose between containerd or dockerd (Moby)
2. A **Kubernetes cluster** -- powered by **k3s** (Rancher's lightweight Kubernetes)

```
Your Machine
  |
  +-- Rancher Desktop VM (Lima / WSL2)
        |
        +-- Container Runtime (containerd or dockerd)
        +-- k3s (single-node Kubernetes)
              |
              +-- API server, SQLite, scheduler, controller-manager
              +-- kubelet, kube-proxy, Traefik
```

Rancher Desktop also provides:

- **rdctl** -- a CLI tool for managing Rancher Desktop
- **nerdctl** (with containerd) or **docker** CLI (with dockerd) for container operations
- A GUI for switching Kubernetes versions, managing images, and monitoring

## Pros and Cons

### Pros

| Advantage | Details |
|-----------|---------|
| Free and open-source | No licensing concerns, regardless of company size. CNCF Sandbox project. |
| GUI application | Manage Kubernetes and containers visually. |
| Choose your runtime | Switch between containerd and dockerd. |
| K8s version selection | Easily switch between Kubernetes versions from the UI. |
| Docker CLI compatible | When using dockerd, existing Docker workflows work unchanged. |
| Built-in container management | View, manage, and troubleshoot containers from the UI. |

### Cons

| Limitation | Impact |
|------------|--------|
| k3s-based Kubernetes | Not full upstream K8s. Some features may differ from EKS/GKE/AKS. |
| Single node only | Cannot create multi-node clusters. |
| macOS and Windows only | No Linux support (Linux users can use k3s directly). |
| VM overhead | The background VM uses ~2 GB RAM even when idle. |
| Slower than CLI tools | Starting/stopping is slower than kind or k3d. |
| Occasional stability issues | Being a GUI application, it can sometimes hang or need restart. |

## Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| RAM | 4 GB free | 8 GB free |
| Disk | 5 GB free | 20 GB free |
| OS | macOS 12+ or Windows 10+ | macOS (Apple Silicon) or Windows 11 |

## Installation

### macOS

```bash
brew install --cask rancher

# Or download from: https://rancherdesktop.io/
```

### Windows

Download the installer from [rancherdesktop.io](https://rancherdesktop.io/) and run it. WSL2 must be installed first.

## Quick Start

### Start Kubernetes

1. Launch Rancher Desktop
2. On first launch, choose your container runtime (dockerd recommended for compatibility)
3. Select a Kubernetes version
4. Click **OK** -- Rancher Desktop will download and start the cluster

### Verify the cluster

```bash
kubectl get nodes
```

Expected output:

```
NAME                   STATUS   ROLES                  AGE   VERSION
lima-rancher-desktop   Ready    control-plane,master   60s   v1.31.4+k3s1
```

### Manage through the GUI

Rancher Desktop provides several tabs:

- **Port Forwarding** -- Forward ports from Kubernetes services to your host
- **Images** -- View, pull, and manage container images
- **Troubleshooting** -- Reset Kubernetes, view logs, run diagnostics

### Reset Kubernetes

1. Go to **Troubleshooting** in the UI
2. Click **Reset Kubernetes**

Or using the CLI:

```bash
rdctl factory-reset
```

## When to Choose Rancher Desktop

Choose Rancher Desktop if:

- You want a free, open-source alternative to Docker Desktop with a GUI
- Your company has Docker Desktop licensing restrictions
- You prefer managing Kubernetes visually
- You need both Docker CLI and Kubernetes in one tool

Consider kind instead if:

- You need full upstream Kubernetes (not k3s)
- You need multi-node clusters
- You want lightweight, fast cluster creation
- You prefer CLI-based workflows
- You are on Linux

---

[Back to Tool Comparison](README.md) | [Back to main documentation](../README.md)
