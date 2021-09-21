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
    Log "Create package directories"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf

    Log "Copy package files"
    cp ${repoDir}/zm-aspell/conf/httpd.conf ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/httpd.conf
    cp ${repoDir}/zm-aspell/conf/php.ini ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/php.ini

    CreatePackage "${os}"
}

#-------------------- Util Functions ---------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

CreateDebianPackage()
{
    Log "Create debian package"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/DEBIAN
    (cd ${repoDir}/zm-build/${currentPackage}; find . -type f ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -print0 | xargs -0 md5sum | sed -e 's| \./| |' \
        > ${repoDir}/zm-build/${currentPackage}/DEBIAN/md5sums)
    DebianFinish
}

CreateRhelPackage()
{
  cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.spec | \
  sed -e "s/@@VERSION@@/${releaseNo}_${releaseCandidate}_${buildNo}.${os} /" \
      -e "s/^Copyright:/Copyright:/" > ${repoDir}/zm-build/${currentScript}.spec
  echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf" >> ${repoDir}/zm-build/${currentScript}.spec
  echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/*" >> ${repoDir}/zm-build/${currentScript}.spec
  echo "" >> ${repoDir}/zm-build/${currentScript}.spec
  echo "%clean" >> ${repoDir}/zm-build/${currentScript}.spec
  (cd ${repoDir}/zm-build/${currentPackage}; \
  rpmbuild --target ${arch} --define '_rpmdir ../' --buildroot=${repoDir}/zm-build/${currentPackage} -bb ${repoDir}/zm-build/${currentScript}.spec )
}

############################################################################
main "$@"
