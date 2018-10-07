resource "aws_service_discovery_private_dns_namespace" "ecs_private_service_discovery" {
  name        = "${var.resource_prefix}-ecs.private.service-discovery.local"
  description = "Amazon ECS Service Discovery for prometheus service that is availabe only in VPC network"
  vpc         = "${module.vpc.vpc_id}"
}

resource "aws_service_discovery_service" "prometheus" {
  name = "prometheus"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.ecs_private_service_discovery.id}"

    dns_records {
      ttl  = 10
      type = "SRV" # NOTE: 'A' DNS record is not supported when specifying 'host' or 'bridge' for networkMode.
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "node_exporter" {
  name = "node-exporter"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.ecs_private_service_discovery.id}"

    dns_records {
      ttl  = 10
      type = "SRV" # NOTE: 'A' DNS record is not supported when specifying 'host' or 'bridge' for networkMode.
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
