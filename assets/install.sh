#!/bin/sh

# install build deps
apk add --no-cache --virtual .builddev build-base ruby-dev go icu-dev zlib-dev libffi-dev \
  cmake krb5-dev postgresql-dev linux-headers re2-dev libassuan-dev libgpg-error-dev gpgme-dev coreutils yarn

# tzdata
apk add --no-cache tzdata

echo "git ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/git

sudo -u git -H echo "install: --no-document" > ~/.gemrc

ash /home/git/build/install_gitlab.sh

ash /home/git/build/install_gitlab-shell.sh

ash /home/git/build/install_gitlab-workhorse.sh

ash /home/git/build/install_gitaly.sh

ash /home/git/build/install_assets.sh

ash /home/git/build/clean_up.sh

rm -f /etc/sudoers.d/git

apk del --no-cache .builddev

# packages install for running gitlab
RUNDEP=`scanelf --needed --nobanner --format '%n#p' --recursive /home/git | tr ',' '\n' | sort -u | awk 'system("[ -e /lib/" $1 " -o -e /usr/lib/" $1 " -o -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'`
RUNDEP2=`scanelf --needed --nobanner --format '%n#p' --recursive /usr/lib/ruby | tr ',' '\n' | sort -u | awk 'system("[ -e /lib/" $1 " -o -e /usr/lib/" $1 " -o -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'`

apk add --no-cache $RUNDEP $RUNDEP2
