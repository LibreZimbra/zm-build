#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

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
