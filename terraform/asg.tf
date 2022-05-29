#Criação do Autoscaling Group para HA
resource "aws_autoscaling_group" "jenkins_asg" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.jenkins_template.id
    version = "$Latest"
  }
  
  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
  
  tag {
    key                 = "Key"
    value               = "Value"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}

#Será usado uma ami da Amazon para depois fazer a instalação do Jenkins pelo Ansible
data "aws_ami" "ami_ubuntu" {
  most_recent = true
  owners = ["099720109477"] #amazon
  
  filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

#Launch template que será usado no ASG
resource "aws_launch_template" "jenkins_template" {
  name_prefix   = "jenkins_template"
  image_id      = data.aws_ami.ami_ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.Jenkins.id}"]
  key_name  = var.KEY_NAME
  
}

#Associar o LB no ASG
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.jenkins_asg.id
  elb                    = aws_elb.elb_jenkins.id
}
