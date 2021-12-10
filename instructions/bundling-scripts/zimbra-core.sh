#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

CreateDebianPackage()
{
    DebianBegin

   (
      set -e;
      cd ${repoDir}/zm-build/${currentPackage}
      find . -type f -print0 \
         | xargs -0 md5sum \
         | grep -v -w "DEBIAN/.*" \
         | sed -e "s@ [.][/]@ @" \
         | sort \
   ) > ${repoDir}/zm-build/${currentPackage}/DEBIAN/md5sums

    export MORE_DEPENDS=", zimbra-timezone-data (>= 1.0.1+1510156506-1) $(find ${repoDir}/zm-packages/ -name \*.deb \
                         | xargs -n1 basename \
                         | sed -e 's/_[0-9].*//' \
                         | grep -e zimbra-common- \
                         | sed '1s/^/, /; :a; {N;s/\n/, /;ba}')";
    DebianFinish
}

CreateRhelPackage()
{
    MORE_DEPENDS=", zimbra-timezone-data >= 1.0.1+1510156506-1 $(find ${repoDir}/zm-packages/ -name \*.rpm \
                       | xargs -n1 basename \
                       | sed -e 's/-[0-9].*//' \
                       | grep -e zimbra-common- \
                       | sed '1s/^/, /; :a; {N;s/\n/, /;ba}')";

    cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.spec | \
    	sed -e "s/@@VERSION@@/${releaseNo}_${releaseCandidate}_${buildNo}.${os}/" \
                -e "s/@@MORE_DEPENDS@@/${MORE_DEPENDS}/" \
            	-e "/^%pre$/ r ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.pre" \
            	-e "/Best email money can buy/ a Network edition" \
            	-e "/^%post$/ r ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post" > ${repoDir}/zm-build/${currentScript}.spec
    (cd ${repoDir}/zm-build/corebuild; find opt -maxdepth 2 -type f -o -type l \
    	| sed -e 's|^|%attr(-, zimbra, zimbra) /|' >> \
    	${repoDir}/zm-build/${currentScript}.spec )
    echo "%attr(440, root, root) /etc/sudoers.d/01_zimbra" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(440, root, root) /etc/sudoers.d/02_zimbra-core" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, root, root) /opt/zimbra/bin" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/docs" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(444, zimbra, zimbra) /opt/zimbra/docs/*" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, root, root) /opt/zimbra/contrib" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, root, root) /opt/zimbra/libexec" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/logger" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/*" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf/sasl2" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/sasl2/*" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf/zmconfigd" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/zmconfigd/*" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, zimbra, zimbra) /opt/zimbra/db" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, root, root) /opt/zimbra/lib" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, zimbra, zimbra) /opt/zimbra/conf/crontabs" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, root, root) /opt/zimbra/common/lib/jylibs" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, root, root) /opt/zimbra/common/lib/perl5/Zimbra" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/logger/db/work" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "" >> ${repoDir}/zm-build/${currentScript}.spec
    echo "%clean" >> ${repoDir}/zm-build/${currentScript}.spec
    (cd ${repoDir}/zm-build/${currentPackage}; \
    	rpmbuild --target ${arch} --define '_rpmdir ../' --buildroot=${repoDir}/zm-build/${currentPackage} -bb ${repoDir}/zm-build/${currentScript}.spec )
}

#-------------------- main packaging ---------------------------

