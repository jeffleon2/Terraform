variable "name" {
    description = "name of IAM user"
    type = string
}

variable "policies" {
  type = list(string)
}