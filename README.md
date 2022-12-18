# Introduction

## Changelog since Service V1 and Environment V1 Release

### Please read this before Upgrade!
- Service V1 and Environment V1 APIs are being deprecated on March 2023. 
- Existing pipelines referencing Service V1 and Environment V1 will run the risk of failure and no longer work. 
- Harness will globally enable Service and Environments V2 APIs for all clients at the end of January 2023.
- Harness has an automated tool to help migrate your services

## Changes by Kind
### Service 

- Service has a mandatory definition that needs to be configured via API or UI in order to use the service in a Pipeline

```
service:
  name: nginx-canary
  identifier: nginxcanary
## In V2, a Service Definition needs to be provided with the Service in order for it to be used in a pipeline 
  serviceDefinition:
    type: Kubernetes
    spec:
## You will need to provide a path to your Service Manifests (i.e. Kubernetes Manifests)
      manifests:
        - manifest:
            identifier: nginx
            type: K8sManifest
            spec:
              store:
                type: Github
                spec:
                  connectorRef: ProductManagementRohan
                  gitFetchType: Branch
                  paths:
                    - traffic-shifting-nginx/backend/deployment.yaml
                    - traffic-shifting-nginx/backend/service.yaml
                    - traffic-shifting-nginx/backend/nginx.yaml
                    - traffic-shifting-nginx/frontend/ui.yaml
                  repoName: Product-Management
                  branch: main
              valuesPaths:
                - traffic-shifting-nginx/values.yaml
              skipResourceVersioning: false
## You will need to add an artifact if you want to pass an image tag in at pipeline runtime 
## this is also associated with the service configuration
      artifacts:
        primary:
          primaryArtifactRef: <+input>
          sources:
            - spec:
                connectorRef: public_dockerhub
                imagePath: library/nginx
                tag: <+input>
              identifier: nginx
              type: DockerRegistry
 ## NEW CAPABILITY: We now have service variables that are mapped and managed with the service
 ## this can be overwritten when deploying the service to different environments
      variables:
        - name: canaryName
          type: String
          description: ""
          value: colors-canary
        - name: host
          type: String
          description: ""
          value: nginx-canary.harness.io
        - name: name
          type: String
          description: ""
          value: colors
        - name: stableName
          type: String
          description: ""
          value: colors-stable
  gitOpsEnabled: false

```

- When creating a service via Harness REST API - Harness has exposed a new endpoint - https://apidocs.harness.io/tag/Services#operation/createServiceV2 

*Sample Payload Request*

```
{
  "identifier": "string",
  "orgIdentifier": "string",
  "projectIdentifier": "string",
  "name": "string",
  "description": "string",
  "tags": {
    "property1": "string",
    "property2": "string"
  },
## NEW PART OF THE SERVICE API PAYLOAD
## the YAML is optional is to provide via API for Service creation. 
## It's mandatory for Pipeline use

  "yaml": "string" 
}
```

*Sample Payload Response*


