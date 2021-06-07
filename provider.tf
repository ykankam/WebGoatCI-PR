provider "aws" {
  region                  = "us-west-2"
  shared_credentials_file = "/Users/ddoughty/.aws/credentials"
  profile                 = "david.doughty"
}
#provider "aws" {
#  region  = var.aws_region
#}
#
data "aws_caller_identity" "current" {}
