terraform {
  required_version = ">=1.4.0"
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.18.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = ">=1.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.55.0"
    }
  }
}