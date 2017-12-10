#!/bin/sh

cd /home/git/gitlab

env PGPASSWORD="$DB_PASS" psql -h $DB_HOST -d $DB_NAME -U $DB_USER -c \
"SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database;" \
  | grep "$DB_NAME" | grep 'kB$' \
&& { echo "yes" | sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production --trace || exit 1; } \
|| { sudo -u git -H bundle exec rake db:migrate RAILS_ENV=production --trace || exit 1; }
