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

{{/*
Converts string passed in into a json pointer
*/}}
{{- define "anyscale-operator.jsonPointer" -}}
{{- . | replace "~" "~0" | replace "/" "~1" -}}
{{- end -}}
