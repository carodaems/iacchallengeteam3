# ECS Security Group
resource "aws_security_group" "ecs" {
  vpc_id = module.vpc.vpc_id

  # Define your security group rules here
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group

resource "aws_security_group" "rds" {
  vpc_id = module.vpc.vpc_id

  # Define your security group rules here
  ingress {
    from_port       = 3306 # Assuming MySQL default port
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id, aws_security_group.ec2.id] # Allow traffic from ECS security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow incoming traffic from any IP
  }

  # Add more ingress rules as needed, depending on your requirements

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
