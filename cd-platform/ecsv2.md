# Introduction

In the Harness CD 2.0 product, we have revamped the ECS Deployment Swimlane. This includes how users configure a service, deployment behaviors for rolling, canary and Blue-Green as well as the deployment steps we offer. 

For Users coming from our CD 1.0 Product, this will be a significant change that will require time to upgrade and it's important to understand these changes. 

## Documentation and Resources provided by Harness 

- For Documentation on our [ECS 2.0 Swimlane](https://docs.harness.io/article/vytf6s0kwc-ecs-deployment-tutorial)
- For our Harness Developer Hub [ECS Deployment Quickstart](https://developer.harness.io/tutorials/deploy-services/docker-ecs ) 

## Major Changes from CD 1.0 ECS to CD 2.0 ECS

**ECS Steps that are deprecated in ECS 2.0**
- Deprecated the [ECS Service Setup Step ](https://docs.harness.io/article/oinivtywnl-ecs-workflows)
- Deprecated[ Upgrade Containers Step](https://docs.harness.io/article/oinivtywnl-ecs-workflows) 
- Deprecated ECS Daemon Service Setup Step 
- Deprecated the [ECS Steady State Check Step](https://docs.harness.io/article/oinivtywnl-ecs-workflows#ecs_steady_state_check_command)
- Deprecated the [Basic ECS Workflow type](https://docs.harness.io/article/oinivtywnl-ecs-workflows)

**New Deployment Types Introduced in ECS 2.0**
- Added [Rolling Deployment Support ](https://docs.harness.io/article/vytf6s0kwc-ecs-deployment-tutorial#define_the_rolling_deployment_steps)
- Revamped the [Canary Deployment Behavior](https://docs.harness.io/article/vytf6s0kwc-ecs-deployment-tutorial#ecs_canary_deployments) 

**Infrastructure Definitions**
- Harness has made the Infrastructure Definitions a lighter configuration now that can be reusable for other ECS Services for deployment
- The ECS Infrastructure Definition no longer has Service specific properties like `Networking`, `ExecutionRoleARN`, `AWSVPC` Information, this has moved to the Service Definition



## What has Changed by Kind 

### Service

- The ECS Service now has more parameters via the [Task Definition](https://docs.harness.io/article/vytf6s0kwc-ecs-deployment-tutorial#add_the_task_definition) and [Service Definition](https://docs.harness.io/article/vytf6s0kwc-ecs-deployment-tutorial#add_the_service_definition).
- Scaling Policies have moved to the ECS Service from the ECS Service Setup step and are now configurable as YAML or JSON files in the Service
- The Scalable Targets have moved from the ECS Service Setup Step and are now configurable as YAML or JSON param files in the Service
- The AWS VPC, Security Group, Subnets, Execution Role ARN have moved out of the Infrastructure Definition and are now part of the Service Definition configuration
- The Service Definition requires more configuration:
  - `serviceName` 
  - `loadbaBancer` properties
  - `networkConfiguration` 
  - `desiredCount` 
- We can manipulate the deployment behavior via the new `deploymentConfiguration` property:
  - `maximumPercent` more details [here](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_DeploymentConfiguration.html)
  - `minimumHealthyPercent` more details [here](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_DeploymentConfiguration.html)



#### ECS 2.0 Task Definition - Supported Fields

**Sample Task Definition and supported parameters - YAML Example**

```
ipcMode:

executionRoleArn: <ecsInstanceRole Role ARN>
containerDefinitions:
- dnsSearchDomains:
  environmentFiles:
  entryPoint:
  portMappings:
  - hostPort: 80
    protocol: tcp
    containerPort: 80
  command:
  linuxParameters:
  cpu: 0
  environment: []
  resourceRequirements:
  ulimits:
  dnsServers:
  mountPoints: []
  workingDirectory:
  secrets:
  dockerSecurityOptions:
  memory:
  memoryReservation: 128
  volumesFrom: []
  stopTimeout:
  image: <+artifact.image>
  startTimeout:
  firelensConfiguration:
  dependsOn:
  disableNetworking:
  interactive:
  healthCheck:
  essential: true
  links:
  hostname:
  extraHosts:
  pseudoTerminal:
  user:
  readonlyRootFilesystem:
  dockerLabels:
  systemControls:
  privileged:
  
## ECS v2 Update
## This is the ECS Task Definition name - you can now define in the Task Definition and Harness won't append anything to it during deployment
  name: nginx
  
placementConstraints: []
memory: '512'

## ECS v2 Update
## The taskRoleARN property needs to be provided this is the ECS Instance Role ARN

taskRoleArn: <ecsInstanceRole Role ARN>
family: sainath-fargate
pidMode:
requiresCompatibilities:
- FARGATE
networkMode: awsvpc
runtimePlatform:
cpu: '256'
inferenceAccelerators:
proxyConfiguration:
volumes: []
```



#### ECS 2.0 Service Definition - Supported Fields

**Sample Service Definition and supported parameters - YAML Example**

```
launchType: FARGATE

## ECS V2 UPDATE
## The Service name, Desired Count, and network configuration needs to be defined in the Service Definition now

serviceName: myapp
desiredCount: 2
networkConfiguration:
  awsvpcConfiguration:
    securityGroups:
    - <Security Group Id>
    subnets:
    - <Subnet Id>
    assignPublicIp: ENABLED 
    
    
## ECS V2 UPDATE
## We can define the deployment behavior properties in the Service Definition and Harness will deploy with the defined configuration

deploymentConfiguration:
  maximumPercent: 200
  minimumHealthyPercent: 100
loadBalancers:
- targetGroupArn: <+targetGroupArn>
  containerName: nginx
  containerPort: 80    
```

