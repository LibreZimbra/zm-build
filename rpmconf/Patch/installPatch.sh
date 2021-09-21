#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only

ID=$(id -un)
if [ x"$ID" != "xroot" ]; then
  echo "$0 must be run as root."
  exit 1
fi

if [ $# -gt 1 ]
then
  echo "usage: $0 [--force]"
  exit 1
fi
if [ "x$1" != "x--force" -a "x$1" != "x" ]
then
  echo "usage: $0 [--force]"
  exit 1
fi

/usr/bin/perl bin/zmpatch.pl --config conf/zmpatch.xml --verbose $1
