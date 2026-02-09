.PHONY: help init validate fmt plan apply destroy clean test outputs

help:
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║    Challenge Terraform Avancé - Commandes Disponibles     ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "  init         : Initialise Terraform"
	@echo "  validate     : Valide la syntaxe Terraform"
	@echo "  fmt          : Formate le code Terraform"
	@echo "  plan         : Affiche le plan de déploiement"
	@echo "  apply        : Déploie l'infrastructure"
	@echo "  outputs      : Affiche les outputs"
	@echo "  test         : Teste les services déployés"
	@echo "  destroy      : Détruit l'infrastructure"
	@echo "  clean        : Nettoie les fichiers Terraform"
	@echo "  all          : Workflow complet (init + validate + apply)"
	@echo ""

init:
	@echo "🔧 Initialisation de Terraform..."
	/opt/homebrew/bin/terraform init

validate:
	@echo "✓ Validation du code Terraform..."
	/opt/homebrew/bin/terraform validate

fmt:
	@echo "📝 Formatage du code..."
	/opt/homebrew/bin/terraform fmt -recursive

plan:
	@echo "📋 Création du plan..."
	/opt/homebrew/bin/terraform plan

apply:
	@echo "🚀 Déploiement de l'infrastructure..."
	/opt/homebrew/bin/terraform apply -auto-approve
	@echo ""
	@echo "✅ Déploiement terminé !"
	@echo ""
	@make outputs

outputs:
	@echo "📊 Outputs du déploiement:"
	@echo ""
	@/opt/homebrew/bin/terraform output
	@echo ""
	@echo "🌐 URLs d'accès rapide:"
	@/opt/homebrew/bin/terraform output -json quick_access_urls | jq -r '.[]'

test:
	@echo "🧪 Tests des services déployés..."
	@echo ""
	@echo "1️⃣  Containers actifs:"
	@docker ps --filter label=managed_by=terraform --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "2️⃣  Réseau:"
	@docker network ls --filter label=managed_by=terraform --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
	@echo ""
	@echo "3️⃣  Volumes:"
	@docker volume ls --filter label=managed_by=terraform --format "table {{.Name}}\t{{.Driver}}"
	@echo ""
	@echo "4️⃣  Test HTTP des services publics:"
	@/opt/homebrew/bin/terraform output -json service_ports_mapping | jq -r 'to_entries[] | "curl -s -o /dev/null -w \"[\(.key)] HTTP \(.value): %{http_code}\\n\" http://localhost:\(.value)"' | while read cmd; do eval $$cmd || echo "Service inaccessible"; done
	@echo ""

destroy:
	@echo "🗑️  Destruction de l'infrastructure..."
	/opt/homebrew/bin/terraform destroy -auto-approve
	@echo "✅ Infrastructure détruite"

clean: destroy
	@echo "🧹 Nettoyage des fichiers Terraform..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	@echo "✅ Nettoyage terminé"

all: init validate fmt apply test
	@echo ""
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║         🎉 Déploiement complet réussi ! 🎉                ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
