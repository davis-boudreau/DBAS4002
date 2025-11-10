include .env
export $(shell sed 's/=.*//' .env)

.PHONY: up down logs ps psql seed backup restore clean status

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

ps:
	docker compose ps

status:
	docker compose ps && echo && docker compose logs --tail=20 db

psql:
	docker compose exec db psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

seed:
	# Re-run lab scripts (idempotent where possible)
	docker compose exec -T db psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /docker-entrypoint-initdb.d/03_demo_tx.sql

backup:
	mkdir -p $(BACKUP_DIR)
	docker compose exec -T db pg_dump -U $(POSTGRES_USER) -d $(POSTGRES_DB) > $(BACKUP_DIR)/txlab_dump.sql
	@echo "Backup written to $(BACKUP_DIR)/txlab_dump.sql"

restore:
	test -f $(BACKUP_DIR)/txlab_dump.sql
	docker compose exec -T db psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) < $(BACKUP_DIR)/txlab_dump.sql

clean:
	docker compose down -v --remove-orphans