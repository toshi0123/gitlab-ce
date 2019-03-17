#!/bin/sh

cd /home/git/gitlab

# gettext
sudo -u git -H bundle exec rake gettext:compile RAILS_ENV=production --trace > gettext_pack.log 2>&1 || { cat gettext_pack.log;exit 1; }

# assets
sudo -u git -H yarn install --production --pure-lockfile
sudo -u git -H env NODE_OPTIONS="--max-old-space-size=2048" bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production --trace > assets.log 2>&1 || { cat assets.log;exit 1; }
