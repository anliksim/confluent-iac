resource "confluent_tag" "tag_pii" {
  name = "PII"
  description = "PII tag"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_tag" "tag_ateam" {
  name = "ATeam"
  description = "Tag for the A-Team"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_schema" "test_metadata" {
  subject_name = "test_metadata-value"
  format = "AVRO"
  schema = file("./schemas/test_metadata.avsc")


  lifecycle {
    prevent_destroy = false
  }
}


resource "confluent_kafka_topic" "test_metadata" {
  topic_name = "test_metadata"

  lifecycle {
    prevent_destroy = false
  }
}

# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_catalog_entity_attributes
resource "confluent_catalog_entity_attributes" "test_metadata_attributes" {
  entity_name = "${var.schema_registry_id}:${var.kafka_id}:${confluent_kafka_topic.test_metadata.topic_name}"
  entity_type = "kafka_topic"
  attributes = {
    "owner"       = "user1"
    "description" = "Kafka topic for metadata testing"
    "ownerEmail"  = "user1@example.com"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_tag_binding" "topic-tagging" {
  tag_name = "PII"
  entity_name = "${var.schema_registry_id}:${var.kafka_id}:${confluent_kafka_topic.test_metadata.topic_name}"
  entity_type = "kafka_topic"

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_business_metadata" "meta_team" {
  name = "Team"
  description = "Team metadata"
  attribute_definition {
    name = "team"
  }
  attribute_definition {
    name = "slack"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "confluent_business_metadata_binding" "main" {
 
  business_metadata_name = confluent_business_metadata.meta_team.name
  entity_name = "${var.schema_registry_id}:${var.kafka_id}:${confluent_kafka_topic.test_metadata.topic_name}"
  entity_type = "kafka_topic"
  attributes = {
    "team"    = "ATeam"
    "slack" = "@ateam"
  }
}


