#!/bin/sh

set -x

prepare_config(){
  [ -e $1 ] || return 1
  local basename=`basename $1`
  cp -pf $1.example /home/git/data/config/example
  cp -pf $1 /home/git/data/config/
}

link_config(){
  local basename=`basename $1`
  rm -f $1
  ln -s /home/git/data/config/$basename $1
}

diff_config(){
  local basename=`basename $1`
  diff $1.example /home/git/data/config/example/$basename.example || exit 1
}

if [ ! -d /home/git/data/config ];then
  mkdir -p /home/git/data/config
  mkdir -p /home/git/data/config/example
  chown -R git:git /home/git/data/config
  
  cp -pf /home/git/gitlab/config/database.yml.postgresql /home/git/gitlab/config/database.yml.example
  cp -pf /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf.example
  while read line;do
    prepare_config $line
  done < configfile_list.txt
fi

cp -pf /home/git/gitlab/config/database.yml.postgresql /home/git/gitlab/config/database.yml.example
cp -pf /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf.example
while read line;do
  diff_config $line
  link_config $line
done < configfile_list.txt

mkdir -p /home/git/data/.ssh
mkdir -p /home/git/data/repositories
mkdir -p /home/git/data/uploads
mkdir -p /home/git/data/builds
mkdir -p /home/git/data/backups
chown git:git /home/git/data/.ssh /home/git/data/repositories /home/git/data/uploads /home/git/data/builds /home/git/data/backups
mkdir -p /home/git/data/shared/artifacts/tmp/cache /home/git/data/shared/artifacts/tmp/uploads
mkdir -p /home/git/data/shared/lfs-objects /home/git/data/shared/pages
mkdir -p /home/git/data/shared/cache/archive
chown -R /home/git/data/shared

ln -s /home/git/data/uploads /home/git/gitlab/public/uploads
rm -rf /home/git/gitlab/builds
ln -s /home/git/data/builds /home/git/gitlab/builds
ln -s /home/git/data/backups /home/git/gitlab/tmp/backups
rm -rf /home/git/gitlab/shared
ln -s /home/git/data/shared /home/git/gitlab/shared
rm -rf /home/git/gitlab/log
ln -s /var/log/gitlab /home/git/gitlab/log

if [ -e /home/git/data/config/VERSION ];then
  cd /home/git/gitlab
  sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production --trace || exit 1
fi

cp -pf /home/git/gitlab/VERSION /home/git/data/config/

/etc/init.d/gitlab start || exit 1
/usr/sbin/nginx

set +x

while [ 0 ];do sleep 3600;done
