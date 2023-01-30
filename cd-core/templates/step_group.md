# Step Group Templates Support

- Harness allows user's to group steps together into a Step Group.
- The Step Group can be configured as a Template and be shared at the: `project`, `organization`, and `account` level.
- User's can customize the configuration of the Step Group Template in the Template Studio
- It can be used with Harness CIE and CD. 
- User's can manage the access to the Step Group Template via the Access Control settings for Templates


## Step Group Template YAML Sample

```YAML
template:
  name: Validate Kubernetes Rollout
  type: StepGroup
  projectIdentifier: proj1
  orgIdentifier: swarajtest2
  spec:
    steps:
      - step:
          type: K8sDryRun
          name: Output Servie Manifest
          identifier: Output_Servie_Manifest
          spec: {}
          timeout: 10m
      - step:
          type: HarnessApproval
          name: Approve Harness Manifests
          identifier: Approve_Harness_Manifests
          spec:
            approvalMessage: Please review the following information and approve the pipeline progression
            includePipelineExecutionHistory: true
            approvers:
              userGroups:
                - account._account_all_users
              minimumCount: 1
              disallowPipelineExecutor: false
            approverInputs: []
          timeout: 1d
      - step:
          type: K8sRollingDeploy
          name: Rolling Deployment
          identifier: Rolling_Deployment
          spec:
            skipDryRun: false
            pruningEnabled: false
          timeout: 10m
    stageType: Deployment
    when:
      stageStatus: Success
      condition: <+input>
  identifier: Validate_Kubernetes_Rollout
  versionLabel: "1.0"
```

## Limitations

- As of 1.30.2022 - Harness only supports Step Group Templates inline, we are working to provide a remote template support.


