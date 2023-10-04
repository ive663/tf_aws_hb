output "subnet_id" {
  description = "nexusRegSub id"
  value = aws_subnet.public-subnet.id
}
output "vpcNexusSG" {
  description = "nexusRegSG id"
  value = aws_security_group.nexusRegSG.id
}
