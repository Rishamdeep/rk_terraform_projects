# create ecs task execution role which helps in pulling ecr images and pushing logs to cw
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
    })
}
# add policy to task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = var.policy_arn
}

# create task role which helps in logging into container using ssm session manager
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
    })
}
# add policy to task role
resource "aws_iam_role_policy" "exec_policy" {
  name = "exec_policy"
  role = aws_iam_role.ecs_task_role.id
  policy = "${file("task_iam_policy.json")}"
}
