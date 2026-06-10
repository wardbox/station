output "control_plane_ipv4" {
  description = "Public IPv4 of the control-plane node."
  value       = hcloud_primary_ip.control_plane_ipv4.ip_address
}

output "control_plane_private_ip" {
  description = "Private IP of the control-plane node."
  value       = local.control_plane_private_ip
}

output "agent_ipv4s" {
  description = "Public IPv4s of the agent nodes."
  value       = [for s in hcloud_server.agent : s.ipv4_address]
}

output "node_names" {
  description = "All node names."
  value       = concat([hcloud_server.control_plane.name], [for s in hcloud_server.agent : s.name])
}

output "kubeconfig_path" {
  description = "Local path to the fetched kubeconfig."
  value       = "${path.root}/kubeconfig.yaml"
}
