# SPDX-License-Identifier: GPL-2.0-only

Copy()
{
   if [ $# -ne 2 ]
   then
      echo "Usage: Copy <file1> <file2>" 1>&2
      exit 1;
   fi

   local src_file="$1"; shift;
   local dest_file="$1"; shift;

   mkdir -p "$(dirname "$dest_file")"

   cp -f "$src_file" "$dest_file"
}

Cpy2()
{
   if [ $# -ne 2 ]
   then
      echo "Usage: Cpy2 <file1> <dir>" 1>&2
      exit 1;
   fi

   local src_file="$1"; shift;
   local dest_dir="$1"; shift;

   mkdir -p "$dest_dir"

   cp -f "$src_file" "$dest_dir"
}

Log()
{
    echo "${currentPackage}: $*" >&2
}

CreatePackage()
{
    if [ $# -ne 1 ]
    then
      echo "Usage: CreatePackage <os-name>" 1>&2
      exit 1
    fi

    if [[ $1 == UBUNTU* ]]
    then
        CreateDebianPackage
    elif [[ $1 == RHEL* ]]
    then
        CreateRhelPackage
    else
        echo "OS not supported. Run using UBUNTU or RHEL system. "
        exit 1
    fi

    if [ $? -ne 0 ]; then
        Log "### package building failed ###"
        exit 1
    else
        Log "package successfully created"
    fi
}

DebianFinish()
{
    packageDir=`realpath $packageDir`
    mkdir -p ${packageDir} ${repoDir}/zm-build/${currentPackage}/DEBIAN

    # fixme: check for post script
    cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.deb \
    | sed -e "s/@@VERSION@@/${releaseNo}.${releaseCandidate}.${buildNo}.${os/_/.}/" \
          -e "s/@@ARCH@@/${arch}/" \
          -e "s/@@MORE_DEPENDS@@/${MORE_DEPENDS}/" \
          -e "/^%post$/ r ${currentPackage}.post" \
    > ${repoDir}/zm-build/${currentPackage}/DEBIAN/control

    (cd ${repoDir}/zm-build/${currentPackage}; dpkg -b ${repoDir}/zm-build/${currentPackage} ${packageDir})
}
