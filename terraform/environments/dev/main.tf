# ----------------------------------------
# Remote State
# ----------------------------------------
# ネットワークは terraform-aws-cmn-vpc で作った共通 VPC を使う
# https://github.com/geek-teru/terraform-aws-cmn-vpc
data "terraform_remote_state" "cmn_vpc" {
  backend = "s3"

  config = {
    bucket = "${var.env}-terraform-aws"
    key    = "cmn-vpc/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

locals {
  cmn_vpc = data.terraform_remote_state.cmn_vpc.outputs.vpc
}

# ----------------------------------------
# Modules
# ----------------------------------------
module "cloudwatch_agent_ec2" {
  source = "../../modules/cloudwatch-agent-ec2"

  env          = var.env
  service_name = var.service_name

  vpc_id    = local.cmn_vpc.cmn_vpc.id
  subnet_id = local.cmn_vpc.cmn_vpc_priv_subnet_ids[0]
}

output "cloudwatch_agent_ec2" {
  value = module.cloudwatch_agent_ec2
}
