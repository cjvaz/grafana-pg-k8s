# =============================================================================
# Grafana + PostgreSQL no Kubernetes com Kind
# =============================================================================

# Configurações
CLUSTER_NAME=grafana-local
POSTGRES_RELEASE=my-postgres
GRAFANA_RELEASE=my-grafana
NAMESPACE=default

# =============================================================================
# Setup e Preparação
# =============================================================================

.PHONY: setup
setup: mkdir-postgres install-helm-deps
	@echo "✅ Setup inicial concluído!"

.PHONY: mkdir-postgres
mkdir-postgres:
	@echo "📁 Criando diretórios necessários..."
	@mkdir -p kind-volumes/postgres
	@chmod 755 kind-volumes/postgres

.PHONY: install-helm-deps
install-helm-deps:
	@echo "📦 Instalando dependências do Helm..."
	@helm repo add bitnami https://charts.bitnami.com/bitnami
	@helm repo update

# =============================================================================
# Gerenciamento do Cluster
# =============================================================================

.PHONY: create-cluster
create-cluster:
	@echo "🚀 Criando cluster Kubernetes com Kind..."
	@kind create cluster --name $(CLUSTER_NAME) --config=kind-cluster.yaml
	@echo "✅ Cluster '$(CLUSTER_NAME)' criado com sucesso!"

.PHONY: cluster-info
cluster-info:
	@echo "ℹ️  Informações do cluster:"
	@kubectl cluster-info --context kind-$(CLUSTER_NAME)
	@echo "\n📊 Nodes:"
	@kubectl get nodes --context kind-$(CLUSTER_NAME)
	@echo "\n🏷️  Namespaces:"
	@kubectl get namespaces --context kind-$(CLUSTER_NAME)

# =============================================================================
# Instalação dos Serviços
# =============================================================================

.PHONY: apply-pvc
apply-pvc:
	@echo "💾 Aplicando PersistentVolumeClaim..."
	@kubectl apply -f pv-pvc-postgres.yaml --context kind-$(CLUSTER_NAME)

.PHONY: install-postgres
install-postgres:
	@echo "🐘 Instalando PostgreSQL..."
	@helm install $(POSTGRES_RELEASE) bitnami/postgresql -f postgres-values.yaml
	@echo "✅ PostgreSQL instalado com sucesso!"

.PHONY: install-grafana
install-grafana:
	@echo "📊 Instalando Grafana..."
	@helm install $(GRAFANA_RELEASE) bitnami/grafana -f grafana-values.yaml
	@echo "✅ Grafana instalado com sucesso!"

.PHONY: install-all
install-all: setup create-cluster apply-pvc install-postgres install-grafana
	@echo "🎉 Instalação completa concluída!"
	@echo "📝 Execute 'make status' para verificar o status dos serviços"

# =============================================================================
# Port Forward e Acesso
# =============================================================================

.PHONY: port-forward
port-forward:
	@echo "🌐 Iniciando port-forward para Grafana (http://localhost:3000)..."
	@kubectl port-forward svc/$(GRAFANA_RELEASE) 3000:3000 --context kind-$(CLUSTER_NAME)

.PHONY: port-forward-postgres
port-forward-postgres:
	@echo "🐘 Iniciando port-forward para PostgreSQL (localhost:5432)..."
	@kubectl port-forward svc/$(POSTGRES_RELEASE)-postgresql 5432:5432 --context kind-$(CLUSTER_NAME)

.PHONY: get-grafana-password
get-grafana-password:
	@echo "🔐 Senha do administrador do Grafana:"
	@kubectl get secret $(GRAFANA_RELEASE)-admin -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" --context kind-$(CLUSTER_NAME) | base64 --decode
	@echo ""

# =============================================================================
# Monitoramento e Status
# =============================================================================

.PHONY: status
status:
	@echo "📊 Status dos serviços:"
	@echo "\n🎯 Pods:"
	@kubectl get pods --context kind-$(CLUSTER_NAME)
	@echo "\n🌐 Services:"
	@kubectl get svc --context kind-$(CLUSTER_NAME)
	@echo "\n💾 PVCs:"
	@kubectl get pvc --context kind-$(CLUSTER_NAME)
	@echo "\n🔐 Secrets:"
	@kubectl get secrets --context kind-$(CLUSTER_NAME)

.PHONY: logs-grafana
logs-grafana:
	@echo "📋 Logs do Grafana:"
	@kubectl logs -l app.kubernetes.io/name=grafana --tail=50 --context kind-$(CLUSTER_NAME)

