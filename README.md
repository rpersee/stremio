# Stremio
Kubernetes manifests to deploy Stremio.

## Deployment
Set the following environment variables:
```bash
OPENVPN_FILEPATH="your_config.ovpn"
OPENVPN_USERNAME="your_username"
OPENVPN_PASSWORD="your_password"
```

Create a namespace for Stremio:
```bash
kubectl create namespace stremio
```

Resolve your OpenVPN server's IP address:
```bash
OPENVPN_REMOTE="$(awk -F' ' '/^remote /{print $2}' "${OPENVPN_FILEPATH}")"
OPENVPN_IPADDR="$(getent hosts "$OPENVPN_REMOTE" | awk '{print $1}')"
sed "s/${OPENVPN_REMOTE}/${OPENVPN_IPADDR}/g" "${OPENVPN_FILEPATH}" > custom.ovpn
```

Create a secret with your OpenVPN configuration:
```bash
kubectl create secret generic openvpn-configuration \
    --from-file=custom.ovpn \
    --namespace stremio
```

Create a secret with your OpenVPN credentials:
```bash
kubectl create secret generic openvpn-credentials \
    --from-literal=username="${OPENVPN_USERNAME}" \
    --from-literal=password="${OPENVPN_PASSWORD}" \
    --namespace stremio
```

Deploy Stremio:
```bash
kubectl apply -f deployment.yaml \
    --namespace stremio
```