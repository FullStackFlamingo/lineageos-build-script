#!/bin/bash

set -eEuo pipefail

KEYS_SUBJECT="/C=US/ST=Someplace/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com"

for c in releasekey platform shared media networkstack sdk_sandbox bluetooth; do
  if [ ! -f "$KEYS_DIR/$c.pk8" ]; then
    echo ">> [$(date)]  Generating $c..."
    $INIT_DIR/make_key_4096 "$KEYS_DIR/$c" "$KEYS_SUBJECT"
  else
    echo ">> [$(date)] $c.pk8 already exists..."
  fi
done

# releasekey.pem for AVB
if [ ! -f "$KEYS_DIR/releasekey.pem" ]; then
  echo ">> [$(date)]  Generating releasekey.pem for AVB"
  openssl pkcs8 -in releasekey.pk8 -inform DER -out releasekey.pem -nocrypt
fi

# symlink cyngn-app testkey
for c in cyngn{-priv,}-app testkey; do
  for e in pk8 x509.pem; do
    ln -sf releasekey.$e "$KEYS_DIR/$c.$e" 2> /dev/null
  done
done

# Android 14 requires to set a BUILD file for bazel to avoid errors:
  cat > "$KEYS_DIR"/BUILD << _EOB
# adding an empty BUILD file fixes the A14 build error:
# "ERROR: no such package 'keys': BUILD file not found in any of the following directories. Add a BUILD file to a directory to mark it as a package."
# adding the filegroup "android_certificate_directory" fixes the A14 build error:
# "no such target '//keys:android_certificate_directory': target 'android_certificate_directory' not declared in package 'keys'"
filegroup(
name = "android_certificate_directory",
srcs = glob([
	"*.pk8",
	"*.pem",
]),
visibility = ["//visibility:public"],
)
_EOB


# https://wiki.lineageos.org/signing_builds#generate-keys-without-a-password
for apex in com.android.adbd com.android.adservices com.android.adservices.api com.android.appsearch com.android.art com.android.bluetooth com.android.btservices com.android.cellbroadcast com.android.compos com.android.configinfrastructure com.android.connectivity.resources com.android.conscrypt com.android.devicelock com.android.extservices com.android.hardware.wifi com.android.healthfitness com.android.hotspot2.osulogin com.android.i18n com.android.ipsec com.android.media com.android.media.swcodec com.android.mediaprovider com.android.nearby.halfsheet com.android.networkstack.tethering com.android.neuralnetworks com.android.ondevicepersonalization com.android.os.statsd com.android.permission com.android.resolv com.android.rkpd com.android.runtime com.android.safetycenter.resources com.android.scheduling com.android.sdkext com.android.support.apexer com.android.telephony com.android.telephonymodules com.android.tethering com.android.tzdata com.android.uwb com.android.uwb.resources com.android.virt com.android.vndk.current com.android.wifi com.android.wifi.dialog com.android.wifi.resources com.google.pixel.vibrator.hal com.qorvo.uwb; do 
  if [ ! -f "$KEYS_DIR/$apex.pk8" ]; then
    apex_subject="/C=US/ST=Someplace/L=Mountain View/O=Android/OU=Android/CN=$apex/emailAddress=android@android.com"
    $INIT_DIR/make_key_4096 "$KEYS_DIR/$apex" "$apex_subject";
    openssl pkcs8 -in "$KEYS_DIR/$apex.pk8" -inform DER -nocrypt -out "$KEYS_DIR/$apex.pem";
  else
    echo ">> [$(date)] $apex.pk8 already exists..."
  fi
done