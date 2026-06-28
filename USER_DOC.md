# User Documentation

This document explains, in simple terms, how to use the **Inception** stack
as an end user or as the administrator responsible for keeping it running.

## Table of Contents

- [What This Stack Provides](#what-this-stack-provides)
- [Starting and Stopping the Project](#starting-and-stopping-the-project)
- [Accessing the Website and the Admin Panel](#accessing-the-website-and-the-admin-panel)
- [Locating and Managing Credentials](#locating-and-managing-credentials)
- [Checking That Everything Is Running Correctly](#checking-that-everything-is-running-correctly)
- [Troubleshooting](#troubleshooting)

## What This Stack Provides

This project runs a small, self-contained website infrastructure made of
three services, each in its own Docker container:

| Service     | What it does                                                        |
|-------------|------------------------------------------------------------------------|
| **NGINX**   | The front door of the site. It receives all traffic from the browser (over HTTPS) and forwards requests to WordPress. It is the only service reachable from outside. |
| **WordPress** | The actual website / content management system. This is what visitors see and what the administrator edits content through. |
| **MariaDB** | The database that stores everything WordPress needs: pages, posts, users, settings. It is not reachable from outside the stack. |

In short: you visit one address in your browser, NGINX answers and shows you
the WordPress site, and WordPress talks to MariaDB behind the scenes to
fetch the content.

## Starting and Stopping the Project

All operations are done through the `Makefile` at the root of the
repository — no need to type Docker commands directly.

| Action | Command | What happens |
|---|---|---|
| First-time setup + start | `make all` | Creates the data folders on disk, then builds and starts all containers |
| Start (already set up) | `make up` | Builds (if needed) and starts all containers in the background |
| Check status | `make ps` | Lists the containers and their state (running / stopped / restarting) |
| Stop | `make down` | Stops and removes the containers, but **keeps your data** |
| Stop + remove images/volumes | `make clean` | Stops everything and removes containers, images and Docker volumes |
| Stop + remove images/volumes + delete all website/database data | `make fclean` | Same as `clean`, plus permanently deletes the data folders on disk |

> **Important:** `make down` and `make clean` do **not** delete your
> website's content — only `make fclean` does. Use it only when you really
> want to start over from a blank site.

A typical day-to-day workflow looks like this:

```bash
make up      # start the site
# ... use the site ...
make down    # stop it when you're done
```

## Accessing the Website and the Admin Panel

Once the stack is running (check with `make ps`), open a browser and go to:

- **Public website:** `https://<your-domain>` (e.g. `https://masase.42.fr`)
- **Admin panel (WordPress dashboard):** `https://<your-domain>/wp-admin`

Since the site uses a self-signed TLS certificate, your browser will show a
security warning ("Your connection is not private" or similar) the first
time you visit. This is expected for a local/student project — you can
proceed past the warning (sometimes labeled "Advanced" → "Proceed anyway").

To log into the admin panel, use the WordPress administrator account
described in the next section.

## Locating and Managing Credentials

All credentials used by the stack (database passwords, WordPress admin
account, etc.) are defined in a single configuration file:

```
srcs/.env
```

This file is **not** committed to the Git repository (it is excluded via
`.gitignore`) because it contains sensitive information. It typically
contains values such as:

| Variable | What it controls |
|---|---|
| `WP_ADMIN_USER` | Username to log into the WordPress dashboard |
| `WP_ADMIN_PASSWORD` | Password for that account |
| `WP_ADMIN_EMAIL` | Admin account email |
| `MYSQL_USER` / `MYSQL_PASSWORD` | Database account used by WordPress |
| `MYSQL_ROOT_PASSWORD` | Database administrator password |
| `DOMAIN_NAME` | The address you type in your browser |

**To change a credential** (e.g. the admin password):

1. Edit the corresponding value in `srcs/.env`.
2. Restart the stack so the change takes effect:
   ```bash
   make down
   make up
   ```

## Checking That Everything Is Running Correctly

1. **Check the containers are up:**
   ```bash
   make ps
   ```
   All three services (`nginx`, `wordpress`, `mariadb`) should be listed
   with a status of `Up` (or `running` / `healthy`).

2. **Check the website responds:**
   Open `https://<your-domain>` in a browser. You should see the WordPress
   site load without a connection error (the TLS warning mentioned above is
   normal and not a sign of failure).

3. **Check the admin panel:**
   Log into `https://<your-domain>/wp-admin` with the admin credentials from
   `srcs/.env`. If you can log in and see the dashboard, WordPress is
   correctly talking to the database.

4. **If something looks wrong**, see the [Troubleshooting](#troubleshooting)
   section below.

## Troubleshooting

| Symptom | Likely cause | What to try |
|---|---|---|
| Browser says "can't connect" / times out | Containers not running | Run `make ps`; if nothing is listed, run `make up` |
| One container keeps restarting | Misconfiguration or bad credentials | Check its logs: `docker compose -f srcs/docker-compose.yml --env-file srcs/.env logs <service>` |
| Site loads but shows a database error | MariaDB not ready yet or wrong credentials in `.env` | Wait a few seconds and reload; verify `MYSQL_*` values match what WordPress expects |
| Can't log into `/wp-admin` | Wrong credentials | Double-check `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD` in `srcs/.env` |
| Browser shows a certificate warning | Self-signed TLS certificate | Expected behavior — proceed past the warning |
| Need a clean restart | Corrupted state / want to reset content | `make fclean` then `make all` (this **erases all website data**) |

For anything not covered here, see `DEV_DOC.md` for lower-level
container/volume inspection commands.