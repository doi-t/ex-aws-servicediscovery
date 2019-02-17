module "prometheus-server" {
  source = "./modules/prometheus_server"

  resource_prefix  = "${var.resource_prefix}"
  ecs_cluster_id   = "${aws_ecs_cluster.ecs_cluster.id}"
  awslogs_group_id = "${aws_cloudwatch_log_group.ecs_log_driver_awslogs.id}"
}

module "node_exporter" {
  source = "./modules/node_exporter"

  resource_prefix  = "${var.resource_prefix}"
  ecs_cluster_id   = "${aws_ecs_cluster.ecs_cluster.id}"
  sd_namespace_id  = "${aws_service_discovery_private_dns_namespace.ecs_private_service_discovery.id}"
  awslogs_group_id = "${aws_cloudwatch_log_group.ecs_log_driver_awslogs.id}"
}

module "example_worker" {
  source = "./modules/example_worker"

  resource_prefix         = "${var.resource_prefix}"
  ecs_cluster_id          = "${aws_ecs_cluster.ecs_cluster.id}"
  sd_public_namespace_id  = "${aws_service_discovery_public_dns_namespace.ecs_public_service_discovery.id}"
  sd_private_namespace_id = "${aws_service_discovery_private_dns_namespace.ecs_private_service_discovery.id}"
  awslogs_group_id        = "${aws_cloudwatch_log_group.ecs_log_driver_awslogs.id}"
}
