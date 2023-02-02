# Run Container Step

- User's will be able to spin up a container in their Kubernetes Cluster and run any docker container of their choice.
- The Run Command Step lets user's bring their own container and lets Harness orchestrate it
- The Infrastructure where the container is spun up is for Kubernetes Infrastructure only. 
- We can fetch containers from any container registry:
  - Docker
  - Google Container Registry
  - Elastic Container Registry
  - Azure Container Registry
  - Artifactory
  - Nexus


### Sample YAML

```YAML
              - step:
                  type: Container
                  spec:
                    connectorRef: public_dockerhub
                    image: maven
                    command: echo "Run some smoke tests"
                    shell: Sh
                    infrastructure:
                      type: KubernetesDirect
                      spec:
                        connectorRef: pmk8scluster
                        namespace: dev
                        resources:
                          limits:
                            cpu: "0.5"
                            memory: 500Mi
                    outputVariables:
                      - name: testResult
                    envVariables:
                      ENV: <+env.name>

```

#### Inputs

- `connector` : This is the docker connector that will be used to fetch your image
- `image` : the image path to define which image repository to fetch the container
- `command` : this is a free form text that lets user's pass in any commands
- `infrastructure` : this defines  the kubernetes cluster where the user will spin up this container
- `resource` : User's can define the size and the limits of the container they wish to spin up


#### Outputs
- `outputVariables` : these are outputs that are defined and are captured after the container step execution
- `envVariables` : These are environment variables to define for the step.
