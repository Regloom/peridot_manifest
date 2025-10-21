#!/bin/bash

# Массив патчей в формате: "директория:URL"
patches=(
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0001-SystemUI-Update-buildNumber-flow-to-return-null.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0002-SystemUI-Add-roaming-indicator-to-statusbar-tuner.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0003-SystemUI-Forward-port-HD-wifi-calling-statusbar-icon.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0007-SystemUI-port-volte-vowifi-icons-to-A16-kairos-impl.patch"
    "packages/apps/Launcher3:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0004-Launcher3-Show-clear-all-button-in-recents-overview.patch"
    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/0005-Settings-Expose-radio-info-4636.patch"
    "kernel/xiaomi/sm8635-modules:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/kernelmodules-qcom-Drop-MIN-macros.patch"
#    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0006-ManageStoragePreferenceController-Explicitly-disable.patch"
#    RIFSXD KERNEL
#    "kernel/xiaomi/sm8635:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/kernel-videodev2.patch"
#    "kernel/xiaomi/sm8635:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/kernel-cpuboost.patch"
#    "kernel/xiaomi/sm8635:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/23/patches/kernel-drvboost.patch"
)

echo "Начинаем применение патчей..."

for patch in "${patches[@]}"; do
    # Разделяем директорию и URL
    IFS=":" read -r directory url <<< "$patch"
    cd "$directory" || { echo "Ошибка: не могу перейти в $directory"; exit 1; }

    # curl -fLSs https://github.com/${patch_url}.patch | git am cd -

    if curl -L "$url" | git am --ignore-whitespace; then
        echo "✓ Патч успешно применен в $directory"
    else
        echo "✗ Ошибка применения патча в $directory"
        echo "Если есть конфликты, разрешите их и выполните: git am --continue"
        echo "Или отмените применение: git am --abort"
        exit 1
    fi
    # Возвращаемся назад
    cd - > /dev/null
    echo "----------------------------------------"
done

echo "Все патчи успешно применены!"
