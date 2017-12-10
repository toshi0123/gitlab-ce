#!/bin/sh

mkdir -p /etc/gitlab/example
chown -R git:git /etc/gitlab/

if [ "$GITLAB_HTTPS" == "true" ];then
	cp -pf /home/git/gitlab/lib/support/nginx/gitlab-ssl /etc/nginx/conf.d/gitlab.conf
else
	cp -pf /home/git/gitlab/lib/support/nginx/gitlab /etc/nginx/conf.d/gitlab.conf
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
done < /home/git/assets/runtime/config_list.txt
