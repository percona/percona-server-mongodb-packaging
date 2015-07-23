#!/bin/bash
#
PATH="${PATH}:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
#
touch /var/run/mongod.pid
chown mongod:mongod /var/run/mongod.pid
#
if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]; then
   echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
#
if [ -f /sys/kernel/mm/transparent_hugepage/defrag ]; then
	echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi
#
