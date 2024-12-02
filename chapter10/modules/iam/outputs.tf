output "credentials" {
  value = <<-EOF
    [${aws_iam_user.user.name}]
    aws_access_key_id = ${aws_iam_access_key.access_key.id}
    aws_secret_access_key = ${aws_iam_access_key.access_key.secret}
  EOF
}