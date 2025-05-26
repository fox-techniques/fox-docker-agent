#!/bin/bash
set -e

# Make sure required environment variables are set
: "${AZP_URL:?Missing AZP_URL}"
: "${AZP_TOKEN:?Missing AZP_TOKEN}"
: "${AZP_POOL:?Missing AZP_POOL}"
: "${AZP_AGENT_NAME:=azdo-agent-$(hostname)}"

echo "Starting Azure DevOps agent:"
echo "- URL: $AZP_URL"
echo "- Pool: $AZP_POOL"
echo "- Agent name: $AZP_AGENT_NAME"

# Setup pyenv environment for interactive shell usage (if needed)
export PYENV_ROOT="/opt/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)" || true

# Clean up previous agent registration (if container reused)
if [ -e .agent ]; then
  echo "Removing previous agent configuration..."
  ./config.sh remove --unattended --auth pat --token "$AZP_TOKEN" || true
fi

# Configure the agent
./config.sh --unattended \
  --url "$AZP_URL" \
  --auth pat \
  --token "$AZP_TOKEN" \
  --pool "$AZP_POOL" \
  --agent "$AZP_AGENT_NAME" \
  --acceptTeeEula \
  --replace

# Graceful shutdown handling
cleanup() {
  echo "Cleanup: Removing Azure DevOps agent..."
  ./config.sh remove --unattended --auth pat --token "$AZP_TOKEN" || true
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Run the agent
./run.sh
