
COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env


up:
	@echo "DOCKER UP"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)  up --build -d

down:
	@echo "DOCKER DOWN"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)  down
ps:
	@echo "DOCKER PS"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)  ps
all:

exec:
	@echo "DOCKER EXEC"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) exec nginx sh

re:

clean:

fclean:
 