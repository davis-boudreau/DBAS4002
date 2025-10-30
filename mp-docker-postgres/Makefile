POSTGRES_USER := $(shell grep POSTGRES_USER .env | cut -d '=' -f2 | tr -d '"')
POSTGRES_DB   := $(shell grep POSTGRES_DB .env | cut -d '=' -f2 | tr -d '"')
DB_CONTAINER  := mp_db

ifeq ($(OS),Windows_NT)
  SHELL := powershell.exe
  .SHELLFLAGS := -NoProfile -Command
endif

up:
	docker compose up -d
	@echo "✅ Containers starting..."

down:
	docker compose down
	@echo "🧹 Containers stopped (volumes preserved)."

reset:
	docker compose down -v
	docker compose up -d --build
	@echo "♻️  Environment reset with clean DB."

psql:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

run-queries:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/10_queries/mp1a_queries.sql

run-aggregates:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/20_aggregates/week5_aggregates.sql

run-tests:
	docker exec -it $(DB_CONTAINER) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /sql/99_tests/mp1b_tests.sql

clean:
	docker system prune -f
	@echo "🧽 Docker system cleaned."