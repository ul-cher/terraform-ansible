# ========================================
# RESSOURCES DOCKER - MULTI-SERVICES
# ========================================

# ─────────────────────────────────────
# 1. RÉSEAU DOCKER UNIQUE
# ─────────────────────────────────────

resource "docker_network" "app_network" {
  name   = format("%s-network", local.naming_prefix)
  driver = var.network_driver

  labels {
    label = "managed_by"
    value = local.common_labels.managed_by
  }

  labels {
    label = "organisation"
    value = local.common_labels.organisation
  }

  labels {
    label = "environnement"
    value = local.common_labels.environnement
  }

  labels {
    label = "projet"
    value = local.common_labels.projet
  }
}

# ─────────────────────────────────────
# 2. VOLUMES CONDITIONNELS
# ─────────────────────────────────────
# Créés uniquement pour les services qui en déclarent

resource "docker_volume" "service_volumes" {
  for_each = local.services_with_volumes

  name = format("%s-volume", local.service_names[each.key])

  labels {
    label = "managed_by"
    value = local.common_labels.managed_by
  }

  labels {
    label = "service"
    value = each.key
  }

  labels {
    label = "environnement"
    value = var.environnement
  }
}

# ─────────────────────────────────────
# 3. IMAGES DOCKER
# ─────────────────────────────────────

resource "docker_image" "service_images" {
  for_each = var.services

  name         = each.value.image
  keep_locally = false
}

# ─────────────────────────────────────
# 4. CONTAINERS DOCKER (for_each)
# ─────────────────────────────────────

resource "docker_container" "services" {
  for_each = var.services

  name  = local.service_names[each.key]
  image = docker_image.service_images[each.key].image_id

  # Configuration réseau
  networks_advanced {
    name = docker_network.app_network.name
  }

  # Configuration des ports (conditionnelle)
  dynamic "ports" {
    for_each = each.value.public && each.value.internal_port != null ? [1] : []

    content {
      internal = each.value.internal_port
      external = local.service_ports[each.key]
      protocol = "tcp"
    }
  }

  # Configuration des volumes (conditionnelle)
  dynamic "volumes" {
    for_each = each.value.volume != null ? [1] : []

    content {
      volume_name    = docker_volume.service_volumes[each.key].name
      container_path = each.value.volume
    }
  }

  # Variables d'environnement
  env = [
    for key, value in merge(
      each.value.env,
      {
        SERVICE_NAME  = each.key
        ENVIRONMENT   = var.environnement
        MANAGED_BY    = "terraform"
      }
    ) : "${key}=${value}"
  ]

  # Politique de redémarrage
  restart = "unless-stopped"

  # Labels Terraform
  labels {
    label = "managed_by"
    value = local.common_labels.managed_by
  }

  labels {
    label = "service"
    value = each.key
  }

  labels {
    label = "environnement"
    value = var.environnement
  }

  labels {
    label = "organisation"
    value = var.organisation
  }

  labels {
    label = "public"
    value = tostring(each.value.public)
  }

  must_run = true

  # Dépendances
  depends_on = [
    docker_network.app_network
  ]
}
