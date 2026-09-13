data "aws_partition" "current" {}

locals {
  common_tags = merge(
    var.tags,
    {
      Name   = var.name
      Module = "network"
    }
  )

  availability_zone_map = {
    for index, availability_zone in var.availability_zones :
    availability_zone => index
  }

  nat_gateway_map = var.enable_nat_gateway ? (
    var.single_nat_gateway
    ? {
      (var.availability_zones[0]) = 0
    }
    : local.availability_zone_map
  ) : {}
}

check "subnet_cidr_counts" {
  assert {
    condition = (
      length(var.public_subnet_cidrs) == length(var.availability_zones) &&
      length(var.private_application_subnet_cidrs) == length(var.availability_zones) &&
      length(var.isolated_database_subnet_cidrs) == length(var.availability_zones)
    )

    error_message = "Each subnet CIDR list must contain one CIDR for every Availability Zone."
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = var.name
    }
  )
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  for_each = local.availability_zone_map

  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = each.key
  cidr_block              = var.public_subnet_cidrs[each.value]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-public-${each.key}"
      Tier = "public"
    }
  )
}

resource "aws_subnet" "private_application" {
  for_each = local.availability_zone_map

  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = each.key
  cidr_block              = var.private_application_subnet_cidrs[each.value]
  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-private-application-${each.key}"
      Tier = "private-application"
    }
  )
}

resource "aws_subnet" "isolated_database" {
  for_each = local.availability_zone_map

  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = each.key
  cidr_block              = var.isolated_database_subnet_cidrs[each.value]
  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-isolated-database-${each.key}"
      Tier = "isolated-database"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-public-route-table"
      Tier = "public"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  for_each = local.nat_gateway_map

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-nat-eip-${each.key}"
    }
  )

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = local.nat_gateway_map

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-nat-${each.key}"
    }
  )

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_route_table" "private_application" {
  for_each = local.availability_zone_map

  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-private-application-route-table-${each.key}"
      Tier = "private-application"
    }
  )
}

resource "aws_route" "private_application_internet" {
  for_each = var.enable_nat_gateway ? local.availability_zone_map : {}

  route_table_id         = aws_route_table.private_application[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.single_nat_gateway ? (
    aws_nat_gateway.nat_gateway[var.availability_zones[0]].id
  ) : aws_nat_gateway.nat_gateway[each.key].id
}

resource "aws_route_table_association" "private_application" {
  for_each = aws_subnet.private_application

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_application[each.key].id
}

resource "aws_route_table" "isolated_database" {
  for_each = local.availability_zone_map

  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-isolated-database-route-table-${each.key}"
      Tier = "isolated-database"
    }
  )
}

resource "aws_route_table_association" "isolated_database" {
  for_each = aws_subnet.isolated_database

  subnet_id      = each.value.id
  route_table_id = aws_route_table.isolated_database[each.key].id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${var.name}/flow-logs"
  retention_in_days = var.flow_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-flow-logs"
    }
  )
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.name}-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "vpc_flow_log" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id                   = aws_vpc.my_vpc.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  iam_role_arn             = aws_iam_role.vpc_flow_logs[0].arn
  max_aggregation_interval = 60

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-flow-log"
    }
  )
}