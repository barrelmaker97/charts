{{/*
Expand the name of the chart.
*/}}
{{- define "obscura.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "obscura.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "obscura.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "obscura.labels" -}}
helm.sh/chart: {{ include "obscura.chart" . }}
{{ include "obscura.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "obscura.selectorLabels" -}}
app.kubernetes.io/name: {{ include "obscura.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "obscura.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "obscura.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Compute the database URL
*/}}
{{- define "obscura.databaseUrl" -}}
{{- if .Values.obscura.databaseUrl -}}
{{- .Values.obscura.databaseUrl -}}
{{- else -}}
{{- $user := .Values.postgresql.auth.username -}}
{{- $pass := .Values.postgresql.auth.password -}}
{{- $db := .Values.postgresql.auth.database -}}
{{- $host := printf "%s-postgresql" .Release.Name -}}
{{- printf "postgres://%s:%s@%s:5432/%s" $user $pass $host $db -}}
{{- end -}}
{{- end }}

{{/*
Compute the S3 endpoint
*/}}
{{- define "obscura.s3Endpoint" -}}
{{- if .Values.obscura.s3.endpoint -}}
{{- .Values.obscura.s3.endpoint -}}
{{- else if .Values.minio.enabled -}}
{{- printf "http://%s-minio:9000" .Release.Name -}}
{{- end -}}
{{- end }}

{{/*
Compute the S3 Access Key
*/}}
{{- define "obscura.s3AccessKey" -}}
{{- if .Values.obscura.s3.accessKey -}}
{{- .Values.obscura.s3.accessKey -}}
{{- else if .Values.minio.enabled -}}
{{- .Values.minio.auth.rootUser -}}
{{- end -}}
{{- end }}

{{/*
Compute the S3 Secret Key
*/}}
{{- define "obscura.s3SecretKey" -}}
{{- if .Values.obscura.s3.secretKey -}}
{{- .Values.obscura.s3.secretKey -}}
{{- else if .Values.minio.enabled -}}
{{- .Values.minio.auth.rootPassword -}}
{{- end -}}
{{- end }}
