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
        project_name = "expense"
        Environment = "dev"
        Component = "backend"
        Terraform = "true"
    }
}

variable "domain_name" {
    type = string
    default = "nsrikanth.online"
  
}