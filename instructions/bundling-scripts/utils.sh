#!/bin/bash

log() {
    local indent="$1"
    shift
    for (( i=1 ; ((i-$indent)) ; i=(($i+1)) )) do echo -e "\t" >> ${buildLogFile} ; done
    echo -e "$@" >> ${buildLogFile}
}

CreatePackage()
{
    if [ $# -ne 1 ]
    then
      echo "Usage: CreatePackage <os-name>" 1>&2
      exit 1
    fi

    case "$1" in
        UBUNTU*|DEBIAN*)
            mkdeb_begin
            CreateDebianPackage
            mkdeb_finish
        ;;
        RHEL*)
            CreateRhelPackage
            mkrpm_finish
        ;;
        *)
            echo "OS \"$1\" not supported. Run using UBUNTU/DEBIAN or RHEL system. "
            exit 1
        ;;
    esac

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

    (
        echo "creating deb control: ${currentPackage}"
        echo "        MORE_DEPENDS: ${MORE_DEPENDS}"
    ) >&2

    mkdir -p ${repoDir}/zm-build/${currentPackage}/DEBIAN/
    cat ${repoDir}/zm-build/pkg/debian/${currentScript}.in \
        | sed -e "s/@@VERSION@@/${releaseNo}.${releaseCandidate}.${buildNo}.${os/_/.}/" \
              -e "s/@@branch@@/${buildTimeStamp}/" \
              -e "s/@@ARCH@@/${debarch}/" \
              -e "s/@@MORE_DEPENDS@@/${MORE_DEPENDS}/" \
              -e "s/@@PKG_OS_TAG@@/${PKG_OS_TAG}/" > ${repoDir}/zm-build/${currentPackage}/DEBIAN/control
}

install_file() {
    local src="${repoDir}/$1"
    local dst="$(target_dir $2)"

    case "$dst" in
        */)
            mkdir -p "$dst"
        ;;
        *)
            mkdir -p $(dirname "$dst")
        ;;
    esac
    # note: do not quote src, so * can be resolved
    cp -f $src "$dst"
}

install_subtree() {
    local src="${repoDir}/$1"
    local dst="$(target_dir $2)"

    mkdir -p "$dst"
    cp -Rf $src/* "$dst"
}

install_dirs() {
    while [ "$1" ]; do
        mkdir -p "$(target_dir $1)"
        shift
    done
}

install_docs() {
    while [ "$1" ]; do
        log 3 "installing doc: $1"
        install_file "$1" opt/zimbra/docs/
        shift;
    done
}

install_libexec() {
    while [ "$1" ]; do
        log 3 "installing libexec: $1"
        install_file "$1" opt/zimbra/libexec/
        shift;
    done
}

install_libexec_scripts() {
    while [ "$1" ]; do
        log 3 "installing libexec/scripts: $1"
        install_file "$1" opt/zimbra/libexec/scripts/
        shift;
    done
}

install_bin() {
    while [ "$1" ]; do
        log 3 "installing bin: $1"
        install_file "$1" opt/zimbra/bin/
        shift;
    done
}

install_lib() {
    while [ "$1" ]; do
        log 3 "installing lib: $1"
        install_file "$1" opt/zimbra/lib/
        shift;
    done
}

install_jar() {
    while [ "$1" ]; do
        log 3 "installing jar: $1"
        install_file "$1" opt/zimbra/lib/jars/
        shift;
    done
}

install_conf() {
    while [ "$1" ]; do
        log 3 "installing conf: $1"
        install_file "$1" opt/zimbra/conf/
        shift;
    done
}

install_bin_from() {
    local srcdir="$1"
    shift
    while [ "$1" ]; do
        install_bin "$srcdir/$1"
        shift
    done
}

install_libexec_from() {
    local srcdir="$1"
    shift
    while [ "$1" ]; do
        install_libexec "$srcdir/$1"
        shift
    done
}

install_conf_from() {
    local srcdir="$1"
    shift
    while [ "$1" ]; do
        install_conf "$srcdir/$1"
        shift
    done
}

install_libexec_scripts_from() {
    local srcdir="$1"
    shift
    while [ "$1" ]; do
        install_libexec_scripts "$srcdir/$1"
        shift
    done
}

install_zimlets_from() {
    local target="$(target_dir opt/zimbra/$1)"
    shift
    mkdir -p "${target}"

    while [ "$1" ]; do
        cp ${repoDir}/$1/*.zip ${target}
        shift
    done
}

mkrpm_finish() {
    (
        cd ${repoDir}/zm-build/${currentPackage} && \
        rpmbuild \
            --target ${arch} \
            --define '_rpmdir ../' \
            --buildroot=${repoDir}/zm-build/${currentPackage} \
            -bb ${repoDir}/zm-build/${currentScript}.spec
    )
}

mkrpm_template() {
    cat ${repoDir}/zm-build/rpmconf/Spec/${currentScript}.spec | \
    sed -e "s/@@VERSION@@/${releaseNo}_${releaseCandidate}_${buildNo}.${os} /" \
        -e "s/@@RELEASE@@/${buildTimeStamp}/" \
        -e "s/@@MORE_DEPENDS@@/${MORE_DEPENDS}/" \
        -e "s/@@PKG_OS_TAG@@/${PKG_OS_TAG}/" \
        -e "s/^Copyright:/Copyright:/"
}

mkrpm_writespec() {
    cat > ${repoDir}/zm-build/${currentScript}.spec
}
