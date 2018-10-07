#
# ECS Instance
#

resource "aws_iam_role" "ecs_instance" {
  name               = "${var.resource_prefix}-ecs-instance"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role.json}"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${aws_iam_role.ecs_instance.name}-instance-profile"
  role = "${aws_iam_role.ecs_instance.name}"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  role       = "${aws_iam_role.ecs_instance.name}"
  policy_arn = "${aws_iam_policy.ecs_instance.arn}"
}

resource "aws_iam_policy" "ecs_instance" {
  name   = "${var.resource_prefix}-ecs-instance-policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ecs_instance.json}"
}

# Ref. https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_managed_policies.html#AmazonEC2ContainerServiceforEC2Role
data "aws_iam_policy_document" "ecs_instance" {
  statement {
    sid = "1"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

#
# ECS Service
#

resource "aws_iam_role" "ecs_service" {
  name               = "${var.resource_prefix}-ecs-service"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role.json}"
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_service" {
  role       = "${aws_iam_role.ecs_service.name}"
  policy_arn = "${aws_iam_policy.ecs_service.arn}"
}

resource "aws_iam_policy" "ecs_service" {
  name   = "${var.resource_prefix}-ecs-service-policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ecs_service.json}"
}

# Ref. https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_managed_policies.html#AmazonEC2ContainerServiceRole
data "aws_iam_policy_document" "ecs_service" {
  statement {
    sid = "1"

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
    ]

    resources = [
      "*",
    ]
  }
}
