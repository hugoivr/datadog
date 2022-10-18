# EKS on Fargate (ES)
Esta es una guía simplificada para el despliegue de los agentes de Datadog sobre *EKS on Fargate*:

## Paso 1: Definición de RBAC

Se aplica el siguiente manifiesto definiendo el RBAC necesario para el despliegue del agente como sidecar:

``` yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: datadog-agent
rules:
  - apiGroups:
    - ""
    resources:
    - nodes
    - namespaces
    verbs:
    - get
    - list
  - apiGroups:
      - ""
    resources:
      - nodes/metrics
      - nodes/spec
      - nodes/stats
      - nodes/proxy
      - nodes/pods
      - nodes/healthz
    verbs:
      - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: datadog-agent
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: datadog-agent
subjects:
  - kind: ServiceAccount
    name: datadog-agent
    namespace: default
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: datadog-agent
  namespace: default

```

## PASO 2: Despliegue de Agente como sidecar

*EKS on Fargate* abstrae el concepto de host o de nodo, por lo que todas las cargas de trabajo corren sobre nodos Fargate para los cuales no tenemos control o administración. Es por esto que el agente de Datadog necesita ser ejecutado como un sidecar junto a los contenedores y pods aplicativos. La definición del agente debe ir en conjunto con los deployments aplicativos para asegurar que sean ejecutados en el mismo nodo de Fargate y pueda entonces colectar las métricas de performance y trazas.

En este caso, el agente de Datadog debe ir definido dentro del manifiesto de las aplicaciones. En este caso. El siguiente ejemplo muestra un manifiesto de despliegue de una aplicación con el agente de Datadog como sidecar. En este caso, se busca segmentar de forma clara con los comentarios, donde empieza el fragmento que define el sidecar del agente de Datadog:

```yaml
apiVersion: apps/v1
kind: Deployment
# Todos los campos con valor APPLICATION_NAME hacen referencia a las definiciones
# del despliegue de los contenedores aplicativos y son solamente un ejemplo de la forma
# en la que se despliega el agente como sidecar.
metadata:
  name: "<APPLICATION_NAME>"
  namespace: default
spec:
  selector:
    matchLabels:
      app: "<APPLICATION_NAME>"
  replicas: 1
  template:
    metadata:
      labels:
        app: "<APPLICATION_NAME>"
      name: "<POD_NAME>"
    spec:
      containers:
      - name: "<APPLICATION_NAME>"
        image: "<APPLICATION_IMAGE>"
     ########################################################################## 
     ## Definición del agente como Sidecar 
     ##########################################################################
      - name: datadog-agent
        image: datadog/agent
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        env:
        - name: DD_API_KEY
          value: "<YOUR_DATADOG_API_KEY>"
        - name: DD_SITE
          value: "datadoghq.com"
        - name: DD_EKS_FARGATE
          value: "true"
        - name: DD_CLUSTER_NAME
          value: "<CLUSTER_NAME>"
        - name: DD_KUBERNETES_KUBELET_NODENAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: spec.nodeName
      ##########################################################################
      ## Variables para comunicar agentes y Cluster Agent
      ##########################################################################
        - name: DD_CLUSTER_AGENT_ENABLED
          value: "true"
          # Se requiere un token de autenticación entre el Cluster Agent y los agentes
          # El token puede ser una llave generada de forma manual y colocarse en texto plano
          # El token puede ser un Secret y accederse usando valueFrom para evitar el texto plano
          # A continuación ambas opciones: 
        - name: DD_CLUSTER_AGENT_AUTH_TOKEN
          value: <Token en texto plano> # Reemplazar este valor con el token
          # En caso de querer evitar usar el token en texto plano:
          # valueFrom:
          #   secretKeyRef:
          #     name: <AUTH_TOKEN_SECRET_NAME>  
          #     key: <AUTH_TOKEN_KEY>
        - name: DD_CLUSTER_AGENT_URL
          # En este caso hay que reemplazar los valores adecuados para referenciar al cluster agent:
          # Al ser desplegado por Helm, el cluster agent toma el formato <RELEASE_NAME>-cluster-agent
          # El namespace en el que fue desplegado el servicio del cluster agent
          value: https://<CLUSTER_AGENT_SERVICE_NAME>.<CLUSTER_AGENT_SERVICE_NAMESPACE>.svc.cluster.local:5005
        - name: DD_ORCHESTRATOR_EXPLORER_ENABLED # Required to get Kubernetes resources view
          value: "true"
      serviceAccountName: datadog-agent  
```

## Paso 3: Despliegue del Cluster Agent
El despliegue del Cluster Agent se realiza utilizando Helm para simplificar la creación de RBAC y servicios involucrados. Seguimos el procedimiento para despliegue por Helm:

Instalar el chart de Helm
``` bash
helm repo add datadog https://helm.datadoghq.com
helm repo update
```
Crear el namespace de Datadog y los secrets necesarios
``` bash
kubectl create ns datadog
kubectl create secret generic datadog-keys -n datadog --from-literal=api-key=<API-KEY>
# Si se quiere crear un secret para el auth token del cluster agent
# kubectl create secret generic cluster-agent-auth-token -n --from-literal=auth-token=<AUTH-TOKEN>

```
El values.yaml se debe usar como entrada para Helm. No es un manifiesto valido para aplicarse directamente sobre el cluster. Usar values.yaml para despliegue exclusivo del Cluster Agent:

``` yaml
# values.yaml
datadog:
  apiKey: <YOUR_DATADOG_API_KEY> # De acuerdo al ejemplo: datadog-keys
  clusterName: <CLUSTER_NAME>    # Hacer match con el despliegue de sidecar de los agentes
agents:
  enabled: false
clusterAgent:
  enabled: true
  replicas: 2
  token: <Token en texto plano>
  # Para evitar Texto Plano
  # tokenExistingSecret: <Nombre del secret que contiene el auth token>
```

Desplegar el char de Helm:

``` bash
helm install datadog datadog/datadog -n datadog -f values.yaml
```
