locals {
  name          = "example-worker"
  port          = 8000
  memory        = 256
  desired_count = 1
  region        = "${data.aws_region.current.name}"
}

resource "aws_ecr_repository" "example_worker" {
  name = "${var.resource_prefix}-${local.name}"
}

resource "aws_ecs_service" "example_worker" {
  name            = "${local.name}"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
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
  template = "${file("${path.module}/container-definitions/${local.name}.json")}"

  vars {
    name          = "${local.name}"
    region        = "${local.region}"
    image         = "${aws_ecr_repository.example_worker.repository_url}"
    port          = "${local.port}"
    memory        = "${local.memory}"
    awslogs_group = "${aws_cloudwatch_log_group.ecs_log_driver_awslogs.id}"
  }
}
