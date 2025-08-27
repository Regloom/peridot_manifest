#!/bin/bash
# crave run --clean --no-patch -- "curl https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/crave.sh | bash"

rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86
rm -rf .repo/project-objects/ .repo/projects/ #repo cache clean

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

# Cleanup unused HAL display, media, audio
rm -rf /tmp/src/android/hardware/qcom-caf/{msm8996,msm8998,sdm845,sm8150,sm8250}/{display,media,audio}
rm -rf /tmp/src/android/hardware/qcom-caf/sm8750

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

# Cleanup unused HAL display, media, audio
rm -rf hardware/qcom-caf/{msm8996,msm8998,sdm845,sm8150,sm8250}/{display,media,audio}
rm -rf hardware/qcom-caf/sm8750

# Empty build-manifest.xml to avoid missing hals error
mkdir -p out/target/product/peridot/product/etc/
echo '<?xml version="1.0" encoding="UTF-8"?><manifest></manifest>' > out/target/product/peridot/product/etc/build-manifest.xml

# Export
export BUILD_USERNAME=regloom
export BUILD_HOSTNAME=crave
export TZ="Europe/Berlin"
export TARGET_RELEASE=bp1a
echo "======= Export Done ======"

# Set up build environment
. build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
# lunch lineage_peridot-bp1a-userdebug
brunch peridot userdebug
echo "============="

# Install clean
m installclean

# Build rom
m bacon
