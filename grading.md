# Grading Self-Assessment

This document provides a self-assessment of our work for the Release Engineering course. Its purpose is to guide the grading process by clarifying our expected level of achievement for each rubric block, detailing where to find the implementation of specific requirements, and providing additional context for any solutions that might not be immediately obvious.

We have structured this document by assignment, with a subsection for each rubric block as defined in the course materials.

---

## Assignment 1

### Data Availability 

*   **Expected Level:** `Pass`
*   **Implementation:**
    - The GitHub organization follows the requested template
    - All relevant information is accessible
    - The `operation` folder contains a `README.md` file with the information to find and start the application
    - The `operation` folder contains the `grading.md` file
*   **Notes for the Grader:**

### Sensible Use Case 

*   **Expected Level:** `Pass`
*   **Implementation:**
    - The frontend allows querying the model
    - Additional interactions exist that allow users to provide feedback by correcting incorrect predictions
*   **Notes for the Grader:**

### Automated Release Process

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Excellent)** After every push to main (and thus also after merging branches to main), the pre-version tag is automatically bumped using a counter (e.g. from `v0.0.1-pre-2` to `v0.0.1-pre-3`). This gives support for multiple versions of the same pre-release.
    - **(Excellent)**   We have implemented a deployment workflow that is triggered manually with the click of a button in the GitHub Actions tab for all repositories. The bump level (patch, minor, major) can be set for this workflow when triggering manually. If the previous version was a pre-release, the pre-tag is removed for the stable release (e.g. for a patch bump, `v0.0.1-pre-2` will become `v0.0.1`, and for a minor bump, `v0.0.1-pre-2` will become `v0.1.0`).
    - **(Excellent)**   `app-frontend`, `app-service`, and `model-service` have a multi-stage Dockerfile.
    - **(Excellent)**   The images that are automatically released by `app-frontend`, `app-service`, and `model-service` supporting the `amd64` and `arm64` architectures.
*   **Notes for the Grader:**

### Software Reuse in Libraries

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** Both libraries provide a `setup.py` for packaging and installation. Installation is done via `pip` directly from the GitHub repositories, this installation method ensures that both libraries are included via regular package managers rather than being referenced locally.
    - **(Good)** The `lib-ml` repository contains core machine learning preprocessing logic, especially in the `preprocessing.py` module.  
    - **(Good)** The `model-service` repository imports the `preprocess` function directly from the `sentiment_analysis_preprocessing` package, which is the same preprocessing logic used during training. 
    - **(Good)** Retrieves version from Git metadata via `setuptools_scm`.
    - **(Excellent)** Model-service downloads model from external storage on startup:
        ```bash
        # In app/model_loader.py
        model_version = os.getenv("MODEL_VERSION")
        ```
    - **(Excellent)** Model is cached in a directory:
        ```bash
        # In app/model_loader.py
        model_path = f".cache/sentiment_pipeline-{model_version}.joblib"
        ```
*   **Notes for the Grader:**

### Exposing a Model via REST

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** Service is implemented using Flask and received REST requests.
    - **(Good)** The host and port of the Flask app are confiurable through an ENV variable.
    - **(Good)** Endpoints have OpenAPI specification.
    - **(Excellent)** The port is configurable.
*   **Notes for the Grader:**

### Docker Compose Operation

* **Expected Level:** `Excellent`
* **Implementation:**  
  - **(Sufficient)** repository contains a docker-compose.yml that brings up app-service, model-service and app-frontend and makes app-service accessible from the host.  
  - **(Good)** defines a named volume model-cache for persistent caching.  
  - **(Good)** maps ports 5000:5000 for app-service and 3000:3000 for app-frontend.  
  - **(Good)** references the same container images as used in the Kubernetes deployment.  
  - **(Excellent)** each service has a `restart: on-failure` policy.  
  - **(Excellent)** Docker secret `example-secret` is defined under `secrets` and mounted into model-service.  
  - **(Excellent)** each service loads its own `env_file` for configuration.  
* **Notes for the Grader:**  

---

## Assignment 2

