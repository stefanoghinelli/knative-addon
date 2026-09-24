# Autoscaling

This example shows how Knative autoscaling based on request concurrency scales a Service up under load and back down when traffic stops.

## Prerequisites

- The Knative platform stack must already be installed, for example through the SD plugin entrypoint `katalog/knative-kourier`.
- [`hey`](https://github.com/rakyll/hey) for load generation: `go install github.com/rakyll/hey@latest`.

## Deploy

```bash
kubectl apply -f examples/autoscaling/
kubectl wait --for=condition=Ready ksvc/autoscale-go -n default --timeout=240s
```

## Test it

From one terminal:

```bash
kubectl get pods -l serving.knative.dev/service=autoscale-go -w
```

In another, forward Kourier's internal listener and generate load. The service defaults to `ClusterLocal` visibility when no `config-domain` is configured. The query params tell each request to sleep 100ms, compute primes up to 10000, and allocate 5MB, giving a realistic cost for each request:

```bash
kubectl -n knative-serving port-forward svc/kourier-internal 8080:80 &
HOST=$(kubectl get ksvc autoscale-go -n default -o jsonpath='{.status.url}' | sed 's#http://##')

hey -z 30s -c 50 -host "$HOST" "http://localhost:8080?sleep=100&prime=10000&bloat=5"
```

With `containerConcurrency: 10` and 50 concurrent workers, expect the pod count to climb toward `maxScale` (10), then scale back down to zero after `hey` stops.
