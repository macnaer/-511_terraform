terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "demo_server" {
  source = "./modules/demo-server"

  ami_id           = var.aws_image_id
  instance_type    = var.aws_instance_type
  instance_count   = var.instance_count
  key_name         = var.aws_key_name
  instance_name    = var.instance_name
  root_volume_size = var.root_volume_size
  sg_name          = var.sg_name
  tags             = var.tags
}
