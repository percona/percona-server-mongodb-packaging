#!/bin/bash
#
PATH="${PATH}:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
#
touch /var/run/mongod.pid
chown mongod:mongod /var/run/mongod.pid
#
KTHP=/sys/kernel/mm/transparent_hugepage
#
[ -z "${CONF}" ] && CONF=/etc/mongod.conf

print_error(){
  echo " * Error disabling Transparent Huge pages, exiting"
  exit 1
}

# checking if PerconaFT is used looking at defaults file and daemon config
storageEngine=$( (egrep -o '^[[:blank:]]?storageEngine.*PerconaFT' ${CONF} || echo "${OPTIONS}" | egrep -o 'storageEngine.*PerconaFT' ) | tr -d '[[:blank:]]' | awk -F'=' '{print $NF}' 2>/dev/null)

# trying to disable THP only if PerconaFT engine is enabled
if [ "${storageEngine}" = PerconaFT ]; then
  fgrep '[always]' ${KTHP}/enabled  2> /dev/null && (echo never > ${KTHP}/enabled 2> /dev/null || print_error)
  fgrep '[always]' ${KTHP}/defrag 2> /dev/null && (echo never > ${KTHP}/defrag 2> /dev/null || print_error)
fi