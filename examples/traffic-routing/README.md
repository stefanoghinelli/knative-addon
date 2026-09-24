# Traffic Routing

This example shows a canary rollout for a single Knative Service: deploy `v1`, shift 10% of traffic to `v2`, then promote `v2` to 100% while keeping `v1` reachable through a tag.

## Prerequisites

The Knative platform must already be installed, for example through the SD plugin entrypoint `katalog/knative-kourier`.

## Run it

```bash
kubectl -n knative-serving port-forward svc/kourier-internal 8080:80 &

# stage 1: deploy v1
kubectl apply -f examples/traffic-routing/stage-1-stable.yaml
kubectl get ksvc traffic-routing -n default -w   # wait, then Ctrl-C
```

Traffic splits and tags show up under `status.traffic`:

```bash
kubectl get ksvc traffic-routing -n default -o jsonpath='{.status.traffic}' | jq
```

Curl the tagged endpoints for each Revision directly. These bypass the percentage split entirely, which is exactly what makes it safe to validate a canary before shifting real traffic to it:

```bash
curl -H "Host: stable-traffic-routing.default.svc.cluster.local" http://localhost:8080
```

```bash
# stage 2: add v2 canary
kubectl apply -f examples/traffic-routing/stage-2-canary.yaml
kubectl get ksvc traffic-routing -n default -o jsonpath='{.status.traffic}' | jq

curl -H "Host: canary-traffic-routing.default.svc.cluster.local" http://localhost:8080

# sample the traffic split
HOST=$(kubectl get ksvc traffic-routing -n default -o jsonpath='{.status.url}' | sed 's#http://##')
for i in $(seq 1 20); do curl -s -H "Host: $HOST" http://localhost:8080; echo; done
```

```bash
# stage 3: promote v2
kubectl patch ksvc traffic-routing -n default --type merge --patch-file examples/traffic-routing/stage-3-promote.yaml
kubectl get ksvc traffic-routing -n default -o jsonpath='{.status.traffic}' | jq

curl -H "Host: $HOST" http://localhost:8080          # v2
curl -H "Host: stable-traffic-routing.default.svc.cluster.local" http://localhost:8080  # v1
```
