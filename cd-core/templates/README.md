# Template Library

In Harness CD 2.0, we have revamped our Template Library Experience. Templates are a more prominent feature in Harness CD 2.0 that enables users to share and scale their CD Process within their account. There are a lot of changes that have been introduced from CD 1.0 to CD 2.0. Below are the list of changes and capabilities we have introduced with the new CD 2.0 release.

## What has Changed from Harness CD 1.0

- Harness has improved the experience around managing templates, users can now set a stable version that can be enforced with all pipelines that reference it
- More Steps are supported as templates
- New Pipeline Template offering
- Template design studio has been overhauled so users can easily build their templates with ease.
- Templates can be versioned and a stable version can be enforced via the Template Library in the Harness UI
- You can copy the configuration of a template and forgoe linking it
  - **WARNING: If you do not link a template, then you cannot enforce the stable version**

### Difference between Copy and Use Template in the Harness UI

#### Copy Template Option

- Copy Template copies the pure configuration of a template, it doesn't have any link to the template
- Copy template is great for quick configuration of a step, stage or pipeline without being tied to a specific version of the template.

#### Use Template Option

- Use Template ensures a link to the template
- Any changes to the existing version will get propagated down to all resources referencing that template.
- If user's select "Always use Stable" when linking a template to a pipeline or stage, any stable version that gets promoted will be pushed to those resources using that template
- User's can fix a version of the template to a specific pipeline to prevent the adoption of a newly published template and its changes

### RBAC for Templates

- User's now have Permissions at the Account, Org and Project level for templates
- Harness supports `create`, `edit/delete`, `access`, and `copy`
  - `create` - user can create a template
  - `edit/delete` - user can edit an existing template or delete it
  - `access` - user can add a template to their pipeline for deployment / build use
  - `copy` - user can copy a template configuration into a pipeline  

### Step Templates

