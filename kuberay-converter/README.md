
# KubeRay Converter `kubectl` Plugin – Release Notes

**Version**: `v0.1.0`
**Initial Release**

The KubeRay Converter `kubectl` plugin converts KubeRay Custom Resources (CRs) to Anyscale configuration files, enabling migration from Kubernetes-based Ray deployments to the Anyscale managed platform.

---

## Core Functionality

### Ray Custom Resource Conversion

The plugin supports conversion of the following KubeRay CRs:

| KubeRay CR   | ➡️  | Anyscale Configuration |
|--------------|-----|-------------------------|
| RayCluster   | →   | Workspace config        |
| RayJob       | →   | Job config              |
| RayService   | →   | Service config          |

### Smart Resource Detection

- **Unified command** auto-detects CR type:
  ```bash
  kubectl anyscale convert --input-cr <file> --config <config> --output-dir <dir>
  ```
  - `input-cr`: Path to KubeRay CR YAML
  - `config`: values.yaml from Anyscale Operator install
  - `output-dir`: Directory for generated Anyscale config files

---

## Generated Configuration

### Workspace Configuration

- Embedded compute config with instance types and resources
- Supports environment variables
- Automatic Ray version detection
- `project: <your_project>` field
- Cloud provider settings included

### Job Configuration

- Converts Ray job entrypoints
- Runtime env: requirements, working dirs, excludes
- Compute templates as separate reusable files
- Includes `project` field

### Service Configuration

- Converts Ray Serve applications
- Handles deployment parameters
- Dedicated compute configurations
- Uses `-service-config` naming convention

---

## Advanced Features

### Pod Specification Support

- CPU & memory limits/requests
- Volume mounts (PVCs, ConfigMaps)
- Environment variables per container
- Port mappings
- Pod/container security context

### Accelerator Support

- GPU (NVIDIA) configuration
- TPU (GCP v6e-16 multi-host) support
- Node selectors for accelerators
- Automatic resource mapping

### Autoscaling Support

- Converts autoscaler settings
- min/max replicas, scaling flags
- Idle termination settings

---

## Anyscale CLI Integration

Generated ready-to-use commands for each resource:

| Resource   | Command                                      |
|------------|----------------------------------------------|
| Workspace  | `anyscale workspace_v2 create -f <config>`   |
| Compute    | `anyscale compute-config create -f <config>` |
| Job        | `anyscale job submit -f <config>`            |
| Service    | `anyscale service deploy -f <config>`        |

---

## Getting Started

## Getting Started

- Download the latest plugin binary from the [Releases section](https://github.com/anyscale/helm-charts/releases) of the GitHub repository.

1. Go to: https://github.com/anyscale/helm-charts/releases
2. Download the appropriate `kubectl-anyscale` binary for your OS and architecture (e.g., `kubectl-anyscale-linux-amd64`, `kubectl-anyscale-darwin-arm64`, etc.)
3. Make the binary executable and move it to a directory in your `PATH`. For example:

```bash
chmod +x kubectl-anyscale-<your-platform>
sudo mv kubectl-anyscale-<your-platform> /usr/local/bin/kubectl-anyscale
```

- Check the plugin version

```
kubectl anyscale version
```
