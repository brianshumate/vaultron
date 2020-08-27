terraform {
  required_providers {
    docker = {
      source = "terraform-providers/docker"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}
