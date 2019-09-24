#!/bin/bash
# SPDX-License-Identifier: GPL-2+
# Copyright (C) Enrico Weigelt, metux IT consult <info@metux.net>
#
# Shell script to create zimbra-timezones package

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_ROOT="$SCRIPT_DIR/../../../"

cp $SRC_ROOT/zm-timezones/build/dist/*.deb ${repoDir}/zm-build/${arch}
