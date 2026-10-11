output "instance_id" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.this[*].id
}

output "public_ip" {
  description = "Public IPs of the EC2 instances"
  value       = aws_instance.this[*].public_ip
}

output "private_ip" {
  description = "Private IPs of the EC2 instances"
  value       = aws_instance.this[*].private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}
