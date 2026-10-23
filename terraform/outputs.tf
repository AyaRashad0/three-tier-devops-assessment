output "website_url" {
  description = "Open in a browser after cloud-init completes"
  value       = "http://${aws_instance.web.public_ip}"
}
output "api_url" {
  value = "http://${aws_instance.web.public_ip}/api/message"
}
output "instance_id" { value = aws_instance.web.id }
