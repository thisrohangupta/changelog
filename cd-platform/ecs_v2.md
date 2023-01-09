# ECS Deployment 2.0 Support

Amazon ECS is a fully managed container orchestration service that helps you easily deploy, manage, and scale containerized applications. It deeply integrates with the rest of the AWS platform to provide a secure and easy-to-use solution for running container workloads in the cloud.

In the Harness CD 2.0 product, we have revamped the ECS Deployment Swimlane. This includes how users configure a service, deployment behaviors for rolling, canary and Blue-Green as well as the deployment steps we offer.

For Users coming from our CD 1.0 Product, this will be a significant change that will require time to upgrade and it's important to understand these changes.

For our Harness CD 1.0 users who were using the ECS Delegate: Please refer to our blog post to configure the ECS flavor of delegate: <https://community.harness.io/t/how-to-deploy-delegate-in-amazon-ecs-for-harness-ng/13056>

## Table of Contents

- [Documentation for ECS Deployment 2.0](https://github.com/thisrohangupta/changelog/blob/e8d920dc0c828722e174ba91ddde9da2a07cd83e/cd-platform/ecs_v2.md#L11)

- [Major Changes from CD 1.0 to 2.0 for ECS](https://github.com/thisrohangupta/changelog/blob/e8d920dc0c828722e174ba91ddde9da2a07cd83e/cd-platform/ecs_v2.md#L18)

- [What has Changed by Kind](https://github.com/thisrohangupta/changelog/blob/e8d920dc0c828722e174ba91ddde9da2a07cd83e/cd-platform/ecs_v2.md#L39)

## Documentation and Resources provided by Harness

- For Documentation on our [ECS 2.0 Swimlane](https://docs.harness.io/article/vytf6s0kwc-ecs-deployment-tutorial)
- For our Harness Developer Hub [ECS Deployment Quickstart](https://developer.harness.io/tutorials/deploy-services/docker-ecs )

## ECS Basics

- Official AWS ECS Docs does a good job of explaining ECS concepts in detail.
We can go through few important points

- A Task is the smallest deployable entity in ECS.
`Task Definition` is the configuration for a task. It contains information about task such as container definition image etc

- `Service` in ECS is an entity that manages a group of the same tasks. Service generally contains information about Load Balancing, task count, task placement strategies across availability zones etc

- ECS deeply integrates with many other AWS native services such as AWS ECR, App Mesh, Cloud Formation etc.

## Major Changes from CD 1.0 ECS to CD 2.0 ECS

#### ECS Steps that are deprecated in ECS 2.0

- Deprecated the [ECS Service Setup Step](https://docs.harness.io/article/oinivtywnl-ecs-workflows)
- Deprecated[Upgrade Containers Step](https://docs.harness.io/article/oinivtywnl-ecs-workflows)
- Deprecated ECS Daemon Service Setup Step
- Deprecated the [ECS Steady State Check Step](https://docs.harness.io/article/oinivtywnl-ecs-workflows#ecs_steady_state_check_command)
- Deprecated the [Basic ECS Workflow type](https://docs.harness.io/article/oinivtywnl-ecs-workflows)

#### New Deployment Types Introduced in ECS 2.0

- Added [Rolling Deployment Support](https://docs.harness.io/article/vytf6s0kwc-ecs-deployment-tutorial#define_the_rolling_deployment_steps)
- Revamped the [Canary Deployment Behavior](https://docs.harness.io/article/vytf6s0kwc-ecs-deployment-tutorial#ecs_canary_deployments)
#### ECS Run Task Revamped in ECS 2.0
- Introduced new configuration yaml ECS Run Task Request Definition as input in ECS Run Task Step.

#### Infrastructure Definitions

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

### ECS 2.0 Task Definition - Supported Fields

#### ample Task Definition and supported parameters - YAML Example

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

#### Sample Task Definition and supported parameters - JSON Example

```JSON
{
    "ipcMode": null,
    "executionRoleArn": "<ecsInstanceRole Role ARN>",
    "containerDefinitions": [
        {
            "dnsSearchDomains": null,
            "environmentFiles": null,
            "entryPoint": null,
            "portMappings": [
                {
                    "hostPort": 80,
                    "protocol": "tcp",
                    "containerPort": 80
                }
            ],
            "command": null,
            "linuxParameters": null,
            "cpu": 0,
            "environment": [],
            "resourceRequirements": null,
            "ulimits": null,
            "dnsServers": null,
            "mountPoints": [],
            "workingDirectory": null,
            "secrets": null,
            "dockerSecurityOptions": null,
            "memory": null,
            "memoryReservation": 128,
            "volumesFrom": [],
            "stopTimeout": null,
            "image": "<+artifact.image>",
            "startTimeout": null,
            "firelensConfiguration": null,
            "dependsOn": null,
            "disableNetworking": null,
            "interactive": null,
            "healthCheck": null,
            "essential": true,
            "links": null,
            "hostname": null,
            "extraHosts": null,
            "pseudoTerminal": null,
            "user": null,
            "readonlyRootFilesystem": null,
            "dockerLabels": null,
            "systemControls": null,
            "privileged": null,
            "name": "nginx"
        }
    ],
    "placementConstraints": [],
    "memory": "512",
    "taskRoleArn": "<ecsInstanceRole Role ARN>",
    "family": "fargate-task-definition",
    "pidMode": null,
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "networkMode": "awsvpc",
    "runtimePlatform": null,
    "cpu": "256",
    "inferenceAccelerators": null,
    "proxyConfiguration": null,
    "volumes": []
}
```

### ECS 2.0 Service Definition - Supported Fields

#### Sample Service Definition and supported parameters - YAML Example**

```YAML
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

### Sample Service Definition and supported parameters - JSON Example

``` JSON
{
    "launchType": "FARGATE",
    "serviceName": "myapp",
    "desiredCount": 1,
    "networkConfiguration": {
        "awsvpcConfiguration": {
            "securityGroups": [
                "<Security Group Id>"
            ],
            "subnets": [
                "<Subnet Id>"
            ],
            "assignPublicIp": "ENABLED"
        }
    },
    "deploymentConfiguration": {
        "maximumPercent": 100,
        "minimumHealthyPercent": 0
    }
}
```
### ECS Run Task Request Definition Supported Fields
Supported schema details can be found here
https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_RunTask.html

### Infrastructure Definitions

- The Infrastructure Definitions in ECS v2 do not have AWS VPC, Security Group, Network Policies associated with it, this configuration is now moved to the service
- The cluster can be a runtime input, this makes the infrastructure definition re-usable for other clusters in a given environment
- Infrastructure Definition YAML has changed for ECS

```YAML
infrastructureDefinition:
  name: ecs-dev-cluster
  identifier: ecsDevCluster
  description: "Sanbox Development Cluster"
  tags: {}
  orgIdentifier: default
  projectIdentifier: cdProductManagement
  environmentRef: devEcs
  deploymentType: ECS
  type: ECS
  spec:
    connectorRef: account.awsEcs
    region: us-east-1
    cluster: staging
  allowSimultaneousDeployments: false

```

## Best Practices

### For Templates and ECS Deployments

- You can templatize your pipelines in Harness NG. Harness enables you to add Templates to create reusable logic and Harness Entities (like `Steps`, `Stages`, and `Pipelines`) in your Pipelines. You can link these Templates in your Pipelines or share them with your teams for improved efficiency. Click on `Start with Template` if you want to use this feature. More about [Templates](https://docs.harness.io/article/6tl8zyxeol-template)

### For ECS Service Configuration

- We recommend storing ECS Manifests in remote stores like Github, Bitbucket etc  as they support version controlling on Files and it is easier to track configuration and revert changes.

- Harness recommends using service variables to templatize entities in ‘Harness Service’ entities. For example, You can refer to service variables in your Manifests using variable expressions such as <+serviceVariables.serviceName>. Here is sample ‘Service Definition’ with service variables

### For ECS Environment Configuration

If ‘Harness Service’ Configuration Parameters need to be overridden based on Infrastructure, Harness recommends using ‘Harness Service’ Variables and override them at Environment level. More about this here.

```TEXT
      For example, AWS Security Group in ECS Service Definition need to overridden at Environment. We recommend creating a Service Variable ‘securityGroup’ in ‘Harness Service’ and used it in ECS Service Definition Manifest as '<+serviceVariables.securityGroup>
```

This service variable ‘securityGroup’ value can be overridden at Environment Level

### For ECS Deployment

#### Rolling Deployment

To achieve rollout of ECS Deployment in a Phased manner, we recommend using
deploymentConfiguration field in ‘ECS Service Definition’
For example:

```YAML
deploymentConfiguration:
  maximumPercent: 100
  minimumHealthyPercent: 80
```

To understand how this configuration works, please refer to [AWS documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_definition_parameters.html)


#### Blue-Green Deployments

- Harness recommends using Approval Step between ‘ECS Blue Green Create Service’ and ‘ECS Blue Green Swap Target Groups’ Step. This is to verify new service deployment health before shifting traffic from old service to new service.

- For Critical Services with High Availability requirements, Harness recommends enabling the ‘Do not downsize old service’ option in ECS Blue Green Swap Target Groups step. When this option is enabled Harness will not downsize old service.This will help in faster rollbacks as rollback process only involves switching traffic at load balancer as old service is already up and running.

#### ECS Migration Manual Changes Checklist
- Need to add task family in task definiton
- Need to add service name, desired count in Service Definition Manifest. In First Gen, these are are part of Step. 
- Load balancer configuration if present need to be mapped manually from 'ECS Service Setup' step in First Gen to 'Service Defintion' manifest in NG.
- 'Same as already running instances' config need to set based on First Gen Configuration.
- In Scaling Policy, Scalable Target keys in json need to start with lower case alphabets. In First Gen, they are upper case alphabets.
- ECS Run Task Request Definition need to be manually configured in Next Gen. This manifest is not present in Current Gen at all.


