# Confluent IaC

Infrastructure-as-Code for Confluent Cloud resources.

## Terraform

For official Confluent terraform provider examples, see [Terraform Provider for Confluent / Examples](https://github.com/confluentinc/terraform-provider-confluent/tree/master/examples/configurations).

For Policy-as-Code examples using Terraform Sentinel, see [Confluent Sentinel Policies for Terraform](https://github.com/confluentinc/policy-library-confluent-terraform).


## Cloud API Key

To run pipelines against Confluent Cloud, a Cloud API key is required.

Generate a Cloud API key in the UI or use the confluent CLI:

```sh
confluent login
confluent api-key create --resource cloud --description "Cloud API key for terraform"
```
