# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Create NAT gateway for outgoing access to the internet
  # Automatically creates the necessary routing tables
  enable_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# S3 Bucket
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "s3-bucket-flasklib"

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Dev"
  }
}

# Upload lms.sql to S3 Bucket
resource "aws_s3_object" "lms_sql" {
  bucket = aws_s3_bucket.my_s3_bucket.bucket
  key    = "lms.sql"
  source = "../application/library-management-system/db/lms.sql"

  acl = "private"
}

# ECS Task Definition

resource "aws_ecs_task_definition" "lms" {
  family                   = "lms"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = data.aws_iam_role.lab_role.arn
  container_definitions = jsonencode([{
    name  = "lms"
    image = "registry.gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/iac-team-3/aws-iac-challenge-team-3:latest" # Use latest built image
    repositoryCredentials = {
      credentialsParameter = data.aws_secretsmanager_secret.gitlab_registry_credentials.arn
    }

    environment = [
      {
        "name" : "DB_HOST",
        "value" : aws_db_instance.flask_db.address
      },
      {
        "name" : "DB_USER",
        "value" : var.db_username
      },
      {
        "name" : "DB_PASSWORD",
        "value" : var.db_password
      },
      {
        "name" : "DB_NAME",
        "value" : "flask"
      }
    ]

    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
    }]
  }])

  depends_on = [aws_instance.sql_execution_instance]
}

# ECS Cluster

resource "aws_ecs_cluster" "my_cluster" {
  name = "team3-ecs-cluster"
}

# ECS Service

resource "aws_ecs_service" "lms" {
  name            = "lms"
  cluster         = aws_ecs_cluster.my_cluster.name
  task_definition = aws_ecs_task_definition.lms.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  depends_on = [aws_ecs_cluster.my_cluster]

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "lms"
    container_port   = 5000 # Port on which your Flask app is running inside the container
  }
}

# ALB

resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets # Deploy ALB in public subnets

  enable_deletion_protection = false

  enable_http2                     = true
  idle_timeout                     = 60
  enable_cross_zone_load_balancing = false
}

# ALB Target Group

resource "aws_lb_target_group" "ecs_target_group" {
  name        = "ecs-target-group"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }
}

# ALB Listener

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    type             = "forward"
  }
}

# DB Subnet Group

resource "aws_db_subnet_group" "flask_db_subnet_group" {
  name        = "flask-db-subnet-group"
  description = "Subnet group for Flask DB"
  subnet_ids  = module.vpc.private_subnets

}

# RDS

resource "aws_db_instance" "flask_db" {
  identifier              = "flaskdbterraform"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  username                = var.db_username
  password                = var.db_password # Replace with a secure password
  parameter_group_name    = "default.mysql5.7"
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 7
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.flask_db_subnet_group.name # Reference to the subnet group created above

  tags = {
    Name        = "MyDBInstance"
    Environment = "Dev"
  }

}
# etc.
