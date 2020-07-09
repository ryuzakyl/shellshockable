VERSION ?= 0.1.0

distribute: image
	docker push lizrice/shellshockable:$(VERSION)

image:
	docker build -f Dockerfile -t lizrice/shellshockable:$(VERSION) .

deploy:
	helm install shell-chart shellshockable/ --values shellshockable/values.yaml