variable "project_name" {
  default = "apple-part-availability-checker"
  type    = string
}

variable "iam_identity" {
  type = string
}

variable "notifier_email" {
  type = string
}

variable "receiver_emails" {
  type = string
}

variable "part_code" {
  type    = string
  default = "MKGQ3D/A"
}

variable "postal_code" {
  type = string
}

variable "city" {
  type = string
}

variable "aws_region" {
  default = "eu-central-1"
  type    = string
}