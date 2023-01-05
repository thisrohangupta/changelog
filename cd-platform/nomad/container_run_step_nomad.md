# Running Nomad Deployments with Harness Container Run Steps

## Container Step Configuration

- Harness offers a container step to let you run any user defined workload via a container in a Kubernetes Cluster
- The user can provide their own dockerimage and Harness will pull the image with the dependencies and perform the task
- [Nomad Public Docker Image](https://hub.docker.com/r/djenriquez/nomad): `docker pull djenriquez/nomad`
- Sample Github Repos to build off:
    1. <https://github.com/jdxlabs/hello-nomad>
    2. <https://github.com/multani/docker-nomad>

### Sample DockerFile

*From Github Repo*:

```DockerFile
FROM alpine:3.17.0

SHELL ["/bin/ash", "-x", "-c", "-o", "pipefail"]

# Based on https://github.com/djenriquez/nomad
LABEL maintainer="Jonathan Ballet <jon@multani.info>"

RUN addgroup nomad \
 && adduser -S -G nomad nomad \
 && mkdir -p /nomad/data \
 && mkdir -p /etc/nomad \
 && chown -R nomad:nomad /nomad /etc/nomad

# Allow to fetch artifacts from TLS endpoint during the builds and by Nomad after.
# Install timezone data so we can run Nomad periodic jobs containing timezone information
RUN apk --update --no-cache add \
        ca-certificates \
        dumb-init \
        libcap \
        tzdata \
        su-exec \
  && update-ca-certificates

# https://github.com/sgerrand/alpine-pkg-glibc/releases
ARG GLIBC_VERSION=2.34-r0

ADD https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub
ADD https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    glibc.apk
RUN apk add --no-cache --force-overwrite \
        glibc.apk \
 && rm glibc.apk

# https://releases.hashicorp.com/nomad/
ARG NOMAD_VERSION=1.4.3

ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip \
    nomad_${NOMAD_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS \
    nomad_${NOMAD_VERSION}_SHA256SUMS
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig \
    nomad_${NOMAD_VERSION}_SHA256SUMS.sig
RUN apk add --no-cache --virtual .nomad-deps gnupg \
  && GNUPGHOME="$(mktemp -d)" \
  && export GNUPGHOME \
  && gpg --keyserver pgp.mit.edu --keyserver keys.openpgp.org --keyserver keyserver.ubuntu.com --recv-keys "C874 011F 0AB4 0511 0D02 1055 3436 5D94 72D7 468F" \
  && gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS \
  && grep nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c \
  && unzip -d /bin nomad_${NOMAD_VERSION}_linux_amd64.zip \
  && chmod +x /bin/nomad \
  && rm -rf "$GNUPGHOME" nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS nomad_${NOMAD_VERSION}_SHA256SUMS.sig \
  && apk del .nomad-deps

EXPOSE 4646 4647 4648 4648/udp

COPY start.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/start.sh"]
```

### Sample Start.sh

```Shell
#!/usr/bin/dumb-init /bin/sh
# Script created following Hashicorp's model for Consul: 
# https://github.com/hashicorp/docker-consul/blob/master/0.X/docker-entrypoint.sh
# Comments in this file originate from the project above, simply replacing 'Consul' with 'Nomad'.
set -e

# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.

# NOMAD_DATA_DIR is exposed as a volume for possible persistent storage. The
# NOMAD_CONFIG_DIR isn't exposed as a volume but you can compose additional
# config files in there if you use this image as a base, or use NOMAD_LOCAL_CONFIG
# below.
NOMAD_DATA_DIR=${NOMAD_DATA_DIR:-"/nomad/data"}
NOMAD_CONFIG_DIR=${NOMAD_CONFIG_DIR:-"/etc/nomad"}

# You can also set the NOMAD_LOCAL_CONFIG environemnt variable to pass some
# Nomad configuration JSON without having to bind any volumes.
if [ -n "$NOMAD_LOCAL_CONFIG" ]; then
    echo "$NOMAD_LOCAL_CONFIG" > "$NOMAD_CONFIG_DIR/local.json"
fi

# If the user is trying to run Nomad directly with some arguments, then
# pass them to Nomad.
if [ "${1:0:1}" = '-' ]; then
    set -- nomad "$@"
fi

# Look for Nomad subcommands.
if [ "$1" = 'agent' ]; then
    shift
    set -- nomad agent \
        -data-dir="$NOMAD_DATA_DIR" \
        -config="$NOMAD_CONFIG_DIR" \
        "$@"
elif [ "$1" = 'version' ]; then
    # This needs a special case because there's no help output.
    set -- nomad "$@"
elif nomad --help "$1" 2>&1 | grep -q "nomad $1"; then
    # We can't use the return code to check for the existence of a subcommand, so
    # we have to use grep to look for a pattern in the help output.
    set -- nomad "$@"
fi

# If we are running Nomad, make sure it executes as the proper user.
if [ "$1" = 'nomad' ] && [ -z "${NOMAD_DISABLE_PERM_MGMT+x}" ]; then
    # If the data or config dirs are bind mounted then chown them.
    # Note: This checks for root ownership as that's the most common case.
    if [ "$(stat -c %u $NOMAD_DATA_DIR)" != "$(id -u root)" ]; then
        chown root:root $NOMAD_DATA_DIR
    fi

    # If requested, set the capability to bind to privileged ports before
    # we drop to the non-root user. Note that this doesn't work with all
    # storage drivers (it won't work with AUFS).
    if [ -n ${NOMAD+x} ]; then
        setcap "cap_net_bind_service=+ep" /bin/nomad
    fi

    set -- su-exec root "$@"
fi

exec "$@"
```

#### Server Side Nomad Docker Commands

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

#### Client Side Nomad Docker Commands

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

#### Store the Nomad File in Github

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
                            nomad job run ./multiregion.hcl
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


#### Pre-Requisites

1. Docker Image with Nomad and Client Properties installed in it, or are exposed as environment params we can inject in.
2. The Job will be spun up in Kubernetes Cluster as a pod - so K8s Cluster needed
3. A Delegate that can access the nomad infrastructure 
