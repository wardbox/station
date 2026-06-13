# Kubernetes layer — front door

Layer 2 starts here. These manifests are still applied by hand until Argo CD owns
this directory.

## DNS records

The domain is registered at Gandi. Until DNS is automated, configure these in
Gandi LiveDNS:

| Type | Name | Value | Purpose |
| --- | --- | --- | --- |
| A | `@` | `5.78.150.13` | apex site (`stationsystems.dev`) |
| A | `*` | `5.78.150.13` | wildcard subdomains for future apps |

Use the default TTL or `300` while wiring the front door.

## Current ingress

`blog/blog.yaml` routes only `Host: stationsystems.dev` to the blog workload.
TLS is not enabled yet; cert-manager + DNS-01 wildcard cert is the next layer-2
step.
