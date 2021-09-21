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
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf/externaldirsync" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/externaldirsync/*" >> \
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

   Copy ${repoDir}/zm-amavis/conf/amavisd.conf.in                                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/amavisd.conf.in
   Copy ${repoDir}/zm-amavis/conf/amavisd/amavisd-custom.conf                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/amavisd-custom.conf
   Copy ${repoDir}/zm-amavis/conf/dspam.conf.in                                                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/dspam.conf.in

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

    PkgImageBinCmds ${repoDir}/zm-core-utils/src/bin \
        antispam-mysql \
        antispam-mysql.server \
        antispam-mysqladmin \
        ldap.production \
        mysql \
        mysql.server \
        mysqladmin \
        postconf \
        postfix \
        qshape \
        zmaccts \
        zmamavisdctl \
        zmantispamctl \
        zmantispamdbpasswd \
        zmantivirusctl \
        zmapachectl \
        zmarchivectl \
        zmauditswatchctl \
        zmblobchk \
        zmcaldebug \
        zmcbpadmin \
        zmcbpolicydctl \
        zmcertmgr \
        zmclamdctl \
        zmconfigdctl \
        zmcontactbackup \
        zmcontrol \
        zmdedupe \
        zmdhparam \
        zmdnscachectl \
        zmdumpenv \
        zmfixcalendtime \
        zmfixcalprio \
        zmfreshclamctl \
        zmgsautil \
        zmhostname \
        zminnotop \
        zmitemdatafile \
        zmjava \
        zmjavaext \
        zmldappasswd \
        zmldapupgrade \
        zmlmtpinject \
        zmlocalconfig \
        zmloggerctl \
        zmloggerhostmap \
        zmlogswatchctl \
        zmmailbox \
        zmmailboxdctl \
        zmmemcachedctl \
        zmmetadump \
        zmmigrateattrs \
        zmmilterctl \
        zmmtactl \
        zmmypasswd \
        zmmysqlstatus \
        zmmytop \
        zmopendkimctl \
        zmplayredo \
        zmprov \
        zmproxyconf \
        zmproxyctl \
        zmpython \
        zmredodump \
        zmresolverctl \
        zmsaslauthdctl \
        zmshutil \
        zmskindeploy \
        zmsoap \
        zmspellctl \
        zmsshkeygen \
        zmstat-chart \
        zmstat-chart-config \
        zmstatctl \
        zmstorectl \
        zmswatchctl \
        zmthrdump \
        zmtlsctl \
        zmtotp \
        zmtrainsa \
        zmtzupdate \
        zmupdateauthkeys \
        zmvolume \
        zmzimletctl \
        zmonlyofficectl

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

   Copy ${repoDir}/zm-core-utils/conf/dhparam.pem.zcs                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/dhparam.pem.zcs
   Copy ${repoDir}/zm-core-utils/conf/zmlogrotate                                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmlogrotate
   Copy ${repoDir}/zm-core-utils/src/contrib/zmfetchercfg                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/contrib/zmfetchercfg
   Copy ${repoDir}/zm-core-utils/src/libexec/600.zimbra                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/600.zimbra
   Copy ${repoDir}/zm-core-utils/src/libexec/client_usage_report.py                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/client_usage_report.py
   Copy ${repoDir}/zm-core-utils/src/libexec/configrewrite                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/configrewrite
   Copy ${repoDir}/zm-core-utils/src/libexec/icalmig                                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/icalmig
   Copy ${repoDir}/zm-core-utils/src/libexec/libreoffice-installer.sh                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/libreoffice-installer.sh
   Copy ${repoDir}/zm-core-utils/src/libexec/zcs                                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zcs
   Copy ${repoDir}/zm-core-utils/src/libexec/zimbra                                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zimbra
   Copy ${repoDir}/zm-core-utils/src/libexec/zmaltermimeconfig                                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmaltermimeconfig
   Copy ${repoDir}/zm-core-utils/src/libexec/zmantispamdbinit                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmantispamdbinit
   Copy ${repoDir}/zm-core-utils/src/libexec/zmantispammycnf                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmantispammycnf
   Copy ${repoDir}/zm-core-utils/src/libexec/zmcbpolicydinit                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmcbpolicydinit
   Copy ${repoDir}/zm-core-utils/src/libexec/zmcheckduplicatemysqld                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmcheckduplicatemysqld
   Copy ${repoDir}/zm-core-utils/src/libexec/zmcheckexpiredcerts                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmcheckexpiredcerts
   Copy ${repoDir}/zm-core-utils/src/libexec/zmcleantmp                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmcleantmp
   Copy ${repoDir}/zm-core-utils/src/libexec/zmclientcertmgr                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmclientcertmgr
   Copy ${repoDir}/zm-core-utils/src/libexec/zmcompresslogs                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmcompresslogs
   Copy ${repoDir}/zm-core-utils/src/libexec/zmcomputequotausage                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmcomputequotausage
   Copy ${repoDir}/zm-core-utils/src/libexec/zmconfigd                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmconfigd
   Copy ${repoDir}/zm-core-utils/src/libexec/zmcpustat                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmcpustat
   Copy ${repoDir}/zm-core-utils/src/libexec/zmdailyreport                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmdailyreport
   Copy ${repoDir}/zm-core-utils/src/libexec/zmdbintegrityreport                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmdbintegrityreport
   Copy ${repoDir}/zm-core-utils/src/libexec/zmdiaglog                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmdiaglog
   Copy ${repoDir}/zm-core-utils/src/libexec/zmdkimkeyutil                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmdkimkeyutil
   Copy ${repoDir}/zm-core-utils/src/libexec/zmdnscachealign                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmdnscachealign
   Copy ${repoDir}/zm-core-utils/src/libexec/zmdomaincertmgr                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmdomaincertmgr
   Copy ${repoDir}/zm-core-utils/src/libexec/zmexplainslow                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmexplainslow
   Copy ${repoDir}/zm-core-utils/src/libexec/zmexplainsql                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmexplainsql
   Copy ${repoDir}/zm-core-utils/src/libexec/zmextractsql                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmextractsql
   Copy ${repoDir}/zm-core-utils/src/libexec/zmfixperms                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmfixperms
   Copy ${repoDir}/zm-core-utils/src/libexec/zmfixreminder                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmfixreminder
   Copy ${repoDir}/zm-core-utils/src/libexec/zmgenentitlement                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmgenentitlement
   Copy ${repoDir}/zm-core-utils/src/libexec/zmgsaupdate                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmgsaupdate
   Copy ${repoDir}/zm-core-utils/src/libexec/zmhspreport                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmhspreport
   Copy ${repoDir}/zm-core-utils/src/libexec/zminiutil                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zminiutil
   Copy ${repoDir}/zm-core-utils/src/libexec/zmiostat                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmiostat
   Copy ${repoDir}/zm-core-utils/src/libexec/zmiptool                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmiptool
   Copy ${repoDir}/zm-core-utils/src/libexec/zmjavawatch                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmjavawatch
   Copy ${repoDir}/zm-core-utils/src/libexec/zmjettyenablelogging                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmjettyenablelogging
   Copy ${repoDir}/zm-core-utils/src/libexec/zmjsprecompile                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmjsprecompile
   Copy ${repoDir}/zm-core-utils/src/libexec/zmlogger                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmlogger
   Copy ${repoDir}/zm-core-utils/src/libexec/zmloggerinit                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmloggerinit
   Copy ${repoDir}/zm-core-utils/src/libexec/zmlogprocess                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmlogprocess
   Copy ${repoDir}/zm-core-utils/src/libexec/zmmsgtrace                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmmsgtrace
   Copy ${repoDir}/zm-core-utils/src/libexec/zmmtainit                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmmtainit
   Copy ${repoDir}/zm-core-utils/src/libexec/zmmtastatus                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmmtastatus
   Copy ${repoDir}/zm-core-utils/src/libexec/zmmycnf                                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmmycnf
   Copy ${repoDir}/zm-core-utils/src/libexec/zmmyinit                                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmmyinit
   Copy ${repoDir}/zm-core-utils/src/libexec/zmnotifyinstall                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmnotifyinstall
   Copy ${repoDir}/zm-core-utils/src/libexec/zmpostfixpolicyd                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmpostfixpolicyd
   Copy ${repoDir}/zm-core-utils/src/libexec/zmproxyconfgen                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmproxyconfgen
   Copy ${repoDir}/zm-core-utils/src/libexec/zmproxyconfig                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmproxyconfig
   Copy ${repoDir}/zm-core-utils/src/libexec/zmproxypurge                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmproxypurge
   Copy ${repoDir}/zm-core-utils/src/libexec/zmqaction                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmqaction
   Copy ${repoDir}/zm-core-utils/src/libexec/zmqstat                                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmqstat
   Copy ${repoDir}/zm-core-utils/src/libexec/zmqueuelog                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmqueuelog
   Copy ${repoDir}/zm-core-utils/src/libexec/zmrc                                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmrc
   Copy ${repoDir}/zm-core-utils/src/libexec/zmrcd                                                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmrcd
   Copy ${repoDir}/zm-core-utils/src/libexec/zmresetmysqlpassword                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmresetmysqlpassword
   Copy ${repoDir}/zm-core-utils/src/libexec/zmrrdfetch                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmrrdfetch
   Copy ${repoDir}/zm-core-utils/src/libexec/zmsacompile                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmsacompile
   Copy ${repoDir}/zm-core-utils/src/libexec/zmsaupdate                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmsaupdate
   Copy ${repoDir}/zm-core-utils/src/libexec/zmserverips                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmserverips
   Copy ${repoDir}/zm-core-utils/src/libexec/zmsetservername                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmsetservername
   Copy ${repoDir}/zm-core-utils/src/libexec/zmsnmpinit                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmsnmpinit
   Copy ${repoDir}/zm-core-utils/src/libexec/zmspamextract                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmspamextract
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-allprocs                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-allprocs
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-cleanup                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-cleanup
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-cpu                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-cpu
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-df                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-df
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-fd                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-fd
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-io                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-io
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-mtaqueue                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-mtaqueue
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-mysql                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-mysql
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-nginx                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-nginx
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-proc                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-proc
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstat-vm                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-vm
   Copy ${repoDir}/zm-core-utils/src/libexec/zmstatuslog                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstatuslog
   Copy ${repoDir}/zm-core-utils/src/libexec/zmsyslogsetup                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmsyslogsetup
   Copy ${repoDir}/zm-core-utils/src/libexec/zmthreadcpu                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmthreadcpu
   Copy ${repoDir}/zm-core-utils/src/libexec/zmunbound                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmunbound
   Copy ${repoDir}/zm-core-utils/src/libexec/zmupdatedownload                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmupdatedownload
   Copy ${repoDir}/zm-core-utils/src/libexec/zmupdatezco                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmupdatezco
   Copy ${repoDir}/zm-core-utils/src/perl/migrate20131014-removezca.pl                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20131014-removezca.pl

   Copy ${repoDir}/zm-db-conf/src/db/migration/Migrate.pm                                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/Migrate.pm
   Copy ${repoDir}/zm-db-conf/src/db/migration/clearArchivedFlag.pl                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/clearArchivedFlag.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/fixConversationCounts.pl                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/fixConversationCounts.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/fixZeroChangeIdItems.pl                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/fixZeroChangeIdItems.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/fixup20080410-SetRsvpTrue.pl                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/fixup20080410-SetRsvpTrue.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate-ComboUpdater.pl                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate-ComboUpdater.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050517-AddUnreadColumn.pl                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050517-AddUnreadColumn.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050531-RemoveCascadingDeletes.pl            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050531-RemoveCascadingDeletes.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050609-AddDateIndex.pl                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050609-AddDateIndex.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050628-ShrinkSyncColumns.pl                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050628-ShrinkSyncColumns.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050701-SchemaCleanup.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050701-SchemaCleanup.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050721-MailItemIndexes.pl                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050721-MailItemIndexes.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050727-RemoveTypeInvite.pl                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050727-RemoveTypeInvite.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050727a-Volume.pl                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050727a-Volume.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050804-SpamToJunk.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050804-SpamToJunk.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050809-AddConfig.pl                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050809-AddConfig.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050811-WipeAppointments.pl                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050811-WipeAppointments.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050818-TagsFlagsIndexes.pl                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050818-TagsFlagsIndexes.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050822-TrackChangeDate.pl                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050822-TrackChangeDate.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050824-AddMailTransport.sh                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050824-AddMailTransport.sh
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050824a-Volume.pl                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050824a-Volume.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050831-SecondaryMsgVolume.pl                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050831-SecondaryMsgVolume.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050916-Volume.pl                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050916-Volume.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050920-CompressionThreshold.pl              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050920-CompressionThreshold.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20050927-DropRedologSequence.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20050927-DropRedologSequence.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20051021-UniqueVolume.pl                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20051021-UniqueVolume.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060120-Appointment.pl                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060120-Appointment.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060412-NotebookFolder.pl                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060412-NotebookFolder.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060515-AddImapId.pl                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060515-AddImapId.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060518-EmailedContactsFolder.pl             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060518-EmailedContactsFolder.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060708-FlagCalendarFolder.pl                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060708-FlagCalendarFolder.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060803-CreateMailboxMetadata.pl             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060803-CreateMailboxMetadata.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060807-WikiDigestFixup.sh                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060807-WikiDigestFixup.sh
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060810-PersistFolderCounts.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060810-PersistFolderCounts.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060911-MailboxGroup.pl                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060911-MailboxGroup.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20060929-TypedTombstones.pl                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20060929-TypedTombstones.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20061101-IMFolder.pl                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20061101-IMFolder.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20061117-TasksFolder.pl                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20061117-TasksFolder.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20061120-AddNameColumn.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20061120-AddNameColumn.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20061204-CreatePop3MessageTable.pl            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20061204-CreatePop3MessageTable.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20061205-UniqueAppointmentIndex.pl            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20061205-UniqueAppointmentIndex.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20061212-RepairMutableIndexIds.pl             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20061212-RepairMutableIndexIds.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20061221-RecalculateFolderSizes.pl            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20061221-RecalculateFolderSizes.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070302-NullContactVolumeId.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070302-NullContactVolumeId.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070306-Pop3MessageUid.pl                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070306-Pop3MessageUid.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070606-WidenMetadata.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070606-WidenMetadata.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070614-BriefcaseFolder.pl                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070614-BriefcaseFolder.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070627-BackupTime.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070627-BackupTime.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070629-IMTables.pl                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070629-IMTables.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070630-LastSoapAccess.pl                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070630-LastSoapAccess.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070703-ScheduledTask.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070703-ScheduledTask.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070706-DeletedAccount.pl                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070706-DeletedAccount.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070713-NullContactBlobDigest.pl             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070713-NullContactBlobDigest.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070725-CreateRevisionTable.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070725-CreateRevisionTable.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070726-ImapDataSource.pl                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070726-ImapDataSource.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070809-Signatures.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070809-Signatures.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070921-ImapDataSourceUidValidity.pl         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070921-ImapDataSourceUidValidity.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20070928-ScheduledTaskIndex.pl                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20070928-ScheduledTaskIndex.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20071128-AccountId.pl                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20071128-AccountId.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20071202-DeleteSignatures.pl                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20071202-DeleteSignatures.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20071204-deleteOldLDAPUsers.pl                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20071204-deleteOldLDAPUsers.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20071206-WidenSizeColumns.pl                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20071206-WidenSizeColumns.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20080130-ImapFlags.pl                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20080130-ImapFlags.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20080213-IndexDeferredColumn.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20080213-IndexDeferredColumn.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20080909-DataSourceItemTable.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20080909-DataSourceItemTable.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20080930-MucService.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20080930-MucService.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20090315-MobileDevices.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20090315-MobileDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20090406-DataSourceItemTable.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20090406-DataSourceItemTable.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20090430-highestindexed.pl                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20090430-highestindexed.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20100106-MobileDevices.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20100106-MobileDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20100913-Mysql51.pl                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20100913-Mysql51.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20100926-Dumpster.pl                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20100926-Dumpster.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20101123-MobileDevices.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20101123-MobileDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20110314-MobileDevices.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20110314-MobileDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20110330-RecipientsColumn.pl                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20110330-RecipientsColumn.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20110705-PendingAclPush.pl                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20110705-PendingAclPush.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20110810-TagTable.pl                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20110810-TagTable.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20110928-MobileDevices.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20110928-MobileDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20110929-VersionColumn.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20110929-VersionColumn.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20111005-ItemIdCheckpoint.pl                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20111005-ItemIdCheckpoint.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20120125-uuidAndDigest.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20120125-uuidAndDigest.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20120222-LastPurgeAtColumn.pl                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20120222-LastPurgeAtColumn.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20120229-DropIMTables.pl                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20120229-DropIMTables.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20120319-Name255Chars.pl                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20120319-Name255Chars.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20120410-BlobLocator.pl                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20120410-BlobLocator.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20120611_7to8_bundle.pl                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20120611_7to8_bundle.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20121009-VolumeBlobs.pl                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20121009-VolumeBlobs.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20130226_alwayson.pl                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20130226_alwayson.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20130227-UpgradeCBPolicyDSchema.sql           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20130227-UpgradeCBPolicyDSchema.sql
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20130606-UpdateCBPolicydSchema.sql            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20130606-UpdateCBPolicydSchema.sql
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20130819-UpgradeQuotasTable.sql               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20130819-UpgradeQuotasTable.sql
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20140319-MailItemPrevFolders.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20140319-MailItemPrevFolders.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20140328-EnforceTableCharset.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20140328-EnforceTableCharset.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20140624-DropMysqlIndexes.pl                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20140624-DropMysqlIndexes.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20150401-ZmgDevices.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20150401-ZmgDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20150515-DataSourcePurgeTables.pl             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20150515-DataSourcePurgeTables.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20150623-ZmgDevices.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20150623-ZmgDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20150702-ZmgDevices.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20150702-ZmgDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20170301-ZimbraChat.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20170301-ZimbraChat.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20180301-ZimbraChat.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20180301-ZimbraChat.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20190401-ZimbraChat.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20190401-ZimbraChat.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20190611-ZimbraChat.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20190611-ZimbraChat.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20210506-BriefcaseApi.pl                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20210506-BriefcaseApi.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20200625-MobileDevices.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20200625-MobileDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20210319-MobileDevices.pl                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20210319-MobileDevices.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrate20210809-UnsubscribeFolder.pl                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20210809-UnsubscribeFolder.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateAmavisLdap20050810.pl                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateAmavisLdap20050810.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateClearSpamFlag.pl                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateClearSpamFlag.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateLargeMetadata.pl                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateLargeMetadata.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateLogger1-index.pl                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateLogger1-index.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateLogger2-config.pl                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateLogger2-config.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateLogger3-diskindex.pl                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateLogger3-diskindex.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateLogger4-loghostname.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateLogger4-loghostname.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateLogger5-qid.pl                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateLogger5-qid.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateLogger6-qid.pl                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateLogger6-qid.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateMailItemTimestamps.pl                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateMailItemTimestamps.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migratePreWidenSizeColumns.pl                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migratePreWidenSizeColumns.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateRemoveMailboxId.pl                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateRemoveMailboxId.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateRemoveTagIndexes.pl                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateRemoveTagIndexes.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateRenameIdentifiers.pl                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateRenameIdentifiers.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateSyncSequence.pl                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateSyncSequence.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateToSplitTables.pl                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateToSplitTables.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/migrateUpdateAppointment.pl                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrateUpdateAppointment.pl
   Copy ${repoDir}/zm-db-conf/src/db/migration/optimizeMboxgroups.pl                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/optimizeMboxgroups.pl
   Copy ${repoDir}/zm-db-conf/src/db/mysql/create_database.sql                                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/db/create_database.sql
   Copy ${repoDir}/zm-db-conf/src/db/mysql/db.sql                                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/db/db.sql

   Copy ${repoDir}/zm-freshclam/freshclam.conf.in                                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/freshclam.conf.in

   Copy ${repoDir}/zm-jython/jylibs/commands.py                                                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/commands.py
   Copy ${repoDir}/zm-jython/jylibs/conf.py                                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/conf.py
   Copy ${repoDir}/zm-jython/jylibs/config.py                                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/config.py
   Copy ${repoDir}/zm-jython/jylibs/globalconfig.py                                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/globalconfig.py
   Copy ${repoDir}/zm-jython/jylibs/ldap.py                                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/ldap.py
   Copy ${repoDir}/zm-jython/jylibs/listener.py                                                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/listener.py
   Copy ${repoDir}/zm-jython/jylibs/localconfig.py                                                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/localconfig.py
   Copy ${repoDir}/zm-jython/jylibs/logmsg.py                                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/logmsg.py
   Copy ${repoDir}/zm-jython/jylibs/miscconfig.py                                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/miscconfig.py
   Copy ${repoDir}/zm-jython/jylibs/mtaconfig.py                                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/mtaconfig.py
   Copy ${repoDir}/zm-jython/jylibs/serverconfig.py                                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/serverconfig.py
   Copy ${repoDir}/zm-jython/jylibs/state.py                                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/common/lib/jylibs/state.py

   Copy ${repoDir}/zm-launcher/build/dist/zmmailboxdmgr                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmmailboxdmgr
   Copy ${repoDir}/zm-launcher/build/dist/zmmailboxdmgr.unrestricted                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmmailboxdmgr.unrestricted 

   Copy ${repoDir}/zm-ldap-utilities/conf/externaldirsync/Exchange2000.xml                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/externaldirsync/Exchange2000.xml
   Copy ${repoDir}/zm-ldap-utilities/conf/externaldirsync/Exchange2003.xml                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/externaldirsync/Exchange2003.xml
   Copy ${repoDir}/zm-ldap-utilities/conf/externaldirsync/Exchange5.5.xml                           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/externaldirsync/Exchange5.5.xml
   Copy ${repoDir}/zm-ldap-utilities/conf/externaldirsync/domino.xml                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/externaldirsync/domino.xml
   Copy ${repoDir}/zm-ldap-utilities/conf/externaldirsync/novellGroupWise.xml                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/externaldirsync/novellGroupWise.xml
   Copy ${repoDir}/zm-ldap-utilities/conf/externaldirsync/openldap.xml                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/externaldirsync/openldap.xml
   Copy ${repoDir}/zm-ldap-utilities/conf/freshclam.conf.in                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/freshclam.conf.in
   Copy ${repoDir}/zm-ldap-utilities/conf/zmconfigd.cf                                              ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmconfigd.cf
   Copy ${repoDir}/zm-ldap-utilities/conf/zmconfigd.log4j.properties                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmconfigd.log4j.properties
   Copy ${repoDir}/zm-ldap-utilities/src/ldap/migration/migrate20110615-AddDynlist.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20110615-AddDynlist.pl
   Copy ${repoDir}/zm-ldap-utilities/src/ldap/migration/migrate20110721-AddUnique.pl                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20110721-AddUnique.pl
   Copy ${repoDir}/zm-ldap-utilities/src/ldap/migration/migrate20111019-UniqueZimbraId.pl           ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20111019-UniqueZimbraId.pl
   Copy ${repoDir}/zm-ldap-utilities/src/ldap/migration/migrate20120210-AddSearchNoOp.pl            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20120210-AddSearchNoOp.pl
   Copy ${repoDir}/zm-ldap-utilities/src/ldap/migration/migrate20120507-UniqueDKIMSelector.pl       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20120507-UniqueDKIMSelector.pl
   Copy ${repoDir}/zm-ldap-utilities/src/ldap/migration/migrate20140728-AddSSHA512.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20140728-AddSSHA512.pl
   Copy ${repoDir}/zm-ldap-utilities/src/ldap/migration/migrate20141022-AddTLSBits.pl               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20141022-AddTLSBits.pl
   Copy ${repoDir}/zm-ldap-utilities/src/ldap/migration/migrate20150930-AddSyncpovSessionlog.pl     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/scripts/migrate20150930-AddSyncpovSessionlog.pl
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapanon                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapanon
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapapplyldif                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapapplyldif
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapenable-mmr                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapenable-mmr
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapenablereplica                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapenablereplica
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapinit                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapinit
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapmmrtool                                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapmmrtool
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapmonitordb                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapmonitordb
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldappromote-replica-mmr                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldappromote-replica-mmr
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapreplicatool                                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapreplicatool
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapschema                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapschema
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmldapupdateldif                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmldapupdateldif
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmreplchk                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmreplchk
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmslapadd                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmslapadd
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmslapcat                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmslapcat
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmslapd                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmslapd
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmslapindex                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmslapindex
   Copy ${repoDir}/zm-ldap-utilities/src/libexec/zmstat-ldap                                        ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec/zmstat-ldap

   Copy ${repoDir}/zm-licenses/zimbra/ypl-full.txt                                                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/docs/YPL.txt
   Copy ${repoDir}/zm-licenses/zimbra/zpl-full.txt                                                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/docs/ZPL.txt

   Copy ${repoDir}/zm-migration-tools/ReadMe.txt                                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/docs/zmztozmig.txt

   Copy ${repoDir}/zm-mta/cbpolicyd.conf.in                                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/cbpolicyd.conf.in
   Copy ${repoDir}/zm-mta/clamd.conf.in                                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/clamd.conf.in
   Copy ${repoDir}/zm-mta/opendkim-localnets.conf.in                                                ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/opendkim-localnets.conf.in
   Copy ${repoDir}/zm-mta/opendkim.conf.in                                                          ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/opendkim.conf.in
   Copy ${repoDir}/zm-mta/postfix_header_checks.in                                                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/postfix_header_checks.in
   Copy ${repoDir}/zm-mta/postfix_sasl_smtpd.conf                                                   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/sasl2/smtpd.conf.in
   Copy ${repoDir}/zm-mta/salocal.cf.in                                                             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/salocal.cf.in
   Copy ${repoDir}/zm-mta/saslauthd.conf.in                                                         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/saslauthd.conf.in
   Copy ${repoDir}/zm-mta/zmconfigd/postfix_content_filter.cf                                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmconfigd/postfix_content_filter.cf
   Copy ${repoDir}/zm-mta/zmconfigd/smtpd_end_of_data_restrictions.cf                               ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmconfigd/smtpd_end_of_data_restrictions.cf
   Copy ${repoDir}/zm-mta/zmconfigd/smtpd_recipient_restrictions.cf                                 ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmconfigd/smtpd_recipient_restrictions.cf
   Copy ${repoDir}/zm-mta/zmconfigd/smtpd_relay_restrictions.cf                                     ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmconfigd/smtpd_relay_restrictions.cf
   Copy ${repoDir}/zm-mta/zmconfigd/smtpd_sender_login_maps.cf                                      ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmconfigd/smtpd_sender_login_maps.cf
   Copy ${repoDir}/zm-mta/zmconfigd/smtpd_sender_restrictions.cf                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmconfigd/smtpd_sender_restrictions.cf

   Cpy2 ${repoDir}/junixsocket/junixsocket-native/build/junixsocket-native-*.nar                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/
   Cpy2 ${repoDir}/junixsocket/junixsocket-native/build/libjunixsocket-native-*.so                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/

   Copy ${repoDir}/zm-bulkprovision-store/build/dist/commons-csv-1.2.jar                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/com_zimbra_bulkprovision/commons-csv-1.2.jar
   Copy ${repoDir}/zm-bulkprovision-store/build/dist/zm-bulkprovision-store*.jar                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/com_zimbra_bulkprovision/com_zimbra_bulkprovision.jar

   Copy ${repoDir}/zm-certificate-manager-store/build/zm-certificate-manager-store*.jar             ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/com_zimbra_cert_manager/com_zimbra_cert_manager.jar 

   Copy ${repoDir}/zm-clientuploader-store/build/zm-clientuploader-store*.jar                       ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/com_zimbra_clientuploader/com_zimbra_clientuploader.jar

   # Copy SSDB Ephemeral storage extension + dependencies
   Cpy2 ${repoDir}/zm-ssdb-ephemeral-store/build/dist/zm-ssdb-ephemeral-store*.jar                  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/com_zimbra_ssdb_ephemeral_store/
   Cpy2 ${repoDir}/zm-zcs-lib/build/dist/jedis-2.9.0.jar                                            ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/com_zimbra_ssdb_ephemeral_store/
   Cpy2 ${repoDir}/zm-zcs-lib/build/dist/commons-pool2-2.4.2.jar                                    ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/com_zimbra_ssdb_ephemeral_store/

   CreatePackage "${os}"
}

############################################################################
main "$@"
