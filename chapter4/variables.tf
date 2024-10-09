variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  type        = string
}

variable "ssh_keypair" {
  description = "SSH keypair to use for EC2 instance"
  // Null is useful for optional variables that
  // don’t have a meaningful default value. 
  default = null
  type    = string
}


variable "region" {
  description = "AWS region"
  default     = "us-west-2"
  type        = string
}