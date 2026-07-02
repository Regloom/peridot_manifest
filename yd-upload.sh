#!/bin/bash
# crave pull "out/target/product/peridot/lineage-22.2-20250820-UNOFFICIAL-peridot.zip"
# https://yandex.ru/dev/disk/rest/
# https://oauth.yandex.ru/
accessToken="SECRET-TOKEN-HERE"
#fileToUpload="out/target/product/peridot/lineage-22.2-20250820-UNOFFICIAL-peridot.zip"
fileToUpload=$1

# Получаем имя файла из пути
fileName=$(basename "$fileToUpload")
# Формируем полный путь загрузки файла
uploadPath="app:/$fileName"
# Временное расширение файла для ускорения загрузки (почему-то некоторые файлы на яндекс грузятся медленно) 
tmpExt=".tmp"
# URL для запроса загрузки файла
uploadRequestUrl="https://cloud-api.yandex.net/v1/disk/resources/upload?path=$uploadPath$tmpExt&overwrite=true"
# Максимальное количество попыток загрузки файла
maxRetryAttempts=3
retryCount=0
while [ $retryCount -lt $maxRetryAttempts ]; do
    # GET-запрос для получения URL загрузки
    response=$(curl -s -X GET -H "Authorization: OAuth $accessToken" "$uploadRequestUrl")
    # Получаем URL для загрузки файла
    uploadUrl=$(echo $response | jq -r '.href')
    # Попытка загрузить файл на Яндекс.Диск
    curl -s -X PUT -T "$fileToUpload" "$uploadUrl"
    if [ $? -eq 0 ]; then
        echo "Файл успешно загружен на Яндекс.Диск."
        # Переименование файла на сервере Яндекс.Диска
        moveResponse=$(curl -s -X POST \
            -H "Authorization: OAuth $accessToken" \
            "https://cloud-api.yandex.net/v1/disk/resources/move?path=$uploadPath&from=$uploadPath$tmpExt&overwrite=true")
        break
    else
        echo "Произошла ошибка при загрузке файла на Яндекс.Диск."
        if [[ $response == *"Precondition Failed"* ]]; then
            range=$(echo "$response" | jq -r '.Range')
            startByte=$(echo "$range" | awk -F'-' '{print $2}' | awk '{print $1 + 1}')
            # Догружаем недостающие части файла
            curl -s -X PUT -H "Content-Range: bytes $startByte-" --data-binary "@$fileToUpload" "$uploadUrl"
            echo "Файл успешно догружен на Яндекс.Диск."
            break
        else
            echo "Не удалось обработать ошибку загрузки файла."
            retryCount=$((retryCount+1))
            if [ $retryCount -lt $maxRetryAttempts ]; then
                echo "Повторная попытка загрузки файла ($retryCount из $maxRetryAttempts)."
            else
                echo "Достигнуто максимальное количество попыток загрузки файла."
            fi
        fi
    fi
done
