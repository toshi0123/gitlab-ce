#!/bin/sh

cd /home/git/gitlab

sudo -u git -H bundle exec rake gitlab:shell:install RAILS_ENV=production SKIP_STORAGE_VALIDATION=true

rm -rf /home/git/gitlab-shell/go /home/git/gitlab-shell/go_build
