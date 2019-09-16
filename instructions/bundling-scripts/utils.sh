#!/bin/bash

log() {
    local indent="$1"
    shift
    for (( i=1 ; ((i-$indent)) ; i=(($i+1)) )) do echo -e "\t" >> ${buildLogFile} ; done
    echo -e "$@" >> ${buildLogFile}
}

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

CreatePackage()
{
    if [ $# -ne 1 ]
    then
      echo "Usage: CreatePackage <os-name>" 1>&2
      exit 1
    fi

    if [[ $1 == UBUNTU* ]]
    then
        mkdeb_begin
        CreateDebianPackage
        mkdeb_finish
    elif [[ $1 == RHEL* ]]
    then
        CreateRhelPackage
    else
        echo "OS not supported. Run using UBUNTU or RHEL system. "
        exit 1
    fi

    if [ $? -ne 0 ]; then
        log 1 "### ${currentPackage} package building failed ###"
    else
        log 1 "*** ${currentPackage} package successfully created ***"
    fi
}

target_dir() {
    echo -n "${repoDir}/zm-build/${currentPackage}/$1"
}

mkdeb_begin() {
    log 1 "Create debian package"

    local debdir="$(target_dir DEBIAN)"

    rm -Rf "${debdir}"
    mkdir -p "${debdir}"

    if [ -f "${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post" ]; then
        cp "${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.post" \
           "${debdir}/postinst"
        chmod 555 "${debdir}/postinst"
    fi

    if [ -f "${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.pre" ]; then
        cp "${repoDir}/zm-build/rpmconf/Spec/Scripts/${currentScript}.pre" \
           "${debdir}/preinst"
        chmod 555 "${debdir}/preinst"
    fi
}

mkdeb_finish() {
    local debdir="$(target_dir DEBIAN)"

    # package script might already have created it differently
    if [ ! -f ${debdir}/md5sums ]; then
        (
            cd $(target_dir)
            find . -type f ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -print0 | \
                xargs -0 md5sum | sed -e 's| \./| |'
        ) > ${debdir}/md5sums
    fi

    (
        set -e
        cd $(target_dir)
        dpkg -b $(target_dir) ${repoDir}/zm-build/${arch}
    )
}

mkdeb_gen_control() {
    local debarch=""

    case "${arch}" in
        x86_64) debarch="amd64";;
        *) debarch="${arch}";;
    esac

    mkdir -p ${repoDir}/zm-build/${currentPackage}/DEBIAN/
    cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.deb \
        | sed -e "s/@@VERSION@@/${releaseNo}.${releaseCandidate}.${buildNo}.${os/_/.}/" \
              -e "s/@@branch@@/${buildTimeStamp}/" \
              -e "s/@@ARCH@@/${debarch}/" \
              -e "s/@@MORE_DEPENDS@@/${MORE_DEPENDS}/" \
              -e "s/@@PKG_OS_TAG@@/${PKG_OS_TAG}/" > ${repoDir}/zm-build/${currentPackage}/DEBIAN/control
}
