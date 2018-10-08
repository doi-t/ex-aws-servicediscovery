resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.resource_prefix}-ecs-cluster"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_driver_awslogs" {
  name = "${var.resource_prefix}-awslogs-ecs"

  tags {
    Name = "${var.resource_prefix}"
  }
}

#
# Launch Configuration
#

data "template_file" "ecs_cloud_config" {
  template = "${file("${path.module}/templates/cloud-config.yml.tpl")}"

  vars {
    ecs_cluster_name = "${aws_ecs_cluster.ecs_cluster.arn}"
  }
}

data "template_cloudinit_config" "cloud_config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.ecs_cloud_config.rendered}"
  }
}

resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "${var.resource_prefix}-"
  user_data     = "${base64encode(data.template_cloudinit_config.cloud_config.rendered)}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids               = ["${aws_security_group.ecs_instance.id}"]
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "terminate"

  # Ref. https://github.com/hashicorp/terraform/issues/2831#issuecomment-298751019
  image_id      = "${join("", data.aws_ami.ecs_ami.*.image_id)}"
  ebs_optimized = true

  block_device_mappings {
    device_name = "${join("", data.aws_ami.ecs_ami.*.root_device_name)}"

    ebs {
      volume_type = "${var.root_block_device_type}"
      volume_size = "${var.root_block_device_size}"
    }
  }

  credit_specification {
    cpu_credits = "${var.cpu_credit_specification}"
  }

  iam_instance_profile {
    name = "${aws_iam_instance_profile.ecs_instance.name}"
  }

  monitoring {
    enabled = "${var.detailed_monitoring}"
  }
}

#
# Auto Scaling Group
#

resource "aws_autoscaling_group" "ecs_instance" {
  name = "${var.resource_prefix}-ecs-instance"

  launch_template = {
    id      = "${aws_launch_template.ecs_launch_template.id}"
    version = "$$Latest"
  }

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type         = "EC2"
  termination_policies      = ["OldestLaunchConfiguration", "Default"]
  max_size                  = "${var.asg_max_size}"
  desired_capacity          = "${var.asg_desired_capacity}"
  min_size                  = "${var.asg_min_size}"
  enabled_metrics           = ["${var.enabled_metrics}"]
  vpc_zone_identifier       = ["${module.vpc.public_subnets}"]

  tag {
    key                 = "Name"
    value               = "${var.resource_prefix}-ecs-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
