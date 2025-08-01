# KubeRay Converter Examples

Convert KubeRay Custom Resources to Anyscale configurations.

## Examples

### `raycluster-simple-config.yaml`
Basic RayCluster with autoscaling.

### `rayjob-sample-job.yaml`
RayJob with runtime environment and ConfigMap mounting.

### `rayservice-simple-serivce.yaml`
RayService with Serve application deployment.

### `values.yaml`
Cloud provider settings and GPU mappings.

## Usage

```bash
# Convert
kubectl anyscale convert --input-cr <example>.yaml --config values.yaml --output-dir ./output

# Deploy
anyscale workspace_v2 create -f ./output/workspace-config.yaml
anyscale job submit -f ./output/job-config.yaml
anyscale service deploy -f ./output/service-config.yaml
```

## Customization

```yaml
# Resource limits
resources:
  limits:
    cpu: "4"
    memory: "8Gi"

# Autoscaling
workerGroupSpecs:
  - maxReplicas: 10
```

## Support

- [Main README](../README.md)
- KubeRay documentation
- Anyscale documentation 