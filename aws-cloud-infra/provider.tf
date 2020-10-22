provider "aws" {
  region  = var.default_region
  profile = var.profile

  version = ">=2.22"
}

provider "template" {
  version = "2.1.2"
}

#############################################################
# Terraform configuration block is used to define backend   #
# Interpolation syntax is not allowed in Backend            #
#############################################################
terraform {
  required_version = ">= 0.12"
}