### Setting up (Virtual) Infrastructure

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)**  All VMs exist with correct hostnames, attached to a private network for inter-VM communication
    - **(Sufficient)**  VMs are directly reachable from host through a host-only network (192.168.56.* range)
    - **(Sufficient)**  VMs are provisioned with Ansible, completing within 5 minutes
    - **(Good)**        Vagrantfile uses loops and template arithmetic for defining node names and IPs
    - **(Good)**        Worker VM specifications are controlled via environment variables (WORKER_COUNT_ENV, WORKER_CPU_COUNT_ENV, WORKER_MEMORY_ENV)
    - **(Excellent)**   Extra arguments are passed to Ansible from Vagrant, including number of workers
    - **(Excellent)**   Vagrant generates a valid inventory.cfg for Ansible containing all active nodes
*   **Notes for the Grader:**
    - The Vagrantfile is in the `/vagrant` directory
    - Environment variables can be found in the README.md documentation
    - Ansible playbooks are in the `/vagrant/ansible` directory
    - Host configuration is generated via the `hosts.j2` template

### Setting up Software Environment

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** The task Install required packages uses the `ansible.builtin.apt` module to install packages such as containerd, kubeadm, kubelet, and kubectl.
    - **(Sufficient)** The task `Start and enable Kubelet service` uses the `ansible.builtin.systemd_service` module to start the kubelet service and enable it for auto-start on boot.
    - **(Sufficient)** The task `Render the /etc/hosts file` uses the `ansible.builtin.template` module to generate and copy the /etc/hosts file from the hosts.j2 template onto the target VM.
    - **(Sufficient)** Multiple tasks under Configure containerd use the `ansible.builtin.lineinfile` module to perform idempotent, regexp-based edits on /etc/containerd/config.toml.
    - **(Good)** Multiple tasks under Configure containerd use the `ansible.builtin.lineinfile` module to perform idempotent, regexp-based edits on /etc/containerd/config.toml.
    - **(Good)** The task `Check if containerd config` exists uses `ansible.builtin.stat` and `registers` the result as config_file, which is then used in subsequent conditional tasks to control execution flow.
    - **(Good)** The task `Add Vagrant's SSH public keys` uses a loop with lookup('fileglob', ssh_key_pattern, wantlist=True) to iterate over multiple public key files and add each key.
    - **(Good)** The playbook uses checks such as the presence of `/etc/containerd/config.toml` before writing default configuration and uses idempotent modules ensuring repeated runs do not reset cluster state.
    - **(Excellent)** The task `Render the /etc/hosts file` uses the `ansible.builtin.template` module to generate and copy the /etc/hosts file from the hosts.j2 template onto the target VM.
    - **(Excellent)** The task `Wait for MetalLB controller to be ready` uses the `ansible.builtin.command` module to run kubectl wait with a label selector and timeout, ensuring the playbook waits until the MetalLB controller pod is ready before continuing, preventing errors due to premature execution.
    - **(Excellent)** Tasks such as `Remove SWAP from fstab` and those within Configure containerd use the `lineinfile` module with regexp to perform idempotent, regex-based edits on configuration files.
*   **Notes for the Grader:**

### Setting up Kubernetes

* **Expected Level:** `Excellent`  
* **Implementation:**  
  - **(Sufficient)** control-plane is initialized via `kubeadm init` using Ansible when `/etc/kubernetes/admin.conf` does not exist.  
  - **(Sufficient)** worker nodes join the cluster automatically via a delegated `kubeadm token create --print-join-command` and subsequent `kubeadm join`.  
  - **(Sufficient)** the control-plane’s kubeconfig is copied to `/home/vagrant/.kube/config` for the vagrant user.  
  - **(Sufficient)** the kubeconfig is also fetched to the host system using an Ansible fetch task.  
  - **(Good)** tasks use idempotent checks (`stat`, `when`, and `changed_when`) to avoid re-running setup tasks unnecessarily.  
  - **(Good)** Flannel CNI plugin is installed by applying the `kube-flannel.yml` manifest.  
  - **(Good)** join command is dynamically generated on the controller and executed on all worker nodes via delegation.  
  - **(Excellent)** Ansible playbook installs and configures Helm (via apt_key, apt_repository, apt) and installs the Helm Diff plugin.  
  - **(Excellent)** the Kubernetes Dashboard is deployed and exposed via Ingress, making it accessible from the host without tunneling.  
  - **(Excellent)** MetalLB is configured with a fixed IP range, and the Istio ingress gateway receives an external IP from this pool.  
  - **(Excellent)** An HTTPS Ingress route is configured using cert-manager and self-signed certificates for secure dashboard access.  
