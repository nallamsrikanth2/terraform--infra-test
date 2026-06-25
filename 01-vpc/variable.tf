variable "project_name" {
    type = string
    default = "expense"
  
}

variable "environment" {
    type = string
    default = "dev"
  
}

variable "common_tags" {
    type = map
    default = {
        Project = "Expense"
        environment = "dev"
        Component = "vpc"
        Terraform = "True"
    }
}

variable "public_subnet_cidrs" {
    type = list
    default = [ "10.0.44.0/24" , "10.0.46.0/24"]
}

variable "private_subnet_cidrs" {
    type = list
    default = [ "10.0.12.0/24" , "10.0.16.0/24"]
}

variable "database_subnet_cidrs" {
    type = list
    default = [ "10.0.33.0/24" , "10.0.36.0/24"]
}

variable "is_peering_required" {
    type = bool
    default = true
}

