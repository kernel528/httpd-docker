[![Build Status](http://drone.kernelsanders.biz/api/badges/kernel528/httpd-docker/status.svg)](http://drone.kernelsanders.biz/kernel528/httpd-docker)

# Base Httpd Docker repo

These images are based on the official httpd docker hub release. The source Dockerfile is used as a base.

### Overview
* The images are based on the kernel528/alpine
* The httpd versions are broken out into subfolders based on the versions, e.g.
    * 2.4
* This repo is based on:  https://github.com/docker-library/httpd

### How to start:
```
docker run -dit --rm --name httpd-docker --hostname httpd-docker -p 80:80 kernel528/httpd:2.4.43
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
docker run -dit --rm --name httpd --hostname httpd -p 80:80 -v "$PWD/htdocs":/usr/local/apache2/htdocs/ kernel528/httpd:2.4.43
```

### Authors
* **kernel528** - (kernel528@gmail.com)
