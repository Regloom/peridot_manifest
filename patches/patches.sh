#!/bin/bash

# @YuanziX (kit) request

# Массив патчей в формате: "директория:URL"
patches=(
    "frameworks/base:https://github.com/AxionAOSP/android_frameworks_base/commit/fb7a2f2409441823270cadf2b4323708df954ce3.patch"
	"frameworks/base:https://github.com/AxionAOSP/android_frameworks_base/commit/311d1bff99a2c02708d8af74ed48748dcfa7a1bf.patch"
)

echo "Начинаем применение патчей..."

for patch in "${patches[@]}"; do
    # Разделяем директорию и URL
    IFS=":" read -r directory url <<< "$patch"
    cd "$directory" || { echo "Ошибка: не могу перейти в $directory"; exit 1; }

    # curl -fLSs https://github.com/${patch_url}.patch | git am cd -

    if curl -L "$url" | git am; then
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
cd frameworks/base
git am 0001-HDR-settings.patch
cd - > /dev/null

echo "Все патчи успешно применены!"
