#!/bin/bash

# Массив патчей в формате: "директория:URL"
patches=(
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0002-VoWiFI-Roaming.patch"
    "frameworks/base:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0003-VRR-Disable.patch"
#    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0004-free-up-space.patch"
    "packages/apps/Settings:https://raw.githubusercontent.com/Regloom/peridot_manifest/refs/heads/hals/patches/0005-disable-storage.patch"
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

# Ручные правки
# cd packages/apps/Settings
# git am ../../../0001-HDR-settings.patch
# cd - > /dev/null

echo "Все патчи успешно применены!"
