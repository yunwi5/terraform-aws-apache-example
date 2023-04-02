data "aws_vpc" "main" {
  id = var.vpc_id
}

resource "aws_security_group" "sg_app_server" {
  name        = "sg_app_server"
  description = "My server security group"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip_with_cidr]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    description      = "outgoing traffic"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

data "template_file" "user_data" {
  template = file("${abspath(path.module)}/userdata.yaml")
}


data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "app_server" {
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [
    aws_security_group.sg_app_server.id,
  ]
  user_data = data.template_file.user_data.rendered

  // execute script/commands on the local machine (get ouptut in the local machine)
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }

  // execute script/commands on the remote ec2 server
  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} >> /home/ec2-user/private_ips.txt"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("~/.ssh/terraform")
    }
  }

  tags = {
    Name = var.server_name
  }
}
