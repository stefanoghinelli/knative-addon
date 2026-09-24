.PHONY: install build autoscaling traffic-routing-stage1 traffic-routing-stage2 traffic-routing-stage3 port-forward

CONTEXT ?=
KUBECTL = kubectl $(if $(CONTEXT),--context $(CONTEXT),)
KAPP = kapp $(if $(CONTEXT),--kubeconfig-context $(CONTEXT),)

install:
	kustomize build katalog/knative-kourier | $(KAPP) deploy -a knative-kourier -n kube-system -f - --allow-all-ns -y --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --wait-timeout 120m0s --apply-timeout 120m0s --apply-concurrency 20
	$(KUBECTL) wait --for=condition=Ready knativeserving/knative-serving -n knative-serving --timeout=360s
	$(KUBECTL) wait --for=condition=Ready knativeeventing/knative-eventing -n knative-eventing --timeout=360s

build:
	kustomize build katalog/knative-operator > /dev/null
	kustomize build katalog/knative-kourier > /dev/null

autoscaling:
	$(KUBECTL) apply -f examples/autoscaling/

traffic-routing-stage1:
	$(KUBECTL) apply -f examples/traffic-routing/stage-1-stable.yaml

traffic-routing-stage2:
	$(KUBECTL) apply -f examples/traffic-routing/stage-2-canary.yaml

traffic-routing-stage3:
	$(KUBECTL) patch ksvc traffic-routing -n default --type merge --patch-file examples/traffic-routing/stage-3-promote.yaml

port-forward:
	$(KUBECTL) port-forward -n knative-serving svc/kourier 8080:80
