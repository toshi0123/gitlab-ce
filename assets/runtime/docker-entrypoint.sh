#!/bin/sh

set -x

# Show versions
[ -e /home/git/data/tmp/VERSION ] && diff /home/git/data/tmp/VERSION /home/git/gitlab/VERSION

# Load functions
. /home/git/assets/runtime/functions.sh

# Set default value of environment
. /home/git/assets/runtime/env_values.sh

# Test values of Postgresql
env PGPASSWORD="$DB_PASS" psql -h $DB_HOST -d $DB_NAME -U $DB_USER -c \
"SELECT true AS enabled FROM pg_available_extensions WHERE name = 'pg_trgm' AND installed_version IS NOT NULL;" || exit 1

# Initialize on first run
if [ ! -e /etc/gitlab/gitlab.yml ];then
  . /home/git/assets/runtime/prepare_config.sh
fi

# Prepare directories
. /home/git/assets/runtime/prepare_dirs.sh

# Check for updated config and make link file for it
. /home/git/assets/runtime/check_config.sh

# Initialize or migrate db
. /home/git/assets/runtime/prepare_database.sh

# Ready to run gitlab
cp -pf /home/git/gitlab/VERSION /home/git/data/tmp/

# Run gitlab
/etc/init.d/gitlab start && /etc/init.d/gitlab status || exit 1

/usr/sbin/nginx || exit 1

/usr/sbin/crond -L /var/log/crond.log

# Wait for trap
set +x

trap 'pkill nginx;/etc/init.d/gitlab stop;pkill crond;exit 0' 15

while [ 0 ]
do
  sleep 365d &
  wait
  pkill sleep
done
