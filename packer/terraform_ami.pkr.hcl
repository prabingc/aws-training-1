packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
variable "region" {
  type    = string
  default = "us-east-2"
}

source "amazon-ebs" "web_servers" {
  region                  = var.region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  instance_type           = "t2.micro"
  ssh_username            = "ec2-user"
  ami_name                = "amazon_linux_nginx-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.web_servers"]

  provisioner "shell" {
    inline = [
      "echo 'giving some time for instance to be ready'",
      "sudo amazon-linux-extras install nginx1",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}