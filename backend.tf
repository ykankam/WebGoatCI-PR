# terraform {
#   backend "s3" {
#     bucket = "acme-tfstate-bucket-us-east-1"
#     key    = "tfstate-aws/cloudtrail.tfstate"
#     region = "us-east-1"
#     dynamodb_table = "tfstate-lock"
#   }
# }
