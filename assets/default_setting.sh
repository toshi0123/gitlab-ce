#!/bin/sh

cd /home/git/gitlab

sudo -u git -H git config --global core.autocrlf input
sudo -u git -H git config --global gc.auto 0
sudo -u git -H git config --global repack.writeBitmaps true

sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb
sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
mkdir -p /etc/default/
sudo cp lib/support/init.d/gitlab.default.example /etc/default/gitlab

# for alpine linux
sed -i 's|/bin/bash|/bin/sh|g' /etc/init.d/gitlab /etc/default/gitlab
sed -i 's|kill --|kill|g' /etc/init.d/gitlab
sed -i 's|$gitaly_dir/gitaly|gitaly|g' /etc/init.d/gitlab

# busybox pkill is used even if procps is installed
rm -f /usr/bin/pkill
ln -s /bin/pkill /usr/bin/pkill

mkdir -p /run/nginx
rm -f /etc/nginx/conf.d/default.conf
sudo cp lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf
