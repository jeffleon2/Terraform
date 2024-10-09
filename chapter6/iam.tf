data "aws_caller_identity" "current" {}

locals {
  principal_arns = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]
}

# Se pasa en el ARN los usuarios que pueden asumir este role
resource "aws_iam_role" "iam_role" {
  name = "${local.namespace}-tf-assume-role"

  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                    "AWS": ${jsonencode(local.principal_arns)}
                },
                "Effect": "Allow"
            }
        ]
    }
  EOF

  tags = {
    ResourceGroup = local.namespace
  }
}

# se agrega una politica para ser usada con dynamo y s3
data "aws_iam_policy_document" "policy_doc" {
    statement {
        actions = [
            "s3:ListBucket",
        ]
        resources = [
            aws_s3_bucket.s3_bucket.arn
        ]
    }

    statement {
      actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
      resources = [
        "${aws_s3_bucket.s3_bucket.arn}/*"
      ]
    }

    statement {
      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ]
      resources = [aws_dynamodb_table.dynamodb_table.arn]
    }

}

# El path se utiliza para organizar las políticas en un espacio de nombres jerárquico dentro de AWS
resource "aws_iam_policy" "iam_policy" {
  name = "${local.namespace}-tf-policy"
  path = "/"
  policy = data.aws_iam_policy_document.policy_doc.json
}

# Se hace attach de la politica dentro del rol
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}