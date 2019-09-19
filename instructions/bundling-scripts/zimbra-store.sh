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

# Shell script to create zimbra store package

set -e

#-------------------- Configuration ---------------------------

    currentScript=`basename $0 | cut -d "." -f 1`                          # zimbra-store
    currentPackage=`echo ${currentScript}build | cut -d "-" -f 2` # storebuild

zm_install_ne_bin() {
    [ "${buildType}" == "NETWORK" ] || return 0

    log 1 "Installing NE binaries and jar libs"

    install_bin \
        zm-hsm/src/bin/zmhsm \
        zm-archive-utils/src/bin/zmarchiveconfig \
        zm-archive-utils/src/bin/zmarchivesearch \
        zm-sync-tools/src/bin/zmsyncreverseproxy \
        zm-sync-store/src/bin/zmdevicesstats \
        zm-sync-store/src/bin/zmgdcutil

    for i in bcpkix-jdk15on-1.55 bcmail-jdk15on-1.55 bcprov-jdk15on-1.55 saaj-impl-1.5.1 ; do
        install_file zm-zcs-lib/build/dist/$i.jar opt/zimbra/lib/ext-common/
    done

    install_dir opt/zimbra/lib/ext/network
    install_file zm-backup-store/build/dist/zm-backup-store.jar               opt/zimbra/lib/ext/backup/zimbrabackup.jar
    install_file zm-archive-store/build/dist/*.jar                            opt/zimbra/lib/ext/zimbra-archive/zimbra-archive.jar
    install_file zm-voice-store/build/dist/zm-voice-store.jar                 opt/zimbra/lib/ext/voice/zimbravoice.jar
    install_file zm-voice-mitel-store/build/dist/zm-voice-mitel-store.jar     opt/zimbra/lib/ext/mitel/
    install_file zm-voice-cisco-store/build/dist/zm-voice-cisco-store.jar     opt/zimbra/lib/ext/cisco/
    install_file zm-sync-common/build/dist/*.jar                              opt/zimbra/lib/ext/zimbrasync/
    install_file zm-sync-store/build/dist/*.jar                               opt/zimbra/lib/ext/zimbrasync/
    install_file zm-sync-tools/build/dist/*.jar                               opt/zimbra/lib/ext/zimbrasync/
    install_file zm-openoffice-store/build/dist/*.jar                         opt/zimbra/lib/ext/com_zimbra_oo/
    ## fixme: bug in com_zimbra_oo extension - should generate the correct jar filename
    mv $(target_dir opt/zimbra/lib/ext/com_zimbra_oo/zm-openoffice-store.jar) \
       $(target_dir opt/zimbra/lib/ext/com_zimbra_oo/com_zimbra_oo.jar)
    install_file zm-convertd-store/build/dist/*.jar                           opt/zimbra/lib/ext/convertd/
    install_file zm-twofactorauth-store/build/dist/zm-twofactorauth-store*.jar \
                 opt/zimbra/lib/ext/twofactorauth/zimbratwofactorauth.jar
    install_file zm-hsm-store/build/zimbrahsm.jar                             opt/zimbra/lib/ext/zimbrahsm/
    install_file zm-freebusy-provider-store/build/zimbra-freebusyprovider.jar opt/zimbra/lib/ext/zimbra-freebusy/
    install_file zm-smime-store/build/dist/*.jar                              opt/zimbra/lib/ext/smime/
    install_file zm-network-gql/build/dist/zm-network-gql*.jar                opt/zimbra/lib/ext/zm-gql/zmnetworkgql.jar

    install_subtree zm-saml-consumer-store/build/dist/saml \
                    opt/zimbra/extensions-network-extra/saml
}

zm_install_openidconsumer() {
    log 1 "Installing openidconsumer extension"

    install_file zm-openid-consumer-store/build/dist/guice*.jar opt/zimbra/lib/ext/openidconsumer/
    install_subtree zm-openid-consumer-store/build/dist/        opt/zimbra/extensions-extra/openidconsumer/

    # fixme: it's a bug in extension build rules
    rm -rf $(target_dir opt/zimbra/extensions-extra/openidconsumer/extensions-extra)
}

zm_install_migration_tools() {
    log 1 "Installing zm-migration-tools"

    install_conf zm-migration-tools/zmztozmig.conf

    install_libexec \
        zm-migration-tools/src/libexec/zmztozmig \
        zm-migration-tools/src/libexec/zmcleaniplanetics
}

zm_install_versioncheck() {
    log 1 "Installing zm-versioncheck"

    install_file zm-versioncheck-store/build/zm-versioncheck-store*.jar \
                 opt/zimbra/lib/ext/zimbraadminversioncheck/zimbraadminversioncheck.jar

    install_libexec zm-versioncheck-utilities/src/libexec/zmcheckversion
}

zm_install_ose_ext() {
    log 1 "Installing OSE extension libraries"

    install_dirs opt/zimbra/lib/jars opt/zimbra/lib/ext/zimbra-license

    install_file zm-clam-scanner-store/build/dist/zm-clam-scanner-store*.jar      opt/zimbra/lib/ext/clamscanner/clamscanner.jar
    install_file zm-nginx-lookup-store/build/dist/zm-nginx-lookup-store*.jar      opt/zimbra/lib/ext/nginx-lookup/nginx-lookup.jar
    install_file zm-ldap-utils-store/build/zm-ldap-utils-*.jar                    opt/zimbra/lib/ext/zimbraldaputils/zimbraldaputils.jar
    install_file zm-oauth-social/build/dist/zm-oauth-social*.jar                  opt/zimbra/lib/ext/zm-oauth-social/zmoauthsocial.jar
    install_file zm-zcs-lib/build/dist/java-jwt-3.2.0.jar                         opt/zimbra/lib/ext/zm-oauth-social/
    install_file zm-gql/build/dist/zm-gql*.jar                                    opt/zimbra/lib/ext/zm-gql/zmgql.jar
}

zm_install_jetty_conf() {
    log 1 "Installign jetty config"

    install_dirs \
        opt/zimbra/jetty_base/common/endorsed \
        opt/zimbra/jetty_base/common/lib \
        opt/zimbra/jetty_base/temp

    touch $(target_dir opt/zimbra/jetty_base/temp/.emptyfile)

    install_file zm-jetty-conf/conf/jetty/jettyrc                      opt/zimbra/jetty_base/etc/
    install_file zm-jetty-conf/conf/jetty/zimbra.policy.example        opt/zimbra/jetty_base/etc/
    install_file zm-jetty-conf/conf/jetty/jetty.xml.production         opt/zimbra/jetty_base/etc/jetty.xml.in
    install_file zm-jetty-conf/conf/jetty/webdefault.xml.production    opt/zimbra/jetty_base/etc/webdefault.xml
    install_file zm-jetty-conf/conf/jetty/jetty-setuid.xml             opt/zimbra/jetty_base/etc/jetty-setuid.xml
    install_file zm-jetty-conf/conf/jetty/spnego/etc/spnego.properties opt/zimbra/jetty_base/etc/spnego.properties.in
    install_file zm-jetty-conf/conf/jetty/spnego/etc/spnego.conf       opt/zimbra/jetty_base/etc/spnego.conf.in
    install_file zm-jetty-conf/conf/jetty/spnego/etc/krb5.ini          opt/zimbra/jetty_base/etc/krb5.ini.in
    install_file zm-jetty-conf/conf/jetty/modules/*.mod                opt/zimbra/jetty_base/modules/
    install_file zm-jetty-conf/conf/jetty/modules/*.mod.in             opt/zimbra/jetty_base/modules/
    install_file zm-jetty-conf/conf/jetty/start.d/*.ini.in             opt/zimbra/jetty_base/start.d/
    install_file zm-jetty-conf/conf/jetty/modules/npn/*.mod            opt/zimbra/jetty_base/modules/npn/

    install_file zm-zimlets/conf/web.xml.production                    opt/zimbra/jetty_base/etc/zimlet.web.xml.in
}

zm_install_help() {
    log 1 "Installing help content"

    install_subtree zm-help/                          opt/zimbra/jetty_base/webapps/zimbra/help/
    install_subtree zm-admin-help-common/WebRoot/help opt/zimbra/jetty_base/webapps/zimbraAdmin/help/

    if [ "${buildType}" == "NETWORK" ]
    then
        install_subtree zm-admin-help-network/WebRoot/help opt/zimbra/jetty_base/webapps/zimbraAdmin/help/
    fi
}

zm_install_touch_client() {
    if [ "${buildType}" == "NETWORK" ]; then

        log 1 "Installing touch web client"

        install_file zm-touch-client/build/WebRoot/css/ztouch.css         opt/zimbra/jetty_base/webapps/zimbra/css/
        install_file zm-touch-client/build/WebRoot/public/loginTouch.jsp  opt/zimbra/jetty_base/webapps/zimbra/public/
        install_subtree zm-touch-client/build/WebRoot/t                   opt/zimbra/jetty_base/webapps/zimbra/t/
        install_subtree zm-touch-client/build/WebRoot/tdebug              opt/zimbra/jetty_base/webapps/zimbra/tdebug/
    fi
}

#-------------------- Build Package ---------------------------
main()
{
    log 1 "Create package directories"
    install_dirs opt/zimbra/conf/templates

    log 1 "Copy package files"
    log 1 "Copy etc files"
    install_file zm-build/rpmconf/Env/sudoers.d/02_${currentScript} etc/sudoers.d/

    log 1 "Copy bin files of /opt/zimbra/"
    zm_install_ne_bin
    zm_install_openidconsumer
    zm_install_migration_tools
    zm_install_versioncheck
    zm_install_ose_ext
    zm_install_jetty_conf
    zm_install_touch_client

    install_conf \
        zm-mailbox/store-conf/conf/owasp_policy.xml \
        zm-mailbox/store-conf/conf/antisamy.xml

    log 1 "Copy lib files of /opt/zimbra/"

#-------------------- Get wars content (service.war, zimbra.war and zimbraAdmin.war) ---------------------------

    log 2 "++++++++++ service.war content ++++++++++"
    install_file zm-zimlets/conf/zimbra.tld             opt/zimbra/jetty_base/webapps/service/WEB-INF/
    install_file zm-taglib/build/zm-taglib*.jar         opt/zimbra/jetty_base/webapps/service/WEB-INF/lib/
    install_file zm-zimlets/build/dist/zimlettaglib.jar opt/zimbra/jetty_base/webapps/service/WEB-INF/lib/

    zm_install_help

    log 2 "***** portals example content *****"
    install_subtree zm-webclient-portal-example/example opt/zimbra/jetty_base/webapps/zimbra/portals/example/

    log 2 "***** robots.txt content *****"
    install_file zm-aspell/conf/robots.txt opt/zimbra/jetty_base/webapps/zimbra/robots.txt

    log 2 "***** downloads content *****"
    downloadsDir=${repoDir}/zm-build/${currentPackage}/opt/zimbra/jetty_base/webapps/zimbra/downloads
    mkdir -p ${downloadsDir}
    cp -rf ${repoDir}/zm-downloads/. ${downloadsDir}

    if [ "${buildType}" == "NETWORK" ]
    then
        set -e
        cd ${downloadsDir}
        wget -r -nd --no-parent --reject "index.*" http://${zimbraThirdPartyServer}/ZimbraThirdParty/zco-migration-builds/current/
    fi

    log 1 "Copy log files of /opt/zimbra/"
    install_file zm-build/rpmconf/Conf/hotspot_compiler opt/zimbra/log/.hotspot_compiler

    log 1 "Copy zimlets files of /opt/zimbra/"
    zimletsArray=( "zm-versioncheck-admin-zimlet" \
                   "zm-bulkprovision-admin-zimlet" \
                   "zm-certificate-manager-admin-zimlet" \
                   "zm-clientuploader-admin-zimlet" \
                   "zm-proxy-config-admin-zimlet" \
                   "zm-helptooltip-zimlet" \
                   "zm-viewmail-admin-zimlet" )
    for i in "${zimletsArray[@]}"
    do
        install_zimlets_from zimlets "${i}/build/zimlet"
    done

    install_zimlets_from zimlets zm-zimlets/build/dist/zimlets

    if [ "${buildType}" == "NETWORK" ]
    then
        log 1 "Copy zimlets-network files of /opt/zimbra/"
      adminZimlets=( "zm-license-admin-zimlet" \
                     "zm-backup-restore-admin-zimlet" \
                     "zm-convertd-admin-zimlet" \
                     "zm-delegated-admin-zimlet" \
                     "zm-hsm-admin-zimlet" \
                     "zm-smime-cert-admin-zimlet" \
                     "zm-2fa-admin-zimlet" \
                     "zm-ucconfig-admin-zimlet" \
                     "zm-securemail-zimlet" \
                     "zm-smime-applet" \
                     "zm-mobile-sync-admin-zimlet" )
      for i in "${adminZimlets[@]}"
      do
            install_zimlets_from zimlets-network ${i}/build/zimlet/
      done

      adminUcZimlets=( "cisco" "mitel" "voiceprefs" )
      for i in "${adminUcZimlets[@]}"
      do
            install_zimlets_from zimlets-network zm-uc-admin-zimlets/${i}/build/zimlet/
      done
    fi

    CreatePackage "${os}"
}

#-------------------- Util Functions ---------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

CreateDebianPackage()
{
    # FIXME: check whether this explicit md5sum generation is necessary
    (cd ${repoDir}/zm-build/${currentPackage}; find . -type f ! -regex '.*jetty_base/webapps/zimbra/WEB-INF/jetty-env.xml' ! \
        -regex '.*jetty_base/webapps/zimbraAdmin/WEB-INF/jetty-env.xml' ! -regex '.*jetty_base/modules/setuid.mod' ! \
        -regex '.*jetty_base/etc/krb5.ini' ! -regex '.*jetty_base/etc/spnego.properties' ! -regex '.*jetty_base/etc/jetty.xml' ! \
        -regex '.*jetty_base/etc/spnego.conf' ! -regex '.*jetty_base/webapps/zimbraAdmin/WEB-INF/web.xml' ! \
        -regex '.*jetty_base/webapps/zimbra/WEB-INF/web.xml' ! -regex '.*jetty_base/webapps/service/WEB-INF/web.xml' ! \
        -regex '.*jetty_base/work/.*' ! -regex '.*.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -print0 | xargs -0 md5sum | \sed -e 's| \./| |' \
        > ${repoDir}/zm-build/${currentPackage}/DEBIAN/md5sums)

    (
        set -e
        MORE_DEPENDS="$(find ${repoDir}/zm-packages/ -name \*.deb \
                         | xargs -n1 basename \
                         | sed -e 's/_[0-9].*//' \
                         | grep -e zimbra-mbox- \
                         | sed '1s/^/, /; :a; {N;s/\n/, /;ba}')";
        mkdeb_gen_control
    )
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
            	-e "s/@@RELEASE@@/${buildTimeStamp}/" \
                -e "s/@@MORE_DEPENDS@@/${MORE_DEPENDS}/" \
                -e "s/@@PKG_OS_TAG@@/${PKG_OS_TAG}/" \
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

   if [ "${buildType}" == "NETWORK" ]
   then
      echo "%attr(-, zimbra, zimbra) /opt/zimbra/zimlets-network" >> \
         ${repoDir}/zm-build/${currentScript}.spec
      echo "%attr(-, zimbra, zimbra) /opt/zimbra/extensions-network-extra" >> \
         ${repoDir}/zm-build/${currentScript}.spec
   fi

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
