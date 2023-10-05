{{/*
Expand the name of the chart.
*/}}
{{- define "vvdn-ice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vvdn-ice.fullname" -}}
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
{{- define "vvdn-ice.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vvdn-ice.labels" -}}
helm.sh/chart: {{ include "vvdn-ice.chart" . }}
{{ include "vvdn-ice.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vvdn-ice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vvdn-ice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vvdn-ice.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vvdn-ice.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-coap-transport to use
*/}}
{{- define "helpers.list-env-tb-coap-transport"}}

{{- range $key, $val := .Values.tb_coap_transport.statefulset.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-http-transport to use
*/}}
{{- define "helpers.list-env-tb-http-transport"}}

{{- range $key, $val := .Values.tb_http_transport.statefulset.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-js-executor to use
*/}}
{{- define "helpers.list-env-tb-js-executor"}}

{{- range $key, $val := .Values.js_executor.deployment.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-kafka to use
*/}}
{{- define "helpers.list-env-tb-kafka"}}

{{- range $key, $val := .Values.kafka.statefulset.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-lwm2m to use
*/}}
{{- define "helpers.list-env-tb-lwm2m-transport"}}

{{- range $key, $val := .Values.tb_lwm2m_transport.statefulset.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-mqtt to use
*/}}
{{- define "helpers.list-env-tb-mqtt-transport"}}

{{- range $key, $val := .Values.tb_mqtt_transport.statefulset.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-node to use
*/}}
{{- define "helpers.list-env-tb-node"}}

{{- range $key, $val := .Values.node.statefulSet.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-snmp to use
*/}}
{{- define "helpers.list-env-tb-snmp-transport"}}

{{- range $key, $val := .Values.tb_snmp_transport.statefulset.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-webui to use
*/}}
{{- define "helpers.list-env-tb-webui"}}

{{- range $key, $val := .Values.web_ui.deployment.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Create the env for tb-zookeeper to use
*/}}
{{- define "helpers.list-env-tb-zookeeper"}}

{{- range $key, $val := .Values.zookeeper.statefulset.env  }}
     - name: {{ $key }}
       value: {{ $val | quote }}
{{- end }}
{{- end }}


