# Creates a cloudwatch log group used in task def for container logs
resource "aws_cloudwatch_log_group" "cloudwatch_group" {
  name_prefix = "cloudwatch_group"
}

# Creates an ecs cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}

# Creates task definition
resource "aws_ecs_task_definition" "ecs_task_def" {
  family = "ecs_task_def"
  cpu = 1024
  memory = 2048
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }
  network_mode = "awsvpc"
  container_definitions = templatefile("${path.module}/templates/container_def.tftpl", {
        container_name = var.container_name
        image_url = var.image_url
        cloudwatch_group = aws_cloudwatch_log_group.cloudwatch_group.name
    })
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
}

# Creates ecs service
resource "aws_ecs_service" "ecs_service" {
  name = var.ecs_name
  cluster = aws_ecs_cluster.ecs_cluster.arn
  desired_count = 1
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
  network_configuration {
    subnets = var.subnets
    assign_public_ip = true
    security_groups = [aws_security_group.ecs_security_group.id]
  }
  launch_type = "FARGATE"
  enable_execute_command = true
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name = "httpd"
    container_port = 80
  }
}

# Creates autoscaling target targeting ecs service
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity = 4
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

# create autoscaling policy for autoscaling target
resource "aws_appautoscaling_policy" "ecs_policy" {
  name = "ecs_policy"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 80
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}