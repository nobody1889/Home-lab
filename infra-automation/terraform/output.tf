output "master-node_ip" {
  value = incus_instance.master-node[*].ipv4_address
}

output "worker-node_ip" {
  value = incus_instance.worker-node[*].ipv4_address
}