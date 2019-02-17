variable "resource_prefix" {}
variable "ecs_cluster_id" {}
variable "awslogs_group_id" {}
variable "sd_public_namespace_id" {}
variable "sd_private_namespace_id" {}

data "aws_region" "current" {}

locals {
  name          = "example-worker"
  port          = 8000
  memory        = 256
  desired_count = 1
  region        = "${data.aws_region.current.name}"
}

resource "aws_service_discovery_service" "public_example_worker" {
  name = "public-example-worker"

  dns_config {
    namespace_id = "${var.sd_public_namespace_id}"

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

resource "aws_service_discovery_service" "example_worker" {
  name = "${local.name}"

  dns_config {
    namespace_id = "${var.sd_private_namespace_id}"

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

resource "aws_ecr_repository" "example_worker" {
  name = "${var.resource_prefix}-${local.name}"
}

resource "aws_ecs_service" "example_worker" {
  name            = "${local.name}"
  cluster         = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.ecs_example_worker.arn}"
  desired_count   = "${local.desired_count}"

  service_registries {
    registry_arn   = "${aws_service_discovery_service.example_worker.arn}"
    container_name = "${local.name}"
    container_port = "${local.port}"
  }
}

resource "aws_ecs_task_definition" "ecs_example_worker" {
  family                = "${var.resource_prefix}-${local.name}"
  container_definitions = "${data.template_file.example_worker.rendered}"
  network_mode          = "bridge"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${local.region}a, ${local.region}c]"
  }
}

data "aws_ecs_task_definition" "example_worker" {
  task_definition = "${aws_ecs_task_definition.ecs_example_worker.family}"
  depends_on      = ["aws_ecs_task_definition.ecs_example_worker"]
}

data "template_file" "example_worker" {
  template = "${file("${path.module}/${local.name}.json")}"

  vars {
    name          = "${local.name}"
    region        = "${local.region}"
    image         = "${aws_ecr_repository.example_worker.repository_url}"
    port          = "${local.port}"
    memory        = "${local.memory}"
    awslogs_group = "${var.awslogs_group_id}"
  }
}
