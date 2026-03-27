# Exercise 06: Rolling Updates

**Difficulty:** Intermediate | **Duration:** ~45 minutes

## Objective

Perform rolling updates, observe the process, and practice rollbacks.

## Concepts

- [ReplicaSets & Deployments](../../docs/04-core-concepts/03-replicasets-deployments.md)

## Steps

### Step 1: Create the Deployment

```bash
kubectl apply -f manifests/web-deployment.yaml
```

```bash
kubectl get deploy web-app
kubectl get pods -l app=web-app
```

### Step 2: Watch a Rolling Update

Open a second terminal to watch pods:
```bash
kubectl get pods -l app=web-app -w
```

In the first terminal, trigger an update:
```bash
kubectl set image deployment/web-app web=nginx:1.28
```

Watch the pods being replaced one by one in the second terminal.

### Step 3: Check Rollout Status

```bash
kubectl rollout status deployment/web-app
```

### Step 4: View Rollout History

```bash
kubectl rollout history deployment/web-app
```

### Step 5: Trigger a Bad Update

```bash
kubectl set image deployment/web-app web=nginx:nonexistent
```

```bash
# Watch pods failing
kubectl get pods -l app=web-app
kubectl rollout status deployment/web-app
```

The rollout will be stuck — pods can't pull the invalid image.

### Step 6: Rollback

```bash
kubectl rollout undo deployment/web-app
kubectl rollout status deployment/web-app
kubectl get pods -l app=web-app
```

All pods should be healthy again.

### Step 7: Test maxUnavailable and maxSurge

Apply the zero-downtime configuration:
```bash
kubectl apply -f manifests/zero-downtime-deployment.yaml
kubectl set image deployment/web-zero-downtime web=nginx:1.28
kubectl rollout status deployment/web-zero-downtime
```

## Checkpoint

- Rolling updates replace pods gradually
- maxSurge controls extra pods during update
- maxUnavailable controls pods that can be down
- Rollback reverts to the previous ReplicaSet
- Invalid images cause rollouts to stall (not crash existing pods)

## Cleanup

```bash
kubectl delete -f manifests/
```

## Next Exercise

[07: Namespaces →](../07-namespaces/)
