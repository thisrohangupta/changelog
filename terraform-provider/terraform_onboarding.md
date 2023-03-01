# Onboarding Automation to Harness via the Harness Terraform Provider

## Introduction

Usually, Harness users leverage the Terraform Provider to help automate scale their adoption and growth within the platform. Harness offers a first-class [Terraform Provider](https://developer.harness.io/docs/platform/terraform/harness-terraform-provider-overview/)

You can navigate to our Terraform Module Offering in the [HashiCorp Terrafrom Registry](https://registry.terraform.io/providers/harness/harness/latest/docs). Select the 'NextGen' Resources drop down to see all the resources we support with our Terraform Provider for the Harness Platform.

## Onboarding Automation

We have some basics to help user's get started with the Harness Terraform Provider covered in our [Terraform Provider Quickstart](https://developer.harness.io/docs/platform/Terraform/harness-terraform-provider). In order to get started with Harness Terraform Provider automation, we recommend user's installing a delegate with the Terraform CLI configured. We will need this to build out the automation pipelines to create the various resources

### Sample Delegate YAML

Please review the Kubernetes [Delegate YAML Quickstart](https://developer.harness.io/docs/first-gen/firstgen-platform/account/manage-delegates/install-kubernetes-delegate/) to install a kubernetes delegate. You will need to download the YAML and make some changes before you apply the delegate yaml to your Kubernetes cluster.

We will be making changes to the `INIT_SCRIPT` field in this YAML. For more details on [INIT_SCRIPTS](https://developer.harness.io/docs/platform/delegates/delegate-reference/common-delegate-profile-scripts/#terraform)

```YAML
apiVersion: v1
kind: Namespace
metadata:
  name: harness-delegate-ng

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: harness-delegate-ng-cluster-admin
subjects:
  - kind: ServiceAccount
    name: default
    namespace: harness-delegate-ng
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io

---

apiVersion: v1
kind: Secret
metadata:
  name: terraform-proxy
  namespace: harness-delegate-ng
type: Opaque
data:
  # Enter base64 encoded username and password, if needed
  PROXY_USER: ""
  PROXY_PASSWORD: ""

---

apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    harness.io/name: terraform
  name: terraform
  namespace: harness-delegate-ng
spec:
  replicas: 1
  podManagementPolicy: Parallel
  selector:
    matchLabels:
      harness.io/name: terraform
  serviceName: ""
  template:
    metadata:
      labels:
        harness.io/name: terraform
    spec:
      containers:
      - image: harness/delegate:latest
        imagePullPolicy: Always
        name: harness-delegate-instance
        ports:
          - containerPort: 8080
        resources:
          limits:
            memory: "2048Mi"
          requests:
            cpu: "0.5"
            memory: "2048Mi"
        readinessProbe:
          exec:
            command:
              - test
              - -s
              - delegate.log
          initialDelaySeconds: 20
          periodSeconds: 10
        livenessProbe:
          exec:
            command:
              - bash
              - -c
              - '[[ -e /opt/harness-delegate/msg/data/watcher-data && $(($(date +%s000) - $(grep heartbeat /opt/harness-delegate/msg/data/watcher-data | cut -d ":" -f 2 | cut -d "," -f 1))) -lt 300000 ]]'
          initialDelaySeconds: 240
          periodSeconds: 10
          failureThreshold: 2
        env:
        - name: JAVA_OPTS
          value: "-Xms64M"
        - name: ACCOUNT_ID
          value: <YOUR ACCOUNT ID> ## Your Account ID will be generated here
        - name: MANAGER_HOST_AND_PORT
          value: https://app.harness.io
        - name: DEPLOY_MODE
          value: KUBERNETES
        - name: DELEGATE_NAME
          value: terraform
        - name: DELEGATE_TYPE
          value: "KUBERNETES"
        - name: DELEGATE_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: INIT_SCRIPT
          value: | ## Install Terraform Here, You can use the latest version, of Terraform.
                curl -O -L  https://releases.hashicorp.com/terraform/0.12.25/terraform_0.12.25_linux_amd64.zip  
                unzip terraform_0.12.25_linux_amd64.zip  
                mv ./terraform /usr/bin/          
                terraform --version  
        - name: DELEGATE_DESCRIPTION
          value: ""
        - name: DELEGATE_TAGS
          value: ""
        - name: NEXT_GEN
          value: "true"
        - name: DELEGATE_TOKEN
          value: <YOUR DELEGATE TOKEN> ## Your Generated Delegate token will go here
        - name: WATCHER_STORAGE_URL
          value: https://app.harness.io/public/prod/premium/watchers
        - name: WATCHER_CHECK_LOCATION
          value: current.version
        - name: DELEGATE_STORAGE_URL
          value: https://app.harness.io
        - name: DELEGATE_CHECK_LOCATION
          value: delegateprod.txt
        - name: HELM_DESIRED_VERSION
          value: ""
        - name: CDN_URL
          value: "https://app.harness.io"
        - name: REMOTE_WATCHER_URL_CDN
          value: "https://app.harness.io/public/shared/watchers/builds"
        - name: JRE_VERSION
          value: 11.0.14
        - name: HELM3_PATH
          value: ""
        - name: HELM_PATH
          value: ""
        - name: KUSTOMIZE_PATH
          value: ""
        - name: KUBECTL_PATH
          value: ""
        - name: POLL_FOR_TASKS
          value: "false"
        - name: ENABLE_CE
          value: "false"
        - name: PROXY_HOST
          value: ""
        - name: PROXY_PORT
          value: ""
        - name: PROXY_SCHEME
          value: ""
        - name: NO_PROXY
          value: ""
        - name: PROXY_MANAGER
          value: "true"
        - name: PROXY_USER
          valueFrom:
            secretKeyRef:
              name: terraform-proxy
              key: PROXY_USER
        - name: PROXY_PASSWORD
          valueFrom:
            secretKeyRef:
              name: terraform-proxy
              key: PROXY_PASSWORD
        - name: GRPC_SERVICE_ENABLED
          value: "true"
        - name: GRPC_SERVICE_CONNECTOR_PORT
          value: "8080"
      restartPolicy: Always

---

apiVersion: v1
kind: Service
metadata:
  name: delegate-service
  namespace: harness-delegate-ng
spec:
  type: ClusterIP
  selector:
    harness.io/name: terraform
  ports:
    - port: 8080

```

Once you make these changes to the delegate yaml, please connect to the Kubernetes Cluster to install. You will need to run:

```SH
kubectl apply -f harness-delegate.yaml
```

To verify if the Terraform CLI was successfully installed please run the command:

```SH
kubectl logs <HARNESS_DELEGATE_POD_NAME> -n harness-delegate-ng
```

You can then search for "Terraform" to see if the CLI was installed successfully or not. 

### Setup a Github Repo to host the Harness Configuration

We recommend user's to create a new Github Repo to store and manage the Harness Configuration. Please see Github's tutorial on [creating a new Github Repo](https://docs.github.com/en/get-started/importing-your-projects-to-github/importing-source-code-to-github/adding-locally-hosted-code-to-github#adding-a-local-repository-to-github-using-git). User's can also leverage an existing repo to manage the Harness Configuration.

We propose a management folder structure like below:

```md
service/
-- backend-service.tf
-- frontend-service.tf
-- transformer.tf

environments/
-- dev.tf
-- qa.tf
-- prod.tf 

infrastructure/
-- dev_k8s.tf
-- qa_k8s.tf
-- prod_k8s.tf 
```

### Store the automation pipeline

Harness recommends storing the automation pipeline to create and manage resources in a common project that many teams can access. You can create a project called "Onboarding" and users can leverage this to run the pipeline to create a service, environment, infrastructure definition, secret, etc.

The other alternative is to create pipeline templates that teams can use in their project. This lets a central team manage the pipelines for onboarding and distribute them to the app teams to leverage and onboard.

## Onboarding a Service

For onboarding a Service onto Harness you will need to use the [Harness Terraform Resource](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/platform_service).

Your will need to create this YAML and store it in your Github Repository.

```YAML
resource "harness_platform_service" "service" {
  identifier  = "nginx" ## Service Identifier
  name        = "nginx" ## Service Name to appear in Harness
  description = "sample nginx app created via Harness terraform Provider"  
  org_id      = "default" ## Replace with Harness Org Identifier for the resource
  project_id  = "cdproduct" ## Replace with your Harness Project Identifier
  yaml = <<-EOT
                service:
                  name: name
                  identifier: identifier
                  serviceDefinition:
                    spec:
                      manifests:
                        - manifest:
                            identifier: manifest1
                            type: K8sManifest
                            spec:
                              store:
                                type: Github
                                spec:
                                  connectorRef: <+input>
                                  gitFetchType: Branch
                                  paths:
                                    - files1
                                  repoName: <+input>
                                  branch: master
                              skipResourceVersioning: false
                      configFiles:
                        - configFile:
                            identifier: configFile1
                            spec:
                              store:
                                type: Harness
                                spec:
                                  files:
                                    - <+org.description>
                      variables:
                        - name: var1
                          type: String
                          value: val1
                        - name: var2
                          type: String
                          value: val2
                    type: Kubernetes
                  gitOpsEnabled: false
              EOT
}
```

## Onboarding an Environment


##  Onbarding an Infrastructure Definition


##  Sample Pipeline to Setup


## Best Practices









