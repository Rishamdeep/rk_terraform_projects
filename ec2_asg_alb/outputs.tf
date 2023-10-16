output "alb_hostname" {
  value = aws_lb.test.dns_name
}

output "ec2_web_server_id" {
  value = aws_instance.ec2_instance.id
}

output "custom_ami_id" {
  value = aws_ami_from_instance.asg_ami.id
}

output "Web_alb_id" {
  value = aws_lb.test.id
}

output "asg_arn" {
  value = aws_autoscaling_group.asg.arn
}

output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

output "target_group_name" {
  value = aws_lb_target_group.alb-example.name
}