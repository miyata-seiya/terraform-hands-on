module "s3_with_iam" {
  source = "../../modules/s3_with_iam"

  bucket_name_prefix = "<your-name>"
  environment        = "dev"
  iam_user_name      = "s3-access-user"

  tags = {
    Project    = "Terraform Handson"
    Owner      = "Infrastructure Team"
    CostCenter = "123456"
  }
}
