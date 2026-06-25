resource "aws_instance" "backend" {
  ami           =  data.aws_ami.ami_id.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  subnet_id = local.private_ip
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-backend"
    }
  )
}

resource "null_resource" "backend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = aws_instance.backend.id
  }
   connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.backend.private_ip
  }

  provisioner "file" {
    source = "backend.sh"
    destination = "/tmp/backend.sh"
    
  }
provisioner "remote-exec" {
  inline = [
    "sudo chmod +x /tmp/backend.sh",
    "sudo bash  /tmp/backend.sh ${var.common_tags.Component} ${var.environment}"
  ]
}
}

resource "aws_ec2_instance_state" "backend" {
  instance_id = aws_instance.backend.id
  state       = "stopped"
  depends_on = [ null_resource.backend ]
}

resource "aws_ami_from_instance" "backend" {
  name               = "${var.project_name}-${var.environment}-backend"
  source_instance_id = aws_instance.backend.id
  depends_on = [ aws_ec2_instance_state.backend ]
}

resource "null_resource" "backend_delete" {
  provisioner "local-exec" {
   command = "aws ec2 terminate-instances --instance-ids ${aws_instance.backend.id}"
}
depends_on = [ aws_ami_from_instance.backend ]
}

resource "aws_lb_target_group" "backend" {
  name     = "${var.project_name}-${var.environment}-backend"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    path                = "/health"
    port                = 8080
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  depends_on = [ null_resource.backend_delete ]
}

resource "aws_launch_template" "backend" {
  name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"

  image_id = aws_ami_from_instance.backend.id

  instance_initiated_shutdown_behavior = "terminate"
  update_default_version = true  # set the latest version of default
  instance_type = "t3.micro"

  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
         Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
      }
    )
  }

 depends_on = [ aws_lb_target_group.backend ]
}

resource "aws_autoscaling_group" "backend" {
  name                      = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 1
  vpc_zone_identifier       =  split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  target_group_arns =  [aws_lb_target_group.backend.arn]

 launch_template {
   id = aws_launch_template.backend.id
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

resource "aws_autoscaling_policy" "backend" {
  name                   = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  policy_type            = "TargetTrackingScaling"
  
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 10.0
  }
}


resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.aws_lb_listener_arn.value
  priority     = 100 #less number first validated

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
     values = ["backend.app-${var.environment}.${var.domain_name}"]
    }
  }
}









