

output "vpc_id" {
  description = "ID of created VPC"
  value       = aws_vpc.main.id
}
output "igw_id" {
  description = "IGW ID"
  value       = aws_internet_gateway.igw.id
}

output "natgw_id" {
  description = "NATGW ID"
  value       = aws_nat_gateway.natgw.id
}

output "public_subnets" {
  description = "Subnets associated with IGW"
  value       = aws_subnet.public_subnets[*].id
}
output "private_subnets" {
  description = "Subnets associated with NATGW"
  value       = aws_subnet.private_subnets[*].id
}

output "public_rt" {
  description = "Private route table id"
  value       = aws_route_table.public_rt.id
}

output "private_rt" {
  description = "Private route table id"
  value       = aws_route_table.private_rt.id
}

output "sg_allow_web" {
  description = "SG id that allows all web traffic on 80 and 443"
  value       = aws_security_group.allow_web.id
}

output "bucket_name" {
  description = "bucket name to store state file"
  value       = aws_s3_bucket.state_bucket.id
}
