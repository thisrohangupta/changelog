# Deploying Helm Charts with Dependencies and Subcharts

In Helm, user's can define dependencies and subcharts that they can reference in their main Helm Chart. Helm will go download the dependencies and subcharts from existing repository or seperate repositories. 

Helm Subchart and Dependency Support is available for Kubernetes Deployment Types that are deploying Helm Charts as the Manifest source and our Native Helm Deployment Swimlane.

To Configure the subcharts, you will need define them in your service. You will need to define the sub chart name which is a path to the chart that resides in the parent chart.

For any dependencies to be resolved, you will need to configure the Helm Command with a Flag `Template` with `--dependency-update` this will allow Harness to go fetch your dependencies that you have defined in your chart.yaml. 

Harness supports Canary, Blue-Green and Rolling Deployments with the Helm Subcharts and Dependencies feature when deploying with Kubernetes. 

Harness supports deploying a basic strategy with native Helm and the Helm Subchart and dependency capabilities.




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


During Pipeline Execution you will see Harness fetch the subcharts and fetch the dependencies for deployment. In the fetch files section we will fetch the Subchart and show the fetched subchart in the fetched files collected.

![Pipeline Execution](https://github.com/thisrohangupta/changelog/blob/86315629686631cc7de7c93aa70bdd9c215ebb39/images/Screenshot%202023-03-07%20at%2011.13.43%20PM.png)


In the prepare section, we will run the template command with the `--dependency-update` flag.

![Prepare Section](<img width="1491" alt="image" src="https://user-images.githubusercontent.com/52221549/223647251-f006522a-8ee3-429e-9003-d2d40e5031e0.png">




