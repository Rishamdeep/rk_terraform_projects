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
  default = "your-image-url"
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
  default = ["your-subnet-id"]
}

variable "security_groups" {
  type = list(string)
  default = ["your-security-group-id"]
}