#!/bin/sh
set -e

# Write service account credentials from Cloudflare Secret to a runtime file.
# The container filesystem is ephemeral — credentials are never baked into the image.
if [ -n "$GSC_CREDENTIALS_JSON" ]; then
  mkdir -p /tmp/gsc-secrets
  # Use printf to avoid echo adding newlines; write raw JSON content
  printf '%s' "$GSC_CREDENTIALS_JSON" > /tmp/gsc-secrets/credentials.json
  export GSC_CREDENTIALS_PATH=/tmp/gsc-secrets/credentials.json
  echo "entrypoint: wrote credentials to $GSC_CREDENTIALS_PATH ($(wc -c < /tmp/gsc-secrets/credentials.json) bytes)" >&2
else
  echo "entrypoint: GSC_CREDENTIALS_JSON not set, skipping file write" >&2
fi

# Advanced: inject pre-generated OAuth token
if [ -n "$GSC_OAUTH_TOKEN_JSON" ]; then
  mkdir -p "${GSC_CONFIG_DIR:-/tmp/mcp-gsc-config}"
  printf '%s' "$GSC_OAUTH_TOKEN_JSON" > "${GSC_CONFIG_DIR:-/tmp/mcp-gsc-config}/token.json"
fi

exec uv run --no-sync python gsc_server.py
