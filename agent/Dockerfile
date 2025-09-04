FROM debian:bullseye-slim

ARG AGENT_VERSION=4.255.0
ENV DEBIAN_FRONTEND=noninteractive

# 1) Minimal deps for the ADO agent + docker client
RUN apt-get update && apt-get install -y \
    curl git unzip sudo docker.io procps ca-certificates \
    libicu-dev libssl-dev libkrb5-3 zlib1g \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2) Non-root user (we’ll still run container with docker.sock mounted)
RUN useradd -m -s /bin/bash azdo && usermod -aG docker azdo

# 3) Agent files
WORKDIR /azdo
RUN curl -Ls "https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz" \
    -o agent.tar.gz \
 && tar -xzf agent.tar.gz \
 && chmod +x ./config.sh ./run.sh ./bin/Agent.Listener \
 && rm agent.tar.gz

# 4) Entry script
COPY start.sh /azdo/start.sh
RUN chmod +x /azdo/start.sh && chown azdo:azdo /azdo/start.sh

# 5) Healthcheck & persistent state
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s \
  CMD pgrep Agent.Listener >/dev/null || exit 1
VOLUME ["/azdo/_work", "/azdo/_diag", "/azdo/logs"]

# 6) Run as non-root
USER azdo
ENTRYPOINT ["/azdo/start.sh"]
