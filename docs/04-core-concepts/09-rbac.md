# RBAC (Role-Based Access Control)

## What is RBAC?

**RBAC** controls who can do what in a Kubernetes cluster. It answers the question: "Can user X perform action Y on resource Z?"

> See the full diagram: [RBAC Model](diagrams/rbac-model.d2)

## RBAC Components

### Subjects (Who)

| Subject | Description |
|---------|-------------|
| **User** | Human user (managed outside K8s, e.g., certificates, OIDC) |
| **Group** | Set of users |
| **ServiceAccount** | Identity for pods/processes running inside the cluster |

### Resources (What)

Kubernetes API resources: pods, deployments, services, configmaps, secrets, etc.

### Verbs (Actions)

| Verb | Description |
|------|-------------|
| `get` | Read a single resource |
| `list` | List multiple resources |
| `watch` | Watch for changes |
| `create` | Create a resource |
| `update` | Modify a resource |
| `patch` | Partially modify a resource |
| `delete` | Delete a resource |

## The Four RBAC Resources

### Role (Namespace-Scoped)

Defines permissions within a **single namespace**.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: development
rules:
  - apiGroups: [""]               # "" = core API group (pods, services, etc.)
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get"]
```

### ClusterRole (Cluster-Scoped)

Defines permissions across the **entire cluster** or for cluster-scoped resources.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
  - apiGroups: [""]
    resources: ["nodes"]           # Cluster-scoped resource
    verbs: ["get", "list", "watch"]
```

### RoleBinding (Namespace-Scoped)

Connects a **subject** to a **Role** within a namespace.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: development
subjects:
  - kind: User
    name: jane
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader                # References the Role above
  apiGroup: rbac.authorization.k8s.io
```

### ClusterRoleBinding (Cluster-Scoped)

Connects a subject to a **ClusterRole** across all namespaces.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-nodes-global
subjects:
  - kind: Group
    name: developers
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

## How It All Connects

```
Subject (User/Group/ServiceAccount)
    ↓
RoleBinding / ClusterRoleBinding
    ↓
Role / ClusterRole
    ↓
Rules (apiGroups + resources + verbs)
```

### Example Scenario

"Developer Jane can read pods in the development namespace":

1. **Role** `pod-reader` in `development` namespace: allows `get`, `list`, `watch` on pods
2. **RoleBinding** `read-pods` in `development` namespace: binds user `jane` to role `pod-reader`

## ServiceAccounts

ServiceAccounts are identities for pods. Every pod runs under a ServiceAccount.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app
  namespace: default
```

```yaml
# Pod using a specific ServiceAccount
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  serviceAccountName: my-app      # Use this ServiceAccount
  containers:
    - name: app
      image: my-app:1.0
```

By default, pods use the `default` ServiceAccount in their namespace, which has minimal permissions.

## Built-in ClusterRoles

Kubernetes provides default ClusterRoles:

| ClusterRole | Permissions |
|-------------|-------------|
| `cluster-admin` | Full access to everything |
| `admin` | Full access within a namespace |
| `edit` | Read/write most resources in a namespace |
| `view` | Read-only access to most resources in a namespace |

```bash
# Give user "jane" edit access in "development" namespace
kubectl create rolebinding jane-edit \
  --clusterrole=edit \
  --user=jane \
  --namespace=development
```

## Common kubectl Commands

```bash
# List Roles and ClusterRoles
kubectl get roles -n development
kubectl get clusterroles

# List bindings
kubectl get rolebindings -n development
kubectl get clusterrolebindings

# Check if you can perform an action
kubectl auth can-i create pods
kubectl auth can-i create pods --as jane
kubectl auth can-i create pods --as jane -n development

# Describe a role
kubectl describe role pod-reader -n development

# Create ServiceAccount
kubectl create serviceaccount my-app
```

## Best Practices

1. **Principle of least privilege** — Grant only the minimum permissions needed
2. **Use Roles over ClusterRoles** when possible (namespace-scoped)
3. **Avoid cluster-admin** for regular users
4. **Use Groups** for team-based access (easier to manage)
5. **Audit regularly** — Review who has access to what

## What's Next?

- [Labels & Selectors →](10-labels-selectors.md)
