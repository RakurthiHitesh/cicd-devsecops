# CI/CD Pipeline with DevSecOps 🔐

A production-grade DevSecOps pipeline built with **Azure DevOps** and **GitHub Actions**, deploying a containerised Flask API to **Azure Kubernetes Service (AKS)**. Security is embedded at every stage — not bolted on at the end.

---

## 🏗️ Architecture

```
┌─────────────┐    ┌──────────────────────────────────────────────────────────────┐
│   Developer │    │                     CI/CD Pipeline                           │
│   Push/PR   │───▶│                                                              │
└─────────────┘    │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
                   │  │  Build   │  │  SAST    │  │ Container│  │   Deploy   │  │
                   │  │& Test    │─▶│SonarQube │─▶│  Scan    │─▶│   AKS      │  │
                   │  │          │  │          │  │  Trivy   │  │            │  │
                   │  └──────────┘  └──────────┘  └──────────┘  └────────────┘  │
                   └──────────────────────────────────────────────────────────────┘
                                                          │
                                         ┌────────────────▼────────────────┐
                                         │        Azure Kubernetes          │
                                         │           Service (AKS)          │
                                         │                                  │
                                         │  ┌──────────┐  ┌──────────┐     │
                                         │  │  Pod 1   │  │  Pod 2   │ ... │
                                         │  │  Flask   │  │  Flask   │     │
                                         │  └──────────┘  └──────────┘     │
                                         │         HPA (2–10 replicas)      │
                                         └──────────────────────────────────┘
```

---

## 🔐 DevSecOps Stages

| Stage | Tool | Purpose |
|---|---|---|
| Unit Tests | pytest + pytest-cov | Code correctness & coverage |
| SAST | SonarQube | Static code analysis, code smells, bugs |
| Container Build | Docker (multi-stage) | Minimal, non-root image |
| Vulnerability Scan | Trivy | HIGH/CRITICAL CVE detection — blocks pipeline |
| Registry Push | Azure Container Registry | Versioned image storage |
| Deploy | AKS + kubectl | Rolling deployment with health probes |
| Autoscaling | HPA | Scale 2–10 pods on CPU/memory |

---

## 📁 Project Structure

```
cicd-devsecops/
├── app/
│   ├── app.py                  # Flask API
│   ├── test_app.py             # Unit tests
│   └── requirements.txt
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml         # Non-root, resource limits, health probes
│   ├── service.yaml            # LoadBalancer service
│   └── hpa.yaml                # Horizontal Pod Autoscaler
├── sonarqube/
│   └── sonar-project.properties
├── scripts/
│   └── trivy-scan.sh           # Standalone Trivy scan script
├── .github/
│   └── workflows/
│       └── pipeline.yml        # GitHub Actions pipeline
├── azure-pipelines.yml         # Azure DevOps pipeline
├── Dockerfile                  # Multi-stage, non-root build
└── .gitignore
```

---

## 🚀 Getting Started

### Prerequisites

- Azure subscription
- Azure CLI installed
- Docker installed
- kubectl installed
- An AKS cluster
- An Azure Container Registry (ACR)
- SonarQube instance (self-hosted or SonarCloud)

### 1. Clone the repo

```bash
git clone https://github.com/RakurthiHitesh/cicd-devsecops.git
cd cicd-devsecops
```

### 2. Run the app locally

```bash
pip install -r app/requirements.txt
python app/app.py
# Visit http://localhost:5000
```

### 3. Run tests locally

```bash
pytest app/test_app.py -v --cov=app
```

### 4. Build & scan Docker image locally

```bash
docker build -t flask-devsecops-app:local .
bash scripts/trivy-scan.sh flask-devsecops-app:local
```

### 5. Configure pipeline secrets

**Azure DevOps** — add these service connections:
- `ACR-ServiceConnection` — Azure Container Registry
- `AKS-ServiceConnection` — Kubernetes Service Connection
- `SonarQube-ServiceConnection` — SonarQube server

**GitHub Actions** — add these repository secrets:
```
ACR_LOGIN_SERVER
ACR_USERNAME
ACR_PASSWORD
AZURE_CREDENTIALS
SONAR_TOKEN
SONAR_HOST_URL
```

### 6. Update variables

In `azure-pipelines.yml`, update:
```yaml
ACR_NAME: 'yourACRname'
AKS_RESOURCE_GROUP: 'rg-devsecops'
AKS_CLUSTER_NAME: 'aks-devsecops'
```

---

## 🔒 Security Highlights

- **Multi-stage Docker build** — minimal final image, no build tools in production
- **Non-root container** — runs as UID 1000, no privilege escalation
- **Read-only root filesystem** — prevents runtime tampering
- **Trivy scan gates** — pipeline fails on HIGH/CRITICAL CVEs
- **SonarQube** — blocks merge on quality gate failure
- **Kubernetes security context** — all capabilities dropped

---

## 📊 API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/` | GET | Returns app info (version, environment) |
| `/health` | GET | Liveness probe — returns `{"status": "healthy"}` |
| `/ready` | GET | Readiness probe — returns `{"status": "ready"}` |

---

## 👤 Author

**R. Hitesh Naga Pavan**  
Azure DevOps Engineer  
[LinkedIn](https://linkedin.com/in/hitesh-naga-pavan) • [GitHub](https://github.com/RakurthiHitesh)
