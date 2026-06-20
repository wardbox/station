# App exposure pattern

Every app should start with the same internal shape:

```text
Deployment -> ClusterIP Service
```

Then choose exposure by adding one small wrapper:

```text
private testing/internal admin -> Tailscale LoadBalancer Service
public internet               -> Traefik Ingress
both during migration          -> both wrappers, then remove one
```

## Private on Tailscale

Create a second Service that selects the same app pods and uses Tailscale's
LoadBalancer class:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-tailnet
  namespace: myapp
  annotations:
    tailscale.com/hostname: myapp
spec:
  type: LoadBalancer
  loadBalancerClass: tailscale
  selector:
    app: myapp
  ports:
    - name: http
      port: 80
      targetPort: http
      protocol: TCP
```

Result:

```text
http://myapp.<tailnet>.ts.net
# or MagicDNS short name, depending on the client:
http://myapp
```

Use this for Argo CD, dashboards, review apps, staging apps, and anything that
should not have a public login surface.

## Public on Traefik

Create a normal Ingress using the wildcard TLS Secret:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  namespace: myapp
spec:
  ingressClassName: traefik
  tls:
    - hosts:
        - myapp.stationsystems.dev
      secretName: stationsystems-dev-wildcard-tls
  rules:
    - host: myapp.stationsystems.dev
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp
                port:
                  number: 80
```

Use this for things intended to be reachable by anyone.

## Moving between private and public

To keep an app private:

```text
keep:    myapp-tailnet Service
remove:  public Ingress
```

To make it public:

```text
keep:    internal ClusterIP Service
add:     public Ingress
option:  keep Tailscale Service for admin/testing, or remove it
```

Do not expose admin tools publicly unless there is a deliberate reason. Prefer
Tailscale first; public ingress is an explicit promotion step.
