# Introduction

In order to provide the best software delivery experience for our customers, Harness has introduced an enhanced experience for Service and Environment entities (V2) in the CD NextGen platform.

The new V2 experience will go into effect on Jan 31, 2023 as the default experience. Except for specific accounts, the current V1 experience will then be removed for all accounts at that time.

## Why Make the Change:
The enhanced Service and Environment feature (V2) comes with a more robust Service and Environment entity that has service variables, independent infrastructure definitions, environment groups, and capabilities to override files and variables. When adopting V2 Service and Environments, you will notice an overall reduction in configuration baked into the pipelines. These changes are also reflected in the the Harness APIs as well. 

All new deployment swimlanes (ECS, Deployment Template, SSH, WinRM, etc.) are only available on the new V2 Experience. New innovations such as Enterprise GitOps, Support for multi-Service and multi-Environment along with the ability to group Environments in an Environment Group will also be based on the V2 experience. The new V2 experience has been designed to provided users and organizations with simpler configuration and ability to scale.

### IMPACT
- Existing Users and Projects in the UI
- There is no impact on your existing pipelines using V1 services and environments. Post 1/31/2023, when you create a new stage, in an existing pipeline, - V2 experience will be the default. 
- Please note that any new services and environments that are created in	Harness will be on the new V2 experience. 

### API
Harness introduced two new APIs to support the V2 Experience. The API reference is shared in the Document Resources/API Documentation section. 
- https://apidocs.harness.io/tag/Environments#operation/createEnvironmentV2
h- ttps://apidocs.harness.io/tag/Services#operation/createServiceV2

### TERRAFORM AUTOMATION
Customers will need to update their service/environment automation to use V2 APIs. 
- https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_service 
- https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_environment 
- https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_infrastructure 

--- 

## Changelog since Service V1 and Environment V1 Release

### Please read this before Upgrade!
- Service V1 and Environment V1 APIs are being deprecated on March 2023. 
- Existing pipelines referencing Service V1 and Environment V1 will run the risk of failure and no longer work after March 2023. 
- Harness will globally enable Service and Environments V2 APIs for all clients at the end of January 2023. T
- The forced change is needed to reduce the migration effort needed for users
- Harness has an automated tool to help migrate your services and environments from the v1 to v2 

## Changes by Kind
### Service 

- Services now has a definition that needs to be configured via API or UI in order to use the service in a Pipeline
- The Service Definition is a firm configuration that is mapped to the Service irrespective of the Pipeline it's being referenced in
- Documentation on Service V2: https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#creating_v2_services 
- The Service object is now removed from the Pipeline and is a stand alone object that contains 3 things:

```
1. Name, Description, Tag, Identifier [Same as Service V1 Experience]
2. Manifests, Artifacts [The Service Manifests and the artifacts are now mapped in the Service object, they are moved out of the pipeline definition
3. Service Variables - Variables are now associated with the Service and can be used for override
```

#### YAML Updates

```
service:
  name: nginx-canary
  identifier: nginxcanary
  
## SERVICE V2 UPDATE
## In V2, a Service Definition needs to be provided with the Service in order for it to be used in a pipeline 

  serviceDefinition:
    type: Kubernetes
    spec:
    
## SERVICE V2 UPDATE  
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
              
## SERVICE V2 UPDATE
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
            
 ## SERVICE V2 UPDATE
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

#### REST API UPDATES

- When creating a service via Harness REST API - Harness has exposed a new endpoint - https://apidocs.harness.io/tag/Services#operation/createServiceV2 

**Sample Payload Request**

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
## It's mandatory for the service to be used in a Pipeline 
## YAML is the Service Definition YAML passed as a string

  "yaml": "string" 
}
```

**Sample Payload Response**

```
{
  "status": "SUCCESS",
  "data": {
    "service": {
      "accountId": "string",
      "identifier": "string",
      "orgIdentifier": "string",
      "projectIdentifier": "string",
      "name": "string",
      "description": "string",
      "deleted": true,
      "tags": {
        "property1": "string",
        "property2": "string"
      },
      "yaml": "string"
    },
    "createdAt": 0,
    "lastModifiedAt": 0
  },
  "metaData": {},
  "correlationId": "string"
}
```

#### TERRAFORM PROVIDER

