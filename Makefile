TF_S3_BUCKET:=
KEY_NAME:=
YOUR_PUBLIC_DOMAIN:=
CLUSTER_NAME:=ex-aws-servicediscovery-ecs-cluster
TF_BACKEND_KEY:=ex-aws-servicediscovery/terraform.tfstate
TF_REGION:=ap-northeast-1

.PHONY: init apply

init:
	terraform init -backend=true \
		-backend-config="bucket=$(TF_S3_BUCKET)" \
		-backend-config="key=$(TF_BACKEND_KEY)" \
		-backend-config="region=$(TF_REGION)"

apply: init
	terraform apply \
		-var=key_name=$(KEY_NAME) \
		-var=your_public_ip=$$(curl -s https://api.ipify.org) \
		-var=your_public_domain_for_service_discovery=$(YOUR_PUBLIC_DOMAIN)

destroy: init
	terraform destroy \
		-var=key_name=$(KEY_NAME) \
		-var=your_public_ip=$$(curl -s https://api.ipify.org) \
		-var=your_public_domain_for_service_discovery=$(YOUR_PUBLIC_DOMAIN)

push:
	./push_container_image.sh $(CLUSTER_NAME) prometheus

update-prometheus: push
	./update_service.sh $(CLUSTER_NAME) prometheus-with-alertmanager

updaste-node-exporter:
	./update_service.sh $(CLUSTER_NAME) node-exporter-daemon
