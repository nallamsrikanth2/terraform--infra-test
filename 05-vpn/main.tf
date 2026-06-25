resource "aws_key_pair" "kuber" {
  key_name   = "vpn"
  #public_key = file("~/.ssh/kuber.pub")
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZs5G7Nb0RjSYK7fRyoUTZVkARog+NJNF7iPCsHtDhu"


}


module "vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-vpn"
  
  ami = "ami-04210df84866a6f22"
  instance_type = "t3.micro"
  # convert stringlist to list ang get first element 
  subnet_id     =  local.public_subnet_id
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  create_security_group = false
  key_name = aws_key_pair.kuber.key_name
  associate_public_ip_address = true
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
} 