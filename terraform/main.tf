resource "docker_network" "app_network" {
  name   = var.network_name
  driver = "bridge"
  
  labels {
    label = "managed_by"
    value = "terraform"
  }
}

resource "docker_volume" "app_volume" {
  name = var.volume_name
  
  labels {
    label = "managed_by"
    value = "terraform"
  }
}

resource "docker_image" "app_image" {
  name = var.image_name
  keep_locally = false
}


resource "docker_container" "app_container" {
  name  = var.container_name
  image = docker_image.app_image.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = var.internal_port
    external = var.external_port
    protocol = "tcp"
  }

  volumes {
    volume_name    = docker_volume.app_volume.name
    container_path = "/usr/share/nginx/html"
  }

  env = [for key, value in var.environment : "${key}=${value}"]
  
  restart = var.restart_policy
  
  labels {
    label = "managed_by"
    value = "terraform"
  }

  labels {
    label = "environment"
    value = var.environment["ENV"]
  }
  
  must_run = true
}