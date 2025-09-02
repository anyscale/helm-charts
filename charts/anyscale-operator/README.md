# Anyscale Operator Helm Chart

The Anyscale Operator Helm Chart enables the deployment and management of Anyscale workloads on Kubernetes clusters. This chart provides a comprehensive set of configuration options to customize the operator's behavior according to your specific requirements.

## Configuration

The following sections detail the configurable parameters available in the chart. Each parameter is documented with its type, default value, and purpose.

## Required values

The following are required values for the Anyscale Operator.

### Core Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cloudDeploymentId` | string | `""` | Anyscale cloud deployment ID (e.g. `cldrsrc_abcdefgh12345678ijklmnop12`). This is created when you register the Anyscale cloud. If you do not have this available, you can retrieve it using `anyscale cloud config get --name <cloud_name>`  |
| `cloudProvider` | string | `""` | Cloud provider environment. Allowed values: `aws`, `gcp`, `azure`, `generic` |
| `region` | string | `""` | Cloud region for deployment |
| `anyscaleCliToken` | string | `""` | Anyscale CLI token for control plane authentication. Falls back to cloud provider identity if not set. This is required for Azure and Generic deployments. |
| `operatorIamIdentity` | string | `""` | Cloud provider IAM identity (AWS role ARN , GCP service account email, Azure identity) |

## Advanced Configuration

For advanced usage consult with Anyscale support.

### Kubernetes Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `workloadServiceAccountName` | string | `""` | Service account for Anyscale workload pods |
| `kubeConfigPath` | string | `""` | Path to kubeconfig file. Suggested to use the defaults. For advanced usage consult with Anyscale support. |
| `kubernetesClientRateLimiterQPS` | float32 | `1000` | Kubernetes API server QPS rate limit. Suggested to use the defaults. For advanced usage consult with Anyscale support. |
| `kubernetesClientRateLimiterBurst` | int | `2000` | Kubernetes API server burst rate limit. Suggested to use the defaults. For advanced usage consult with Anyscale support. |
| `additionalPatches` | array | `[]` | Additional patches that will be applied to Pods and other Kubernetes resources |
| `workloadDefaultTolerances` | object | See values.yaml | Default tolerances for workloads (includes configurations for all, gpu, and spot workloads) |

### Performance and Resource Management

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `unscheduledPodReaperReconcileInterval` | duration | `1m` | Unscheduled pod cleanup interval, reaper probes every default=1m, works together with unscheduled... at which point termination will occur |
| `unscheduledPodReaperTerminationThreshold` | duration | `10m` | Time threshold for unscheduled pod termination. If a pod remains unscheduled beyond this duration, it will be terminated. |

### High Availability

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `operatorReplicas` | int | `1` | Number of operator replicas, if the value is larger than 1, leader election will be enabled. |

### Resource Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `operatorResources.operator.requests.memory` | string | `512Mi` | Operator container memory request |
| `operatorResources.operator.requests.cpu` | string | `1` | Operator container CPU request |
| `operatorResources.operator.limits.memory` | string | `2Gi` | Operator container memory limit |
| `operatorResources.vector.requests.cpu` | string | `100m` | Vector sidecar CPU request |
| `operatorResources.vector.requests.memory` | string | `512Mi` | Vector sidecar memory request |
| `operatorResources.vector.limits.memory` | string | `512Mi` | Vector sidecar memory limit |

### Instance Types and Resources

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `defaultInstanceTypes` | object | See values.yaml | Default pod resource configurations |
| `additionalInstanceTypes` | object | `{}` | Additional pod resource configurations |
| `supportedAccelerators` | object | See values.yaml | Accelerator type mappings for scheduling |
| `acceleratorNodeSelector` | string | `""` | Node selector key to use when scheduling pods with accelerators. If not set, the default key for the cloud provider will be used |

### Networking

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ingressAddress` | string | `""` | DNS address for cluster ingress. Only required when needing to override what is provided by the ingress resource. |
| `enableGateway` | bool | `false` | Enable gateway functionality for load balancing |
| `gatewayName` | string | `""` | Name of the gateway to be used |
| `gatewayIp` | string | `""` | IP address of the gateway. Either gatewayIp or gatewayHostname should be provided when using gateway. |
| `gatewayHostname` | string | `""` | Hostname of the gateway. Either gatewayIp or gatewayHostname should be provided when using gateway. |
| `gatewayAPIVersion` | string | `"gateway.networking.k8s.io/v1"` | API version of the gateway. Supported values: `gateway.networking.k8s.io/v1`, `networking.istio.io/v1alpha3` |

### Storage Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `storageS3UsePathStyle` | bool | `false` | Use path-style S3 URLs instead of virtual-hosted-style URLs |

### Other Advanced Features

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableAnyscaleRayHeadNodePDB` | bool | `true` | Enable PodDisruptionBudget for head nodes |
| `enableKarpenterSupport` | bool | `false` | Enable Karpenter support |
| `enableZoneNodeSelector` | bool | `false` | Enable zone-based node selection |
| `operatorExcludeComponentVerification` | array | `[]` | Components to skip during startup verification |
| `operatorImage` | string | `"public.ecr.aws/v0b8w7e3/anyscale/kubernetes_manager:ci-1449ce2282c302f4da4378daa67c6073d78686a7"` | Docker image to use for the Anyscale Operator. Updated with helm releases. Anyscale support may provide preview version of image for debugging. |
| `operatorImagePullPolicy` | string | `"IfNotPresent"` | imagePullPolicy for the Anyscale Operator. |
| `vectorImage` | string | `"timberio/vector:0.40.0-debian"` | Docker image to use for the Vector sidecar. |
| `vectorImagePullPolicy` | string | `"IfNotPresent"` | imagePullPolicy for the Vector sidecar. |


## Installation

For detailed installation instructions, please refer to the [Anyscale Operator Documentation](https://docs.anyscale.com/administration/cloud-deployment/kubernetes/).
