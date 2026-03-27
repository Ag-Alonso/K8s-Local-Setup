# Workload Types

Beyond Deployments, Kubernetes offers several workload controllers for different use cases.

## Overview

| Workload | Purpose | Replicas | Pod Identity | Use Case |
|----------|---------|----------|--------------|----------|
| **Deployment** | Stateless apps | Variable | Interchangeable | Web servers, APIs |
| **StatefulSet** | Stateful apps | Variable | Stable, unique | Databases, caches |
| **DaemonSet** | One per node | One per node | Per-node | Log collectors, monitoring |
| **Job** | Run to completion | Fixed | Disposable | Batch processing, migrations |
| **CronJob** | Scheduled Jobs | Per schedule | Disposable | Backups, reports |

## Deployment (Review)

The standard for stateless applications. Covered in [ReplicaSets & Deployments](03-replicasets-deployments.md).

## StatefulSet

For applications that need **stable identities** and **persistent storage**.

### What Makes StatefulSets Special

| Feature | Deployment | StatefulSet |
|---------|-----------|-------------|
| Pod names | Random (`nginx-7d6f8c-xk2lp`) | Ordered (`db-0`, `db-1`, `db-2`) |
| Startup order | All at once | Sequential (0, then 1, then 2) |
| Shutdown order | All at once | Reverse (2, then 1, then 0) |
| Storage | Shared or none | Each pod gets its own PVC |
| DNS | Via Service only | Individual DNS per pod |

### StatefulSet Manifest

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-headless     # Required headless service
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:16
          ports:
            - containerPort: 5432
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
          resources:
            requests:
              cpu: 250m
              memory: 256Mi
            limits:
              cpu: 500m
              memory: 512Mi
  volumeClaimTemplates:              # Each pod gets its own PVC
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
```

### Headless Service

StatefulSets require a headless Service (no ClusterIP) for pod DNS:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None                    # Headless
  selector:
    app: postgres
  ports:
    - port: 5432
```

Each pod gets a DNS name: `postgres-0.postgres-headless.default.svc.cluster.local`

## DaemonSet

Ensures a pod runs on **every node** (or a subset of nodes). When nodes are added, the DaemonSet automatically adds pods. When nodes are removed, pods are garbage collected.

### Common Uses

- **Log collection** (Fluentd, Filebeat, Promtail)
- **Node monitoring** (Node Exporter, cAdvisor)
- **Network plugins** (Calico, Cilium)
- **Storage daemons** (CSI drivers)

### DaemonSet Manifest

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
        - name: node-exporter
          image: prom/node-exporter:v1.8.0
          ports:
            - containerPort: 9100
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 100m
              memory: 128Mi
```

## Job

Runs one or more pods to **completion**. Once all pods succeed, the job is done.

### Job Manifest

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
spec:
  completions: 1                     # Number of successful completions needed
  parallelism: 1                     # How many pods run at once
  backoffLimit: 3                    # Retries before marking failed
  activeDeadlineSeconds: 300         # Timeout
  template:
    spec:
      restartPolicy: Never           # Required: Never or OnFailure
      containers:
        - name: migrate
          image: my-app:1.0
          command: ["./migrate", "--up"]
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 256Mi
```

### Parallel Jobs

Process multiple items in parallel:

```yaml
spec:
  completions: 10        # Need 10 successful completions
  parallelism: 3         # Run 3 pods at a time
```

## CronJob

Creates Jobs on a **schedule** (like cron in Linux).

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-backup
spec:
  schedule: "0 2 * * *"             # Every day at 2:00 AM
  concurrencyPolicy: Forbid          # Don't run if previous still running
  successfulJobsHistoryLimit: 3      # Keep last 3 successful jobs
  failedJobsHistoryLimit: 1          # Keep last failed job
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: backup
              image: my-backup:1.0
              command: ["./backup.sh"]
              resources:
                requests:
                  cpu: 100m
                  memory: 128Mi
                limits:
                  cpu: 500m
                  memory: 256Mi
```

### Cron Schedule Syntax

```
┌───────── minute (0-59)
│ ┌─────── hour (0-23)
│ │ ┌───── day of month (1-31)
│ │ │ ┌─── month (1-12)
│ │ │ │ ┌─ day of week (0-6, Sun=0)
│ │ │ │ │
* * * * *
```

| Schedule | Meaning |
|----------|---------|
| `*/5 * * * *` | Every 5 minutes |
| `0 * * * *` | Every hour |
| `0 2 * * *` | Daily at 2 AM |
| `0 0 * * 0` | Weekly on Sunday midnight |
| `0 0 1 * *` | Monthly on the 1st |

## Common kubectl Commands

```bash
# StatefulSets
kubectl get statefulsets
kubectl describe statefulset postgres
kubectl scale statefulset postgres --replicas=5

# DaemonSets
kubectl get daemonsets -A
kubectl describe daemonset node-exporter

# Jobs
kubectl get jobs
kubectl describe job db-migration
kubectl logs job/db-migration

# CronJobs
kubectl get cronjobs
kubectl create job --from=cronjob/daily-backup manual-backup  # Trigger manually
```

## Choosing the Right Workload

```
Need to run a stateless app? → Deployment
Need stable pod identity/storage? → StatefulSet
Need one pod per node? → DaemonSet
Need to run once to completion? → Job
Need to run on a schedule? → CronJob
```

## Hands-On

- [Exercise 11: Multi-Container Pods →](../../exercises/11-multi-container-pods/)

## Back to

- [Core Concepts →](README.md)
