resource "aws_s3_bucket" "ocb_poc_bucket" {
  bucket_prefix = "ocb-poc-"
}


resource "aws_s3_bucket_versioning" "ocb_poc_bucket_versioning" {
  bucket = aws_s3_bucket.ocb_poc_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ocb_poc_bucket_encryption" {
  bucket = aws_s3_bucket.ocb_poc_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
