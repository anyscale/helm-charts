# KubeRay Converter Examples

This directory contains example configurations for the KubeRay Converter `kubectl` plugin, which converts KubeRay Custom Resources (CRs) to Anyscale configuration files.

## Overview

The KubeRay Converter plugin enables migration from Kubernetes-based Ray deployments to the Anyscale managed platform by converting:

- **RayCluster** → Workspace configuration
- **RayJob** → Job configuration  
- **RayService** → Service configuration

## Example Files

### 1. `raycluster-simple-config.yaml`

A basic RayCluster configuration demonstrating:
- Ray version specification (`2.7.0`)
- Head group with dashboard configuration
- Worker group with autoscaling (1-100 replicas)
- Resource limits for CPU and memory

**Usage:**
```bash
kubectl anyscale convert --input-cr raycluster-simple-config.yaml --config values.yaml --output-dir ./output
```

**Key Features:**
- Head pod with 2 CPU cores and 4Gi memory
- Worker pods with 4 CPU cores and 8Gi memory
- Dashboard accessible on all interfaces (`0.0.0.0`)
- Autoscaling enabled with min/max replicas

### 2. `rayjob-sample-job.yaml`

A comprehensive RayJob example showing:
- Job submission with entrypoint
- Runtime environment configuration
- ConfigMap volume mounting
- Resource specifications
- Job lifecycle management

**Usage:**
```bash
kubectl anyscale convert --input-cr rayjob-sample-job.yaml --config values.yaml --output-dir ./output
```

**Key Features:**
- Python entrypoint with sample code
- Runtime environment with pip dependencies
- ConfigMap mounting for code distribution
- Autoscaling worker group (1-5 replicas)
- Job lifecycle controls (TTL, deadlines, suspend)

### 3. `rayservice-simple-serivce.yaml`

A RayService configuration demonstrating:
- Ray Serve application deployment
- Serve configuration with deployments
- Head and worker group specifications
- Service routing configuration

**Usage:**
```bash
kubectl anyscale convert --input-cr rayservice-simple-serivce.yaml --config values.yaml --output-dir ./output
```

**Key Features:**
- Serve application with import path
- Route prefix configuration (`/simple`)
- Deployment with 2 replicas
- Autoscaling worker group (1-100 replicas)

### 4. `values.yaml`

Configuration file containing:
- Cloud provider settings (AWS)
- Instance type definitions with resource specifications
- GPU accelerator mappings for different cloud providers
- Memory and CPU configurations

**Usage:**
```bash
# Use as the config parameter in convert commands
kubectl anyscale convert --input-cr <your-cr>.yaml --config values.yaml --output-dir ./output
```

**Key Features:**
- AWS instance types (g3, g4dn, g5, m5, p3 series)
- GPU accelerator mappings for AWS, Azure, and GCP
- Memory and CPU specifications for each instance type
- Support for various GPU types (A10G, T4, V100, A100, H100)

## Getting Started

1. **Install the KubeRay Converter plugin:**
   ```bash
   # Installation instructions depend on your setup
   # Refer to the main README for installation details
   ```

2. **Choose an example based on your use case:**
   - Use `raycluster-simple-config.yaml` for basic Ray cluster deployment
   - Use `rayjob-sample-job.yaml` for Ray job submission
   - Use `rayservice-simple-serivce.yaml` for Ray Serve applications

3. **Convert your configuration:**
   ```bash
   kubectl anyscale convert --input-cr <example-file>.yaml --config values.yaml --output-dir ./output
   ```

4. **Deploy to Anyscale:**
   ```bash
   # For workspaces
   anyscale workspace_v2 create -f ./output/workspace-config.yaml
   
   # For jobs
   anyscale job submit -f ./output/job-config.yaml
   
   # For services
   anyscale service deploy -f ./output/service-config.yaml
   ```

## Customization

### Modifying Resource Specifications

Update CPU and memory limits in the example files:
```yaml
resources:
  limits:
    cpu: "4"      # Number of CPU cores
    memory: "8Gi" # Memory limit
```

### Adding Environment Variables

Include environment variables in container specifications:
```yaml
containers:
  - name: ray
    image: rayproject/ray:2.7.0
    env:
      - name: MY_VAR
        value: "my_value"
```

### Configuring Autoscaling

Adjust autoscaling parameters:
```yaml
workerGroupSpecs:
  - groupName: small-group
    replicas: 1
    minReplicas: 1
    maxReplicas: 10  # Maximum number of workers
```

## Advanced Features

### GPU Support

The `values.yaml` file includes GPU accelerator mappings for:
- **AWS**: A10G, T4, V100
- **Azure**: A10, A100, H100, T4  
- **GCP**: A100, H100, L4, P100, T4, V100

### Volume Mounts

Examples show how to mount ConfigMaps and other volumes:
```yaml
volumeMounts:
  - mountPath: /home/ray/samples
    name: sample-job
volumes:
  - name: sample-job
    configMap:
      name: sample-job
```

### Runtime Environment

Configure Python dependencies and environment variables:
```yaml
runtimeEnvYAML: |
  pip:
    - requests==2.26.0
    - pendulum==2.1.2
  env_vars:
    counter_name: sample-job
```

## Troubleshooting

### Common Issues

1. **Resource Limits Too High:**
   - Reduce CPU/memory limits in the example files
   - Ensure your cluster has sufficient resources

2. **Image Pull Errors:**
   - Verify Ray image versions match your requirements
   - Ensure image registry access

3. **Conversion Errors:**
   - Check that all required fields are present
   - Validate YAML syntax
   - Ensure `values.yaml` is properly configured

## Support

For issues and questions:
- Check the main [KubeRay Converter README](../README.md)
- Review KubeRay documentation for CR specifications
- Refer to Anyscale documentation for deployment guidance

## Contributing

To add new examples:
1. Create a new YAML file with descriptive name
2. Include comprehensive comments explaining the configuration
3. Test the conversion process
4. Update this README with the new example 