data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

variable "ami_owners" {
  default = ["self", "amazon", "aws-marketplace"]
}

variable "resource_prefix" {
  default = "ex-aws-servicediscovery"
}

variable "s3_bucket_name" {
  default = "ex-aws-servicediscovery"
}

variable "cidr" {
  default = "10.40.0.0/16"
}

variable "public_subnet_cidr_1" {
  default = "10.40.1.0/24"
}

variable "public_subnet_cidr_2" {
  default = "10.40.2.0/24"
}

variable "root_block_device_type" {
  default = "gp2"
}

variable "root_block_device_size" {
  default = "8"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "cpu_credit_specification" {
  description = "The credit option for CPU usage. Can be 'standard' or 'unlimited'."
  default     = "standard"
}

variable "key_name" {}
variable "your_public_ip" {}

variable "health_check_grace_period" {
  default = "600"
}

variable "prometheus_desired_task_count" {
  default = "1"
}

variable "asg_max_size" {
  default = "2"
}

variable "asg_desired_capacity" {
  default = "2"
}

variable "asg_min_size" {
  default = "1"
}

variable "enabled_metrics" {
  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  type = "list"
}

variable "detailed_monitoring" {
  default = false
}
