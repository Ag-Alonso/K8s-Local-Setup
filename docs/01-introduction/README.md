# Introduction to Kubernetes

## What is Kubernetes?

Kubernetes (often shortened to **K8s**) is an open-source platform for automating the deployment, scaling, and management of containerized applications. Originally designed by Google and now maintained by the [Cloud Native Computing Foundation (CNCF)](https://www.cncf.io/), Kubernetes has become the industry standard for container orchestration.

### The Problem Kubernetes Solves

Imagine you have a web application running in a Docker container. A single container works fine for development, but in production you need:

- **Multiple copies** of your app for handling traffic (scaling)
- **Automatic restarts** when a container crashes (self-healing)
- **Rolling updates** without downtime (deployments)
- **Load balancing** across containers (services)
- **Configuration management** without rebuilding images (ConfigMaps/Secrets)
- **Storage management** for persistent data (volumes)

Managing all of this manually across dozens or hundreds of containers is impractical. Kubernetes automates these tasks.

### Kubernetes in One Sentence

> Kubernetes is a system that takes your desired state ("I want 3 copies of my app running") and continuously works to make the actual state match.

## Who Is This Guide For?

This repository is designed for:

- **Developers** who want to understand how their apps run in production
- **DevOps/SRE beginners** starting their Kubernetes journey
- **Students** learning cloud-native technologies
- **Anyone** curious about container orchestration

### Prerequisites

You should be comfortable with:

- Basic command line usage (terminal/shell)
- Docker fundamentals (images, containers, `docker run`)
- YAML syntax (indentation, key-value pairs, lists)

No prior Kubernetes experience is needed.

## How This Guide is Organized

| Section | What You'll Learn |
|---------|-------------------|
| [Tool Comparison](../02-tool-comparison/) | Choose the right local K8s tool |
| [Setup Guides](../03-setup-guides/) | Install and configure your environment |
| [Core Concepts](../04-core-concepts/) | Understand K8s architecture and resources |
| [Exercises](../../exercises/) | Hands-on practice with real manifests |

### Recommended Learning Path

```
1. Read this introduction
2. Review the tool comparison (we recommend kind)
3. Follow the setup guide for your chosen tool
4. Work through core concepts (read + practice)
5. Complete exercises 00-12 in order
```

## Key Concepts at a Glance

### The Cluster

A Kubernetes **cluster** consists of:

- **Control Plane** — The "brain" that makes decisions about the cluster
  - **API Server** — Front door for all operations
  - **etcd** — Database storing all cluster state
  - **Scheduler** — Decides which node runs each pod
  - **Controller Manager** — Ensures desired state matches actual state

- **Worker Nodes** — Machines that run your applications
  - **kubelet** — Agent on each node that manages pods
  - **kube-proxy** — Handles networking rules
  - **Container Runtime** — Runs containers (Docker, containerd)

![Kubernetes Architecture](diagrams/k8s-architecture-overview.d2)

### The Pod

The **Pod** is the smallest deployable unit in Kubernetes. A pod wraps one or more containers that share networking and storage. In most cases, one pod = one container.

### Declarative Configuration

Kubernetes uses a **declarative** model. Instead of saying "start a container," you declare what you want in a YAML file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
    - name: app
      image: nginx:1.27
      ports:
        - containerPort: 80
```

Then apply it: `kubectl apply -f my-app.yaml`

Kubernetes figures out how to make it happen.

### kubectl — Your Primary Tool

`kubectl` is the command-line tool for interacting with Kubernetes. Every operation — from creating resources to debugging — goes through `kubectl`.

Common patterns:

```bash
kubectl get <resource>          # List resources
kubectl describe <resource>     # Detailed info
kubectl apply -f <file>         # Create/update from YAML
kubectl delete <resource>       # Remove resources
kubectl logs <pod>              # View container logs
kubectl exec -it <pod> -- bash  # Shell into container
```

## What's Next?

1. **[Choose your local K8s tool →](../02-tool-comparison/)**
2. **[Set up your environment →](../03-setup-guides/)**
3. **[Learn core concepts →](../04-core-concepts/)**
