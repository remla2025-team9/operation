{{- define "app-helm-chart.fullname" -}}
{{- printf "%s-%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
