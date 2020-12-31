resource "aws_s3_bucket" "tfs-state-anubhav1" {
    bucket = "tfs-state-anubhav.demo2"
    lifecycle {
        prevent_destroy = true
    }
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }

     }

 }
}

resource "aws_dynamodb_table" "tfs-locks" {
    name         = "tfs-state-locking1"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"
    attribute {
      name       = "LockID"
      type       = "S"
    }

}

resource "aws_dynamodb_table" "records-table" {
    name         = "records"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "UserID"
    attribute {
      name       = "UserID"
      type       = "S"
    }

}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAXHUWH2637XZGONJ3"
  secret_key = "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"
}