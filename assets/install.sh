#!/bin/sh

set -x

gem install bundler

cd /home/git/gitlab

#sudo -u git -H bundle install --deployment --without development test mysql aws
