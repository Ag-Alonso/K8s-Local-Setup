# ReplicaSets & Deployments

## ReplicaSets

A **ReplicaSet** ensures that a specified number of identical pods are running at all times. If a pod crashes or is deleted, the ReplicaSet creates a replacement.

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-rs
spec:
  replicas: 3                    # Desired number of pods
  selector:
    matchLabels:
      app: nginx                 # Must match pod template labels
  template:                      # Pod template
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.27
```

**You rarely create ReplicaSets directly.** Deployments manage them for you.

## Deployments

A **Deployment** is the standard way to run stateless applications. It manages ReplicaSets and provides:

- **Declarative updates** — Change the image, Kubernetes handles the rollout
- **Rolling updates** — Zero-downtime deployments
- **Rollback** — Revert to any previous version
- **Scaling** — Change replica count on demand

### Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx                 # Selects pods with this label
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1                # Max pods over desired count during update
      maxUnavailable: 0          # Max pods unavailable during update
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.27
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 250m
              memory: 256Mi
```

### The Hierarchy

```
Deployment
  └── ReplicaSet (managed by Deployment)
        ├── Pod 1
        ├── Pod 2
        └── Pod 3
```

A Deployment creates and manages ReplicaSets. A ReplicaSet creates and manages Pods. You interact with the Deployment; the rest happens automatically.

## Rolling Updates

When you update a Deployment (e.g., change the image), Kubernetes performs a **rolling update**:

1. Creates a **new ReplicaSet** with the updated pod template
2. Gradually scales up the new ReplicaSet
3. Gradually scales down the old ReplicaSet
4. Result: zero downtime

> See the full diagram: [Deployment Rolling Update](diagrams/deployment-rolling-update.d2)

### Update Strategies

| Strategy | Behavior |
|----------|----------|
| `RollingUpdate` | Gradual replacement (default) |
| `Recreate` | Kill all old pods, then create new ones (has downtime) |

### Rolling Update Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `maxSurge` | 25% | Extra pods allowed during update |
| `maxUnavailable` | 25% | Pods that can be unavailable during update |

Setting `maxUnavailable: 0` ensures no capacity loss during updates.

## Common Operations

```bash
# Create a deployment
kubectl apply -f deployment.yaml

# List deployments
kubectl get deployments
kubectl get deploy              # Short form

# Watch rollout status
kubectl rollout status deployment/nginx-deployment

# Scale a deployment
kubectl scale deployment/nginx-deployment --replicas=5

# Update the image (triggers rolling update)
kubectl set image deployment/nginx-deployment nginx=nginx:1.28

# View rollout history
kubectl rollout history deployment/nginx-deployment

# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Rollback to a specific revision
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Pause/resume rollout
kubectl rollout pause deployment/nginx-deployment
kubectl rollout resume deployment/nginx-deployment
```

## How the Selector Works

The `spec.selector.matchLabels` field is critical. It tells the Deployment which pods it owns:

```yaml
spec:
  selector:
    matchLabels:
      app: nginx          # "I manage pods with label app=nginx"
  template:
    metadata:
      labels:
        app: nginx        # Pod template MUST have these labels
```

The selector **must match** the pod template labels. Kubernetes enforces this.

## Deployment Status

```bash
$ kubectl get deployment nginx-deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           5m
```

| Column | Meaning |
|--------|---------|
| `READY` | Pods ready / desired |
| `UP-TO-DATE` | Pods with the latest template |
| `AVAILABLE` | Pods ready for at least `minReadySeconds` |

## Best Practices

1. **Always use Deployments** (not bare Pods or ReplicaSets)
2. **Set resource requests and limits** on all containers
3. **Use labels** consistently for selection and organization
4. **Set `maxUnavailable: 0`** for zero-downtime updates
5. **Add health checks** so K8s knows when pods are ready

## Hands-On

- [Exercise 02: Deployments →](../../exercises/02-deployments/)
- [Exercise 06: Rolling Updates →](../../exercises/06-rolling-updates/)

## What's Next?

- [Services →](04-services.md)
