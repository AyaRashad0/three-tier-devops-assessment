variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}
variable "instance_type" {
  description = "EC2 size; t3.small can incur charges"
  type        = string
  default     = "t3.small"
}
variable "project" {
  type    = string
  default = "hello-devops"
}
