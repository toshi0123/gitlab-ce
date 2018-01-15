#!/bin/sh

cd /home/git/gitlab

sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml
sudo -u git -H cp config/database.yml.postgresql config/database.yml
sudo -u git -H cp config/resque.yml.example config/resque.yml

sudo -u git -H bundle config --local build.gpgme --use-system-libraries

sudo -u git -H mkdir -p /home/git/repositories

sed -i 's/google-protobuf (3.2.0.2)/google-protobuf (3.3.0)/g' Gemfile.lock
sed -i 's/grpc (1.2.5)/grpc (1.4.0)/g' Gemfile.lock

sudo -u git -H bundle install --system --without development test mysql aws kerberos -j$(nproc)
