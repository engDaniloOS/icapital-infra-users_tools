# Recurso de dados para acessar o ECR criado em outro arquivo Terraform
data "aws_ecr_repository" "icapital_users_tools_ecr" {
  name = "icapital-users-tools"
}

resource "aws_ecs_cluster" "icapital_user_tools" {
  name    = "icapital-user-tools"
  
  tags = {
    feat = "icapital-users-tools"
  }
}

resource "aws_iam_role" "icapital_task_role" {
  name = "icapital-task-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
        Action    = "sts:AssumeRole",
      },
    ],
  })

  tags = {
    feat = "icapital-users-tools"
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name = "icapital-ecs-task-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.icapital_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

#Task definitions
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "icapital-task"
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]

  execution_role_arn       = aws_iam_role.icapital_task_role.arn  # Usar a role criada acima
  task_role_arn            = aws_iam_role.icapital_task_role.arn      # Usar a role da tarefa criada acima

  container_definitions = jsonencode([
    {
      name      = "users_tools",
      image     = data.aws_ecr_repository.icapital_users_tools_ecr.repository_url
      cpu       = 512,
      memory    = 1024,
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp",
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
  subnets            = ["subnet-0f07f205ca006e580", "subnet-04b05459f32d1b31f"]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "target_group" {
  name     = "icapital-service-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "vpc-0b3d7c2f0a9a183c3"
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

resource "aws_ecs_service" "service" {
  name            = "icapital-service"
  cluster         = aws_ecs_cluster.icapital_user_tools.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1

  network_configuration {
    subnets = ["subnet-0f07f205ca006e580", "subnet-04b05459f32d1b31f"]
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
