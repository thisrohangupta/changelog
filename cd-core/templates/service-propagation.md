# Propagate a Service throughout a Pipeline

When defining a pipeline, you often times want to pass the same service and its parameters through multiple stages. With Service Propagation you are able to now pass the service, its variables, artifact and manifest inputs through various stages. 



## Product Demo

https://www.loom.com/share/79b0d4c9c4634d2e95da1a832ef8060f 




## Supported Combinations for Service Propagation

Harness supports Service Propagation in a few combinations of setup:

1. (Non Template) CD Stage with subsequent (Non Template) CD Stages 
2. (Templated) CD Stage with subsequent (Same Template Referenced) CD Stages
3. (Templated) CD Stage with  subsequent (Different Template Referenced) CD Stages 



## Setup for Service Propagation:

### Requirements for Use

1. The Service must be configured as a runtime input in the Stage Template or Stage
2. Make sure the Template or subsequent stage configured also supports an input of a service. 


You should see an option like this:

#### First Stage with a configured Service

<img width="1467" alt="image" src="https://user-images.githubusercontent.com/52221549/228049351-72fc5ba3-02a4-4d16-a9a4-a47fc3d8996d.png">


#### Second Stage referencing the first stage's Service

<img width="1507" alt="image" src="https://user-images.githubusercontent.com/52221549/228049279-a463fd22-9e9e-4067-985a-b40c3569e2e0.png">


Propagation is also supported if the first stage's service is a runtime input

<img width="1462" alt="image" src="https://user-images.githubusercontent.com/52221549/228049553-038c592f-e445-4428-bdf2-dd45bbf15599.png">

<img width="1494" alt="image" src="https://user-images.githubusercontent.com/52221549/228049611-c6f3f064-c98b-49b7-a87b-902cdcf8195f.png">



### Sample YAML Setup for Servicce Propagation

```YAML
pipeline:
  name: Deployment Pipeline
  identifier: Deployment_Pipeline
  projectIdentifier: Rohan
  orgIdentifier: default
  tags: {}
  stages:
    - stage:
        name: Deploy Dev
        identifier: Deploy_Dev
        template:
          templateRef: Deploy_Stage_1
          versionLabel: "1.01"
          templateInputs:
            type: Deployment
            spec:
              service:
                serviceInputs:
                  serviceDefinition:
                    type: Kubernetes
                    spec:
                      artifacts:
                        primary:
                          primaryArtifactRef: nginx
                          sources:
                            - identifier: nginx
                              type: DockerRegistry
                              spec:
                                tag: <+input>
                serviceRef: nginxcanary
    - stage:
        name: Deploy to QA
        identifier: Deploy_to_QA
        template:
          templateRef: Deploy_Stage_1
          versionLabel: "1.01"
          templateInputs:
            type: Deployment
            spec:
              service:
                useFromStage:
                  stage: Deploy_Dev
    - stage:
        name: Deploy to Prod
        identifier: Deploy_to_Prod
        template:
          templateRef: Deploy_Stage_1
          versionLabel: "1.01"
          templateInputs:
            type: Deployment
            spec:
              service:
                useFromStage:
                  stage: Deploy_Dev

```


### Limitations

We cannot propagate the service between different deployment types. We can only propagate a service that is of the same deployment type as the stages. For example, we cannot propagate a Kubernetes Service between a kubernetes deployment stage and a native helm deployment type stage. It needs to be Kubernetes Deployment Type across for the Stage Deployment type, and the service deployment type.
