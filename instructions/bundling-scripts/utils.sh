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

    case "$1" in
        UBUNTU*|DEBIAN*)
            CreateDebianPackage
        ;;
        RHEL*)
            CreateRhelPackage
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
