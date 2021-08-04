variable "aws_region" {
  type    = string
  default = "us-east-2"
}
variable "cluster_name" {
  type    = string
  default = "EKS-k8s"
}
variable "environment" {
  type    = string
  default = "production"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "num_subnets" {
  type    = number
  default = 3
}
variable "newbits" {
  type    = number
  default = 8
}
variable "netnum" {
  type    = number
  default = 30
}
variable "common_tags" {
  type = map(string)
  default = {
    installer = "terraform"
    WARNING   = "Do not edit this object manually"
  }
}
variable "common" {
  type = map(string)
  default = {
    any_cidr     = "0.0.0.0/0"
    any_port     = 0
    any_protocol = "-1"
    ssl_port     = 443
    protocol     = "tcp"
  }
}
variable "instance_types" {
  type    = string
  default = "c5.xlarge"
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
