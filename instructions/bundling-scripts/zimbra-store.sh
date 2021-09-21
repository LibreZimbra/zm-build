#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

set -e

#-------------------- Configuration ---------------------------

    currentScript=`basename $0 | cut -d "." -f 1`                          # zimbra-store
    currentPackage=`echo ${currentScript}build | cut -d "-" -f 2` # storebuild

#-------------------- Build Package ---------------------------
main()
{
    Log "Create package directories"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/etc/sudoers.d
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/bin
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/templates

    Log "Copy package files"

    Log "Copy etc files"
    cp ${repoDir}/zm-build/rpmconf/Env/sudoers.d/02_${currentScript} ${repoDir}/zm-build/${currentPackage}/etc/sudoers.d/02_${currentScript}

    Log "Copy bin files of /opt/zimbra/"

    cp -f ${repoDir}/zm-migration-tools/zmztozmig.conf ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/zmztozmig.conf

    cp -f ${repoDir}/zm-mailbox/store-conf/conf/owasp_policy.xml ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/owasp_policy.xml
    cp -f ${repoDir}/zm-mailbox/store-conf/conf/antisamy.xml ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/antisamy.xml
    cp -f ${repoDir}/zm-mailbox/store-conf/conf/custom-mimetypes.xml ${repoDir}/zm-build/${currentPackage}/opt/zimbra/conf/custom-mimetypes.xml

    Log "Copy extensions-extra files of /opt/zimbra/"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/extensions-extra/openidconsumer
    cp -rf ${repoDir}/zm-openid-consumer-store/build/dist/. ${repoDir}/zm-build/${currentPackage}/opt/zimbra/extensions-extra/openidconsumer
    rm -rf ${repoDir}/zm-build/${currentPackage}/opt/zimbra/extensions-extra/openidconsumer/extensions-extra

    Log "Copy lib files of /opt/zimbra/"

    Log "Copy ext files of /opt/zimbra/lib/"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/jars
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/clamscanner
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/nginx-lookup
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/openidconsumer
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/zimbraadminversioncheck
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/zimbraldaputils
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/zm-oauth-social
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/zm-gql
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext-common

    cp -f ${repoDir}/zm-clam-scanner-store/build/dist/zm-clam-scanner-store*.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/clamscanner/clamscanner.jar
    cp -f ${repoDir}/zm-nginx-lookup-store/build/dist/zm-nginx-lookup-store*.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/nginx-lookup/nginx-lookup.jar
    cp -f ${repoDir}/zm-openid-consumer-store/build/dist/guice*.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/openidconsumer/
    cp -f ${repoDir}/zm-versioncheck-store/build/zm-versioncheck-store*.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/zimbraadminversioncheck/zimbraadminversioncheck.jar
    cp -f ${repoDir}/zm-ldap-utils-store/build/zm-ldap-utils-*.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/zimbraldaputils/zimbraldaputils.jar
    
    cp -f ${repoDir}/zm-oauth-social/build/dist/zm-oauth-social.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/zm-oauth-social/zmoauthsocial.jar
    cp -f ${repoDir}/zm-oauth-social/build/dist/zm-oauth-social-common.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext-common/zm-oauth-social-common.jar
    
    cp -f ${repoDir}/zm-zcs-lib/build/dist/java-jwt-3.2.0.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/zm-oauth-social/
    cp -f ${repoDir}/zm-gql/build/dist/zm-gql*.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/lib/ext/zm-gql/zmgql.jar

#-------------------- Get wars content (service.war, zimbra.war and zimbraAdmin.war) ---------------------------

    Log "service.war content"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/service/WEB-INF/lib
    cp ${repoDir}/zm-zimlets/conf/zimbra.tld ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/service/WEB-INF
    cp ${repoDir}/zm-taglib/build/zm-taglib*.jar         ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/service/WEB-INF/lib
    cp ${repoDir}/zm-zimlets/build/dist/zimlettaglib.jar ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/service/WEB-INF/lib

    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/zimbra

    Log "help content"
    cp -rf ${repoDir}/zm-help/. ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/zimbra/help

    Log "portals example content"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/zimbra/portals/example
    cp -rf ${repoDir}/zm-webclient-portal-example/example ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/zimbra/portals

    Log "robots.txt content"
    cp -f ${repoDir}/zm-aspell/conf/robots.txt ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/zimbra/robots.txt

    Log "downloads content"
    downloadsDir=${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/zimbra/downloads
    mkdir -p ${downloadsDir}
    cp -rf ${repoDir}/zm-downloads/. ${downloadsDir}

    Log "help content"
    rsync -a ${repoDir}/zm-admin-help-common/WebRoot/help ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/zimbraAdmin/

    cp -f ${repoDir}/zm-migration-tools/src/libexec/zmztozmig ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec
    cp -f ${repoDir}/zm-migration-tools/src/libexec/zmcleaniplanetics ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec
    cp -f ${repoDir}/zm-versioncheck-utilities/src/libexec/zmcheckversion ${repoDir}/zm-build/${currentPackage}/opt/zimbra/libexec

    Log "Copy log files of /opt/zimbra/"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/log
    cp -f ${repoDir}/zm-build/rpmconf/Conf/hotspot_compiler ${repoDir}/zm-build/${currentPackage}/opt/zimbra/log/.hotspot_compiler

    Log "Copy zimlets files of /opt/zimbra/"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/zimlets
    zimletsArray=( "zm-versioncheck-admin-zimlet" \
                   "zm-bulkprovision-admin-zimlet" \
                   "zm-certificate-manager-admin-zimlet" \
                   "zm-clientuploader-admin-zimlet" \
                   "zm-proxy-config-admin-zimlet" \
                   "zm-helptooltip-zimlet" \
                   "zm-viewmail-admin-zimlet" )
    for i in "${zimletsArray[@]}"
    do
        cp ${repoDir}/${i}/build/zimlet/*.zip ${repoDir}/zm-build/${currentPackage}/opt/zimbra/zimlets
    done

    cp -f ${repoDir}/zm-zimlets/build/dist/zimlets/*.zip ${repoDir}/zm-build/${currentPackage}/opt/zimbra/zimlets

    Log "Building jetty/common/"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/common/endorsed
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/common/lib

    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/temp
    touch ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/temp/.emptyfile

    Log "Create jetty conf"
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/modules
    mkdir -p ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/start.d

    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/jettyrc  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/zimbra.policy.example ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/jetty.xml.production ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/jetty.xml.in
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/webdefault.xml.production ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/webdefault.xml
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/jetty-setuid.xml ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/jetty-setuid.xml
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/spnego/etc/spnego.properties ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/spnego.properties.in
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/spnego/etc/spnego.conf ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/spnego.conf.in
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/spnego/etc/krb5.ini ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/krb5.ini.in
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/modules/*.mod  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/modules
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/modules/*.mod.in ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/modules
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/start.d/*.ini.in   ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/start.d
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/modules/npn/*.mod  ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/modules/npn
    cp -f ${repoDir}/zm-jetty-conf/conf/jetty/jetty-logging.properties ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/

    cp -f ${repoDir}/zm-zimlets/conf/web.xml.production ${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/etc/zimlet.web.xml.in

    CreatePackage "${os}"
}

#-------------------- Util Functions ---------------------------

CreateDebianPackage()
{
    mkdir -p ${repoDir}/zm-build/${currentPackage}/DEBIAN
    cat ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post >> ${repoDir}/zm-build/${currentPackage}/DEBIAN/postinst
    chmod 555 ${repoDir}/zm-build/${currentPackage}/DEBIAN/*

    Log "Create debian package"
    (cd ${repoDir}/zm-build/${currentPackage}; find . -type f ! -regex '.*jetty_base/webapps/zimbra/WEB-INF/jetty-env.xml' ! \
        -regex '.*jetty_base/webapps/zimbraAdmin/WEB-INF/jetty-env.xml' ! -regex '.*jetty_base/modules/setuid.mod' ! \
        -regex '.*jetty_base/etc/krb5.ini' ! -regex '.*jetty_base/etc/spnego.properties' ! -regex '.*jetty_base/etc/jetty.xml' ! \
        -regex '.*jetty_base/etc/spnego.conf' ! -regex '.*jetty_base/webapps/zimbraAdmin/WEB-INF/web.xml' ! \
        -regex '.*jetty_base/webapps/zimbra/WEB-INF/web.xml' ! -regex '.*jetty_base/webapps/service/WEB-INF/web.xml' ! \
        -regex '.*jetty_base/work/.*' ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -print0 | xargs -0 md5sum | \sed -e 's| \./| |' \
        > ${repoDir}/zm-build/${currentPackage}/DEBIAN/md5sums)

    export MORE_DEPENDS="$(find ${repoDir}/zm-packages/ -name \*.deb \
                         | xargs -n1 basename \
                         | sed -e 's/_[0-9].*//' \
                         | grep -e zimbra-mbox- \
                         | sed '1s/^/, /; :a; {N;s/\n/, /;ba}')";
    DebianFinish
}

CreateRhelPackage()
{
    MORE_DEPENDS="$(find ${repoDir}/zm-packages/ -name \*.rpm \
                       | xargs -n1 basename \
                       | sed -e 's/-[0-9].*//' \
                       | grep -e zimbra-mbox- \
                       | sed '1s/^/, /; :a; {N;s/\n/, /;ba}')";

    cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.spec | \
    	sed -e "s/@@VERSION@@/${releaseNo}_${releaseCandidate}_${buildNo}.${os}/" \
                -e "s/@@MORE_DEPENDS@@/${MORE_DEPENDS}/" \
            	-e "/^%pre$/ r ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.pre" \
            	-e "/^%post$/ r ${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post" > ${repoDir}/zm-build/${currentScript}.spec

    echo "%attr(-, root, root) /opt/zimbra/lib" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(440, root, root) /etc/sudoers.d/02_zimbra-store" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, zimbra, zimbra) /opt/zimbra/conf" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(644, zimbra, zimbra) /opt/zimbra/conf/*" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, zimbra, zimbra) /opt/zimbra/log" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, zimbra, zimbra) /opt/zimbra/zimlets" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, zimbra, zimbra) /opt/zimbra/extensions-extra" >> \
    	${repoDir}/zm-build/${currentScript}.spec

    echo "%attr(755, root, root) /opt/zimbra/bin" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(755, root, root) /opt/zimbra/libexec" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "%attr(-, zimbra, zimbra) /opt/zimbra/jetty_base" >> \
    	${repoDir}/zm-build/${currentScript}.spec
    echo "" >> ${repoDir}/zm-build/${currentScript}.spec
    echo "%clean" >> ${repoDir}/zm-build/${currentScript}.spec
    (cd ${repoDir}/zm-build/${currentPackage}; \
    rpmbuild --target ${arch} --define '_rpmdir ../' --buildroot=${repoDir}/zm-build/${currentPackage} -bb ${repoDir}/zm-build/${currentScript}.spec )
}
############################################################################
main "$@"
