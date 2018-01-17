#!/bin/sh

# Download
ash -ex /home/git/assets/build/download_gitlab.sh

# Prepare for install
apk add --no-cache --virtual .builddev \
  build-base \
  ruby-dev \
  go \
  icu-dev \
  zlib-dev \
  libffi-dev \
  cmake \
  postgresql-dev \
  mariadb-dev \
  linux-headers \
  re2-dev \
  libassuan-dev \
  libgpg-error-dev \
  gpgme-dev \
  coreutils \
  yarn

sudo -u git -H echo "install: --no-document" > ~/.gemrc

echo "git ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/git

# Install
ash -ex /home/git/assets/build/install_gitlab.sh

ash -ex /home/git/assets/build/install_gitlab-shell.sh

ash -ex /home/git/assets/build/install_gitlab-workhorse.sh

ash -ex /home/git/assets/build/install_gitaly.sh

ash -ex /home/git/assets/build/install_assets.sh

# Set default settings
ash -ex /home/git/assets/build/default_setting.sh

# Clean up
ash -x  /home/git/assets/build/clean_up.sh

# Remove build dependencies
rm -f /etc/sudoers.d/git

apk del --no-cache .builddev

# Install for runtime
RUNDEP=`scanelf --needed --nobanner --format '%n#p' --recursive /usr/lib/ruby | tr ',' '\n' | sort -u | awk 'system("[ -e /lib/" $1 " -o -e /usr/lib/" $1 " -o -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'`

apk add --no-cache $RUNDEP
