variable "iam_identifier" {
  type        = string
  description = "A unique purposeful identifier for the iam entities. Example: ci, myorg etc"
}

variable "environment" {
  type        = string
  description = "An environment identifier for the terraform iam entities"
}

