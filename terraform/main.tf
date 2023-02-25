terraform {
  backend "s3" {
    bucket         = "java-maven-app"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
   region = var.region
}


data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
  }
}

module "security_group" {
  source = "./modules/security_group"
  my_ip = var.my_ip
  jenkins_ip = var.jenkins_ip
  env_prefix = var.env_prefix
}

resource "aws_instance" "app-server" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.security_group.id]
  associate_public_ip_address = true
  key_name = "amazon-linux"
  //user_data = file("entry-script.sh")

  tags = {
    Name    = "${var.env_prefix}-WebServer"
    Owner   = "Marharyta Romaniuk"
    Project = "EPAM_project"
  }
}



