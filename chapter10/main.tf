terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.28"
    }
    local = {
        source = "hashicorp/local"
        version = "~> 2.0"
    }
  }
}

provider "aws" {
    region = "us-west-2"
}

locals {
    # Obtiene todos los archivos de la carpeta policies con la extension json y crea un map con el nombre del archivo y su contenido
    policies = {
        for path in fileset(path.module, "policies/*.json") : basename(path) => file(path)
    }
  policy_mapping = {
    "app1" = {
        policies = [local.policies["app1.json"]]
    },
    "app2" = {
        policies = [local.policies["app2.json"]]
    }
  }
}

module "iam" {
    source = "./modules/iam"
    for_each = local.policy_mapping
    name = each.key
    policies = each.value.policies
}

resource "local_file" "credentials" {
  filename = "credentials"
  content = join("\n", [for m in module.iam : m.credentials])
}