# My Homelab configuration

Currently consists of three raspberry pi 5's

## Initial setup

### 1. Install ArgoCD

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Expose ArgoCD locally

```shell
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Retrieve the initial admin password

```shell
ARGOPASSWORD=$(kubectl get secret argocd-initial-admin-secret -o=jsonpath={".data.password"} | base64 -d)
```

Login

```shell
argocd login localhost:8080 --insecure --password $ARGOPASSWORD --username admin
```

Update password

```shell
argocd account update-password --current-password $ARGOPASSWORD --new-password $NEWPASSWORD
```

Create cluster context

```shell
argocd cluster add k3s-cluster-context
```

Add this repo as an "app"

```shell
argocd app create apps --repo https://github.com/IrrelevantElephant/homelab.git --path apps --dest-server https://kubernetes.default.svc --dest-namespace default
```

sync the app

```shell
argocd app sync apps
```

## DNS with CloudFlare tunnels

Create the tunnel

```shell
cloudflared tunnel create argocd
```

Create a secret based on the file created by `cloudflared`
```shell
kubectl create secret generic argocd-tunnel-creds \
	--from-file=credentials.json=/home/harry/.cloudflared/$TUNNELID.json
```

```shell
cloudflared tunnel route dns argocd argocd.giulia-harry.dev
```

## Image pull secret

Create an image pull secret:

```shell
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=./.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
```

