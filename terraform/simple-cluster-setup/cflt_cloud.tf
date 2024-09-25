# Confluent Cloud Environment 
resource "confluent_environment" "simple_env" {

  # this is the name of your env
  display_name = "${var.use_prefix}${var.cc_env_name}-${random_id.id.hex}"

  stream_governance {
    # here you define the packaged only
    # the region will be automatically selected based on the first cluster being deployed
    package = "ESSENTIALS"
    # package = "ADVANCED"
  }

  lifecycle {
    prevent_destroy = false
  }
}

output "simple_env_id" {
  # e.g. env-xyz123
  value = confluent_environment.simple_env.id
}

# Confluent Cloud Standard Kafka Cluster 
resource "confluent_kafka_cluster" "standard_kafka_cluster" {
  display_name = "${var.use_prefix}ccgcp_cluster"
  availability = "SINGLE_ZONE"
  cloud        = var.cc_cloud_provider
  region       = var.cc_cloud_region
  
  standard {
  }

  environment {
    id = confluent_environment.simple_env.id
  }
  lifecycle {
    prevent_destroy = false
  }
}

output "standard_kafka_cluster_id" {
  # e.g. lkc-xyz456
  value = confluent_kafka_cluster.standard_kafka_cluster.id
}

data "confluent_schema_registry_cluster" "sr_cluster" {
  environment {
    id = confluent_environment.simple_env.id
  }
  depends_on = [
    # depends on the first kafka cluster creation as
    # schema registry is automatically created in the 
    # same region if the stream governance package is set on env level
    confluent_kafka_cluster.standard_kafka_cluster
  ]
}

output "sr_cluster_id" {
  # e.g. lsrc-xyz789
  value = data.confluent_schema_registry_cluster.sr_cluster.id
}
