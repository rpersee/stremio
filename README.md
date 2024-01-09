# Stremio
Kubernetes manifests to deploy Stremio.

## Deployment
Create a namespace for Stremio:
```bash
kubectl create namespace stremio
```

Resolve your OpenVPN server's IP address:
```bash
OPENVPN_REMOTE="$(awk -F' ' '/^remote /{print $2}' stremio.ovpn)"
OPENVPN_IPADDR="$(getent hosts "$OPENVPN_REMOTE" | awk '{print $1}')"
sed "s/${OPENVPN_REMOTE}/${OPENVPN_IPADDR}/g" your_config.ovpn > custom.ovpn
```

Create a configmap with your OpenVPN configuration:
```bash
kubectl create configmap openvpn-configuration \
    --from-file=custom.ovpn \
    --namespace stremio
```

Create a secret with your OpenVPN credentials:
```bash
kubectl create secret generic openvpn-credentials \
    --from-literal=username=your_username \
    --from-literal=password=your_password \
    --namespace stremio
```

Deploy Stremio:
```bash
kubectl apply -f deployment.yaml \
    --namespace stremio
```