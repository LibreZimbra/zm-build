#!/bin/bash
# SPDX-License-Identifier: GPL-2+
# Copyright (C) Enrico Weigelt, metux IT consult <info@metux.net>
#
# Shell script to create zimbra-timezones package

set -e

#currentScript=`basename $0 | cut -d "." -f 1`                 # zimbra-store
#currentPackage=`echo ${currentScript}build | cut -d "-" -f 2` # storebuild

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_ROOT="$SCRIPT_DIR/../../../"

( set -e ; cd "$SRC_ROOT/zm-timezones" && ./pkg-builder.pl )

cp $SRC_ROOT/zm-timezones/build/dist/*.deb ${repoDir}/zm-build/${arch}
