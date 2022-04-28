terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.16.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.1.1"  
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
  required_version = ">= 0.13"
}
