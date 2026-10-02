output "instance_id" {
  value = aws_instance.this.id
}

output "log_group_names" {
  value = {
    syslog = aws_cloudwatch_log_group.syslog.name
    audit  = aws_cloudwatch_log_group.audit.name
  }
}
