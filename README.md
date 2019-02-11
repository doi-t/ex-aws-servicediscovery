# ex-aws-servicediscovery

Play with [AWS Cloud Map](https://docs.aws.amazon.com/cloud-map/latest/dg/what-is-cloud-map.html) and [ECS Service Discovery](https://aws.amazon.com/blogs/aws/amazon-ecs-service-discovery/) features.

# TODOs
- [x] Deploy Prometheus, node-exporter and alertmanager just for fun
- [x] Use ECS Service Discovery as a Prometheus's DNS-based service discovery
    - It supports SRV record query in [dns_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#dns_sd_config)
- [x] Use EBS with [Docker Volumes](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-volumes.html) as Prometheus's tsdb storage
    - Ref. [Data Volumes in Tasks](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_data_volumes.html)
- [ ] Alertmanager
- [ ] Grafana
- [ ] cAdvisor
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

### push example code
Run an example in https://github.com/prometheus-up-and-running/examples (Python only).
```
export EXAMPLE_CODE=up-and-running-examples/4/4-1-wsgi.py; make push-example
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

## Understanding Prometheus's TSDB
```
$ ssh -i <your key pair's pem file path> ec2-user@<instance public ip which Prometheus container is running on>
[ec2] $ docker volume inspect prometheus-storage
[ec2] $ docker exec -it $(docker ps | grep prometheus-server | awk '{ print $1 }') /bin/sh
```