- Harness now offers more Step Template options for users
- Any step that is available in our Step pallete is available as a template
- Step Templates can be managed in git via the [Harness Git Experience](https://docs.harness.io/article/xl028jo9jk-git-experience-overview)
- Step Templates can be created at the Account, the Organization, or at the Project level.
- Step Templates can be used in Pipelines, Stages, Stage Templates, Pipeline Templates
- Templates are supported for Continuous Integration Steps & Continuous Delivery Steps

#### Sample YAML Snippet

```YAML
template:
  name: Cleanup Demo
  identifier: Cleanup_Demo
  versionLabel: 0.0.1
  type: Step
  projectIdentifier: Rohan
  orgIdentifier: default
  spec:
    type: K8sDelete
    spec:
      deleteResources:
        type: ReleaseName
        spec:
          deleteNamespace: true
    timeout: 10m

```

Below shows how its used in a pipeline:

```YAML
pipeline:
  name: Multi Service Deployment Demo
  identifier: Multi_Service_Deployment_Demo
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
          service:
            serviceRef: <+input>
            serviceInputs: <+input>
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

## Step Template Reference in a Pipeline
## You will provide the templateRef and version that's going to be configured for the step

              - step:
                  name: Cleanup Demo
                  identifier: CleanupDemo
                  template:
                    templateRef: Cleanup_Demo
                    versionLabel: 0.0.1
            rollbackSteps:
              - step:
                  name: Rollback Rollout Deployment
                  identifier: rollbackRolloutDeployment
                  type: K8sRollingRollback
                  timeout: 10m
                  spec:
                    pruningEnabled: false
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
        tags: {}
        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: StageRollback
  allowStageExecutions: true

```

### Stage Templates

- Harness supports stage types: Build, Deploy, Custom, and Approval Stages as Templates
- User's can configure a stage template at the Project, Organization and Account level
- Stage Templates can be versioned in Harness or via our [Harness Git Experience](https://docs.harness.io/article/xl028jo9jk-git-experience-overview)
- Users can define cariables within the stage template and they are accessible within the pipeline that the template is referenced in.

#### Sample Stage Template

```YAML
template:
  name: CD Deploy
  identifier: CD_Deploy
  versionLabel: "1.0"
  type: Stage
  tags: {}
  spec:
    type: Deployment
    spec:
      deploymentType: Kubernetes
      service:
        serviceRef: <+input>
        serviceInputs: <+input>
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
              type: Http
              name: Health Check
              identifier: Health_Check
              spec:
                url: https://app.harness.io
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
    when:
      pipelineStatus: Success
      condition: <+input>


```

Below is a Pipeline referencing the Stage Template:
pipeline:

- The stage templates can take in inputs at runtime during pipeline run or fix it in the pipeline when it's linked to the pipeline and provide identifiers for object input or strings for variable input.
- When referencing a template at the account level: `account.<templateIdentifier>`
- When referencing a template at the organization level: `org.<templateIdentifier>`
- Sta

```YAML
  name: Multi Service Deployment Demo
  identifier: Multi_Service_Deployment_Demo
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
          service:
            serviceRef: <+input>
            serviceInputs: <+input>
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
                  name: Cleanup Demo
                  identifier: CleanupDemo
                  template:
                    templateRef: Cleanup_Demo
                    versionLabel: 0.0.1
            rollbackSteps:
              - step:
                  name: Rollback Rollout Deployment
                  identifier: rollbackRolloutDeployment
                  type: K8sRollingRollback
                  timeout: 10m
                  spec:
                    pruningEnabled: false
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
        tags: {}
        failureStrategies:
          - onFailure:
              errors:
                - AllErrors
              action:
                type: StageRollback
    - stage:
        name: Dev Deploy
        identifier: Dev_Deploy

## Stage Template is referenced in the pipeline, if its an account level template use the preffix account.<templateIdentifier> and if it's an organization template - org.<templateIdenteifier>
        template:
          templateRef: account.CD_Deploy
          versionLabel: "1.0"
          templateInputs:
            type: Deployment
            spec:
              service:
                serviceRef: <+input>
                serviceInputs: <+input>
              environment:
                environmentRef: <+input>
                environmentInputs: <+input>
                infrastructureDefinitions: <+input>
            when:
              condition: <+input>
  allowStageExecutions: true
```

### Pipeline Templates

- Pipeline Templates can support all stage types to be configured in it and be saved as one pipeline template
- Pipeline templates can reference Stage Templates at the same object level or higher.
- Pipeline Templates can be managed in the [Harness Git Experience](https://docs.harness.io/article/xl028jo9jk-git-experience-overview)
- Steps and Stages are un-editable when its linked to a pipeline in a project. The user needs to go to the studio to change the template configuration

#### Sample Pipeline Template

```YAML
template:
## the name is the name of the pipeline when it's linked with a pipeline template
  name: "Golden Pipeline"
  type: Pipeline
  projectIdentifier: sandbox
  orgIdentifier: default
  spec:
    stages:
      - stage:
          name: Deploy to Dev
          identifier: Deploy_to_Dev
          template:
            templateRef: Deploy_Stage
            versionLabel: "1.0"
            templateInputs:
              type: Deployment
              spec:
                service:
                  serviceRef: <+input>
                  serviceInputs: <+input>
                environment:
                  environmentRef: <+input>
                  environmentInputs: <+input>
                  serviceOverrideInputs: <+input>
                  infrastructureDefinitions: <+input>
      - stage:
          name: Deploy to QA
          identifier: Deploy_to_QA
          template:
            templateRef: Deploy_Stage
            versionLabel: "1.0"
            templateInputs:
              type: Deployment
              spec:
                service:
                  serviceRef: <+input>
                  serviceInputs: <+input>
                environment:
                  environmentRef: <+input>
                  environmentInputs: <+input>
                  serviceOverrideInputs: <+input>
                  infrastructureDefinitions: <+input>
      - stage:
          name: Approve
          identifier: Approve
          description: ""
          type: Approval
          spec:
            execution:
              steps:
                - step:
                    name: Approve
                    identifier: Approve
                    type: HarnessApproval
                    timeout: 1d
                    spec:
                      approvalMessage: |-
                        Please review the following information
                        and approve the pipeline progression
                      includePipelineExecutionHistory: true
                      approvers:
                        minimumCount: 1
                        disallowPipelineExecutor: false
                        userGroups:
                          - account._account_all_users
                      approverInputs: []
          tags: {}
      - stage:
          name: Deploy to Prod
          identifier: Deploy_to_Prod
          template:
            templateRef: Deploy_Stage
            versionLabel: "1.0"
            templateInputs:
              type: Deployment
              spec:
                service:
                  serviceRef: <+input>
                  serviceInputs: <+input>
                environment:
                  environmentRef: <+input>
                  environmentInputs: <+input>
                  serviceOverrideInputs: <+input>
                  infrastructureDefinitions: <+input>

## Below is the identifier for the Pipeline Template and the version label
  identifier: End_2_End_Pipeline
  versionLabel: "1.0"

```
