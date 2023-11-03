# Creates a SG for load balancer
resource "aws_security_group" "lb-security-group" {
  name = "lb-security-group"
  description = "SG for LB that allows traffic from anywhere"
}
# Creates inbound rule for LB SG
resource "aws_vpc_security_group_ingress_rule" "lb-ingress-rule" {
  security_group_id = aws_security_group.lb-security-group.id
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
  cidr_ipv4 = "0.0.0.0/0"
}
resource "aws_vpc_security_group_egress_rule" "lb-egress-rule" {
  security_group_id = aws_security_group.lb-security-group.id
  # from_port = 0
  # to_port = 65535
  ip_protocol = -1
  cidr_ipv4 = "0.0.0.0/0"
}

# Creates a SG for ecs tasks
resource "aws_security_group" "ecs_security_group" {
  name = "ecs-security-group"
  description = "SG for ecs tasks that allows traffic only from LB"
}
# Creates inbound rule for ECS-tasks SG
resource "aws_vpc_security_group_ingress_rule" "ecs-ingress-rule" {
  security_group_id = aws_security_group.ecs_security_group.id
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
  referenced_security_group_id = aws_security_group.lb-security-group.id
}
resource "aws_vpc_security_group_egress_rule" "ecs-egress-rule" {
  security_group_id = aws_security_group.ecs_security_group.id
  # from_port = 80
  # to_port = 80
  ip_protocol = -1
  cidr_ipv4 = "0.0.0.0/0"
}

# Creates a Load Balancer
resource "aws_lb" "elb" {
  name = "ecs-service-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.lb-security-group.id ]
  subnets = var.subnets
}

# Creates a target group
resource "aws_lb_target_group" "ecs_target_group" {
  name = "ecs-target-group"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = var.vpc
}

# Creates a lb listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.elb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}