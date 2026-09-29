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
{{- if .Values.obscura.database.url -}}
{{- .Values.obscura.database.url -}}
{{- else if .Values.postgresql.enabled -}}
{{- $user := .Values.postgresql.auth.username -}}
{{- $pass := .Values.postgresql.auth.password -}}
{{- $db := .Values.postgresql.auth.database -}}
{{- $host := printf "%s-postgresql" .Release.Name -}}
{{- printf "postgres://%s:%s@%s:5432/%s" $user $pass $host $db -}}
{{- else -}}
{{- fail "obscura.database.url or obscura.database.existingSecret.name is required when postgresql.enabled is false" -}}
{{- end -}}
{{- end }}

{{/*
Get the Secret containing the database URL
*/}}
{{- define "obscura.databaseSecretName" -}}
{{- if .Values.obscura.database.existingSecret.name -}}
{{- .Values.obscura.database.existingSecret.name -}}
{{- else -}}
{{- printf "%s-secret" (include "obscura.fullname" .) -}}
{{- end -}}
{{- end }}

{{/*
Get the database URL key
*/}}
{{- define "obscura.databaseSecretKey" -}}
{{- .Values.obscura.database.existingSecret.key -}}
{{- end }}

{{/*
Validate the database configuration
*/}}
{{- define "obscura.validateDatabaseConfiguration" -}}
{{- if and .Values.obscura.database.url .Values.obscura.database.existingSecret.name -}}
{{- fail "obscura.database.url and obscura.database.existingSecret.name are mutually exclusive" -}}
{{- end -}}
{{- if and .Values.postgresql.enabled (or .Values.obscura.database.url .Values.obscura.database.existingSecret.name) -}}
{{- fail "postgresql.enabled must be false when obscura.database.url or obscura.database.existingSecret.name is set" -}}
{{- end -}}
{{- if and .Values.obscura.database.existingSecret.name (not .Values.obscura.database.existingSecret.key) -}}
{{- fail "obscura.database.existingSecret.key is required when obscura.database.existingSecret.name is set" -}}
{{- end -}}
{{- if and (not .Values.postgresql.enabled) (not .Values.obscura.database.url) (not .Values.obscura.database.existingSecret.name) -}}
{{- fail "obscura.database.url or obscura.database.existingSecret.name is required when postgresql.enabled is false" -}}
{{- end -}}
{{- end }}

{{/*
Compute the PubSub URL
*/}}
{{- define "obscura.pubsubUrl" -}}
{{- if .Values.obscura.pubsub.url -}}
{{- .Values.obscura.pubsub.url -}}
{{- else if .Values.valkey.enabled -}}
{{- $pass := .Values.valkey.auth.password -}}
{{- $host := printf "%s-valkey" .Release.Name -}}
{{- printf "redis://:%s@%s:6379" $pass $host -}}
{{- end -}}
{{- end }}

{{/*
Compute the storage endpoint
*/}}
{{- define "obscura.storageEndpoint" -}}
{{- if .Values.obscura.storage.endpoint -}}
{{- .Values.obscura.storage.endpoint -}}
{{- else if .Values.rustfs.enabled -}}
{{- $rustfs := dict "Chart" (dict "Name" "rustfs") "Values" .Values.rustfs "Release" .Release -}}
{{- printf "http://%s-svc:%v" (include "rustfs.fullname" $rustfs) .Values.rustfs.service.endpoint.port -}}
{{- end -}}
{{- end }}

{{- define "obscura.storageRegion" -}}
{{- if .Values.rustfs.enabled -}}
{{- .Values.rustfs.config.rustfs.region -}}
{{- else -}}
{{- .Values.obscura.storage.region -}}
{{- end -}}
{{- end }}

{{/*
Compute the Storage Access Key
*/}}
{{- define "obscura.storageAccessKey" -}}
{{- if .Values.rustfs.enabled -}}
{{- .Values.rustfs.secret.rustfs.access_key -}}
{{- else -}}
{{- .Values.obscura.storage.accessKey -}}
{{- end -}}
{{- end }}

{{/*
Compute the Storage Secret Key
*/}}
{{- define "obscura.storageSecretKey" -}}
{{- if .Values.rustfs.enabled -}}
{{- .Values.rustfs.secret.rustfs.secret_key -}}
{{- else -}}
{{- .Values.obscura.storage.secretKey -}}
{{- end -}}
{{- end }}

{{- define "obscura.storageCredentialsSecretName" -}}
{{- if and .Values.rustfs.enabled .Values.rustfs.secret.existingSecret -}}
{{- .Values.rustfs.secret.existingSecret -}}
{{- else if .Values.obscura.storage.existingSecret.name -}}
{{- .Values.obscura.storage.existingSecret.name -}}
{{- else -}}
{{- printf "%s-secret" (include "obscura.fullname" .) -}}
{{- end -}}
{{- end }}

{{- define "obscura.storageAccessKeyName" -}}
{{- if and .Values.rustfs.enabled .Values.rustfs.secret.existingSecret -}}
RUSTFS_ACCESS_KEY
{{- else if .Values.obscura.storage.existingSecret.name -}}
{{- .Values.obscura.storage.existingSecret.accessKeyKey -}}
{{- else -}}
storage-access-key
{{- end -}}
{{- end }}

{{- define "obscura.storageSecretKeyName" -}}
{{- if and .Values.rustfs.enabled .Values.rustfs.secret.existingSecret -}}
RUSTFS_SECRET_KEY
{{- else if .Values.obscura.storage.existingSecret.name -}}
{{- .Values.obscura.storage.existingSecret.secretKeyKey -}}
{{- else -}}
storage-secret-key
{{- end -}}
{{- end }}

{{- define "obscura.validateStorageConfiguration" -}}
{{- $storage := .Values.obscura.storage -}}
{{- if not $storage.bucket -}}
{{- fail "obscura.storage.bucket is required" -}}
{{- end -}}
{{- if .Values.rustfs.enabled -}}
{{- if lt (int .Values.bucketSetup.attempts) 1 -}}
{{- fail "bucketSetup.attempts must be at least 1" -}}
{{- end -}}
{{- if or $storage.endpoint $storage.accessKey $storage.secretKey $storage.existingSecret.name -}}
{{- fail "disable rustfs.enabled before configuring external obscura.storage endpoint or credentials" -}}
{{- end -}}
{{- else -}}
{{- if not $storage.endpoint -}}
{{- fail "obscura.storage.endpoint is required when rustfs.enabled is false" -}}
{{- end -}}
{{- if $storage.existingSecret.name -}}
{{- if or $storage.accessKey $storage.secretKey (not $storage.existingSecret.accessKeyKey) (not $storage.existingSecret.secretKeyKey) -}}
{{- fail "external storage existingSecret requires both key names and no inline credentials" -}}
{{- end -}}
{{- else if or (not $storage.accessKey) (not $storage.secretKey) -}}
{{- fail "external storage requires both accessKey and secretKey, or existingSecret.name" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
Check if FCM is configured (both projectId and credentialsJson are non-empty)
*/}}
{{- define "obscura.fcmEnabled" -}}
{{- if and .Values.obscura.fcm.projectId .Values.obscura.fcm.credentialsJson -}}
true
{{- end -}}
{{- end }}