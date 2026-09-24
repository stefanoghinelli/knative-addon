# Knative

Add serverless capabilities to Kubernetes clusters with [Knative](https://knative.dev/).

If you are new to SIGHUP Distribution (SD) please refer to the [official documentation][sd-docs] on how to get started with SD.

## Requirements

- kubectl (for kustomize)
- kapp CLI, as used by SD, to enforce the dependency order among the CRDs, the Operator, the KnativeServing and KnativeEventing resources in the aggregated package

## Usage

Under `spec.plugins.kustomize` in `furyctl.yaml`:

```yaml
apiVersion: kfd.sighup.io/v1alpha2
kind: KFDDistribution
spec:
  plugins:
    kustomize:
      - name: knative
        folder: ./plugins/kustomize/knative-kourier
```

`furyctl` deploys it with kapp, so the annotations in the package are used to apply CRDs, the Operator and the Knative stack in the correct order.

> [!NOTE]
> `config.domain` is left for SD users to set explicitly, exactly like SD's own ingress module leaves `baseDomain` to be supplied by them. By default KnativeService URLs use `*.svc.cluster.local`, reachable from inside the cluster; SD users set a real external domain with a kustomize patch on KnativeServing's `spec.config.domain`.

## Examples

| Example                                     | Description                                                                              |
|----------------------------------------------|-------------------------------------------------------------------------------------------|
| [autoscaling](examples/autoscaling)         | Autoscaling demo based on request concurrency using the official `autoscale-go` sample.  |
| [traffic-routing](examples/traffic-routing) | Rollout in three stages across two Revisions using `spec.traffic` splits and tags.       |

-----

Disclaimer: this is not an official SIGHUP project or roadmap. Refer to the [SIGHUP Distribution documentation][docs] for the official plugins documentation.

[docs]: https://docs.sighup.io/docs/installation/sd-configuration/plugins
[sd-docs]: https://docs.sighup.io/docs/distribution/