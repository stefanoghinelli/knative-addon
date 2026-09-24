# Knative

Add serverless capabilities to Kubernetes clusters with [Knative](https://knative.dev/).

If you are new to SIGHUP Distribution (SD) please refer to the [official documentation][sd-docs] on how to get started with SD.

## Requirements

The latest furyctl (follow the instructions in [furyctl's documentation][furyctl-installation]).

## Usage

Under `spec.plugins.kustomize` in `furyctl.yaml`:

```yaml
apiVersion: kfd.sighup.io/v1alpha2
kind: KFDDistribution
spec:
  plugins:
    kustomize:
      - name: knative
        folder: github.com/stefanoghinelli/knative-kustomize-manifests//katalog/knative-kourier?ref=main
```

`furyctl` deploys it with kapp, so the annotations in the package are used to apply CRDs, the Operator and the Knative stack in the correct order.

> [!NOTE]
> This package intentionally leaves `spec.config.domain` unset in the `KnativeServing` resource, following the same approach as the SD ingress module with `baseDomain`. As a result, Knative Services use the default `{service}.{namespace}.svc.cluster.local` URLs, which are reachable only from within the cluster. To configure a custom domain, patch this field in [`katalog/knative-kourier/platform.yaml`](katalog/knative-kourier/platform.yaml).

## Examples

| Example                                     | Description                                                                              |
|----------------------------------------------|-------------------------------------------------------------------------------------------|
| [autoscaling](examples/autoscaling)         | Autoscaling demo based on request concurrency using the official `autoscale-go` sample.  |
| [traffic-routing](examples/traffic-routing) | Rollout in three stages across two Revisions using `spec.traffic` splits and tags.       |

-----

Disclaimer: this is not an official SIGHUP project or roadmap. Refer to the [SIGHUP Distribution documentation][docs] for the official plugins documentation.

[furyctl-installation]: https://github.com/sighupio/furyctl#installation
[docs]: https://docs.sighup.io/docs/installation/sd-configuration/plugins
[sd-docs]: https://docs.sighup.io/docs/distribution/
