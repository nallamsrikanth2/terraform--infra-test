resource "aws_instance" "example" {
  ami           = data.aws_ami.ami_id.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  subnet_id = local.public_subnet_id
  user_data = file("bastion.sh")
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
  
}