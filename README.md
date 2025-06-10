[![Build Status](http://drone.kernelsanders.biz:8080/api/badges/kernel528/httpd-docker/status.svg)](http://drone.kernelsanders.biz:8080/kernel528/httpd-docker)
[![Latest Version](https://img.shields.io/github/v/tag/kernel528/httpd-docker)](https://github.com/kernel528/httpd-docker/releases/latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/kernel528/httpd)](https://hub.docker.com/r/kernel528/httpd)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/kernel528/httpd/2.4.62)](https://hub.docker.com/r/kernel528/httpd/2.4.62)
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/kernel528/httpd?sort=semver)](https://hub.docker.com/r/kernel528/httpd)

# Base Httpd Docker repo

These images are based on the official httpd docker hub release. The source Dockerfile is used as a base.

### Overview
* The images are based on the kernel528/alpine
* The httpd versions are broken out into subfolders based on the versions, e.g.
    * 2.4
* This repo is based on:  https://github.com/docker-library/httpd

### How to start:
```
docker run -dit --rm --name httpd-docker --hostname httpd-docker -p 80:80 kernel528/httpd:2.4.63
```
```
Open web browser to http://localhost
```

### How to add custom settings:
* Create a custom httpd.conf file.
* Include the httpd.conf file in your Dockerfile customization:
```
COPY ./my-httpd.conf /usr/local/apache2/conf/httpd.conf
```

### Add custom htdocs at run time:
```
docker run -dit --rm --name httpd --hostname httpd -p 80:80 -v "$PWD/htdocs":/usr/local/apache2/htdocs/ kernel528/httpd:2.4.63
```

### Authors
* **kernel528** - (kernel528@gmail.com)
