#!/bin/sh

cd /home/git/data

while read line;do
  [ -d "$line" ] && continue
  mkdir -p $line
  chown git:git $line
done <<EOF
.ssh
repositories
uploads
builds
backups
tmp
shared
shared/artifacts
shared/artifacts/tmp
shared/artifacts/tmp/cache
shared/artifacts/tmp/uploads
shared/lfs-objects
shared/pages
shared/cache
shared/cache/archive
EOF

chmod -R ug+rwX,o-rwx /home/git/data/repositories
chmod -R ug-s /home/git/data/repositories
find /home/git/data/repositories -type d -print0 | sudo xargs -0 chmod g+s

chmod 700 /home/git/data/uploads

rm -rf /home/git/gitlab/public/uploads
ln -s /home/git/data/uploads /home/git/gitlab/public/uploads

rm -rf /home/git/gitlab/builds
ln -s /home/git/data/builds /home/git/gitlab/builds

rm -rf /home/git/gitlab/tmp/backups
ln -s /home/git/data/backups /home/git/gitlab/tmp/backups

rm -rf /home/git/gitlab/shared
ln -s /home/git/data/shared /home/git/gitlab/shared

rm -rf /home/git/gitlab/log
mkdir -p /var/log/gitlab
ln -s /var/log/gitlab /home/git/gitlab/log
chown git:git /var/log/gitlab

mkdir -p /var/log/nginx
