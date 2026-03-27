# Kubernetes Architecture

## Overview

A Kubernetes cluster has two main parts: the **Control Plane** and **Worker Nodes**. The control plane makes decisions about the cluster. Worker nodes run your applications.

```
┌─────────────────────────────────────────────────┐
│                 Control Plane                    │
│  ┌───────────┐ ┌──────┐ ┌─────────┐ ┌────────┐ │
│  │ API Server│ │ etcd │ │Scheduler│ │  CCM   │ │
│  └───────────┘ └──────┘ └─────────┘ └────────┘ │
└─────────────────────┬───────────────────────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
   ┌─────┴─────┐ ┌───┴─────┐ ┌───┴─────┐
   │  Node 1   │ │  Node 2 │ │  Node 3 │
   │ ┌───────┐ │ │ ┌─────┐ │ │ ┌─────┐ │
   │ │kubelet│ │ │ │ Pod │ │ │ │ Pod │ │
   │ ├───────┤ │ │ ├─────┤ │ │ ├─────┤ │
   │ │k-proxy│ │ │ │ Pod │ │ │ │ Pod │ │
   │ └───────┘ │ │ └─────┘ │ │ └─────┘ │
   └───────────┘ └─────────┘ └─────────┘
```

> See the full diagram: [K8s Architecture Overview](../01-introduction/diagrams/k8s-architecture-overview.d2)

## Control Plane Components

### API Server (`kube-apiserver`)

The front door to Kubernetes. Every operation — whether from `kubectl`, the dashboard, or internal components — goes through the API server.

- Validates and processes REST requests
- Authenticates and authorizes users
- Serves as the communication hub for all components

```bash
# Everything you do with kubectl talks to the API server
kubectl get pods        # GET /api/v1/namespaces/default/pods
kubectl apply -f x.yaml # POST/PUT to API server
```

### etcd

A distributed key-value store that holds **all cluster state**. Think of it as the cluster's database.

- Stores configuration, state, and metadata
- Only the API server communicates with etcd directly
- In production: runs as a 3 or 5 node cluster for high availability

### Scheduler (`kube-scheduler`)

Decides **which node** should run a newly created pod.

Considers:
- Resource requirements (CPU, memory)
- Node capacity and existing workloads
- Affinity/anti-affinity rules
- Taints and tolerations

### Controller Manager (`kube-controller-manager`)

Runs **controllers** — loops that watch cluster state and work to match the desired state.

Key controllers:
- **Deployment controller** — Manages ReplicaSets for deployments
- **ReplicaSet controller** — Ensures the right number of pod replicas
- **Node controller** — Monitors node health
- **Job controller** — Manages one-off tasks

### Cloud Controller Manager (optional)

Integrates with cloud providers (AWS, GCP, Azure) for:
- Load balancers
- Storage volumes
- Node management

Not used in local clusters.

## Worker Node Components

### kubelet

An agent running on every node. It:
- Receives pod specs from the API server
- Ensures containers described in pod specs are running and healthy
- Reports node and pod status back to the API server

### kube-proxy

Manages **networking rules** on each node.

- Implements Services (the K8s networking abstraction)
- Routes traffic to the right pods
- Uses iptables or IPVS under the hood

### Container Runtime

The software that actually runs containers.

- **containerd** — Most common, default in modern K8s
- **CRI-O** — Lightweight alternative
- Docker was used historically but is no longer directly supported (containerd is the standard)

## How It All Works Together

When you run `kubectl apply -f deployment.yaml`:

1. **kubectl** sends the YAML to the **API Server**
2. **API Server** validates it and stores it in **etcd**
3. **Controller Manager** (Deployment controller) creates a ReplicaSet
4. **Controller Manager** (ReplicaSet controller) creates Pod objects
5. **Scheduler** assigns each Pod to a Node
6. **kubelet** on the assigned Node pulls the image and starts the container
7. **kube-proxy** updates networking rules so the Pod is reachable

This entire process is **declarative**: you describe what you want, and Kubernetes makes it happen.

## Control Plane vs. Worker Nodes in Local Clusters

In production, the control plane and workers run on separate machines. In local clusters:

| Tool | Control Plane | Workers |
|------|--------------|---------|
| **kind** | Docker container | Docker containers |
| **minikube** | Same VM/container | Same VM/container (default) |
| **k3d** | Docker container | Docker containers |

With kind, you can simulate a real multi-node setup:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

## Key Terminology

| Term | Definition |
|------|-----------|
| **Cluster** | A set of nodes running Kubernetes |
| **Control Plane** | Components that manage the cluster |
| **Node** | A machine (physical or virtual) in the cluster |
| **Pod** | Smallest deployable unit (wraps containers) |
| **Desired State** | What you declared in YAML |
| **Actual State** | What's currently running |
| **Reconciliation** | The process of making actual match desired |

## What's Next?

- [Pods →](02-pods.md)
