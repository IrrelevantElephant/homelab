# Forgejo runner

The runner registers itself as the global runner named `kubernetes` using
Forgejo's offline registration mechanism. Before syncing the Deployment, create
the shared 40-character hexadecimal secret:

```shell
openssl rand -hex 20 | kubectl --namespace forgejo create secret generic \
  forgejo-runner-registration --from-file=secret=/dev/stdin
```

The registration init container idempotently creates or updates the runner in
Forgejo. A second init container derives the runner UUID from the same secret
and generates its runtime configuration.

Runner jobs use the pod's isolated Docker-in-Docker sidecar. The sidecar is
privileged, but does not mount a container runtime socket from a Kubernetes
node.
