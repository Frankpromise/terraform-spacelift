output "public-ip" {
  value = aws_instance.prom-server.public_ip
}