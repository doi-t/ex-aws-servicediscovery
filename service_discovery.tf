#
# ECS Service Discovery (Private)
#

resource "aws_service_discovery_private_dns_namespace" "ecs_private_service_discovery" {
  name        = "${var.resource_prefix}.ecs-service-discovery.local"
  description = "Amazon ECS Service Discovery for prometheus service that is availabe only in VPC network"
  vpc         = "${module.vpc.vpc_id}"
}

#
# Public Service Discovery
#

resource "aws_service_discovery_public_dns_namespace" "ecs_public_service_discovery" {
  name        = "${var.resource_prefix}.${var.your_public_domain_for_service_discovery}"
  description = "Public Service Discovery for example workers"
}
