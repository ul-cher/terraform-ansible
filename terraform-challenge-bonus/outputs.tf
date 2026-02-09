# ========================================
# OUTPUTS STRUCTURÉS
# ========================================

# ─────────────────────────────────────
# 1. OUTPUT PRINCIPAL : Services
# ─────────────────────────────────────

output "services" {
  description = "Informations structurées pour tous les services déployés"
  value = {
    for name, config in var.services :
    name => {
      # Identification
      name            = local.service_names[name]
      original_name   = name
      image           = config.image
      
      # Container
      container_id    = docker_container.services[name].id
      container_short_id = substr(docker_container.services[name].id, 0, 12)
      status          = "running"
      
      # Réseau
      network         = docker_network.app_network.name
      internal_ip     = length(docker_container.services[name].network_data) > 0 ? docker_container.services[name].network_data[0].ip_address : null
      
      # Ports & Accessibilité
      internal_port   = config.internal_port
      external_port   = config.public ? local.service_ports[name] : null
      public          = config.public
      url             = local.service_urls[name]
      
      # Volume
      has_volume      = config.volume != null
      volume_name     = config.volume != null ? docker_volume.service_volumes[name].name : null
      volume_path     = config.volume
      
      # Metadata
      environment     = var.environnement
      restart_policy  = docker_container.services[name].restart
    }
  }
}

# ─────────────────────────────────────
# 2. OUTPUTS SPÉCIFIQUES
# ─────────────────────────────────────

output "public_services" {
  description = "Liste des services accessibles publiquement avec leurs URLs"
  value = {
    for name, url in local.service_urls :
    name => url if url != null
  }
}

output "service_ports_mapping" {
  description = "Mapping service → port externe calculé"
  value       = local.service_ports
}

output "network_info" {
  description = "Informations sur le réseau Docker créé"
  value = {
    id     = docker_network.app_network.id
    name   = docker_network.app_network.name
    driver = docker_network.app_network.driver
    scope  = docker_network.app_network.scope
  }
}

output "volumes_info" {
  description = "Informations sur les volumes Docker créés"
  value = {
    for name, volume in docker_volume.service_volumes :
    name => {
      id         = volume.id
      name       = volume.name
      driver     = volume.driver
      mountpoint = volume.mountpoint
    }
  }
}

output "deployment_summary" {
  description = "Résumé du déploiement"
  value = {
    organisation     = var.organisation
    environnement    = var.environnement
    projet           = var.projet
    naming_prefix    = local.naming_prefix
    total_services   = length(var.services)
    public_services  = length(local.public_services)
    private_services = length(var.services) - length(local.public_services)
    services_with_volumes = length(local.services_with_volumes)
    base_port        = var.base_port
    network_name     = docker_network.app_network.name
  }
}

# ─────────────────────────────────────
# 3. OUTPUT POUR DEBUGGING
# ─────────────────────────────────────

output "naming_debug" {
  description = "Informations de debug sur le naming"
  value       = local.normalize
}

output "quick_access_urls" {
  description = "URLs rapides pour tester les services publics"
  value = [
    for name in local.public_services :
    format("curl http://localhost:%d  # %s", local.service_ports[name], name)
  ]
}
