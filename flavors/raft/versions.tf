terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.8.0"
    }
  }
  required_version = ">= 0.13"
}
