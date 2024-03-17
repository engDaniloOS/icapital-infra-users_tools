# Cluster já existente
data "aws_ecs_cluster" "icapital_cluster" {
  cluster_name = "icapital-user-tools"
}

# Recurso de dados para acessar o ECR criado em outro arquivo Terraform
data "aws_ecr_repository" "icapital_users_tools_ecr" {
  name = "icapital-users-tools"
}

# Criar uma role do IAM para a tarefa ECS
resource "aws_iam_role" "icapital_task_role" {
  name = "icapital-task-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "sts:AssumeRole",
        ],
        Resource  = "arn:aws:*:*:*:*"
      }
    ]
  })

  tags = {
    icapital = "true"
  }
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
    icapital = "true"
  }
}

resource "aws_ecs_service" "service" {
  name            = "icapital-service"
  cluster         = data.aws_ecs_cluster.icapital_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1

  tags = {
    icapital = "true"
  }
}
