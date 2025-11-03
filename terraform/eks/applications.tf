resource "kubernetes_namespace" "strimzi" {
  metadata {
    name = var.strimzi_namespace
  }
}

resource "helm_release" "strimzi_kafka_operator" {
  name       = "strimzi-kafka-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = var.strimzi_chart_version
  namespace  = kubernetes_namespace.strimzi.metadata[0].name

  depends_on = [
    kubernetes_namespace.strimzi,
    aws_eks_node_group.node-group
  ]
}

# resource "kubernetes_namespace" "app" {
#   metadata {
#     name = var.kafka_data_shipper_namespace
#   }
# }

resource "helm_release" "kafka_data_shipper" {
  name      = var.kafka_data_shipper_release_name
  chart     = var.kafka_data_shipper_chart_path
  # namespace = kubernetes_namespace.app.metadata[0].name
  namespace  = kubernetes_namespace.strimzi.metadata[0].name


  depends_on = [
    # kubernetes_namespace.app,
    aws_eks_node_group.node-group,
    
  ]
}
