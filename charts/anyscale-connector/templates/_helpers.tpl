{{/*
Expand the name of the chart.
*/}}
{{- define "anyscale-connector.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Truncate at 63 chars because some Kubernetes name fields are limited to this.
If Release.Name contains the chart name it will be used as-is.
*/}}
{{- define "anyscale-connector.fullname" -}}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "anyscale-connector.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "anyscale-connector.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for the connector Deployment, also matched by the
kuberay-telemetry-injector Service.
*/}}
{{- define "anyscale-connector.connector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "anyscale-connector.name" . }}
app.kubernetes.io/component: connector
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Projected-token audience, shared by every pod in this chart. Must match what Anyscale
derives per cloud resource, so it is defined once here rather than inlined per
Deployment.
*/}}
{{- define "anyscale-connector.tokenAudience" -}}
{{- $url := .Values.global.controlPlaneAudience | trimSuffix "/" -}}
{{- $cloud := required "global.cloudId is required" .Values.global.cloudId -}}
{{- $resource := required "global.cloudResourceId is required" .Values.global.cloudResourceId -}}
{{- printf "%s/oidc/clouds/%s/resources/%s" $url $cloud $resource -}}
{{- end }}

{{/*
The host every component in this chart dials. controlPlaneHost wins if set; otherwise it
is derived from the cloud id and controlPlaneDomain. The rendered value is the host to
allowlist for egress, which is why the derivation lives here rather than in the binaries.

The cloud id is lowercased with underscores turned to hyphens. It must match how Anyscale
normalizes it, so the transform is load-bearing, not cosmetic.
*/}}
{{- define "anyscale-connector.controlPlaneHost" -}}
{{- with .Values.global.controlPlaneHost -}}
{{- . -}}
{{- else -}}
{{- $cloud := required "global.cloudId is required" .Values.global.cloudId -}}
{{- $domain := required "global.controlPlaneDomain is required" .Values.global.controlPlaneDomain -}}
{{- printf "%s.%s:443" ($cloud | lower | replace "_" "-") $domain -}}
{{- end }}
{{- end }}

{{/*
Base name for the Cluster Telemetry Gateway's resources. Fixed, not derived from the chart or
release name: Anyscale updates the gateway Deployment by this name.
*/}}
{{- define "anyscale-connector.clusterTelemetry.fullname" -}}
anyscale-connector-cluster-telemetry
{{- end }}

{{/*
ServiceAccount for the Cluster Telemetry Gateway. Its own, not the connector's: the two
need different permissions (the gateway reads nodes and pods cluster-wide, the connector
writes the gateway's ConfigMap), and sharing one account would grant each the other's.
*/}}
{{- define "anyscale-connector.clusterTelemetry.serviceAccountName" -}}
{{- include "anyscale-connector.clusterTelemetry.fullname" . }}
{{- end }}

{{/*
Selector labels for the Cluster Telemetry Gateway Deployment.
*/}}
{{- define "anyscale-connector.clusterTelemetry.selectorLabels" -}}
app.kubernetes.io/name: {{ include "anyscale-connector.name" . }}
app.kubernetes.io/component: cluster-telemetry
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Renders "registry/repository:tag" for every image in this chart, so the shape lives in one
place instead of once per component.

Pass the image block, and for Anyscale-built images the registry and release tag to fall
back to when that block leaves them unset (fallbackRegistry/fallbackTag, normally
global.image.registry/global.image.tag). The fallbacks are what let a normal install, or a
mirror, set global.image.registry and global.image.tag once and have every Anyscale image
follow (vector_sidecar: registry only, pinned tag). Third-party blocks pass no fallbacks,
so they must carry their own registry and pinned tag. tagError names the
value to set when the tag resolves empty.
*/}}
{{- define "anyscale-connector.image" -}}
{{- $registry := .image.registry | default .fallbackRegistry -}}
{{- $tag := .image.tag | default .fallbackTag -}}
{{- if $registry }}{{ $registry }}/{{ end }}{{ .image.repository }}:{{ required .tagError $tag }}
{{- end }}

{{/*
Tolerations for one component's pod. A component's own list replaces global.tolerations
rather than appending, so it can be pinned to a node pool the rest of the chart is not.

Call with: (dict "tolerations" .Values.clusterTelemetry.tolerations "root" .)
*/}}
{{- define "anyscale-connector.tolerations" -}}
{{- with .tolerations | default .root.Values.global.tolerations -}}
tolerations:
{{ toYaml . | indent 2 }}
{{- end -}}
{{- end }}

