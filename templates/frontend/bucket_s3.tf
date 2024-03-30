# Recurso Bucket S3
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-name"
  acl    = "private"  # Permissões de acesso ao bucket
}