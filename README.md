# ex-aws-servicediscovery

Play with [Route53 Auto Naming](https://docs.aws.amazon.com/Route53/latest/APIReference/overview-service-discovery.html) and [ECS Service Discovery](https://aws.amazon.com/blogs/aws/amazon-ecs-service-discovery/) features.

# TODOs
- [x] Deploy Prometheus, node-exporter and alertmanager just for fun
- [x] Use ECS Service Discovery as a Prometheus's DNS-based service discovery
    - It supports SRV record query in [dns_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#dns_sd_config)
- [ ] Establish a DNS based Load Balancer in public with [a public DNS namespace](https://aws.amazon.com/premiumsupport/knowledge-center/service-discovery-route53-auto-naming/)
- [ ] Use [EBS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-ami-storage-config.html) as Prometheus's tsdb storage
    - Relates?: [Data Volumes in Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_data_volumes.html)
- [ ] Setup alertmanager properly
- [ ] Use Spot Fleet

## Preparation
Create a S3 bucket for tfstate.

## Deploy cluster
```shell
make TF_S3_BUCKET=<your_s3_bucket_name> KEY_NAME=<your_key_pair_name> YOUR_PUBLIC_DOMAIN=<your_public_domain_name> apply
```

## Upload container images to ECR
```shell
make push
```

## Cleanup
```shell
make TF_S3_BUCKET=<your_s3_bucket_name> KEY_NAME=<your_key_pair_name> YOUR_PUBLIC_DOMAIN=<your_public_domain_name> destroy
```

# References
- [YouTube: New Features for Building Powerful Containerized Microservices on AWS - AWS Online Tech Talks](https://www.youtube.com/watch?v=WLD7wqJzKEw)

## Health Checks
> **Health checks**: Perform periodic container-level health checks. If an endpoint does not pass the health check, it is removed from DNS routing and marked as unhealthy. For more information, see [How Amazon Route 53 Checks the Health of Your Resources](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/welcome-health-checks.html).
>
> Ref. https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html#service-discovery-concepts

## DNS Based Load Balancer in Public
Currently you need to register/deregister an instance to/from a public namespace with **a public IP address** by yourself.

> - The DNS records created for a service discovery service will always register with the private IP address for the task, rather than the public IP address, even when public namespaces are used.
>
> Ref. https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html#service-discovery-considerations
