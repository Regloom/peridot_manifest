#!/bin/bash
# LineageOS 24 build for Poco F6 (peridot) on crave.io:
#   crave run --clean --no-patch -- "curl -sL https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/24/crave.sh | bash"

BRANCH=24
MANIFEST_URL=https://github.com/Regloom/peridot_manifest
MANIFEST_DIR=/tmp/peridot_manifest

rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86

echo "====== Repo init ======"
repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs || exit 1
curl -sL --create-dirs "$MANIFEST_URL/raw/refs/heads/$BRANCH/local_manifest.xml" \
    -o .repo/local_manifests/local_manifest.xml || exit 1

echo "====== Sync ======"
/opt/crave/resync.sh

echo "====== Patches ======"
rm -rf "$MANIFEST_DIR"
git clone -q --depth=1 -b "$BRANCH" "$MANIFEST_URL.git" "$MANIFEST_DIR" || exit 1
bash "$MANIFEST_DIR/patches/import_patches.sh" || exit 1

echo "====== Envsetup ======"
export BUILD_USERNAME=regloom
export BUILD_HOSTNAME=crave
export TZ="Europe/Berlin"
# error: libandroid's ABI has INCOMPATIBLE CHANGES.
export SKIP_ABI_CHECKS=true
source build/envsetup.sh

echo "====== Build ======"
lunch lineage_peridot-cp2a-userdebug || exit 1
m bacon
