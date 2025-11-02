# This file was previously empty.
# It now defines the namespaces and Helm releases for your applications.

# 1. Strimzi (Kafka Operator)
# ===========================

# Namespace for Strimzi Kafka Operator
resource "kubernetes_namespace" "strimzi" {
  metadata {
    name = var.strimzi_namespace
  }
}

# Helm release for Strimzi Kafka Operator
resource "helm_release" "strimzi_kafka_operator" {
  name       = "strimzi-kafka-operator"
  repository = "https://strimzi.org/charts/"
  chart      = "strimzi-kafka-operator"
  version    = var.strimzi_chart_version
  namespace  = kubernetes_namespace.strimzi.metadata[0].name

  # Wait for the namespace to be created first
  depends_on = [
    kubernetes_namespace.strimzi
  ]
}

# 2. kafka-data-shipper (Your Application)
# ========================================

# Namespace for your application
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.kafka_data_shipper_namespace
  }
}

# Helm release for your kafka-data-shipper application
resource "helm_release" "kafka_data_shipper" {
  name      = var.kafka_data_shipper_release_name
  # This path is relative to where you run `terraform apply` (the terraform/ directory)
  chart     = var.kafka_data_shipper_chart_path
  namespace = kubernetes_namespace.app.metadata[0].name

  # Wait for the namespace to be created
  depends_on = [
    kubernetes_namespace.app
  ]
}
