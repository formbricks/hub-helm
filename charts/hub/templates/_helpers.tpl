{{/*
Expand the name of the chart.
*/}}
{{- define "hub.name" -}}
{{- default .Chart.Name .Values.hub.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "hub.fullname" -}}
{{- if .Values.hub.fullnameOverride }}
{{- .Values.hub.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.hub.nameOverride }}
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
{{- define "hub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hub.labels" -}}
helm.sh/chart: {{ include "hub.chart" . }}
{{ include "hub.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hub.serviceAccountName" -}}
{{- if .Values.hub.serviceAccount.create }}
{{- default (include "hub.fullname" .) .Values.hub.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.hub.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host
*/}}
{{- define "hub.postgresql.host" -}}
{{- if .Values.cloudnativepg.enabled }}
{{- printf "%s-rw" (include "hub.fullname" .) }}
{{- else }}
{{- .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "hub.postgresql.port" -}}
{{- if .Values.cloudnativepg.enabled }}
{{- print "5432" }}
{{- else }}
{{- .Values.externalDatabase.port }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "hub.postgresql.database" -}}
{{- if .Values.cloudnativepg.enabled }}
{{- .Values.cloudnativepg.cluster.bootstrap.initdb.database }}
{{- else }}
{{- .Values.externalDatabase.database }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "hub.postgresql.username" -}}
{{- if .Values.cloudnativepg.enabled }}
{{- .Values.cloudnativepg.cluster.bootstrap.initdb.owner }}
{{- else }}
{{- .Values.externalDatabase.username }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret name
*/}}
{{- define "hub.postgresql.secretName" -}}
{{- if .Values.cloudnativepg.enabled }}
{{- printf "%s-app" (include "hub.fullname" .) }}
{{- else if .Values.externalDatabase.existingSecret.name }}
{{- .Values.externalDatabase.existingSecret.name }}
{{- else }}
{{- printf "%s-postgresql" (include "hub.fullname" .) }}
{{- end }}
{{- end }}

{{/*
PostgreSQL password secret key
*/}}
{{- define "hub.postgresql.secretKey" -}}
{{- if .Values.cloudnativepg.enabled }}
{{- print "password" }}
{{- else if .Values.externalDatabase.existingSecret.name }}
{{- .Values.externalDatabase.existingSecret.key }}
{{- else }}
{{- print "password" }}
{{- end }}
{{- end }}

{{/*
Database URL
*/}}
{{- define "hub.databaseUrl" -}}
{{- if .Values.hub.config.databaseUrl }}
{{- .Values.hub.config.databaseUrl }}
{{- else }}
{{- $host := include "hub.postgresql.host" . }}
{{- $port := include "hub.postgresql.port" . }}
{{- $database := include "hub.postgresql.database" . }}
{{- $username := include "hub.postgresql.username" . }}
{{- $sslMode := .Values.externalDatabase.sslMode | default "disable" }}
{{- printf "postgresql://%s:$(DB_PASSWORD)@%s:%s/%s?sslmode=%s" $username $host $port $database $sslMode }}
{{- end }}
{{- end }}

{{/*
Image name
*/}}
{{- define "hub.image" -}}
{{- $tag := .Values.hub.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.hub.image.repository $tag }}
{{- end }}
