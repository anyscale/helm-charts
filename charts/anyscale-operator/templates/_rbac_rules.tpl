{{/*
Common RBAC rules for cross-namespace resource management.
This template contains the shared rules used by both ClusterRole and Role.
The conditional logic for enableCrossNamespaceResourceManagement is handled in the calling template.
*/}}
{{- define "anyscale-operator.rbac-rules" }}
  - apiGroups: [""]
    resources: ["configmaps", "services", "pods", "secrets", "events"]
    verbs: ["get", "watch", "list", "create", "update", "patch", "delete"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get", "watch", "list", "create", "update", "patch", "delete"]
{{- if .Values.networking.gateway.enabled }}
{{- if eq .Values.networking.gateway.apiVersion "networking.istio.io/v1alpha3" }}
  - apiGroups: ["networking.istio.io"]
    resources: ["virtualservices"]
    verbs: ["get", "watch", "list", "create", "update", "patch", "delete"]
{{- else }}
  - apiGroups: ["gateway.networking.k8s.io"]
    resources: ["httproutes"]
    verbs: ["get", "watch", "list", "create", "update", "patch", "delete"]
  - apiGroups: ["gateway.networking.k8s.io"]
    resources: ["referencegrants"]
    verbs: ["get", "watch", "list", "create", "update", "patch", "delete"]
{{- end }}
{{- end }}
{{- if gt (int .Values.operator.replicas) 1 }}
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ["get", "watch", "list", "create", "update", "patch", "delete"]
{{- end }}
{{- if or (.Capabilities.APIVersions.Has "kueue.x-k8s.io/v1beta1")}}
  - apiGroups: ["kueue.x-k8s.io"]
    resources: ["workloads"]
    verbs: ["get", "watch", "list", "create", "update", "patch", "delete"]
{{- end }}
{{- if .Values.workloads.kaiScheduler.enabled }}
  - apiGroups: ["scheduling.run.ai"]
    resources: ["podgroups"]
    verbs: ["get", "watch", "list", "create", "update", "patch", "delete"]
  - apiGroups: ["kai.scheduler"]
    resources: ["topologies"]
    verbs: ["get", "watch", "list", "create", "update", "patch", "delete"]
{{- end }}
{{- end }}
