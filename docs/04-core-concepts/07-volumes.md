# Volumes

## The Problem

Containers are **ephemeral** — when a container restarts, all data inside it is lost. Kubernetes volumes solve this by providing persistent storage that survives container restarts.

## Volume Types

### emptyDir

A temporary directory created when a Pod is assigned to a node. It exists as long as the pod runs. Useful for sharing data between containers in the same pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: shared-data
spec:
  containers:
    - name: writer
      image: busybox
      command: ["sh", "-c", "echo hello > /data/message && sleep 3600"]
      volumeMounts:
        - name: shared
          mountPath: /data
    - name: reader
      image: busybox
      command: ["sh", "-c", "cat /data/message && sleep 3600"]
      volumeMounts:
        - name: shared
          mountPath: /data
  volumes:
    - name: shared
      emptyDir: {}
```

### hostPath

Mounts a file or directory from the host node's filesystem. Useful for local development but **not recommended for production** (ties pod to a specific node).

```yaml
volumes:
  - name: host-data
    hostPath:
      path: /data/app
      type: DirectoryOrCreate
```

## Persistent Storage

> See the full diagram: [Storage Architecture](diagrams/storage-architecture.d2)

For data that must survive pod restarts and rescheduling, Kubernetes uses:

### StorageClass

Defines **how** storage is provisioned. Think of it as a template for creating volumes.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: rancher.io/local-path    # kind uses this provisioner
reclaimPolicy: Delete                  # Delete PV when PVC is deleted
volumeBindingMode: WaitForFirstConsumer
```

In kind, a `standard` StorageClass is available by default.

### PersistentVolume (PV)

A piece of storage provisioned in the cluster. It's a **cluster-level** resource (not namespaced).

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce           # Can be mounted by one node
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /data/pv-001
```

### PersistentVolumeClaim (PVC)

A **request** for storage by a user. It's **namespaced** and binds to a matching PV.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi          # Request 500 MiB
  storageClassName: standard   # Must match a StorageClass
```

### Using a PVC in a Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-storage
spec:
  containers:
    - name: app
      image: nginx:1.27
      volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: my-pvc      # References the PVC
```

## The Storage Flow

```
StorageClass (defines how to provision)
       ↓
PersistentVolume (actual storage)
       ↑
PersistentVolumeClaim (request for storage)
       ↑
Pod (mounts the PVC)
```

With **dynamic provisioning** (the norm), you only create the StorageClass and PVC. The PV is created automatically.

## Access Modes

| Mode | Short | Description |
|------|-------|-------------|
| `ReadWriteOnce` | RWO | Single node read-write |
| `ReadOnlyMany` | ROX | Multiple nodes read-only |
| `ReadWriteMany` | RWX | Multiple nodes read-write |
| `ReadWriteOncePod` | RWOP | Single pod read-write (K8s 1.27+) |

## Reclaim Policies

What happens to the PV when the PVC is deleted:

| Policy | Behavior |
|--------|----------|
| `Delete` | PV and underlying storage are deleted |
| `Retain` | PV is kept, must be manually cleaned up |
| `Recycle` | Deprecated — use `Delete` |

## Common kubectl Commands

```bash
# List PersistentVolumes
kubectl get pv

# List PersistentVolumeClaims
kubectl get pvc

# List StorageClasses
kubectl get storageclass

# Describe a PVC (check binding status)
kubectl describe pvc my-pvc

# Check what's using storage
kubectl get pods -o json | grep -A5 persistentVolumeClaim
```

## Storage in kind

kind uses the `local-path-provisioner` for dynamic storage provisioning. The `standard` StorageClass is available by default:

```bash
$ kubectl get storageclass
NAME                 PROVISIONER             RECLAIMPOLICY
standard (default)   rancher.io/local-path   Delete
```

## Hands-On

- [Exercise 05: Persistent Storage →](../../exercises/05-persistent-storage/)

## What's Next?

- [Ingress & Gateway API →](08-ingress-gateway-api.md)
