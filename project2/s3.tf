# Generate a random number (4 digits)
resource "random_integer" "gigabyte" {
  min = 1000
  max = 9999
}

# Create a DynamoDB table (for example, used for Terraform state locking)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-${random_integer.gigabyte.result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Locks Table"
    Environment = "Dev"
  }
}

# Create 3 S3 buckets using count
resource "aws_s3_bucket" "gigabyte" {
  count  = 3
  bucket = "my-bucket-${random_integer.gigabyte.result}-${count.index}"

  depends_on = [aws_dynamodb_table.terraform_locks]

  tags = {
    Name        = "gigabyte ${count.index}"
    Environment = "Dev"
  }
}
