module "db" {
    source = "../../terraform-infra-dev/02-sg"
    project_name = var.project_name
    common_tags = var.common_tags
    environment = var.environment
    sg_name = "db"
    description = "allow the sg group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
  
}

module "backend" {
    source = "../../terraform-infra-dev/02-sg"
    project_name = var.project_name
    common_tags = var.common_tags
    environment = var.environment
    sg_name = "backend"
    description = "allow the sg group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
  
}

module "frontend" {
    source = "../../terraform-infra-dev/02-sg"
    project_name = var.project_name
    common_tags = var.common_tags
    environment = var.environment
    sg_name = "frontend"
    description = "allow the sg group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
  
}

module "bastion" {
    source = "../../terraform-infra-dev/02-sg"
    project_name = var.project_name
    common_tags = var.common_tags
    environment = var.environment
    sg_name = "bastion"
    description = "allow the sg group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
  
}

module "vpn" {
    source = "../../terraform-infra-dev/02-sg"
    project_name = var.project_name
    common_tags = var.common_tags
    environment = var.environment
    sg_name = "vpn"
    description = "allow the sg group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    ingress_ports = var.ingress
  
}

module "app_alb" {
    source = "../../terraform-infra-dev/02-sg"
    project_name = var.project_name
    common_tags = var.common_tags
    environment = var.environment
    sg_name = "app_alb"
    description = "allow the sg group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
  
}

module "web_alb" {
    source = "../../terraform-infra-dev/02-sg"
    project_name = var.project_name
    common_tags = var.common_tags
    environment = var.environment
    sg_name = "web_alb"
    description = "allow the sg group"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
  
}

# db accepting connection from backend
resource "aws_security_group_rule" "db_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = module.db.sg_id
  source_security_group_id = module.backend.sg_id
}

# db accepting connection from bastion
resource "aws_security_group_rule" "db_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = module.db.sg_id
  source_security_group_id = module.bastion.sg_id
}

# db accepting connection from vpn
resource "aws_security_group_rule" "db_vpn" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = module.db.sg_id
  source_security_group_id = module.vpn.sg_id
}

# backend accepting connection from app-alb
resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.backend.sg_id
  source_security_group_id = module.app_alb.sg_id
}

# backend accepting connection from vpn
resource "aws_security_group_rule" "backend_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = module.backend.sg_id
  source_security_group_id = module.vpn.sg_id
}

# backend accepting connection from bastion
resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.backend.sg_id
  source_security_group_id = module.bastion.sg_id
}

# backend accepting connection from vpn_ssh
resource "aws_security_group_rule" "backend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.backend.sg_id
  source_security_group_id = module.vpn.sg_id
}

# app_alb accepting connection from frontend
resource "aws_security_group_rule" "app_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = module.app_alb.sg_id
  source_security_group_id = module.frontend.sg_id
}

# app_alb accepting connection from vpn
resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = module.app_alb.sg_id
  source_security_group_id = module.vpn.sg_id
}

# app_alb accepting connection from vpn
resource "aws_security_group_rule" "app_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = module.app_alb.sg_id
  source_security_group_id = module.bastion.sg_id
}

# frontend accepting connection from web_alb
resource "aws_security_group_rule" "frontend_web_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = module.frontend.sg_id
  source_security_group_id = module.web_alb.sg_id
}

# frontend accepting connection from vpn
resource "aws_security_group_rule" "frontend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.frontend.sg_id
  source_security_group_id = module.vpn.sg_id
}

# frontend accepting connection from bastion
resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.frontend.sg_id
  source_security_group_id = module.bastion.sg_id
}

# web_alb accepting connection from public
resource "aws_security_group_rule" "web_alb_public_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb.sg_id
}

# web_alb accepting connection from public
resource "aws_security_group_rule" "web_alb_public_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.web_alb.sg_id
}

# bastion accepting connection from public
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}












