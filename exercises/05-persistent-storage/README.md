# Exercise 05: Persistent Storage

**Difficulty:** Intermediate | **Duration:** ~60 minutes

## Objective

Create PersistentVolumeClaims, mount them in Pods, and verify data persists across Pod restarts.

## Concepts

- [Volumes](../../docs/04-core-concepts/07-volumes.md)

## Steps

### Step 1: Check Available StorageClasses

```bash
kubectl get storageclass
```

kind provides a `standard` StorageClass by default.

### Step 2: Create a PersistentVolumeClaim

```bash
kubectl apply -f manifests/data-pvc.yaml
```

```bash
kubectl get pvc data-pvc
```

The status should be `Pending` (waits for a pod to use it in kind) or `Bound`.

### Step 3: Create a Pod That Uses the PVC

```bash
kubectl apply -f manifests/writer-pod.yaml
```

```bash
# Write data to the volume
kubectl exec writer-pod -- sh -c 'echo "Data written at $(date)" > /data/message.txt'
kubectl exec writer-pod -- cat /data/message.txt
```

### Step 4: Delete the Pod and Verify Data Persists

```bash
kubectl delete pod writer-pod

# Recreate the pod
kubectl apply -f manifests/writer-pod.yaml

# Check if data survived
kubectl exec writer-pod -- cat /data/message.txt
```

The data should still be there — that's persistent storage.

### Step 5: Use emptyDir for Temporary Shared Storage

```bash
kubectl apply -f manifests/shared-volume-pod.yaml
```

```bash
# Watch the writer container produce data
kubectl logs shared-volume-pod -c reader -f
```

Delete the pod and notice the emptyDir data is gone (it's temporary).

### Step 6: Check PV/PVC Binding

```bash
kubectl get pv
kubectl get pvc
kubectl describe pvc data-pvc
```

## Checkpoint

- PVCs request storage, PVs provide it
- Data in PVCs persists across pod restarts
- emptyDir is temporary (per-pod lifetime)
- StorageClass enables dynamic provisioning

## Cleanup

```bash
kubectl delete -f manifests/
kubectl delete pvc data-pvc
```

## Next Exercise

[06: Rolling Updates →](../06-rolling-updates/)
