#!/bin/bash

UP="/app/config/up.sh"

if [ -d /app/config ]
then
	files=($(find /app/config -type f))

	for source in "${files[@]}"
	do
		pattern="\.DS_Store"
		target=${source/\/app\/config/\/etc\/mysql}

		if [[ ! $target =~ $pattern ]]; then
			if [[ -f $target ]]; then
				echo "    Removing \"$target\"" && rm -rf $target
			fi

			echo "    Linking \"$source\" to \"$target\"" && mkdir -p $(dirname "${target}") && ln -s $source $target
		fi
	done
fi

mkdir -p /app/data/logs
mkdir -p /app/data/database
mkdir -p /app/config

if [[ ! -f /app/data/database/dump.sql ]]; then
	echo "    Initializing new database"
	
	/usr/bin/mysql_install_db > /dev/null 2>&1
	/usr/bin/mysqld_safe --skip-syslog --skip-networking > /dev/null 2>&1 &

	RET=1
	while [[ RET -ne 0 ]]; do
		sleep 1
		/usr/bin/mysql -uroot -e "status" > /dev/null 2>&1
		RET=$?
	done
	
	/usr/bin/mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'fyoDBafo'"
	/usr/bin/mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
	/usr/bin/mysqldump -uroot --hex-blob --routines --triggers --skip-lock-tables --all-databases > /app/data/database/dump.sql
	/usr/bin/mysqladmin -uroot shutdown
	
	echo "    successfully initialized new database"
else
	echo "    Importing existing database"
	
	/usr/bin/mysqld_safe --skip-syslog --skip-networking > /dev/null 2>&1 &
	
	RET=1
	while [[ RET -ne 0 ]]; do
		sleep 1
		/usr/bin/mysql -uroot -e "status" > /dev/null 2>&1
		RET=$?
	done
	
	/usr/bin/mysql -uroot < /app/data/database/dump.sql
	/usr/bin/mysqladmin -uroot shutdown
	
	echo "    successfully imported existing database"
fi

if [ -f $UP ]
then
	echo "    Running startup script /app/config/up.sh"
	chmod +x $UP && chmod 755 $UP && eval $UP;
fi

# Tweaks to give MySQL write permissions to the app
# chown -R mysql:staff /var/lib/mysql
# chown -R mysql:staff /var/run/mysqld
# chmod -R 770 /var/lib/mysql
# chmod -R 770 /var/run/mysqld