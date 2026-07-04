
COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env

all: init up

init:
	@echo "Creating persistant volume"
	@sudo mkdir -p /home/masase/data/mariadb
	@sudo mkdir -p /home/masase/data/wordpress
	@ls /home/masase/data/

up:
	@echo "DOCKER UP"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)  up --build -d

down:
	@echo "DOCKER DOWN"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)  down
ps:
	@echo "DOCKER PS"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)  ps

exec:
	@echo "DOCKER EXEC"
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) exec nginx sh

re: fclean all

clean: down
	@echo "docker down  + clean volumes and images "
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down --rmi all --volumes --remove-orphans

fclean: clean
	@echo "Removing all data...$(RESET)"
	@sudo rm -rf /home/masase/data/mariadb
	@sudo rm -rf /home/masase/data/wordpress


 