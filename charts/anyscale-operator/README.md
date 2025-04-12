# Anyscale Operator Helm Chart

The Anyscale Operator Helm Chart enables the deployment and management of Anyscale workloads on Kubernetes clusters. This chart provides a comprehensive set of configuration options to customize the operator's behavior according to your specific requirements.

## Configuration

The following sections detail the configurable parameters available in the chart. Each parameter is documented with its type, default value, and purpose.

### Core Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cloudDeploymentId` | string | `""` | Anyscale cloud deployment ID (e.g. cldrsrc_*) for resource management |
| `cloudProvider` | string | `""` | Cloud provider environment ("aws" or "gcp") |
| `region` | string | `""` | Cloud region for deployment |
| `anyscaleCliToken` | string | `""` | Anyscale CLI token for control plane authentication. Falls back to cloud provider identity if not set |
| `controlPlaneUrl` | string | `""` | URL of the Anyscale Control Plane |
| `operatorImage` | string | `"public.ecr.aws/v0b8w7e3/anyscale/kubernetes_manager:ci-cd1e11a0eae946ead3bc57949c480bb82ef5a9b1"` | Operator container image |
| `operatorIamIdentity` | string | `""` | Cloud provider IAM identity (AWS role ARN or GCP service account email) |

### Kubernetes Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `kubeConfig` | string | `""` | Path to kubeconfig file. Uses in-cluster config if not specified |
| `kubernetesClientRateLimiterQPS` | float32 | `1000` | Kubernetes API server QPS rate limit |
| `kubernetesClientRateLimiterBurst` | int | `2000` | Kubernetes API server burst rate limit |
| `workloadServiceAccountName` | string | `""` | Service account for Anyscale workload pods |

### Performance and Resource Management

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `syncInterval` | duration | `1s` | State reconciliation interval |
| `syncTimeout` | duration | `30s` | Sync RPC timeout |
| `completedReportTTL` | duration | `10m` | Completed operation report retention period |
| `unscheduledPodReaperReconcileInterval` | duration | `1m` | Unscheduled pod cleanup interval |
| `unscheduledPodReaperTerminationThreshold` | duration | `10m` | Unscheduled pod termination threshold |

### Monitoring and Telemetry

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `metricsServerPort` | int | `2112` | Metrics server port |
| `systemLogsIngressProxyPort` | int | `3100` | System logs proxy port |
| `systemMetricsIngressProxyPort` | int | `3101` | System metrics proxy port |
| `vectorEnrichmentTablePath` | string | `""` | Path to vector enrichment table for telemetry |

### High Availability

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableLeaderElection` | bool | `false` | Enable leader election |
| `leaderElectionLeaseNamespace` | string | `""` | Leader election lease namespace |
| `leaderElectionLeaseName` | string | `""` | Leader election lease name |
| `operatorReplicas` | int | `1` | Number of operator replicas |

### Resource Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `operatorResources.operator.requests.memory` | string | `512Mi` | Operator container memory request |
| `operatorResources.operator.requests.cpu` | string | `1` | Operator container CPU request |
| `operatorResources.operator.limits.memory` | string | `2Gi` | Operator container memory limit |
| `operatorResources.vector.requests.cpu` | string | `100m` | Vector sidecar CPU request |
| `operatorResources.vector.requests.memory` | string | `512Mi` | Vector sidecar memory request |
| `operatorResources.vector.limits.memory` | string | `512Mi` | Vector sidecar memory limit |

### Advanced Features

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableAnyscaleRayHeadNodePDB` | bool | `false` | Enable PodDisruptionBudget for head nodes |
| `enableKarpenterSupport` | bool | `false` | Enable Karpenter support |
| `enableZoneNodeSelector` | bool | `false` | Enable zone-based node selection |
| `operatorExcludeComponentVerification` | array | `[]` | Components to skip during startup verification |

### Instance Types and Resources

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `defaultInstanceTypes` | object | See values.yaml | Default pod resource configurations |
| `additionalInstanceTypes` | object | `{}` | Additional pod resource configurations |
| `supportedAccelerators` | object | See values.yaml | Accelerator type mappings for scheduling |

### Networking

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ingressAddress` | string | `""` | DNS address for cluster ingress |
| `controlPlaneProxySocketPath` | string | `"/tmp/anyscale/sockets/control_plane.sock"` | Control plane proxy socket path |

## Installation

For detailed installation instructions, please refer to the [Anyscale Operator Documentation](https://docs.anyscale.com/administration/cloud-deployment/kubernetes/).
