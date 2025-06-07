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

1. Start Minikube with appropriate resources and enable ingress:
```bash
minikube start --cpus 6 --memory 6144 --driver=docker
minikube addons enable ingress
```

2. Install istio and the required addons:
```bash
istioctl install
# go to the appropriate directory where istio is installed
kubectl apply -f istio-1.26.0/samples/addons/prometheus.yaml
kubectl apply -f istio-1.26.0/samples/addons/jaeger.yaml
kubectl apply -f istio-1.26.0/samples/addons/kiali.yaml
```
3. Enable istio sidecar injection for the namespace:
```bash
kubectl label namespace default istio-injection=enabled
```
5. Navigate to the Helm chart directory:
```bash
cd app-helm-chart
```

6. Install the application:
```bash
# Update dependencies first
helm dependency update
# Install the chart (optionally modify values.yaml first)
helm install my-app .
```

7. Configure Local Access

a. Check your service configuration in `values.yaml`:
```yaml
appFrontend:
  ingress:
    host: "app-frontend.k8s.local"  # Default frontend hostname
  service:
    port: 80              # Default frontend port

appService:
  stable:
    host: "app-service.k8s.local"  # Default backend hostname
  canary:
    host: "canary.app-service.k8s.local" # Default canary backend hostname
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
sudo sh -c "echo '$INGRESS_BIND_IP canary.app-service.k8s.local' >> /etc/hosts"

# Check if the hostnames are correctly added to the /etc/hosts file
cat /etc/hosts
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


### Clean up minikube:
```bash
# Uninstall the application
helm uninstall my-app

# Stop minikube
minikube stop
```

---

### Istio Rate Limiting Guide

- Run the following commands:

  ```bash
  # Apply rate limit ConfigMap and EnvoyFilter
  kubectl apply -f rate-limiting.yaml -n istio-system

  # Deploy the rate limit service
  kubectl apply -f path/to/istio/samples/ratelimit/rate-limit-service.yaml -n istio-system
  ```
- Test Rate Limiting:

  Replace the `GATEWAY_PORT` value with your actual NodePort (found via `kubectl -n istio-system get svc istio-ingressgateway`).

  ```bash
  export GATEWAY_PORT=30530  # Replace with your actual port

  for i in {1..20}; do
    curl -H "Host: app-frontend.k8s.local" -s -o /dev/null -w "%{http_code}\n" http://192.168.49.2:$GATEWAY_PORT/
  done
  ```
  If over 10 requests are made within one minute, subsequent ones should return a 429 Too Many Requests error.

---
### Check Prometheus and Grafana with Helm

Ensure the `prometheus-community` Helm repository is added to your local Helm setup, check it by running:

```bash
helm repo list
```

Ensure `my-app-grafana` in the pod, check it by running:

```bash
kubectl get svc -n default
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
  - Password: `prom-operator` (for kubernetes cluster deployment)

Note: The port number (1234) can be changed to any available port on your local machine.

3. Import the Dashboard
- In the Grafana UI:
  1. Go to **Dashboards** in the left sidebar
  2. Click **New** → **Import**
  3. Upload the dashboard JSON file or paste the JSON content
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

To spin up the VMs, make sure to be in the '/vagrant' directory

### Provisioning the Kubernetes cluster and spinning up VMs

First, copy your SSH public key into the template files:

```bash
cp ~/.ssh/id_rsa.pub /ssh/<your_username>.pub
```

Then, run the following command to start the VMs and provision them with Ansible:

```bash
vagrant up
```

After the Kubernetes cluster is up, the installation can be finalized by running the following command in the `vagrant/` directory:

```bash
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization.yml
```

Afterwards, you can find the kubernetes configuration file in `config/.kubeconfig`. You can use this file to connect to the Kubernetes cluster from your local machine. Make sure to set the `KUBECONFIG` environment variable to point to this file:

```bash
kubectl --kubeconfig config/.kubeconfig ...
```