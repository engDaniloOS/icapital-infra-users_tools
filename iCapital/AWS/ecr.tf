resource "aws_ecr_repository" "icapital_users_tools" {
  name                 = "icapital-users-tools"
}

# Política de permissão para manter o registro privado
resource "aws_ecr_repository_policy" "icapital_users_tools_policy" {
  repository = aws_ecr_repository.icapital_users_tools.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPushPull",
        Effect    = "Allow",
        Principal = "*",
        Action    = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}
