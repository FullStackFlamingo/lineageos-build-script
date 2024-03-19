#!/bin/bash

export INIT_DIR=$(pwd)
WORKING_DIR="/home/ubuntu/AOSP/LineageOS111"
export SRC_DIR="$WORKING_DIR/lineage"
export ZIP_DIR="$WORKING_DIR/zips"
export LMANIFEST_DIR="$WORKING_DIR/local_manifests"
export KEYS_DIR="$WORKING_DIR/keys"
export LOGS_DIR="$WORKING_DIR/logs"

export REPO_LOG="$LOGS_DIR/repo-$(date +%Y%m%d).log"
export DEBUG_LOG="$LOGS_DIR/debug-$(date +%Y%m%d).log"

# https://github.com/LineageOS/android/branches for possible options
export BRANCH_NAME="lineage-21.0"
export THEMUPPETS_BRANCH_NAME="lineage-21.0"

export DEVICE="sunfish"
export BUILD_TYPE="user"
# Release type string
export RELEASE_TYPE="UNOFFICIAL"

# https://wiki.lineageos.org/devices/sunfish/build/#turn-on-caching-to-speed-up-build
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR="$WORKING_DIR/ccache"

# To include microG (or possibly the actual Google Mobile Services) in your build,
# LineageOS expects certain Makefiles in vendor/partner_gms and variable WITH_GMS set to true.
# This repo contains the common packages included for official lineageos4microg builds.
# To include it in your build, create an XML (the name is irrelevant, as long as it ends with .xml)
# in the $LMANIFEST_DIR folder with this content:
export WITH_GMS=true # BY LINEAGE - Possibly reduces spare unused space