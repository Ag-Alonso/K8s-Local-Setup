# Exercise 11: Multi-Container Pods

**Difficulty:** Intermediate | **Duration:** ~45 minutes

## Objective

Learn multi-container pod patterns: sidecar, init containers, and ambassador.

## Steps

### Step 1: Init Container Pattern

Init containers run before the main container and must complete successfully.

```bash
kubectl apply -f manifests/init-container.yaml
```

```bash
# Watch the pod — init container runs first
kubectl get pod init-demo -w

# Check init container logs
kubectl logs init-demo -c init-data

# Check main container can read the data
kubectl logs init-demo -c web
```

### Step 2: Sidecar Pattern

A sidecar container runs alongside the main container, providing supporting functionality (logging, proxying, etc.).

```bash
kubectl apply -f manifests/sidecar.yaml
```

```bash
# Main container writes logs
kubectl logs sidecar-demo -c app

# Sidecar processes the logs
kubectl logs sidecar-demo -c log-shipper
```

### Step 3: Adapter Pattern

An adapter container transforms the main container's output into a different format.

```bash
kubectl apply -f manifests/adapter.yaml
```

```bash
# Main app produces raw metrics
kubectl exec adapter-demo -c app -- cat /metrics/raw.txt

# Adapter converts to Prometheus format
kubectl exec adapter-demo -c adapter -- cat /metrics/prometheus.txt
```

### Step 4: Container Communication

All containers in a pod share:
- **Network**: same IP, same localhost
- **Volumes**: shared mount points

```bash
# Containers can talk via localhost
kubectl exec sidecar-demo -c log-shipper -- wget -qO- http://localhost:8080
```

## Checkpoint

- **Init containers**: Run before main containers (setup, wait for dependencies)
- **Sidecar**: Runs alongside main container (logging, proxy, sync)
- **Adapter**: Transforms output format
- All containers share network (localhost) and can share volumes

## Cleanup

```bash
kubectl delete -f manifests/
```

## Next Exercise

[12: Capstone — Guestbook →](../12-capstone/)
