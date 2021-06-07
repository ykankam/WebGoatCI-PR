variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "security"
}

variable "purpose" {
  default = "logging"
}

variable "access_logging_bucket_name_prefix" {
  default = "acme-s3-access-logs"
}

variable "logging_bucket_name" {
  default = "acme-cloudtrail-logging"
}

variable "logging_trail_name" {
  default = "AcmeTrailLogging"
}
