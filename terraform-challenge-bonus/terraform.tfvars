# ========================================
# CONFIGURATION EXEMPLE - Challenge Terraform Avancé
# ========================================

# ─────────────────────────────────────
# METADATA DU PROJET
# ─────────────────────────────────────

organisation  = "ESILV"
environnement = "dev"
projet        = "challenge-bonus"

# ─────────────────────────────────────
# CONFIGURATION RÉSEAU
# ─────────────────────────────────────

base_port      = 8080
network_driver = "bridge"

# ─────────────────────────────────────
# SERVICES DOCKER
# ─────────────────────────────────────

services = {
  # Service 1 : NGINX (serveur web public)
  nginx = {
    image         = "nginx:stable"
    internal_port = 80
    public        = true
    env = {
      NGINX_HOST = "localhost"
      NGINX_PORT = "80"
    }
    volume = "/usr/share/nginx/html"
  }

  # Service 2 : Whoami (service de test public)
  whoami = {
    image         = "traefik/whoami:latest"
    internal_port = 80
    public        = true
    env = {
      WHOAMI_PORT_NUMBER = "80"
    }
    volume = null
  }

  # Service 3 : Redis (base de données privée)
  redis = {
    image         = "redis:7-alpine"
    internal_port = null
    public        = false
    env = {
      REDIS_MAXMEMORY = "256mb"
    }
    volume = "/data"
  }

  # Service 4 : API Backend (service public)
  api = {
    image         = "nginx:alpine"  # Simulé avec nginx pour le test
    internal_port = 80
    public        = true
    env = {
      API_ENV     = "development"
      LOG_LEVEL   = "debug"
    }
    volume = null
  }

  # Service 5 : Worker (service privé)
  worker = {
    image         = "alpine:latest"
    internal_port = null
    public        = false
    env = {
      WORKER_THREADS = "4"
      QUEUE_URL      = "redis://redis:6379"
    }
    volume = null
  }
}
