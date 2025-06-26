# REMLA 2025 Team 9 - Operations

This repository contains the necessary configuration to run and operate the services developed by REMLA 2025 Team 9. You can run the entire application stack locally using Docker Compose or deploy it to a Kubernetes cluster.

## Project Repositories

You can click on the repository name to navigate to the corresponding GitHub page.

| Repository                                                          | Description                                                                                           |
| ------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| [model-training](https://github.com/remla2025-team9/model-training) | Trains ML models, including preprocessing, training, evaluation, and model saving.                    |
| [model-service](https://github.com/remla2025-team9/model-service)   | Serves predictions from a trained ML model via a REST API.                                            |
| [lib-ml](https://github.com/remla2025-team9/lib-ml)                 | Shared logic for data preprocessing and other ML-related utilities.                                   |
| [app-service](https://github.com/remla2025-team9/app-service)       | The main backend API service, built with Flask.                                                       |
| [app-frontend](https://github.com/remla2025-team9/app-service)      | Frontend application that communicates with `app-service` to display system status and predictions.   |
| [lib-version](https://github.com/remla2025-team9/lib-version)       | A lightweight library for managing and retrieving the application version.                            |
| [operation](https://github.com/remla2025-team9/operation)           | Orchestrates all services using Docker Compose, Helm for Kubernetes, and Vagrant for VM provisioning. |



## Project Structure

- **`docker-compose/`** - Contains Docker Compose files and environment configurations for local development
- **`app-helm-chart/`** - Kubernetes deployment files using Helm
- **`vagrant/`** - Scripts to provision a multi-node Kubernetes cluster using VMs through Vagrant and Ansible
- **`docs/`** - Documentation files

## Getting Started

You have two main options for running the application:

1.  **Docker Compose:** For a quick, lightweight local setup.
2.  **Kubernetes:** For a full-fledged deployment that mirrors a production environment.

## Method 1: Local Development with Docker Compose

This is the simplest way to get all services running on your local machine.

**Prerequisites:**
*   Docker
*   Docker Compose

**Steps:**

1.  **Navigate to the Docker Compose Directory:**
    ```bash
    cd docker-compose
    ```

2.  **Configure Environment:**
    Copy the template environment files. The default values are suitable for most local setups.
    ```bash
    cp env-files/app-service.env.template env-files/app-service.env
    cp env-files/app-frontend.env.template env-files/app-frontend.env
    cp env-files/model-service.env.template env-files/model-service.env
    ```

3.  **Start Services:**
    This command will download the necessary images and start all services in the background.
    ```bash
    docker compose up -d
    ```

4.  **Access Services:**
    *   App-frontend: `http://localhost:3000`
    *   App-backend: `http://localhost:5000`

5.  **Stop Services:**
    ```bash
    docker compose down
    ```

> **Note:** If you are using images from GitHub Container Registry (GHCR) and encounter permission errors, log in to Docker first:
> `echo $GH_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin`

---

## Method 2: Kubernetes Deployment

This method deploys the application to a Kubernetes cluster using Helm. You can set up the cluster using either Minikube (local) or Vagrant (virtual machines).

---

### **Step 1: Set Up Your Kubernetes Environment**

Choose one of the following options to prepare your cluster, either Minikube or Vagrant (click on the prefered option).

---

### Option A: Using Minikube

---

**Prerequisites:**
*   Minikube
*   kubectl
*   Helm
*   istioctl

**Instructions:**

1.  **Start Minikube:**
    Start a Minikube instance with sufficient resources and enable the `ingress` addon.
    ```bash
    minikube start --cpus 6 --memory 6144 --driver=docker
    minikube addons enable ingress
    ```

2.  **Install Istio:**
    Install Istio and its monitoring addons (Jaeger for tracing, Kiali for service mesh visualization).
    ```bash
    # Install the Istio control plane
    istioctl install

    # Apply addons (ensure the path to your Istio installation is correct)
    kubectl apply -f istio-1.26.0/samples/addons/jaeger.yaml
    kubectl apply -f istio-1.26.0/samples/addons/kiali.yaml
    ```

3.  **Enable Istio Sidecar Injection:**
    Label the `default` namespace to instruct Istio to automatically inject proxy sidecars into your application pods.
    ```bash
    kubectl label namespace default istio-injection=enabled
    ```
Your Minikube cluster is now prepared. Proceed to **Step 2: Deploy the Application with Helm**.

---

### Option B: Using Vagrant and Ansible

----

**Prerequisites:**
*   Vagrant
*   Ansible
*   VirtualBox

**1. Configure VM Resources (Optional):**
The following environment variables can be used to customize the VM configurations.

| Variable                   | Description                      | Default |
| -------------------------- | -------------------------------- | ------- |
| `WORKER_COUNT_ENV`         | Number of worker nodes to create | 2       |
| `WORKER_CPU_COUNT_ENV`     | Number of CPUs for each worker   | 2       |
| `WORKER_MEMORY_ENV`        | Memory (MB) for each worker      | 6144    |
| `CONTROLLER_CPU_COUNT_ENV` | Number of CPUs for controller    | 1       |
| `CONTROLLER_MEMORY_ENV`    | Memory (MB) for controller       | 4096    |

To set these variables, export them in your terminal before starting vagrant:

**Linux/macOS:**
```bash
# This is an example configuration for the variables
export WORKER_COUNT_ENV=1
export WORKER_MEMORY_ENV=8192
```

**2. Provision VMs and Cluster:**
These commands will create the VMs, install dependencies, and set up a Kubernetes cluster using Ansible:

```bash
# Navigate to the Vagrant directory containing the Vagrantfile
cd vagrant/

# Copy your SSH public key to be authorized on the VMs
# This allows passwordless SSH access to the provisioned machines
# If you don't have an SSH key yet, create one with: ssh-keygen -t rsa -b 4096
cp ~/.ssh/id_rsa.pub ssh/<your_username>.pub

# Start and provision the VMs according to the Vagrantfile configuration
# Note: The higher the CPU counts and memory were set, the faster this command executes
vagrant up

# Run the finalization playbook to complete the Kubernetes setup
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization.yml
```

Your cluster is now running. A `kubeconfig` file to access it is located at `config/.kubeconfig`. You can use it by setting the `KUBECONFIG` environment variable to this file 

```bash
export KUBECONFIG=$(pwd)/config/.kubeconfig
```
or simply use the following command.

```bash
kubectl --kubeconfig config/.kubeconfig ...
```

Proceed to **Step 2: Deploy the Application with Helm**.

</details>

---

### **Step 2: Deploy the Application with Helm**

Before proceeding, ensure kubectl is properly configured to communicate with your cluster. Run `kubectl get nodes -A` to verify connectivity. You should see your cluster's nodes listed with a status of "Ready". If you encounter errors, double-check that your kubeconfig is correctly set up as described in the previous step. For Minikube, kubectl configuration should happen automatically, while for Vagrant, you'll need to set the KUBECONFIG environment variable or merge the provided config file.

The Helm chart supports email alerting, but requires configuration to work. There is no default setup, you must follow these steps to enable alert emails:

1. Create an app password for your Google account:
   - Go to your Google Account settings
   - Navigate to the "Security" section
   - Enable 2-Step Verification if you haven't already
   - Under "Signing in to Google," find the "App passwords" option (or navigate directly to https://myaccount.google.com/apppasswords)
   - Create a new app password for the application (e.g., "Alert Mail")

2. Modify the `values.yaml` file in the Helm chart to include your email and app password. The alerts will be sent from this email address:
   ```yaml
   alertCreds:
     username: <your-gmail-address>
     password: <your-app-password>
   ```

> **Note:** You can always change the email alert settings later using the same step-by-step plan. Make sure to update the helm chart after making these modifications.

The mail alerts will be sent to the email address `remla2025team9.alerts@gmail.com`. The credentials to login to this email are:
```text
Username: remla2025team9.alerts@gmail.com
Password: team9-alerts
```

Once your cluster is running, deploy the application using the provided Helm chart.

1.  **Navigate to the Helm Chart Directory:**
    ```bash
    cd app-helm-chart
    ```

2.  **Update Helm Dependencies:**
    This downloads any chart dependencies listed in `Chart.yaml`.
    ```bash
    helm dependency update
    ```

3.  **Install the Helm Chart:**
    This command deploys all project services, ingresses, and configurations to your cluster. It is possible to either run the charts with the Ingress gateway or the Istio gateway. The default is the Istio gateway, but you can change this in the `values.yaml` file by modifying the boolean value of `useNginxIngress`. If you set it to `true`, the chart will use the Nginx Ingress controller instead of Istio.
    ```bash
    # You can change 'my-app' to any release name you prefer
    helm install my-app .
    ```
    >**Note:** If you want to use the Nginx Ingress controller instead of Istio, make sure to delete Istio with the following `istioctl uninstall --purge` command
---

### **Step 3: Access the Application Locally**

To access the application from your browser, you must map the service hostnames to the cluster's ingress IP address on your local machine.

1.  **Find and Expose the Ingress IP Address:**
    *   **For Minikube:** You must create a tunnel from your local machine to the cluster's ingress controller. **Open a new, dedicated terminal** and run the following command. It will run continuously.
        ```bash
        # We bind to 127.0.0.1 for consistency
        minikube tunnel --bind-address 127.0.0.1
        ```
        The Ingress IP for your `hosts` file will be `127.0.0.1`.

    *   **For Vagrant:** The Ingress IP is static and pre-configured in the environment.
        The Ingress IP is `192.168.56.91`.

2.  **Update Your Local `hosts` File:**
    Add an entry to your local `hosts` file to resolve the application domains to the Ingress IP.

    *   **Linux/macOS** (`/etc/hosts`):
        ```bash
        # Replace {{ INGRESS_IP }} with 127.0.0.1 for Minikube or 192.168.56.91 for Vagrant
        # This command adds all required hostnames for the default setup
        sudo sh -c "echo '{{ INGRESS_IP }} app-frontend.k8s.local app-service.k8s.local grafana.k8s.local' >> /etc/hosts"

        # If you are running the vagrant setup, also add the Kubernetes dashboard hostnam
        sudo sh -c "echo '192.168.56.90 dashboard.k8s.local' >> /etc/hosts"
        
        # Verify the entry was added
        cat /etc/hosts
        ```

    *   **Windows** (Run PowerShell as Administrator):
        ```powershell
        # Replace {{ INGRESS_IP }} with 127.0.0.1 for Minikube or 192.168.56.91 for Vagrant
        Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "{{ INGRESS_IP }} app-frontend.k8s.local app-service.k8s.local canary.app-service.k8s.local"
        ```

3.  **Access the Application in Your Browser:**
    You can now navigate to the services:
    *   **App-frontend:** `http://app-frontend.k8s.local`
    *   **App-backend:** `http://app-service.k8s.local`
    *   ***Grafana:** `http://grafana.k8s.local`
    *   **Kubernetes Dashboard (Vagrant Only):** `http://dashboard.k8s.local`
  > **Note:** You have to wait for the services to be fully deployed and ready. You can check the status with `kubectl get pods -A` to see if all pods are in the "Running" state.



## Interacting with Your Kubernetes Deployment

Your Helm deployment is pre-configured with powerful features for monitoring and management.

### Customizing the Deployment
You can change default settings like hostnames, replica counts, or container versions by editing the `app-helm-chart/values.yaml` file *before* running `helm install`. If you've already installed the chart, you can apply changes with `helm upgrade my-app .` in the app-helm-chart folder.

> **Important:** If you change the hostnames of app-frontend or app-service in `values.yaml`, remember to update the corresponding entries in your local `hosts` file as explained in Step 3 of the Kubernetes Deployment instructions. Otherwise, your browser won't be able to resolve the custom hostnames to your cluster's IP address. Similarly, if you modify the service ports in `values.yaml`, you'll need to include those ports in your URLs when accessing the services (e.g., `http://app-frontend.k8s.local:8080` instead of the default `http://app-frontend.k8s.local`).

### Accessing the Kubernetes Dashboard (Vagrant Only)
The Kubernetes Dashboard is a web-based UI for managing your Kubernetes cluster. It is installed by default in the Vagrant setup after running the finalization playbook.

1.  **Access the Dashboard:**
    Make sure the DNS entry for the dashboard is in your `hosts` file as described in Step 3. Then, navigate to the following URL in your browser:
    ```text
    http://dashboard.k8s.local
    ```
2.  **Log In:**
    Generate a token for authentication with the following command:
    ```bash
    kubectl -n kubernetes-dashboard create token admin-user
    ```
    Copy the generated token and paste it into the login form on the dashboard.
### Viewing the Grafana Dashboard
Grafana is installed for monitoring application metrics.

1.  **Access the Grafana UI:**
    Make sure the DNS entry for Grafana is in your `hosts` file as described in Step 3. Then, navigate to the following URL in your browser:
    ```text
    http://grafana.k8s.local
    ```

2.  **Log In:**
    *   **Username:** `admin`
    *   **Password:** `prom-operator`

3.  **Available Dashboards:**
    The Helm chart includes two custom dashboards pre-configured in Grafana:
    *   **grafana-dashboard:** Provides overall system metrics obtained from Prometheus.
    *   **Experiment Dashboard:** Specifically designed for the canary experiment, showing key metrics for comparing stable and canary versions.

    These dashboards can be accessed from the Grafana dashboard page after login.

### Testing Istio Rate Limiting
The deployment includes a rate limit of 10 requests per minute per IP. You can test this with `curl`.
```bash
# This loop sends 20 requests to the frontend
for i in {1..20}; do
  curl -H "Host: app-frontend.k8s.local" -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1/
done
```
You will see several `200` (OK) responses, followed by `429` (Too Many Requests).


### Canary Deployment & Experimentation
The Helm chart includes a complete setup for A/B testing with canary deployments:

- A **stable** version running the current production code
- A **canary** version (10% of traffic) running experimental features
- Consistent user experiences through sticky sessions
- Dedicated metrics collection for experiment analysis

The canary deployment is part of a continuous experimentation framework measuring how displaying model confidence scores affects user behavior. Users assigned to the canary version will see confidence scores alongside sentiment predictions, while stable users see the traditional interface.

#### Testing Specific Versions

You can manually test specific versions of each service:

1. **Testing app-frontend Versions:**
   - To access the stable frontend: Set cookie `app-version=stable` in your browser for the specific app-frontend domain 
   - To access the canary frontend: Set cookie `app-version=canary` in your browser for the specific app-frontend domain
   - For simplicity, you can access the frontend to automatically let it set a cookie in your browser. Afterwards you can set this cookie to the desired version.

2. **Testing app-service API Versions Directly:**
   - To access the stable API: Add header `X-App-Version: stable` to your API requests
   - To access the canary API: Add header `X-App-Version: canary` to your API requests

For full details about the experimental setup, metrics, and decision criteria, see the [Continuous Experimentation documentation](docs/continious_experimentation.md).


### Cleanup

Follow the steps corresponding to the method you used to run the application.

*   **Docker Compose:**
    ```bash
    docker compose down
    ```
*   **Kubernetes (Minikube/Vagrant):**
    ```bash
    # Uninstall the Helm release from your cluster
    helm uninstall my-app

    # Stop the Kubernetes cluster itself
    # If you used Minikube
    minikube stop

    # If you used vagrant
    # Navigate to the '/vagrant' folder
    vagrant destroy -f
    ```