#!/bin/sh

set -x

cd /home/git/gitlab

sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml
sudo -u git -H cp config/database.yml.postgresql config/database.yml
sudo -u git -H cp config/resque.yml.example config/resque.yml

apk add --no-cache --virtual .builddev build-base ruby-dev ruby-rake ruby-bigdecimal ruby-irb go icu-dev zlib-dev libffi-dev cmake krb5-dev postgresql-dev linux-headers re2-dev libassuan-dev libgpg-error-dev gpgme-dev coreutils

sudo -u git -H echo "install: --no-document" > .gemrc

sudo -u git -H bundle config --local build.gpgme --use-system-libraries

echo "git ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/git

# gitlab
sudo -u git -H bundle install --system --without development test mysql aws -j2

# tzdata
apk add --no-cache tzdata

# gitlab-shell
sudo -u git -H bundle exec rake gitlab:shell:install RAILS_ENV=production SKIP_STORAGE_VALIDATION=true

# gitlab-workhorse
sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production

# gitaly
sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly]" RAILS_ENV=production

# gettext
sudo -u git -H bundle exec rake gettext:pack RAILS_ENV=production
sudo -u git -H bundle exec rake gettext:po_to_json RAILS_ENV=production

# assets
sudo -u git -H yarn install --production --pure-lockfile
sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production

# clean up
sudo -u git -H yarn cache clean
sudo -u git -H rm -rf tmp/cache/assets
find /home/git -type d -name '.git' | xargs rm -rf
find /home/git -type f -name '*.gem' | xargs rm -f

for fn in `find / -type f -name 'Makefile'`;do ( cd `dirname $fn`;make clean );done

apk del --no-cache .builddev

RUNDEP=`scanelf --needed --nobanner --format '%n#p' --recursive /home/git/ | tr ',' '\n' | sort -u | awk 'system("[ -e /lib/" $1 " -o -e /usr/lib/" $1 " -o -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'`

apk add --no-cache $RUNDEP
