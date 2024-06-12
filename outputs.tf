output "mongodb_instance_ips" {
  value = [for instance in aws_instance.mongodb : instance.public_ip]
}
