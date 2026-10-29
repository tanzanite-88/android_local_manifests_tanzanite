#!/bin/bash
#
# vendorsetup.sh - auto-clone dependensi build Redmi Note 14 4G (tanzanite)
#
# File ini di-source otomatis oleh build/envsetup.sh karena letaknya di
# .repo/local_manifests/. Project yang belum ada langsung di-clone sesuai
# branch yang dipakai manifest, jadi `source build/envsetup.sh` = deps siap.
#
# Setup awal:
#   repo init -u https://github.com/LineageOS/android.git -b lineage-23.2
#   git clone https://github.com/tanzanite-88/android_local_manifests_tanzanite \
#             -b tanzanite-88 .repo/local_manifests
#   source build/envsetup.sh
#
# Env:
#   TZ_NO_AUTOCLONE=1    lewati auto-clone
#   TZ_DEPTH=<n>         kedalaman clone, default 1 (0 = full history)
#   TZ_REPLACE_WPA=1     timpa external/wpa_supplicant_8 bawaan AOSP

_tz_vendorsetup() {
    local remote="${TZ_REMOTE:-https://github.com/tanzanite-88}"
    local depth="${TZ_DEPTH:-1}"
    local cloned=0 skipped=0 failed=0 path repo branch args url

    if [ -n "${TZ_NO_AUTOCLONE:-}" ]; then
        echo "vendorsetup: TZ_NO_AUTOCLONE diset, skip"
        return 0
    fi
    if [ ! -d .repo ]; then
        echo "vendorsetup: bukan root tree AOSP (tidak ada .repo/), skip"
        return 0
    fi

    # path|repo|branch
    local deps="
device/xiaomi/tanzanite|android_device_xiaomi_tanzanite|lineage-23.2
device/xiaomi/tanzanite-kernel|android_device_xiaomi_tanzanite-kernel|vanilla
device/mediatek/sepolicy_vndr|android_device_mediatek_sepolicy_vndr|16.2
vendor/xiaomi/tanzanite|android_vendor_xiaomi_tanzanite|16.2
vendor/mediatek/ims|android_vendor_mediatek_ims|16.2
hardware/xiaomi|android_hardware_xiaomi|16.2
hardware/mediatek|android_hardware_mediatek|16.2
external/wpa_supplicant_8|android_external_wpa_supplicant_8|16.2
"

    while IFS='|' read -r path repo branch; do
        [ -z "${path:-}" ] && continue
        url="$remote/$repo.git"

        if [ -d "$path/.git" ]; then
            if [ "$(git -C "$path" remote get-url origin 2>/dev/null)" != "$url" ]; then
                # wpa_supplicant_8 sudah ada dari manifest AOSP, harus ditimpa
                if [ "$repo" = "android_external_wpa_supplicant_8" ] && \
                   [ -n "${TZ_REPLACE_WPA:-}" ]; then
                    echo "vendorsetup: timpa $path dengan $repo@$branch"
                    rm -rf "$path"
                else
                    echo "vendorsetup: $path ada tapi remote lain (bukan $repo), skip"
                    echo "vendorsetup:   pakai TZ_REPLACE_WPA=1 kalau mau ditimpa"
                    skipped=$((skipped + 1))
                    continue
                fi
            else
                skipped=$((skipped + 1))
                continue
            fi
        fi

        args=""
        [ "$depth" != "0" ] && args="--depth $depth"
        echo "vendorsetup: clone $path <- $repo@$branch"

        if git clone $args -b "$branch" "$url" "$path"; then
            cloned=$((cloned + 1))
        else
            echo "vendorsetup: GAGAL clone $repo@$branch"
            failed=$((failed + 1))
        fi
    done <<EOF
$deps
EOF

    if [ "$cloned" -gt 0 ]; then
        echo "vendorsetup: $cloned clone, $skipped sudah ada"
        echo "vendorsetup: lanjut 'repo sync -c -j8 --force-sync --no-clone-bundle --no-tags'"
    elif [ "$failed" -eq 0 ]; then
        echo "vendorsetup: semua dependensi sudah ada"
    fi
    [ "$failed" -gt 0 ] && echo "vendorsetup: $failed project gagal, cek akses repo"
    return 0
}

_tz_vendorsetup
unset -f _tz_vendorsetup
