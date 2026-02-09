output "container_id" {
  description = "ID du container Docker"
  value       = docker_container.app_container.id
}

output "container_name" {
  description = "Nom du container Docker"
  value       = docker_container.app_container.name
}

output "network_name" {
  description = "Nom du réseau Docker"
  value       = docker_network.app_network.name
}

output "volume_name" {
  description = "Nom du volume Docker"
  value       = docker_volume.app_volume.name
}

output "external_port" {
  description = "Port externe exposé"
  value       = var.external_port
}

output "internal_port" {
  description = "Port interne du container"
  value       = var.internal_port
}

output "app_url" {
  description = "URL locale pour accéder à l'application"
  value       = "http://localhost:${var.external_port}"
}

output "container_status" {
  description = "Statut du container"
  value       = docker_container.app_container.must_run ? "running" : "stopped"
}

output "restart_policy" {
  description = "Politique de redémarrage configurée"
  value       = docker_container.app_container.restart
}
