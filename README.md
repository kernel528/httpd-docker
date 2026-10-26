[![Build Status](https://drone.kernelsanders.biz:8443/api/badges/kernel528/httpd-docker/status.svg)](https://drone.kernelsanders.biz:8443/kernel528/httpd-docker)
[![Latest Version](https://img.shields.io/github/v/tag/kernel528/httpd-docker)](https://github.com/kernel528/httpd-docker/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/kernel528/httpd)](https://hub.docker.com/r/kernel528/httpd)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/kernel528/httpd/2.4.69-3.24.3_3)](https://hub.docker.com/r/kernel528/httpd/2.4.69-3.24.3_3)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/kernel528/httpd?sort=semver)](https://hub.docker.com/r/kernel528/httpd)

# Base Httpd Docker repo

These images are based on the official httpd docker hub release. The source Dockerfile is used as a base.

## Overview
- Base image: `kernel528/alpine`
- httpd version line: `2.4`
- Upstream reference: https://github.com/docker-library/httpd

## Repository Relationships and Refresh Policy

This repository is an independent image project coordinated by [`docker-workspace`](https://github.com/kernel528/docker-workspace). Its direct upstream custom base is [`kernel528/alpine`](https://github.com/kernel528/alpine-docker).

[`www.kernelsanders.biz`](https://github.com/kernel528/www.kernelsanders.biz) builds its website image from `kernel528/httpd`. After publishing and validating a new immutable HTTPD tag, refresh the website in a separate branch/PR/release by updating its Dockerfile base tag and testing the rendered site. Only after the website image is published should [`docker-swarm`](https://github.com/kernel528/docker-swarm) update `kernelsanders-stack.yml`.

Refresh sequence: `alpine-docker` -> `httpd-docker` -> `www.kernelsanders.biz` -> `docker-swarm`.

## CI validation and release policy

- Pull requests targeting `2.4` run the rootless exact-image HTTPD smoke check; the job receives no registry credentials and publishes nothing.
- Pushes to `2.4` run rootless validation and build/smoke a fresh DIND candidate before a separate credentialed step publishes a unique build-number candidate tag.
- Tags are created manually from reviewed `main`. The tag pipeline freshly builds and smoke-tests the exact image, publishes the immutable tag first, then updates `2.4`, the HTTPD version alias, and `latest` to that same image.
- Candidate images are not deployment inputs. HTTPD release tags are distinct from Alpine base tags.
- The HTTPD GitHub repository is public. The rootless validation job runs without credentials inside the isolated guest; PR code therefore executes there with the guest's rootless Podman boundary.
- Add `kernel528/httpd-docker` to the isolated runner's exact repository allowlist only after reviewing this pipeline. Do not add wildcard repository patterns.

## Build
```
docker build -t kernel528/httpd:2.4.69-3.24.3_3 -f Dockerfile .
```

## Run
```
docker run -dit --rm --name httpd-docker --hostname httpd-docker -p 80:80 kernel528/httpd:2.4.69-3.24.3_3
```
```
Open web browser to http://localhost
```

## Custom configuration
Create a custom `httpd.conf` and copy it into the image:
```
COPY ./my-httpd.conf /usr/local/apache2/conf/httpd.conf
```

## Custom content (htdocs)
```
docker run -dit --rm --name httpd --hostname httpd -p 80:80 -v "$PWD/htdocs":/usr/local/apache2/htdocs/ kernel528/httpd:2.4.69-3.24.3_3
```

## Authors
* **kernel528** - (kernel528@gmail.com)
