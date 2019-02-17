variable "resource_prefix" {}
variable "ecs_cluster_id" {}
variable "awslogs_group_id" {}

data "aws_region" "current" {}

locals {
  container_name           = "prometheus-server"
  resource_name            = "${var.resource_prefix}-${local.container_name}"
  prometheus_port          = 9090
  alertmanager_port        = 9093
  prometheus_memory        = 256
  alertmanager_memory      = 128
  prometheus_desired_count = 1
  region                   = "${data.aws_region.current.name}"
}

resource "aws_ecs_service" "prometheus_with_alertmanager" {
  name            = "${local.resource_name}"
  cluster         = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.prometheus_with_alertmanager.arn}"
  desired_count   = "${local.prometheus_desired_count}"

  # This is necessary when I use LB for ecs.
  # Ref. https://www.terraform.io/docs/providers/aws/r/ecs_service.html#iam_role
  # iam_role        = "${aws_iam_role.ecs_service.arn}"
  # depends_on      = ["aws_iam_role_policy_attachment.ecs_service"]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  # TODO: Check the spec
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${local.region}a, ${local.region}c]"
  }
}

resource "aws_ecs_task_definition" "prometheus_with_alertmanager" {
  family                = "${local.resource_name}"
  container_definitions = "${data.template_file.prometheus_with_alertmanager.rendered}"
  network_mode          = "bridge"

  volume {
    name = "prometheus-storage"

    # TODO: Make sure the spec: https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html#docker-volume-configuration-arguments
    docker_volume_configuration {
      scope         = "shared" # Docker volumes that are scoped as shared persist after the task stops.
      autoprovision = true
      driver        = "local"

      labels {
        Name = "prometheus-tsdb-storage"
      }
    }
  }

  # TODO: Check the spec
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${local.region}a, ${local.region}c]"
  }
}

data "aws_ecs_task_definition" "prometheus_with_alertmanager" {
  task_definition = "${aws_ecs_task_definition.prometheus_with_alertmanager.family}"
  depends_on      = ["aws_ecs_task_definition.prometheus_with_alertmanager"]
}

data "template_file" "prometheus_with_alertmanager" {
  template = "${file("${path.module}/${local.container_name}.json")}"

  vars {
    name                = "${local.container_name}"
    region              = "${local.region}"
    image               = "${aws_ecr_repository.prometheus_with_alertmanager.repository_url}"
    prometheus_port     = "${local.prometheus_port}"
    prometheus_memory   = "${local.prometheus_memory}"
    alertmanager_port   = "${local.alertmanager_port}"
    alertmanager_memory = "${local.alertmanager_memory}"
    awslogs_group       = "${var.awslogs_group_id}"
  }
}

resource "aws_ecr_repository" "prometheus_with_alertmanager" {
  name = "${local.resource_name}"
}
