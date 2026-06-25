locals {
  private_ip = element(split(",", data.aws_ssm_parameter.private_subnet_ids.value), 0)
}