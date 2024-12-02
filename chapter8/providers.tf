provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

provider "google" {
  project = "terraform-in-action-438119"
  region  = "us-east1"
}

provider "docker" {}