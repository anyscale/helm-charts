# anyscale-connector

> **Private preview; contact Anyscale before use.** Not self-service: Anyscale supplies your
> values and tells you when to upgrade. Versions below 1.0 may change incompatibly in any
> release, including patch releases, so pin an exact `--version`.

Connects a Kubernetes cluster to Anyscale: a connector Deployment with the KubeRay telemetry
webhook, plus the optional Cluster Telemetry Gateway and Observability API. Every value is
documented in `values.yaml`. This file covers what those comments cannot: how to get access,
the optional subcharts, and how to upgrade.

## Before you install

- **Contact Anyscale first.** Your Anyscale account team enables the connector for your cloud
  and gives you the values this chart needs: `global.cloudId`, `global.cloudResourceId` and
  the release to install. Without an account team contact, write to support@anyscale.com.
- **Pin the version.** Add the repo and always pass `--version`. Without it, `helm upgrade`
  moves to the newest release, which may be incompatible with your values:

  ```sh
  helm repo add anyscale https://anyscale.github.io/helm-charts
  helm install anyscale-connector anyscale/anyscale-connector --version <version> \
    --namespace anyscale-connector --create-namespace -f your-values.yaml
  ```

- **Upgrade only when Anyscale tells you to.** Until 1.0 a new release may rename values,
  change resources, or need a manual step first. Anyscale tells you what to do before you move.

## Optional subcharts

The chart can install the two things a KubeRay cluster needs that the connector itself does
not provide. Both are off by default: most clusters already run them, and a second copy
collides with the first.

| Subchart | Enable with | Use instead of |
|---|---|---|
| [kuberay-operator](https://github.com/ray-project/kuberay) | `kuberay-operator.enabled=true` | an operator you already run |
| [dcgm-exporter](https://github.com/NVIDIA/dcgm-exporter) | `dcgm-exporter.enabled=true` | the NVIDIA GPU Operator's exporter, or your own |

The versions pinned in `Chart.yaml` are the ones this chart release is tested with. Each block in
`values.yaml` is the subchart's own values file, so any upstream value can be set there: for
example `kuberay-operator.watchNamespace` to scope the operator, or `dcgm-exporter.affinity`
to match the labels your GPU nodes carry.

### One install on a bare cluster

```sh
helm install anyscale-connector anyscale/anyscale-connector --version <version> \
  --namespace anyscale-connector --create-namespace \
  --set global.cloudId=cld_... --set global.cloudResourceId=cldrsrc_... \
  --set kuberay-operator.enabled=true \
  --set dcgm-exporter.enabled=true
```

With `dcgm-exporter.enabled=true` and `clusterTelemetry.dcgmNamespace` left empty, the gateway
scrapes the subchart's exporter automatically. Leave the exporter off on a cluster without GPU
nodes.

### Using what you already run

Leave both off (the default). Point GPU metrics at your exporter with
`clusterTelemetry.dcgmNamespace` and, if its Service is not named `nvidia-dcgm-exporter`,
`clusterTelemetry.dcgmServiceName`. An operator you already run needs no configuration.

Enabling `kuberay-operator` next to an existing operator fails at install time: the operator's
resource names are fixed (`kuberay-operator`), so Helm refuses to take ownership of them. That
is the intended outcome; disable the subchart and keep the existing install.

## Upgrading the KubeRay operator

Helm installs the `ray.io` CustomResourceDefinitions from the subchart with the first install
and never touches them again: `helm upgrade` moves the operator Deployment to the new version
but leaves the CRDs at the version they were installed with. Before upgrading to a chart with
a newer `kuberay-operator` pin, bring the CRDs to that version yourself:

```sh
# 1. Upgrade the CRDs to the version the new chart pins (X.Y.Z from its Chart.yaml).
kubectl replace -k "github.com/ray-project/kuberay/ray-operator/config/crd?ref=vX.Y.Z&timeout=90s"
# 2. Upgrade the release as usual.
helm upgrade anyscale-connector anyscale/anyscale-connector --version <version> \
  --namespace anyscale-connector -f your-values.yaml
```

`kubectl replace` keeps your RayJobs, RayClusters and RayServices; only the schema moves.
Skipping step 1 leaves the new operator running against the old CRDs, where fields added in
the new version are silently dropped from your manifests. `replace` needs each CRD to exist
already: if your first install used `--skip-crds`, or the new version adds a CRD, run
`kubectl create -k` with the same URL first. It creates the missing ones and reports
`AlreadyExists` for the rest, which is fine.

## Uninstalling

`helm uninstall` removes the operator and the exporter but, again by Helm's design, leaves the
`ray.io` CRDs in place. Deleting them also deletes every Ray custom resource in the cluster, so
do it only when you mean to:

```sh
kubectl delete crd rayclusters.ray.io rayjobs.ray.io rayservices.ray.io raycronjobs.ray.io
```
