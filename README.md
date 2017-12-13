# gitlab-ce on alpine linux

[![Docker Repository on Quay](https://quay.io/repository/toshi0123/gitlab-ce/status "Docker Repository on Quay")](https://quay.io/repository/toshi0123/gitlab-ce)

This image is under developing.  

This gitlab-ce container image is built from source files.  
You can find the installation guides as follows.  
https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/install/installation.md

This docker image contains
1. gitlab-ce(postgres)
1. gitlab-shell
1. gitaly
1. gitlab-workhorse
1. nginx

Postgresql and redis are not contained in this image.  
You have to setup by yourself.  

## Quick start

First, you have to create new network.

```shell=
docker network create gitlab-network
```

And run redis. (On this time I use my own redis image.)  
You can use library/redis or other redis container images.  

```shell=
docker run --name gitlab-redis \
  -d \
  --hostname gitlab-redis \
  --log-opt max-size=10m \
  --log-opt max-file=4 \
  -v $PWD/redis:/data \
  --network gitlab-network \
  quay.io/toshi0123/redis:latest
```

And run postgresql. (Rails 4 is not support to use Postgresql 10.)  
You can use library/postgres:9.6.6-alpine or other postgresql container images.  

```shell=
docker run --name gitlab-postgres \
  -d \
  --hostname gitlab-postgres \
  -e 'POSTGRES_USER=gitlab' \
  -e 'POSTGRES_PASSWORD=gitlabpassword' \
  -e 'POSTGRES_DB=gitlabhq_production' \
  -e 'DB_EXTENSION=pg_trgm' \
  --log-opt max-size=10m \
  --log-opt max-file=4 \
  -v $PWD/postgres:/var/lib/postgresql/data:rw \
  --network gitlab-network \
  quay.io/toshi0123/postgres:9.6.6-r0
```

Then, run gitlab. (If you want to set up with **https**, you have to read HTTPS section before starting gitlab container.)  

```shell=
docker run --name gitlab \
  -d \
  -p 80:80 \
  -p 443:443 \
  --hostname gitlab \
  -e 'GITLAB_SECRETS_DB_KEY_BASE=please-modify-by-yourself' \
  -e 'GITLAB_SECRETS_SECRET_KEY_BASE=please-modify-by-yourself' \
  -e 'GITLAB_SECRETS_OTP_KEY_BASE=please-modify-by-yourself' \
  --log-opt max-size=10m \
  --log-opt max-file=4 \
  -v $PWD/gitlab/etc:/etc/gitlab:rw \
  -v $PWD/gitlab/data:/home/git/data:rw \
  -v $PWD/gitlab/log:/var/log:rw \
  --network gitlab-network \
  quay.io/toshi0123/gitlab-ce:latest
```

Wait for gitlab to start up.  

```
$ docker logs gitlab -f
...
The GitLab Unicorn web server with pid 132 is running.
The GitLab Sidekiq job dispatcher with pid 230 is running.
The GitLab Workhorse with pid 170 is running.
Gitaly with pid 178 is running.
GitLab and all its components are up and running.
+ /usr/sbin/crond -L /var/log/crond.log
+ set +x
```

And you can access http://127.0.0.1 in your browser.

All data and config, log files are in $PWD/redis and $PWD/postgres, $PWD/gitlab directories.  
**Please keep these carefully.**

Environment variables
---

| variables | example values | description |
| --------- | ------ | ----------- |
| DB_HOST | `gitlab-postgres` | Postgresql host(default: `gitlab-postgres`) |
| DB_PORT | `5432` | Postgresql port(default: `5432`) |
| DB_NAME | `gitlabhq_production` | Gitlab DB name(default: `gitlabhq_production`) |
| DB_USER | `gitlab` | Gitlab DB user's name(default: `gitlab`) |
| DB_PASS | `gitlabpassword` | Gitlab DB user's password(default: `gitlabpassword`) |
| REDIS_HOST | `gitlab-redis` | Redis-server host(default: `gitlab-redis`) |
| REDIS_PORT | `6379` | Redis-server port(default: `6379`) |
| GITLAB_SECRETS_DB_KEY_BASE | `very-long-random-string` | Encryption key(default: `default`) |
| GITLAB_SECRETS_SECRET_KEY_BASE | `very-long-random-string` | Encryption key(default: `default`) |
| GITLAB_SECRETS_OTP_KEY_BASE | `very-long-random-string` | Encryption key(default: `default`) |
| GITLAB_HTTPS | `false` | HTTPS(default: `false`) |

### HTTPS

The `GITLAB_HTTPS` flag is available only **first run**.  
If you started `GITLAB_HTTPS` with `false`, you have to modify $PWD/gitlab/etc/gitlab.conf by yourself.  
The example of https nginx config is /home/git/gitlab/lib/support/nginx/gitlab-ssl.  
And in that case you are required to run `cp -pf /home/git/gitlab/lib/support/nginx/gitlab-ssl /etc/gitlab/example/gitlab.conf.example` for update gitlab.  

Of cause you have to prepare the key pair.  
Before starting gitlab container, store the key pair to $PWD/gitlab/etc directory.  

```shell=
$ mkdir -p ./gitlab/etc/
$ cp -pf private.key ./gitlab/etc/gitlab.key
$ cp -pf public.crt ./gitlab/etc/gitlab.crt
```

## Custumize configuration files

You can modify some configuration files as you like.  
The files are stored in the $PWD/gitlab/etc directory.  
You can edit by your editor, and run `docker restart gitlab`.  
These files are not modified by this container image except first run.  
When you recreate the updated version of gitlab container image, the configuration files will be patched compared to the new one.  
(If it cannot be patched with some conflict, the new container will not be started.)  

### Example of update conflict
Follows logs shows update conflict of database.yml. (v10.1.5 to v10.2.4)

```
patching file /home/git/data/config/database.yml
Hunk #1 FAILED at 9.
Hunk #2 FAILED at 23.
Hunk #3 FAILED at 33.
Hunk #4 FAILED at 48.
4 out of 4 hunks FAILED -- saving rejects to file /home/git/data/config/database.yml.rej
--- database.yml.example
+++ database.yml.example
@@ -9,4 +9,3 @@
-  # username: git
-  # password:
-  # host: localhost
-  # port: 5432
+  username: git
+  password: "secure password"
+  host: localhost
@@ -23,2 +22,2 @@
-  password:
-  # host: localhost
+  password: "secure password"
+  host: localhost
@@ -33,4 +32,4 @@
-  pool: 5
-  username: postgres
-  password:
-  # host: localhost
+  pool: 10
+  username: git
+  password: "secure password"
+  host: localhost
@@ -48 +47 @@
-  # host: localhost
+  host: localhost
```

You have to verify $PWD/gitlab/etc/database.yml.  
Then you remove the example file.

```
$ rm -f ./gitlab/config/example/database.yml.example
$ docker start gitlab
```

## Login in gitlab container for debug

You want to login into the gitlab container, run the follow command.  

```shell=
$ docker exec -it gitlab sh
```

Enjoy it!  
