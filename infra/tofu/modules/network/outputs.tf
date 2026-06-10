output "network_id" {
  description = "ID of the private network."
  value       = hcloud_network.this.id
}

output "subnet_id" {
  description = "ID of the private subnet."
  value       = hcloud_network_subnet.this.id
}

output "firewall_id" {
  description = "ID of the node firewall."
  value       = hcloud_firewall.this.id
}
