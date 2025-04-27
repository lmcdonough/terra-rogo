output "aws_instance_public_dns" {
  value       = "http://${aws_instance.nginx1.public_dns}"
  description = "the public dns name of the nginx server on the ec2 instance"
}
