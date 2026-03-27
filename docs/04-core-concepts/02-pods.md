# Pods

## What is a Pod?

A **Pod** is the smallest deployable unit in Kubernetes. It wraps one or more containers that:

- Share the same **network** (same IP address, same localhost)
- Can share **storage** (volumes)
- Are always **co-scheduled** (run on the same node)

In most cases, **one pod = one container**. Multi-container pods are for specific patterns like sidecars.

## Pod Manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod              # Name of the pod
  labels:                      # Labels for identification
    app: nginx
    env: dev
spec:
  containers:
    - name: nginx              # Container name
      image: nginx:1.27        # Container image
      ports:
        - containerPort: 80    # Port the container listens on
      resources:               # Resource requests and limits
        requests:
          cpu: 100m            # 0.1 CPU cores
          memory: 128Mi        # 128 MiB RAM
        limits:
          cpu: 250m
          memory: 256Mi
```

### Key Fields Explained

| Field | Purpose |
|-------|---------|
| `apiVersion` | API group and version (`v1` for core resources) |
| `kind` | Resource type |
| `metadata.name` | Unique name within the namespace |
| `metadata.labels` | Key-value pairs for identification and selection |
| `spec.containers` | List of containers to run in the pod |
| `resources.requests` | Minimum resources guaranteed to the container |
| `resources.limits` | Maximum resources the container can use |

## Pod Lifecycle

A pod moves through these phases:

```
Pending → Running → Succeeded (or Failed)
```

| Phase | Description |
|-------|-------------|
| **Pending** | Pod accepted but not yet running. Waiting for scheduling, image pull, etc. |
| **Running** | At least one container is running |
| **Succeeded** | All containers exited with code 0 |
| **Failed** | At least one container exited with non-zero code |
| **Unknown** | Pod state cannot be determined (node communication issue) |

> See the full diagram: [Pod Lifecycle](diagrams/pod-lifecycle.d2)

### Container States

Within a running pod, each container has its own state:

- **Waiting** — Not yet started (pulling image, etc.)
- **Running** — Executing
- **Terminated** — Finished (success or failure)

### CrashLoopBackOff

When a container crashes repeatedly, Kubernetes restarts it with increasing delays (10s, 20s, 40s... up to 5 minutes). This state is called **CrashLoopBackOff**.

Common causes:
- Application error on startup
- Missing configuration (env vars, config files)
- Wrong image or command
- Health check failures

## Common kubectl Commands

```bash
# Create a pod from YAML
kubectl apply -f pod.yaml

# List pods
kubectl get pods
kubectl get pods -o wide          # Show node and IP

# Detailed pod info
kubectl describe pod nginx-pod

# View container logs
kubectl logs nginx-pod
kubectl logs nginx-pod -f         # Follow/stream logs

# Execute command in pod
kubectl exec -it nginx-pod -- bash
kubectl exec nginx-pod -- cat /etc/nginx/nginx.conf

# Delete a pod
kubectl delete pod nginx-pod
kubectl delete -f pod.yaml

# Quick pod creation (imperative, for testing only)
kubectl run test-pod --image=busybox --command -- sleep 3600
```

## Resource Requests and Limits

Always define resources. Without them, a single pod can consume all node resources.

```yaml
resources:
  requests:
    cpu: 100m       # 0.1 cores — used for scheduling
    memory: 128Mi   # Used for scheduling
  limits:
    cpu: 500m       # 0.5 cores — hard cap
    memory: 512Mi   # Hard cap — OOMKilled if exceeded
```

**CPU units:**
- `1` = 1 vCPU/core
- `100m` = 0.1 cores (m = millicores)

**Memory units:**
- `Mi` = mebibytes (1 Mi = 1,048,576 bytes)
- `Gi` = gibibytes

## When NOT to Use Bare Pods

You should almost never create pods directly. Instead, use:

- **Deployment** — For stateless apps (web servers, APIs)
- **StatefulSet** — For stateful apps (databases)
- **Job** — For one-off tasks
- **DaemonSet** — For one pod per node

These controllers manage pods for you, handling restarts, scaling, and updates.

## Hands-On

- [Exercise 01: First Pod →](../../exercises/01-first-pod/)

## What's Next?

- [ReplicaSets & Deployments →](03-replicasets-deployments.md)
