# TD Terraform & Ansible - Infrastructure Docker

## Contexte

Ce projet implémente une séparation claire des responsabilités entre Terraform (provisionnement) et Ansible (validation & hygiène). L'objectif est de créer un socle reproductible pour des environnements applicatifs conteneurisés.

### Ressources provisionnées

- **Réseau Docker** : `app-network` (bridge)
- **Volume Docker** : `app-data` (persistant)
- **Container** : `app-nginx` (nginx:alpine)
- **Port exposé** : 8080 → 80

## Structure du projet

```
td-terraform-ansible/
├── terraform/
│   ├── main.tf           # Ressources Docker
│   ├── variables.tf      # Variables configurables
│   ├── outputs.tf        # Outputs exportés
│   ├── versions.tf       # Versions Terraform & providers
│   └── terraform.tfvars  # Valeurs des variables
├── ansible/
│   ├── inventory.ini     # Inventaire localhost
│   └── validate.yml      # Playbook validation/hygiène
└── README.md             # Documentation
```


## Détails techniques

### Terraform

#### Variables principales

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `image_name` | Image Docker | `nginx:alpine` |
| `container_name` | Nom du container | `app-nginx` |
| `external_port` | Port exposé | `8080` |
| `internal_port` | Port interne | `80` |
| `restart_policy` | Politique de redémarrage | `unless-stopped` |

#### Outputs exportés

- `container_id` : ID du container
- `container_name` : Nom du container
- `app_url` : URL d'accès (http://localhost:8080)
- `external_port` / `internal_port` : Mapping des ports
- `restart_policy` : Politique configurée

### Ansible

#### Vérifications effectuées

**Validation HTTP :**
- Service HTTP accessible (status 200)
- Timeout configuré (10s)
- Retry automatique (3 tentatives)

**Hygiène (read-only checks) :**
- Container en état `running`
- Port 8080 exposé correctement
- Politique de redémarrage = `unless-stopped`
- Label Terraform présent (`managed_by=terraform`)

#### Idempotence

Le playbook Ansible est **100% idempotent** et **non-intrusif** :
- Aucune modification du container
- Utilisation de `changed_when: false` pour les commandes read-only
- Assertions avec messages clairs
- Mode check supporté

## Contraintes respectées

- Terraform ne contient aucun script de configuration applicative
- Ansible ne modifie pas l'infrastructure Docker
- Pas de `local-exec` / `remote-exec` pour configurer le service
- Les checks Ansible sont idempotents et non-intrusifs

## Limites

- Déploiement local uniquement (Docker local)
- Pas de gestion multi-environnements avancée
- Pas de registry privée
- Pas d’orchestration type Kubernetes

## Réponses aux questions

### 1. Pourquoi séparer provisionnement et validation ?

La séparation permet :

Responsabilité unique par outil

Meilleure maintenabilité

Moins d’effets de bord

Plus grande clarté architecturale

Terraform gère l’état désiré de l’infrastructure.
Ansible vérifie que cet état est conforme et fonctionnel.

### 2. En quoi les outputs Terraform facilitent l’automatisation ?

Les outputs permettent :

D’exposer dynamiquement ports et URLs

D’alimenter des pipelines CI/CD

D’éviter les valeurs codées en dur

D’enchaîner automatiquement Terraform → Ansible → Tests

Ils servent d’interface entre l’infrastructure et les outils de validation.

### 3. Quelle est la valeur d'Ansible dans un rôle non-configurant ?

Même sans modifier l’infrastructure, Ansible :

Vérifie la conformité

Détecte les dérives

Permet des audits automatisés

Sert d’outil de validation dans une pipeline CI

Il agit comme un mécanisme de contrôle qualité.

### 4. Comment ce socle évoluerait vers un environnement CI/CD ?

**Pipeline GitOps proposé** :

```yaml
# .gitlab-ci.yml / .github/workflows/deploy.yml
stages:
  - validate
  - plan
  - apply
  - test
  - healthcheck

terraform-validate:
  stage: validate
  script:
    - terraform init
    - terraform validate
    - terraform fmt -check

terraform-plan:
  stage: plan
  script:
    - terraform plan -out=plan.tfplan
  artifacts:
    paths: [plan.tfplan]

terraform-apply:
  stage: apply
  script:
    - terraform apply -auto-approve plan.tfplan
    - terraform output -json > outputs.json
  artifacts:
    paths: [outputs.json]

ansible-validate:
  stage: test
  script:
    - export APP_URL=$(jq -r .app_url.value outputs.json)
    - ansible-playbook validate.yml
  dependencies:
    - terraform-apply

healthcheck:
  stage: healthcheck
  script:
    - curl -f $(jq -r .app_url.value outputs.json)
    - docker stats --no-stream app-nginx
```

**Évolutions possibles** :

1. **Multi-environnements** :
   ```
   terraform/
   ├── environments/
   │   ├── dev/
   │   ├── staging/
   │   └── prod/
   ```

2. **State management** :
   ```hcl
   terraform {
     backend "s3" {
       bucket = "terraform-states"
       key    = "app/terraform.tfstate"
     }
   }
   ```

3. **Tests avancés** :
   - Terratest (tests Go pour Terraform)
   - Molecule (tests Ansible)
   - Tests de charge (k6, Apache Bench)

4. **Monitoring** :
   - Prometheus exporters
   - Logs centralisés (ELK, Loki)
   - Alerting (Alertmanager)

5. **Sécurité** :
   - Scan de vulnérabilités (Trivy)
   - Policy as Code (OPA, Sentinel)
   - Secrets management (Vault)