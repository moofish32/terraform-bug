provider "aws" {
  region = "eu-west-1"
  alias = "local"
}

resource "aws_s3_bucket" "destination" {
  provider = "aws.local"
  bucket   = "tf-test-bucket-destination-cowgill"
  region   = "eu-west-1"

  versioning {
    enabled = true
  }
}
output "destination_arn" { value = "${aws_s3_bucket.destination.arn}"}
