
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  key_name               = var.key_name
  user_data = <<-EOF
    #!/bin/bash
    set -e

    apt-get update
    apt-get install -y cloud-utils apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    apt-get update
    apt-get install -y docker-ce
    usermod -aG docker ubuntu

    # Install docker-compose
    sudo curl -L https://github.com/docker/compose/releases/download/2.27.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ubuntu

    sudo -u ubuntu git clone https://github.com/ErickMUOSD/deno-drash-realworld-example-app.git /home/ubuntu/deno-drash-realworld-example-app
    chown -R ubuntu:ubuntu /home/ubuntu/deno-drash-realworld-example-app
  EOF



  tags = { Name = var.name }
}