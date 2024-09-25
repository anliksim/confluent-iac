locals {
  description = "Resource created using terraform"
}

resource "random_id" "id" {
  byte_length = 4
}

variable "use_prefix" {
  description = "If a common organization is being used, and default names are not updated, choose a prefix"
  type        = string
}

variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "cc_cloud_provider" {
  type    = string
  default = "GCP"
}

variable "cc_cloud_region" {
  type    = string
  default = "europe-west1"
}

variable "cc_env_name" {
  type    = string
  default = "simple"
}
