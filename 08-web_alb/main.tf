resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-${var.environment}-web-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = split("," , data.aws_ssm_parameter.public_subnet_ids.value)
  security_groups = [data.aws_ssm_parameter.web_alb_sg_id.value]
  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-web-alb"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
 type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>this is fixed reason from web-alb</h1>"
      status_code  = "200"
    }
}
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =  data.aws_ssm_parameter.aws_acm_certificate.value

 default_action {
 type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>this is fixed reason from web-alb-https</h1>"
      status_code  = "200"
    }
}
}


module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "web-${var.environment}"
      type    = "A"
       alias = {
        name    = aws_lb.web_alb.dns_name
        zone_id = aws_lb.web_alb.zone_id
      }
      allow_overwrite = true
    }
  ]

}

