#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

packageDir=`realpath ${packageDir}`

cd ${repoDir}/zm-build

ZCS_REL=zcs-${releaseNo}_${releaseCandidate}_${buildNo}.${os}

mkdir -p $ZCS_REL/bin
mkdir -p $ZCS_REL/data
mkdir -p $ZCS_REL/docs/en_US
mkdir -p $ZCS_REL/lib/jars
mkdir -p $ZCS_REL/packages
mkdir -p $ZCS_REL/util/modules

cp -f ${repoDir}/zm-build/RE/README.txt                                                 ${ZCS_REL}/
cp -f ${repoDir}/zm-build/rpmconf/Build/checkService.pl                                 ${ZCS_REL}/bin
cp -f ${repoDir}/zm-build/rpmconf/Build/get_plat_tag.sh                                 ${ZCS_REL}/bin
cp -f ${repoDir}/zm-build/rpmconf/Build/zmValidateLdap.pl                               ${ZCS_REL}/bin
cp -f ${repoDir}/zm-build/rpmconf/Install/Util/addUser.sh                               ${ZCS_REL}/util
cp -f ${repoDir}/zm-build/rpmconf/Install/Util/globals.sh                               ${ZCS_REL}/util
cp -f ${repoDir}/zm-build/rpmconf/Install/Util/modules/getconfig.sh                     ${ZCS_REL}/util/modules
cp -f ${repoDir}/zm-build/rpmconf/Install/Util/modules/packages.sh                      ${ZCS_REL}/util/modules
cp -f ${repoDir}/zm-build/rpmconf/Install/Util/modules/postinstall.sh                   ${ZCS_REL}/util/modules
cp -f ${repoDir}/zm-build/rpmconf/Install/Util/modules/install_rabbitmq.sh              ${ZCS_REL}/util/modules
cp -f ${repoDir}/zm-build/rpmconf/Install/Util/utilfunc.sh                              ${ZCS_REL}/util
cp -f ${repoDir}/zm-build/rpmconf/Install/install.sh                                    ${ZCS_REL}/

if [ -f "/etc/redhat-release" ]
then
   if \which createrepo 2>&-
   then
      ( cd ${packageDir} && createrepo . ) # Create index of packages
   fi
else
   if \which dpkg-scanpackages 2>&-
   then
      ( cd ${packageDir} && dpkg-scanpackages . /dev/null > Packages ) # Create index of packages
   fi
fi

# all local packages to bundle
cp -f ${packageDir}/*.*                                                                 ${ZCS_REL}/packages

chmod 755 ${ZCS_REL}/bin/checkService.pl
chmod 755 ${ZCS_REL}/bin/zmValidateLdap.pl
chmod 755 ${ZCS_REL}/install.sh

cp -f ${repoDir}/zm-licenses/zimbra/zcl.txt                                             ${ZCS_REL}/docs

##########################################

echo "FOSS"                > ${ZCS_REL}/.BUILD_TYPE
echo "${buildNo}"          > ${ZCS_REL}/.BUILD_NUM
echo "${os}"               > ${ZCS_REL}/.BUILD_PLATFORM
echo "${releaseNo}"        > ${ZCS_REL}/.BUILD_RELEASE_NO
echo "${releaseCandidate}" > ${ZCS_REL}/.BUILD_RELEASE_CANDIDATE

##########################################

tar czf ${ZCS_REL}.tgz  ${ZCS_REL}

echo "ZCS build completed: ${repoDir}/zm-build/${ZCS_REL}.tgz"
