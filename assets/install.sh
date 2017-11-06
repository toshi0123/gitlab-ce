#!/bin/sh

set -x

cd /home/git/gitlab

apk add --no-cache --virtual .builddev build-base ruby-dev ruby-rake go icu-dev zlib-dev libffi-dev cmake krb5-dev postgresql-dev linux-headers re2-dev libassuan-dev libgpg-error-dev gpgme-dev

sudo -u git -H echo "install: --no-document" > .gemrc

sudo -u git -H bundle config --local build.gpgme --use-system-libraries

sudo -u git -H bundle install --deployment --without development test mysql aws # --verbose || echo "testing"

apk del --no-cache .builddev

RUNDEP=`scanelf --needed --nobanner --format '%n#p' --recursive /home/git/ | tr ',' '\n' | sort -u | awk 'system("[ -e /lib/" $1 " -o -e /usr/lib/" $1 " -o -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'`

apk add --no-cache $RUNDEP
