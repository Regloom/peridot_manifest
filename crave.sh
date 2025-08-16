#!/bin/bash

# Run sample
# crave run --clean --no-patch -- "curl https://gist.githubusercontent.com/Regloom/dc650e6f9ba6a035b994f9bb714206b6/raw/crave.sh | bash"

# LOS Repo init
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs

# Cleansing
rm -rf .repo/local_manifests
rm -rf prebuilts/clang/host/linux-x86

rm -rf device/xiaomi/peridot
rm -rf vendor/xiaomi/peridot
rm -rf device/xiaomi/peridot-kernel
rm -rf hardware/xiaomi

rm -rf hardware/qcom-caf/common
rm -rf hardware/qcom-caf/sm8650
rm -rf device/qcom/sepolicy_vndr/sm8650

# Manifest
curl -L --create-dirs https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/peridot.xml -o .repo/local_manifests/local_manifest.xml

# Build Sync
/opt/crave/resync.sh

# Don't need sm8750 ...
# rm -rf hardware/qcom-caf/sm8750

# Build
. build/envsetup.sh
lunch lineage_peridot-bp1a-userdebug && m bacon
