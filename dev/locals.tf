locals {
  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing_code = var.billing_code
    environment  = var.environment
  }
  # s3_bucket_name = "nanny-goat-labs-${random_integer.s3.result}"

  s3_bucket_name = "${lower(local.naming_prefix)}-${random_integer.s3.result}"

  website_content = {
    website = "/website/index.html"
    graphic = "/website/graphic.png"
  }

  naming_prefix = "${var.naming_prefix}-${var.environment}"
}

resource "random_integer" "s3" {
  min = 10000
  max = 99999
}
