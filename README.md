# Operation

This repository helps connect and run the services developed by REMLA 2025 Team 9. The application can be run either using Docker Compose locally or deployed to a Kubernetes cluster using Minikube and Helm.

## Option 1: Running with Docker Compose

Make sure Docker and Docker Compose are installed. Then:

Configure the env files for each service:
* app-service.env
* app-frontend.env
* model-service.env

To use the default configurations, copy the example files:

```bash
cp app-service.env.example app-service.env
cp app-frontend.env.example app-frontend.env
cp model-service.env.example model-service.env
```

Start the services:
```bash
docker compose up -d
```

To stop the services:

```bash
docker compose down
```

If you're using GitHub Container Registry (GHCR) images and encounter permission errors, log in first:

```bash
echo $GH_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

## Option 2: Running with Minikube and Helm

### Prerequisites
- Minikube
- Helm
- kubectl

### Setup steps

1. Start Minikube with appropriate resources:
```bash
minikube start --cpus 2 --memory 2048 --driver=docker
```

2. Navigate to the Helm chart directory:
```bash
cd app-helm-chart
```

3. Install the ingress-nginx repository manually
```bash
# Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Update repositories
helm repo update

# Create namespace for ingress-nginx
kubectl create namespace ingress-nginx

# Install ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer
```

3. Install the application:
```bash
# Update dependencies first
helm dependency update
# Install the chart (optionally modify values.yaml first)
helm install my-app .
```

4. Configure Local Access

a. Check your service configuration in `values.yaml`:
```yaml
appFrontend:
  ingress:
    host: "app-frontend.k8s.local"  # Default frontend hostname
  service:
    port: 80              # Default frontend port

appService:
  ingress:
    host: "app-service.k8s.local"  # Default backend hostname
  service:
    port: 80              # Default backend port
```

b. Start Minikube tunnel with a fixed IP:
```bash
# Use any IP address you prefer, default is 127.0.0.1
export INGRESS_BIND_IP=127.0.0.1
minikube tunnel --bind-address $INGRESS_BIND_IP
```

c. Add hostnames to your local hosts file:

**Linux/macOS**:
```bash
# Replace hostnames if you changed them in values.yaml
sudo sh -c "echo '$INGRESS_BIND_IP app-frontend.k8s.local' >> /etc/hosts"
sudo sh -c "echo '$INGRESS_BIND_IP app-service.k8s.local' >> /etc/hosts"
```

**Windows** (Run PowerShell as Administrator):
```powershell
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "$INGRESS_BIND_IP app-frontend.k8s.local"
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "$INGRESS_BIND_IP app-service.k8s.local"
```

d. Access your services:
- Frontend: `http://app-frontend.k8s.local:<frontend_port>`
  - Default: http://app-frontend.k8s.local
  - Custom: Use the port specified in `appFrontend.service.port`

- Backend API: `http://app-service.k8s.local:<backend_port>`
  - Default: http://app-service.k8s.local
  - Custom: Use the port specified in `appService.service.port`

Note: If you modify the default ports in `values.yaml`, you'll need to include them in the URL:
```yaml
# Example custom port configuration
appFrontend:
  service:
    port: 8080  # Access via http://app-frontend.k8s.local:8080
```


### Useful kubectl commands when the cluster is running

Monitor the deployment:
```bash
# Get all pods
kubectl get pods

# Get all services
kubectl get services

# Get ingress details
kubectl get ingress

# View pod logs
kubectl logs -l app=app-frontend
kubectl logs -l app=app-service
kubectl logs -l app=model-service

# Describe resources for troubleshooting
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl describe ingress <ingress-name>
```

Clean up:
```bash
# Uninstall the application
helm uninstall my-app

# Stop minikube
minikube stop
```

---

## Repositories

Each repository has a `README.md` file with information about running. Below is a summary of each repository:

