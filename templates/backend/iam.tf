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
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_access_policy" {
  name        = "icapital-ecr-read-policy"
  description = "Policy de acesso ao ECR"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:ListImages",
        ],
        Resource  = "*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.icapital_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr_task_policy_attachment" {
  role       = aws_iam_role.icapital_task_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}