# Recurso de dados para acessar o ECR criado em outro arquivo Terraform
data "aws_ecr_repository" "icapital_users_tools_ecr" {
  name = "icapital-users-tools"
}

data "aws_iam_role" "icapital_task_role" {
  name = "icapital-task-role"
}

data "aws_security_group" "cluster_security_group" {
  name        = "cluster_security_group_icapital"
}

data "aws_security_group" "lb_security_group" {
  name        = "lb_security_group_icapital"
}

resource "aws_ecs_cluster" "icapital_user_tools" {
  name    = "icapital-user-tools"
  
  tags = {
    feat = "icapital-users-tools"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "icapital-task"
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = data.aws_iam_role.icapital_task_role.arn
  execution_role_arn       = data.aws_iam_role.icapital_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "users_tools",
      image     = data.aws_ecr_repository.icapital_users_tools_ecr.repository_url
      cpu       = 256,
      memory    = 512,
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "HTTP",
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "user_tools",
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "users_tools",
          "awslogs-create-group"  = "true",
          "awslogs-datetime-format" = "%Y-%m-%dT%H:%M:%SZ",
        },
      }
    },
  ])

  tags = {
    feat = "icapital-users-tools"
  }
}

resource "aws_lb" "public_lb" {
  name               = "icapital-service-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-0949be2fae98dbcd3", "subnet-07fc7292ce47077d1"]
  enable_deletion_protection = false
  security_groups = [ data.aws_security_group.lb_security_group.id ]
}

resource "aws_lb_target_group" "target_group" {
  name     = "icapital-service-target-group"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = "vpc-0b3d7c2f0a9a183c3"
  
  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_cloudwatch_log_group" "user_tools_log_group" {
  name = "user_tools"
}

resource "aws_ecs_service" "service" {
  name            = "icapital-service"
  cluster         = aws_ecs_cluster.icapital_user_tools.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type = "FARGATE"
  
  network_configuration {
    subnets = ["subnet-0949be2fae98dbcd3", "subnet-07fc7292ce47077d1"]
    assign_public_ip = true
    security_groups = [ data.aws_security_group.cluster_security_group.id ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "users_tools"
    container_port   = 8080
  }

  tags = {
    feat = "icapital-users-tools"
  }
}