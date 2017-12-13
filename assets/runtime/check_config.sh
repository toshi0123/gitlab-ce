#!/bin/sh

if [ "$GITLAB_HTTPS" == "true" ];then
  [ -e /etc/gitlab/gitlab.crt -a -e /etc/gitlab/gitlab.key ] || \
    { echo "ERROR: You have to prepare gitlab.crt and gitlab.key files into config directory.";exit 1; }
  mkdir -p /etc/nginx/ssl
  ln -s /etc/gitlab/gitlab.crt /etc/nginx/ssl/gitlab.crt
  ln -s /etc/gitlab/gitlab.key /etc/nginx/ssl/gitlab.key
fi

cp -pf /home/git/gitlab/config/database.yml.postgresql /home/git/gitlab/config/database.yml.example
if [ "$GITLAB_HTTPS" == "true" ];then
  cp -pf /home/git/gitlab/lib/support/nginx/gitlab-ssl /etc/nginx/conf.d/gitlab.conf.example
else
  cp -pf /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf.example
fi

while read line;do
  diff_config $line
  link_config $line
done < /home/git/assets/runtime/config_list.txt

if [ ! -e /home/git/gitlab/.gitlab_shell_secret ];then
  cat /dev/urandom | tr -dc '0-9a-f' | head -c 16 > /home/git/gitlab/.gitlab_shell_secret
  chown git:git /home/git/gitlab/.gitlab_shell_secret
  chmod 600 /home/git/gitlab/.gitlab_shell_secret
fi

/usr/sbin/nginx -t || exit 1
