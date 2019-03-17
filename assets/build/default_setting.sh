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
sed -i \
    -e 's|/bin/bash|/bin/sh|g' \
    -e 's|kill --|kill|g' \
    -e 's|$gitaly_dir/gitaly|gitaly|g' \
    /etc/init.d/gitlab /etc/default/gitlab

# busybox pkill is used even if procps was installed
#rm -f /usr/bin/pkill
#ln -s /bin/pkill /usr/bin/pkill

mkdir -p /run/nginx
rm -f /etc/nginx/conf.d/default.conf
sed -i 's/ssl_session_cache/#ssl_session_cache/' /etc/nginx/nginx.conf

# default settings of data volume
sed -i 's|/home/git/.ssh/authorized_keys|/home/git/data/.ssh/authorized_keys|g' /home/git/gitlab-shell/config.yml
sed -i '/^path/s|/home/git/repositories|/home/git/data/repositories|g' /home/git/gitaly/config.toml
sed -i "/^  repositories:/,/^  backup:/ s|path: /home/git/repositories/|path: /home/git/data/repositories/|" config/gitlab.yml

# default log rotate settings
cat <<EOF > /etc/logrotate.d/gitlab
/var/log/gitlab/*.log {
  weekly
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  copytruncate
  dateext
}
EOF

cat <<EOF > /etc/logrotate.d/nginx
/var/log/nginx/*.log {
  weekly
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  copytruncate
  dateext
}
EOF

cat <<EOF > /etc/logrotate.d/crond
/var/log/crond.log {
  weekly
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  copytruncate
  dateext
}
EOF
