data "aws_vpc" "default" {
  default = true
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24", "${var.environment.network_prefix}.103.0/24"]

  tags = {
    Terraform   = "true"
    Environment = var.environment.name
  }
}

resource "aws_instance" "blog" {
  ami           = "ami-785db401"
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog_sg.security_group_id]

  subnet_id = module.blog_vpc.public_subnets[0]

  tags = {
    Name = "blog"
  }
}

module "autoscaling" {
  source              = "terraform-aws-modules/autoscaling/aws"
  name                = "blog"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  vpc_zone_identifier = module.blog_vpc.public_subnets
  security_groups     = [module.blog_sg.security_group_id]
  image_id            = "ami-785db401"
  instance_type       = var.instance_type
}

module "blog_alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "blog-alb"

  vpc_id          = module.blog_vpc.vpc_id
  subnets         = module.blog_vpc.public_subnets
  security_groups = [module.blog_sg.security_group_id]

  target_groups = {
    blog-instance = {
      name_prefix = "blog"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id   = aws_instance.blog.id
    }
  }

  listeners = {
    blog-http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "blog-instance"
      }
    }
  }

  tags = {
    Environment = "dev"
    Project     = "Blog"
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"
  name    = "blog"

  vpc_id = module.blog_vpc.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

}

