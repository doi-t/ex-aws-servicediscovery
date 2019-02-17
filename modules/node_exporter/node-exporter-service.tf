variable "resource_prefix" {}
variable "ecs_cluster_id" {}
variable "awslogs_group_id" {}
variable "sd_namespace_id" {}
data "aws_region" "current" {}

locals {
  container_name = "node-exporter"
  resource_name  = "${var.resource_prefix}-${local.container_name}"
  port           = 9100
  memory         = 128
  region         = "${data.aws_region.current.name}"
}

resource "aws_service_discovery_service" "node_exporter" {
  name = "${local.resource_name}"

  dns_config {
    namespace_id = "${var.sd_namespace_id}"

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

resource "aws_ecs_service" "node_exporter" {
  name                = "${local.resource_name}"
  cluster             = "${var.ecs_cluster_id}"
  task_definition     = "${aws_ecs_task_definition.node_exporter.arn}"
  scheduling_strategy = "DAEMON"

  # NOTE: When specifying 'host' or 'bridge' for networkMode, values for 'containerName' and 'containerPort' must be specified from the task definition.
  service_registries {
    registry_arn = "${aws_service_discovery_service.node_exporter.arn}"

    # The container name value that is already specified in the task definition
    container_name = "${local.container_name}"

    # The port value that is already specified in the task definition
    container_port = "${local.port}"
  }
}

resource "aws_ecs_task_definition" "node_exporter" {
  family                = "${local.resource_name}"
  container_definitions = "${data.template_file.node_exporter.rendered}"
  network_mode          = "host"

  # TODO: Check the spec
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${local.region}a, ${local.region}c]"
  }
}

data "aws_ecs_task_definition" "node_exporter" {
  task_definition = "${aws_ecs_task_definition.node_exporter.family}"
  depends_on      = ["aws_ecs_task_definition.node_exporter"]
}

data "template_file" "node_exporter" {
  template = "${file("${path.module}/${local.container_name}.json")}"

  vars {
    name          = "${local.container_name}"
    region        = "${local.region}"
    image         = "${aws_ecr_repository.node_exporter.repository_url}"
    port          = "${local.port}"
    memory        = "${local.memory}"
    awslogs_group = "${var.awslogs_group_id}"
  }
}

resource "aws_ecr_repository" "node_exporter" {
  name = "${local.resource_name}"
}
