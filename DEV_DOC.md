# Developer Documentation

This document describes how to set up, build, run, and manage the
**Inception** project from a developer's point of view.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setting Up the Environment From Scratch](#setting-up-the-environment-from-scratch)
- [Building and Launching the Project](#building-and-launching-the-project)
- [Managing Containers and Volumes](#managing-containers-and-volumes)
- [Data Storage and Persistence](#data-storage-and-persistence)
- [Useful Docker Compose Commands](#useful-docker-compose-commands)

## Prerequisites

Make sure the following are installed on the host (or VM):

- Linux (the Makefile uses `sudo mkdir`, so a Unix-like system is assumed)
- [Docker Engine](https://docs.docker.com/engine/install/)
- [Docker Compose v2](https://docs.docker.com/compose/install/) (the `docker compose` command, used by the Makefile)
- `make`
- `sudo` rights (used by `make init`/`make fclean` to create/remove the data directories)
- `git`

## Setting Up the Environment From Scratch

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd <repo-name>
   ```

2. **Create the configuration file**

   The stack is configured through `srcs/.env`, which is **not** versioned
   (it is git-ignored because it holds secrets). Create it from scratch (or
   from a `.env.example` if one is provided) with at least:

   ```dotenv
   DOMAIN_NAME=masase.42.fr

   MYSQL_DATABASE=wordpress
   MYSQL_USER=wp_user
   MYSQL_PASSWORD=change_me
   MYSQL_ROOT_PASSWORD=change_me_too

   WP_ADMIN_USER=admin
   WP_ADMIN_PASSWORD=change_me_as_well
   WP_ADMIN_EMAIL=admin@example.com
   WP_TITLE=Inception
   ```

   > Adjust these keys to exactly match what `srcs/docker-compose.yml` and
   > the container entrypoint scripts actually expect.

3. **(If applicable) Set up Docker secrets**

   If sensitive values (passwords) are passed as Docker secrets rather than
   plain environment variables, create one file per secret under a
   `secrets/` directory (e.g. `secrets/db_password.txt`,
   `secrets/db_root_password.txt`), each containing only the secret value
   with no extra whitespace, and reference them in
   `srcs/docker-compose.yml` under each service's `secrets:` key.

4. **Map the domain name locally**

   Add an entry to `/etc/hosts` so the configured domain resolves to your
   machine:

   ```
   127.0.0.1   masase.42.fr
   ```

5. **Create the persistent data directories**

   ```bash
   make init
   ```

   This runs:

   ```make
   init:
       @sudo mkdir -p /home/masase/data/mariadb
       @sudo mkdir -p /home/masase/data/wordpress
   ```

   These two directories are where MariaDB's database files and
   WordPress's files will live on the host (see
   [Data Storage and Persistence](#data-storage-and-persistence)).

## Building and Launching the Project

Everything is driven by the root `Makefile`, which wraps `docker compose`
calls using:

```make
COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE     = srcs/.env
```

| Make target | Underlying command | Purpose |
|---|---|---|
| `make init` | `mkdir -p` for both data dirs | Prepares host directories for bind mounts |
| `make up` | `docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build -d` | Builds all images and starts every service in the background |
| `make all` | `init` then `up` | One-shot setup + launch — the standard entrypoint |
| `make down` | `docker compose ... down` | Stops and removes containers (keeps images/volumes) |
| `make ps` | `docker compose ... ps` | Shows container status |
| `make exec` | `docker compose ... exec nginx sh` | Opens an interactive shell inside the `nginx` container |
| `make clean` | `down` then `docker compose ... down --rmi all --volumes --remove-orphans` | Stops everything and removes containers, images, volumes, orphans |
| `make fclean` | `clean` then `sudo rm -rf` on both data dirs | Full reset: also wipes all persisted data on disk |
| `make re` | *(currently empty)* | Intended as a full rebuild shortcut — consider implementing it as `re: fclean all` |

Standard first run:

```bash
make all
```

Rebuilding after changing a `Dockerfile` or `docker-compose.yml`:

```bash
make down
make up        # --build flag in the Makefile rebuilds changed images
```

## Managing Containers and Volumes

Quick shell into a container (NGINX is pre-wired via `make exec`; for the
others, call `docker compose` directly with the same flags as the
Makefile):

```bash
# Shell into nginx (via Makefile)
make exec

# Shell into wordpress or mariadb
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec wordpress sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec mariadb sh
```

Inspecting logs for a specific service:

```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs -f wordpress
```

Listing and inspecting the network and volumes Docker Compose created:

```bash
docker network ls
docker network inspect <project>_inception

docker volume ls
docker volume inspect <volume_name>
```

Restarting a single service without touching the others:

```bash
docker compose -f srcs/docker-compose.yml --env-file srcs/.env restart mariadb
```

## Data Storage and Persistence

Persistent data lives on the **host filesystem**, via bind mounts created
by `make init`:

| Host path | Mounted into | Contains |
|---|---|---|
| `/home/masase/data/mariadb` | `mariadb` container | The actual MariaDB database files (tables, content, users) |
| `/home/masase/data/wordpress` | `wordpress` container | WordPress core files, themes, plugins, uploaded media |

Because these are bind mounts (not container-internal storage), the data
**survives**:

- `make down` (containers removed, host data untouched)
- `make clean` (containers/images/Docker-managed volumes removed, host data untouched)
- Image rebuilds (`make up` after a `Dockerfile` change)

The data is only destroyed by `make fclean`, which explicitly runs
`sudo rm -rf` on both directories — use it deliberately when you want a
completely fresh install (e.g. for testing the full setup from zero).

To verify what's currently stored on disk at any time:

```bash
ls -la /home/masase/data/mariadb
ls -la /home/masase/data/wordpress
```

## Useful Docker Compose Commands

For reference, here are the raw commands the Makefile wraps, useful when
debugging something the Makefile doesn't expose directly:

```bash
# Build only, without starting
docker compose -f srcs/docker-compose.yml --env-file srcs/.env build

# Start in the foreground (see logs live, Ctrl+C to stop)
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up --build

# Validate the compose file syntax / resolved config
docker compose -f srcs/docker-compose.yml --env-file srcs/.env config

# Force-recreate a single service
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --force-recreate wordpress
```