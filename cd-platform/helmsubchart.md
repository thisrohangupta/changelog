# Deploying Helm Charts with Dependencies and Subcharts

## Introduction

This Feature is behind a Feature Flag, please contact Harness support to enable the flag.
`Feature Flage Name: NG_CDS_HELM_SUB_CHARTS`

In Helm, users can define dependencies and subcharts that they can reference in their main Helm Chart. Helm will go download the dependencies and subcharts from existing repository or seperate repositories. 

Helm Subchart and Dependency Support is available for Kubernetes Deployment Types that are deploying Helm Charts as the Manifest source and our Native Helm Deployment Swimlane.

## Service Configuration

To Configure the subcharts, you will need to define them in your service. You will need to define the sub chart name which is a path to the chart that resides in the parent chart. Please ensure that all your sub-charts are located within the `charts/` folder inside your parent chart. 
Sample dir:
```
charts/
	- subchart1/
		 - templates/
			 - app.yaml
		 - Chart.yaml
		 - values.yaml
```

For any dependencies to be resolved, you will need to configure the Helm Command with a Flag `Template` with `--dependency-update` this will allow Harness to go fetch your dependencies that you have defined in your chart.yaml. 

### Sample Service YAML

- You can create a Kubernetes Deployment Type Service to leverage this feature
- You can also create a Native Helm Deployment type service to use this feature



```YAML
service:
  name: K8sHelmSubChart
  identifier: K8sHelmSubChart
  serviceDefinition:
    type: Kubernetes
    spec:
      manifests:
        - manifest:
            identifier: m1
            type: HelmChart
            spec:
              store:
                type: Github
                spec:
                  connectorRef: gitHubAchyuth
                  gitFetchType: Branch
                  folderPath: parent-chart
                  branch: main
              subChartName: first-child
              skipResourceVersioning: false
              enableDeclarativeRollback: false
              helmVersion: V3
              commandFlags:
                - commandType: Template
                  flag: "--dependency-update"
  gitOpsEnabled: false

```


### Supported Swimlanes

Harness supports Canary, Blue-Green and Rolling Deployments with the Helm Subcharts and Dependencies feature when deploying with Kubernetes. 

Harness supports deploying a basic strategy with native Helm and the Helm Subchart and dependency capabilities.


### Pipeline Execution of a Helm Chart with Subcharts

During Pipeline Execution you will see Harness fetch the subcharts and fetch the dependencies for deployment. In the fetch files section we will fetch the Subchart and show the fetched subchart in the fetched files collected.

![Pipeline Execution](https://github.com/thisrohangupta/changelog/blob/86315629686631cc7de7c93aa70bdd9c215ebb39/images/Screenshot%202023-03-07%20at%2011.13.43%20PM.png)


In the prepare section, we will run the `template` command with the `--dependency-update` flag.

![Prepare Section](https://github.com/thisrohangupta/changelog/blob/1008aab8d5ad861d95420a2b6ff472aa824d4219/images/Screenshot%202023-03-07%20at%2011.17.46%20PM.png)



