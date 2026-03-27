# Exercise 04: ConfigMaps & Secrets

**Difficulty:** Beginner | **Duration:** ~45 minutes

## Objective

Configure applications using ConfigMaps and Secrets without rebuilding images.

## Concepts

- [ConfigMaps & Secrets](../../docs/04-core-concepts/05-configmaps-secrets.md)

## Steps

### Step 1: Create a ConfigMap

```bash
kubectl apply -f manifests/app-config.yaml
```

Verify:
```bash
kubectl get configmap app-config -o yaml
```

### Step 2: Create a Pod Using ConfigMap as Environment Variables

```bash
kubectl apply -f manifests/pod-env.yaml
```

Verify the environment variables:
```bash
kubectl exec env-pod -- env | grep APP_
```

**Expected output:**
```
APP_COLOR=blue
APP_MODE=production
```

### Step 3: Create a ConfigMap with a Config File

```bash
kubectl apply -f manifests/nginx-config.yaml
```

### Step 4: Mount ConfigMap as a Volume

```bash
kubectl apply -f manifests/pod-volume.yaml
```

Verify the mounted file:
```bash
kubectl exec nginx-custom -- cat /etc/nginx/conf.d/default.conf
```

Test it works:
```bash
kubectl port-forward nginx-custom 8080:80 &
curl localhost:8080
# You should see "ConfigMap works!"
kill %1
```

### Step 5: Create a Secret

```bash
kubectl apply -f manifests/db-secret.yaml
```

View the secret (values are base64-encoded):
```bash
kubectl get secret db-secret -o yaml
```

### Step 6: Use Secret in a Pod

```bash
kubectl apply -f manifests/pod-secret.yaml
```

Verify:
```bash
kubectl exec secret-pod -- env | grep DB_
kubectl exec secret-pod -- cat /etc/db-credentials/DB_PASSWORD
```

### Step 7: Update a ConfigMap and Observe

```bash
kubectl patch configmap app-config -p '{"data":{"APP_COLOR":"red"}}'

# For env vars: pod needs restart
kubectl delete pod env-pod
kubectl apply -f manifests/pod-env.yaml
kubectl exec env-pod -- env | grep APP_COLOR
```

## Checkpoint

- ConfigMaps store non-sensitive configuration
- Secrets store sensitive data (base64-encoded)
- Both can be consumed as env vars or mounted files
- Env vars require pod restart to update; mounted files auto-update

## Cleanup

```bash
kubectl delete -f manifests/
```

## Next Exercise

[05: Persistent Storage →](../05-persistent-storage/)
