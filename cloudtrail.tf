# Issues in this example
# - [S3] No block public access on bucket
# - [S3] No SSE on bucket
# - [S3] No versioning on bucket
# - [S3] No lifecycle configuration on bucket
# - [S3] No access logging on cloudtrail storage bucket
# - [CloudTrail] No log file validation on cloudtrail trail
# - [CloudTrail] No encryption of log files
# - [KMS] Key rotation not enabled

#######################################
###### CloudTrail Logging Bucket ######
#######################################
resource "aws_s3_bucket" "logging_bucket" {
  bucket        = var.logging_bucket_name
  acl           = "private"
}

resource "aws_s3_bucket_policy" "logging_bucket" {
  bucket = aws_s3_bucket.logging_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": {
          "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.logging_bucket.arn}"
    },
    {
      "Sid": "CloudTrailWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": [
        "${aws_s3_bucket.logging_bucket.arn}/AWSLogs/123456789012/*"
      ],
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Sid": "Require HTTPS",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.logging_bucket.arn}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

############################
##### Logging KMS Key #####
############################
resource "aws_kms_key" "logging_key" {
  is_enabled = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "cloudtrail-key-policy",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Enable CloudTrail",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "kms:GenerateDataKey*",
            "Resource": "*",
            "Condition": {
              "StringLike": {
                "kms:EncryptionContext:aws:cloudtrail:arn": [
                  "arn:aws:cloudtrail:*:123456789012:trail/*"
                ]
              }
            }
        },
        {
            "Sid": "Allow CloudTrail access",
            "Effect": "Allow",
            "Action": "kms:DescribeKey",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_kms_alias" "logging_key_alias" {
  name = "alias/logging-key"
  target_key_id = aws_kms_key.logging_key.key_id
}

#########################
##### Logging Trail #####
#########################
resource "aws_cloudtrail" "logging_trail" {
    name = "var.logging_trail_name"
    s3_bucket_name = aws_s3_bucket.logging_bucket.id
    include_global_service_events = true

    enable_logging = true
    is_multi_region_trail = true
}
