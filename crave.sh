#!/bin/bash

# Run sample
# crave run --clean --no-patch -- "curl https://gist.githubusercontent.com/Regloom/dc650e6f9ba6a035b994f9bb714206b6/raw/crave.sh | bash"

# Repo Init
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs

# Sync the repositories
/opt/crave/resync.sh

# Cleansing
rm -rf device/xiaomi/peridot
rm -rf vendor/xiaomi/peridot
rm -rf device/xiaomi/peridot-kernel
rm -rf hardware/xiaomi
rm -rf hardware/qcom-caf/common
rm -rf hardware/qcom-caf/sm8650
rm -rf device/qcom/sepolicy_vndr/sm8650
rm -rf hardware/qcom-caf/sm8750
rm -rf hardware/qcom-caf/sm8650/audio/agm
rm -rf hardware/qcom-caf/sm8650/audio/pal
rm -rf hardware/qcom-caf/sm8650/audio/primary-hal
rm -rf hardware/qcom-caf/sm8650/display

# Manifest
# curl -L --create-dirs https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/peridot.xml -o .repo/local_manifests/local_manifest.xml
git clone https://github.com/Voltage-Peridot/hardware_xiaomi -b 15 hardware/xiaomi
git clone https://github.com/Regloom/device_xiaomi_peridot -b GuidixX device/xiaomi/peridot
git clone https://github.com/GuidixX/device_xiaomi_peridot-kernel -b 15 device/xiaomi/peridot-kernel
git clone https://github.com/GuidixX/vendor_xiaomi_peridot -b 15 vendor/xiaomi/peridot
git clone https://github.com/TogoFire/packages_apps_ViPER4AndroidFX -b v4a packages/apps/ViPER4AndroidFX
git clone https://github.com/Regloom/hardware_qcom-caf_common -b 15-qpr2 hardware/qcom-caf/common
git clone https://github.com/sm8635-dev/vendor_qcom_opensource_agm -b lineage-22.2-caf-sm8650 hardware/qcom-caf/sm8650/audio/agm
git clone https://github.com/sm8635-dev/vendor_qcom_opensource_arpal-lx -b lineage-22.2-caf-sm8650 hardware/qcom-caf/sm8650/audio/pal
git clone https://github.com/sm8635-dev/hardware_qcom_audio-ar -b lineage-22.2-caf-sm8650 hardware/qcom-caf/sm8650/audio/primary-hal
git clone https://github.com/sm8635-dev/hardware_qcom_display -b lineage-22.2-caf-sm8650 hardware/qcom-caf/sm8650/display
git clone https://github.com/sm8635-dev/device_qcom_sepolicy_vndr -b lineage-22.2-caf-sm8650 device/qcom/sepolicy_vndr/sm8650

# SYMLINKS
ln -sf hardware/qcom-caf/common/os_pickup_aosp.mk hardware/qcom/Android.mk
ln -sf hardware/qcom-caf/common/os_pickup_sepolicy_vndr.mk device/qcom/sepolicy_vndr/SEPolicy.mk

mkdir -p hardware/qcom-caf/msm8953
ln -sf ../../common/os_pickup_qssi.bp hardware/qcom-caf/msm8953/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/msm8953/Android.mk

mkdir -p hardware/qcom-caf/msm8996
ln -sf ../../common/os_pickup.bp hardware/qcom-caf/msm8996/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/msm8996/Android.mk

mkdir -p hardware/qcom-caf/msm8998
ln -sf ../../common/os_pickup.bp hardware/qcom-caf/msm8998/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/msm8998/Android.mk

mkdir -p hardware/qcom-caf/sdm660
ln -sf ../../common/os_pickup_qssi.bp hardware/qcom-caf/sdm660/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/sdm660/Android.mk

mkdir -p hardware/qcom-caf/sdm845
ln -sf ../../common/os_pickup_qssi.bp hardware/qcom-caf/sdm845/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/sdm845/Android.mk

mkdir -p hardware/qcom-caf/sm8150
ln -sf ../../common/os_pickup_qssi.bp hardware/qcom-caf/sm8150/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/sm8150/Android.mk

mkdir -p hardware/qcom-caf/sm8250
ln -sf ../../common/os_pickup_qssi.bp hardware/qcom-caf/sm8250/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/sm8250/Android.mk

mkdir -p hardware/qcom-caf/sm8350
ln -sf ../../common/os_pickup_qssi.bp hardware/qcom-caf/sm8350/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/sm8350/Android.mk

mkdir -p hardware/qcom-caf/sm8450
mkdir -p hardware/qcom-caf/sm8450/audio
ln -sf ../../../common/os_pickup_audio-ar.mk hardware/qcom-caf/sm8450/audio/Android.mk
ln -sf ../../common/os_pickup_qssi.bp hardware/qcom-caf/sm8450/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/sm8450/Android.mk

mkdir -p hardware/qcom-caf/sm8550
mkdir -p hardware/qcom-caf/sm8550/audio
ln -sf ../../../common/os_pickup_audio-ar.mk hardware/qcom-caf/sm8550/audio/Android.mk
ln -sf ../../common/os_pickup_qssi.bp hardware/qcom-caf/sm8550/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/sm8550/Android.mk

ln -sf ../../../common/os_pickup_audio-ar.mk hardware/qcom-caf/sm8650/audio/Android.mk
ln -sf ../../common/os_pickup_qssi.bp hardware/qcom-caf/sm8650/Android.bp
ln -sf ../../common/os_pickup.mk hardware/qcom-caf/sm8650/Android.mk

if [ -d .repo ]; then
    repo forall hardware/qcom-caf/common -c 'git config --local project.groups qcom'
fi

# Build
. build/envsetup.sh
lunch lineage_peridot-bp1a-userdebug 
make installclean
m bacon
