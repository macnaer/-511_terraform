aws_region        = "eu-north-1"
aws_image_id      = "ami-035c8a091035e710a"
aws_instance_type = "t3.small"
aws_key_name      = "Stockholm_3"
instance_name     = "Ubuntu Instance"
instance_count    = 2
root_volume_size  = 20
sg_name           = "SG_Terraform"

tags = {
  Project   = "HMP621"
  ManagedBy = "Terraform"
}
