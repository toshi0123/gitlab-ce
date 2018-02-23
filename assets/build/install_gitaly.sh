#!/bin/sh

GITALY_SERVER_VERSION=$(cat /home/git/gitlab/GITALY_SERVER_VERSION)
sudo -u git -H git clone --depth 1 -b v${GITALY_SERVER_VERSION} https://gitlab.com/gitlab-org/gitaly.git /home/git/gitaly

cd /home/git/gitaly

sudo -u git -H cp config.toml.example config.toml

sed -i '/vendor\/bundle/d' Makefile
#sed -i 's/bundle install/bundle install --system/' Makefile

BUNDLE_FLAGS="--system" make install

make clean

rm -f /home/git/gitaly/gitaly /home/git/gitaly/gitaly-ssh
