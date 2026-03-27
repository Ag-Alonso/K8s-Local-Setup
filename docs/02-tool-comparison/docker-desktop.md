# Docker Desktop -- Built-in Kubernetes

**Docker Desktop** includes a built-in single-node Kubernetes cluster that you can enable with one click. If you already use Docker Desktop, this is the zero-effort way to get Kubernetes running.

## Table of Contents

- [How It Works](#how-it-works)
- [Pros and Cons](#pros-and-cons)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [License Considerations](#license-considerations)
- [When to Choose Docker Desktop](#when-to-choose-docker-desktop)

## How It Works

Docker Desktop runs a lightweight Linux VM on macOS and Windows (using Apple's Virtualization framework or WSL2). When you enable Kubernetes in the settings, it runs a single-node cluster inside that VM.

```
Your Machine
  |
  +-- Docker Desktop VM
        |
        +-- Docker Engine
        +-- Kubernetes (single node: control plane + worker)
              |
              +-- API server, etcd, scheduler, controller-manager
              +-- kubelet, kube-proxy
```

The Kubernetes cluster shares the Docker daemon, so images you build with `docker build` are immediately available to Kubernetes without any extra loading step.

## Pros and Cons

### Pros

| Advantage | Details |
|-----------|---------|
| Zero extra installation | If you already have Docker Desktop, just enable K8s in settings. |
| Shared Docker daemon | Images built locally are available to K8s immediately. |
| GUI management | Start, stop, and reset Kubernetes from the Docker Desktop UI. |
| Full upstream Kubernetes | Runs real Kubernetes, not a stripped-down version. |
| Cross-platform | Works on macOS, Windows, and Linux. |

### Cons

| Limitation | Impact |
|------------|--------|
| Single node only | Cannot practice multi-node scenarios like scheduling or node failure. |
| Tied to Docker Desktop | Cannot run K8s independently of Docker Desktop. |
| Heavier resource usage | Docker Desktop VM uses ~2 GB RAM minimum, plus K8s overhead. |
| Slower K8s updates | Kubernetes version updates lag behind upstream releases. |
| Limited configuration | Cannot customize the cluster configuration the way kind or k3d allow. |
| No cluster-level reset | Resetting K8s resets everything; no selective cleanup. |

## Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Docker Desktop | v4.0+ | Latest stable |
| RAM | 4 GB allocated to Docker Desktop | 6 GB allocated |
| Disk | 5 GB free | 20 GB free |
| OS | macOS 12+, Windows 10+, Linux | macOS or Windows |

## Quick Start

### Enable Kubernetes

1. Open Docker Desktop
2. Go to **Settings** (gear icon)
3. Select **Kubernetes** in the left sidebar
4. Check **Enable Kubernetes**
5. Click **Apply & Restart**
6. Wait for the Kubernetes status indicator to turn green (this may take 2-3 minutes on first enable)

### Verify the cluster

```bash
# Check that the context is set
kubectl config current-context
```

Expected output:

```
docker-desktop
```

```bash
# List nodes
kubectl get nodes
```

Expected output:

```
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   60s   v1.31.4
```

### Reset Kubernetes

If you need a fresh cluster:

1. Open Docker Desktop Settings
2. Go to **Kubernetes**
3. Click **Reset Kubernetes Cluster**

This removes all workloads, configurations, and persistent data.

## License Considerations

Docker Desktop has a subscription model:

| Use Case | License Required |
|----------|-----------------|
| Personal use | Free (Docker Personal) |
| Education / open source | Free (Docker Personal) |
| Small business (< 250 employees AND < $10M revenue) | Free (Docker Personal) |
| Enterprise (>= 250 employees OR >= $10M revenue) | Paid (Docker Business) |

If your company requires a paid license and you prefer a free alternative, consider:
- [Rancher Desktop](rancher-desktop.md) -- free, open-source GUI alternative
- [Colima](colima.md) -- free, CLI-based Docker alternative on macOS
- [kind](kind.md) or [k3d](k3d.md) -- free, work with any Docker-compatible runtime

## When to Choose Docker Desktop

Choose Docker Desktop Kubernetes if:

- You already use Docker Desktop and want zero extra setup
- You need a simple single-node cluster for quick testing
- You prefer GUI-based management
- You are doing basic Kubernetes exploration, not in-depth learning

Consider kind instead if:

- You need multi-node clusters
- You want lightweight resource usage
- You need reproducible, declarative cluster configuration
- You want to learn Kubernetes deeply (kind gives you more control)

---

[Back to Tool Comparison](README.md) | [Back to main documentation](../README.md)
