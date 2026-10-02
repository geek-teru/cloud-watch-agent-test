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

# ----------------------------------------
# CloudWatch Agent Config
# ----------------------------------------
# CloudWatchAgentServerPolicy が読めるのは AmazonCloudWatch-* のパラメータだけなので、名前はこの接頭辞で始める
resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name = "AmazonCloudWatch-${var.env}-${var.service_name}"
  type = "String"
  value = jsonencode({
    agent = {
      # audit.log は root:root 0600 なので root で読む
      run_as_user = "root"
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/messages"
              log_group_name  = aws_cloudwatch_log_group.syslog.name
              log_stream_name = "{instance_id}"
            },
            {
              file_path       = "/var/log/audit/audit.log"
              log_group_name  = aws_cloudwatch_log_group.audit.name
              log_stream_name = "{instance_id}"
            },
          ]
        }
      }
    }
  })
}
