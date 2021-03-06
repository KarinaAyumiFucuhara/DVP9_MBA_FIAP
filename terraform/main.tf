provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-09d56f8956ab235b3"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.Jenkins.id}"]
  key_name  = var.KEY_NAME

  tags = {
    Name = "Jenkins3"
    env  = "Helder"
  }
}

#Criação do security group com as portas necessárias para o funcionamento do Jenkins
resource "aws_security_group" "Jenkins" {
  name        = "Jenkins"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  #Ansible remote command
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  #Jenkins Web
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  #Prometeus Agent
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    env = "Helder"
  }
}

#Criação do LB para HA
resource "aws_elb" "elb_jenkins" {
  name = "elb-Jenkins"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  security_groups = ["${aws_security_group.Jenkins.id}"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 6
  }
}
