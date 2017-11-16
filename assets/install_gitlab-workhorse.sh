#!/bin/sh

#cd /home/git/gitlab
#sudo -u git -H bundle exec rake "gitlab:workhorse:install[/home/git/gitlab-workhorse]" RAILS_ENV=production

GITLAB_WORKHORSE_VERSION=$(cat /home/git/gitlab/GITLAB_WORKHORSE_VERSION)
sudo -u git -H git clone --depth 1 -b v${GITLAB_WORKHORSE_VERSION} https://gitlab.com/gitlab-org/gitlab-workhorse.git /home/git/gitlab-workhorse

cd /home/git/gitlab-workhorse

make install

make clean

cd

rm -rf /home/git/gitlab-workhorse
sudo -u git -H mkdir -p /home/git/gitlab-workhorse
