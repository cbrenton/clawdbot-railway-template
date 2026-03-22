#!/usr/bin/env bash
set -euo pipefail

mkdir -p /root/.config/gogcli
chmod 700 /root/.config/gogcli

export GOG_KEYRING_BACKEND="${GOG_KEYRING_BACKEND:-file}"
export GOG_KEYRING_PASSWORD="${GOG_KEYRING_PASSWORD:-${GOG_KEYRING_PASSPHRASE:-}}"

if [ -z "${GOG_KEYRING_PASSWORD:-}" ]; then
  echo "Missing GOG_KEYRING_PASSWORD / GOG_KEYRING_PASSPHRASE" >&2
  exit 1
fi

# point this at your mounted persistent-volume path
GOG_CLIENT_CREDENTIALS_PATH="${GOG_CLIENT_CREDENTIALS_PATH:-/data/gog/credentials.json}"

if [ -f "$GOG_CLIENT_CREDENTIALS_PATH" ]; then
  gog auth credentials "$GOG_CLIENT_CREDENTIALS_PATH" >/dev/null
else
  echo "Missing OAuth client credentials file at $GOG_CLIENT_CREDENTIALS_PATH" >&2
  exit 1
fi

if [ -n "${GOG_TOKENS_B64:-}" ]; then
  echo "$GOG_TOKENS_B64" | base64 -d > /tmp/gog-tokens.json
  gog auth tokens import /tmp/gog-tokens.json >/dev/null
fi

if [ -n "${GOG_ACCOUNT:-}" ]; then
  gog auth status --account "$GOG_ACCOUNT" || true
else
  gog auth list || true
fi

exec "$@"
