variable "image_name" {
  description = "Nom de l'image Docker à utiliser"
  type        = string
  default     = "nginx:alpine"
}

variable "container_name" {
  description = "Nom du container Docker"
  type        = string
  default     = "app-nginx"
}

variable "external_port" {
  description = "Port externe exposé sur l'hôte"
  type        = number
  default     = 8080
}

variable "internal_port" {
  description = "Port interne du container"
  type        = number
  default     = 80
}

variable "network_name" {
  description = "Nom du réseau Docker"
  type        = string
  default     = "app-network"
}

variable "volume_name" {
  description = "Nom du volume Docker"
  type        = string
  default     = "app-data"
}

variable "environment" {
  description = "Variables d'environnement (clé/valeur)"
  type        = map(string)
  default = {
    ENV = "development"
  }
}

variable "restart_policy" {
  description = "Politique de redémarrage du container"
  type        = string
  default     = "unless-stopped"
}
