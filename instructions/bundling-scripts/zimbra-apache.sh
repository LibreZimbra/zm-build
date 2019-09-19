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

# Shell script to create zimbra apache package


#-------------------- Configuration ---------------------------

    currentScript=`basename $0 | cut -d "." -f 1`                          # zimbra-apache
    currentPackage=`echo ${currentScript}build | cut -d "-" -f 2` # apachebuild


#-------------------- Build Package ---------------------------

main()
{
    log 1 "Copy package files"
    install_conf_from zm-aspell/conf \
        httpd.conf php.ini

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
        mkrpm_template
        echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf"
        echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/*"
        echo ""
        echo "%clean"
    ) | mkdeb_writespec
}

############################################################################
main "$@"
