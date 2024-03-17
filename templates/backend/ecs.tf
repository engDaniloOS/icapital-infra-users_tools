resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family = "api-indices"
  container_definitions = ""
  # Defina sua configuração de task aqui
}

resource "aws_lb" "example" {
  name               = "example-nlb"
  internal           = false
  load_balancer_type = "network"
}

resource "aws_lb_target_group" "example" {
  name     = "example-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = "your_vpc_id"
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.example.arn
    type             = "forward"
  }
}

resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["your_subnet_ids"]
    security_groups  = ["your_security_group_ids"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "your_container_name"
    container_port   = 80
  }
}