# Service and Environments V2 Experience Release

In order to provide the best software delivery experience for our customers, Harness has introduced an enhanced experience for Service and Environment entities (V2) in the CD NextGen platform.

The new V2 experience will go into effect on Jan 31, 2023 as the default experience. Except for specific accounts, the current V1 experience will then be removed for all accounts at that time.

## Table of Contents

- [Why Make The Change](https://github.com/thisrohangupta/changelog/blob/e8d920dc0c828722e174ba91ddde9da2a07cd83e/cd-core/service_environment_v2/README.md#L11)

- [Changes since Service and Environments V1](https://github.com/thisrohangupta/changelog/blob/e8d920dc0c828722e174ba91ddde9da2a07cd83e/cd-core/service_environment_v2/README.md#L11)

- [Changes By Kind](https://github.com/thisrohangupta/changelog/blob/e8d920dc0c828722e174ba91ddde9da2a07cd83e/cd-core/service_environment_v2/README.md#L46)

- [Migration to V2 Service and Environments](https://github.com/thisrohangupta/changelog/blob/e8d920dc0c828722e174ba91ddde9da2a07cd83e/cd-core/service_environment_v2/README.md#L817)

## Why Make the Change

The enhanced Service and Environment feature (V2) comes with a more robust Service and Environment entity that has service variables, independent infrastructure definitions, environment groups, and capabilities to override files and variables. When adopting V2 Service and Environments, you will notice an overall reduction in configuration baked into the pipelines. These changes are also reflected in the the Harness APIs as well.

All new deployment swimlanes (ECS, Deployment Template, SSH, WinRM, etc.) are only available on the new V2 Experience. New innovations such as Enterprise GitOps, Support for multi-Service and multi-Environment along with the ability to group Environments in an Environment Group will also be based on the V2 experience. The new V2 experience has been designed to provided users and organizations with simpler configuration and ability to scale.

### IMPACT

- Existing Users and Projects in the UI
- There is no impact on your existing pipelines using V1 services and environments. Post 1/31/2023, when you create a new stage, in an existing pipeline, - V2 experience will be the default.
- Please note that any new services and environments that are created in Harness will be on the new V2 experience.

### API

Harness introduced two new APIs to support the V2 Experience. The API reference is shared in the Document Resources/API Documentation section.

- <https://apidocs.harness.io/tag/Environments#operation/createEnvironmentV2>
h- ttps://apidocs.harness.io/tag/Services#operation/createServiceV2

### TERRAFORM AUTOMATION

Customers will need to update their service/environment automation to use V2 APIs.

- <https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_service>
- <https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_environment>
- <https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_infrastructure>

---

## Changelog since Service V1 and Environment V1 Release

### Please read this before Upgrade

- Service V1 and Environment V1 APIs are being deprecated on March 2023.
- Existing pipelines referencing Service V1 and Environment V1 will run the risk of failure and no longer work after March 2023.
- Harness will globally enable Service and Environments V2 APIs for all clients at the end of January 2023. T
- The forced change is needed to reduce the migration effort needed for users
- Harness has an automated tool to help migrate your services and environments from the v1 to v2

## Changes by Kind

### Service

- Services now has a definition that needs to be configured via API or UI in order to use the service in a Pipeline
- The Service Definition is a firm configuration that is mapped to the Service irrespective of the Pipeline it's being referenced in
- Documentation on Service V2: <https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#creating_v2_services>
- The Service object is now removed from the Pipeline and is a stand alone object that contains 3 things:

```text
1. Name, Description, Tag, Identifier [Same as Service V1 Experience]
2. Manifests, Artifacts [The Service Manifests and the artifacts are now mapped in the Service object, they are moved out of the pipeline definition
3. Service Variables - Variables are now associated with the Service and can be used for override
```

#### YAML Updates

```YAML
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
 ## NEW CAPABILITY: We now have service variables that are mapped and managed with the service, no longer defined in the Pipeline
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

- When creating a service via Harness REST API - Harness has exposed a new endpoint - <https://apidocs.harness.io/tag/Services#operation/createServiceV2>

#### Sample Payload Request

```JSON
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
  
// NEW PART OF THE SERVICE API PAYLOAD
//the YAML is optional is to provide via API for Service creation. 
// It's mandatory for the service to be used in a Pipeline 
//YAML is the Service Definition YAML passed as a string

  "yaml": "string" 
}
```

#### Sample Payload Response

```JSON
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

- The Terraform Provider Service Resource Endpoint HAS NOT CHANGED - <https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_service>
- The Service Resource Payload has a new field added for Service Creation - YAML
- YAML is not mandatory for service object creation
- When creating a service without YAML defined, it will create a skeleton service that cannot be used for immediate deployment
- The YAML field defines the actual definition of the Service so it can be used in a Pipeline for deployment

```YAML
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
- The Environment variables can override the variables defined at the Service Variable. Variable Override Information Details: <https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#service_overrides>
- Documentation on Environments V2: <https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#creating_and_using_v2_environments>
- Harness introduced Environment Service Overrides, Environment Variables defined can override Service variables when the service is deployed into a given environment. Based on the variable name Harness can override the service variable with the environment variable value.
- Harness has introduced Service specific Environment overrides where users can define specific services and variables they want to override for a given environment. For More Information: <https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#override_priority>

#### Environment Groups

- Harness introduced Environment Groups, this allows users to group their environments and manage them at scale. It's a list of Environments that can allow users to deploy to a subset of environments within the group or all of them at once.
- Documentation on Environments Groups: <https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#environment_groups>

#### Environment YAML Updates

```YAML
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

#### Environment REST API UPDATES

- When creating a Environment via Harness REST API - Harness has exposed a new endpoint - <https://apidocs.harness.io/tag/Environments#operation/createEnvironmentV2>
- The YAML parameter is not required for Environment Creation or usage in a pipeline
- Harness has a new API Endpoint for Environment Groups: <https://apidocs.harness.io/tag/EnvironmentGroup#operation/postEnvironmentGroup>
- Harness has a new API Endpoint for Service Specific Environment Overrides: <https://apidocs.harness.io/tag/Environments#operation/upsertServiceOverride>

##### Environment REST Request Changes

```JSON
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
  
// ENVIRONMENT V2 UPDATE
// User's can now pass in the Environment Variables and Overrides via YAML Payload 
// NOTE: This field is not mandatory for Environment Creation or Usage in a Pipeline

  "yaml": "string"
}
```

#### Environment TERRAFORM PROVIDER

- The Terraform Provider Environment Resource Endpoint HAS NOT CHANGED -<https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_environment>
- The Environment Resource Payload has a new field added for Environment Creation - YAML
- YAML is NOT mandatory for Environment object creation
- Harness has a new Resource Endpoint for Environment Groups: <https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_environment_group>
- Harness has a new Resource Endpoint for Environment Service Configuration Overrides: <https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_environment_service_overrides>

##### New Terraform Provider Environment Resource

```YAML
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

- Harness has taken the Infrastructure Definition that was originally defined in the pipeline and now moves it to the Environment. For more information: <https://docs.harness.io/article/9ryi1ay01f-services-and-environments-overview#infrastructure_definitions>
- The Infrastructure definition can only be associated with 1 environment
- The Infrastructure Definition is required for a Pipeline Execution to occur. User will now need to pick an environment and infrastructure definition.
- The Infrastructure Definition configuration now contains:

```Text
1. Name, Description, Tag, Deployment Type
2. Connector Details
3. Deployment Target Details [Differs per Deployment Type (i.e. namespace for K8s, cluster for ECS, Hosts for SSH)] 
```

#### Infrastructure Definition YAML Updates

- The entire object is now a standalone object not defined in a pipeline
- When configuring you will associate the Infrastructure Definition with the Environment you wish to use it with (think of this as the actual cluster in the environment you wish to deploy)

```YAML
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

#### Infrastructure Definition TERRAFORM PROVIDER

- Harness released a new Terraform Provider Resource for Infrastructure Definitions: <https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_infrastructure>

##### New Terraform Provider Infrastructure Definition Resource

```YAML
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

### Stage

- The Stage definition changes when the Service and Environment V2 update is enabled.
- Stage now has a Deployment Type, a Service Ref, an Environment Ref, and an Infrastructure Definition that needs to be defined along with the Execution Steps

```YAML
    - stage:
        name: Deploy
        identifier: Deploy
        description: ""
        type: Deployment
        spec:
        
 ## SERVICE + ENVIRONMENT V2 UPDATE
 ## deploymentType - this scopes the stage config to one of the Deployment Types that Harness offers 
 ## Steps, Services, Environments, Infrastructure Definitions are all scoped to the stage's deployment type - prevents incompatible config usage
 
          deploymentType: Kubernetes
          
 ## SERVICE + ENVIRONMENT V2 UPDATE
 ## serviceref - is now a reference to the service object that is configured and managed outside the pipeline
 ## serviceInputs - these are the runtime inputs that users provide for the artifact when they deploy the particular service
 
          service:
            serviceRef: nginxcanary
            serviceInputs:
              serviceDefinition:
                type: Kubernetes
                spec:
                  artifacts:
                    primary:
                      primaryArtifactRef: <+input>
                      sources: <+input>
                      
 ## SERVICE + ENVIRONMENT V2 UPDATE
 ## environmentref - is now a reference to the environment object that is configured and managed outside the pipeline
 ## infrastructureDefinitions - this object is defined outside of the pipeline and is referenced via the identifier, the yaml is inserted into the stage definition once defined
 
          environment:
            environmentRef: staging
            deployToAll: false
  
            infrastructureDefinitions:
              - identifier: productstaging
                inputs:
                  identifier: productstaging
                  type: KubernetesDirect
                  spec:
                    namespace: <+input>.allowedValues(dev,qa,prod)
          execution:
            steps:
              - stepGroup:
                  name: Canary Deployment
                  identifier: canaryDepoyment
                  steps:
                    - step:
                        name: Canary Deployment
                        identifier: canaryDeployment
                        type: K8sCanaryDeploy
                        timeout: 10m
                        spec:
                          instanceSelection:
                            type: Count
                            spec:
                              count: 1
                          skipDryRun: false
                    - step:
                        name: Canary Delete
                        identifier: canaryDelete
                        type: K8sCanaryDelete
                        timeout: 10m
                        spec: {}
              - stepGroup:
                  name: Primary Deployment
                  identifier: primaryDepoyment
                  steps:
                    - step:
                        name: Rolling Deployment
                        identifier: rollingDeployment
                        type: K8sRollingDeploy
                        timeout: 10m
                        spec:
                          skipDryRun: false
            rollbackSteps:
              - step:
                  name: Canary Delete
                  identifier: rollbackCanaryDelete
                  type: K8sCanaryDelete
                  timeout: 10m
                  spec: {}
              - step:
                  name: Rolling Rollback
                  identifier: rollingRollback
                  type: K8sRollingRollback
                  timeout: 10m
                  spec: {}
        tags: {}
        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: StageRollback
```

### Pipeline

- The Pipeline object changes with the Service and Environment V2 update
- Your Service and your Environment + Infrastructure Definitions are no longer defined in the Pipeline, they are managed outside of the pipeline
- The Pipeline will reference the identifier of the Service, Environment and Infrastructure Definitions when being used in a pipeline
- Each Stage will now have a reference to the Service, Environment and Infrastructure Definition objects

#### Sample Pipeline YAML with Service and Environments V2 Experience Enabled

```YAML
pipeline:
  name: Nginx Colors Canary
  identifier: Nginx_Colors_Canary
  projectIdentifier: Rohan
  orgIdentifier: default
  tags: {}
  stages:
    - stage:
        name: Deploy
        identifier: Deploy
        description: ""
        type: Deployment
        spec:
          deploymentType: Kubernetes
          
 ## SERVICE + ENVIRONMENT V2 UPDATE
 ## serviceref - is now a reference to the service object that is configured and managed outside the pipeline
 ## serviceInputs - these are the runtime inputs that users provide for the artifact when they deploy the particular service
 
          service:
            serviceRef: nginxcanary
            serviceInputs:
              serviceDefinition:
                type: Kubernetes
                spec:
                  artifacts:
                    primary:
                      primaryArtifactRef: <+input>
                      sources: <+input>
                      
 ## SERVICE + ENVIRONMENT V2 UPDATE
 ## environmentref - is now a reference to the environment object that is configured and managed outside the pipeline
 ## infrastructureDefinitions - this object is defined outside of the pipeline and is referenced via the identifier, the yaml is inserted into the stage definition once defined
 
          environment:
            environmentRef: staging
            deployToAll: false
  
            infrastructureDefinitions:
              - identifier: productstaging
                inputs:
                  identifier: productstaging
                  type: KubernetesDirect
                  spec:
                    namespace: <+input>.allowedValues(dev,qa,prod)
          execution:
            steps:
              - stepGroup:
                  name: Canary Deployment
                  identifier: canaryDepoyment
                  steps:
                    - step:
                        name: Canary Deployment
                        identifier: canaryDeployment
                        type: K8sCanaryDeploy
                        timeout: 10m
                        spec:
                          instanceSelection:
                            type: Count
                            spec:
                              count: 1
                          skipDryRun: false
                    - step:
                        name: Canary Delete
                        identifier: canaryDelete
                        type: K8sCanaryDelete
                        timeout: 10m
                        spec: {}
              - stepGroup:
                  name: Primary Deployment
                  identifier: primaryDepoyment
                  steps:
                    - step:
                        name: Rolling Deployment
                        identifier: rollingDeployment
                        type: K8sRollingDeploy
                        timeout: 10m
                        spec:
                          skipDryRun: false
            rollbackSteps:
              - step:
                  name: Canary Delete
                  identifier: rollbackCanaryDelete
                  type: K8sCanaryDelete
                  timeout: 10m
                  spec: {}
              - step:
                  name: Rolling Rollback
                  identifier: rollingRollback
                  type: K8sRollingRollback
                  timeout: 10m
                  spec: {}
        tags: {}
        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: StageRollback
```

### Templates

- Templates are impacted by the Service and Environments V2 Update
- Your existing Templates in the Service and Environments V1 Experience will still run till EOL of the API
- When migrating to the V2 Service and environments, users will need to create a new stage template that references the V2 Service and Environment

#### Sample Stage Template

```YAML
template:
  name: Deploy
  identifier: Deploy
  type: Stage
  projectIdentifier: Rohan
  orgIdentifier: default
  tags: {}
  spec:
    type: Deployment
    spec:
 
 ## SERVICE + ENVIRONMENT V2 UPDATE
 ## deploymentType - this scopes the stage config to one of the Deployment Types that Harness offers 
 ## Steps, Services, Environments, Infrastructure Definitions are all scoped to the stage's deployment type - prevents incompatible config usage
 
      deploymentType: Kubernetes
      
 ## SERVICE + ENVIRONMENT V2 UPDATE
 ## serviceref - is now a reference to the service object that is configured and managed outside the pipeline
 ## serviceInputs - these are the runtime inputs that users provide for the artifact when they deploy the particular service
 
      service:
        serviceRef: <+input>
        serviceInputs: <+input>
        
 ## SERVICE + ENVIRONMENT V2 UPDATE
 ## environmentref - is now a reference to the environment object that is configured and managed outside the pipeline
 ## infrastructureDefinitions - this object is defined outside of the pipeline and is referenced via the identifier, the yaml is inserted into the stage
 ## definition once defined
 
      environment:
        environmentRef: <+input>
        deployToAll: false
        environmentInputs: <+input>
        infrastructureDefinitions: <+input>
      execution:
        steps:
          - step:
              name: Rollout Deployment
              identifier: rolloutDeployment
              type: K8sRollingDeploy
              timeout: 10m
              spec:
                skipDryRun: false
                pruningEnabled: false
          - step:
              type: ShellScript
              name: Shell Script
              identifier: ShellScript
              spec:
                shell: Bash
                onDelegate: true
                source:
                  type: Inline
                  spec:
                    script: kubectl get pods -n <+infra.namespace>
                environmentVariables: []
                outputVariables: []
              timeout: 10m
          - step:
              type: Http
              name: HTTP
              identifier: HTTP
              spec:
                url: https://google.com
                method: GET
                headers: []
                outputVariables: []
              timeout: 10s
        rollbackSteps:
          - step:
              name: Rollback Rollout Deployment
              identifier: rollbackRolloutDeployment
              type: K8sRollingRollback
              timeout: 10m
              spec:
                pruningEnabled: false
    failureStrategies:
      - onFailure:
          errors:
            - AllErrors
          action:
            type: StageRollback
  versionLabel: "2.0"

```

---

## Migration from the V1 Service and Environments to the V2

To support automated migration of services and environments, we have created two apis:

The idea of the APIs is to copy over the serviceDefinition from a pipeline stage and update the existing service with this. Also it would create an infrastructure definition by using the details from the `infrastructure.infrastructureDefinition` yaml field in the pipeline stage

If the pipeline:

1. uses stage templates
2. does not use any templates

The API would be able to update the pipeline yaml also (given that the user running the APIs has permission to update the pipeline. Same applies for services and environments also)

### Pipeline Level Migration

This API will migrate services and environments for all CD stages that exist in a pipeline. It can update pipeline Yaml also (optionally). It will take CD stages of pipeline one by one and migrate them to the v2 service and environments

#### Sample Curl Command

```CURL
curl --location --request POST 'https://<base_url>/gateway/ng/api/service-env-migration/pipeline?accountIdentifier=account_identifier' \
--header 'content-type: application/yaml' \
--header 'Authorization: auth_token' \
--data-raw '{
 "orgIdentifier": '\''org_identifier'\'',
 "projectIdentifier": '\''project_identifier'\'',
 "infraIdentifierFormat": '\''<+stage.identifier>_<+pipeline.identifier>_infra'\'',
 "pipelineIdentifier": '\''pipeline_identifier'\'',
 "isUpdatePipeline": true,
 "templateMap" : 
      {
          "source_template_ref@ source_template_version": {
              "templateRef" : "target_template_ref",
              "versionLabel" : "target_template_version"
          }
      },
      "skipInfras": ["abc"],
      "skipServices": ["abc"],
}'
```

#### Sample Response

```JSON
{
    "status": "SUCCESS",
    "data": {
        "failures": [
            {
                "orgIdentifier": "org_identifier",
                "projectIdentifier": "project_identifier",
                "pipelineIdentifier": "pipeline_identifier",
                "stageIdentifier": "stage_identifier",
                "failureReason": "service of type v1 doesn't exist in stage yaml"
            }
        ],
        "pipelineYaml": "yaml",
        "migrated": false
    },
    "metaData": null,
    "correlationId": "9ed00aca-d788-441e-a636-58661ef36efe"
}
```

#### Input Fields

- `Authorization` - Auth Bearer Token, Can be extracted from header of network calls from browser after login in harness
- `accountIdentifier` - user account ID
- `orgIdentifier` -  organization identifier of the pipeline you wish to migrate
- `projectIdentifier` - project identifier of the pipeline you wish to migrate
- `infraIdentifierFormat` - format for infrastructure definition identifier. Harness will replace the expressions in this string by actual values and use it as an identifier to create an **infrastructure definition**.
- `templateMap` -  
mapping of source template to target template.
  - **source template**: It refers to a stage template which is currently existing in a CD stage yaml.
  - **target template**: It refers to a stage template which will replace the currently existing source template in a CD stage yaml.
  - `skipInfras`: list of infrastructures identifier to skip migration, this allows users to omit infrastructures they don't want to upgrade
  - `skipServices`: list of service identifier to skip migration, this allows users to omit services they don't want to upgrade
  - `isUpdatePipeline`: pipeline yaml will get updated with new svc-env  framework if it is true otherwise pipeline yaml will not get updated.

#### Output Fields

- `failures`: List of reasons for failure of migration of CD stages.
- `pipelineYaml`: Updated pipeline yaml with new  svc-env  framework
- `migrated`: true if pipeline got updated otherwise false

### Project Level Migration

This API will migrate services and envs for all pipelines exist in a project. It can update pipeline Yaml also optionally.

#### Sample Request

```curl
curl --location --request POST 'https://<base_url>/gateway/ng/api/service-env-migration/project?accountIdentifier=account_id' \
--header 'content-type: application/yaml' \
--header 'Authorization: auth_token' \
--data-raw '{
 "orgIdentifier": '\''org_identifier'\'',
 "projectIdentifier": '\''project_identifier'\'',
 "infraIdentifierFormat": '\''<+stage.identifier>_<+pipeline.identifier>_infra'\'',
  "isUpdatePipeline": true,
  "templateMap" : 
      {
          "source_template_ref@ source_template_version": {
              "templateRef" : "target_template_version",
              "versionLabel" : "v1"
          }
      },
      "skipInfras": ["abc"],
      "skipServices": ["abc"],
      "skipPipelines": ["def"]
}'
```

#### Sample Response**

```json
{
    "status": "SUCCESS",
    "data": {
        "failures": [
            {
                "orgIdentifier": "org_identifier",
                "projectIdentifier": "project_identifier",
                "pipelineIdentifier": "pipeline_identifier",
                "stageIdentifier": "stage_identifier",
                "failureReason": "service of type v1 doesn't exist in stage yaml"
            }
        ],
        "migratedPipelines": ["def"]
    },
    "metaData": null,
    "correlationId": "9ed00aca-d788-441e-a636-58661ef36efe"
}
```