main()
{
   set -e

   Copy ${repoDir}/zm-build/rpmconf/Env/sudoers.d/01_zimbra                                         ${repoDir}/zm-build/${currentPackage}/etc/sudoers.d/01_zimbra
   Copy ${repoDir}/zm-build/rpmconf/Env/sudoers.d/02_zimbra-core                                    ${repoDir}/zm-build/${currentPackage}/etc/sudoers.d/02_zimbra-core

   Copy ${repoDir}/zm-build/lib/Zimbra/DB/DB.pm                                                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/DB/DB.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/LDAP.pm                                                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/LDAP.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/LocalConfig.pm                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/LocalConfig.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/Mon/Logger.pm                                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/Mon/Logger.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/Mon/LoggerSchema.pm                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/Mon/LoggerSchema.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/Mon/Zmstat.pm                                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/Mon/Zmstat.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/SMTP.pm                                                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/SMTP.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/SOAP/Soap.pm                                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/SOAP/Soap.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/SOAP/Soap11.pm                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/SOAP/Soap11.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/SOAP/Soap12.pm                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/SOAP/Soap12.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/SOAP/XmlDoc.pm                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/SOAP/XmlDoc.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/SOAP/XmlElement.pm                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/SOAP/XmlElement.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/Util/Common.pm                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/Util/Common.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/Util/LDAP.pm                                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/Util/LDAP.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/Util/Timezone.pm                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/Util/Timezone.pm
   Copy ${repoDir}/zm-build/lib/Zimbra/ZmClient.pm                                                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/perl5/Zimbra/ZmClient.pm

   Copy ${repoDir}/zm-build/rpmconf/Build/get_plat_tag.sh                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/get_plat_tag.sh

   Copy ${repoDir}/zm-build/rpmconf/Build/get_plat_tag.sh                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/installer/bin/get_plat_tag.sh
   Copy ${repoDir}/zm-build/rpmconf/Conf/auditswatchrc                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/auditswatchrc.in
   Copy ${repoDir}/zm-build/rpmconf/Conf/logswatchrc                                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/logswatchrc
   Copy ${repoDir}/zm-build/rpmconf/Conf/swatchrc                                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/swatchrc.in
   Copy ${repoDir}/zm-build/rpmconf/Conf/zmssl.cnf.in                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmssl.cnf.in
   Copy ${repoDir}/zm-build/rpmconf/Env/crontabs/crontab                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/crontabs/crontab
   Copy ${repoDir}/zm-build/rpmconf/Env/crontabs/crontab.ldap                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/crontabs/crontab.ldap
   Copy ${repoDir}/zm-build/rpmconf/Env/crontabs/crontab.logger                                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/crontabs/crontab.logger
   Copy ${repoDir}/zm-build/rpmconf/Env/crontabs/crontab.mta                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/crontabs/crontab.mta
   Copy ${repoDir}/zm-build/rpmconf/Env/crontabs/crontab.store                                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/crontabs/crontab.store
   Copy ${repoDir}/zm-build/rpmconf/Env/zimbra.bash_profile                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/.bash_profile
   Copy ${repoDir}/zm-build/rpmconf/Env/zimbra.bashrc                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/.bashrc
   Copy ${repoDir}/zm-build/rpmconf/Env/zimbra.exrc                                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/.exrc
   Copy ${repoDir}/zm-build/rpmconf/Env/zimbra.ldaprc                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/.ldaprc
   Copy ${repoDir}/zm-build/rpmconf/Env/zimbra.platform                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/.platform
   Copy ${repoDir}/zm-build/rpmconf/Env/zimbra.viminfo                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/.viminfo
   Copy ${repoDir}/zm-build/rpmconf/Img/connection_failed.gif                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/logger/db/work/connection_failed.gif
   Copy ${repoDir}/zm-build/rpmconf/Img/data_not_available.gif                                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/logger/db/work/data_not_available.gif
   Copy ${repoDir}/zm-build/rpmconf/Install/Util/addUser.sh                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/addUser.sh
   Copy ${repoDir}/zm-build/rpmconf/Install/Util/addUser.sh                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/installer/util/addUser.sh
   Copy ${repoDir}/zm-build/rpmconf/Install/Util/globals.sh                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/installer/util/globals.sh
   Copy ${repoDir}/zm-build/rpmconf/Install/Util/modules/getconfig.sh                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/installer/util/modules/getconfig.sh
   Copy ${repoDir}/zm-build/rpmconf/Install/Util/modules/packages.sh                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/installer/util/modules/packages.sh
   Copy ${repoDir}/zm-build/rpmconf/Install/Util/modules/install_rabbitmq.sh                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/installer/util/modules/install_rabbitmq.sh
   Copy ${repoDir}/zm-build/rpmconf/Install/Util/modules/postinstall.sh                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/installer/util/modules/postinstall.sh
   Copy ${repoDir}/zm-build/rpmconf/Install/Util/utilfunc.sh                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/installer/util/utilfunc.sh
   Copy ${repoDir}/zm-build/rpmconf/Install/install.sh                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/installer/install.sh
   Copy ${repoDir}/zm-build/rpmconf/Install/postinstall.pm                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/postinstall.pm
   Copy ${repoDir}/zm-build/rpmconf/Install/preinstall.pm                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/preinstall.pm
   Copy ${repoDir}/zm-build/rpmconf/Install/zmsetup.pl                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmsetup.pl
   Copy ${repoDir}/zm-build/rpmconf/Upgrade/zmupgrade.pm                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmupgrade.pm

   Cpy2 ${repoDir}/junixsocket/junixsocket-native/build/junixsocket-native-*.nar                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/
   Cpy2 ${repoDir}/junixsocket/junixsocket-native/build/libjunixsocket-native-*.so                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/

   CreatePackage "${os}"
}

############################################################################
main "$@"
