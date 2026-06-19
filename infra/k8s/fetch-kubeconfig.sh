#!/usr/bin/env bash
set -euo pipefail

host="${1:-${CONTROL_PLANE_IPV4:-}}"
key="${SSH_PRIVATE_KEY:-$HOME/.ssh/id_ed25519}"
out="${KUBECONFIG_OUT:-infra/tofu/kubeconfig.yaml}"

if [[ -z "$host" ]]; then
  cat >&2 <<'EOF'
usage: infra/k8s/fetch-kubeconfig.sh <control-plane-ip>

Or set CONTROL_PLANE_IPV4. The script SSHes to the k3s control plane, reads
/etc/rancher/k3s/k3s.yaml, rewrites 127.0.0.1 to the public control-plane IP,
and writes infra/tofu/kubeconfig.yaml by default.
EOF
  exit 2
fi

mkdir -p "$(dirname "$out")"
known_hosts="$(mktemp)"
trap 'rm -f "$known_hosts"' EXIT

ssh-keyscan -T 15 -H "$host" > "$known_hosts"
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
