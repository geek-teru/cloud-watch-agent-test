# ----------------------------------------
# Security Group
# ----------------------------------------
# インバウンドは開けない。SSM / CloudWatch Logs へのアウトバウンドだけ
resource "aws_security_group" "ec2" {
  name   = "${var.env}-${var.service_name}-ec2"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.service_name}-ec2"
  }
}

# ----------------------------------------
# EC2 Instance
# ----------------------------------------
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "this" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    config_parameter_name = aws_ssm_parameter.cloudwatch_agent_config.name
  })
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.env}-${var.service_name}-ec2"
  }

  lifecycle {
    # AMI の最新化のたびに作り直さない
    ignore_changes = [ami]
  }

  # エージェント起動時にロール・ロググループ・設定が揃っているようにする
  depends_on = [
    aws_iam_role_policy_attachment.cloudwatch_agent,
    aws_iam_role_policy_attachment.ssm_core,
    aws_cloudwatch_log_group.syslog,
    aws_cloudwatch_log_group.audit,
  ]
}
