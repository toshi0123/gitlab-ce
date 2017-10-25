#!/bin/sh

set -x

cd /home/git/gitlab

apk add --no-cache build-base icu-dev zlib-dev libffi-dev cmake krb5-dev postgresql-dev linux-headers re2-dev libassuan-dev libgpg-error-dev gpgme-dev

sudo -u git -H bundle install --deployment --without development test mysql aws --verbose || echo "testing"
