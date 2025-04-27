#!/usr/bin/env bash
set -euo pipefail

PORT=${PORT:-8080}
SSE_PATH=${SSE_PATH:-"/sse"}
MESSAGE_PATH=${MESSAGE_PATH:-"/message"}
BASE_URL=${BASE_URL:-"http://localhost:$PORT"}
VENV_DIR="/app/.venv"

# available MCP servers
ALLOWED_SERVERS=(
  "mcp-server-fetch"
  "mcp-server-puppeteer"
  "mcp-server-qdrant"
)

print_help() {
  echo "Usage: docker run <image> <mcp-server-package> [extra-args]"
  echo
  echo "Available MCP servers:"
  for s in "${ALLOWED_SERVERS[@]}"; do
    echo "  • $s"
  done
}

# print help without argument
if [[ $# -eq 0 ]]; then
  print_help
  exit 1
fi

# try to find server in list
SERVER="$1"; shift
MATCHED=false
for s in "${ALLOWED_SERVERS[@]}"; do
  if [[ "$s" == "$SERVER" ]]; then
    MATCHED=true
    break
  fi
done

# if server not available print help
if [[ $MATCHED == false ]]; then
  echo "❌  '$SERVER' is not available."
  print_help
  exit 1
fi

# run
export PATH="$VENV_DIR/bin:/app/node_modules/.bin:$PATH"
source "$VENV_DIR/bin/activate"

# prepare server cmd
if [[ $# -gt 0 ]]; then
  SERVER_CMD="$SERVER $*" # e.g.  "mcp-server-git --test --foo=bar"
else
  SERVER_CMD="$SERVER"
fi

exec /app/node_modules/.bin/supergateway \
  --port "$PORT" \
  --baseUrl "$BASE_URL" \
  --ssePath "$SSE_PATH" \
  --messagePath "$MESSAGE_PATH" \
  --cors \
  --healthEndpoint /healthz \
  --outputTransport sse \
  --stdio "$SERVER_CMD"