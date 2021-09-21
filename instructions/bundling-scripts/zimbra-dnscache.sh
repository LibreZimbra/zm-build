#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#-------------------- Configuration ---------------------------

    currentScript=`basename $0 | cut -d "." -f 1`                          # zimbra-dnscache
    currentPackage=`echo ${currentScript}build | cut -d "-" -f 2` # dnscachebuild


#-------------------- Build Package ---------------------------
main()
{
    PkgImageDirs /etc/sudoers.d /opt/zimbra/data/dns/ca /opt/zimbra/data/dns/trust
    CreatePackage "${os}"
}

#-------------------- Util Functions ---------------------------

CreateDebianPackage()
{
    DebianBegin

    PkgImageDirs /etc/resolvconf/update.d
    cp ${repoDir}/zm-dnscache/conf/dns/zimbra-unbound ${repoDir}/zm-build/${currentPackage}/etc/resolvconf/update.d
    cp ${repoDir}/zm-build/rpmconf/Env/sudoers.d/02_${currentScript}.deb ${repoDir}/zm-build/${currentPackage}/etc/sudoers.d/02_${currentScript}

    Log "Create debian package"
    (cd ${repoDir}/zm-build/${currentPackage}; find . -type f ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -print0 | xargs -0 md5sum | sed -e 's| \./| |' \
        > ${repoDir}/zm-build/${currentPackage}/DEBIAN/md5sums)
    DebianFinish
}

CreateRhelPackage()
{
    cp ${repoDir}/zm-build/rpmconf/Env/sudoers.d/02_${currentScript}.rpm ${repoDir}/zm-build/${currentPackage}/etc/sudoers.d/02_${currentScript}

    cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.spec | \
        sed -e "s/@@VERSION@@/${releaseNo}_${releaseCandidate}_${buildNo}.${os}/" \
            -e "s/^Copyright:/Copyright:/" \
            -e "/^%post$/ r ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post" > ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, zimbra, zimbra) /opt/zimbra/data/dns" >> \
        ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(440, root, root) /etc/sudoers.d/02_zimbra-dnscache" >> \
        ${repoDir}/zm-build/${currentScript}.spec
    (cd ${repoDir}/zm-build/${currentPackage}; \
        rpmbuild --target ${arch} --define '_rpmdir ../' --buildroot=${repoDir}/zm-build/${currentPackage} -bb ${repoDir}/zm-build/${currentScript}.spec )
}

############################################################################
main "$@"