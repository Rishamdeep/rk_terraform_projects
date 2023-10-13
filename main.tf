terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.53.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
}


resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  iam_instance_profile = var.iam_instance_profile
  subnet_id   = var.public_subnet1_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
   tags = {
    Name = "Web server"
  }
  user_data = <<EOF
#!/bin/sh

# Install a LAMP stack
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum -y install httpd php-mbstring

# Start the web server
chkconfig httpd on
systemctl start httpd

# Install the web pages for our lab
if [ ! -f /var/www/html/immersion-day-app-php7.tar.gz ]; then
   cd /var/www/html
   wget https://aws-joozero.s3.ap-northeast-2.amazonaws.com/immersion-day-app-php7.tar.gz  
   tar xvfz immersion-day-app-php7.tar.gz
fi

# Install the AWS SDK for PHP
if [ ! -f /var/www/html/aws.zip ]; then
   cd /var/www/html
   mkdir vendor
   cd vendor
   wget https://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip
   unzip aws.zip
fi

# Update existing packages
yum -y update
EOF
}

resource "aws_ami_from_instance" "asg_ami" {
  name               = "Web server v1"
  source_instance_id = aws_instance.ec2_instance.id
   tags = {
    Name = "Web Server v1"
  }
}

resource "aws_lb" "test" {
  name               = "Web-ALB"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [var.public_subnet1_id, var.public_subnet2_id]

}


resource "aws_lb_target_group" "alb-example" {
  name        = "Web-TG"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id      = var.default_vpc_id
  protocol_version = "HTTP1"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-example.arn
  }
}

resource "aws_launch_template" "lt" {
  name = "web"
  iam_instance_profile {
    name = var.iam_instance_profile
  }
  image_id = aws_ami_from_instance.asg_ami.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
    tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Web Instance"
    }
  }
  # user_data = filebase64("${path.module}/example.sh")
}

resource "aws_autoscaling_group" "asg" {
  name = "Web-ASG"
  vpc_zone_identifier  = [var.public_subnet1_id, var.public_subnet2_id]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Default"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn               = aws_lb_target_group.alb-example.arn
}

resource "aws_autoscaling_policy" "example" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  name                   = "asg_policy"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 20.0
  }
}
#setup dynamo DB as our locking mechanism with s3 remote backend
terraform {
  backend "s3" {
    bucket = "YOUR_S3_Bucket_Name"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "YOUR_DYNAMO_DB_TABLE"
  }
}