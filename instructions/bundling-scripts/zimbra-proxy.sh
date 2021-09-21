#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#-------------------- Configuration ---------------------------

    currentScript=`basename $0 | cut -d "." -f 1`                          # zimbra-proxy
    currentPackage=`echo ${currentScript}build | cut -d "-" -f 2` # proxybuild

#-------------------- Build Package ---------------------------
main()
{
    Log "Create package directories"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/etc/sudoers.d
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/nginx/includes
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/nginx/templates

    Log "Copy package files"
    cp ${repoDir}/zm-build/rpmconf/Env/sudoers.d/02_${currentScript} ${repoDir}/zm-build/${currentPackage}/etc/sudoers.d/02_${currentScript}
    cp ${repoDir}/zm-nginx-conf/conf/nginx/* ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/nginx/templates/

    CreatePackage "${os}"
}

#-------------------- Util Functions ---------------------------

CreateDebianPackage()
{
    mkdir -p ${repoDir}/zm-build/${currentPackage}/DEBIAN
    cat ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post >> ${repoDir}/zm-build/${currentPackage}/DEBIAN/postinst
    chmod 555 ${repoDir}/zm-build/${currentPackage}/DEBIAN/*

    Log "Create debian package"
    (cd ${repoDir}/zm-build/${currentPackage}; find . -type f ! -regex ".*?debian-binary.*" ! -regex ".*?DEBIAN.*" -print0 | xargs -0 md5sum | sed -e "s| \./| |" \
        > ${repoDir}/zm-build/${currentPackage}/DEBIAN/md5sums)
    DebianFinish
}

CreateRhelPackage()
{
    cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.spec | \
        sed -e "s/@@VERSION@@/${releaseNo}_${releaseCandidate}_${buildNo}.${os}/" \
               -e "s/^Copyright:/Copyright:/" \
               -e "/^%post$/ r ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post" > ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(440, root, root) /etc/sudoers.d/02_zimbra-proxy" >> \
        ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf/nginx" >> \
        ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/nginx/*" >> \
        ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf/nginx/includes" >> \
        ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf/nginx/templates" >> \
        ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/nginx/templates/*" >> \
        ${repoDir}/zm-build/${currentScript}.spec
    echo "" >> ${repoDir}/zm-build/${currentScript}.spec
    echo "%clean" >> ${repoDir}/zm-build/${currentScript}.spec
    (cd ${repoDir}/zm-build/${currentPackage}; \
    rpmbuild --target ${arch} --define '_rpmdir ../' --buildroot=${repoDir}/zm-build/${currentPackage} -bb ${repoDir}/zm-build/${currentScript}.spec )
}

############################################################################
main "$@"