
services:
  etcd:
    snapshot: true
    creation: 6h
    retention: 24

# Required for external TLS termination with
# ingress-nginx v0.22+
ingress:
  provider: nginx
  options:
    use-forwarded-headers: "true"
