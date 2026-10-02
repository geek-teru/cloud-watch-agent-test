# ----------------------------------------
# Provider Settings
# ----------------------------------------
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      env          = var.env
      service_name = var.service_name
      terraform    = "true"
    }
  }
}

# ----------------------------------------
# Terraform Settings
# ----------------------------------------
terraform {
  required_version = "~> 1.16.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.67.0"
    }
  }

  backend "s3" {
    # bucket / key はプロジェクトごとに変更する
    bucket  = "dev-terraform-aws"
    key     = "cloud-watch-agent-test/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}
