variable "organisation" {
  description = "Nom de l'organisation"
  type        = string

  validation {
    condition     = length(var.organisation) > 0
    error_message = "Le nom de l'organisation ne peut pas être vide."
  }
}

variable "environnement" {
  description = "Environnement de déploiement"
  type        = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environnement)
    error_message = "L'environnement doit être l'un des suivants : dev, test, prod."
  }
}

variable "projet" {
  description = "Nom du projet"
  type        = string

  validation {
    condition     = length(var.projet) > 0
    error_message = "Le nom du projet ne peut pas être vide."
  }
}

variable "base_port" {
  description = "Port de base pour le calcul dynamique des ports publics"
  type        = number

  validation {
    condition     = var.base_port >= 1024 && var.base_port <= 65000
    error_message = "Le base_port doit être compris entre 1024 et 65000."
  }
}

variable "services" {
  description = "Map des services Docker à provisionner"
  type = map(object({
    image         = string
    internal_port = optional(number)
    public        = bool
    env           = optional(map(string), {})
    volume        = optional(string)
  }))

  validation {
    condition = alltrue([
      for name, service in var.services :
      service.public == false || service.internal_port != null
    ])
    error_message = "Si un service a public=true, alors internal_port ne peut pas être null."
  }

  validation {
    condition = alltrue([
      for name, service in var.services :
      !contains(["redis", "postgres", "mysql", "mongodb"], name) || service.public == false
    ])
    error_message = "Les services de base de données (redis, postgres, mysql, mongodb) ne peuvent pas être exposés publiquement."
  }
}

variable "network_driver" {
  description = "Driver du réseau Docker"
  type        = string
  default     = "bridge"
}
