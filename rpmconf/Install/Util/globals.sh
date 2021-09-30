#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

LOGFILE=`mktemp -t install.log.XXXXXXXX 2> /dev/null` || { echo "Failed to create tmpfile"; exit 1; }
PLATFORM=`bin/get_plat_tag.sh`

CORE_PACKAGES="zimbra-core"

PACKAGES="zimbra-ldap \
zimbra-logger \
zimbra-mta \
zimbra-dnscache \
zimbra-snmp \
zimbra-store \
zimbra-spell \
zimbra-memcached \
zimbra-proxy \
zimbra-onlyoffice"

SERVICES=""

MYDIR="$(CDPATH= cd "$(dirname "$0")" && pwd)"

PACKAGE_DIR="$(CDPATH= cd "$(dirname "$0")" && pwd)/packages"

SAVEDIR="/opt/zimbra/.saveconfig"

if [ x$RESTORECONFIG = "x" ]; then
	RESTORECONFIG=$SAVEDIR
fi

#
# Initial values
#

AUTOINSTALL="no"
INSTALLED="no"
INSTALLED_PACKAGES=""
REMOVE="no"
UPGRADE="no"
HOSTNAME=`hostname --fqdn`
ZIMBRAINTERNAL=no
echo $HOSTNAME | egrep -qe 'eng.synacor.com$|eng.zimbra.com$|lab.zimbra.com$' > /dev/null 2>&1
if [ $? = 0 ]; then
  ZIMBRAINTERNAL=yes
fi

LDAPHOST=""
LDAPPORT=389
fq=`isFQDN $HOSTNAME`

if [ $fq = 0 ]; then
	HOSTNAME=""
fi

SERVICEIP=`hostname -i`

SMTPHOST=$HOSTNAME
SNMPTRAPHOST=$HOSTNAME
SMTPSOURCE="none"
SMTPDEST="none"
SNMPNOTIFY="0"
SMTPNOTIFY="0"
INSTALL_PACKAGES="zimbra-core"
STARTSERVERS="yes"
LDAPROOTPW=""
LDAPZIMBRAPW=""
LDAPPOSTPW=""
LDAPREPPW=""
LDAPAMAVISPW=""
LDAPNGINXPW=""
if [ x"$ZIMBRAINTERNAL" = "xno" ]; then
  CREATEDOMAIN=$(hostname -d) # May be empty
  CREATEDOMAIN=${CREATEDOMAIN:-$HOSTNAME} # only go with fqdn if domain is empty
else
  CREATEDOMAIN=$HOSTNAME
fi

CREATEADMIN="admin@${CREATEDOMAIN}"
CREATEADMINPASS=""
MODE="http"
ALLOWSELFSIGNED="yes"
RUNAV=""
RUNSA=""
AVUSER=""
AVDOMAIN=""
