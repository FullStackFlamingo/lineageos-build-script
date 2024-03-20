#!/bin/bash

set -eEuo pipefail

# https://wiki.lineageos.org/devices/sunfish/build/#initialize-the-lineageos-source-repository
cd "$SRC_DIR"
# Remove previous changes (if they exist)
echo ">> [$(date)] Remove previous changes (if they exist)" | tee -a "$REPO_LOG"
for path in "vendor/lineage" "frameworks/base" "build/core" "device/google/sunfish" "device/google/gs101"; do
    if [ -d "$path" ]; then
    cd "$path"
    git reset -q --hard
    git clean -q -fd
    cd $SRC_DIR
    fi
done


echo ">> [$(date)] (Re)initializing branch repository" | tee -a "$REPO_LOG"
repo init -u https://github.com/LineageOS/android.git -b "$BRANCH_NAME" --git-lfs --depth=1 | tee -a "$REPO_LOG"

# lineageos4microg
vendor=lineage
# Copy local manifests *.xml to the appropriate folder in order take them into consideration
echo ">> [$(date)] Copying '$LMANIFEST_DIR/*.xml' to '.repo/local_manifests/'"
mkdir -p .repo/local_manifests
rsync -a --delete --include '*.xml' --exclude '*' "$LMANIFEST_DIR/" .repo/local_manifests/

# ALTERNATIVE TO  https://wiki.lineageos.org/devices/sunfish/build/#extract-proprietary-blobs
# add muppets.xml manifest to $LMANIFEST_DIR
# rm -f .repo/local_manifests/proprietary.xml
# wget -q -O .repo/local_manifests/proprietary.xml "https://raw.githubusercontent.com/TheMuppets/manifests/$THEMUPPETS_BRANCH_NAME/muppets.xml"

# https://wiki.lineageos.org/devices/sunfish/build/#download-the-source-code
echo ">> [$(date)] Syncing branch repository" | tee -a "$REPO_LOG"
builddate=$(date +%Y%m%d)
repo sync --jobs $(nproc --all) --retry-fetches 2 -c --force-sync | tee -a "$REPO_LOG"

if [ ! -d "vendor/$vendor" ]; then
    echo ">> [$(date)] Missing \"vendor/$vendor\", aborting"
    exit 1
fi

# figure out Lineage version to name output file
makefile_containing_version="vendor/$vendor/config/common.mk"
if [ -f "vendor/$vendor/config/version.mk" ]; then
    makefile_containing_version="vendor/$vendor/config/version.mk"
fi
los_ver_major=$(sed -n -e 's/^\s*PRODUCT_VERSION_MAJOR = //p' "$makefile_containing_version")
los_ver_minor=$(sed -n -e 's/^\s*PRODUCT_VERSION_MINOR = //p' "$makefile_containing_version")
los_ver="$los_ver_major.$los_ver_minor"

echo ">> [$(date)] Setting \"$RELEASE_TYPE\" as release type"
sed -i "/\$(filter .*\$(${vendor^^}_BUILDTYPE)/,/endif/d" "$makefile_containing_version"

# Apply the microG's signature spoofing patch (modified to try native LineageOS implementation)
## Set up our overlay
echo ">> [$(date)] Set up our overlay"
mkdir -p "vendor/$vendor/overlay/OVERRIDES/"
sed -i "1s;^;PRODUCT_PACKAGE_OVERLAYS := vendor/$vendor/overlay/OVERRIDES\n;" "vendor/$vendor/config/common.mk"
# Override device-specific settings for the location providers
mkdir -p "vendor/$vendor/overlay/OVERRIDES/frameworks/base/core/res/res/values/"
cp $INIT_DIR/patches/frameworks_base_config.xml "vendor/$vendor/overlay/OVERRIDES/frameworks/base/core/res/res/values/config.xml"

