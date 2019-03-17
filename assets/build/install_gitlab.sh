#!/bin/sh

cd /home/git/gitlab

sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml
sudo -u git -H cp config/database.yml.postgresql config/database.yml
sudo -u git -H cp config/resque.yml.example config/resque.yml

sudo -u git -H bundle config --local build.gpgme --use-system-libraries

sudo -u git -H echo "gem 'webrick'" >> Gemfile

sudo -u git -H bundle install --system --without development test mysql aws kerberos -j$(nproc)
