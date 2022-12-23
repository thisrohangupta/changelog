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

## Managing Templates

- Harness has various ways for users to manage templates with their account
- Templates can be managed at different levels like Account, Organization and Project Level
- Harness offers RBAC for the templates at each of the levels in the Platfrom Hierarchy
- Templates can be versioned via Harness and can be versioned in Git
- When you reference resources in a Template, you can only reference resources in it's scope. Please see below:

```TEXT
Use Case 1: Account Level Deploy Stage Template 

Expected Behavior:

- User will NOT be able to hard code a service because there are no services at the account level, this means the field will be <+input>

- User will NOT be able to hard code an environment because there are no environments at the account level, this also means the field will be <+input>

- Your Execution Steps will be configured as is with no restrictions at the account level

- Variables that you define at the account level stage template should be configured as fixed or runtime input values so that they can be defined when referenced in a Pipeline.

- Connectors you reference are only at the Account level, you cannot reference a connector in a lower level org or project.

---

Use Case 2: Org Level Deploy Stage Template

Expected Behavior:

- Users will NOT be able to fix a service because there are no services at the org level, so they are going to be defined as <+input>. When used in a pipeline, the user will be able to configure an expression, keep it runtime or fix the service. 

- User will NOT be able to fix an environment because there are no environments at the org level, this means that it will be configured as <+input>. When referenced in a pipeline in a given project, users will be able to pick an environment within the project. 

- Connectors Options you have when you reference in the template are scoped to the org the template is configured in and the Account level. The selection is also dictated by the users RBAC who is configuring the template.

- Variables should be either a fixed value or runtime input so the user can configure the correct option when its linked in the pipeline. 

```

## Rolling out changes with your Templates

- Harness offers various mechanisms to make changes to your template and roll them out to your users and pipelines

```TEXT
You can manage in 2 ways:

  1. Users can leverage our Inline Template experience, meaning the template files are backed in Harness and are fully managed in Harness

  2. Harness can manage the template in Github and make commits and PR Driven changes to it
  ```

- Both methods have benefits and can provide user's with a easy and scalable way to manage, edit and promote templates

- In your Pipeline, when referencing a Template, you can configure it to always fetch the Stable version, this means when you make changes to the template and promote it as the stable version, the changes are automatically published and pushed to all pipeliens referencing that template.

### Inline Templates

- When managing the templates in Harness, the templates are stored in the Harness Database and the versions are managed in Harness

- The user can configure templates and make changes to the templates in the UI and update an existing version or create a new version.

- Users can set the version of a template that is used in a Pipeline when they build out the pipeline.

- Users can set any version of the template to be the stable version and all pipelines referencing that template with the option "Always reference from Stable" will get the changes pushed

### Creating a new Version of Harness Backed (Inline) Template

- You should manage the versions of the templates primarily in the UI, this ensures you can see the changes between updates to an existing version of the template.

- When decided where to store the template, you should understand the following:
  - how many users are going to consume this template?
  - are these users in different teams?
  - will they have access to the same resources?

- Given the answer to the above questions you can decide if you want to store the templates at the `account`, `organization`, or `project` level in the Harness Platform.

- You can manage the creation and state of these templates via our terraform provider. For more information please see the [Harness Templates Terraform Provider Resource](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_template)

A Sample Terraform Resource snippet for Inline Templates:

```YAML
resource "harness_platform_template" "inline" {
  identifier    = "identifier"
  org_id        = harness_platform_project.test.org_id
  project_id    = harness_platform_project.test.id
  name          = "name"
  comments      = "comments"
  version       = "ab"
  is_stable     = true
  template_yaml = <<-EOT
template:
      name: "name"
      identifier: "identifier"
      versionLabel: ab
      type: Pipeline
      projectIdentifier: ${harness_platform_project.test.id}
      orgIdentifier: ${harness_platform_project.test.org_id}
      tags: {}
      spec:
        stages:
          - stage:
              name: dvvdvd
              identifier: dvvdvd
              description: ""
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
                  serviceOverrideInputs: <+input>
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
                  rollbackSteps:
                    - step:
                        name: Rollback Rollout Deployment
                        identifier: rollbackRolloutDeployment
                        type: K8sRollingRollback
                        timeout: 10m
                        spec:
                          pruningEnabled: false
              tags: {}
              failureStrategies:
                - onFailure:
                    errors:
                      - AllErrors
                    action:
                      type: StageRollback

      EOT
}
```

