# ex-aws-servicediscovery

Play with [Route53 Auto Naming](https://docs.aws.amazon.com/Route53/latest/APIReference/overview-service-discovery.html) and [ECS Service Discovery](https://aws.amazon.com/blogs/aws/amazon-ecs-service-discovery/) features.

# TODOs
- [x] Deploy Prometheus, node-exporter and alertmanager just for fun
- [x] Use ECS Service Discovery as a Prometheus's DNS-based service discovery
    - It supports SRV record query in [dns_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#dns_sd_config)
- [ ] Use [EBS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-ami-storage-config.html) as Prometheus's tsdb storage
    - Relates?: [Data Volumes in Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_data_volumes.html)
- [ ] Setup alertmanager properly
- [ ] Use Spot Fleet

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

## Cleanup
```shell
make TF_S3_BUCKET=doi-t-tfstate KEY_NAME=playground destroy
```

# References
- [YouTube: New Features for Building Powerful Containerized Microservices on AWS - AWS Online Tech Talks](https://www.youtube.com/watch?v=WLD7wqJzKEw)

> **Health checks**: Perform periodic container-level health checks. If an endpoint does not pass the health check, it is removed from DNS routing and marked as unhealthy. For more information, see [How Amazon Route 53 Checks the Health of Your Resources](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/welcome-health-checks.html).
>
> Ref. https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html#service-discovery-concepts
