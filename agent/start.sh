#!/bin/bash
set -e

: "${AZP_URL:?Missing AZP_URL}"
: "${AZP_TOKEN:?Missing AZP_TOKEN}"
: "${AZP_POOL:?Missing AZP_POOL}"
: "${AZP_AGENT_NAME:=azdo-agent-$(hostname)}"

echo "Starting Azure DevOps agent:"
echo "- URL: $AZP_URL"
echo "- Pool: $AZP_POOL"
echo "- Agent name: $AZP_AGENT_NAME"

# Clean stale registration
if [ -e .agent ]; then
  echo "Cleaning previous agent registration..."
  ./config.sh remove --unattended --auth pat --token "$AZP_TOKEN" || true
fi

# Configure agent
./config.sh --unattended \
  --url "$AZP_URL" \
  --auth pat \
  --token "$AZP_TOKEN" \
  --pool "$AZP_POOL" \
  --agent "$AZP_AGENT_NAME" \
  --acceptTeeEula \
  --replace

# Graceful shutdown
cleanup() {
  echo "Cleanup: Removing agent..."
  ./config.sh remove --unattended --auth pat --token "$AZP_TOKEN" || true
}
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Run the agent
./run.sh
