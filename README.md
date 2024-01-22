# Stremio
Kubernetes manifests to deploy Stremio.

## Deployment with Flux
### Create a certificate for sealed secrets
Set the following environment variables:
```bash
export NAMESPACE="flux-system"
export SECRETNAME="sealed-secrets-default-cert"
export PRIVATEKEY="sealed-secrets-default.key"
export PUBLICKEY="sealed-secrets-default.crt"
```

Create a certificate:
```bash
openssl req -x509 -days 365 -nodes -newkey rsa:4096 \
    -keyout "$PRIVATEKEY" -out "$PUBLICKEY" \
    -subj "/CN=sealed-secret/O=sealed-secret"
```

> **Note**: Keep the private key safe. It is required to decrypt the secrets.

Create a secret with the certificate:
```bash
kubectl create secret tls "$SECRETNAME" \
    --namespace "$NAMESPACE" \
    --cert="$PUBLICKEY" \
    --key="$PRIVATEKEY" \
    --dry-run=client \
    -o yaml > sealed-secrets-cert.yaml
```

Label the secret:
```bash
yq '.metadata.labels += {"sealedsecrets.bitnami.com/sealed-secrets-key": "active"}' \
    sealed-secrets-cert.yaml > sealed-secrets-cert-labeled.yaml
```

### Create a sealed secret with OpenVPN credentials
Set the following environment variables:
```bash
OPENVPN_FILEPATH="your_config.ovpn"
OPENVPN_USERNAME="your_username"
OPENVPN_PASSWORD="your_password"
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
    --namespace stremio \
    --dry-run=client \
    -o yaml > ovpn-config.yaml
```

Create a secret with your OpenVPN credentials:
```bash
kubectl create secret generic openvpn-credentials \
    --from-literal=username="${OPENVPN_USERNAME}" \
    --from-literal=password="${OPENVPN_PASSWORD}" \
    --namespace stremio \
    --dry-run=client \
    -o yaml > ovpn-creds.yaml
```

Encrypt the secrets:
```bash
kubeseal --format=yaml --cert="$PUBLICKEY" \
    < ovpn-config.yaml > ovpn-config-sealed.yaml
kubeseal --format=yaml --cert="$PUBLICKEY" \
    < ovpn-creds.yaml > ovpn-creds-sealed.yaml
```
