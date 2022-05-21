terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-09d56f8956ab235b3"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-http.id}"]
  key_name  = "${var.KEY_NAME}"

  tags = {
    Name = "Jenkins3"
    env  = "Helder"
  }
}

resource "aws_security_group" "allow-ssh-http" {
  name        = "allow-ssh-http"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
    env = "Helder"
  }
}
