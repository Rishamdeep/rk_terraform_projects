variable "bucket_name" {
  type = string
  default = "your-bucket-name"
}

variable "repository_name" {
    type = string
    default = "your-codecommit-repo"
}

variable "image" {
    type = string
    default = "your-image"
}

variable "ecr_repository_name" {
    type = string
    default = "your-ecr-repo"
}