#
# ECS Service Discovery (Private)
#

resource "aws_service_discovery_private_dns_namespace" "ecs_private_service_discovery" {
  name        = "${var.resource_prefix}.ecs-service-discovery.local"
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

#
# Public Service Discovery
#

resource "aws_service_discovery_public_dns_namespace" "ecs_public_service_discovery" {
  name        = "${var.resource_prefix}.${var.your_public_domain_for_service_discovery}"
  description = "Public Service Discovery for example workers"
}

resource "aws_service_discovery_service" "example_workers" {
  name = "example-workers"

  dns_config {
    namespace_id = "${aws_service_discovery_public_dns_namespace.ecs_public_service_discovery.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_config {
    failure_threshold = 10
    resource_path     = "/"    # FIXME Use an actual endpoint
    type              = "HTTP"
  }
}
