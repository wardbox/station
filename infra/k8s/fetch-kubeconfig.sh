#!/usr/bin/env bash
set -euo pipefail

host="${1:-${CONTROL_PLANE_IPV4:-}}"
key="${SSH_PRIVATE_KEY:-$HOME/.ssh/id_ed25519}"
out="${KUBECONFIG_OUT:-infra/tofu/kubeconfig.yaml}"

if [[ -z "$host" ]]; then
  cat >&2 <<'EOF'
usage: infra/k8s/fetch-kubeconfig.sh <control-plane-ip>

Or set CONTROL_PLANE_IPV4. Trust is required before SSH: either set
SSH_HOST_KEY_SHA256 to the expected host key fingerprint, or pre-provision a
matching entry in ~/.ssh/known_hosts. The script SSHes to the k3s control plane,
reads /etc/rancher/k3s/k3s.yaml, rewrites 127.0.0.1 to the public control-plane
IP, and writes infra/tofu/kubeconfig.yaml by default.
EOF
  exit 2
fi

mkdir -p "$(dirname "$out")"
known_hosts="$(mktemp)"
trap 'rm -f "$known_hosts"' EXIT

if [[ -n "${SSH_HOST_KEY_SHA256:-}" ]]; then
  ssh-keyscan -T 15 "$host" > "$known_hosts"
  if ! ssh-keygen -lf "$known_hosts" | awk '{print $2}' | grep -Fxq "$SSH_HOST_KEY_SHA256"; then
    printf 'host key fingerprint mismatch for %s\n' "$host" >&2
    exit 1
  fi
elif [[ -f "$HOME/.ssh/known_hosts" ]] && ssh-keygen -F "$host" -f "$HOME/.ssh/known_hosts" > "$known_hosts"; then
  test -s "$known_hosts"
else
  cat >&2 <<'EOF'
no trusted host key found

Set SSH_HOST_KEY_SHA256 to the expected SHA256 fingerprint, or add the control
plane host key to ~/.ssh/known_hosts before running this script.
EOF
  exit 1
fi

ssh \
  -o StrictHostKeyChecking=yes \
  -o UserKnownHostsFile="$known_hosts" \
  -o ConnectTimeout=15 \
  -i "$key" \
  "root@$host" \
  'cat /etc/rancher/k3s/k3s.yaml' \
  | sed "s#https://127.0.0.1:6443#https://$host:6443#" \
  > "$out"

chmod 600 "$out"
test -s "$out"
printf 'wrote %s\n' "$out"
printf 'test with: KUBECONFIG=%q kubectl get nodes\n' "$out"
