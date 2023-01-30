# Introduction

Service and Environments can now be created at the Account and Organization Levels. Depending on the user's access, you can pick the Service and Environment from the account and organization level and leverage it in a project for deployment.  

## Account and Organization Service

By creating an Account Level service, user's will be able to create a globally (account wide) managed service that can be accessible to Oganizations and Projects within the account. The service would no longer be tied to a specific project and can be referenced from a higher level in the heirarchy.

### Configuration

The Service can only be configured with resources that are in it's same scope. An account level service can only reference connectors for the manifests and artifacts that are also at the account level. Since these objects are global they CANNOT have dependencies that are at lower levels.

#### YAML Configuration

```YAML
service:
  name: nginx
  identifier: nginx
  tags: {}
  serviceDefinition:
    spec:
      manifests:
        - manifest:
            identifier: nginx-base
            type: K8sManifest
            spec:
              store:
                type: Github
                spec:
                  connectorRef: account.Harness_K8sManifest
                  gitFetchType: Branch
                  paths:
                    - cdng/
                  repoName: <+input>
                  branch: main
              skipResourceVersioning: false
      artifacts:
        primary:
          primaryArtifactRef: <+input>
          sources:
            - spec:
                connectorRef: account.Harness_DockerHub
                imagePath: library/nginx
                tag: <+input>
                digest: <+input>
              identifier: harness dockerhub
              type: DockerRegistry
    type: Kubernetes
```

- There are no major YAML Changes to the Service object when it's configured at the account or organization level.

### API and Terraform Changes

```TEXT
TO BE DOCUMENTED
```

### The benefits

- User's don't have as many similar or identical services to manage at the project level because the same service can be referenced accross multiple projects
- The service can be managed outside of the project teams, giving Harness Platform owners the ability to manage services at scale at the account level
- Shared services, now have a common service reference that can be created and managed at the Account or Organization level. 


### How to Use Services at the account or org level when designing with Templates

- User's can reference the Service in the same scope as the template, meaning if a user has an Account Level Deployment Stage Template, you can only fix the account level service in the template.

- User's have an Organization level Deployment Stage Template, user's would only be able to reference organization level service to be fixed in the template

### When using a Deployment Stage Template in a Pipeline that has a service configured as runtime input

- User's can now pick services from the project, organization or account level to pass in as runtime into the Deployment Stage Template.

- Based on RBAC, the user's selection to pick a service will be scoped to what permissions the user has access to (i.e. `runtime`, `view`)

## Account and Organization Environment

Environments can now be created at the Account and Organization level. This includes the Infrastructure Definitions and Service Overrides.

### Configuration 

There isn't any major configuration changes when configuring an Environment at the Org or Account level. When user's define an account level environment, the


