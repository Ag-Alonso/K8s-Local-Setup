# Exercise 01: First Pod

**Difficulty:** Beginner | **Duration:** ~30 minutes

## Objective

Create, inspect, and manage your first Kubernetes Pod.

## Concepts

- [Pods](../../docs/04-core-concepts/02-pods.md)

## Steps

### Step 1: Create a Pod from YAML

Create the file `manifests/nginx-pod.yaml` (already provided):

```bash
kubectl apply -f manifests/nginx-pod.yaml
```

### Step 2: Verify the Pod is Running

```bash
kubectl get pods
```

**Expected output:**
```
NAME        READY   STATUS    RESTARTS   AGE
nginx-pod   1/1     Running   0          30s
```

Wait until STATUS is `Running` and READY is `1/1`.

### Step 3: Get Detailed Information

```bash
kubectl describe pod nginx-pod
```

Look for:
- **Node** — Which node it's running on
- **IP** — The pod's internal IP address
- **Containers** — Image, ports, resource limits
- **Events** — What happened during creation

### Step 4: View Logs

```bash
kubectl logs nginx-pod
```

You should see NGINX startup logs.

### Step 5: Execute a Command Inside the Pod

```bash
# Check the NGINX default page
kubectl exec nginx-pod -- curl -s localhost

# Open an interactive shell
kubectl exec -it nginx-pod -- /bin/bash

# Inside the pod:
cat /etc/nginx/nginx.conf
exit
```

### Step 6: Port Forward to Access Locally

```bash
kubectl port-forward nginx-pod 8080:80
```

Now open http://localhost:8080 in your browser. You should see the NGINX welcome page.

Press `Ctrl+C` to stop port forwarding.

### Step 7: Delete the Pod

```bash
kubectl delete pod nginx-pod
```

Verify it's gone:
```bash
kubectl get pods
```

## Checkpoint

You should now be able to:
- Create a pod from a YAML manifest
- Check pod status, describe pods, view logs
- Execute commands inside a running pod
- Access a pod via port-forward
- Delete a pod

## Optional Challenges

1. Create a pod using the `busybox` image that prints "Hello, Kubernetes!" and exits
2. Create a pod with resource requests and limits
3. Create a pod with two containers sharing a volume

## Cleanup

```bash
kubectl delete -f manifests/
```

## Next Exercise

[02: Deployments →](../02-deployments/)
