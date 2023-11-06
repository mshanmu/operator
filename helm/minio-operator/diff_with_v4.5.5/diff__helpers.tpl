diff --git a/helm/minio-operator/templates/_helpers.tpl b/helm/minio-operator/templates/_helpers.tpl
index 5a96945..91e5194 100644
--- a/helm/minio-operator/templates/_helpers.tpl
+++ b/helm/minio-operator/templates/_helpers.tpl
@@ -3,7 +3,7 @@
 Expand the name of the chart.
 */}}
 {{- define "minio-operator.name" -}}
-{{- default .Chart.Name | trunc 63 | trimSuffix "-" -}}
+  {{- default .Chart.Name | trunc 63 | trimSuffix "-" -}}
 {{- end -}}
 
 {{/*
@@ -12,19 +12,19 @@ We truncate at 63 chars because some Kubernetes name fields are limited to this
 If release name contains chart name it will be used as a full name.
 */}}
 {{- define "minio-operator.fullname" -}}
-{{- $name := default .Chart.Name -}}
-{{- if contains $name .Release.Name -}}
-{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
-{{- else -}}
-{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
-{{- end -}}
+  {{- $name := default .Chart.Name -}}
+  {{- if contains $name .Release.Name -}}
+    {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
+  {{- else -}}
+    {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
+  {{- end -}}
 {{- end -}}
 
 {{/*
 Expand the name of the Operator Console.
 */}}
 {{- define "minio-operator.console-name" -}}
-{{- printf "%s-%s" .Chart.Name "console" | trunc 63 | trimSuffix "-" -}}
+  {{- printf "%s-%s" .Chart.Name "console" | trunc 63 | trimSuffix "-" -}}
 {{- end -}}
 
 {{/*
@@ -33,14 +33,14 @@ We truncate at 63 chars because some Kubernetes name fields are limited to this
 If release name contains chart name it will be used as a full name.
 */}}
 {{- define "minio-operator.console-fullname" -}}
-{{- printf "%s-%s" .Release.Name "console" | trunc 63 | trimSuffix "-" -}}
+  {{- printf "%s-%s" .Release.Name "console" | trunc 63 | trimSuffix "-" -}}
 {{- end -}}
 
 {{/*
 Create chart name and version as used by the chart label.
 */}}
 {{- define "minio-operator.chart" -}}
-{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
+  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
 {{- end -}}
 
 {{/*
@@ -82,3 +82,17 @@ Selector labels Operator
 app.kubernetes.io/name: {{ include "minio-operator.name" . }}
 app.kubernetes.io/instance: {{ printf "%s-%s" .Release.Name "console" }}
 {{- end -}}
+
+
+{{/*
+Renders a value that contains template.
+Usage:
+{{ include "minio-operator.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
+*/}}
+{{- define "minio-operator.render" -}}
+  {{- if typeIs "string" .value }}
+    {{- tpl .value .context }}
+  {{- else }}
+    {{- tpl (.value | toYaml) .context }}
+  {{- end }}
+{{- end -}}
