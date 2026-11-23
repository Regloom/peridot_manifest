#!/bin/bash
# vendor/partner_gms/vendorsetup.sh downloads the microG and F-Droid APKs on
# `source build/envsetup.sh`, but skips any APK that already exists, so a
# sync that bumps a pinned version would still ship the old APK.
# Run from the root of the Android tree after sync, before envsetup.

for dir in vendor/partner_gms/*/; do
    [ -f "$dir.version_code" ] || continue
    if ! cmp -s "$dir.version_code" "$dir.apk_version"; then
        rm -f "$dir"*.apk
        cp "$dir.version_code" "$dir.apk_version"
    fi
done
