
variable "cidr" {
  type    = string
  default = "10.10.0.0/22"
}

variable az_region {
    type = list(string)
    default= ['us-east-1a', 'us-east-1b']
}