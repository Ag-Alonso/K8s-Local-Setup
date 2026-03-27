# Prerequisites

Before setting up a local Kubernetes cluster, you need three core tools installed: **Docker**, **kubectl**, and **kind**. This guide covers installation on both Linux and macOS.

## Table of Contents

- [System Requirements](#system-requirements)
- [Docker](#docker)
- [kubectl](#kubectl)
- [kind](#kind)
- [Optional Tools](#optional-tools)
- [Verification Summary](#verification-summary)

---

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 cores | 4 cores |
| RAM | 4 GB | 8 GB |
| Disk | 10 GB free | 20 GB free |
| Docker | 20.10+ | Latest |
| OS | Linux (x86_64/arm64) or macOS 12+ | Latest stable |

> **Note for Apple Silicon users**: All tools listed here support arm64 natively. No Rosetta required.

---

## Docker

Docker is the container runtime that kind uses to simulate Kubernetes nodes. Each Kubernetes "node" runs as a Docker container on your machine.

### Linux

**Debian / Ubuntu:**

```bash
# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
```

**Fedora / RHEL:**

```bash
# Install dnf plugins
sudo dnf -y install dnf-plugins-core

# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Install Docker Engine
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
```

**Post-install -- add your user to the docker group (avoids using sudo):**

```bash
sudo usermod -aG docker $USER
```

> **Important**: Log out and log back in for the group change to take effect. Alternatively, run `newgrp docker` in your current terminal.

### macOS

**Option A -- Docker Desktop (simplest):**

Download and install from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/). After installation, launch Docker Desktop from your Applications folder and wait for the whale icon in the menu bar to show "Docker Desktop is running".

**Option B -- Colima (lightweight, open source):**

```bash
brew install colima docker

# Start Colima with recommended resources
colima start --cpu 4 --memory 8
```

### Verify Docker

Run the following on either Linux or macOS:

```bash
docker --version
```

Expected output (version may differ):

```
Docker version 27.5.1, build 9f9e405
```

Now test that Docker can run containers:

```bash
docker run --rm hello-world
```

Expected output:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

> **Checkpoint**: At this point you should see the "Hello from Docker!" message. If you get a "permission denied" error on Linux, make sure you added your user to the docker group and logged out/in. If Docker is not running on macOS, launch Docker Desktop or start Colima.

---

## kubectl

kubectl is the command-line tool for interacting with Kubernetes clusters. You will use it constantly throughout the exercises.

### Linux

**Option A -- Download binary directly:**

```bash
# Download the latest stable release
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable and move to PATH
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

> For arm64 systems, replace `amd64` with `arm64` in the URL above.

**Option B -- Using apt (Debian/Ubuntu):**

```bash
# Add Kubernetes apt repo
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl
```

**Option C -- Using dnf (Fedora/RHEL):**

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF

sudo dnf install -y kubectl
```

### macOS

```bash
brew install kubectl
```

### Verify kubectl

```bash
kubectl version --client
```

Expected output:

```
Client Version: v1.32.3
Kustomize Version: v5.5.0
```

> The exact version numbers may differ. Any version 1.28 or later will work.

### Shell Completion (Recommended)

Shell completion saves time by letting you press Tab to auto-complete kubectl commands, resource names, and flags.

**Bash:**

```bash
# Add to your ~/.bashrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc

# Apply now without restarting shell
source ~/.bashrc
```

**Zsh:**

```bash
# Add to your ~/.zshrc
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
echo 'alias k=kubectl' >> ~/.zshrc

# Apply now without restarting shell
source ~/.zshrc
```

> **Checkpoint**: You should be able to run `kubectl version --client` and see a version number. If you set up the alias, `k version --client` should produce the same output.

---

## kind

kind (Kubernetes IN Docker) is the primary tool for this repository. It creates Kubernetes clusters by running each node as a Docker container, making it fast and lightweight.

### Linux

**Option A -- Download binary directly:**

```bash
# For amd64
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

> For arm64, replace `kind-linux-amd64` with `kind-linux-arm64`.

**Option B -- Using go install (requires Go 1.16+):**

```bash
go install sigs.k8s.io/kind@v0.27.0
```

### macOS

```bash
brew install kind
```

### Verify kind

```bash
kind version
```

Expected output:

```
kind v0.27.0 go1.23.6 darwin/arm64
```

> The platform shown (`darwin/arm64`, `linux/amd64`, etc.) will match your system.

> **Checkpoint**: Running `kind version` should display the installed version. If the command is not found, ensure `/usr/local/bin` (or `$GOPATH/bin` if you used `go install`) is in your PATH.

---

## Optional Tools

These are not required but will improve your learning experience.

### k9s -- Terminal UI for Kubernetes

k9s provides a visual, interactive terminal interface for navigating your cluster. It is much faster than typing kubectl commands repeatedly.

**macOS:**

```bash
brew install k9s
```

**Linux:**

```bash
# Download the latest release
curl -Lo k9s.tar.gz https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar xf k9s.tar.gz k9s
sudo mv k9s /usr/local/bin/
rm k9s.tar.gz
```

**Verify:**

```bash
k9s version
```

### kubectx and kubens -- Context and Namespace Switching

kubectx lets you quickly switch between Kubernetes clusters. kubens lets you switch the default namespace.

**macOS:**

```bash
brew install kubectx
```

**Linux:**

```bash
# Using krew (kubectl plugin manager)
kubectl krew install ctx
kubectl krew install ns
```

**Usage:**

```bash
# List contexts
kubectx

# Switch context
kubectx kind-k8s-local

# Switch default namespace
kubens kube-system
```

### Helm -- Kubernetes Package Manager

While this repository uses raw YAML manifests (to teach fundamentals), Helm is widely used in the real world. Installing it now prepares you for future learning.

**macOS:**

```bash
brew install helm
```

**Linux:**

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**Verify:**

```bash
helm version
```

### d2 -- Diagram Renderer

This repository includes architecture diagrams written in D2 format. Install d2 if you want to render or modify them.

**macOS:**

```bash
brew install d2
```

**Linux:**

```bash
curl -fsSL https://d2lang.com/install.sh | sh -s --
```

**Verify:**

```bash
d2 --version
```

**Render project diagrams:**

```bash
./scripts/render-diagrams.sh
```

---

## Verification Summary

Run through this checklist to confirm everything is ready:

```bash
# Docker
docker --version          # Should show 20.10+
docker run --rm hello-world  # Should print greeting

# kubectl
kubectl version --client  # Should show version

# kind
kind version              # Should show version
```

Expected results:

| Tool | Check | Expected |
|------|-------|----------|
| Docker | `docker --version` | Version 20.10 or later |
| Docker | `docker run --rm hello-world` | "Hello from Docker!" message |
| kubectl | `kubectl version --client` | Version 1.28 or later |
| kind | `kind version` | Version 0.20 or later |

> **Checkpoint**: All four checks above should pass. If any fail, review the installation steps for that specific tool or check the [Troubleshooting Guide](troubleshooting.md).

## Next Step

Proceed to [kind Setup](kind-setup.md) to create your first Kubernetes cluster.
