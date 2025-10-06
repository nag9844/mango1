variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas API Public Key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas API Private Key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "database_password" {
  description = "Database user password"
  type        = string
  sensitive   = true
}

variable "aws_vpc_id" {
  description = "AWS VPC ID for peering"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_kms_key_id" {
  description = "AWS KMS Key ID for encryption at rest"
  type        = string
}

variable "aws_kms_role_id" {
  description = "AWS KMS Role ID"
  type        = string
}
