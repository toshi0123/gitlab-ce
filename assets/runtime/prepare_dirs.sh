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
shared/artifacts/tmp/cache
shared/artifacts/tmp/uploads
shared/lfs-objects
shared/pages
shared/cache/archive
EOF

rm -rf /home/git/gitlab/public/uploads
ln -s /home/git/data/uploads /home/git/gitlab/public/uploads

rm -rf /home/git/gitlab/builds
ln -s /home/git/data/builds /home/git/gitlab/builds

rm -rf /home/git/gitlab/tmp/backups
ln -s /home/git/data/backups /home/git/gitlab/tmp/backups

rm -rf /home/git/gitlab/shared
ln -s /home/git/data/shared /home/git/gitlab/shared

rm -rf /home/git/gitlab/log
ln -s /var/log/gitlab /home/git/gitlab/log
chown git:git /var/log/gitlab
