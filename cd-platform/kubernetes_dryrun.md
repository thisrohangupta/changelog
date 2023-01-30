# Kubernetes Dry Run Step

- Users can perform a Dry Run of the Service Manifests for Kubernetes, and output the Dry Run as a file for use.
- User's can export the `manifest-dry-run.yaml` as a variable for a subsequent step.
- The Variable to reference the manifest - `<+pipeline.stages.{STAGE_ID}.spec.execution.steps.{STEP_ID}.k8s.ManifestDryRun>`
- User's can leverage the Dry Run Manifests, Validate the manifests and then use the validated manifests in a kubernetes deployment step.

## Step Configuration

```YAML
              - step:
                  type: K8sDryRun
                  name: Output Service Manifests
                  identifier: OutputService
                  spec: {}
                  timeout: 10m
```

