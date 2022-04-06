output "vpc_id" {
  value = aws_vpc.application_vpc.id
}

output "application_vpc_public_subnet1" {
  value = aws_subnet.application_vpc_public_subnet1.id
}

output "application_vpc_public_subnet2" {
  value = aws_subnet.application_vpc_public_subnet2.id
}

output "application_vpc_private_subnet1" {
  value = aws_subnet.application_vpc_private_subnet1.id
}

output "application_vpc_private_subnet2" {
  value = aws_subnet.application_vpc_private_subnet2.id
}

output "application_vpc_private_subnet3" {
  value = aws_subnet.application_vpc_private_subnet3.id
}

output "application_vpc_private_subnet4" {
  value = aws_subnet.application_vpc_private_subnet4.id
}

output "application_vpc_private_subnet5" {
  value = aws_subnet.application_vpc_private_subnet5.id
}

output "application_vpc_private_subnet6" {
  value = aws_subnet.application_vpc_private_subnet6.id
}