# Recurso Amazon CloudFront Distribution
resource "aws_cloudfront_distribution" "example" {
  origin {
    domain_name = aws_s3_bucket.example.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.example.id}"
  }

  enabled             = true
  default_root_object = "index.html"  # Página padrão a ser servida
  price_class         = "PriceClass_200"  # Classe de preço (opcional)

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.example.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Configurações opcionais
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Certificado SSL opcional
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}