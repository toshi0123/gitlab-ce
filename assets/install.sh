#!/bin/sh

set -x

date

cd /home/git/gitlab

sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml
sudo -u git -H cp config/database.yml.postgresql config/database.yml
sudo -u git -H cp config/resque.yml.example config/resque.yml

apk add --no-cache --virtual .builddev build-base ruby-dev go icu-dev zlib-dev libffi-dev \
  cmake krb5-dev postgresql-dev linux-headers re2-dev libassuan-dev libgpg-error-dev gpgme-dev coreutils yarn

sudo -u git -H echo "install: --no-document" > .gemrc

sudo -u git -H bundle config --local build.gpgme --use-system-libraries

echo "git ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/git

# gitlab
sudo -u git -H bundle install --system --without development test mysql aws -j$(nproc)

# tzdata
apk add --no-cache tzdata

# gitlab-shell
sudo -u git -H bundle exec rake gitlab:shell:install RAILS_ENV=production SKIP_STORAGE_VALIDATION=true

# gitlab-workhorse
#sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production
GITLAB_WORKHORSE_VERSION=$(cat /home/git/gitlab/GITLAB_WORKHORSE_VERSION)
sudo -u git -H git clone --depth 1 -b v${GITLAB_WORKHORSE_VERSION} https://gitlab.com/gitlab-org/gitlab-workhorse.git /home/git/gitlab-workhorse

cd /home/git/gitlab-workhorse
make install

cd -

# gitaly
#sudo -u git -H bundle exec rake "gitlab:gitaly:install[/home/git/gitaly]" RAILS_ENV=production
GITALY_SERVER_VERSION=$(cat /home/git/gitlab/GITALY_SERVER_VERSION)
sudo -u git -H git clone --depth 1 -b v${GITALY_SERVER_VERSION} https://gitlab.com/gitlab-org/gitaly.git /home/git/gitaly

cd /home/git/gitaly

sudo -u git -H cp config.toml.example config.toml

sed -i '/vendor\/bundle/d' Makefile
sed -i 's/bundle install/bundle install --system/' Makefile

make install

cd -

# gitlab-pages
GITLAB_PAGES_VERSION=$(cat /home/git/gitlab/GITLAB_PAGES_VERSION)
sudo -u git -H git clone --depth 1 -b v${GITLAB_PAGES_VERSION} https://gitlab.com/gitlab-org/gitlab-pages.git /home/git/gitlab-pages

cd /home/git/gitlab-pages
make
make install
cp -f gitlab-pages /usr/local/bin/

cd -

# gettext
sudo -u git -H bundle exec rake gettext:pack RAILS_ENV=production > gettext_pack.log 2>&1
sudo -u git -H bundle exec rake gettext:po_to_json RAILS_ENV=production

# assets
sudo -u git -H yarn install --production --pure-lockfile
sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production > assets.log 2>&1
echo $?

# clean up
sudo -u git -H yarn cache clean
sudo -u git -H rm -rf tmp/cache/assets
find /home/git -type d -name '.git' | xargs rm -rf
find / -type f -name '*.gem' | xargs rm -f

for fn in `find / -type f -name 'Makefile'`;do ( cd `dirname $fn`;make clean );done > make.log 2>&1

rm -f /etc/sudoers.d/git

apk del --no-cache .builddev

RUNDEP=`scanelf --needed --nobanner --format '%n#p' --recursive /home/git | tr ',' '\n' | sort -u | awk 'system("[ -e /lib/" $1 " -o -e /usr/lib/" $1 " -o -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'`
RUNDEP2=`scanelf --needed --nobanner --format '%n#p' --recursive /usr/lib/ruby | tr ',' '\n' | sort -u | awk 'system("[ -e /lib/" $1 " -o -e /usr/lib/" $1 " -o -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }'`

apk add --no-cache $RUNDEP $RUNDEP2

sudo -u git -H git config --global core.autocrlf input
sudo -u git -H git config --global gc.auto 0
sudo -u git -H git config --global repack.writeBitmaps true

sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb
sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
mkdir -p /etc/default/
sudo cp lib/support/init.d/gitlab.default.example /etc/default/gitlab

sed -i 's|/bin/bash|/bin/sh|g' /etc/init.d/gitlab /etc/default/gitlab
sed -i 's|kill --|kill|g' /etc/init.d/gitlab

# busybox pkill is used even if procps is installed
rm -f /usr/bin/pkill
ln -s /bin/pkill /usr/bin/pkill

mkdir -p /run/nginx
rm -f /etc/nginx/conf.d/default.conf
sudo cp lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf

date
