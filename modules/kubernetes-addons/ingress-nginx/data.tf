data "aws_acm_certificate" "issued" {
  domain   = var.acm_domain
  statuses = ["ISSUED"]
}
