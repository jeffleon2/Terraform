resource "aws_iam_user" "user" {
  name = "${var.name}-svc-account"
  force_destroy = true
}

resource "aws_iam_policy" "policy" {
    count = length(var.policies)
    name = "${var.name}-policy-${count.index}"
    policy = var.policies[count.index]
}

resource "aws_iam_user_policy_attachment" "attachment" {
  count = length(var.policies)
  user = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy[count.index].arn
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}
