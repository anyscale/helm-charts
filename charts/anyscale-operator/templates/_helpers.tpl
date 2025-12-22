{{/*
Validate controlPlaneURL to ensure it doesn't end with a trailing slash
*/}}
{{- define "anyscale-operator.validateControlPlaneURL" -}}
{{- $url := .Values.global.controlPlaneURL | default "https://console.anyscale.com" -}}
{{- if hasSuffix "/" $url -}}
{{- fail (printf "controlPlaneURL must not end with a trailing slash. Current value: %s" $url) -}}
{{- end -}}
{{- $url -}}
{{- end -}}

{{- define "anyscale-operator.aws_credentials" -}}
[default]
aws_access_key_id = {{ required "A valid .Values.credentialMount.aws.createSecret.accessKeyId is required if .Values.credentialMount.aws.createSecret.create is true" .Values.credentialMount.aws.createSecret.accessKeyId }}
aws_secret_access_key = {{ required "A valid .Values.credentialMount.aws.createSecret.secretAccessKey is required if .Values.credentialMount.aws.createSecret.create is true" .Values.credentialMount.aws.createSecret.secretAccessKey }}
{{- end }}

{{- define "anyscale-operator.aws_config" -}}
[default]
{{- if .Values.global.aws.region }}
region = {{ .Values.global.aws.region }}
{{- else if .Values.global.region }}
region = {{ .Values.global.region }}
{{- end }}
{{- if .Values.credentialMount.aws.createSecret.endpointUrl }}
endpoint_url = {{ .Values.credentialMount.aws.createSecret.endpointUrl }}
{{- end }}
{{- end }}

{{- define "anyscale-operator.aws_credential_mount_patch" -}}
{{- $headContainerIndices := list 0 1 2 5 -}}{{/* ray, vector, anyscaled, activity-probe */}}
{{- $workerContainerIndices := list 0 1 2 3 -}}{{/* ray, vector, anyscaled, activity-probe */}}
- kind: Pod
  selector: "anyscale.com/ray-node-type in (head)"
  patch:
    - op: add
      path: /spec/volumes/-
      value:
        name: aws-creds
        secret:
          secretName: {{ .Values.credentialMount.aws.fromSecret.name }}
    {{- range $headContainerIndices }}
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: AWS_SHARED_CREDENTIALS_FILE
        value: {{ $.Values.credentialMount.aws.fromSecret.podMountPath }}/credentials
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: AWS_CONFIG_FILE
        value: {{ $.Values.credentialMount.aws.fromSecret.podMountPath }}/config
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: AWS_SDK_LOAD_CONFIG
        value: 1
    - op: add
      path: /spec/containers/{{ . }}/volumeMounts/-
      value:
        name: aws-creds
        mountPath: {{ $.Values.credentialMount.aws.fromSecret.podMountPath }}
        readOnly: true
    {{- end }}
- kind: Pod
  selector: "anyscale.com/ray-node-type in (worker)"
  patch:
    - op: add
      path: /spec/volumes/-
      value:
        name: aws-creds
        secret:
          secretName: {{ .Values.credentialMount.aws.fromSecret.name }}
    {{- range $workerContainerIndices }}
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: AWS_SHARED_CREDENTIALS_FILE
        value: {{ $.Values.credentialMount.aws.fromSecret.podMountPath }}/credentials
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: AWS_CONFIG_FILE
        value: {{ $.Values.credentialMount.aws.fromSecret.podMountPath }}/config
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: AWS_SDK_LOAD_CONFIG
        value: 1
    - op: add
      path: /spec/containers/{{ . }}/volumeMounts/-
      value:
        name: aws-creds
        mountPath: {{ $.Values.credentialMount.aws.fromSecret.podMountPath }}
        readOnly: true
    {{- end }}
{{- end }}

{{- define "anyscale-operator.gcp_credential_mount_patch" -}}
{{- $headContainerIndices := list 0 1 2 5 -}}{{/* ray, vector, anyscaled, activity-probe */}}
{{- $workerContainerIndices := list 0 1 2 3 -}}{{/* ray, vector, anyscaled, activity-probe */}}
- kind: Pod
  selector: "anyscale.com/ray-node-type in (head)"
  patch:
    - op: add
      path: /spec/volumes/-
      value:
        name: gcp-creds
        secret:
          secretName: {{ .Values.credentialMount.gcp.fromSecret.name }}
    {{- range $headContainerIndices }}
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: GOOGLE_APPLICATION_CREDENTIALS
        value: {{ printf "%s/key.json" $.Values.credentialMount.gcp.fromSecret.podMountPath }}
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: GCLOUD_PROJECT
        value: {{ $.Values.global.gcp.projectId }}
    - op: add
      path: /spec/containers/{{ . }}/volumeMounts/-
      value:
        name: gcp-creds
        mountPath: {{ $.Values.credentialMount.gcp.fromSecret.podMountPath }}
        readOnly: true
    {{- end }}
- kind: Pod
  selector: "anyscale.com/ray-node-type in (worker)"
  patch:
    - op: add
      path: /spec/volumes/-
      value:
        name: gcp-creds
        secret:
          secretName: {{ .Values.credentialMount.gcp.fromSecret.name }}
    {{- range $workerContainerIndices }}
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: GOOGLE_APPLICATION_CREDENTIALS
        value: {{ printf "%s/key.json" $.Values.credentialMount.gcp.fromSecret.podMountPath }}
    - op: add
      path: /spec/containers/{{ . }}/env/-
      value:
        name: GCLOUD_PROJECT
        value: {{ $.Values.global.gcp.projectId }}
    - op: add
      path: /spec/containers/{{ . }}/volumeMounts/-
      value:
        name: gcp-creds
        mountPath: {{ $.Values.credentialMount.gcp.fromSecret.podMountPath }}
        readOnly: true
    {{- end }}
{{- end }}
{{/*
Converts string passed in into a json pointer
*/}}
{{- define "anyscale-operator.jsonPointer" -}}
{{- . | replace "~" "~0" | replace "/" "~1" -}}
{{- end -}}
