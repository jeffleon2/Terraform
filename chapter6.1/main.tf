terraform {
  backend "s3" {
    bucket = "terraform-in-action-jl"
    key = "team1/my-cool-project"
    region = "us-west-2"
    encrypt = true
  }

  required_version = ">= 0.15"
}

variable "region" {
  description = "AWS Region"
  type = string
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }
    owners = ["099720109477"]
}


resource "aws_instance" "instance" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
    Name = terraform.workspace
  }
}