* **Notes for the Grader:**  


---

## Assignment 3


### Kubernetes Usage

* **Expected Level:** `Excellent`
* **Implementation:**  
  - **(Sufficient)** application is deployed to a Kubernetes cluster using Helm templates for each component.  
  - **(Sufficient)** Deployment and Service objects exist for app-service, app-frontend and model-service.  
  - **(Sufficient)** application is accessible through a VirtualService and Istio Gateway.  
  - **(Good)** environment variables in deployments point to the model-service hostname, making it reconfigurable via K8s config.  
  - **(Good)** a Secret is defined and referenced inside the pod templates.  
  - **(Excellent)** a hostPath volume is declared and mounted into the model-service pod, mapped from `/mnt/shared/model-cache`.  
  - **(Excellent)** Shared folder mounted at `/mnt/shared`
* **Notes for the Grader:**  

### Helm Installation

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** A helm chart exists that covers the complete deployment  
    - **(Good)** The helm chart is configurable via a values.yaml file and the dns name of the model-service can be modified in it.  
    - **(Excellent)** All names and labels are prefixed with the release name using {{ Release.Name }} to enable mutiple installments of the same Helm chart in the same cluster.  
*   **Notes for the Grader:**

### App Monitoring

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** The app has a total of 9 app-specific metrics for reasoning about users behavior or model performance.
    - **(Sufficient)** The metrics include at least a `Gauge` and a `Counter`.
    - **(Sufficient)** The metrics are automatically discovered by Prometheus through applying `ServiceMonitor` resource.
    - **(Good)** An app-specific `Histogram` metric is defined to track the distribution of response times for the model service.
    - **(Good)** Each metric type has at least one metric defined in the code and broken down with labels.
    - **(Excellent)** An `AlertManager` is configured with a `PrometheusRule` that triggers an alert if the number of reviews submitted exceeds 5 over a 5-minute window.
    - **(Excellent)** A corresponding `Alert` is raised and sent by mail to the configured email address when the alert condition is met.
    - **(Excellent)** The deployment files do not contain any hardcoded credentials or sensitive information, but instead uses Kubernetes Secrets to manage sensitive data securely, and the `README.md` file provides instructions on how to set up the necessary secrets on runtime.
*   **Notes for the Grader:**
    - The metrics are defined in the `app-service` repository, specifically in the `src/metrics.py` file.
    - The Prometheus configuration for the alerts can be found in the `operation` repository, specifically in the `app-helm-chart/templates/monitoring.yaml` file.

### Grafana

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** The `my-dashboard` in `grafana-dashboards` folder exists and illustrate all custom metrics.
    - **(Sufficient)** The `my-dashboard` is a JSON file and can be imported manually.
    - **(Sufficient)** The README.md in operation repository contains relevant content to explain manual installation.
    - **(Good)** The dashboard contains a Gauge panel to display the average number of reviews currently awaiting confirmation over the selected time interval. The Counter panel focuses on number of submitted reviews in recent periods.
    - **(Good)** The dashboard uses time range variables like `$__interval` to make queries dynamically adjust based on the selected timeframe.
    - **(Good)** Functions such as `avg_over_time` or `rate` are applied to smooth data, show trends, and provide meaningful insights.
    - **(Excellent)** In  `grafana-dashboard-configmap.yaml` file, the configmap is defined to ensure that the dashboard is provisioned automatically during Helm installation, with no manual steps required to add it in the Grafana UI.
*   **Notes for the Grader:**

---

## Assignment 4

