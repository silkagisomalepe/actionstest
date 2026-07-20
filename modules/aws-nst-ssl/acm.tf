resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${var.dns}"
  validation_method = var.verification

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.service_tags, {
    Name = var.dns
  })
}
