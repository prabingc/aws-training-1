
#
#

#
#getting the AMI id created by packer
#
data "aws_ami" "golden_image" {
  owners      = ["self"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amazon_linux_nginx-*"]
  }
}

#
#getting iam instance profile arn
#
data "aws_iam_instance_profile" "ec2" {
  name = "EC2_role"
}

locals {
  key_value = "capstone_1-${random_string.random.result}"
}
module "vpc" {
  source     = "../modules/vpc"
  name       = "Web_tier_VPC"
  cidr_block = var.cidr_block
  az         = var.az_region
  your_name  = var.user_name
}

resource "aws_lb_target_group" "phase1_tg" {
  name     = "Solution1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}

module "asg" {
  source                      = "terraform-aws-modules/autoscaling/aws"
  version                     = "~> 7.0"
  name                        = "phase1_asg"
  min_size                    = var.asg_min_size
  max_size                    = var.asg_max_size
  desired_capacity            = var.asg_desired_size
  health_check_type           = "ELB"
  vpc_zone_identifier         = module.vpc.private_subnets
  launch_template_name        = "${var.project}-lt"
  launch_template_description = "web alb lt"
  update_default_version      = true
  image_id                    = data.aws_ami.golden_image.id
  instance_type               = var.instance_type
  ebs_optimized               = true
  enable_monitoring           = true
  create_iam_instance_profile = false
  iam_instance_profile_arn    = data.aws_iam_instance_profile.ec2.arn
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp3"
  } }]
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [module.vpc.sg_allow_web]
  }]
  target_group_arns = [aws_lb_target_group.phase1_tg.arn]
}
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.asg.autoscaling_group_name
}
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.asg.autoscaling_group_name
}


module "alb" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "~> 9.0"
  name                       = "public-alb1"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.cidr_block
    }
  }
  security_group_description = "Allow http/https to ALB"
  security_group_name        = "ALB_SG"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.phase1_tg.arn
  }
}