{{/*
Labels for one component's pod template: the chart's selector labels, then the component's
own, then global.labels, merged into one map where the first occurrence of a key wins. So
a user label can never replace a selector label, and no key renders twice.

Call with: (dict "selector" (include "anyscale-connector.connector.selectorLabels" .) "labels" .Values.connector.labels "root" .)
*/}}
{{- define "anyscale-connector.podLabels" -}}
{{- toYaml (merge (dict) (fromYaml .selector) (.labels | default dict) (.root.Values.global.labels | default dict)) -}}
{{- end }}

{{/*
Annotations for one component's pod template: the ones the chart sets, then the component's
own, then global.annotations, merged the same way. Renders nothing when all three are
empty, so the caller can leave the annotations key out.

Call with: (dict "chart" (dict "key" "value") "annotations" .Values.connector.annotations "root" .)
*/}}
{{- define "anyscale-connector.podAnnotations" -}}
{{- with merge (dict) (.chart | default dict) (.annotations | default dict) (.root.Values.global.annotations | default dict) -}}
{{- toYaml . -}}
{{- end -}}
{{- end }}

{{/*
Base name for the Observability API's resources.
*/}}
{{- define "anyscale-connector.observabilityApi.fullname" -}}
{{- printf "%s-observability-api" (include "anyscale-connector.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
ServiceAccount for the Observability API. Its own so its projected token is scoped to
this component and not shared with the connector or the gateway.
*/}}
{{- define "anyscale-connector.observabilityApi.serviceAccountName" -}}
{{- include "anyscale-connector.observabilityApi.fullname" . }}
{{- end }}

{{/*
Selector labels for the Observability API Deployment.
*/}}
{{- define "anyscale-connector.observabilityApi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "anyscale-connector.name" . }}
app.kubernetes.io/component: observability-api
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/* Per-cloud obs host: obs-<cloudResourceId>.i.<dynamicHttpsDomain> (underscores -> dashes). */}}
{{- define "anyscale-connector.observabilityApi.host" -}}
{{- $crid := required "global.cloudResourceId is required" .Values.global.cloudResourceId -}}
{{- $domain := required "observabilityApi.ingress.dynamicHttpsDomain is required when ingress is enabled" .Values.observabilityApi.ingress.dynamicHttpsDomain -}}
{{- printf "obs-%s.i.%s" (replace "_" "-" $crid) $domain | lower }}
{{- end }}

{{/* TLS secret for the obs host; defaults to the per-cloud-resource certificate. */}}
{{- define "anyscale-connector.observabilityApi.tlsSecretName" -}}
{{- if .Values.observabilityApi.ingress.tlsSecretName -}}
{{- .Values.observabilityApi.ingress.tlsSecretName -}}
{{- else -}}
{{- printf "anyscale-%s-certificate" (replace "_" "-" (required "global.cloudResourceId is required" .Values.global.cloudResourceId)) | lower -}}
{{- end -}}
{{- end }}

{{/*
Where the gateway's GPU scrape points. Explicit clusterTelemetry values win; with the dcgm-exporter
subchart enabled and nothing set, its own Service, named by the subchart's helpers via .Subcharts.
A set value that points elsewhere is honoured; the connector warns at startup if no Service is there.
*/}}
{{- define "anyscale-connector.dcgm.namespace" -}}
{{- if .Values.clusterTelemetry.dcgmNamespace -}}
{{- .Values.clusterTelemetry.dcgmNamespace -}}
{{- else if (index .Values "dcgm-exporter").enabled -}}
{{- include "dcgm-exporter.namespace" (index .Subcharts "dcgm-exporter") -}}
{{- end -}}
{{- end }}

{{- define "anyscale-connector.dcgm.serviceName" -}}
{{- if .Values.clusterTelemetry.dcgmServiceName -}}
{{- .Values.clusterTelemetry.dcgmServiceName -}}
{{- else if (index .Values "dcgm-exporter").enabled -}}
{{- include "dcgm-exporter.fullname" (index .Subcharts "dcgm-exporter") -}}
{{- end -}}
{{- end }}
