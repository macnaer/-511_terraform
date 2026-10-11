output "instance_id" {
  description = "IDs of the EC2 instances"
  value       = module.demo_server.instance_id
}

output "public_ip" {
  description = "Public IPs of the EC2 instances"
  value       = module.demo_server.public_ip
}

output "private_ip" {
  description = "Private IPs of the EC2 instances"
  value       = module.demo_server.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.demo_server.security_group_id
}
