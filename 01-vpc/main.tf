module "vpc" {
    source ="git::https://github.com/nallamsrikanth2/terraform-infra-dev.git?ref=main"
    project_name = var.project_name
    environment =  var.environment
    common_tags = var.common_tags
    public_subnets_cidrs = var.public_subnet_cidrs
    private_subnets_cidrs = var.private_subnet_cidrs
    database_subnets_cidrs = var.database_subnet_cidrs
    is_peering_required = var.is_peering_required
}