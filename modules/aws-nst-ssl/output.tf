output "ssl_cert_arn" {
  value = aws_acm_certificate.cert.arn
}

output "cert_status" {
  value = aws_acm_certificate.cert.status
}
