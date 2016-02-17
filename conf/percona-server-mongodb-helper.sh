#!/bin/bash
#
PATH="${PATH}:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
#
touch /var/run/mongod.pid
touch /var/log/@@LOGDIR@@/mongod.{stdout,stderr}
chown mongod:mongod /var/run/mongod.pid
chown -R mongod:mongod /var/log/@@LOGDIR@@
#
KTHP=/sys/kernel/mm/transparent_hugepage
#
[ -z "${CONF}" ] && CONF=/etc/mongod.conf
#
print_error(){
  echo " * Error disabling Transparent Huge pages, exiting"
  exit 1
}
#
. /etc/@@LOCATION@@/mongod
#
# checking if PerconaFT is used looking at defaults file and daemon config
defaults=$(echo "${OPTIONS}" | egrep -o 'storageEngine.*PerconaFT' | tr -d '[[:blank:]]' | awk -F'=' '{print $NF}' 2>/dev/null)
config=$(egrep -o '^[[:blank:]]+engine.*PerconaFT' ${CONF} | tr -d '[[:blank:]]' | awk -F':' '{print $NF}' 2>/dev/null)
#
if [ -z "${defaults}" ] && [ -z "${config}" ]; then # nothing to do
  exit 0
fi
#
if [ -n "${defaults}" ] && [ -n "${config}" ]; then # engine is set in 2 places
  if [ "${defaults}" ==  "${config}" ]; then # it's OK
    echo " * Warning, engine is set both in defaults file and mongod.conf!"
  else
    echo " * Error, different engines are set in the same time!"
    exit 1
  fi
fi
#
if [ -n "${defaults}" ]; then
  storageEngine=${defaults}
else
  storageEngine=${config}
fi
# trying to disable THP only if PerconaFT engine is enabled and THP is set to always
if [ "${storageEngine}" = PerconaFT ]; then
  fgrep '[always]' ${KTHP}/enabled  > /dev/null 2>&1 && (echo never > ${KTHP}/enabled 2> /dev/null || print_error) || true
  fgrep '[always]' ${KTHP}/defrag   > /dev/null 2>&1 && (echo never > ${KTHP}/defrag  2> /dev/null || print_error) || true
fi
