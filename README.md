# Operation

This repository helps connect and run the services developed by REMLA 2025 Team 9. It uses Docker Compose to start everything locally for testing or demonstration purposes.

## How to Start

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

### Environment Variables

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
export WORKER_MEMORY_ENV=2048
export CONTROLLER_CPU_COUNT_ENV=1
export CONTROLLER_MEMORY_ENV=1024
vagrant up
```

### Base Configuration

- All VMs use the `bento/ubuntu-24.04` box.
- VMs are assigned static IPs in the `192.168.56.*` range:
  - Controller node (`ctrl`): `192.168.56.100`
  - Worker nodes: `192.168.56.101`, `192.168.56.102`, ...

### Ansible Provisioning

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