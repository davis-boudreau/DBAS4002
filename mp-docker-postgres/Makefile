DB=mp_db
PSQL=docker exec -it $(DB) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

up:
	docker compose up -d

down:
	docker compose down

reset:
	docker compose down -v
	docker compose up -d

psql:
	$(PSQL)

run-queries:
	$(PSQL) -f /sql/10_queries/mp1a_queries.sql

run-aggregates:
	$(PSQL) -f /sql/20_aggregates/week5_aggregates.sql

run-tests:
	$(PSQL) -f /sql/99_tests/mp1b_tests.sql

