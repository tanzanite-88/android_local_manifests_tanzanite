# Bazel-less local manifest - Redmi Note 14 4G (tanzanite)

Kumpulan `local_manifests.xml` + `vendorsetup.sh` untuk build ROM tanzanite
dari mirror org [tanzanite-88](https://github.com/tanzanite-88).

## Isi

| File | Branch | Keterangan |
|---|---|---|
| `local_manifests.xml` | `lineage-23.2` | salinan asli dari `nathanzerogarage/local_manifests_tanzanite` |
| `local_manifests.xml` | `tanzanite-88` | semua project diarahkan ke mirror `tanzanite-88` |
| `vendorsetup.sh` | `tanzanite-88` | auto-clone dependensi saat `source build/envsetup.sh` |

## Pakai

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2

git clone https://github.com/tanzanite-88/android_local_manifests_tanzanite \
          -b tanzanite-88 .repo/local_manifests

# di sini dependensi otomatis ke-clone
source build/envsetup.sh

repo sync -c -j8 --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh
lunch lineage_tanzanite-userdebug
mka bacon
```

## vendorsetup.sh

Dipanggil otomatis oleh `build/envsetup.sh` (file di `.repo/local_manifests/`
di-source). Yang di-clone kalau belum ada:

```
device/xiaomi/tanzanite             lineage-23.2
device/xiaomi/tanzanite-kernel      vanilla
device/mediatek/sepolicy_vndr       16.2
vendor/xiaomi/tanzanite             16.2
vendor/mediatek/ims                 16.2
hardware/xiaomi                     16.2
hardware/mediatek                   16.2
external/wpa_supplicant_8           16.2
```

Variabel lingkungan:

| Env | Efek |
|---|---|
| `TZ_NO_AUTOCLONE=1` | lewati auto-clone |
| `TZ_DEPTH=<n>` | kedalaman clone, default `1`, `0` = full history |
| `TZ_REPLACE_WPA=1` | timpa `external/wpa_supplicant_8` bawaan AOSP dengan versi halcyon |

Catatan: `external/wpa_supplicant_8` sudah ada di manifest LineageOS, jadi
default-nya cuma diperingatkan. Kalau tidak memakai `TZ_REPLACE_WPA=1`,
`repo sync` tetap akan menimpanya karena manifest ini memakai
`<remove-project>` + project pengganti.

Hapus folder ini kalau mau balik ke `nathanzerogarage` sepenuhnya:

```bash
rm -rf .repo/local_manifests
```
