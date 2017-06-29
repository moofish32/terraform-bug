provider "aws" {
  region = "eu-central-1"
}


module "destination_bucket" {
  source = "modules"
}

resource "aws_iam_role" "replication" {
  name = "tf-iam-role-replication-12345"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "tf-iam-role-policy-replication-12345"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${module.destination_bucket.destination_arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "tf-iam-role-attachment-replication-12345"
  roles      = ["${aws_iam_role.replication.name}"]
  policy_arn = "${aws_iam_policy.replication.arn}"
}

resource "aws_s3_bucket" "bucket" {
  bucket   = "tf-test-bucket-12345-cowgill"
  acl      = "private"
  region   = "eu-central-1"

  versioning {
    enabled = true
  }

  replication_configuration {
    role = "${aws_iam_role.replication.arn}"

    rules {
      id     = "foobar"
      prefix = "foo"
      status = "Enabled"

      destination {
        bucket        = "${module.destination_bucket.destination_arn}"
        storage_class = "STANDARD"
      }
    }
  }
}



