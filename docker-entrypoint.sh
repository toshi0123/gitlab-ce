#!/bin/sh

prepare_config(){
  [ -e $1 ] || exit 1
  local basename=`basename $1`
  cp -pf $1.example /home/git/data/config/example
  sudo -u git -H mv $1 /home/git/data/config/
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
  
  prepare_config /home/git/gitlab/config/gitlab.yml
  cp -pf /home/git/gitlab/config/database.yml.postgresql /home/git/gitlab/config/database.yml.example
  prepare_config /home/git/gitlab/config/database.yml
  prepare_config /home/git/gitlab/config/resque.yml
  prepare_config /home/git/gitlab/config/secrets.yml
  prepare_config /home/git/gitlab/config/unicorn.rb
  prepare_config /home/git/gitlab/config/initializers/rack_attack.rb
  prepare_config /home/git/gitaly/config.toml
  prepare_config /home/git/gitlab-shell/config.yml
  cp -pf /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf.example
  prepare_config /etc/nginx/conf.d/gitlab.conf
fi

diff_config /home/git/gitlab/config/gitlab.yml
cp -pf /home/git/gitlab/config/database.yml.postgresql /home/git/gitlab/config/database.yml.example
diff_config /home/git/gitlab/config/database.yml
diff_config /home/git/gitlab/config/resque.yml
diff_config /home/git/gitlab/config/secrets.yml
diff_config /home/git/gitlab/config/unicorn.rb
diff_config /home/git/gitlab/config/initializers/rack_attack.rb
diff_config /home/git/gitaly/config.toml
diff_config /home/git/gitlab-shell/config.yml
cp -pf /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf.example
diff_config /etc/nginx/conf.d/gitlab.conf

if [ -e /home/git/data/config/VERSION ];then
  cd /home/git/gitlab
  sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production --trace
fi

cp -pf /home/git/gitlab/VERSION /home/git/data/config/

/etc/init.d/gitlab start
/usr/sbin/nginx

while [ 0 ];do sleep 3600;done
