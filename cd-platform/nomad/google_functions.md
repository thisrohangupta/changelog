
# Google Functions Deployment Support

## Introduction

- Google offers a Serverless offering calling Google Functions
- Harness supports deploying Google Functions through the [Gen 2](https://cloud.google.com/blog/products/serverless/cloud-functions-2nd-generation-now-generally-available) offering that Google Cloud Provides
- To Review differences between [GEN 1 vs GEN 2](https://cloud.google.com/functions/docs/concepts/version-comparison#comparison-table) please see Google Cloud's Documentation. 

### Harness Google Functions GEN 2 Support

- User's can perform Blue-Green and Canary Deployments
- Harness leverages the Revisions capability that Google Cloud offers to configure Rollback
- Harness' can perform traffic shifting for Blue Green and Canary based deployments only in GEN 2

### Limitations

- Google Functions GEN 2 doesn't support yet [Google Cloud Source Repository](https://cloud.google.com/functions/docs/deploy#from-source-repo)


### Quick Start

1. Create a Pipeline
2. Add a Deploy Stage
3. Configure the Deployment Type: *Google Functions*
4. Click "+ Service"
5. Save the created Service
6. Click "+ New Environment"
7. Configure the New Environment and Save, itll be used by default in the Pipeline Studio
8. Configure the Infrastructure Definition, please make sure you configure the GCP Connector with the correct permissions, we will use this connector for deployment.
9. Configure a Basic Deployment
10. Harness will populate the Deploy Function Step on the Pipeline Studio canvas, no further configuration needed from the user
11. User can click save and then run the pipeline.


#### Creating a Service

1. Give your service a name
2. Configure the Function Definition
3. Configure the Artifact Source, its a required field.

##### Function Definition

The Function Definition is the parameter file you use to define your Google Function. The Function Definition file maps to 1 Google Function. The parameters for Google Functions for Gen 2 that the users can provide in the YAML are defined [here](https://cloud.google.com/functions/docs/reference/rpc/google.cloud.functions.v2#function) by Google Cloud.

User's can defined details of the [service configuration](https://cloud.google.com/functions/docs/reference/rpc/google.cloud.functions.v2#google.cloud.functions.v2.ServiceConfig) and [build config](https://cloud.google.com/functions/docs/reference/rpc/google.cloud.functions.v2#buildconfig) via the YAML as seen in the below example.



##### Sample Google Function Definition

```YAML
# Following are the minimum set of parameters required to create a Google Cloud Function.
# Please make sure your uploaded manifest file includes all of them.

function:
  name: <functionName>
  buildConfig:
    runtime: nodejs18
    entryPoint: helloGET
  environment: GEN_2
function_id: <functionName>

```

1. Add this sample YAML to your Git based Source Repository or the Harness File Store. For this example, we are using the Harness File Store

2. Sample Harness Service Created once the Function Definition is created

##### Sample Harness Service YAML

```YAML
service:
  name: helloworld
  identifier: Google_Function
  serviceDefinition:
    type: GoogleCloudFunctions
    spec:
      manifests:
        - manifest:
            identifier: GoogleFunction
            type: GoogleCloudFunctionDefinition
            spec:
              store:
                type: Harness
                spec:
                  files:
                    - /GoogleFunctionDefinition.yaml
      artifacts:
        primary:
          primaryArtifactRef: <+input>
          sources:
            - spec:
                connectorRef: gcp_connector
                project: cd-play
                bucket: cloud-functions-automation-bucket
                artifactPath: helloworld
              identifier: helloworld
              type: GoogleCloudStorage
```

#### Creating an Environment

Users can pick an existing or create a new environment from scratch. The Sample YAML once configured would look similar to below.

```YAML
environment:
  name: dev-gcp
  identifier: dev
  description: "dev google cloud environment"
  tags: {}
  type: PreProduction
  orgIdentifier: default
  projectIdentifier: serverlesstest
  variables: []

```

#### Creating an Infrastructure Definition

User's will need a GCP Connector with the permissions to deploy google functions in GCP.User's can pick an existing connector or create a new one from scratch. Below is a Sample Infrastructure Definition.

```YAML
infrastructureDefinition:
  name: dev
  identifier: dev
  description: "dev google cloud infrastructure"
  tags: {}
  orgIdentifier: default
  projectIdentifier: serverlesstest
  environmentRef: dev
  deploymentType: GoogleCloudFunctions
  type: GoogleCloudFunctions
  spec:
    connectorRef: gcp_connector
    project: cd-play
    region: us-central1
  allowSimultaneousDeployments: false

```

#### Basic Deployment

User's can select the Basic Deployment Execution Strategy. Harness will provide the Deploy Function Step on the Pipeline studio. The Deploy Function Command will deploy the new function and by default will route 100% traffic over to the newly deployed function.

The Step YAML looks like below:

```YAML
              - step:
                  name: Deploy Cloud Function
                  identifier: deployCloudFunction
                  type: DeployCloudFunction
                  timeout: 10m
                  spec:
                    updateFieldMask: ""
```

#### Canary Deployment

Harness will provide a [Step Group](https://developer.harness.io/docs/continuous-delivery/cd-technical-reference/cd-gen-ref-category/step-groups/) that will perform the Canary Deployment. Sample YAML for the Canary Deployment Step Group below. Harness knows how to route the traffic from the existing function to the newly deployed function.

```YAML
             - stepGroup:
                  name: Canary Deployment
                  identifier: canaryDepoyment
                  steps:
                    - step:
                        name: Deploy Cloud Function With No Traffic
                        identifier: deployCloudFunctionWithNoTraffic
                        type: DeployCloudFunctionWithNoTraffic
                        timeout: 10m
                        spec: {}
                    - step:
                        name: Cloud Function Traffic Shift
                        identifier: cloudFunctionTrafficShiftFirst
                        type: CloudFunctionTrafficShift
                        timeout: 10m
                        spec:
                          trafficPercent: 10
                    - step:
                        name: Cloud Function Traffic Shift
                        identifier: cloudFunctionTrafficShiftSecond
                        type: CloudFunctionTrafficShift
                        timeout: 10m
                        spec:
                          trafficPercent: 100
```


#### Blue-Green Deployment

Harness will deploy the staged function with 0% traffic. User's can incrementally or do a full cutover by routing the older revisions traffic to the newly deployed stage.

Harness will provide a [Step Group](https://developer.harness.io/docs/continuous-delivery/cd-technical-reference/cd-gen-ref-category/step-groups/) that will perform the Blue Green Deployment. Below is a sample YAML snippet of the Blue-Green Deployment step group.

```YAML
                  name: Blue Green Deployment
                  identifier: blueGreenDepoyment
                  steps:
                    - step:
                        name: Deploy Cloud Function With No Traffic
                        identifier: deployCloudFunctionWithNoTraffic
                        type: DeployCloudFunctionWithNoTraffic
                        timeout: 10m
                        spec: {}
                    - step:
                        name: Cloud Function Traffic Shift
                        identifier: cloudFunctionTrafficShift
                        type: CloudFunctionTrafficShift
                        timeout: 10m
                        spec:
                          trafficPercent: 100
```

Harness will deploy the staged function with 0% traffic. User's can incrementally or do a full cutover by routing the older revisions traffic to the newly deployed stage.

#### Rollback Function

Harness will offer the Rollback functionality out of the box. The Harness Rollback capabilities are based of the [Revisions](https://cloud.google.com/run/docs/managing/revisions) available in Google Cloud for the particular function.

**Rollback**
When a function is deployed the first time and if the step after fails which would trigger a rollback, then we delete the function.
If the function already exists (revision 10) and a new revision is deployed during deploy(revision 11) but a step after deploy fails and rollback is triggered then Harness will deploy a new function revision (revision 12) but will contain the artifact and metadata for revision 10.


Sample YAML for the step, no user configuration required

```YAML
              - step:
                  name: Rollback Cloud Function
                  identifier: cloudFunctionRollback
                  type: CloudFunctionRollback
                  timeout: 10m
                  spec: {}
```

