# Confluent IaC

Infrastructure as Code for Confluent Cloud resources.


## Cloud API Key

To run pipelines against Confluent Cloud, a Cloud API key is required.

Generate a Cloud API key in the UI or use the confluent CLI:

```sh
confluent login
confluent api-key create --resource cloud --description "Cloud API key for terraform"
```
