provider "aws" {
   region = var.region
}

resource "aws_security_group" "web_server_sg" {
    name = "web_server_sg"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip, var.jenkins_ip]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
  }
}
// amzn2-ami-kernel-5.10-hvm-2.0.20230119.1-x86_64-gp2
resource "aws_instance" "app-server" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  associate_public_ip_address = true
  key_name = "amazon-linux"
  user_data = file("entry-script.sh")

  tags = {
    Name    = "${var.env_prefix}-WebServer"
    Owner   = "Marharyta Romaniuk"
    Project = "EPAM_project"}
}

output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}
output "ec2_public_ip" {
    value = aws_instance.app-server.public_ip
}
