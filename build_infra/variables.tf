variable "project" {
  type    = string
  default = "john wick"
}
variable "cidr_block" {
  type    = string
  default = "10.10.0.0/22"
}
variable "az_region" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}
variable "user_name" {
  type    = string
  default = "jonh wick"
}
variable "instance_type" {
  type    = string
  default = "t3.small"
}
variable "asg_min_size" {
  type    = number
  default = 1
}
variable "asg_max_size" {
  type    = number
  default = 2
}
variable "asg_desired_size" {
  type    = number
  default = 1
}
