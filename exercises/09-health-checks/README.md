# Exercise 09: Health Checks

**Difficulty:** Intermediate | **Duration:** ~45 minutes

## Objective

Configure liveness, readiness, and startup probes to make applications self-healing.

## Steps

### Step 1: Deploy Without Health Checks

```bash
kubectl apply -f manifests/no-probes.yaml
```

### Step 2: Add Liveness Probe

```bash
kubectl apply -f manifests/liveness.yaml
```

The liveness probe checks if the container is alive. If it fails, Kubernetes restarts it.

```bash
# Watch the pod — it will be restarted after the liveness probe fails
kubectl get pods -l app=liveness-test -w
```

After ~30 seconds the probe will fail and the container will restart.

### Step 3: Add Readiness Probe

```bash
kubectl apply -f manifests/readiness.yaml
```

The readiness probe determines if the pod should receive traffic.

```bash
kubectl get pods -l app=readiness-test
```

Notice READY is `0/1` until the readiness probe passes.

### Step 4: Add Startup Probe

```bash
kubectl apply -f manifests/startup.yaml
```

Startup probes are for slow-starting containers. They disable liveness/readiness until the app is started.

### Step 5: Observe Probe Behavior

```bash
kubectl describe pod -l app=liveness-test | grep -A5 "Liveness"
kubectl describe pod -l app=readiness-test | grep -A5 "Readiness"
```

## Checkpoint

- **Liveness**: Is the container alive? Restart if not.
- **Readiness**: Should this pod receive traffic? Remove from service if not.
- **Startup**: Has the container started? Protect slow starters.
- Always configure readiness probes for web services.

## Cleanup

```bash
kubectl delete -f manifests/
```

## Next Exercise

[10: Observability Basics →](../10-observability-basics/)
