module "iam" {
  source = "./iam/"
  environment = "prod"
  iam_identifier = "ci"
}