### Creating a new Version of a Template with Git Experience

- User's can manage their Templates in Github 
- When user's create a new version of the template, Harness creates a new file with the file name `<template_name>_<version>.yaml`
- User's can manage templates on different branches, this allows for safe changes to an existing version without pushing it to users on the stable, main branch version.
- If you wish to track changes to your template, we recommend updating the same file and using branches to manage different versions and changes.

  *Note: User's shouldn't mix and match Harness versioning with Github Versioning if they wish to track changes to a template*

- When referencing a pipeline with a template, you need to make sure the pipeline branch is the same branch as the template if the template resides in the same repo.

Sample Template YAML in Github:

```YAML
template:
    name: Rohan Template
    identifier: Rohan_Template
    versionLabel: 0.0.1
    type: Step
    projectIdentifier: CD_Product_Team
    orgIdentifier: default
    description: "Shell Script Template"
    tags: {}
    spec:
        type: ShellScript
        timeout: 10m
        spec:
            shell: Bash
            onDelegate: true
            source:
                type: Inline
                spec:
                    script: |-
                        echo "Hello World"
                        
                        echo "This is Git to Harness, Hi Rohan!"
            environmentVariables: []
            outputVariables: []
            executionTarget: {}
```

- You can create templates via Terraform Automation in Github, Harness offers a Terraform Provider Resource for Templates to be configured in Git. See [here](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_template) for more information.

Below is a sample Terraform Resource Snippet:

```YAML
resource "harness_platform_template" "remote" {
  identifier = "identifier"
  org_id     = harness_platform_project.test.org_id
  project_id = harness_platform_project.test.id
  name       = "name"
  comments   = "comments"
  version    = "ab"
  is_stable  = true
  git_details {
    branch_name    = "main"
    commit_message = "Commit"
    file_path      = "file_path"
    connector_ref  = "account.connector_ref"
    store_type     = "REMOTE"
    repo_name      = "repo_name"
  }
  template_yaml = <<-EOT
template:
      name: "name"
      identifier: "identifier"
      versionLabel: ab
      type: Pipeline
      projectIdentifier: ${harness_platform_project.test.id}
      orgIdentifier: ${harness_platform_project.test.org_id}
      tags: {}
      spec:
        stages:
          - stage:
              name: dvvdvd
              identifier: dvvdvd
              description: ""
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
                  serviceOverrideInputs: <+input>
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
                  rollbackSteps:
                    - step:
                        name: Rollback Rollout Deployment
                        identifier: rollbackRolloutDeployment
                        type: K8sRollingRollback
                        timeout: 10m
                        spec:
                          pruningEnabled: false
              tags: {}
              failureStrategies:
                - onFailure:
                    errors:
                      - AllErrors
                    action:
                      type: StageRollback

      EOT
}
```

### What Changes to your Template are backward compatible?

- When making changes to your template sometimes they cannot be backwards compatible, specifically when users configure a variable and reference it in a step or stage.

- When reverting the template that version will no longer have the variable and that could break the step that is referencing if not properly maintained

- Backwards compatible changes are changes to the configurations of Harness deployment steps in a pipeline. Often times the configurations change the behavior but are minimal risk to the overall execution of the pipeline. 

### Reconciling Changes to your Template

- When users make a change to a template and a pipeline is referencing that template, Harness will flag in the UI that the Template needs to be reconciled
- Harness will show the git yaml diff for the Pipeline and show what lines have been updated.
- The user can update the template by clicking Save and Harness will reconcile the change it make it the default state.