| Repository                                                          | Description                                                                                                                                                                                                                        |
|---------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [model-training](https://github.com/remla2025-team9/model-training) | Code for training ML models using datasets, including preprocessing, training, evaluation, and model saving.                                                                                                                       |
| [model-service](https://github.com/remla2025-team9/model-service)   | Serves predictions from a trained ML model via a REST API. Built with Flask, containerized with Docker, and supports integration with `app-service`.                                                                               |
| [lib-ml](https://github.com/remla2025-team9/lib-ml)                 | Contains shared logic for data preprocessing and any ML-related utilities. Used by both training and inference components.                                                                                                         |
| [app-service](https://github.com/remla2025-team9/app-service)       | Flask-based web service providing the main API interface. Includes `/healthcheck` and `/version`  routes and is configured to run in a Docker container. CI/CD is enabled for automatic tagging, versioning, and image publishing. |
| [app-frontend](https://github.com/remla2025-team9/app-service)      | Frontend application showing the status of the system, version info, or predictions. Communicates with `app-service`.                                                                                                              |
| [lib-version](https://github.com/remla2025-team9/lib-version)       | Lightweight Python library with a `VersionUtil` class to retrieve the current version. Version is maintained in `__version__.py` and updated automatically using GitHub workflows.                                                 |
| [operation](https://github.com/remla2025-team9/operation)           | Orchestrates all project services using `docker-compose`. Includes `README.md`, `docker-compose.yml`, and activity log for all assignments                                                                                         |


## Provision

Start the environment:

```bash
vagrant up --provision
```

### Environment variables

The following environment variables can be used to customize the VM configurations:

| Variable | Description | Default |
|----------|-------------|---------|
| WORKER_COUNT_ENV | Number of worker nodes to create | 2 |
| WORKER_CPU_COUNT_ENV | Number of CPUs for each worker | 2 |
| WORKER_MEMORY_ENV | Memory (MB) for each worker | 6144 |
| CONTROLLER_CPU_COUNT_ENV | Number of CPUs for controller | 1 |
| CONTROLLER_MEMORY_ENV | Memory (MB) for controller | 4096 |

To set all environment variables locally before starting (all values can be changed to match your needs):

```bash
export WORKER_COUNT_ENV=1
export WORKER_CPU_COUNT_ENV=1
export WORKER_MEMORY_ENV=1024
export CONTROLLER_CPU_COUNT_ENV=2
export CONTROLLER_MEMORY_ENV=2048
vagrant up
```

### Base configuration

- All VMs use the `bento/ubuntu-24.04` box.
- VMs are assigned static IPs in the `192.168.56.*` range:
  - Controller node (`ctrl`): `192.168.56.100`
  - Worker nodes: `192.168.56.101`, `192.168.56.102`, ...

### Ansible provisioning

Each VM is further configured using Ansible playbooks:

- **Controller (`ctrl`)** runs:
  - `ansible/general.yaml`
  - `ansible/ctrl.yaml`
- **Worker nodes (`node-X`)** run:
  - `ansible/general.yaml`
  - `ansible/node.yaml`

To spin up the VMs, make sure to be in the '/vagrant' directory and run:

```bash
vagrant up
```

After the Kubernetes cluster is up, the installation can be finalized by running the following command in the `/vagrant/ansible` directory:

```bash
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization.yml
```

Afterwards, you can find the kubernetes configuration file in `config/.kubeconfig`. You can use this file to connect to the Kubernetes cluster from your local machine. Make sure to set the `KUBECONFIG` environment variable to point to this file:

```bash
kubectl --kubeconfig config/.kubeconfig ...
```

### Install the application 

```bash
helm upgrade --install --namespace application --create-namespace restaurant-review ./app-helm-chart
```

### Installing Prometheus with Helm

Ensure the `prometheus-community` Helm repository is added to your local Helm setup:

Run:

```bash
helm repo list
```

Look for prometheus-community in the list. If it’s not there, add it with:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts/

# Update Helm repositories:
helm repo update

# Install the Prometheus Kube-Prometheus-Stack chart:
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

### Accessing Grafana Dashboard in Minikube

1. Access Grafana UI using port forwarding:
```bash
kubectl port-forward -n default svc/my-app-grafana 1234:80
```

- Navigate to: http://localhost:1234

2. Log in to Grafana
- Default credentials:
  - Username: `admin`
  - Password: `admin` (for minikube deployment)
  - Password: `prom-operator` (for kubernetes cluster deployment)

Note: The port number (1234) can be changed to any available port on your local machine.

3. Import the Dashboard
- In the Grafana UI:
  1. Go to **Dashboards** in the left sidebar
  2. Click **New** → **Import**
  3. Upload the dashboard JSON file or paste the JSON content