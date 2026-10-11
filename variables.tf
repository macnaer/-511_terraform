variable "aws_access_key" {
  description = "AWS access key for authentication (store in secrets.tfvars, never commit)"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key for authentication (store in secrets.tfvars, never commit)"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-north-1"
}

variable "aws_image_id" {
  description = "AMI ID for the primary Ubuntu instance"
  type        = string
  default     = "ami-0d6d8576c5ce37b8a"
}

variable "aws_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "aws_key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
  default     = "Stockholm_3"
}

variable "instance_name" {
  description = "Name tag for the instance"
  type        = string
  default     = "Ubuntu Instance"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "SG_Terraform"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project   = "HMP621"
    ManagedBy = "Terraform"
  }
}
