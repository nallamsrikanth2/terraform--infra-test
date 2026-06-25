data "aws_route53_zone" "zone_id" {
  name         = "nsrikanth.online"
  private_zone = false
}