- The Terraform Provider Service Resource Endpoint HAS NOT CHANGED - https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_service 
- The Service Resource Payload has a new field added for Service Creation - YAML 
- YAML is not mandatory for service object creation 
- When creating a service without YAML defined, it will create a skeleton service that cannot be used for immediate deployment
- The YAML field defines the actual definition of the Service so it can be used in a Pipeline for deployment

```
resource "harness_platform_service" "example" {
  identifier  = "identifier"
  name        = "name"
  description = "test"
  org_id      = "org_id"
  project_id  = "project_id"
  
## SERVICE V2 UPDATE
## We now take in a YAML that can define the service definition for a given Service
## It isn't mandatory for Service creation 
## It is mandatory for Service use in a pipeline

  yaml        = <<-EOT
                service:
                  name: name
                  identifier: identifier
                  serviceDefinition:
                    spec:
                      manifests:
                        - manifest:
                            identifier: manifest1
                            type: K8sManifest
                            spec:
                              store:
                                type: Github
                                spec:
                                  connectorRef: <+input>
                                  gitFetchType: Branch
                                  paths:
                                    - files1
                                  repoName: <+input>
                                  branch: master
                              skipResourceVersioning: false
                      configFiles:
                        - configFile:
                            identifier: configFile1
                            spec:
                              store:
                                type: Harness
                                spec:
                                  files:
                                    - <+org.description>
                      variables:
                        - name: var1
                          type: String
                          value: val1
                        - name: var2
                          type: String
                          value: val2
                    type: Kubernetes
                  gitOpsEnabled: false
              EOT
}
```


### Environment

- Environment is now a standalone object that has global environment variable configuration, manifest configurations associated with it
- The Environment variables can override the variables defined at the Service Variable. Variable Override Information Details: https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#service_overrides 
- Documentation on Environments V2: https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#creating_and_using_v2_environments
- Harness introduced Environment Groups, this allows users to group their environments and manage them at scale. It's a list of Environments that can allow users to deploy to a subset of environments within the group or all of them at once.
- Harness introduced Environment Service Overrides, Environment Variables defined can override Service variables when the service is deployed into a given environment. Based on the variable name Harness can override the service variable with the environment variable value. 
- Harness has introduced Service specific Environment overrides where users can define specific services and variables they want to override for a given environment. For More Information: https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#override_priority 


#### YAML Updates

```
environment:
  name: staging
  identifier: staging
  tags: {}
  type: PreProduction
  orgIdentifier: default
  projectIdentifier: Rohan

## ENVIRONMENT V2 UPDATE
## Environments now have variables that can be associated with it
## These Variables are globally defined and can be accessed when the environment is referenced in the pipeline

  variables:
    - name: db_host
      type: String
      value: postgres-staging
      description: ""
    - name: DB_PASS_STAGING
      type: Secret
      value: Rohan_QA
      description: ""
 
 ## ENVIRONMENT V2 UPDATE    
 ## Environment specific property files like Values.yaml (K8s) can now be mapped to the Environment as well in the manifest block

  overrides:
    manifests:
      - manifest:
          identifier: staging
          type: Values
          spec:
            store:
              type: Github
              spec:
                connectorRef: ProductManagementRohan
                gitFetchType: Branch
                paths:
                  - cdng/staging-values.yaml
                repoName: Product-Management
                branch: main

```

#### REST API UPDATES

- When creating a Environment via Harness REST API - Harness has exposed a new endpoint - https://apidocs.harness.io/tag/Environments#operation/createEnvironmentV2 
- The YAML parameter is not required for Environment Creation or usage in a pipeline
- Harness has a new API Endpoint for Environment Groups: https://apidocs.harness.io/tag/EnvironmentGroup#operation/postEnvironmentGroup 
- Harness has a new API Endpoint for Service Specific Environment Overrides: https://apidocs.harness.io/tag/Environments#operation/upsertServiceOverride 


##### Environment REST Request Changes 

```
{
  "orgIdentifier": "string",
  "projectIdentifier": "string",
  "identifier": "string",
  "tags": {
    "property1": "string",
    "property2": "string"
  },
  "name": "string",
  "description": "string",
  "color": "string",
  "type": "PreProduction",
  
## ENVIRONMENT V2 UPDATE
## User's can now pass in the Environment Variables and Overrides via YAML Payload 
## NOTE: This field is not mandatory for Environment Creation or Usage in a Pipeline

  "yaml": "string"
}
```

