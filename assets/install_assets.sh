#!/bin/sh

cd /home/git/gitlab

# gettext
sudo -u git -H bundle exec rake gettext:pack RAILS_ENV=production > gettext_pack.log 2>&1 || cat gettext_pack.log
sudo -u git -H bundle exec rake gettext:po_to_json RAILS_ENV=production

# assets
sudo -u git -H yarn install --production --pure-lockfile
sudo -u git -H bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production > assets.log 2>&1 || cat assets.log
