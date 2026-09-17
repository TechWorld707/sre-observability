locals {
  common_tags = merge(
    var.tags,
    {
      Module = "service-connect"
    }
  )
}

resource "aws_service_discovery_http_namespace" "application" {
  name        = var.name
  description = var.description

  tags = merge(
    local.common_tags,
    {
      Name = var.name
    }
  )
}