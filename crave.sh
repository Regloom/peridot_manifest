#!/bin/bash
# crave run --clean --no-patch -- "curl https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/crave.sh | bash"

rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86

# Repo Init
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
curl -L --create-dirs https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/peridot.xml -o .repo/local_manifests/local_manifest.xml
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Cleanup unused HAL display, media, audio
# rm -rf /tmp/src/android/hardware/qcom-caf/{msm8996,msm8998,sdm845,sm8150,sm8250}/{display,media,audio}
# rm -rf /tmp/src/android/hardware/qcom-caf/sm8750

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

# KernelSU Next setup
cd kernel/xiaomi/sm8635
echo "======== Inside kernel/xiaomi/sm8635 ========"
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s v3.1.0
echo "======== Added KSU successfully ========"
cd ../../..
echo "======== Returned to root directory ========"

# TEMP FIX:
# vendor/xiaomi/peridot
# sed -i 's#hardware/voltage/interfaces/power-libperfmgr#hardware/lineage/interfaces/power-libperfmgr#g' vendor/xiaomi/peridot/Android.bp
# device/xiaomi/peridot-miuicamera/

# Cleanup unused HAL display, media, audio
# rm -rf hardware/qcom-caf/{msm8996,msm8998,sdm845,sm8150,sm8250}/{display,media,audio}
# rm -rf hardware/qcom-caf/sm8750

echo "======= Patches ======"
patches=(
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0001-SystemUI-Update-buildNumber-flow-to-return-null.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0002-SystemUI-Add-roaming-indicator-to-statusbar-tuner.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0003-SystemUI-Forward-port-HD-wifi-calling-statusbar-icon.patch"
    "packages/apps/Launcher3:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0004-Launcher3-Show-clear-all-button-in-recents-overview.patch"
    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0005-Settings-Expose-radio-info-4636.patch"
    # Vendor (Voltage => Lineage)
    "vendor/xiaomi/peridot:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0000-voltage-lineage.patch"
    # MIUI camera
    "frameworks/native:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/camera/0001-Native-Camera-Import-Release-Slot-Xiaomi-Changes.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/camera/0002-Base-Camera-11.patch"
    "frameworks/av:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/camera/0003-frameworks-av-Import-Xiaomi-Image-Tags-defenitions.patch"
    # BLUETOOTH
    "packages/modules/Bluetooth:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/bluetooth_aa/0000-modules_bt_ten.patch"
    "packages/modules/Bluetooth:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/bluetooth_aa/0000-modules_bt_aapriv.patch"
    # AA
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/bluetooth_aa/0000-frameworks_base_aa.patch"
)

for patch in "${patches[@]}"; do
    IFS=":" read -r directory url <<< "$patch"
    cd "$directory" || { echo "Ошибка: не могу перейти в $directory"; exit 1; }
    if curl -L "$url" | git am --ignore-whitespace; then
        echo "✓ Патч успешно применен в $directory"
    else
        echo "✗ Ошибка применения патча в $directory"
        exit 1
    fi
    # Возвращаемся назад
    cd - > /dev/null
    echo "----------------------------------------"
done
echo "======= Patching Done ======"

# Export
export BUILD_USERNAME=regloom
export BUILD_HOSTNAME=crave
export TZ="Europe/Berlin"
export TARGET_RELEASE=bp4a
#- error: libandroid's ABI has INCOMPATIBLE CHANGES.
export SKIP_ABI_CHECKS=true
echo "======= Export Done ======"

source build/envsetup.sh
echo "====== Envsetup Done ======="

# Build auto
brunch peridot userdebug
echo "============="

# Build manual
# lunch lineage_peridot-bp4a-userdebug
# m installclean
# m bacon | tee build-$(date +%Y%m%d-%H%M%S).log
