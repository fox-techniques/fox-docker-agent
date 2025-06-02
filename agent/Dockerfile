# Base image with Python
FROM python:3.10-slim

ARG AGENT_VERSION=4.255.0
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install required system dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip sudo docker.io procps \
    libicu-dev libssl-dev libkrb5-3 zlib1g \
    ca-certificates && \
    apt-get clean

# 2. Create user and allow Docker access
RUN useradd -m -s /bin/bash azdo && usermod -aG docker azdo

# 3. Install `uv` globally for azdo user
USER azdo
RUN curl -Ls https://astral.sh/uv/install.sh | bash

# 4. Add uv to PATH
ENV PATH="/home/azdo/.local/bin:$PATH"

# 5. Switch back to root and prepare agent directory
USER root
WORKDIR /azdo

# 6. Download and extract Azure DevOps agent
RUN curl -Ls "https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz" \
    -o agent.tar.gz && \
    tar -xzf agent.tar.gz && \
    chmod +x ./config.sh ./run.sh ./bin/Agent.Listener && \
    rm agent.tar.gz

# 7. Copy start script into container
COPY start.sh /azdo/start.sh
RUN chmod +x /azdo/start.sh && chown azdo:azdo /azdo/start.sh

# 8. Add Docker healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s CMD pgrep Agent.Listener || exit 1

# 9. Use persistent volume for agent state and logs
VOLUME ["/azdo/_work", "/azdo/_diag", "/azdo/logs"]

# 10. Finalize container run as azdo user
USER azdo
WORKDIR /azdo

ENTRYPOINT ["/azdo/start.sh"]
