# Deployment Structure and Data Flow

This document provides a conceptual overview of our deployment architecture and data flow, focusing on the Kubernetes and Istio-based setup. It is intended to help new contributors quickly understand the system’s structure, the roles of its components, and how requests flow through the cluster. For implementation details, see the [operation repository](https://github.com/remla2025-team9/operation).

---

## 1. **High-Level Architecture**

Our deployment consists of three main application components, monitoring infrastructure, and supporting Kubernetes/Istio resources:

### Core application components
- **App Frontend**: User-facing web application.
- **App Service**: Backend API, mediates between frontend and model.
- **Model Service**: Serves ML model predictions.

### Monitoring stack
- **Prometheus**: Collects metrics from core application and define alerts.
- **Grafana**: Visualizes metrics and provides dashboards for our custom metrics.
- **AlertManager**: Sends email alerts based on Prometheus rules.

### Service Mesh

- **Istio Gateway**: Entry point for external HTTP traffic.
- **VirtualServices** & **DestinationRules**: Intelligent traffic routing.
- **EnvoyFilters**: Enforce rate limiting policies.

### Storage and Configuration
- **ConfigMaps**: Grafana dashboards.
- **PersistentVolumes/Claims**: Model cache storage.
- **Secrets**: Store sensitive information like AlertManager SMTP credentials.

---

## 2. **Deployment Structure Visualization**

![Deployment Structure](images/deployment.png)

The diagram above shows:
* The Kubernetes Deployments and their relationships
* Communication paths between components
* How Istio resources such as VirtualServices and DestinationRules route traffic. While DestinationRules are not explicitly shown, they are implied in the routing logic of VirtualServices. In our deployment, they define subsets for each service version (v1, v2) to enable traffic splitting and version management, as well as sticky sessions (ensuring users consistently hit the same service version).

---

## 3. **Kubernetes Resources Overview**

- **Deployments**: Each service (frontend, backend, model) is deployed as a Kubernetes Deployment, supporting multiple versions for experiments.
    - To enable canary deployments, we deploy one Deployment resource for each version and use labels to differentiate versions (e.g., `app=app-frontend, version=stable` and `app=app-frontend, version=canary`).
- **Services**: Expose each Deployment internally in the cluster.
- **PersistentVolumes/Claims**: Provide storage for model cache, ensuring model artifacts persist across pod restarts.
- **Secrets & ConfigMaps**: Store sensitive and non-sensitive configuration, injected into pods as environment variables or files.
- **Monitoring**: Prometheus and Grafana are deployed via Helm charts, with dashboards configured for metrics collection and visualization.
    - **ServiceMonitors**: Automatically discover and scrape metrics from application services.
    - **PrometheusRules**: Define alerting rules for Prometheus (load increase)
    - **AlertManager**: Configured to send email alerts based on Prometheus rules.
---

## 4. **Istio Service Mesh Components**

- **Gateway**: Entry point for all external traffic into the cluster.
- **VirtualServices**: Define routing rules for HTTP traffic. 
    - Routes requests to specific service versions (by default, 90% to v1, 10% to v2, although configurable in the helm chart).
    - Uses cookie-based routing to ensure user sessions are sticky to a specific version.
- **DestinationRules**: Define subsets for each service, enabling version-based routing and sticky sessions.
- **EnvoyFilters**: Used for rate limiting.

---

## 5. **Request Flow and Dynamic Routing**

### **External Request Flow**

1. **User Request**: A user accesses the frontend via a DNS name (`app-frontend.k8s.local`).
2. **Gateway**: The request enters the cluster through the Istio Gateway.
3. **VirtualService Routing**: Istio routes the request to the appropriate frontend pod, splitting traffic between versions (90% to stable, 10% to canary). To ensure sticky sessions, the a cookie will be set at this stage which allows the user to consistently hit the same version of the frontend.
4. **Frontend to Backend**: The frontend calls the backend API (`app-service`) via its internal service name. Using VirtualServices, we ensure that the same version of the backend is used consistently for the frontend version.
5. **Backend to Model**: The backend calls the model service for predictions. The model service can also have multiple versions, and the backend uses VirtualServices to route requests to the appropriate model version.
6. **Response Propagation**: The response flows back through the same path to the user.

### **Dynamic Traffic Routing**

- **Canary Releases**: VirtualServices and DestinationRules allow us to direct a percentage of traffic to different versions of a service (90% to stable, 10% to canary), enabling safe experimentation and gradual rollouts.
- **Cookie-Based Routing**: Some routes use HTTP cookies for consistent hashing, ensuring user sessions are sticky to a particular version.
- **Rate Limiting**: EnvoyFilters can enforce rate limits at the gateway level.

---

## 6. **Experimental Design**

- **Multiple Versions**: Each service can have multiple versions (v1, v2) deployed simultaneously.
- **Traffic Splitting**: Istio VirtualServices control what percentage of traffic goes to each version, supporting controlled experiments.
- **Observability**: Metrics and dashboards allow us to monitor the impact of experiments in real time.
- **Persistence**: Model cache is shared via PersistentVolumes, ensuring consistent model state across deployments.

---
## 7. **Further Reading**

For more details, see the [operation repository](https://github.com/remla2025-team9/operation) and its [README](https://github.com/remla2025-team9/operation#readme).

---