.PHONY: help up down restart logs ps clean clean-docker dev-up dev-down build force-recreate n8n-export n8n-import

# Define docker-compose commands
DC = docker compose

# Colors for terminal output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Include environment variables from .env
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# ------------------------------------------------------------------
# 📚 Help: List all available commands
# ------------------------------------------------------------------
help:
	@echo "🚀 ${GREEN}Available Commands:${NC}"
	@echo "------------------------------------------"
	@echo "Development Commands:"
	@echo "  ${YELLOW}make dev-up${NC}         - Start development environment"
	@echo "  ${YELLOW}make dev-down${NC}       - Stop development environment"
	@echo ""
	@echo "Build Commands:"
	@echo "  ${YELLOW}make build${NC}          - Build all images"
	@echo "  ${YELLOW}make force-recreate${NC} - Force rebuild everything"
	@echo ""
	@echo "Database Commands:"
	@echo "  ${YELLOW}make db-backup${NC}      - Backup database"
	@echo "  ${YELLOW}make db-restore${NC}     - Restore database from backup"
	@echo ""
	@echo "Container Management:"
	@echo "  ${YELLOW}make up${NC}             - Start all containers"
	@echo "  ${YELLOW}make down${NC}           - Stop all containers"
	@echo "  ${YELLOW}make restart${NC}        - Restart all containers"
	@echo "  ${YELLOW}make logs${NC}           - View logs"
	@echo "  ${YELLOW}make ps${NC}             - List running containers"
	@echo "  ${YELLOW}make clean${NC}          - Clean all data"
	@echo ""
	@echo "N8n Management:"
	@echo "  ${YELLOW}make n8n-export${NC}     - Export n8n workflows"
	@echo "  ${YELLOW}make n8n-import${NC}     - Import n8n workflows"
	@echo "------------------------------------------"

# ------------------------------------------------------------------
# 🚀 Development Environment
# ------------------------------------------------------------------
dev-up:
	@echo "🚀 Starting development environment..."
	@$(DC) up -d
	@echo "✅ Development environment is ready!"
	@echo ""
	@echo "📝 Services:"
	@echo ""
	@echo "   🗄️   PostgreSQL: localhost:${POSTGRES_PORT} (User: ${POSTGRES_USER}, DB: ${POSTGRES_DB})"
	@echo "   📟️  N8n: http://localhost:${N8N_PORT}/ or http://${N8N_HOST}:${N8N_PORT}/"
	@echo "   📟️  pgAdmin: http://localhost:5050/ or http://${N8N_HOST}:5050/"
	@echo ""
	@echo "📝 Available Routes:"
	@echo "   N8n:"
	@echo "   - Dashboard: http://localhost:${N8N_PORT}/ or http://${N8N_HOST}:${N8N_PORT}/"
	@echo "   - Setup: http://localhost:${N8N_PORT}/setup or http://${N8N_HOST}:${N8N_PORT}/setup"
	@echo "   - Workflows: http://localhost:${N8N_PORT}/workflows or http://${N8N_HOST}:${N8N_PORT}/workflows"
	@echo ""
	@echo "   PostgreSQL:"
	@echo "   - Connection String: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PORT}/${POSTGRES_DB}"

dev-down:
	@echo "🛑 Stopping development environment..."
	@$(DC) down
	@echo "✅ Development environment stopped."

# ------------------------------------------------------------------
# 🏗️ Build Commands
# ------------------------------------------------------------------
build:
	@echo "🏗️  Building all images..."
	@$(DC) build --no-cache
	@echo "✅ Build complete!"

force-recreate:
	@echo "${RED}🧨 Force recreating everything...${NC}"
	@echo "1️⃣  Stopping all containers..."
	@$(DC) down --remove-orphans || true
	@echo "2️⃣  Removing all project volumes..."
	@docker volume rm -f "$${PROJECT_NAME}_postgres_data" "$${PROJECT_NAME}_n8n_data" "$${PROJECT_NAME}_pgadmin_data" 2>/dev/null || true
	@echo "3️⃣  Removing all project networks..."
	@docker network rm "$${PROJECT_NAME}_network" 2>/dev/null || true
	@echo "4️⃣  Removing all project images..."
	@docker images | grep "$${PROJECT_NAME}" | awk '{print $$3}' | xargs -r docker rmi 2>/dev/null || true
	@echo "5️⃣  Cleaning local directories..."
	@rm -rf core/n8n/postgres/data/* core/n8n/data/* .pytest_cache **/__pycache__ **/*.pyc
	@echo "6️⃣  Recreating necessary directories..."
	@mkdir -p core/n8n/postgres/data core/n8n/data core/n8n/files/workflows
	@chmod 777 core/n8n/postgres/data
	@echo "7️⃣  Building images..."
	@$(MAKE) build
	@echo "8️⃣  Starting services..."
	@$(DC) up -d --force-recreate
	@echo "${GREEN}✨ Force recreate complete!${NC}"
	@$(DC) logs -f

# ------------------------------------------------------------------
# 🐳 Container Management
# ------------------------------------------------------------------
up:
	@echo "🚀 Starting containers..."
	@$(DC) up -d
	@echo "✅ Containers are up!"

down:
	@echo "🛑 Stopping containers..."
	@$(DC) down
	@echo "✅ Containers stopped."

restart: down up

logs:
	@$(DC) logs -f

ps:
	@$(DC) ps


# ------------------------------------------------------------------
# 🔄 N8n Workflow Management
# ------------------------------------------------------------------
n8n-export:
	@echo "🔄 Exporting n8n workflows..."
	@mkdir -p ./core/n8n/files/workflows
	@$(DC) exec n8n mkdir -p /home/node/files/workflows
	@$(DC) exec n8n n8n export:workflow --all --output=/home/node/files/workflows/ --separate || echo "ℹ️ No workflows to export or n8n not ready yet."
	@echo "✅ Completed workflows export process."

n8n-import:
	@echo "🔄 Importing n8n workflows..."
	@if [ -d "./core/n8n/files/workflows" ] && [ "$$(ls -A ./core/n8n/files/workflows/*.json 2>/dev/null)" ]; then \
		echo "📁 Found workflow files in ./core/n8n/files/workflows/"; \
		$(DC) exec n8n mkdir -p /home/node/files/workflows; \
		echo "🔄 Importing workflows..."; \
		$(DC) exec n8n n8n import:workflow --separate --input=/home/node/files/workflows/; \
	else \
		echo "❌ No workflow files found in ./core/n8n/files/workflows/"; \
	fi

# ------------------------------------------------------------------
# 🧹 Cleanup
# ------------------------------------------------------------------
clean:
	@echo "🧹 Cleaning all data for project: $${PROJECT_NAME:-wattabase}..."
	@$(DC) down --rmi all --remove-orphans
	@rm -rf core/n8n/postgres/data/* core/n8n/data/*
	@echo "📦 Removing Docker volumes..."
	@docker volume rm -f "$${PROJECT_NAME}_postgres_data" "$${PROJECT_NAME}_n8n_data" 2>/dev/null || true
	@mkdir -p core/n8n/postgres/data core/n8n/data
	@chmod 777 core/n8n/postgres/data
	@echo "✨ Clean complete!"

# ------------------------------------------------------------------
# 👥 User Management
# ------------------------------------------------------------------
n8n-reset-users:
	@echo "🔄 Resetting n8n user management..."
	@$(DC) exec n8n n8n user-management:reset
	@echo "✅ User management reset complete. You can now create the first owner account at http://localhost:${N8N_PORT}"
