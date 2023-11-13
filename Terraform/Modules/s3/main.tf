resource "aws_s3_bucket" "terraform_state" {
  bucket = "var.s3_bucket_name"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

resource "aws_dynamodb_table" "dynamodb_terraform_state_lock" {
  name           = "var.dynamodb_table_name"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
