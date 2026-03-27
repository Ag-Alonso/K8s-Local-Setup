# Exercise 10: Observability Basics

**Difficulty:** Intermediate | **Duration:** ~60 minutes

## Objective

Learn to debug Kubernetes applications using logs, events, resource metrics, and kubectl debugging techniques.

## Steps

### Step 1: Deploy a Working Application

```bash
kubectl apply -f manifests/web-app.yaml
```

```bash
kubectl get pods -l app=web-debug
```

### Step 2: View Container Logs

```bash
# Current logs
kubectl logs -l app=web-debug

# Follow logs in real-time
kubectl logs -l app=web-debug -f

# Logs from a specific container (multi-container pods)
kubectl logs <pod-name> -c web

# Previous container logs (after a crash)
kubectl logs <pod-name> --previous
```

### Step 3: View Cluster Events

```bash
# All events (sorted by time)
kubectl get events --sort-by='.lastTimestamp'

# Events for a specific pod
kubectl describe pod <pod-name> | tail -20

# Watch events in real-time
kubectl get events -w
```

### Step 4: Deploy a Broken Application

```bash
kubectl apply -f manifests/broken-app.yaml
```

Debug it:
```bash
# Check pod status
kubectl get pods -l app=broken

# Describe the pod to see events
kubectl describe pod -l app=broken

# Check logs
kubectl logs -l app=broken
```

What's wrong? Fix the issue and redeploy.

### Step 5: Resource Monitoring

```bash
# Node resource usage (requires metrics-server)
kubectl top nodes

# Pod resource usage
kubectl top pods

# Pod resource usage sorted by CPU
kubectl top pods --sort-by=cpu
```

> If `kubectl top` doesn't work, install metrics-server:
> ```bash
> kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
> ```
> For kind, you may need to add `--kubelet-insecure-tls` to the metrics-server deployment.

### Step 6: Debug with Ephemeral Containers

```bash
# Create a debug container attached to a running pod
kubectl debug -it <pod-name> --image=busybox:1.36 -- sh

# Inside the debug container:
wget -qO- http://localhost:80
nslookup kubernetes
exit
```

### Step 7: Examine Resource Details

```bash
# Get YAML of a running resource
kubectl get pod <pod-name> -o yaml

# Get specific fields with jsonpath
kubectl get pods -o jsonpath='{.items[*].status.podIP}'

# Check resource usage vs limits
kubectl describe pod <pod-name> | grep -A3 "Limits\|Requests"
```

## Checkpoint

- `kubectl logs` for container output
- `kubectl describe` + events for lifecycle issues
- `kubectl top` for resource metrics
- `kubectl debug` for interactive debugging
- Events tell the story of what happened and why

## Cleanup

```bash
kubectl delete -f manifests/
```

## Next Exercise

[11: Multi-Container Pods →](../11-multi-container-pods/)
