variable "aws_region" {
  type     = string
  default  = "us-east-1"
}

variable "default_vpc_id" {
     type     = string
     default  = "vpc-xxxxxxxxx"
}

variable "public_subnet1_id" {
     type     = string
     default  = "subnet-xxxx"
}

variable "public_subnet2_id" {
     type     = string
     default  = "subnet-xxxxx"
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  type        = string
  default     = "ami-xxxxx"    #us-east-1
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = "YOUR_IAM_ROLE"
}