### Automated Tests

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** Tests follows `ML Tests Score` methodology, tests cover four aspects: Feature and Data; Model Development; ML infrastructure;
    Monitoring tests.
    - **(Sufficient)** For Feature and Data: the `test_data.py` consists of tests primarily verify the validity and quality of features and data, including checks on feature structure (e.g., sparsity, non-negativity, absence of NaNs/Infs), label correctness (e.g., binary, balanced), and data processing integrity and efficiency (e.g., matching dimensions, duplicates, preprocessing speed). For Model Development: the `test_development.py` consists of tests ensure that the trained model performs better than a simple baseline (majority class) classifier. For ML infrastructure: the `test_infrastructure.py` has test to run the DVC pipeline and verify it produces a valid model and metrics. For Monitoring: the `test_monitoring.py` has tests monitor the runtime duration and memory usage.
    - **(Sufficient)** The name of the file indicates the category of tests and there are comment for tests.
    - **(Good)** The `test_non-determinism.py` have test checks the stability of model accuracy across different random seeds, ensuring that performance does not vary much. The `test_data_slices.py` consists of tests evaluate the trained model’s accuracy on the entire test set as well as separately on positive and negative reviews, ensuring it performs reasonably across all cases.
    - **(Good)** The `test_feature_cost.py` have tests to evaluate the prediction efficiency of the model by measuring its latency and peak memory usage during inference on the test set, ensuring both stay within acceptable limits.
    - **(Excellent)** Using pytest together with the pytest-cov plugin, test adequacy is measured and reported on the terminal when running the tests.
    - **(Excellent)** The coverage is automatically meausred using `pytest --cov=src tests/`.
    - **(Excellent)** The `test_mutamorphic.py` have tests to check whether the model maintains consistent predictions when sentiment-related words are replaced with synonyms, and attempts to "repair" misclassifications caused by such changes.
*   **Notes for the Grader:**

### Continuous Training

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** The execution of tests and linter are included in the `testing.yaml` workflow.
    - **(Sufficient)** `pytest` runs all tests on every push to the main branch in the `testing.yaml` workflow.
    - **(Sufficient)** `pylint` runs on every push to the main branch in the `testing.yaml` workflow.
    - **(Good)** The test adequacy metrics are calculated during the `testing.yaml` workflow execution.
    - **(Good)** Test coverage is measured during the `testing.yaml` workflow execution.
    - **(Excellent)** The test adequacy metrics are reported back and automatically added in the `README.md` file on every run of the `testing.yaml` workflow.
    - **(Excellent)** The test coverage is reported back and automatically added in the `README.md` file on every run of the `testing.yaml` workflow.
    - **(Excellent)** The `pylint` linting score is added to the `README.md` file as a badge on every run of the `testing.yaml` workflow.
*   **Notes for the Grader:**
    - The `testing.yaml` workflow is located in the `.github/workflows` directory of the `model-training` repository.
    - The test adequacy metrics and coverage are automatically added to the `README.md` file in the `model-training` repository.

### Project Organization

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** The project is a Python project
    - **(Sufficient)** The pipeline stages are split into data loading, data preparing, training and evaluating. Each stage calls a seperate script.
    - **(Sufficient)** All dependencies are formulated in a requirements.txt file
    - **(Sufficient)** The project layout is inspired by the Cookiecutter template. Some additional folders are added for testing, linting, and plugins. These are structured in a folder as well to avoid clutter.
    - **(Good)** The dataset is stored and downloaded from google drive
    - **(Good)** Exploratory code can be placed in a seperate notebooks folder
    - **(Good)** The python project is reduced to the required source code.
    - **(Excellent)** The model is packaged automatically. It is deployed as a versioned GitHub release through a workflow.

*   **Notes for the Grader:**

### Pipeline Management with DVC

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** Pipeline works, and is reproducible. AWS S3 used as remote storage with documentation on how to set it up.
    - **(Good)** Metrics are defined which contain accuracy, cloud-based remote with S3 and rollback capabilities.
    - **(Excellent)** Metrics go beyond accuracy and can be displayed with `dvc exp show`.
*   **Notes for the Grader:**

### Code Quality

