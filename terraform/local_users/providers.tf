# see https://registry.terraform.io/providers/confluentinc/confluent/latest
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.2"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}