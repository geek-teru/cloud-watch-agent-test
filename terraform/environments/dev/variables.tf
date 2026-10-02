variable "env" {
  type    = string
  default = "dev"
}

variable "service_name" {
  type    = string
  default = "cloud-watch-agent-test"
}

data "aws_caller_identity" "current" {}
