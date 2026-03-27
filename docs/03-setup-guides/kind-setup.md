# kind Setup Guide

kind (Kubernetes IN Docker) is the **recommended tool** for this repository. It creates Kubernetes clusters by running nodes as Docker containers, which means setup is fast, lightweight, and reproducible.

This guide takes you from zero to a working cluster, step by step.

## Table of Contents

- [1. Verify Prerequisites](#1-verify-prerequisites)
- [2. Create Your First Cluster](#2-create-your-first-cluster)
- [3. Verify the Cluster](#3-verify-the-cluster)
- [4. Explore the Cluster](#4-explore-the-cluster)
- [5. Multi-Node Cluster](#5-multi-node-cluster)
- [6. Port Mappings](#6-port-mappings)
- [7. Ingress Controller Setup](#7-ingress-controller-setup)
- [8. Loading Local Docker Images](#8-loading-local-docker-images)
- [9. Cluster Lifecycle](#9-cluster-lifecycle)
- [10. Tips and Advanced Usage](#10-tips-and-advanced-usage)

---

## 1. Verify Prerequisites

Before creating a cluster, confirm that all three required tools are installed and working:

```bash
docker --version
kubectl version --client
kind version
```

Expected output:

```
Docker version 27.5.1, build 9f9e405
Client Version: v1.32.3
kind v0.27.0 go1.23.6 darwin/arm64
```

Also verify that the Docker daemon is running:

```bash
docker info > /dev/null 2>&1 && echo "Docker is running" || echo "Docker is NOT running"
```

Expected output:

```
Docker is running
```

> **Checkpoint**: All three version commands should succeed and Docker should be running. If any fail, go back to [Prerequisites](prerequisites.md).

---

## 2. Create Your First Cluster

### Using the Repository Script (Recommended)

The repository includes a setup script that creates a cluster with sensible defaults:

```bash
./scripts/setup-kind.sh
```

Expected output:

```
Creating single-node cluster: k8s-local
Creating cluster "k8s-local" ...
 ✓ Ensuring node image (kindest/node:v1.32.2) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-k8s-local"
...
============================================
  Cluster 'k8s-local' is ready!
============================================

Context: kind-k8s-local
Nodes:
NAME                      STATUS   ROLES           AGE   VERSION
k8s-local-control-plane   Ready    control-plane   30s   v1.32.2
```

### Manual Creation

If you prefer to create the cluster manually:

```bash
kind create cluster --name k8s-local
```

Expected output:

```
Creating cluster "k8s-local" ...
 ✓ Ensuring node image (kindest/node:v1.32.2) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-k8s-local"
You can now use your cluster with:

kubectl cluster-info --context kind-k8s-local

Have a nice day! 👋
```

> **What happens behind the scenes**: kind pulls a Docker image (`kindest/node`) that contains all Kubernetes components, starts it as a container, and configures it as a single-node cluster. It also updates your kubeconfig so kubectl can connect.

> **Checkpoint**: The command should complete without errors and show "Set kubectl context to kind-k8s-local". If creation fails, check the [Troubleshooting Guide](troubleshooting.md).

---

## 3. Verify the Cluster

### Quick Verification

Check that kubectl can reach the cluster:

```bash
kubectl cluster-info
```

Expected output:

```
Kubernetes control plane is running at https://127.0.0.1:PORT
CoreDNS is running at https://127.0.0.1:PORT/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

Check that the node is ready:

```bash
kubectl get nodes
```

Expected output:

```
NAME                      STATUS   ROLES           AGE   VERSION
k8s-local-control-plane   Ready    control-plane   1m    v1.32.2
```

> The STATUS must say **Ready**. If it says **NotReady**, wait 30 seconds and try again -- the node may still be initializing.

### Full Verification Script

Run the repository's verification script for a comprehensive check:

```bash
./scripts/verify-cluster.sh
```

Expected output:

```
============================================
  Kubernetes Cluster Verification
============================================

Prerequisites:
  ✓ kubectl installed
  ✓ docker running

Cluster Connectivity:
  ✓ kubectl can reach cluster
  ✓ API server responding

Node Status:
  ✓ Nodes are Ready

  Nodes found: 1

Core Components:
  ✓ kube-system pods running
  ✓ CoreDNS running

Basic Functionality:
  ✓ Can create namespace
  ✓ Can create pods

============================================
  Results: 8 passed, 0 failed
============================================
```

> **Checkpoint**: All checks should pass (green checkmarks). If any fail, the script will point you to the troubleshooting guide.

---

## 4. Explore the Cluster

Now that the cluster is running, let's look around to understand what Kubernetes set up automatically.

### List All Namespaces

```bash
kubectl get namespaces
```

Expected output:

```
NAME                 STATUS   AGE
default              Active   2m
kube-node-lease      Active   2m
kube-public          Active   2m
kube-system          Active   2m
local-path-storage   Active   2m
```

These namespaces are created automatically:

| Namespace | Purpose |
|-----------|---------|
| `default` | Where your workloads go if you do not specify a namespace |
| `kube-system` | Kubernetes internal components (API server, scheduler, etc.) |
| `kube-node-lease` | Node heartbeat tracking |
| `kube-public` | Publicly readable data (rarely used) |
| `local-path-storage` | kind's built-in storage provisioner |

### List All Running Pods

```bash
kubectl get pods --all-namespaces
```

Expected output:

```
NAMESPACE            NAME                                              READY   STATUS    RESTARTS   AGE
kube-system          coredns-7c65d6cfc9-abcde                         1/1     Running   0          2m
kube-system          coredns-7c65d6cfc9-fghij                         1/1     Running   0          2m
kube-system          etcd-k8s-local-control-plane                     1/1     Running   0          2m
kube-system          kindnet-xxxxx                                    1/1     Running   0          2m
kube-system          kube-apiserver-k8s-local-control-plane            1/1     Running   0          2m
kube-system          kube-controller-manager-k8s-local-control-plane   1/1     Running   0          2m
kube-system          kube-proxy-xxxxx                                 1/1     Running   0          2m
kube-system          kube-scheduler-k8s-local-control-plane            1/1     Running   0          2m
local-path-storage   local-path-provisioner-xxxxxxxxx-xxxxx            1/1     Running   0          2m
```

> These are the core Kubernetes components. You will learn about each of them in the core concepts section of this repository.

### Check the Kubernetes Context

kubectl uses "contexts" to know which cluster to talk to. Verify you are connected to the kind cluster:

```bash
kubectl config current-context
```

Expected output:

```
kind-k8s-local
```

### View All Contexts

```bash
kubectl config get-contexts
```

Expected output:

```
CURRENT   NAME             CLUSTER          AUTHINFO         NAMESPACE
*         kind-k8s-local   kind-k8s-local   kind-k8s-local
```

The `*` indicates your active context.

> **Checkpoint**: You should see the `kind-k8s-local` context as current, all system pods running, and 4-5 namespaces. This means your cluster is healthy and ready for exercises.

---

## 5. Multi-Node Cluster

A single-node cluster is fine for most exercises, but some topics (scheduling, node affinity, pod anti-affinity) require multiple nodes. kind makes this easy with a configuration file.

### Using the Repository Script

```bash
# Delete the existing cluster first
kind delete cluster --name k8s-local

# Create a multi-node cluster
./scripts/setup-kind.sh k8s-local --multi-node
```

### Manual Multi-Node Setup

Create a file called `kind-multi-node.yaml`:

```yaml
# kind-multi-node.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: k8s-local
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
  - role: worker
  - role: worker
```

Apply the configuration:

```bash
kind create cluster --config kind-multi-node.yaml
```

Expected output:

```
Creating cluster "k8s-local" ...
 ✓ Ensuring node image (kindest/node:v1.32.2) 🖼
 ✓ Preparing nodes 📦 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-k8s-local"
```

> Notice the three package icons (📦 📦 📦) -- one for each node being prepared.

Verify the nodes:

```bash
kubectl get nodes
```

Expected output:

```
NAME                      STATUS   ROLES           AGE   VERSION
k8s-local-control-plane   Ready    control-plane   45s   v1.32.2
k8s-local-worker          Ready    <none>          30s   v1.32.2
k8s-local-worker2         Ready    <none>          30s   v1.32.2
```

You can also see the nodes as Docker containers:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Expected output:

```
NAMES                      STATUS          PORTS
k8s-local-control-plane    Up 1 minute     0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, ...
k8s-local-worker           Up 1 minute
k8s-local-worker2          Up 1 minute
```

> **Checkpoint**: You should see 3 nodes in Ready status -- 1 control-plane and 2 workers. Each node is a Docker container running on your machine.

---

## 6. Port Mappings

By default, services inside the kind cluster are not accessible from your host machine. Port mappings bridge that gap by forwarding traffic from a host port to a container port.

The repository setup script already includes port mappings for ports 80 and 443. Here is how they work in the kind configuration:

```yaml
nodes:
  - role: control-plane
    extraPortMappings:
      # Forward host port 80 to container port 80 (HTTP)
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      # Forward host port 443 to container port 443 (HTTPS)
      - containerPort: 443
        hostPort: 443
        protocol: TCP
```

### Adding Custom Port Mappings

If you need to expose additional ports (for example, a NodePort service on port 30000):

```yaml
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
      - containerPort: 30000
        hostPort: 30000
        protocol: TCP
```

> **Important**: Port mappings can only be set at cluster creation time. If you need to change them, you must delete and recreate the cluster.

### Using kubectl port-forward (Alternative)

For quick, temporary access to a specific service without pre-configured port mappings:

```bash
# Forward local port 8080 to a service's port 80
kubectl port-forward service/my-service 8080:80
```

Then access the service at `http://localhost:8080`.

> **Checkpoint**: If your cluster was created with the repository script, ports 80 and 443 are already mapped. You can verify with `docker ps` and checking the PORTS column.

---

## 7. Ingress Controller Setup

An Ingress controller is needed to route external HTTP traffic to services inside the cluster. kind works well with the NGINX Ingress Controller.

### Install NGINX Ingress Controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

Expected output:

```
namespace/ingress-nginx created
serviceaccount/ingress-nginx created
...
deployment.apps/ingress-nginx-controller created
...
```

### Wait for the Controller to be Ready

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

Expected output:

```
pod/ingress-nginx-controller-xxxxxxxxx-xxxxx condition met
```

### Verify Ingress Works

Create a quick test to verify the Ingress controller is functional:

```bash
# Create a test deployment and service
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo --port=80

# Create an Ingress resource
kubectl create ingress demo --class=nginx \
  --rule="demo.localhost/=demo:80"
```

Test it:

```bash
# Wait a few seconds for the Ingress to be configured, then:
curl http://demo.localhost/
```

Expected output:

```
<html><body><h1>It works!</h1></body></html>
```

> **Note on macOS**: `*.localhost` resolves to 127.0.0.1 by default. On Linux, you may need to add `127.0.0.1 demo.localhost` to `/etc/hosts`.

Clean up the test resources:

```bash
kubectl delete ingress demo
kubectl delete service demo
kubectl delete deployment demo
```

> **Checkpoint**: After installing the NGINX Ingress Controller, the curl command to `demo.localhost` should return "It works!". If not, verify the controller pod is running with `kubectl get pods -n ingress-nginx`.

---

## 8. Loading Local Docker Images

When you build Docker images locally (for example, from the `sample-apps/` directory), kind cannot pull them from a registry because they only exist on your machine. Use `kind load` to make them available inside the cluster.

### Build and Load an Image

```bash
# Build an image locally
docker build -t my-app:latest ./sample-apps/my-app/

# Load it into the kind cluster
kind load docker-image my-app:latest --name k8s-local
```

Expected output:

```
Image: "my-app:latest" with ID "sha256:abc123..." not yet present on node "k8s-local-control-plane", loading...
```

### Verify the Image is Available

```bash
docker exec k8s-local-control-plane crictl images | grep my-app
```

Expected output:

```
docker.io/library/my-app    latest    abc123def456    50.2MB
```

### Important: Use imagePullPolicy Correctly

When using locally loaded images, your pod spec must set `imagePullPolicy: Never` or `imagePullPolicy: IfNotPresent` to prevent Kubernetes from trying to pull the image from a remote registry:

```yaml
spec:
  containers:
    - name: my-app
      image: my-app:latest
      imagePullPolicy: IfNotPresent  # Use the locally loaded image
```

> **Checkpoint**: After loading an image with `kind load`, you should be able to see it listed with the `crictl images` command on the node.

---

## 9. Cluster Lifecycle

### List Existing Clusters

```bash
kind get clusters
```

Expected output:

```
k8s-local
```

### Delete a Cluster

```bash
kind delete cluster --name k8s-local
```

Expected output:

```
Deleting cluster "k8s-local" ...
Deleted nodes: ["k8s-local-control-plane"]
```

### Restart a Cluster

kind clusters survive Docker restarts. If you restart Docker (or your machine), the cluster containers will restart automatically.

To manually stop the cluster containers without deleting:

```bash
# Stop (pause) the cluster
docker stop k8s-local-control-plane

# Start it again later
docker start k8s-local-control-plane
```

> After restarting, wait 30-60 seconds for Kubernetes components to initialize, then verify with `kubectl get nodes`.

For multi-node clusters, stop and start all containers:

```bash
# Stop all nodes
docker stop k8s-local-control-plane k8s-local-worker k8s-local-worker2

# Start all nodes
docker start k8s-local-control-plane k8s-local-worker k8s-local-worker2
```

### Recreate a Cluster (Fresh Start)

If your cluster is in a bad state and you want to start over:

```bash
kind delete cluster --name k8s-local
./scripts/setup-kind.sh
```

> **Checkpoint**: `kind get clusters` should list your cluster. After deleting, the cluster name should no longer appear.

---

## 10. Tips and Advanced Usage

### Running Multiple Clusters

You can run multiple kind clusters simultaneously (useful for testing multi-cluster scenarios):

```bash
kind create cluster --name cluster-a
kind create cluster --name cluster-b
```

Switch between them:

```bash
kubectl config use-context kind-cluster-a
kubectl config use-context kind-cluster-b
```

> **Resource Warning**: Each cluster consumes CPU and memory. Two clusters with 3 nodes each means 6 Docker containers. Monitor your system resources.

### Using a Specific Kubernetes Version

kind supports multiple Kubernetes versions. Specify the version in your configuration:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.31.4
```

Or from the command line:

```bash
kind create cluster --name k8s-old --image kindest/node:v1.31.4
```

Available images are listed at [github.com/kubernetes-sigs/kind/releases](https://github.com/kubernetes-sigs/kind/releases).

### Exporting Cluster Logs

If you need to debug kind internals:

```bash
kind export logs --name k8s-local ./kind-logs/
```

This creates a directory with logs from all nodes and Kubernetes components.

### Resource Limits for Docker Desktop (macOS)

If running on macOS with Docker Desktop, ensure sufficient resources are allocated:

1. Open Docker Desktop
2. Go to Settings (gear icon) > Resources
3. Set at least: CPUs: 4, Memory: 8 GB, Disk: 20 GB
4. Click "Apply & Restart"

---

## Next Steps

Your cluster is ready. Here is what to do next:

1. **Run the verification script** to confirm everything works:

   ```bash
   ./scripts/verify-cluster.sh
   ```

2. **Start the first exercise**:

   ```bash
   cd exercises/00-verify-setup/
   ```

3. If you encounter issues, check the [Troubleshooting Guide](troubleshooting.md).
