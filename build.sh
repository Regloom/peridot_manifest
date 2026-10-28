#!/bin/bash
# Local LineageOS 24 build for Poco F6 (peridot).
#
# Run from the root of the Android tree. Expects this repo checked out next
# to the tree (../peridot_manifest, override with MANIFEST_DIR) and, to build
# with RBE, rbe.sh copied to the tree root with a real BuildBuddy key.
#
# First-time setup:
#   repo init -u https://github.com/LineageOS/android.git -b lineage-24.0 --git-lfs
#   git clone -b 24 https://github.com/Regloom/peridot_manifest.git ../peridot_manifest
#   mkdir -p .repo/local_manifests
#   cp ../peridot_manifest/local_manifest.xml .repo/local_manifests/
#   cp ../peridot_manifest/rbe.sh ../peridot_manifest/build.sh .

MANIFEST_DIR=${MANIFEST_DIR:-../peridot_manifest}

echo "====== Sync ======"
repo sync --force-sync

echo "====== Patches ======"
bash "$MANIFEST_DIR/patches/import_patches.sh" || exit 1

echo "====== Envsetup ======"
source build/envsetup.sh
if [ -f rbe.sh ]; then
    source rbe.sh || exit 1
fi
# error: libandroid's ABI has INCOMPATIBLE CHANGES.
export SKIP_ABI_CHECKS=true

# Optional:
# export BUILD_USERNAME=regloom
# export BUILD_HOSTNAME=crave
# export TZ="Europe/Berlin"

echo "====== Build ======"
lunch lineage_peridot-cp2a-userdebug || exit 1
# m installclean
# -j3: with RBE -j only sets siso --local_jobs (remote jobs come from
# NINJA_REMOTE_NUM_JOBS). Local kotlinc runs with -Xmx8G each; 6 of them
# OOM a 30 GB machine.
m bacon -j3 | tee build-$(date +%Y%m%d-%H%M%S).log
exit ${PIPESTATUS[0]}
