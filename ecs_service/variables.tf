variable "cluster_name" {
  type = string
  default = "your-cluster-name"
}

variable "ecs_name" {
  type = string
  default = "your-ecs-service-name"
}

variable "image_url" {
  type = string
  default = "public.ecr.aws/docker/library/httpd:latest"
}

variable "container_name" {
  type = string
  default = "your-container-name"
}

variable "policy_arn" {
  type = string
  default = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "subnets" {
  type = list(string)
  default = ["your-subnet-1-id","your-subnet-2-id"]
}


variable "vpc" {
  type = string
  default = "your-vpc-id"
}