module "taskrole_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["taskrole"]
  context    = module.this.context
}

resource "aws_iam_role" "taskrole" {
  name = module.taskrole_label.id
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = module.taskrole_label.tags
}

module "taskrole_policy_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["taskrole", "policy"]
  context    = module.this.context
}

resource "aws_iam_role_policy" "taskrole" {
  name = module.taskrole_policy_label.id
  role = aws_iam_role.taskrole.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}

module "executionrole_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["executionrole"]
  context    = module.this.context
}

resource "aws_iam_role" "executionrole" {
  name = module.executionrole_label.id
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = module.executionrole_label.tags
}

module "executionrole_policy_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["executionrole", "policy"]
  context    = module.this.context
}

resource "aws_iam_role_policy" "executionrole" {
  name = module.executionrole_policy_label.id
  role = aws_iam_role.executionrole.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}
