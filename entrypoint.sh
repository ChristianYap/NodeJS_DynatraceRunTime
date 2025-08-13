#!/bin/bash
set -e

echo "Entrypoint revamp 8/12/25 with more error logging..."

# Set default Dynatrace home if not already set
DT_HOME="${DT_HOME:-/opt/dynatrace/oneagent}"
ZIP="${DT_HOME}/oneagent.zip"
LIB="${DT_HOME}/agent/lib64/liboneagentproc.so"

# Echo variables to double check
echo "DT_HOME: ${DT_HOME}"
echo "DT_API_URL: ${DT_API_URL}"

# Prep directory, won't recreate if it already exists
mkdir -p "$DT_HOME"

# Download agent wget
echo "Downloading OneAgent to: ${ZIP}"

# Capture wget’s headers & status to a temp log for debugging
TMPLOG="$(mktemp)"

# --server-response writes headers to stderr; we redirect 2>&1 into TMPLOG
# Quiet body output to stdout, write file to $ZIP
if ! wget --server-response --quiet \
  --header="Authorization: Api-Token ${DT_API_TOKEN}" \
  -O "${ZIP}" \
  "${DT_API_URL}" 2> "${TMPLOG}"; then
  echo "wget failed. Dumping headers/log:"
  sed -n '1,200p' "${TMPLOG}" || true
  exit 1
fi

# Print what we actually got from above.....
echo "Wget response (40 lines):"
tail -n 40 "${TMPLOG}" || true

echo "Listing DT_HOME: let's just double check"
ls -lah "${DT_HOME}" || true

if [[ -f "${ZIP}" ]]; then
  BYTES=$(wc -c < "${ZIP}" || echo 0)
  echo "oneagent.zip size: ${BYTES} bytes"
  # Try to identify the MIME type (will be 'application/zip' for a real zip)
  if command -v file >/dev/null 2>&1; then
    echo "MIME type: $(file -b --mime-type "${ZIP}")"
  fi
else
  echo "${ZIP} was not created"
  exit 1
fi

# Extract
echo "Extracting OneAgent to ${DT_HOME}…"
unzip -oq "${ZIP}" -d "${DT_HOME}"
echo "Post-extract listing:"
ls -lah "${DT_HOME}" || true


# Set LD_PRELOAD *after* the .so exists
if [[ -f "${LIB}" ]]; then
  export LD_PRELOAD="${LIB}"
  echo "LD_PRELOAD set to: ${LD_PRELOAD}"
else
  echo "Dynatrace library not found at ${LIB}"
  exit 1
fi

# Start the Node.js app
exec npm start
