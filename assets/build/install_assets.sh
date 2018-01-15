#!/bin/sh

cd /home/git/gitlab

# gettext
sudo -u git -H bundle exec rake gettext:pack RAILS_ENV=production --trace > gettext_pack.log 2>&1 || { cat gettext_pack.log;exit 1; }
sudo -u git -H bundle exec rake gettext:po_to_json RAILS_ENV=production --trace

# assets
sudo -u git -H yarn install --production --pure-lockfile
sudo -u git -H yarn add ajv@^4.0.0
sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production --trace > assets.log 2>&1 || { cat assets.log;exit 1; }
