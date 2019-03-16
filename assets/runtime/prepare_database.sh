#!/bin/sh

cd /home/git/gitlab

env PGPASSWORD="$DB_PASS" psql -h $DB_HOST -d $DB_NAME -U $DB_USER -c \
"\dt" 2>&1 | grep '^Did not find any relations.' \
&& { 
 sudo -u git -H gitaly /etc/gitlab/config.toml >> /var/log/gitlab/gitaly.log 2>&1 &
 sleep 10
 echo "yes" | sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production --trace || exit 1
 pkill gitaly
} || { 
 sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production --trace || exit 1; 
}
