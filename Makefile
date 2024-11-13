.PHONY: up down dbt-build dbt-compile

up:
	docker compose up -d

down:
	docker compose down

dbt-build:
	docker compose run dbt build

dbt-compile:
	docker compose run dbt compile

dbt-test:
	docker compose run dbt test
