resource "aws_instance" "frontend" {
  ami           =  data.aws_ami.ami_id.id
  instance_type = "t3.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  subnet_id = local.private_ip
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-frontend"
    }
  )
}

resource "null_resource" "frontend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = aws_instance.frontend.id
  }
   connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.frontend.private_ip
  }

  provisioner "file" {
    source = "frontend.sh"
    destination = "/tmp/frontend.sh"
    
  }
provisioner "remote-exec" {
  inline = [
    "sudo chmod +x /tmp/frontend.sh",
    "sudo bash  /tmp/frontend.sh ${var.common_tags.Component} ${var.environment}"
  ]
}
}

resource "aws_ec2_instance_state" "frontend" {
  instance_id = aws_instance.frontend.id
  state       = "stopped"
  depends_on = [ null_resource.frontend ]
}

resource "aws_ami_from_instance" "frontend" {
  name               = "${var.project_name}-${var.environment}-frontend"
  source_instance_id = aws_instance.frontend.id
  depends_on = [ aws_ec2_instance_state.frontend ]
}

resource "null_resource" "frontend_delete" {
  provisioner "local-exec" {
   command = "aws ec2 terminate-instances --instance-ids ${aws_instance.frontend.id}"
}
depends_on = [ aws_ami_from_instance.frontend ]
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.project_name}-${var.environment}-frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    path                = "/health"
    port                = 80
    protocol            = "HTTP"
    matcher             = "200-299"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    
  }
  depends_on = [ null_resource.frontend_delete ]
}

resource "aws_launch_template" "frontend" {
  name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"

  image_id = aws_ami_from_instance.frontend.id

  instance_initiated_shutdown_behavior = "terminate"
  update_default_version = true  # set the latest version of default
  instance_type = "t3.micro"

  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
         Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
      }
    )
  }

 depends_on = [ aws_lb_target_group.frontend ]
}

resource "aws_autoscaling_group" "frontend" {
  name                      = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 1
  vpc_zone_identifier       =  split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  target_group_arns =  [aws_lb_target_group.frontend.arn]

 launch_template {
   id = aws_launch_template.frontend.id
   version = "$Latest"
 }

 instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

 tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "frontend" {
  name                   = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  autoscaling_group_name = aws_autoscaling_group.frontend.name
  policy_type            = "TargetTrackingScaling"
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 10.0
  }
}


resource "aws_lb_listener_rule" "frontend" {
  listener_arn = data.aws_ssm_parameter.aws_lb_listener_arn.value
  priority     = 100 #less number first validated

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
     values = ["web-${var.environment}.${var.domain_name}"]
    }
  }
}









