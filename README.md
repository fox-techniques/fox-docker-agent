# FOX-docker-agent

# Azure DevOps Agent Stack (Docker + systemd, Ubuntu 22.04)

Self-hosted Azure DevOps agent that:
- Runs as a Docker container on Ubuntu 22.04
- Executes pipeline jobs **in containers** (`container:` in YAML)
- Optionally keeps a “warm” container for faster stage starts
- Ships logs via **Fluent Bit** (configurable outputs)
- Auto-maintains the host with **systemd timers** (Docker prune, log rotation)

## Structure
- `agent/` — Agent image & entrypoint script
- `systemd/` — Units for the agent, warm container (optional), prune timer, Fluent Bit
- `fluent-bit/` — Fluent Bit config (tail Docker & agent logs)
- `pipelines/` — Sample Azure Pipelines YAMLs using job containers

## Quick flow
1. Build the agent image.
2. Enable `azdo-agent.service` (uses `/var/run/docker.sock` to launch job containers).
3. (Optional) Enable `fluent-bit.service` for log forwarding.
4. (Optional) Enable weekly `docker-prune.timer`.
5. Point your pipeline to this pool and declare `container:` per job.



## Azure DevOps Self-hosted Docker Build Agent + Python Template with `uv`



[![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg)](https://github.com/fox-techniques/fox-docker-agent/blob/main/LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-fox--docker--agent-181717?logo=github)](https://github.com/fox-techniques/fox-docker-agent)

This repository provides a ready-to-use setup for a self-hosted Azure DevOps agent in Docker, optimized for Python projects using uv for dependency management and builds. The agent supports multiple Python versions using pyenv, and can be easily deployed with Docker Compose.


## 🚀 Key Features

- Self-hosted Azure DevOps build agent using Docker
- Pre-installed Python versions (3.10, 3.11, 3.12)
- Fast dependency resolution and build with `uv`
- Matrix build strategy to test across multiple Python versions
- Minimal and production-ready Azure Pipelines configuration


## 📁 Repository Structure

```bash
.
├── agent/                  # Self-hosted agent Docker setup
│   ├── docker-compose.yml  # Brings up the agent
│   ├── Dockerfile          # Builds the agent image
│   ├── start.sh            # Starts and registers the agent
│   └── secrets/PAT         # Personal Access Token (not checked in)
├── azure-pipelines.yml     # Azure Pipeline using uv to test/build Python project
├── pyproject.toml          # Python project metadata (setuptools/uv compatible)
├── src/                    # Project source code (follows `src/` layout)
│   └── fox_pypi/
├── tests/                  # Pytest-based test suite
└── uv.lock                 # uv-generated dependency lock file
```

## 🚀 Getting Started

1. Clone the repository

```bash
git clone https://github.com/fox-techniques/fox-docker-agent.git
cd fox-docker-agent
```

2. Set up the Agent

Edit `.env` file (create it if missing):

```bash
AZP_URL=https://dev.azure.com/YOUR_ORG
AZP_TOKEN=your_pat_token
AZP_POOL=your_azure_devops_pool
```

Then run the agent:

```bash
cd agent
docker compose up -d
```

💡 Ensure your PAT has agent pool and read/write access.


## 🧪 Azure Pipeline: Test & Build

This pipeline (azure-pipelines.yml) runs for each commit on main. It:

- Spins up a matrix of Python versions: 3.10, 3.11, 3.12
- Creates a virtual environment using uv
- Installs the project in editable mode with dev dependencies
- Runs pytest
- Builds the package
