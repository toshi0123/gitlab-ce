#!/bin/sh

cd /home/git/gitlab

sed -i '/^SHELL/s/bash/sh/' /usr/lib/node_modules/npm/Makefile
sed -i '/^clean:/s/uninstall//' /usr/lib/node_modules/npm/Makefile

for fn in `find / -type f -name 'Makefile'`;do ( cd `dirname $fn`;make clean );done > make.log 2>&1

sudo -u git -H yarn cache clean
sudo -u git -H rm -rf tmp/cache/assets

find / -type f -name '*.gem' | xargs rm -f

find /usr/lib/ruby/gems/ -type f -name '*.o' | xargs rm -f
find /usr/lib/ruby/gems/ -type f -name '*.a' | xargs rm -f
find /home/git/ -type f -name '*.a' | xargs rm -f

find /usr/lib/ruby/gems/*/gems/ -type f -name "*.so" -delete

rm -rf /root/.bundle/cache /home/git/.bundle/cache

find / -type f -name "*.rdoc" -delete
find / -type f -name "*.log" -delete

rm -f /home/git/gitlab/.gitlab_shell_secret /home/git/gitlab/.gitlab_workhorse_secret
