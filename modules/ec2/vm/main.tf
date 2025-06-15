
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  key_name               = var.key_name
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install nginx -y
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = { Name = var.name }
}