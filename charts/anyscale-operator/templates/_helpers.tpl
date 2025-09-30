{{/*
Validate controlPlaneURL to ensure it doesn't end with a trailing slash
*/}}
{{- define "anyscale-operator.validateControlPlaneURL" -}}
{{- $url := .Values.controlPlaneURL | default "https://console.anyscale.com" -}}
{{- if hasSuffix "/" $url -}}
{{- fail (printf "controlPlaneURL must not end with a trailing slash. Current value: %s" $url) -}}
{{- end -}}
{{- $url -}}
{{- end -}}

{{- define "anyscale-operator.aws_credentials" -}}
[default]
aws_access_key_id = {{ required "A valid .Values.aws.credentialSecret.accessKeyId is required if .Values.aws.credentialSecret.create is true" .Values.aws.credentialSecret.accessKeyId }}
aws_secret_access_key = {{ required "A valid .Values.aws.credentialSecret.secretAccessKey is required if .Values.aws.credentialSecret.create is true" .Values.aws.credentialSecret.secretAccessKey }}
{{- end }}

{{- define "anyscale-operator.aws_config" -}}
[default]
region = {{ .Values.region }}
{{- if .Values.aws.credentialSecret.endpointUrl }}
endpoint_url = {{ .Values.aws.credentialSecret.endpointUrl }}
{{- end }}
{{- end }}

{{- define "anyscale-operator.aws_credential_mount_patch" -}}
- kind: Pod
  patch:
    - op: add
      path: /spec/volumes/-
      value:
        name: aws-creds
        secret:
          secretName: {{ .Values.aws.credentialSecret.name }}
    - op: add
      path: /spec/containers/0/volumeMounts/-  # 0 = ray
      value:
        name: aws-creds
        mountPath: {{ .Values.aws.credentialSecret.podMountPath }}
        readOnly: true
    - op: add
      path: /spec/containers/2/volumeMounts/-  # 2 = anyscaled
      value:
        name: aws-creds
        mountPath: {{ .Values.aws.credentialSecret.podMountPath }}
        readOnly: true
    - op: add
      path: /spec/containers/0/env/-
      value:
        name: AWS_SHARED_CREDENTIALS_FILE
        value: {{ .Values.aws.credentialSecret.podMountPath }}/credentials
    - op: add
      path: /spec/containers/2/env/-
      value:
        name: AWS_SHARED_CREDENTIALS_FILE
        value: {{ .Values.aws.credentialSecret.podMountPath }}/credentials
{{- end }}

{{/*
Converts string passed in into a json pointer
*/}}
{{- define "anyscale-operator.jsonPointer" -}}
{{- . | replace "~" "~0" | replace "/" "~1" -}}
{{- end -}}
