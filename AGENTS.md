# Repository Guidelines

## Project Structure & Module Organization
- `Dockerfile` builds the httpd image from `kernel528/alpine`.
- `httpd-foreground` is the container entrypoint script.
- `htdocs/` contains default web assets (optional runtime bind mount target).
- `README.md` documents usage; `VERSION.md` tracks releases.
- CI/CD is configured in `.drone.yml`.

## Build, Test, and Development Commands
- Build locally:
  ```sh
  docker build -t kernel528/httpd:2.4.68-3.24.1 -f Dockerfile .
  ```
- Run a container:
  ```sh
  docker run -dit --rm --name httpd --hostname httpd -p 80:80 kernel528/httpd:2.4.68-3.24.1
  ```
- Verify version:
  ```sh
  docker exec -it httpd httpd -v
  ```

## Coding Style & Naming Conventions
- Keep Dockerfile updates aligned with upstream `docker-library/httpd` conventions.
- Prefer explicit image tags in docs and examples.
- Keep version strings consistent across `Dockerfile`, `README.md`, `VERSION.md`, and `.drone.yml`.

## Testing Guidelines
- No automated tests; run `httpd -v` in a container after changes.
- If adjusting config files, confirm the server starts and serves `htdocs/`.

## Commit & Pull Request Guidelines
- Commit messages are concise and descriptive (e.g., “Updated base image to kernel528/alpine:3.24.1.”).
- Branch flow: version branch → `2.4` → `main`, then tag from `main`.
- PRs should update `VERSION.md`, `README.md`, and `.drone.yml` when tags change.

## Security & Configuration Tips
- Verify GPG key import remains valid for new httpd releases.
- Keep `httpd-foreground` executable and minimal.
