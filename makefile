# Makefile for building and running the kubeacon-testing image

IMAGE_NAME = guillh/kubeacon-testing:latest
CONTAINER_NAME = kubeacon

.PHONY: build run push kube-run kube-logs kube-clean kube all

build:
	podman build -t $(IMAGE_NAME) .

run:
	podman run --rm --name $(CONTAINER_NAME) $(IMAGE_NAME)

push:
	podman push $(IMAGE_NAME)

kube-run:
	kubectl apply -f deployment.yaml

kube-logs:
	kubectl logs deploy/kubeacon

kube-clean:
	kubectl delete deployment kubeacon

kube:
	$(MAKE) kube-run
	sleep 5
	@echo
	@echo "#### LOGS ####"
	@echo
	$(MAKE) kube-logs
	@echo
	@echo "##############"
	@echo
	$(MAKE) kube-clean

all:
	$(MAKE) build
	$(MAKE) run
	$(MAKE) push
	$(MAKE) kube