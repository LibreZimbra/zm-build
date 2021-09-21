#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#-------------------- Configuration ---------------------------

    currentScript=`basename $0 | cut -d "." -f 1`                          # zimbra-spell
    currentPackage=`echo ${currentScript}build | cut -d "-" -f 2` # spellbuild


#-------------------- Build Package ---------------------------
main()
{
    Log "Create package directories"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/data/httpd/htdocs

    Log "Copy package files"
    cp ${repoDir}/zm-aspell/src/php/aspell.php ${repoDir}/zm-build/${currentPackage}/opt/zimbra/data/httpd/htdocs/aspell.php

    CreatePackage "${os}"
}

#-------------------- Util Functions ---------------------------

CreateDebianPackage()
{
    mkdir -p ${repoDir}/zm-build/${currentPackage}/DEBIAN
    cat ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post >> ${repoDir}/zm-build/${currentPackage}/DEBIAN/postinst
    chmod 555 ${repoDir}/zm-build/${currentPackage}/DEBIAN/*

    Log "Create debian package"
    (cd ${repoDir}/zm-build/${currentPackage}; find . -type f ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -print0 | xargs -0 md5sum | sed -e 's| \./| |' \
        > ${repoDir}/zm-build/${currentPackage}/DEBIAN/md5sums)
    DebianFinish
}

CreateRhelPackage()
{
    cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.spec | \
    	sed -e "s/@@VERSION@@/${releaseNo}_${releaseCandidate}_${buildNo}.${os}/" \
    	-e "s/^Copyright:/Copyright:/" \
    	> ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, root, root) /opt/zimbra/data/httpd/htdocs/aspell.php" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "" >> ${repoDir}/zm-build/${currentScript}.spec
    echo "%clean" >> ${repoDir}/zm-build/${currentScript}.spec
    (cd ${repoDir}/zm-build/${currentPackage}; \
    	rpmbuild --target ${arch} --define '_rpmdir ../' --buildroot=${repoDir}/zm-build/${currentPackage} -bb ${repoDir}/zm-build/${currentScript}.spec )
}

############################################################################
main "$@"