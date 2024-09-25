# Confluent Cloud Environment 
resource "confluent_environment" "dev" {

  # this is the name of your env
  display_name = "${var.use_prefix}${var.cc_env_name}-${random_id.id.hex}"

  stream_governance {
    # here you define the packaged only
    # the region will be automatically selected based on the first cluster being deployed
    package = "ADVANCED"
  }

  lifecycle {
    prevent_destroy = false
  }
}

output "dev_env_id" {
  # e.g. env-xyz123
  value = confluent_environment.dev.id
}

# Confluent Cloud Standard Kafka Cluster 
resource "confluent_kafka_cluster" "kafka_dev_cluster" {
  display_name = "${var.use_prefix}gcp_dev_cluster"
  availability = "MULTI_ZONE"
  cloud        = var.cc_cloud_provider
  region       = var.cc_cloud_region
  
  standard {}

  environment {
    id = confluent_environment.dev.id
  }
  lifecycle {
    prevent_destroy = false
  }
}

output "kafka_dev_cluster_id" {
  # e.g. lkc-xyz456
  value = confluent_kafka_cluster.kafka_dev_cluster.id
}

data "confluent_schema_registry_cluster" "sr_dev_cluster" {
  environment {
    id = confluent_environment.dev.id
  }
  depends_on = [
    # depends on the first kafka cluster creation as
    # schema registry is automatically created in the 
    # same region if the stream governance package is set on env level
    confluent_kafka_cluster.kafka_dev_cluster
  ]
}

output "sr_dev_cluster_id" {
  # e.g. lsrc-xyz789
  value = data.confluent_schema_registry_cluster.sr_dev_cluster.id
}

# ^^^ same as simple-org-setup-tf

resource "confluent_service_account" "dev-env-manager" {
  display_name = "${var.use_prefix}dev-env-manager-sa"
  description  = "Envrionment manager service account"
}

# Role bindings
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_role_binding
# https://docs.confluent.io/cloud/current/security/access-control/rbac/predefined-rbac-roles.html


# https://docs.confluent.io/cloud/current/security/access-control/rbac/predefined-rbac-roles.html#environmentadmin
resource "confluent_role_binding" "dev-env-manager-env-admin-rb" {
  principal   = "User:${confluent_service_account.dev-env-manager.id}"
  role_name   = "EnvironmentAdmin" 
  crn_pattern = confluent_environment.dev.resource_name
}

# https://docs.confluent.io/cloud/current/security/access-control/rbac/predefined-rbac-roles.html#resourceowner
# resource "confluent_role_binding" "dev-env-manager-sr-owner-rb" {
#   principal   = "User:${confluent_service_account.dev-env-manager.id}"
#   role_name   = "ResourceOwner"
#   crn_pattern = "${data.confluent_schema_registry_cluster.sr_dev_cluster.resource_name}/subject=*"
# }

resource "confluent_api_key" "dev-env-manager-schema-registry-api-key" {
  display_name = "${var.use_prefix}dev-env-manager-schema-registry-api-key"
  description  = "Schema Registry API Key that is owned by 'dev-env-manager' service account"
  owner {
    id          = confluent_service_account.dev-env-manager.id
    api_version = confluent_service_account.dev-env-manager.api_version
    kind        = confluent_service_account.dev-env-manager.kind
  }

  managed_resource {
    id          = data.confluent_schema_registry_cluster.sr_dev_cluster.id
    api_version = data.confluent_schema_registry_cluster.sr_dev_cluster.api_version
    kind        = data.confluent_schema_registry_cluster.sr_dev_cluster.kind

    environment {
      id = confluent_environment.dev.id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_api_key" "dev-env-manager-kafka-api-key" {
  display_name = "${var.use_prefix}dev-env-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'dev-env-manager' service account"
  owner {
    id          = confluent_service_account.dev-env-manager.id
    api_version = confluent_service_account.dev-env-manager.api_version
    kind        = confluent_service_account.dev-env-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.kafka_dev_cluster.id
    api_version = confluent_kafka_cluster.kafka_dev_cluster.api_version
    kind        = confluent_kafka_cluster.kafka_dev_cluster.kind

    environment {
      id = confluent_environment.dev.id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_schema_registry_cluster_config
resource "confluent_schema_registry_cluster_config" "sr_dev_cluster_config" {
  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.sr_dev_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.sr_dev_cluster.rest_endpoint
  # NOTE: if you change this after some schemas have been created using the default, all schemas on the default will be using the new value
  # for schemas where compatibility mode has been set explicitly, changing this value has no impact
  compatibility_level = "FORWARD"
  credentials {
    key    = confluent_api_key.dev-env-manager-schema-registry-api-key.id
    secret = confluent_api_key.dev-env-manager-schema-registry-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

# resources can be created in the main pipeline as follows
# more likely they will be defined as part of a subsequent pipeline (see org-sub/)

# in-place updates, e.g.
# apply -> v1
# add field to orders.avsc file
# apply -> v2
resource "confluent_schema" "orders" {
  subject_name = "orders-value"
  format = "AVRO"
  schema = file("./schemas/orders.avsc")

  schema_registry_cluster {
    id = data.confluent_schema_registry_cluster.sr_dev_cluster.id
  }
  rest_endpoint = data.confluent_schema_registry_cluster.sr_dev_cluster.rest_endpoint
  credentials {
    key    = confluent_api_key.dev-env-manager-schema-registry-api-key.id
    secret = confluent_api_key.dev-env-manager-schema-registry-api-key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}


resource "confluent_kafka_topic" "orders" {
  kafka_cluster {
    id = confluent_kafka_cluster.kafka_dev_cluster.id
  }
  rest_endpoint      = confluent_kafka_cluster.kafka_dev_cluster.rest_endpoint

  topic_name         = "orders"
  partitions_count   = 6
  
  # https://docs.confluent.io/cloud/current/client-apps/topics/manage.html#ak-topic-configurations-for-all-ccloud-cluster-types
  config = {
    "retention.ms" = "-1"
  }

  credentials {
    key    = confluent_api_key.dev-env-manager-kafka-api-key.id
    secret = confluent_api_key.dev-env-manager-kafka-api-key.secret
  }

  lifecycle {
    prevent_destroy = false
  }
}

