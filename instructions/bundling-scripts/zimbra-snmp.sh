#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

#-------------------- Configuration ---------------------------

    currentScript=`basename $0 | cut -d "." -f 1`                          # zimbra-snmp
    currentPackage=`echo ${currentScript}build | cut -d "-" -f 2` # snmpbuild


#-------------------- Build Package ---------------------------
main()
{
    Log "Create package directories"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/data/snmp/persist
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/data/snmp/state
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/conf
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/share/snmp/mibs

    Log "Copy package files"
    cp ${repoDir}/zm-build/rpmconf/Conf/snmp.conf ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/conf/snmp.conf
    cp ${repoDir}/zm-build/rpmconf/Conf/snmpd.conf.in ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/snmpd.conf.in
    cp ${repoDir}/zm-build/rpmconf/Conf/snmp.conf ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/share/snmp/snmp.conf
    cp ${repoDir}/zm-build/rpmconf/Conf/mibs/*mib ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/share/snmp/mibs

    CreatePackage "${os}"
}

#-------------------- Util Functions ---------------------------


CreateDebianPackage()
{
    mkdir -p ${repoDir}/zm-build/${currentPackage}/DEBIAN
    cat ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post >> ${repoDir}/zm-build/${currentPackage}/DEBIAN/postinst
    chmod 555 ${repoDir}/zm-build/${currentPackage}/DEBIAN/*

    Log "Create debian package"
    (cd ${repoDir}/zm-build/${currentPackage}; find . -type f ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -print0 | xargs -0 md5sum | sed -e 's| \./| |' \
        > ${repoDir}/zm-build/${currentPackage}/DEBIAN/md5sums)
    DebianFinish
}

CreateRhelPackage()
{
    cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.spec | \
    	sed -e "s/@@VERSION@@/${releaseNo}_${releaseCandidate}_${buildNo}.${os}/" \
    	-e "s/^Copyright:/Copyright:/" \
    	> ${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/data/snmp" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/*" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(775, root, zimbra) /opt/zimbra/common/conf" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, root, root) /opt/zimbra/common/conf/snmp.conf" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, root, root) /opt/zimbra/common/share/snmp" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, root, root) /opt/zimbra/common/share/snmp/snmp.conf" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, root, root) /opt/zimbra/common/share/snmp/mibs" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, root, root) /opt/zimbra/common/share/snmp/mibs/zimbra.mib" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, root, root) /opt/zimbra/common/share/snmp/mibs/zimbra_traps.mib" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "" >> ${repoDir}/zm-build/${currentScript}.spec
    echo "%clean" >> ${repoDir}/zm-build/${currentScript}.spec
    (cd ${repoDir}/zm-build/${currentPackage}; \
    	rpmbuild --target ${arch} --define '_rpmdir ../' --buildroot=${repoDir}/zm-build/${currentPackage} -bb ${repoDir}/zm-build/${currentScript}.spec )

}


############################################################################
main "$@"
