[![Build Status](http://drone.kernelsanders.biz:8080/api/badges/kernel528/httpd-docker/status.svg)](http://drone.kernelsanders.biz:8080/kernel528/httpd-docker)
[![Latest Version](https://img.shields.io/github/v/tag/kernel528/httpd-docker)](https://github.com/kernel528/httpd-docker/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/kernel528/httpd)](https://hub.docker.com/r/kernel528/httpd)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/kernel528/httpd/2.4.68)](https://hub.docker.com/r/kernel528/httpd/2.4.68)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/kernel528/httpd?sort=semver)](https://hub.docker.com/r/kernel528/httpd)

# Base Httpd Docker repo

These images are based on the official httpd docker hub release. The source Dockerfile is used as a base.

## Overview
- Base image: `kernel528/alpine`
- httpd version line: `2.4`
- Upstream reference: https://github.com/docker-library/httpd

## Build
```
docker build -t kernel528/httpd:2.4.68-3.24.1_1 -f Dockerfile .
```

## Run
```
docker run -dit --rm --name httpd-docker --hostname httpd-docker -p 80:80 kernel528/httpd:2.4.68-3.24.1_1
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
docker run -dit --rm --name httpd --hostname httpd -p 80:80 -v "$PWD/htdocs":/usr/local/apache2/htdocs/ kernel528/httpd:2.4.68-3.24.1_1
```

## Authors
* **kernel528** - (kernel528@gmail.com)
