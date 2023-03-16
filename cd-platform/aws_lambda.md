# AWS Lambda Deployment Support + Quickstart

## Introduction

Harness supports the deployment of AWS Lambda Functions. Below is a guide to get started on using the swimlane to deploy your Lambda functions through Harness CD! The swimlane only deploys the Lambda Function, it doesn't update any auxillary things like the API Gateway, or the Triggers etc. It's designed to empower developers to launch their Lambda code with ease without having to mess with the infrastructure components around AWS Lambda. Harness can deploy a new Lambda function or update an existing Lambda Function



## Lambda Service Configuration

Harness lets users define a service that represents their AWS Lambda Function they wish to deploy. 

[AWS Lambda] (<img width="1512" alt="image" src="https://user-images.githubusercontent.com/52221549/225522422-1834e511-4393-4e61-8784-e1a032cd9404.png">)


### Artifacts

Harness supports deploying your AWS Lambda's that are packaged as `.zip` in S3 Buckets or as containers from `ECR`. These are the only two artifact sources AWS Cloud Provider supports today with AWS Lambda. 

[AWS Lambda Artifact Sources] (<img width="857" alt="image" src="https://user-images.githubusercontent.com/52221549/225522517-d2451973-e443-45e5-9969-d1abdff5d3a8.png">)


### Function Definition

Harness has introduced a JSON configuration file to define the AWS Lambda you wish to deploy. This configuration lets you define things like:

- VPC
- Lambda Layers
- Runtime
- Handler
- Tags


For a full list of supported fields, please check out the [AWS Lambda Create Function Request](https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html)


Below is are some Sample Function Definition to get started:

**Node JS Hello World Function**

```JSON
{
   "runtime": "nodejs16.x",
   "functionName": "Hello World",
   "handler": "handler.hello",
   "role": "<YOUR_AWS_ARN>"
}

```

You can use [Service Variables] in your function definition json, this allows your function definition yaml to be reusable across multiple lambdas. It can also be used to override configuration of a particular Lambda per environment.

```JSON
{
   "runtime": "<+serviceVariables.runtime>",
   "functionName": "<+serviceVariables.functionName>",
   "handler": "<+serviceVariables.handler>",
   "role": "<+serviceVariables.roleARN>"
}
```


**ECR Lambda Function**

```JSON
{
   "functionName": "helloworld-lambda-ecr",
   "role": "<YOUR_ARN>"
}
```



### Sample Service YAML

Below is a Sample Service Definition YAML in for the AWS Lambda


```YAML
service:
  name: helloworld
  identifier: helloworld
  description: "Hello World AWS Lambda"
  tags: {}
  serviceDefinition:
    spec:
      manifests: # Harness introduces a function definition to define the properties of your AWS Lambda function
        - manifest:
            identifier: lambdaFunctionDefinition 
            type: AwsLambdaFunctionDefinition
            spec:
              store:
                type: Github
                spec:
                  connectorRef: rohitgithub
                  gitFetchType: Branch
                  paths:
                    - serverless/aws-lambda/createFunction.json
                  branch: master
      artifacts: # The artifact is the packaged .zip or Docker image you wish to deploy to AWS
        primary:
          primaryArtifactRef: <+input>
          sources:
            - spec:
                connectorRef: awscp
                bucketName: sainathlambda
                region: us-east-2
                filePath: <+serviceVariables.workload_name>
              identifier: test
              type: AmazonS3
      variables:
        - name: workload_name
          type: String
          description: "sample variable definition"
          value: workloadNameValue
    type: AwsLambda

```


## Lambda Environment and Infrastructure Configuration

User's will need to configure an Environment and Infrastructure Definition to tell Harness where to deploy the Lambda Function Service defined earlier.

We will need an [AWS Connector](https://developer.harness.io/docs/platform/connectors/add-aws-connector/) to be able to connect to an AWS Account and specify a region to deploy. This connector will be used to deploy your Lambda and access the AWS cloud provider.

**Sample Environment Definition**

```YAML
environment:
  name: aws
  identifier: aws
  description: "sandbox aws account"
  tags: {}
  type: PreProduction
  orgIdentifier: default
  projectIdentifier: serverlesstest
  variables: []

```

**Sample Infrastructure Definition**

```YAML
infrastructureDefinition:
  name: aws-lambda
  identifier: awslambda
  description: ""
  tags: {}
  orgIdentifier: default
  projectIdentifier: serverlesstest
  environmentRef: aws
  deploymentType: AwsLambda
  type: AwsLambda
  spec:
    connectorRef: awscp
    region: us-east-2
  allowSimultaneousDeployments: false

```

## Lambda Steps

### Lambda Deployment Steps


Below is a YAML snippet of the Deploy Lambda Step. It requires minimal configuration because Harness handles the logic to deploy the artifact to the proper AWS Account and Region. Harness will deploy the Lambda function and automatically route the traffic from the old version of the Lambda function to the newly deployed one.


```YAML
- step:
                  name: Deploy Aws Lambda
                  identifier: deployawslambda
                  type: AwsLambdaDeploy
                  timeout: 10m
                  spec: {}
                  when:
                    stageStatus: Success
                    condition: "false"
                  failureStrategies: []
```

### Rollback Deploy Step

Below is the YAML snippet for the AWS Lambda Rollback Step. When a Pipeline fails, Harness will automatically rollback your Lambda function to the previous version using the Rollback step. Harness remembers the successful version of the AWS Lambda Service deployed and rollback for you. 

```YAML
            rollbackSteps:
              - step:
                  name: Aws Lambda rollback
                  identifier: awslambdarollback
                  type: AwsLambdaRollback
                  timeout: 10m
                  spec: {}
```


