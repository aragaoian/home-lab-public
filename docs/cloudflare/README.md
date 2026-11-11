# Cloudflare configuration

This directory records the Cloudflare configuration used to provide protected
remote access to MLflow in the home lab.

## Completed setup

### 1. Domain configuration

- Domain configured and managed through Cloudflare DNS.
- MLflow is exposed through the hostname:
  `mlflow.example.com`.
- No inbound router port forwarding is required.

### 2. MLflow tunnel

- A Cloudflare Tunnel was created for MLflow.
- The tunnel runs through the `cloudflared` service in
  [`docker-compose.yaml`](../../docker-compose.yaml).
- The tunnel token is supplied through the `CLOUDFLARE_TUNNEL_TOKEN`
  environment variable and must not be committed to the repository.
- The MLflow service is bound to `127.0.0.1:5000` on the host and is reachable
  by `cloudflared` as `http://mlflow:5000` over the `home-lab-network` Docker
  network.

### 3. Access policy

- A Cloudflare Access policy was configured to protect the MLflow hostname.
- Access is granted only to the identities or conditions defined in the
  Cloudflare policy.
- The MLflow UI should be tested from outside the home network to verify both
  authentication and connectivity.

## Configuration flow

```text
Client
  -> Cloudflare DNS
  -> Cloudflare Access policy
  -> Cloudflare Tunnel
  -> cloudflared container
  -> mlflow:5000
```

## Security notes

- Keep the tunnel token in `.env` or another secret manager; use
  [`.env.example`](../../.env.example) only as a template.
- Do not commit `.env`, tunnel credentials, or Access credentials.
- Review the Access policy whenever users, domains, or intended exposure
  change.
- Rotate the tunnel token if it is exposed.

## Remaining validation

- [X] Confirm access from a device outside the home network.
- [X] Confirm that only the MLflow hostname is routed through this tunnel.
- [ ] Confirm that no unnecessary router ports are exposed.
- [ ] Document the credential rotation and access-revocation procedure.