# Setup Guides

This section walks you through setting up a local Kubernetes cluster on your machine. By the end, you will have a fully functional cluster ready for the hands-on exercises in this repository.

## Recommended Path

Follow these three steps in order:

```
1. Prerequisites  -->  2. kind Setup  -->  3. Verify Cluster
```

| Step | Guide | Time |
|------|-------|------|
| 1 | [Prerequisites](prerequisites.md) | 10-15 min |
| 2 | [kind Setup](kind-setup.md) (recommended) | 5-10 min |
| 3 | Run `./scripts/verify-cluster.sh` | 1 min |

## Alternative Tools

kind is the primary tool used throughout this repository. If you have a specific reason to use a different tool, these guides are also available:

| Tool | Guide | Best For |
|------|-------|----------|
| **kind** | [kind-setup.md](kind-setup.md) | Learning Kubernetes fundamentals (recommended) |
| **k3d** | [k3d-setup.md](k3d-setup.md) | Faster startup, built-in registry |
| **minikube** | [minikube-setup.md](minikube-setup.md) | Built-in dashboard, easy addons |

All exercises in this repository are tested with kind. If you use k3d or minikube, minor differences may apply.

## Troubleshooting

If something goes wrong during setup, check the [Troubleshooting Guide](troubleshooting.md). It covers common issues for Docker, kind, kubectl, and platform-specific problems on both Linux and macOS.

## Quick Start (Experienced Users)

If you already have Docker, kubectl, and kind installed:

```bash
# Create cluster
./scripts/setup-kind.sh

# Verify
./scripts/verify-cluster.sh

# Start learning
cd exercises/00-verify-setup/
```
