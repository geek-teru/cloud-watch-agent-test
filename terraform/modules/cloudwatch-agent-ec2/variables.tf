variable "env" {
  type = string
}

variable "service_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "インスタンスを置くサブネット。CloudWatch Logs / SSM へ出られる（NAT 経由など）こと"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "log_retention_in_days" {
  type    = number
  default = 30
}
