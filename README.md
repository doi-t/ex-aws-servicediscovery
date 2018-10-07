# ex-r53-auto-naming

Play with [Route53 Auto Naming](https://docs.aws.amazon.com/Route53/latest/APIReference/overview-service-discovery.html) and [ECS Service Discovery](https://aws.amazon.com/blogs/aws/amazon-ecs-service-discovery/) features.

- TODO: Add Service Discovery
- Deploy Prometheus just for fun
    - (WIP) Make node-exporter available for Prometheus
    - (WIP) Use EBS as Prometheus's tsdb storage
    - (WIP) Setup alertmanager properly
- TODO: Use Spot Fleet

## Preparation
Create a S3 bucket for tfstate.

## Deploy cluster
```shell
make TF_S3_BUCKET=doi-t-tfstate KEY_NAME=playground apply
```

## Upload container images to ECR
```shell
make push
```

# References
- [YouTube: New Features for Building Powerful Containerized Microservices on AWS - AWS Online Tech Talks](https://www.youtube.com/watch?v=WLD7wqJzKEw)

> **Health checks**: Perform periodic container-level health checks. If an endpoint does not pass the health check, it is removed from DNS routing and marked as unhealthy. For more information, see [How Amazon Route 53 Checks the Health of Your Resources](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/welcome-health-checks.html).
>
> Ref. https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html#service-discovery-concepts
