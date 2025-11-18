#!/bin/bash
#curl -LSs "https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/patches.sh" | bash -

echo "KernelSU Next setup"
cd kernel/xiaomi/sm8635
curl -LSs "https://raw.githubusercontent.com/rifsxd/KernelSU-Next/next/kernel/setup.sh" | bash -
cd ../../..

# Patches array: "directory:URL"
patches=(
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0001-SystemUI-Update-buildNumber-flow-to-return-null.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0002-SystemUI-Add-roaming-indicator-to-statusbar-tuner.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0003-SystemUI-Forward-port-HD-wifi-calling-statusbar-icon.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0007-SystemUI-port-volte-vowifi-icons-to-A16-kairos-impl.patch"
    "packages/apps/Launcher3:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0004-Launcher3-Show-clear-all-button-in-recents-overview.patch"
    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0005-Settings-Expose-radio-info-4636.patch"
)

echo "Begin patching..."

for patch in "${patches[@]}"; do
    IFS=":" read -r directory url <<< "$patch"
    cd "$directory" || { echo "Error: can't enter $directory"; exit 1; }
    if curl -L "$url" | git am --ignore-whitespace; then
        echo "✓ Patch OK in $directory"
    else
        echo "✗ Patch NOK in $directory"
        exit 1
    fi
    cd - > /dev/null
    echo "----------------------------------------"
done

echo "Patches applied OK!"
