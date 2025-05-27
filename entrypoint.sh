#!/bin/bash
set -e

# Set default Dynatrace home if not already set
DT_HOME=${DT_HOME:-/opt/dynatrace/oneagent}
mkdir -p "$DT_HOME"

# Only install the OneAgent if token and URL are provided
if [[ -z "$DT_API_TOKEN" || -z "$DT_API_URL" ]]; then
  echo "Dynatrace API token or URL not set. Skipping agent install."
else
  echo "Downloading Dynatrace OneAgent using Authorization header..."
  curl -sSL \
    -H "Authorization: Api-Token ${DT_API_TOKEN}" \
    "${DT_API_URL}/v1/deployment/installer/agent/unix/paas/latest?${DT_ONEAGENT_OPTIONS}" \
    -o "$DT_HOME/oneagent.zip"

  echo "Extracting OneAgent..."
  unzip -q -d "$DT_HOME" "$DT_HOME/oneagent.zip"
  rm "$DT_HOME/oneagent.zip"
fi

# Start the Node.js app
exec npm start
