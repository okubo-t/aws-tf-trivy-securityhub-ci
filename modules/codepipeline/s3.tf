resource "aws_s3_bucket" "artifacts_store" {
  bucket        = "${var.prefix}-${var.env}-codepipeline-${var.Account["region"]}-${data.aws_caller_identity.self.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "artifacts_store" {
  bucket = aws_s3_bucket.artifacts_store.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_store" {
  bucket = aws_s3_bucket.artifacts_store.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.artifacts_store.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "artifacts_store" {
  bucket = aws_s3_bucket.artifacts_store.id
  policy = jsonencode({
    Version : "2012-10-17",
    Id : "SSEAndSSLPolicy",
    Statement : [
      {
        Sid : "DenyUnEncryptedObjectUploads",
        Effect : "Deny",
        Principal : "*",
        Action : "s3:PutObject",
        Resource : "${aws_s3_bucket.artifacts_store.arn}/*",
        Condition : {
          StringNotEquals : {
            "s3:x-amz-server-side-encryption" : "aws:kms"
          }
        }
      },
      {
        Sid : "DenyInsecureConnections",
        Effect : "Deny",
        Principal : "*",
        Action : "s3:*",
        Resource : "${aws_s3_bucket.artifacts_store.arn}/*",
        Condition : {
          Bool : {
            "aws:SecureTransport" : "false"
          }
        }
      },
      {
        Sid : "CodePipelineBucketPolicy",
        Effect : "Allow",
        Principal : {
          AWS : [
            aws_iam_role.codepipeline_codecommit.arn,
            aws_iam_role.codebuild.arn,
        ] },
        Action : [
          "s3:Get*",
          "s3:Put*"
        ],
        Resource : "${aws_s3_bucket.artifacts_store.arn}/*",
      },
      {
        Sid : "CodePipelineBucketListPolicy",
        Effect : "Allow",
        Principal : {
          AWS : [
            aws_iam_role.codepipeline_codecommit.arn,
            aws_iam_role.codebuild.arn,
        ] },
        Action : "s3:ListBucket",
        Resource : aws_s3_bucket.artifacts_store.arn,
      }
    ]
  })
}
