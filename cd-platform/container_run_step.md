# Running Nomad Deployments with Harness Container Run Steps

## Container Step Configuration

- Harness offers a container step to let you run any user defined workload via a container in a Kubernetes Cluster
- The user can provide their own dockerimage and Harness will pull the image with the dependencies and perform the task
- [Nomad Public Docker Image](https://hub.docker.com/r/djenriquez/nomad): `docker pull djenriquez/nomad`

### Server Side Nomad Docker Commands

```SHELL
docker run -d \
--name nomad \
--net host \
-e NOMAD_LOCAL_CONFIG='{ "server": {
        "enabled": true,
        "bootstrap_expect": 3
    },
    "datacenter": "${DATACENTER}",
    "region": "${REGION}",
    "data_dir": "/nomad/data/",
    "bind_addr": "0.0.0.0",
    "advertise": {
        "http": "${IPV4}:4646",
        "rpc": "${IPV4}:4647",
        "serf": "${IPV4}:4648"
    },
    "enable_debug": true }' \
-v "/opt/nomad:/opt/nomad" \
-v "/var/run/docker.sock:/var/run/docker.sock" \
-v "/tmp:/tmp" \
djenriquez/nomad:v0.6.0 agent
```

### Client Side Nomad Docker Commands

```SHELL
docker run -d \
--name nomad \
--net host \
-e NOMAD_LOCAL_CONFIG='{ "client": {
        "enabled": true
    },
    "datacenter": "${DATACENTER}",
    "region": "${REGION}",
    "data_dir": "/nomad/data/",
    "bind_addr": "0.0.0.0",
    "advertise": {
        "http": "${IPV4}:4646",
        "rpc": "${IPV4}:4647",
        "serf": "${IPV4}:4648"
    },
    "enable_debug": true }' \
-v "/opt/nomad:/opt/nomad" \
-v "/var/run/docker.sock:/var/run/docker.sock" \
-v "/tmp:/tmp" \
djenriquez/nomad:v0.6.0 agent
```

### Store the Nomad File in Github

```nomad
job "example" {

  multiregion {

    strategy {
      max_parallel = 1
      on_failure   = "fail_all"
    }

    region "west" {
      count       = 2
      datacenters = ["west-1"]
    }

    region "east" {
      count       = 1
      datacenters = ["east-1", "east-2"]
    }

  }

  update {
    max_parallel      = 1
    min_healthy_time  = "10s"
    healthy_deadline  = "2m"
    progress_deadline = "3m"
    auto_revert       = true
    auto_promote      = true
    canary            = 1
    stagger           = "30s"
  }


  group "cache" {

    count = 0

    network {
      port "db" {
        to = 6379
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:6.0"

        ports = ["db"]
      }

      resources {
        cpu    = 256
        memory = 128
      }
    }
  }
}
```

### Container Run Step Nomad File Sample Deploy Step

```YAML
step:
                    type: Container
                    name: nomad deploy
                    identifier: nomad_deploy
                    timeout: 10m
                    spec:
                        command: |-
                            git clone https://github.com/thisrohangupta/nomadSample.git
                            nomad job run ./multi.nomad
                        image: djenriquez/nomad:v0.6.0
                        shell: sh
                        infrastructure: 
                            type: KubernetesDirect
                            spec:
                                connectorRef: ab.asd
                                namespace: default
                                resources:
                                    limits:
                                        cpu: 1
                                        memory: 500Mi
```

#### Nomad Container Plugin Step - Get Deployment Status

```YAML
step:
                    type: Container
                    name: nomad deploy status
                    identifier: nomad_deploy_status
                    timeout: 10m
                    spec:
                        command: |-
                            nomad job status -region east example
                        image: djenriquez/nomad:v0.6.0
                        shell: sh
                        infrastructure: 
                            type: KubernetesDirect
                            spec:
                                connectorRef: ab.asd
                                namespace: default
                                resources:
                                    limits:
                                        cpu: 1
                                        memory: 500Mi
```


#### Nomad Container Plugin Step - Unblock Nomad Deployyment

```YAML
step:
                    type: Container
                    name: nomad deploy unblock
                    identifier: nomad_deploy_unblock
                    timeout: 10m
                    spec:
                        command: |-
                            nomad deployment unblock -region east f08122e5
                        image: djenriquez/nomad:v0.6.0
                        shell: sh
                        infrastructure: 
                            type: KubernetesDirect
                            spec:
                                connectorRef: ab.asd
                                namespace: default
                                resources:
                                    limits:
                                        cpu: 1
                                        memory: 500Mi
```

