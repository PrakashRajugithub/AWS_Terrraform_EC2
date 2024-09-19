data "aws_availability_zones" "available" {
  state = "available"
}

output "zones" {
  value = data.aws_availability_zones.available.names
}

output "ec2-1-pubIP" {
  value = aws_instance.ec2-instance1.public_ip
}

output "ec2-2-pubIP" {
  value = aws_instance.ec2-instance2.public_ip
}

output "ec2-1-pubDNS" {
  value = aws_instance.ec2-instance1.public_dns
}

output "ec2-2-pubDNS" {
  value = aws_instance.ec2-instance2.public_dns
}

# output "ALB-DNS" {
#   value = aws_lb.my_alb.public_dns
# }