.PHONY: logs-postgres
logs-postgres:
	@echo "📋 Logs do PostgreSQL:"
	@kubectl logs -l app.kubernetes.io/name=postgresql --tail=50 --context kind-$(CLUSTER_NAME)

# =============================================================================
# Utilitários
# =============================================================================

.PHONY: restart-grafana
restart-grafana:
	@echo "🔄 Reiniciando Grafana..."
	@kubectl rollout restart deployment/$(GRAFANA_RELEASE) --context kind-$(CLUSTER_NAME)
	@kubectl rollout status deployment/$(GRAFANA_RELEASE) --context kind-$(CLUSTER_NAME)

.PHONY: restart-postgres
restart-postgres:
	@echo "🔄 Reiniciando PostgreSQL..."
	@kubectl rollout restart statefulset/$(POSTGRES_RELEASE)-postgresql --context kind-$(CLUSTER_NAME)
	@kubectl rollout status statefulset/$(POSTGRES_RELEASE)-postgresql --context kind-$(CLUSTER_NAME)

.PHONY: shell-postgres
shell-postgres:
	@echo "🐘 Conectando ao PostgreSQL..."
	@kubectl exec -it $(POSTGRES_RELEASE)-postgresql-0 --context kind-$(CLUSTER_NAME) -- psql -U grafana -d grafanadb

# =============================================================================
# Limpeza
# =============================================================================

.PHONY: uninstall-services
uninstall-services:
	@echo "🧹 Removendo serviços..."
	@helm uninstall $(POSTGRES_RELEASE) --namespace $(NAMESPACE) || true
	@helm uninstall $(GRAFANA_RELEASE) --namespace $(NAMESPACE) || true

.PHONY: destroy
destroy: uninstall-services
	@echo "💥 Destruindo cluster..."
	@kind delete cluster --name $(CLUSTER_NAME)
	@echo "✅ Cluster removido com sucesso!"

.PHONY: clean
clean:
	@echo "🧹 Limpando recursos locais..."
	@rm -rf kind-volumes/postgres/*
	@echo "✅ Limpeza concluída!"

# =============================================================================
# Ajuda
# =============================================================================

.PHONY: help
help:
	@echo "🚀 Grafana + PostgreSQL no Kubernetes com Kind"
	@echo "🎯 Cluster: $(CLUSTER_NAME) (context: kind-$(CLUSTER_NAME))"
	@echo ""
	@echo "📋 Comandos disponíveis:"
	@echo ""
	@echo "🛠️  Setup e Preparação:"
	@echo "  setup                 - Prepara o ambiente (cria diretórios, instala helm deps)"
	@echo "  create-cluster        - Cria o cluster Kubernetes com Kind"
	@echo "  install-all           - Instalação completa (setup + cluster + serviços)"
	@echo ""
	@echo "📦 Instalação Individual:"
	@echo "  apply-pvc            - Aplica PersistentVolumeClaim"
	@echo "  install-postgres     - Instala PostgreSQL"
	@echo "  install-grafana      - Instala Grafana"
	@echo ""
	@echo "🌐 Acesso aos Serviços:"
	@echo "  port-forward         - Port-forward para Grafana (porta 3000)"
	@echo "  port-forward-postgres - Port-forward para PostgreSQL (porta 5432)"
	@echo "  get-grafana-password - Exibe a senha do admin do Grafana"
	@echo ""
	@echo "📊 Monitoramento:"
	@echo "  status               - Mostra status de todos os recursos"
	@echo "  cluster-info         - Informações do cluster"
	@echo "  logs-grafana         - Logs do Grafana"
	@echo "  logs-postgres        - Logs do PostgreSQL"
	@echo ""
	@echo "🔧 Utilitários:"
	@echo "  restart-grafana      - Reinicia o Grafana"
	@echo "  restart-postgres     - Reinicia o PostgreSQL"
	@echo "  shell-postgres       - Conecta ao shell do PostgreSQL"
	@echo ""
	@echo "🧹 Limpeza:"
	@echo "  uninstall-services   - Remove apenas os serviços (mantém cluster)"
	@echo "  destroy              - Remove cluster e todos os recursos"
	@echo "  clean                - Limpa arquivos locais"
	@echo ""
	@echo "❓ Ajuda:"
	@echo "  help                 - Mostra esta ajuda"

.DEFAULT_GOAL := help

