#!/bin/bash
#
# ***** BEGIN LICENSE BLOCK *****
# Zimbra Collaboration Suite Server
# Copyright (C) 2009, 2010, 2011, 2013, 2014, 2015, 2016 Synacor, Inc.
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software Foundation,
# version 2 of the License.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program.
# If not, see <https://www.gnu.org/licenses/>.
# ***** END LICENSE BLOCK *****

# Shell script to create zimbra ldap package


#-------------------- Configuration ---------------------------

    currentScript=`basename $0 | cut -d "." -f 1`                          # zimbra-ldap
    currentPackage=`echo ${currentScript}build | cut -d "-" -f 2` # ldapbuild

#-------------------- Build Package ---------------------------
main()
{
    log 1 "Copy package files"
    install_subtree zm-ldap-utilities/build/dist opt/zimbra/common/etc/openldap/zimbra

    if [ "${buildType}" == "NETWORK" ]
    then
        install_file zm-convertd-native/conf/ldap/zimbra_mimehandlers.ldif \
                     opt/zimbra/common/etc/openldap/zimbra/convertd_mimehandlers.ldif
    fi

    install_file zm-build/rpmconf/Env/sudoers.d/02_${currentScript} etc/sudoers.d/

    CreatePackage "${os}"
}

#-------------------- Util Functions ---------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

CreateDebianPackage()
{
    mkdeb_gen_control
}

CreateRhelPackage()
{
    (
        mkrpm_template | sed \
            -e "/^%post$/ r ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post"
        echo "%attr(440, root, root) /etc/sudoers.d/02_zimbra-ldap"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra/*"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra/config"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra/config/*"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra/config/cn=config"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra/config/cn=config/*"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra/config/cn=config/olcDatabase={2}mdb"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra/config/cn=config/olcDatabase={2}mdb/*"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra/schema"
        echo "%attr(-, root, root) /opt/zimbra/common/etc/openldap/zimbra/schema/*"
        echo ""
        echo "%clean"
    ) | mkrpm_writespec
}

############################################################################
main "$@"
