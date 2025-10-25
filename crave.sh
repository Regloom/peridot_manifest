#!/bin/bash
# crave run --clean --no-patch -- "curl https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/crave.sh | bash"

rm -rf .repo/local_manifests/
rm -rf prebuilts/clang/host/linux-x86

# Repo Init
repo init -u https://github.com/LineageOS/android.git -b lineage-23.0 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
curl -L --create-dirs https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23ag/peridot.xml -o .repo/local_manifests/local_manifest.xml
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Cleanup unused HAL display, media, audio
# rm -rf /tmp/src/android/kernel/xiaomi/sm8635*
# rm -rf /tmp/src/android/hardware/qcom-caf/{msm8996,msm8998,sdm845,sm8150,sm8250}/{display,media,audio}
# rm -rf /tmp/src/android/hardware/qcom-caf/sm8750

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

# KernelSU Next setup
cd kernel/xiaomi/sm8635
echo "======== Inside kernel/xiaomi/sm8635 ========"
# curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -
# echo "======== Added KSU successfully ========"
git submodule update --init
echo "======== Initialized submodules ========"
cd ../../..
echo "======== Returned to root directory ========"

# Cleanup unused HAL display, media, audio
# rm -rf hardware/qcom-caf/{msm8996,msm8998,sdm845,sm8150,sm8250}/{display,media,audio}
# rm -rf hardware/qcom-caf/sm8750

echo "======= Patches ======"
patches=(
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23ag/patches/0001-SystemUI-Update-buildNumber-flow-to-return-null.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23ag/patches/0002-SystemUI-Add-roaming-indicator-to-statusbar-tuner.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23ag/patches/0003-SystemUI-Forward-port-HD-wifi-calling-statusbar-icon.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23ag/patches/0007-SystemUI-port-volte-vowifi-icons-to-A16-kairos-impl.patch"
    "packages/apps/Launcher3:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23ag/patches/0004-Launcher3-Show-clear-all-button-in-recents-overview.patch"
    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23ag/patches/0005-Settings-Expose-radio-info-4636.patch"
    "kernel/xiaomi/sm8635-modules:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23ag/patches/kernelmodules-qcom-Drop-MIN-macros.patch"
#    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0006-ManageStoragePreferenceController-Explicitly-disable.patch"
#    RIFSXD KERNEL
#    "kernel/xiaomi/sm8635:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23ag/patches/wip/kernel-videodev2.patch"
#    GUIDIX KERNEL
#    "kernel/xiaomi/sm8635:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/kernel-cpuboost.patch"
#    "kernel/xiaomi/sm8635:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/kernel-drvboost.patch"

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
export TARGET_RELEASE=bp2a
#- error: libandroid's ABI has INCOMPATIBLE CHANGES.
export SKIP_ABI_CHECKS=true
echo "======= Export Done ======"

source build/envsetup.sh
echo "====== Envsetup Done ======="

# Build auto
brunch peridot userdebug
echo "============="

# Build manual

# lunch lineage_peridot-bp2a-userdebug
# m installclean
# m bacon
