# Exercise 00: Verify Setup

**Difficulty:** Beginner | **Duration:** ~15 minutes

## Objective

Confirm that your local Kubernetes cluster is running and that you can interact with it using `kubectl`.

## Prerequisites

- Docker installed and running
- kind (or k3d/minikube) installed
- kubectl installed
- A running cluster (see [Setup Guides](../../docs/03-setup-guides/))

## Steps

### Step 1: Check kubectl Connection

```bash
kubectl cluster-info
```

**Expected output:**
```
Kubernetes control plane is running at https://127.0.0.1:xxxxx
CoreDNS is running at https://127.0.0.1:xxxxx/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

> If you get "connection refused", your cluster may not be running. Check `kind get clusters` or `docker ps`.

### Step 2: List Nodes

```bash
kubectl get nodes
```

**Expected output:**
```
NAME                      STATUS   ROLES           AGE   VERSION
k8s-local-control-plane   Ready    control-plane   5m    v1.31.x
```

The STATUS should be `Ready`.

### Step 3: Explore System Pods

```bash
kubectl get pods -n kube-system
```

**Expected output (kind cluster):**
```
NAME                                              READY   STATUS    RESTARTS   AGE
coredns-xxx-xxx                                   1/1     Running   0          5m
coredns-xxx-xxx                                   1/1     Running   0          5m
etcd-k8s-local-control-plane                      1/1     Running   0          5m
kindnet-xxx                                       1/1     Running   0          5m
kube-apiserver-k8s-local-control-plane            1/1     Running   0          5m
kube-controller-manager-k8s-local-control-plane   1/1     Running   0          5m
kube-proxy-xxx                                    1/1     Running   0          5m
kube-scheduler-k8s-local-control-plane            1/1     Running   0          5m
```

All pods should be in `Running` status.

### Step 4: List Namespaces

```bash
kubectl get namespaces
```

**Expected output:**
```
NAME              STATUS   AGE
default           Active   5m
kube-node-lease   Active   5m
kube-public       Active   5m
kube-system       Active   5m
```

### Step 5: Check API Resources

```bash
kubectl api-resources | head -20
```

This shows all the resource types your cluster supports.

### Step 6: Run the Verification Script

```bash
../../scripts/verify-cluster.sh
```

All checks should pass.

## Checkpoint

You should now be able to answer:

- How many nodes does your cluster have?
- What Kubernetes version is running?
- What pods run in the `kube-system` namespace?
- What are the default namespaces?

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "connection refused" | Start your cluster: `kind create cluster --name k8s-local` |
| Nodes show "NotReady" | Wait 1-2 minutes, then check again |
| kubectl not found | Install kubectl (see [Prerequisites](../../docs/03-setup-guides/prerequisites.md)) |

## Next Exercise

[01: First Pod →](../01-first-pod/)
