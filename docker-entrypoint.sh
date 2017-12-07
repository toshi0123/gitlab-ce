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
  if [ -e /home/git/data/config/example/$basename.example ];then
    diff /home/git/data/config/example/$basename.example $1.example | patch -N $1 || exit 1
  fi
  cp -pf $1.example /home/git/data/config/example
}

# set default
DB_HOST=${DB_HOST:-gitlab-postgres}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-gitlabhq_production}
DB_USER=${DB_USER:-gitlab}
DB_PASS=${DB_PASS:-gitlabpassword}

env PGPASSWORD="$DB_PASS" psql -h $DB_HOST -d $DB_NAME -U $DB_USER -c \
"SELECT true AS enabled FROM pg_available_extensions WHERE name = 'pg_trgm' AND installed_version IS NOT NULL;" || exit 1

REDIS_HOST=${REDIS_HOST:-gitlab-redis}
REDIS_PORT=${REDIS_PORT:-6379}

GITLAB_SECRETS_DB_KEY_BASE=${GITLAB_SECRETS_DB_KEY_BASE:-default}
GITLAB_SECRETS_SECRET_KEY_BASE=${GITLAB_SECRETS_SECRET_KEY_BASE:-default}
GITLAB_SECRETS_OTP_KEY_BASE=${GITLAB_SECRETS_OTP_KEY_BASE:-default}

GITLAB_HTTPS=${GITLAB_HTTPS:-false}

if [ ! -d /home/git/data/config ];then
  mkdir -p /home/git/data/config
  mkdir -p /home/git/data/config/example
  chown -R git:git /home/git/data/config
  
  cp -pf /home/git/gitlab/config/database.yml.postgresql /home/git/gitlab/config/database.yml.example
  if [ "$GITLAB_HTTPS" == "true" ];then
    cp -pf /home/git/gitlab/lib/support/nginx/gitlab-ssl /etc/nginx/conf.d/gitlab.conf
    cp -pf /home/git/gitlab/lib/support/nginx/gitlab-ssl /etc/nginx/conf.d/gitlab.conf.example
  else
    cp -pf /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf
    cp -pf /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf.example
  fi
  
  sed -i \
  -e "s|\(# \)*database:.*$|database: $DB_NAME|g" \
  -e "s|\(# \)*username:.*$|username: $DB_USER|g" \
  -e "s|\(# \)*password:.*$|password: $DB_PASS|g" \
  -e "s|\(# \)*host:.*$|host: $DB_HOST|g" \
  -e "s|\(# \)*port:.*$|port: $DB_PORT|g" \
    /home/git/gitlab/config/database.yml
  
  sed -i \
  -e "s|unix:.*$|redis://$REDIS_HOST:$REDIS_PORT|g" \
    /home/git/gitlab/config/resque.yml
  
  sed -i \
  -e "s|bin: .*$|bin: ''|g" \
  -e "s|\(# \)*host: .*$|host: $REDIS_HOST|g" \
  -e "s|\(# \)*port: .*$|port: $REDIS_PORT|g" \
  -e "s|database:|# database:|g" \
  -e "s|socket:|# socket:|g" \
  -e "s|http://localhost/|http://localhost:8080/|g" \
    /home/git/gitlab-shell/config.yml
  
  sed -i \
  -e "s|secret_key_base: .*$|secret_key_base: $GITLAB_SECRETS_SECRET_KEY_BASE|g" \
  -e "s|otp_key_base: .*$|otp_key_base: $GITLAB_SECRETS_OTP_KEY_BASE|g" \
  -e "s|db_key_base: .*$|db_key_base: $GITLAB_SECRETS_DB_KEY_BASE|g" \
    /home/git/gitlab/config/secrets.yml
  
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
mkdir -p /home/git/data/tmp
chown git:git /home/git/data/.ssh /home/git/data/repositories /home/git/data/uploads /home/git/data/builds /home/git/data/backups /home/git/data/tmp
mkdir -p /home/git/data/shared/artifacts/tmp/cache /home/git/data/shared/artifacts/tmp/uploads
mkdir -p /home/git/data/shared/lfs-objects /home/git/data/shared/pages
mkdir -p /home/git/data/shared/cache/archive
chown -R git:git /home/git/data/shared

ln -s /home/git/data/uploads /home/git/gitlab/public/uploads
rm -rf /home/git/gitlab/builds
ln -s /home/git/data/builds /home/git/gitlab/builds
ln -s /home/git/data/backups /home/git/gitlab/tmp/backups
rm -rf /home/git/gitlab/shared
ln -s /home/git/data/shared /home/git/gitlab/shared
rm -rf /home/git/gitlab/log
ln -s /var/log/gitlab /home/git/gitlab/log
chown git:git /var/log/gitlab

if [ "$GITLAB_HTTPS" == "true" ];then
  [ -e /home/git/data/gilab.crt -a -e /home/git/data/gilab.key ] || \
    { echo "ERROR: You have to prepare gitlab.crt and gitlab.key files into data/.";exit 1; }
  mkdir -p /etc/nginx/ssl
  ln -s /home/git/data/gilab.crt /etc/nginx/ssl/gilab.crt
  ln -s /home/git/data/gilab.key /etc/nginx/ssl/gilab.key
fi

[ -e /home/git/gitlab/.gitlab_shell_secret ] || \
cat /dev/urandom | tr -dc '0-9a-f' | head -c 16 > /home/git/gitlab/.gitlab_shell_secret
chown git:git /home/git/gitlab/.gitlab_shell_secret
chmod 600 /home/git/gitlab/.gitlab_shell_secret

[ -e /home/git/data/tmp/VERSION ] && diff /home/git/data/tmp/VERSION /home/git/gitlab/VERSION

cd /home/git/gitlab
env PGPASSWORD="$DB_PASS" psql -h $DB_HOST -d $DB_NAME -U $DB_USER -c \
"SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database;" \
  | grep "$DB_NAME" | grep 'kB$' \
&& { echo "yes" | sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production --trace || exit 1; } \
|| { sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production --trace || exit 1; }

cp -pf /home/git/gitlab/VERSION /home/git/data/tmp/

/usr/sbin/nginx -t || exit 1

/etc/init.d/gitlab start && /etc/init.d/gitlab status || exit 1

/usr/sbin/nginx || exit 1

set +x

while [ 0 ];do sleep 3600;done
