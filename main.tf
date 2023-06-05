resource "aws_s3_bucket" "demo_queue" {
  bucket        = var.bucket_name
  force_destroy = true
  acl           = "private"

 
}


resource "aws_s3_bucket_lifecycle_configuration" "demo_queue_bucket-config" {
  bucket = aws_s3_bucket.demo_queue.id

  rule {
    id     = "delete"
    status = "Enabled"

    filter {}

    expiration {	
      days = 14
    }
  }
}

# Security Note - there is no current need for a bucket policy as no external accounts, IAM roles, etc need to be granted access.
# If during future development, a need is identified, a bucket policy would be created and managed here.

resource "aws_s3_bucket_policy" "allow_access_https_true_demo_queue" {
  bucket = aws_s3_bucket.demo_queue.id
  policy = data.aws_iam_policy_document.allow_access_https_true_demo_queue.json
}

data "aws_iam_policy_document" "allow_access_https_true_demo_queue" {
   statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    condition {    
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }

    resources = [
      "${aws_s3_bucket.demo_queue.arn}",
      "${aws_s3_bucket.demo_queue.arn}/*",
    ]
  }
}


resource "aws_s3_bucket_public_access_block" "demo_queue_public_access_block" {
  bucket                  = aws_s3_bucket.demo_queue.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo_queue_encryption" {
  bucket = aws_s3_bucket.demo_queue.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_default_tags" "current" {}



terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.53.0"
    }
  }
  required_version = ">= 1.3.2"
}

