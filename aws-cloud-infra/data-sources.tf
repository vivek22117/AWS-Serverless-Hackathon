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