Deployment notes — TLS & reverse proxy

1) Option: Cloud Run / Managed platform
   - Build the backend image (see Dockerfile) and push to your container registry.
   - Use Cloud Run or a managed container service with HTTPS termination by default.
   - Configure `SENTRY_DSN` and `SECRET_PROVIDER` as environment variables in the service.

2) Option: Kubernetes / virtual machines + nginx
   - Use the provided `backend/nginx/nginx.conf` as a template for a reverse proxy
     that proxies traffic to the backend service on port 8080 and exposes `/metrics`.
   - Terminate TLS at the load balancer (Let's Encrypt cert-manager on k8s, or nginx with certbot).

3) DNS & TLS
   - Point your domain's A/ALIAS/CNAME to the load balancer IP or managed service.
   - Obtain certificates (Let's Encrypt recommended) and configure auto-renewal.

4) Healthchecks
   - The Dockerfile includes a `HEALTHCHECK` calling `/health`.
   - Configure your load balancer to use `/health` (HTTP 200) for readiness/liveness.

5) Secrets
   - Do NOT commit `.env` or any credentials. Use `SECRET_PROVIDER=aws` with `AWS_REGION` and
     an IAM role or `SENTRY_DSN` env var in your deployment environment.
