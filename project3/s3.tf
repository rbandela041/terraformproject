# Generate a random number (4 digits)
resource "random_integer" "gigabyte" {
  count = 3
  min = 1000
  max = 9999
}

# Create a DynamoDB table (for example, used for Terraform state locking)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-${random_integer.gigabyte[0].result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "local.dynamo_db"
    Environment = "local.env"
  }
}

# Create 3 S3 buckets using count
resource "aws_s3_bucket" "gigabyte" {
  count  = 3
  bucket = join("-", [local.s3_bucket, terraform.workspace, random_integer.gigabyte[count.index].result])

  depends_on = [aws_dynamodb_table.terraform_locks]

  tags = {
    Name        = join("-", [local.s3_bucket, terraform.workspace, random_integer.gigabyte[count.index].result])
    Environment = local.env
  }
}

