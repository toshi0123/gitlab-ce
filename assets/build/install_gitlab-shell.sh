#!/bin/sh

GITLAB_SHELL_VERSION=$(cat /home/git/gitlab/GITLAB_SHELL_VERSION)
sudo -u git -H git clone --depth 1 -b v${GITLAB_SHELL_VERSION} https://gitlab.com/gitlab-org/gitlab-shell.git /home/git/gitlab-shell

cd /home/git/gitlab-shell

sudo -u git -H cp /home/git/gitlab-shell/config.yml.example /home/git/gitlab-shell/config.yml

./bin/compile
./bin/install

cd

rm -rf /home/git/gitlab-shell/go /home/git/gitlab-shell/go_build
