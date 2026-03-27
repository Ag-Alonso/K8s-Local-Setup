# Exercise 02: Deployments

**Difficulty:** Beginner | **Duration:** ~45 minutes

## Objective

Create a Deployment, scale it, and understand how Deployments manage ReplicaSets and Pods.

## Concepts

- [ReplicaSets & Deployments](../../docs/04-core-concepts/03-replicasets-deployments.md)

## Steps

### Step 1: Create a Deployment

```bash
kubectl apply -f manifests/nginx-deployment.yaml
```

### Step 2: Observe the Hierarchy

```bash
# List deployments
kubectl get deployments

# List ReplicaSets (created by the Deployment)
kubectl get replicasets

# List Pods (created by the ReplicaSet)
kubectl get pods

# See all at once
kubectl get deploy,rs,pods
```

Notice the naming pattern: `deployment → replicaset-<hash> → pod-<hash>`

### Step 3: Scale the Deployment

```bash
# Scale to 5 replicas
kubectl scale deployment/nginx-deployment --replicas=5

# Watch pods appear
kubectl get pods -w
```

Press `Ctrl+C` to stop watching.

```bash
# Scale back to 3
kubectl scale deployment/nginx-deployment --replicas=3
```

### Step 4: Examine the Deployment

```bash
kubectl describe deployment nginx-deployment
```

Look for:
- **Replicas** — desired, updated, available
- **Strategy** — RollingUpdate settings
- **Pod Template** — The template used to create pods
- **Events** — Scaling events

### Step 5: Update the Image

```bash
# Update to a different NGINX version
kubectl set image deployment/nginx-deployment nginx=nginx:1.28

# Watch the rollout
kubectl rollout status deployment/nginx-deployment
```

### Step 6: Check ReplicaSets After Update

```bash
kubectl get replicasets
```

You should see two ReplicaSets — the old one (0 pods) and the new one (3 pods).

### Step 7: View Rollout History

```bash
kubectl rollout history deployment/nginx-deployment
```

### Step 8: Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Verify
kubectl describe deployment nginx-deployment | grep Image
```

## Checkpoint

You should now understand:
- Deployments create and manage ReplicaSets
- Scaling changes the number of pod replicas
- Image updates trigger a rolling update
- You can rollback to any previous revision

## Optional Challenges

1. Create a deployment with `Recreate` strategy and observe the difference
2. Set `maxUnavailable: 0` and `maxSurge: 1` and perform an update
3. Use `kubectl rollout undo --to-revision=1` to rollback to a specific version

## Cleanup

```bash
kubectl delete -f manifests/
```

## Next Exercise

[03: Services →](../03-services/)
