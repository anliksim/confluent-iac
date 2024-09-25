# Simple org setup

Org setup in two different pipelines.

`org-sub` depends on `org-main`

## Setup

Main pipeline

```sh
cd org-main

terraform init

cat > terraform.tfvars <<EOF
confluent_cloud_api_key = "{Cloud API Key}"
confluent_cloud_api_secret = "{Cloud API Key Secret}"
use_prefix = "{Your resource prefix}"
EOF
```

Subsequent pipeline

```sh
cd org-main

terraform init

cat > terraform.tfvars <<EOF
confluent_cloud_api_key = "{Cloud API Key}"
confluent_cloud_api_secret = "{Cloud API Key Secret}"
kafka_id = "{Kafka cluster ID}"
kafka_rest_endpoint = "{Kafka cluster endpoint}"
kafka_api_key = "{Kafka API Key}"
kafka_api_secret = "{Kafka API Key Secret}"
schema_registry_id = "{Schema Registry cluster ID}"
schema_registry_rest_endpoint = "{Schema Registry cluster endpoint}"
schema_registry_api_key = "{Schema Registry API Key}"
schema_registry_api_secret = "{Schema Registry API Key Secret}"
use_prefix = "{Your resource prefix}"
EOF
```