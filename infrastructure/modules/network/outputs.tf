output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.my_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the VPC."
  value       = aws_vpc.my_vpc.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the VPC."
  value       = var.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the public subnets in Availability Zone order."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.public[availability_zone].id
  ]
}

output "private_application_subnet_ids" {
  description = "IDs of the private application subnets."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.private_application[availability_zone].id
  ]
}

output "isolated_database_subnet_ids" {
  description = "IDs of the isolated database subnets."
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.isolated_database[availability_zone].id
  ]
}

output "nat_gateway_ids" {
  description = "IDs of the NAT gateways."
  value       = values(aws_nat_gateway.nat_gateway)[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.internet_gateway.id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log, if enabled."
  value       = try(aws_flow_log.vpc_flow_log[0].id, null)
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch log-group name for VPC Flow Logs."
  value       = try(aws_cloudwatch_log_group.vpc_flow_logs[0].name, null)
}