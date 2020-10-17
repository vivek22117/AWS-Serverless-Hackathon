#############################
# Global Variables          #
#############################
variable "profile" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type = string
  description = "Environment to deploy, Valid values 'qa', 'dev', 'prod'"
}

variable "default_region" {
  type        = string
  description = "AWS region to deploy resources"
}

#################################
#  Default Variables            #
#################################
variable "s3_bucket_prefix" {
  type = string
  description = "S3 deployment bucket prefix"
  default = "doubledigit-tfstate"
}



#####========================Lambda Configuration======================#####
variable "log-retention-in-days" {
  type        = number
  description = "Number of days to retain logs"
}

variable "email-reminder-lambda" {
  type        = string
  description = "Name of lambda function for Email Reminder"
}

variable "memory-size" {
  type        = string
  description = "Lambda memory size"
}

variable "time-out" {
  type        = string
  description = "Lambda time out"
}

variable "api_gateway_reminder_path" {
  type        = string
  description = "URL path for reminder api gateway resource"
}

variable "email-lambda-bucket-key" {
  type        = string
  description = "S3 bucket key to hold lambda artifactory"
}

variable "verified_email" {
  type        = string
  description = "Verified email Id to send email!"
}

#####====================Default Variables==================#####
variable "artifactory_bucket_prefix" {
  type        = string
  description = "Predefined for Artifactory Bucket"
}

variable "sns_stack_name" {
  type        = string
  description = "Unique Cloudformation stack name that wraps the SNS topic."
}

variable "protocol" {
  type        = list(string)
  default     = ["email"]
  description = "SNS protocols to use"
}

variable "display_name" {
  type        = string
  description = "Name shown in confirmation emails"
}


#####============================Local variables=====================#####
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "Vivek-1"
    environment = var.environment
  }
}

