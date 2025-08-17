#!/bin/bash
# crave run --clean --no-patch -- "curl https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/crave.sh | bash"

rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86

# Repo Init
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
curl -L --create-dirs https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/peridot.xml -o .repo/local_manifests/local_manifest.xml
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

# Export
export BUILD_USERNAME=regloom
export BUILD_HOSTNAME=crave
export TZ="Europe/Berlin"
echo "======= Export Done ======"

# Set up build environment
. build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch lineage_peridot-bp1a-userdebug 
echo "============="

# Install clean
m installclean

# Build rom
m bacon
