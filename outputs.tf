output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.demo_server.instance_id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.demo_server.public_ip
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.demo_server.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.demo_server.security_group_id
}