* **Expected Level:** `Excellent`
* **Implementation:**
    - **(Sufficient)** The project includes a valid `.pylintrc` with non-default configuration and naming conventions tailored to the codebase.
    - **(Sufficient)** Running `pylint` on the codebase results in a perfect score of 10.00/10, with no warnings or errors.
    - **(Good)** The project uses multiple linters (`flake8`, `bandit`, `pylint`) configured via dedicated files (`.flake8`, `bandit.yaml`, `.pylintrc`), with tailored rule sets.
    - **(Excellent)** A custom `pylint` rule is implemented in `plugin/ml_code_smells_checker.py`. It defines a `RandomSeedChecker` that detects hardcoded random seeds, which are ML-specific code smells.
*   **Notes for the Grader:**

---

## Assignment 5

### Traffic Management

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** A Gateway and VirtualServices are defined.  
    - **(Sufficient)** The application is accessible through an Ingress Gateway. Locally by adding the hosts and the ingress ip to the etc/hosts file.
    - **(Good)** DestinationRules are used and weights can be configured in the values.yaml file to enable traffic splitting between different versions of the app  
    - **(Good)** The versions of model-service and the app are consistent by checking the app-service version of the request when traffic arrives at the model service.
    - **(Excellent)** Sticky sessions are achieved by setting a cookie in the front-end upon the first request. This cookie is checked in the app-frontend VirtualService to respond with the same version as in the cookie. The cookie is also used to access the correct version of the app-service by setting a header parameter with the correct version when sending a request to the app-service from the frontend, achieving consistency. The app-service VirtualService checks this specific header parameter and responds with the version that is in this header parameter. 
*   **Notes for the Grader:**

### Additional Use Case

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Excellent)** In `rate-limiting.yaml`, Rate limiting is configured using Istio's EnvoyFilter and a custom ConfigMap. The ratelimit-config defines a global rule that limits incoming requests to 10 per minute based on the request path. EnvoyFilters inject the Envoy Rate Limit HTTP filter into the ingress gateway and match it to the defined rules. The configuration ensures that traffic through the Istio ingress is dynamically rate-limited via a gRPC rate limit service.

*   **Notes for the Grader:**

### Continuous Experimentation

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)**  The documentation describes the experiment in detail, including the effect experimented on, implemented changes and the relevant metric.
    - **(Sufficient)** The experiment involves two version of the app-frontend, app-service, and model-service. All 6 versions have their own images (tagged with :latest for stable, and :canary for canary)
    - **(Sufficient)** Both component versions are reachable. The README also describes a way to consistently get one version for testing
    - **(Sufficient)** The metric is implemented in the app-service and described in the docs
    - **(Good)** Prometheus picks up this metric
    - **(Good)** We created a Grafana dashboard named "Experiment Dashboard". The configuration is located in app-helm-chart/grafana-dashboards/experiment-dashboard.json
    - **(Good)** The documentation contains a screenshot of this dashboard
    - **(Excellent)** The documentation clearly describes the decision process. 
*   **Notes for the Grader:**
    - Both the README and the docs describe the experiment and how to interact with it very well.

### Deployment Documentation

*   **Expected Level:** `Excellent`
*   **Implementation:**
    - **(Sufficient)** Documentation explain the deployment structure, flow of traffic and a visualization.
    - **(Good)** Documentation includes all the deployed resources, their purpose and relationships.
    - **(Excellent)** This is a subjective rubric, but we consider that upon reading this documentation, the reader will have a good understanding of the deployment and how to contribute to it.

### Extension Proposal

* **Expected Level:** `Excellent`
* **Implementation:**
    - **(Sufficient)** The documentation describes a clear release engineering shortcoming: the complex, manual setup process for running the app on Minikube.
    - **(Sufficient)** The proposed extension automates this setup using a `Makefile`, addressing onboarding delays, reproducibility issues, and system misconfiguration risks.
    - **(Sufficient)** The extension is new and not covered in any rubric block. Sources like GNU Make, Minikube, and Ansible best practices are cited.
    - **(Good)** The shortcomings are critically reflected on, describing the time cost, setup inconsistency, and permission issues of the current approach. A structured user experiment is proposed to measure improvement using metrics like time-to-setup and user satisfaction.
    - **(Excellent)** The extension is general and applicable to any Kubernetes-based project using Minikube or similar tools. It clearly resolves the stated shortcoming and replaces manual steps with safe, reproducible automation.
*   **Notes for the Grader:**
