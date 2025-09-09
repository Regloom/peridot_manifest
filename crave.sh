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

# Cleanup unused HAL display, media, audio
rm -rf /tmp/src/android/hardware/qcom-caf/{msm8996,msm8998,sdm845,sm8150,sm8250}/{display,media,audio}
rm -rf /tmp/src/android/hardware/qcom-caf/sm8750

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

# Cleanup unused HAL display, media, audio
rm -rf hardware/qcom-caf/{msm8996,msm8998,sdm845,sm8150,sm8250}/{display,media,audio}
rm -rf hardware/qcom-caf/sm8750


echo "======= Patches ======"
patches=(
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0002-VoWiFI-Roaming.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0003-VRR-Disable.patch"
    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0005-disable-storage.patch"
    "packages/apps/Trebuchet:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0001-Launcher3-Show-clear-all-button-in-recents-overview.patch"
    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0006-radio-info.patch"
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
export TARGET_RELEASE=bp1a
echo "======= Export Done ======"

. build/envsetup.sh
echo "====== Envsetup Done ======="

# Build auto
brunch peridot userdebug
echo "============="

# Build manual

# lunch lineage_peridot-bp1a-userdebug
# m installclean
# m bacon
