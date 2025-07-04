# Makefile para build dos projetos Spring Boot
.PHONY: help build build-coroutine build-virtual-thread run stop clean logs setup-gatling load-test monitor-resources

# Variáveis
DOCKER_COMPOSE = docker compose -f docker-compose.yml
DOCKERFILE = Dockerfile

# Comando padrão
help:
	@echo "Comandos disponíveis:"
	@echo "  build                - Builda ambos os projetos"
	@echo "  build-coroutine      - Builda apenas o projeto with-coroutine"
	@echo "  build-virtual-thread - Builda apenas o projeto with-virtual-thread"
	@echo "  run                  - Executa todos os serviços"
	@echo "  stop                 - Para todos os serviços"
	@echo "  clean                - Remove containers"
	@echo "  logs                 - Mostra logs dos serviços"
	@echo "  logs-coroutine       - Mostra logs do projeto coroutine"
	@echo "  logs-virtual-thread  - Mostra logs do projeto virtual-thread"
	@echo "  load-test            - Executa teste de carga com 50k requests para cada projeto"
	@echo "  monitor-resources    - Monitora uso de CPU e memória dos containers"

# Build de ambos os projetos
build: build-coroutine build-virtual-thread

# Build do projeto with-coroutine
build-coroutine:
	@echo "🔨 Buildando projeto with-coroutine..."
	docker build -f $(DOCKERFILE) -t spring-coroutine:latest ./with-coroutine

# Build do projeto with-virtual-thread
build-virtual-thread:
	@echo "🔨 Buildando projeto with-virtual-thread..."
	docker build -f $(DOCKERFILE) -t spring-virtual-thread:latest ./with-virtual-thread

# Executar todos os serviços
run:
	@echo "🚀 Iniciando todos os serviços..."
	$(DOCKER_COMPOSE) up -d

# Parar todos os serviços
stop:
	@echo "🛑 Parando todos os serviços..."
	$(DOCKER_COMPOSE) down

# Limpar containers
clean:
	@echo "🧹 Limpando containers..."
	$(DOCKER_COMPOSE) down -v --rm all
	docker system prune -f

# Mostrar logs de todos os serviços
logs:
	$(DOCKER_COMPOSE) logs -f

# Mostrar logs do projeto coroutine
logs-coroutine:
	$(DOCKER_COMPOSE) logs -f app-coroutine

# Mostrar logs do projeto virtual-thread
logs-virtual-thread:
	$(DOCKER_COMPOSE) logs -f app-virtual-thread

# Rebuild e restart (útil para desenvolvimento)
rebuild: clean build run

# Verificar status dos serviços
status:
	$(DOCKER_COMPOSE) ps

# Executar apenas databases
run-db:
	@echo "🗄️ Iniciando apenas os bancos de dados..."
	$(DOCKER_COMPOSE) up -d postgres-coroutine postgres-virtual-thread

# Executar apenas aplicações (assumindo que DBs já estão rodando)
run-apps:
	@echo "🚀 Iniciando apenas as aplicações..."
	$(DOCKER_COMPOSE) up -d app-coroutine app-virtual-thread

# Executar teste de carga com dashboard em tempo real
load-test:
	@echo "🔥 Iniciando teste de carga com dashboard k6..."
	@echo "🌐 Dashboard disponível em: http://localhost:5665"
	@echo "⚡ Executando teste de carga nos dois serviços..."
	@echo "📊 Aguarde... O teste levará alguns minutos para ser concluído."
	$(DOCKER_COMPOSE) --profile load-test-dashboard up --abort-on-container-exit k6-dashboard

# Gerar relatório de resultados
report-results:
	@echo "📋 Gerando relatório de resultados..."
	@if [ -f k6/results/results.json ]; then \
		echo "📊 Últimos resultados de teste:"; \
		cat k6/results/results.json | tail -n 20; \
	else \
		echo "❌ Nenhum resultado encontrado. Execute um teste primeiro."; \
	fi

# Monitorar uso de recursos
monitor-resources:
	@echo "📊 Monitorando uso de recursos dos containers..."
	@echo "Pressione Ctrl+C para sair"
	docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}" \
		app-coroutine app-virtual-thread postgres-coroutine postgres-virtual-thread