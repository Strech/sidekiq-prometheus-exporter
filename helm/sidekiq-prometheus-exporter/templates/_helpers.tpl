{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sidekiq-prometheus-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the docker image.
*/}}
{{- define "sidekiq-prometheus-exporter.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sidekiq-prometheus-exporter.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sidekiq-prometheus-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use.
*/}}
{{- define "sidekiq-prometheus-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "sidekiq-prometheus-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create pod service account name.
*/}}
{{- define "sidekiq-prometheus-exporter.podServiceAccountName" -}}
{{- if and .Values.serviceAccount .Values.serviceAccount.create -}}
serviceAccountName: {{ include "sidekiq-prometheus-exporter.serviceAccountName" . }}
{{- end -}}
{{- end -}}

{{/*
Create pod image pull secrets.
*/}}
{{- define "sidekiq-prometheus-exporter.podImagePullSecrets" -}}
{{- if .Values.image.pullSecrets -}}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Create container environment variables.
*/}}
{{- define "sidekiq-prometheus-exporter.env" -}}
{{- if .Values.envFrom -}}
envFrom:
  {{ if eq (default "configMapRef" .Values.envFrom.type) "secretRef" -}}
  - secretRef:
      name: {{ .Values.envFrom.name }}
  {{- else -}}
  - configMapRef:
      name: {{ .Values.envFrom.name }}
  {{- end -}}
{{- else if .Values.env -}}
env:
  {{- range $name, $value := .Values.env }}
  - name: {{ $name }}
    value: {{ $value | quote }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
Expand common labels.
*/}}
{{- define "sidekiq-prometheus-exporter.labels" -}}
app.kubernetes.io/name: {{ include "sidekiq-prometheus-exporter.name" . }}
helm.sh/chart: {{ include "sidekiq-prometheus-exporter.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
