#!/bin/bash
# SPDX-License-Identifier: GPL-2+
# Copyright (C) Enrico Weigelt, metux IT consult <info@metux.net>
#
# Shell script to create zimbra-core-amavis package

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_ROOT="$SCRIPT_DIR/../../../"

#( set -e ; cd "$SRC_ROOT/zm-amavis" && ./pkg-builder.pl )

#cp $SRC_ROOT/zm-amavis/build/dist/*.deb ${repoDir}/zm-build/${arch}
