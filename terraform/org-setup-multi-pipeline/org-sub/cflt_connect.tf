resource "confluent_kafka_topic" "shoe_orders" {
  topic_name    = "shoe_orders"
  partitions_count   = 1

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_service_account" "connectors" {
  display_name = "${var.use_prefix}connectors-${random_id.id.hex}"
  description  = local.description
  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_kafka_acl" "connectors_source_describe_cluster" {
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  host          = "*"

  lifecycle {
    prevent_destroy = false
  }
}


resource "confluent_kafka_acl" "connectors_source_create_topic_demo" {
  resource_type = "TOPIC"
  resource_name = "shoe_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "CREATE"
  permission    = "ALLOW"
  host          = "*"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_kafka_acl" "connectors_source_write_topic_demo" {
  resource_type = "TOPIC"
  resource_name = "shoe_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "WRITE"
  permission    = "ALLOW"
  host          = "*"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_kafka_acl" "connectors_source_read_topic_demo" {
  resource_type = "TOPIC"
  resource_name = "shoe_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"

  lifecycle {
    prevent_destroy = false
  }
}

# DLQ topics (for the connectors)
resource "confluent_kafka_acl" "connectors_source_create_topic_dlq" {
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "CREATE"
  permission    = "ALLOW"
  host          = "*"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_kafka_acl" "connectors_source_write_topic_dlq" {
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "WRITE"
  permission    = "ALLOW"
  host          = "*"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_kafka_acl" "connectors_source_read_topic_dlq" {
  resource_type = "TOPIC"
  resource_name = "dlq-"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"

  lifecycle {
    prevent_destroy = false
  }
}

# Consumer group
resource "confluent_kafka_acl" "connectors_source_consumer_group" {
  resource_type = "GROUP"
  resource_name = "connect"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.connectors.id}"
  operation     = "READ"
  permission    = "ALLOW"
  host          = "*"

  lifecycle {
    prevent_destroy = false
  }
}

data "confluent_kafka_cluster" "dev_cluster" {
  id = var.kafka_id
  environment {
    id = var.cc_dev_env_id
  }
}

resource "confluent_api_key" "connector_key" {
  display_name = "${var.use_prefix}connector-dev-cluster-key-${random_id.id.hex}"
  description  = local.description
  owner {
    id          = confluent_service_account.connectors.id
    api_version = confluent_service_account.connectors.api_version
    kind        = confluent_service_account.connectors.kind
  }
  managed_resource {
    id          = data.confluent_kafka_cluster.dev_cluster.id
    api_version = data.confluent_kafka_cluster.dev_cluster.api_version
    kind        = data.confluent_kafka_cluster.dev_cluster.kind
    environment {
      id = var.cc_dev_env_id
    }
  }
  depends_on = [
    confluent_kafka_acl.connectors_source_create_topic_demo,
    confluent_kafka_acl.connectors_source_write_topic_demo,
    confluent_kafka_acl.connectors_source_read_topic_demo,
    confluent_kafka_acl.connectors_source_create_topic_dlq,
    confluent_kafka_acl.connectors_source_write_topic_dlq,
    confluent_kafka_acl.connectors_source_read_topic_dlq,
    confluent_kafka_acl.connectors_source_consumer_group,
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Connectors
# --------------------------------------------------------

# https://github.com/confluentinc/kafka-connect-datagen/tree/master/src/main/resources
# datagen_orders
resource "confluent_connector" "datagen_orders" {
  environment {
    id = var.cc_dev_env_id
  }
  kafka_cluster {
    id = var.kafka_id
  }
  config_sensitive = {}
  config_nonsensitive = {
    "connector.class"          = "DatagenSource"
    "name"                     = "${var.use_prefix}OrdersDatagenConnector"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.connectors.id
    "kafka.topic"              = confluent_kafka_topic.shoe_orders.topic_name
    "output.data.format"       = "AVRO"
    "quickstart"               = "SHOE_ORDERS"
    "tasks.max"                = "1"
    "max.interval"             = "500"
  }
  depends_on = [
    confluent_kafka_acl.connectors_source_create_topic_demo,
    confluent_kafka_acl.connectors_source_write_topic_demo,
    confluent_kafka_acl.connectors_source_read_topic_demo,
    confluent_kafka_acl.connectors_source_create_topic_dlq,
    confluent_kafka_acl.connectors_source_write_topic_dlq,
    confluent_kafka_acl.connectors_source_read_topic_dlq,
    confluent_kafka_acl.connectors_source_consumer_group,
  ]
  lifecycle {
    prevent_destroy = false
  }
}