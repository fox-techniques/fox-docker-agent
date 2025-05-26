FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG AGENT_VERSION=4.255.0

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip sudo build-essential \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    ca-certificates docker.io

RUN add-apt-repository ppa:git-core/ppa -y && \
    apt-get update && \
    apt-get install -y git

# 2. Create agent user early so we can assign permissions later
RUN useradd -m -s /bin/bash azdo && usermod -aG docker azdo

# 3. Install pyenv for managing Python versions
ENV PYENV_ROOT=/opt/pyenv
ENV PATH="$PYENV_ROOT/bin:$PATH"

RUN git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT && \
    $PYENV_ROOT/plugins/python-build/install.sh && \
    chown -R azdo:azdo $PYENV_ROOT

# 4. Preinstall a Python version (optional for faster builds)
RUN bash -c 'export PYENV_ROOT=/opt/pyenv && export PATH="$PYENV_ROOT/bin:$PATH" && \
    eval "$(pyenv init --path)" && \
    pyenv install 3.10.13 && pyenv global 3.10.13'

# 5. Install uv and link it
RUN curl -Ls https://astral.sh/uv/install.sh | bash && \
    ln -s ~/.local/bin/uv /usr/local/bin/uv

# 6. Set working directory for the agent
WORKDIR /azdo

# 7. Download Azure DevOps agent
RUN curl -Ls "https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz" \
    -o agent.tar.gz && \
    tar -xzf agent.tar.gz && \
    chmod +x ./config.sh ./run.sh ./bin/Agent.Listener && \
    rm agent.tar.gz

# 8. Copy start script and fix permissions before switching users
COPY start.sh .
RUN chmod +x start.sh && chown azdo:azdo start.sh

# 9. Switch to azdo user
USER azdo
WORKDIR /azdo


# 10. Install uv as azdo user
USER azdo
RUN curl -Ls https://astral.sh/uv/install.sh | bash

# 11. Create symlink as root
USER root
RUN ln -sf /home/azdo/.local/bin/uv /usr/local/bin/uv

# 12. Return to azdo for execution
USER azdo
WORKDIR /azdo

# 13. Launch the agent
ENTRYPOINT ["./start.sh"]
