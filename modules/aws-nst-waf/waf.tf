module "kms_key" {
  source                  = "../aws-nst-kms"
  description             = "waf-logs-kms-key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  alias                   = "alias/${var.name}-waf-logs-key"
  policy                  = data.aws_iam_policy_document.kms_waf.json
}

resource "aws_s3_bucket" "waf" {
  bucket = "aws-waf-logs-${var.name}"

  tags = merge(var.service_tags, {
    Name = "aws-waf-logs-${var.name}"
  })
}

resource "aws_s3_bucket_versioning" "waf" {
  bucket     = aws_s3_bucket.waf.id
  depends_on = [aws_s3_bucket.waf]

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf" {
  bucket     = aws_s3_bucket.waf.id
  depends_on = [aws_s3_bucket.waf]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.kms_key.key_arn
    }
    bucket_key_enabled = true
  }

}

resource "aws_s3_bucket_ownership_controls" "waf" {
  bucket = aws_s3_bucket.waf.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "waf" {
  bucket     = aws_s3_bucket.waf.id
  depends_on = [aws_s3_bucket.waf]

  rule {
    id = "Expire in 365 Days"
    expiration {
      days = 365
    }
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = 365
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "waf" {
  bucket                  = aws_s3_bucket.waf.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "waf" {
  bucket     = aws_s3_bucket.waf.id
  policy     = data.aws_iam_policy_document.waf_s3_enforce_ssl.json
  depends_on = [aws_s3_bucket.waf]
}

resource "aws_wafv2_web_acl" "acl" {
  description = "${var.name}-acl"
  name        = "${var.name}-acl"
  scope       = var.scope

  tags = merge(var.service_tags, {
    Name = "${var.name}-acl"
  })

  default_action {
    allow {
    }
  }

  rule {
    name     = "${var.name}-ip-rate-limit"
    priority = 1
    action {
      block {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 1000
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ip-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 4
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "SizeRestrictions_BODY"

          action_to_use {
            block {
            }
          }
        }
        rule_action_override {
          name = "CrossSiteScripting_BODY"

          action_to_use {
            block {
            }
          }
        }
        rule_action_override {
          name = "GenericLFI_BODY"

          action_to_use {
            block {
            }
          }
        }
        rule_action_override {
          name = "NoUserAgent_HEADER"

          action_to_use {
            block {
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 5
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 7
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "LFI_URIPATH"

          action_to_use {
            count {
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 6

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "SQLi_BODY"

          action_to_use {
            count {
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesUnixRuleSet"
    priority = 8
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesUnixRuleSet"
      sampled_requests_enabled   = true
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-acl"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "web-acl-logging" {

  log_destination_configs = [
    aws_s3_bucket.waf.arn,
  ]
  resource_arn = aws_wafv2_web_acl.acl.arn

  redacted_fields {

    method {}
  }
  redacted_fields {

    query_string {}
  }
  redacted_fields {

    uri_path {}
  }
}
