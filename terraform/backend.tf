terraform {
  backend "s3" {
    bucket = "lambdacraft-terraform-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "lambdacraft-terraform-locks"
    encrypt = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "lambdacraft-terraform-state"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }   
    }   
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "lambdacraft-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S" 
  }
}