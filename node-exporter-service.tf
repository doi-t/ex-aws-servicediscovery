# FIXME: prometheus can not talk to node-exporter now.
resource "aws_ecs_service" "node_exporter_daemon" {
  name                = "node-exporter-daemon"
  cluster             = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition     = "${aws_ecs_task_definition.ecs_node_exporter_daemon.arn}"
  scheduling_strategy = "DAEMON"

  # NOTE: When specifying 'host' or 'bridge' for networkMode, values for 'containerName' and 'containerPort' must be specified from the task definition.
  service_registries {
    registry_arn = "${aws_service_discovery_service.node_exporter.arn}"

    # The container name value that is already specified in the task definition
    container_name = "node-exporter"

    # The port value that is already specified in the task definition ()
    container_port = "9100"
  }
}

resource "aws_ecs_task_definition" "ecs_node_exporter_daemon" {
  family                = "${var.resource_prefix}-node-exporter"
  container_definitions = "${file("container-definitions/node-exporter.json")}"

  # TODO: Make sure the proper network mode for node exporter
  network_mode = "host"

  # TODO: Check the spec
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [ap-northeast-1a, ap-northeast-1c]"
  }
}
