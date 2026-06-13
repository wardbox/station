# --------------------------------------------------------------------------
# What layer 2 (Argo) and you need after apply.
# --------------------------------------------------------------------------

output "control_plane_ipv4" {
  description = "Public IPv4 of the control-plane node — the cluster entry point and the DNS target."
  value       = module.cluster.control_plane_ipv4
}

output "node_names" {
  description = "All node names (control plane + agents)."
  value       = module.cluster.node_names
}

output "agent_ipv4s" {
  description = "Public IPv4s of the agent nodes."
  value       = module.cluster.agent_ipv4s
}

output "kubeconfig_path" {
  description = "Local path to the fetched kubeconfig. Use it: export KUBECONFIG=<path>"
  value       = module.cluster.kubeconfig_path
}
