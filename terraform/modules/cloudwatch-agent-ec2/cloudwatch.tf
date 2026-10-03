# ----------------------------------------
# CloudWatch Logs
# ----------------------------------------
# エージェントに作らせず Terraform で作る。保持期間を揃え、destroy で消えるようにするため
resource "aws_cloudwatch_log_group" "syslog" {
  name              = "/${var.env}/${var.service_name}/syslog"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/${var.env}/${var.service_name}/audit"
  retention_in_days = var.log_retention_in_days
}
