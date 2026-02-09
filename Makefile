TERRAFORM_DIR = terraform
ANSIBLE_DIR = ansible

init: 
	@echo "Initialisation de Terraform..."
	cd $(TERRAFORM_DIR) && terraform init

validate-tf: 
	@echo "Validation Terraform..."
	cd $(TERRAFORM_DIR) && terraform validate
	cd $(TERRAFORM_DIR) && terraform fmt -check

plan: init
	@echo "Création du plan Terraform..."
	cd $(TERRAFORM_DIR) && terraform plan -out=tfplan

apply: plan 
	@echo "Application de la configuration..."
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve tfplan
	@echo ""
	@echo "Outputs:"
	cd $(TERRAFORM_DIR) && terraform output

validate:
	@echo "Attente du démarrage du container..."
	@sleep 5
	@echo "Validation Ansible..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.ini validate.yml

validate-verbose:
	@echo "Attente du démarrage du container..."
	@sleep 5
	@echo "Validation Ansible (verbose)..."
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventory.ini validate.yml -v

test: 
	@echo "Tests manuels..."
	@echo ""
	@echo "1 Test HTTP:"
	@curl -s -o /dev/null -w "   Status HTTP: %{http_code}\n" http://localhost:8080 || echo "   Service inaccessible"
	@echo ""
	@echo "2 Container:"
	@docker ps --filter name=app-nginx --format "   {{.Names}}: {{.Status}}"
	@echo ""
	@echo "3 Réseau:"
	@docker network inspect app-network --format "   {{.Name}}: {{len .Containers}} container(s)" 2>/dev/null || echo "   Réseau non trouvé"
	@echo ""
	@echo "4 Volume:"
	@docker volume inspect app-data --format "   {{.Name}}: {{.Mountpoint}}" 2>/dev/null || echo "   Volume non trouvé"

outputs: 
	@cd $(TERRAFORM_DIR) && terraform output

destroy:
	@echo "Destruction de l'infrastructure..."
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve
	@echo "Infrastructure détruite"

clean: destroy 
	@echo "Nettoyage des fichiers Terraform..."
	rm -rf $(TERRAFORM_DIR)/.terraform
	rm -f $(TERRAFORM_DIR)/.terraform.lock.hcl
	rm -f $(TERRAFORM_DIR)/tfplan
	rm -f $(TERRAFORM_DIR)/terraform.tfstate*
	@echo "Nettoyage terminé"

all: apply validate test ## Workflow complet (apply + validate + test)
	@echo ""
	@echo "Déploiement complet terminé avec succès!"
	@echo "Application accessible sur: http://localhost:8080"

logs: 
	@docker logs app-nginx

inspect: 
	@docker inspect app-nginx | jq '.[] | {Name, State, RestartPolicy: .HostConfig.RestartPolicy, Ports: .NetworkSettings.Ports}'

stats: 
	@docker stats app-nginx --no-stream