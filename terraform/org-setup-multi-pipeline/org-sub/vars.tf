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

variable "cc_dev_env_id" {
  type    = string
  default = "env-8gwr50"
}

variable "cc_dev_env_manager_sa_id" {
  type    = string
  default = "sa-gdryd1"
}

variable "cc_cloud_provider" {
  type    = string
  default = "GCP"
}

variable "cc_cloud_region" {
  type    = string
  default = "europe-west1"
}

variable "kafka_id" {
  description = "Kafka Cluster ID"
  type        = string 
}

variable "kafka_rest_endpoint" {
  description = "Kafka Cluster Rest Endpoint"
  type        = string 
}

variable "kafka_api_key" {
  description = "Kafka Cluster API key"
  type        = string 
}

variable "kafka_api_secret" {
  description = "Kafka Cluster API Secret"
  type        = string
  sensitive   = true
}

variable "schema_registry_id" {
  description = "Schema Registry ID"
  type        = string 
}

variable "schema_registry_rest_endpoint" {
  description = "Schema Registry Rest Endpoint"
  type        = string 
}

variable "schema_registry_api_key" {
  description = "Schema Registry API key"
  type        = string 
}

variable "schema_registry_api_secret" {
  description = "Schema Registry API Secret"
  type        = string
  sensitive   = true
}
