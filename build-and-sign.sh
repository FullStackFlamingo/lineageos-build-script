#!/bin/bash
 
set -eEuo pipefail

cd "$SRC_DIR"

# https://wiki.lineageos.org/signing_builds#generating-and-signing-target-files
# https://wiki.lineageos.org/devices/sunfish/build/#start-the-build
echo ">> [$(date)] Starting build target-files-package otatools" | tee -a "$DEBUG_LOG"
mka target-files-package otatools | tee -a "$DEBUG_LOG"


#   $OUT set by build/envsetup.sh?

# https://wiki.lineageos.org/signing_builds#generating-and-signing-target-files
# croot
./build/tools/releasetools/sign_target_files_apks -o -d $KEYS_DIR \
    --extra_apks com.android.adbd.apex=$KEYS_DIR/com.android.adbd \
    --extra_apks com.android.adservices.apex=$KEYS_DIR/com.android.adservices \
    --extra_apks com.android.adservices.api.apex=$KEYS_DIR/com.android.adservices.api \
    --extra_apks com.android.appsearch.apex=$KEYS_DIR/com.android.appsearch \
    --extra_apks com.android.art.apex=$KEYS_DIR/com.android.art \
    --extra_apks com.android.bluetooth.apex=$KEYS_DIR/com.android.bluetooth \
    --extra_apks com.android.btservices.apex=$KEYS_DIR/com.android.btservices \
    --extra_apks com.android.cellbroadcast.apex=$KEYS_DIR/com.android.cellbroadcast \
    --extra_apks com.android.compos.apex=$KEYS_DIR/com.android.compos \
    --extra_apks com.android.configinfrastructure.apex=$KEYS_DIR/com.android.configinfrastructure \
    --extra_apks com.android.connectivity.resources.apex=$KEYS_DIR/com.android.connectivity.resources \
    --extra_apks com.android.conscrypt.apex=$KEYS_DIR/com.android.conscrypt \
    --extra_apks com.android.devicelock.apex=$KEYS_DIR/com.android.devicelock \
    --extra_apks com.android.extservices.apex=$KEYS_DIR/com.android.extservices \
    --extra_apks com.android.hardware.wifi.apex=$KEYS_DIR/com.android.hardware.wifi \
    --extra_apks com.android.healthfitness.apex=$KEYS_DIR/com.android.healthfitness \
    --extra_apks com.android.hotspot2.osulogin.apex=$KEYS_DIR/com.android.hotspot2.osulogin \
    --extra_apks com.android.i18n.apex=$KEYS_DIR/com.android.i18n \
    --extra_apks com.android.ipsec.apex=$KEYS_DIR/com.android.ipsec \
    --extra_apks com.android.media.apex=$KEYS_DIR/com.android.media \
    --extra_apks com.android.media.swcodec.apex=$KEYS_DIR/com.android.media.swcodec \
    --extra_apks com.android.mediaprovider.apex=$KEYS_DIR/com.android.mediaprovider \
    --extra_apks com.android.nearby.halfsheet.apex=$KEYS_DIR/com.android.nearby.halfsheet \
    --extra_apks com.android.networkstack.tethering.apex=$KEYS_DIR/com.android.networkstack.tethering \
    --extra_apks com.android.neuralnetworks.apex=$KEYS_DIR/com.android.neuralnetworks \
    --extra_apks com.android.ondevicepersonalization.apex=$KEYS_DIR/com.android.ondevicepersonalization \
    --extra_apks com.android.os.statsd.apex=$KEYS_DIR/com.android.os.statsd \
    --extra_apks com.android.permission.apex=$KEYS_DIR/com.android.permission \
    --extra_apks com.android.resolv.apex=$KEYS_DIR/com.android.resolv \
    --extra_apks com.android.rkpd.apex=$KEYS_DIR/com.android.rkpd \
    --extra_apks com.android.runtime.apex=$KEYS_DIR/com.android.runtime \
    --extra_apks com.android.safetycenter.resources.apex=$KEYS_DIR/com.android.safetycenter.resources \
    --extra_apks com.android.scheduling.apex=$KEYS_DIR/com.android.scheduling \
    --extra_apks com.android.sdkext.apex=$KEYS_DIR/com.android.sdkext \
    --extra_apks com.android.support.apexer.apex=$KEYS_DIR/com.android.support.apexer \
    --extra_apks com.android.telephony.apex=$KEYS_DIR/com.android.telephony \
    --extra_apks com.android.telephonymodules.apex=$KEYS_DIR/com.android.telephonymodules \
    --extra_apks com.android.tethering.apex=$KEYS_DIR/com.android.tethering \
    --extra_apks com.android.tzdata.apex=$KEYS_DIR/com.android.tzdata \
    --extra_apks com.android.uwb.apex=$KEYS_DIR/com.android.uwb \
    --extra_apks com.android.uwb.resources.apex=$KEYS_DIR/com.android.uwb.resources \
    --extra_apks com.android.virt.apex=$KEYS_DIR/com.android.virt \
    --extra_apks com.android.vndk.current.apex=$KEYS_DIR/com.android.vndk.current \
    --extra_apks com.android.wifi.apex=$KEYS_DIR/com.android.wifi \
    --extra_apks com.android.wifi.dialog.apex=$KEYS_DIR/com.android.wifi.dialog \
    --extra_apks com.android.wifi.resources.apex=$KEYS_DIR/com.android.wifi.resources \
    --extra_apks com.google.pixel.vibrator.hal.apex=$KEYS_DIR/com.google.pixel.vibrator.hal \
    --extra_apks com.qorvo.uwb.apex=$KEYS_DIR/com.qorvo.uwb \
    --extra_apex_payload_key com.android.adbd.apex=$KEYS_DIR/com.android.adbd.pem \
    --extra_apex_payload_key com.android.adservices.apex=$KEYS_DIR/com.android.adservices.pem \
    --extra_apex_payload_key com.android.adservices.api.apex=$KEYS_DIR/com.android.adservices.api.pem \
    --extra_apex_payload_key com.android.appsearch.apex=$KEYS_DIR/com.android.appsearch.pem \
    --extra_apex_payload_key com.android.art.apex=$KEYS_DIR/com.android.art.pem \
    --extra_apex_payload_key com.android.bluetooth.apex=$KEYS_DIR/com.android.bluetooth.pem \
    --extra_apex_payload_key com.android.btservices.apex=$KEYS_DIR/com.android.btservices.pem \
    --extra_apex_payload_key com.android.cellbroadcast.apex=$KEYS_DIR/com.android.cellbroadcast.pem \
    --extra_apex_payload_key com.android.compos.apex=$KEYS_DIR/com.android.compos.pem \
    --extra_apex_payload_key com.android.configinfrastructure.apex=$KEYS_DIR/com.android.configinfrastructure.pem \
    --extra_apex_payload_key com.android.connectivity.resources.apex=$KEYS_DIR/com.android.connectivity.resources.pem \
    --extra_apex_payload_key com.android.conscrypt.apex=$KEYS_DIR/com.android.conscrypt.pem \
    --extra_apex_payload_key com.android.devicelock.apex=$KEYS_DIR/com.android.devicelock.pem \
    --extra_apex_payload_key com.android.extservices.apex=$KEYS_DIR/com.android.extservices.pem \
    --extra_apex_payload_key com.android.hardware.wifi.apex=$KEYS_DIR/com.android.hardware.wifi.pem \
    --extra_apex_payload_key com.android.healthfitness.apex=$KEYS_DIR/com.android.healthfitness.pem \
    --extra_apex_payload_key com.android.hotspot2.osulogin.apex=$KEYS_DIR/com.android.hotspot2.osulogin.pem \
    --extra_apex_payload_key com.android.i18n.apex=$KEYS_DIR/com.android.i18n.pem \
    --extra_apex_payload_key com.android.ipsec.apex=$KEYS_DIR/com.android.ipsec.pem \
    --extra_apex_payload_key com.android.media.apex=$KEYS_DIR/com.android.media.pem \
    --extra_apex_payload_key com.android.media.swcodec.apex=$KEYS_DIR/com.android.media.swcodec.pem \
    --extra_apex_payload_key com.android.mediaprovider.apex=$KEYS_DIR/com.android.mediaprovider.pem \
    --extra_apex_payload_key com.android.nearby.halfsheet.apex=$KEYS_DIR/com.android.nearby.halfsheet.pem \
    --extra_apex_payload_key com.android.networkstack.tethering.apex=$KEYS_DIR/com.android.networkstack.tethering.pem \
    --extra_apex_payload_key com.android.neuralnetworks.apex=$KEYS_DIR/com.android.neuralnetworks.pem \
    --extra_apex_payload_key com.android.ondevicepersonalization.apex=$KEYS_DIR/com.android.ondevicepersonalization.pem \
    --extra_apex_payload_key com.android.os.statsd.apex=$KEYS_DIR/com.android.os.statsd.pem \
    --extra_apex_payload_key com.android.permission.apex=$KEYS_DIR/com.android.permission.pem \
    --extra_apex_payload_key com.android.resolv.apex=$KEYS_DIR/com.android.resolv.pem \
    --extra_apex_payload_key com.android.rkpd.apex=$KEYS_DIR/com.android.rkpd.pem \
    --extra_apex_payload_key com.android.runtime.apex=$KEYS_DIR/com.android.runtime.pem \
    --extra_apex_payload_key com.android.safetycenter.resources.apex=$KEYS_DIR/com.android.safetycenter.resources.pem \
    --extra_apex_payload_key com.android.scheduling.apex=$KEYS_DIR/com.android.scheduling.pem \
    --extra_apex_payload_key com.android.sdkext.apex=$KEYS_DIR/com.android.sdkext.pem \
    --extra_apex_payload_key com.android.support.apexer.apex=$KEYS_DIR/com.android.support.apexer.pem \
    --extra_apex_payload_key com.android.telephony.apex=$KEYS_DIR/com.android.telephony.pem \
    --extra_apex_payload_key com.android.telephonymodules.apex=$KEYS_DIR/com.android.telephonymodules.pem \
    --extra_apex_payload_key com.android.tethering.apex=$KEYS_DIR/com.android.tethering.pem \
    --extra_apex_payload_key com.android.tzdata.apex=$KEYS_DIR/com.android.tzdata.pem \
    --extra_apex_payload_key com.android.uwb.apex=$KEYS_DIR/com.android.uwb.pem \
    --extra_apex_payload_key com.android.uwb.resources.apex=$KEYS_DIR/com.android.uwb.resources.pem \
    --extra_apex_payload_key com.android.virt.apex=$KEYS_DIR/com.android.virt.pem \
    --extra_apex_payload_key com.android.vndk.current.apex=$KEYS_DIR/com.android.vndk.current.pem \
    --extra_apex_payload_key com.android.wifi.apex=$KEYS_DIR/com.android.wifi.pem \
    --extra_apex_payload_key com.android.wifi.dialog.apex=$KEYS_DIR/com.android.wifi.dialog.pem \
    --extra_apex_payload_key com.android.wifi.resources.apex=$KEYS_DIR/com.android.wifi.resources.pem \
    --extra_apex_payload_key com.google.pixel.vibrator.hal.apex=$KEYS_DIR/com.google.pixel.vibrator.hal.pem \
    --extra_apex_payload_key com.qorvo.uwb.apex=$KEYS_DIR/com.qorvo.uwb.pem \
    $OUT/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip \
    signed-target_files.zip

builddate=$(date +%Y%m%d)

# https://wiki.lineageos.org/signing_builds#generating-the-install-package
./build/tools/releasetools/ota_from_target_files -k $KEYS_DIR/releasekey \
--block --backup=true \
signed-target_files.zip \
signed-ota_update-lineageos-$builddate.zip | tee -a "$DEBUG_LOG"



"$SRC_DIR/external/avb/avbtool" extract_public_key --key "$KEYS_DIR/releasekey.pem --output "$KEYS_DIR/avb_pkmd.bin | tee -a "$DEBUG_LOG"

