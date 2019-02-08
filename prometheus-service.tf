resource "aws_ecs_service" "prometheus_with_alertmanager" {
  name            = "prometheus-with-alertmanager"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.prometheus_with_alertmanager.arn}"
  desired_count   = "${var.prometheus_desired_task_count}"

  # This is necessary only when I use LB for ecs.
  # Ref. https://www.terraform.io/docs/providers/aws/r/ecs_service.html#iam_role
  # iam_role        = "${aws_iam_role.ecs_service.arn}"
  # depends_on      = ["aws_iam_role_policy_attachment.ecs_service"]

  # NOTE: When specifying 'host' or 'bridge' for networkMode, values for 'containerName' and 'containerPort' must be specified from the task definition.
  service_registries {
    registry_arn = "${aws_service_discovery_service.prometheus.arn}"

    # The container name value that is already specified in the task definition
    container_name = "prometheus-server"

    # The port value that is already specified in the task definition ()
    container_port = "9090"
  }
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  # TODO: Check the spec
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [ap-northeast-1a, ap-northeast-1c]"
  }
}

resource "aws_ecs_task_definition" "prometheus_with_alertmanager" {
  family                = "${var.resource_prefix}-prometheus-with-alertmanager"
  container_definitions = "${file("container-definitions/prometheus.json")}"
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
    expression = "attribute:ecs.availability-zone in [ap-northeast-1a, ap-northeast-1c]"
  }
}

resource "aws_ecr_repository" "ecr_prometheus" {
  name = "${var.resource_prefix}-ecr-prometheus"
}