# PATCH
cd $SRC_DIR/frameworks/base
# frameworks_base_patch="android_frameworks_base-Android14.patch"
# echo ">> [$(date)] Applying the restricted signature spoofing patch (based on $frameworks_base_patch) to frameworks/base"
# Ensure patch has android:protectionLevel="signature|privileged" (Not "dangerous") https://developer.android.com/guide/topics/manifest/permission-element#plevel
# patch --quiet --force -p1 -i $INIT_DIR/patches/$frameworks_base_patch
echo ">> [$(date)] Enabling LineageOS's built-in microg spoofing for *user* build"
# https://review.lineageos.org/c/LineageOS/android_frameworks_base/+/383574
# https://github.com/LineageOS/android_frameworks_base/compare/lineage-21.0...FullStackFlamingo:android_frameworks_base:patch-1
patch --quiet --force -p1 -i $INIT_DIR/patches/android_frameworks_base-lineage-21-allow-microg-on-user-build.patch
git clean -q -f

cd "$SRC_DIR"

echo ">> [$(date)] Adding keys path ($KEYS_DIR)"
# symlink as Soong (Android 9+) complains if the signing keys are outside the build path
ln -sf "$KEYS_DIR" user-keys
sed -i "1s;^;PRODUCT_DEFAULT_DEV_CERTIFICATE := user-keys/releasekey\nPRODUCT_OTA_PUBLIC_KEYS := user-keys/releasekey\n\n;" "vendor/$vendor/config/common.mk"


# https://wiki.lineageos.org/devices/sunfish/build/#prepare-the-device-specific-code
echo ">> [$(date)] breakfast preparing build environment"
set +eu
source build/envsetup.sh > /dev/null
breakfast "$DEVICE" "$BUILD_TYPE" | tee -a "$DEBUG_LOG"
breakfast_returncode=$?
if [ $breakfast_returncode -ne 0 ]; then
    echo ">> [$(date)] breakfast failed for $DEVICE, $BRANCH_NAME branch" | tee -a "$DEBUG_LOG"
    exit 1
fi
set -eu

# PATCH AVB
# https://xdaforums.com/t/guide-re-locking-the-bootloader-on-the-google-pixel-6-with-a-self-signed-build-of-los-20-0.4555419/
# https://android.googlesource.com/platform/external/avb/+/master/README.md#build-system-integration
echo ">> [$(date)] patch core_Makefile"
cd $SRC_DIR/build/make
patch --quiet --force -p1 -i $INIT_DIR/patches/core_Makefile-21.0.patch

ESCAPED_RELEASE_KEY_PATH=$(printf '%s\n' "$KEYS_DIR/releasekey.pem" | sed -e 's/[\/&]/\\&/g')
echo ">> [$(date)] patch device/google/sunfish"
cd $SRC_DIR/device/google/sunfish
# https://github.com/LineageOS/android_device_google_sunfish/blob/lineage-21/BoardConfigLineage.mk
sed -i "$ a BOARD_AVB_ALGORITHM := SHA256_RSA4096" BoardConfigLineage.mk
sed -i "$ a BOARD_AVB_KEY_PATH := $KEYS_DIR/releasekey.pem" BoardConfigLineage.mk
sed -i 's/^BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3/#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3/' BoardConfigLineage.mk
# https://github.com/LineageOS/android_device_google_sunfish/blob/lineage-21/BoardConfig-common.mk
sed -i "s/external\/avb\/test\/data\/testkey_rsa2048.pem/$ESCAPED_RELEASE_KEY_PATH/" BoardConfig-common.mk
sed -i 's/SHA256_RSA2048/SHA256_RSA4096/' BoardConfig-common.mk

#for pixel 6+ gs101 == tensor chip
# echo ">> [$(date)] patch device/google/gs101"
# cd $SRC_DIR/device/google/gs101
# https://github.com/LineageOS/android_device_google_gs101/blob/lineage-21/BoardConfigLineage.mk
# sed -i "$ a BOARD_AVB_ALGORITHM := SHA256_RSA4096" BoardConfigLineage.mk
# sed -i "$ a BOARD_AVB_KEY_PATH := $KEYS_DIR/releasekey.pem" BoardConfigLineage.mk
# sed -i 's/^BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3/#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3/' BoardConfigLineage.mk
# https://github.com/LineageOS/android_device_google_gs101/blob/lineage-21/BoardConfig-common.mk
# sed -i "s/external\/avb\/test\/data\/testkey_rsa2048.pem/$ESCAPED_REPLACE/" BoardConfig-common.mk
# sed -i 's/SHA256_RSA2048/SHA256_RSA4096/' BoardConfig-common.mk

cd "$SRC_DIR"
