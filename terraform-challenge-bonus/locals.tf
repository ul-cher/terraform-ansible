# ========================================
# LOCALS : Naming & Calculs Dynamiques
# ========================================

locals {
  # ─────────────────────────────────────
  # 1. NAMING STANDARDISÉ
  # ─────────────────────────────────────
  # Pattern: {organisation}-{environnement}-{projet}-{service}
  # Normalisation: minuscules, caractères spéciaux remplacés par des tirets
  
  # Normaliser chaque composant puis les joindre
  naming_prefix = join("-", [
    lower(replace(var.organisation, "/[^a-zA-Z0-9]/", "")),
    lower(replace(var.environnement, "/[^a-zA-Z0-9]/", "")),
    lower(replace(var.projet, "/[^a-zA-Z0-9]/", ""))
  ])

  # Génération des noms de services normalisés
  service_names = {
    for name, config in var.services :
    name => format("%s-%s",
      local.naming_prefix,
      lower(replace(name, "/[^a-zA-Z0-9]/", "-"))
    )
  }

  # ─────────────────────────────────────
  # 2. CALCUL DYNAMIQUE DES PORTS
  # ─────────────────────────────────────
  
  # Liste triée des services publics (pour garantir l'ordre)
  public_services = sort([
    for name, config in var.services :
    name if config.public == true
  ])

  # Map service → port externe calculé
  # Formule: base_port + index dans la liste triée
  service_ports = {
    for idx, name in local.public_services :
    name => var.base_port + idx
  }

  # ─────────────────────────────────────
  # 3. VOLUMES DYNAMIQUES
  # ─────────────────────────────────────
  
  # Filtre: créer des volumes uniquement pour les services qui le demandent
  services_with_volumes = {
    for name, config in var.services :
    name => config if config.volume != null
  }

  # ─────────────────────────────────────
  # 4. GÉNÉRATION DES URLS
  # ─────────────────────────────────────
  
  # Map service → URL publique (ou null si non public)
  service_urls = {
    for name, config in var.services :
    name => config.public ? format("http://localhost:%d", local.service_ports[name]) : null
  }

  # ─────────────────────────────────────
  # 5. LABELS COMMUNS
  # ─────────────────────────────────────
  
  common_labels = {
    managed_by   = "terraform"
    organisation = var.organisation
    environnement = var.environnement
    projet       = var.projet
  }

  # ─────────────────────────────────────
  # 6. FONCTION SIMULÉE : Normalisation
  # ─────────────────────────────────────
  # Pattern avancé : simulation de fonction via locals
  # Utilisé pour factoriser la logique de normalisation
  
  normalize = {
    for name, _ in var.services :
    name => {
      original   = name
      normalized = local.service_names[name]
      prefix     = local.naming_prefix
    }
  }
}