#### TERRAFORM PROVIDER

- The Terraform Provider Environment Resource Endpoint HAS NOT CHANGED -https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_environment 
- The Environment Resource Payload has a new field added for Environment Creation - YAML 
- YAML is NOT mandatory for Environment object creation 
- Harness has a new Resource Endpoint for Environment Groups: https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_environment_group 
- Harness has a new Resource Endpoint for Environment Service Configuration Overrides: https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_environment_service_overrides


##### New Terraform Provider Environment Resource

```
resource "harness_platform_environment" "example" {
  identifier = "identifier"
  name       = "name"
  org_id     = "org_id"
  project_id = "project_id"
  tags       = ["foo:bar", "baz"]
  type       = "PreProduction"

## ENVIRONMENT V2 Update
## The YAML is needed if you want to define the Environment Variables and Overrides for the environment
## Not Mandatory for Environment Creation nor Pipeline Usage

  yaml       = <<-EOT
               environment:
         name: name
         identifier: identifier
         orgIdentifier: org_id
         projectIdentifier: project_id
         type: PreProduction
         tags:
           foo: bar
           baz: ""
         variables:
           - name: envVar1
             type: String
             value: v1
             description: ""
           - name: envVar2
             type: String
             value: v2
             description: ""
         overrides:
           manifests:
             - manifest:
                 identifier: manifestEnv
                 type: Values
                 spec:
                   store:
                     type: Git
                     spec:
                       connectorRef: <+input>
                       gitFetchType: Branch
                       paths:
                         - file1
                       repoName: <+input>
                       branch: master
           configFiles:
             - configFile:
                 identifier: configFileEnv
                 spec:
                   store:
                     type: Harness
                     spec:
                       files:
                         - account:/Add-ons/svcOverrideTest
                       secretFiles: []
      EOT
}
```

### Infrastructure Definition 
- Harness has taken the Infrastructure Definition that was originally defined in the pipeline and now moves it to the Environment. For more information: https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#infrastructure_definitions
- The Infrastructure definition can only be associated with 1 environment
- The Infrastructure Definition is required for a Pipeline Execution to occur. User will now need to pick an environment and infrastructure definition.
- The Infrastructure Definition configuration now contains:

```
1. Name, Description, Tag, Deployment Type
2. Connector Details
3. Deployment Target Details [Differs per Deployment Type (i.e. namespace for K8s, cluster for ECS, Hosts for SSH)] 
```

#### YAML Updates 

- The entire object is now a standalone object not defined in a pipeline
- When configuring you will associate the Infrastructure Definition with the Environment you wish to use it with (think of this as the actual cluster in the environment you wish to deploy) 


```
infrastructureDefinition:
  name: product-staging
  identifier: productstaging
  description: ""
  tags: {}
  orgIdentifier: default
  projectIdentifier: Rohan
  
## NOTE: the Environment REF maps the infrastructure definition to the environment

  environmentRef: staging
  deploymentType: Kubernetes
  type: KubernetesDirect
  spec:
    connectorRef: pmk8scluster
    namespace: <+input>.allowedValues(dev,qa,prod)
    releaseName: release-<+INFRA_KEY>
  allowSimultaneousDeployments: false
```

#### TERRAFORM PROVIDER
- Harness released a new Terraform Provider Resource for Infrastructure Definitions: https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_infrastructure 


##### New Terraform Provider Infrastructure Definition Resource

```
resource "harness_platform_infrastructure" "example" {
  identifier      = "identifier"
  name            = "name"
  org_id          = "orgIdentifer"
  project_id      = "projectIdentifier"
  env_id          = "environmentIdentifier"
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = <<-EOT
        infrastructureDefinition:
         name: name
         identifier: identifier
         description: ""
         tags:
           asda: ""
         orgIdentifier: orgIdentifer
         projectIdentifier: projectIdentifier
         environmentRef: environmentIdentifier
         deploymentType: Kubernetes
         type: KubernetesDirect
         spec:
          connectorRef: account.gfgf
          namespace: asdasdsa
          releaseName: release-<+INFRA_KEY>
          allowSimultaneousDeployments: false
      EOT
}
```



