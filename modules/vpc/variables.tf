variable "name" {
  type        = string
  description = "Name for VPC"
}

variable "your_name" {
  type        = string
  description = "Your name, each resources will have this to identify"
}

variable "cidr_block" {
  type        = string
  description = "CIDR range"
  validation {
    condition     = tonumber(regex("^.*/(\\d+)$", var.cidr_block)[0]) <= 22
    error_message = "VPC CIDR must be less than 22 to generate atleast 4 /24 networks"
  }
}

locals {
  prefix_length = tonumber(regex("^.*/(\\d+)$", var.cidr_block)[0])
  newbits       = 24 - local.prefix_length
}

variable "region" {
  type        = string
  description = "Region where VPC should be deployed"
  default     = "us-east-2"
}

variable "az" {
  type        = list(string)
  description = "az where you want the subnets be created"
  default     = ["us-east-2a", "us-east-2b"]

  validation {
    condition     = length(var.az) >= 2 && (length(var.az) * 2) <= pow(2, 24 - tonumber(regex("^.*/(\\d+)$", var.cidr_block)[0]))
    error_message = "Min is 2 and max is defined by CIDR range"
  }
}

variable "allow_web" {
  type = list(object({
    description = string
  port = number }))
  default = [
    {
      description = "Allow TCP 80 for web traffic"
      port        = 80
    },
    {
      description = "Allow TCP 443 for web traffic"
      port        = 443
  }]
}
