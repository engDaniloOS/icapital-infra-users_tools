##Criação do bucket para servir arquivos estáticos
resource "aws_s3_bucket" "static_site_users_tools"{
    bucket = "static-site-${var.bucket_name}"

    website {
      index_document = "index.html"
      error_document = "error.html"
    }

    tags = var.default_tags
}

##ABC
##Configuração para liberar acesso ao público
resource "aws_s3_bucket_public_access_block" "static_site_users_tools" {
  bucket = aws_s3_bucket.static_site_users_tools.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

##Concede ao proprietário controle total sobre o bucket
resource "aws_s3_bucket_ownership_controls" "static_site_users_tools" {
  bucket = aws_s3_bucket.static_site_users_tools.id

  rule{ 
    object_ownership = "BucketOwnerPreferred"
    }
}

##Anexa a política de acesso público
resource "aws_s3_bucket_acl" "static_site_users_tools" {
  bucket = aws_s3_bucket.static_site_users_tools.id
  acl = "public-read"

  depends_on = [ 
    aws_s3_bucket_public_access_block.static_site_users_tools, 
    aws_s3_bucket_ownership_controls.static_site_users_tools 
  ]
}

##OK