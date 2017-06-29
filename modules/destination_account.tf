provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "destination" {
  bucket   = "tf-test-bucket-destination-cowgill"
  region   = "eu-west-1"

  versioning {
    enabled = true
  }
}
output "destination_arn" { value = "${aws_s3_bucket.destination.arn}"}
