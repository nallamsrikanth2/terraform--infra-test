data "aws_ssm_parameter" "public_subnet_id" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}


data "aws_ssm_parameter" "vpn_sg_id" {
  name = "/${var.project_name}/${var.environment}/vpn_sg_id"
}




