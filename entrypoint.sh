#!/bin/bash
set -e

if [[ -z "$DT_API_TOKEN" || -z "$DT_API_URL" ]]; then
  echo "Dynatrace API token or URL not set. Skipping agent install."
else
  echo "Downloading Dynatrace OneAgent..."
  wget -q -O "$DT_HOME/oneagent.zip" "${DT_API_URL}/v1/deployment/installer/agent/unix/paas/latest?Api-Token=${DT_API_TOKEN}&${DT_ONEAGENT_OPTIONS}"
  unzip -q -d "$DT_HOME" "$DT_HOME/oneagent.zip"
  rm "$DT_HOME/oneagent.zip"
fi

exec npm start
