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
