#!/bin/bash
#
# Copyright (c) 2013 Joyent Inc. All rights reserved.
#

# set -o errexit
# set -o pipefail

export PS4='[\D{%FT%TZ}] ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -o xtrace

echo "Performing setup of assets zone"

# This includes the fatal function and downloads and installs files.
source /opt/smartdc/sdc-boot/scripts/setup.common

# Cookie to identify this as a SmartDC zone and its role
mkdir -p /var/smartdc/assets

nginx_manifest="/opt/local/share/smf/nginx/manifest.xml"
# HEAD-1507 clean up tarball branch.
[[ -z ${NO_FS_TARBALL} ]] \
  && nginx_manifest="/opt/local/share/smf/manifest/nginx.xml"

# Import nginx (config is already setup by configure above)
if [[ -z $(/usr/bin/svcs -a | grep nginx) ]]; then
  echo "Importing nginx service"
  /usr/sbin/svccfg import ${nginx_manifest}
  /usr/sbin/svcadm enable -s nginx
elif [[ -z $(/usr/bin/svcs -a | grep online.*nginx) ]]; then
  # have manifest, but not enabled, do that now
  echo "Enabling nginx service"
  /usr/sbin/svcadm disable -s nginx
  /usr/sbin/svcadm enable -s nginx
else
  fatal "Can't start nginx service in assets."
fi

touch /var/svc/setup_complete
echo "setup done"
(sleep 5; cp /var/svc/setup.log /var/svc/setup_init.log) &

exit 0
