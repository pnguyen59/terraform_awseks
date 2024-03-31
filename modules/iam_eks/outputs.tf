output "iam_arn" {
  description = "The ARN of IAM"
  value       = aws_iam_role.iam.arn
}

output "iam_name" {
  description = "The ARN of IAM"
  value       = aws_iam_role.iam.name
}
