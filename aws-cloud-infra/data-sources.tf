############==============Read Json cloudformation template for SNS===========########
data "template_file" "cft_sns_stack" {
  template = file("${path.module}/templates/sns-cft.json.tpl")

  vars = {
    display_name = var.display_name
    subscriptions = join(
      ",",
      formatlist(
        "{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\"  }",
        var.verified_email,
        var.protocol,
      )
    )
  }
}


###################################################
# Fetch remote state for S3 deployment bucket     #
###################################################
data "terraform_remote_state" "backend" {
  backend = "s3"

  config = {
    profile = var.profile
    bucket ="${var.s3_bucket_prefix}-${var.environment}-${var.default_region}"
    key = "state/${var.environment}/backend/terraform.tfstate"
    region = var.default_region
  }
}
