variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "terraform-handson"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "iam_user_name" {
  description = "Name for the IAM user"
  type        = string
  default     = "s3-access-user"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
