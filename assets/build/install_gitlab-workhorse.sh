#!/bin/sh

GITLAB_WORKHORSE_VERSION=$(cat /home/git/gitlab/GITLAB_WORKHORSE_VERSION)
sudo -u git -H git clone --depth 1 -b v${GITLAB_WORKHORSE_VERSION} https://gitlab.com/gitlab-org/gitlab-workhorse.git /home/git/gitlab-workhorse

cd /home/git/gitlab-workhorse

make install

make clean

cd

rm -rf /home/git/gitlab-workhorse
sudo -u git -H mkdir -p /home/git/gitlab-workhorse
