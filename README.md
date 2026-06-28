*This project has been created as part of the 42 curriculum by masase.*

# Inception

> A small system infrastructure built entirely with Docker: NGINX, WordPress
> (php-fpm) and MariaDB, each running in its own container, wired together
> with a custom Docker network and persistent volumes.

## Table of Contents

- [Description](#description)
- [Instructions](#instructions)
  - [Makefile Commands](#makefile-commands)
  - [Accessing the Website](#accessing-the-website)
- [Project Description](#project-description)
  - [Why Docker](#why-docker)
  - [Sources Used](#sources-used)
  - [Design Choices](#design-choices)
  - [Virtual Machines vs Docker](#virtual-machines-vs-docker)
  - [Secrets vs Environment Variables](#secrets-vs-environment-variables)
  - [Docker Network vs Host Network](#docker-network-vs-host-network)
  - [Docker Volumes vs Bind Mounts](#docker-volumes-vs-bind-mounts)
- [Resources](#resources)

## Description

**Inception** is a system administration project whose goal is to set up a
small, self-contained web infrastructure using **Docker** and
**Docker Compose**, following an "each service in its own container"
philosophy rather than relying on a single monolithic image.

The final stack serves a working **WordPress** website, backed by a
**MariaDB** database, exposed to the outside world exclusively through an
**NGINX** reverse proxy configured to accept only **TLSv1.2/TLSv1.3**
traffic on port 443. Every image is built from scratch from a minimal base
image (no pre-built service images pulled from Docker Hub), data is kept on
the host through Docker volumes, and containers automatically restart in
case of a crash.

The broader goal of the project is to understand, in a hands-on way, how a
modern containerized infrastructure is designed: image building, networking,
persistent storage, secret management, and service orchestration.

## Instructions

### Makefile Commands

| Command       | Description                                                              |
|---------------|---------------------------------------------------------------------------|
| `make init`   | Creates the persistent data directories on the host (`/home/masase/data/mariadb`, `/home/masase/data/wordpress`) |
| `make up`     | Builds the images (if needed) and starts the full stack in detached mode  |
| `make down`   | Stops and removes the containers                                          |
| `make ps`     | Shows the status of the running containers                                |
| `make exec`   | Opens a shell inside the `nginx` container                                |
| `make clean`  | Stops the stack and removes containers, images, volumes and orphans       |
| `make fclean` | Runs `clean` then deletes all host data directories                       |
| `make all`    | Runs `init` then `up` — the standard way to (re)launch the project        |
| `make re`     | Currently empty — intended for a full rebuild; consider defining it as `fclean all` |

### Accessing the Website

Once `make all` has finished and all containers report `healthy`/`running`
(check with `make ps`), open:

```
https://<DOMAIN_NAME>
```

in a browser (e.g. `https://masase.42.fr`). Since the certificate is
self-signed, the browser will show a security warning — this is expected.

## Project Description

### Why Docker

Docker lets each piece of the stack (web server, application, database) run
in an isolated, reproducible environment built from a minimal, version-pinned
base image. This avoids "works on my machine" issues, keeps the host system
clean, allows independent scaling/restarting of each service, and makes the
whole infrastructure reproducible from source (the `Dockerfile`s) rather than
from a pre-built, opaque image.

### Sources Used

Each image (`nginx`, `wordpress`, `mariadb`) is built from a `Dockerfile`
based on a minimal Debian/Alpine base image, with the actual service
(NGINX, php-fpm + WordPress, MariaDB) installed and configured from the
distribution's official package repositories — no service-specific image is
pulled directly from Docker Hub, per the project's constraints.

### Design Choices

- **One service per container**: NGINX, WordPress and MariaDB are fully
  separated, each with its own `Dockerfile` and configuration.
- **NGINX as the single entrypoint**: only NGINX is reachable from outside
  the Docker network, and only over TLS on port 443.
- **Custom bridge network**: all containers communicate over a dedicated
  Docker network (`inception`) instead of the host network, so they can
  resolve each other by container name (`wordpress`, `mariadb`) without
  exposing internal ports to the host.
- **Persistent volumes**: WordPress files and the MariaDB database are
  stored on bind-mounted host directories (`/home/masase/data/...`) so data
  survives container recreation.
- **`.env`-driven configuration**: domain name, credentials and other
  parameters are injected at build/run time via `srcs/.env`, keeping
  secrets out of the `Dockerfile`s and the images themselves.
- **Auto-restart policy**: every service is configured with a restart
  policy so it comes back up automatically after a crash.

### Virtual Machines vs Docker

| | Virtual Machines | Docker |
|---|---|---|
| Isolation level | Full hardware-level isolation, own kernel | Process-level isolation, shares host kernel |
| Resource usage | Heavy (full OS per VM) | Lightweight (no guest OS) |
| Startup time | Minutes | Seconds |
| Portability | Large images, less portable | Small images, highly portable |
| Use case | Strong isolation, different OS/kernel needs | Fast, reproducible app deployment |

### Secrets vs Environment Variables

| | Secrets | Environment Variables |
|---|---|---|
| Storage | Mounted as files, encrypted at rest (e.g. Docker Swarm secrets) | Stored in plaintext in `.env`/process environment |
| Visibility | Not visible in `docker inspect` or process listings | Visible via `docker inspect`, `/proc`, logs |
| Best for | Passwords, API keys, certificates | Non-sensitive config (ports, hostnames, feature flags) |
| Risk if leaked | Lower — access requires file-system access to the mount | Higher — can leak through logs, history, `inspect` |

### Docker Network vs Host Network

| | Docker (bridge) Network | Host Network |
|---|---|---|
| Isolation | Containers get their own virtual network, isolated from host | Container shares the host's network stack directly |
| Port handling | Explicit port mapping/exposure required | All host ports are directly accessible, no mapping |
| DNS resolution | Built-in service discovery by container name | No built-in discovery; relies on host networking |
| Security | Better isolation, smaller attack surface | Larger attack surface, no isolation from host |
| Use case here | Lets `nginx`, `wordpress`, `mariadb` talk to each other by name while staying isolated from the host | Not used in this project, since it would defeat container isolation |

### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|---|---|---|
| Managed by | Docker (stored under `/var/lib/docker/volumes`) | The user (any path on the host filesystem) |
| Path visibility | Abstracted, managed via `docker volume` commands | Explicit host path, fully visible/editable |
| Portability | Portable across hosts via Docker tooling | Tied to the specific host path |
| Use case here | Could be used for fully Docker-managed persistence | Used here to store WordPress files and the MariaDB database in a known, predictable host location (`/home/masase/data/...`), as required by the subject |

## Resources

**Classic references**

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/build/building/best-practices/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Docker Networking Overview](https://docs.docker.com/network/)
- [Docker Storage: Volumes vs Bind Mounts](https://docs.docker.com/storage/)

**Use of AI**

AI assistance (Claude, by Anthropic) was used in this project for:

- Drafting and structuring this `README.md` file from the project's
  Makefile and the 42 subject requirements.
- debugging

No AI tool was used to generate the Dockerfiles, configuration files, or
core infrastructure logic without review — all such files were written
and verified manually. *(Edit this paragraph to accurately reflect your
own usage before submitting.)*