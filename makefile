SHOCK_VERSION ?= 0.1.0
NONROOT_VERSION ?= 0.2.0
NOSHOCK_VERSION ?= 0.3.0

push: images
	docker push lizrice/shellshockable:$(SHOCK_VERSION)
	docker push lizrice/shellshockable:$(NONROOT_VERSION)
	docker push lizrice/shellshockable:$(NOSHOCK_VERSION)

images: shock-image nonroot-image noshock-image

shock-image:
	docker build -f Dockerfile -t lizrice/shellshockable:$(SHOCK_VERSION) .

nonroot-image:
	docker build -f Dockerfile.nonroot -t lizrice/shellshockable:$(NONROOT_VERSION) .

noshock-image:
	docker build -f Dockerfile.noshock -t lizrice/shellshockable:$(NOSHOCK_VERSION) .

deploy:
	helm install shell-chart shellshockable/ --values shellshockable/values.yaml --set image.tag=$(SHOCK_VERSION)

security-context:
	helm upgrade shell-chart shellshockable/ --values security-context.yaml --set image.tag=$(NONROOT_VERSION)

noshock:
	helm upgrade shell-chart shellshockable/ --set image.tag=$(NOSHOCK_VERSION)