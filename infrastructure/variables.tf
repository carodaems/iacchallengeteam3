variable "db_username" {
  description = "Database username"
}

variable "db_password" {
  description = "Database password"
}

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "AWS_SESSION_TOKEN" {}


# Data source to retrieve the secret
data "aws_secretsmanager_secret" "gitlab_registry_credentials" {
  name = "ecs/PullPrivateRegistry" # Use the name you chose for the secret
}

# Data source to retrieve the secret version
data "aws_secretsmanager_secret_version" "gitlab_registry_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.gitlab_registry_credentials.id
}

#IAM LabRole
data "aws_iam_role" "lab_role" {
  name = "LabRole" # Replace with the actual name of your IAM role
}
