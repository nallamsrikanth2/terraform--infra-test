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
        Project = "expense"
        environment = "dev"
        Terraform = "True"
    }
}

variable "ingress" {
    default = [
        {
        to_port = 22
        from_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        },
        {
        to_port = 1194
        from_port = 1194
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
        },
        {
        to_port = 443
        from_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        },
        {
        to_port = 943
        from_port = 943
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
        

    ]
  
}


