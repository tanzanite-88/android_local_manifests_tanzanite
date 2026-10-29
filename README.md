# Local manifest - Redmi Note 14 4G (tanzanite)

`local_manifests.xml` untuk build ROM tanzanite dari mirror
[tanzanite-88](https://github.com/tanzanite-88).

## Isi

| Branch | Keterangan |
|---|---|
| `lineage-23.2` | salinan asli dari `nathanzerogarage/local_manifests_tanzanite` (remote `nx` + `halcyon`) |
| `tanzanite-88` | semua project diarahkan ke mirror `tanzanite-88` |

## Pakai

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2

git clone https://github.com/tanzanite-88/android_local_manifests_tanzanite \
          -b tanzanite-88 .repo/local_manifests

repo sync -c -j8 --force-sync --no-clone-bundle --no-tags

source build/envsetup.sh
lunch lineage_tanzanite-userdebug
mka bacon
```

## Auto-clone dependensi

`vendorsetup.sh` ada di repo **device tree**
(`device/xiaomi/tanzanite/vendorsetup.sh`), bukan di sini, karena
`build/envsetup.sh` LineageOS hanya scan `device/`, `vendor/`, `product/`
(maksimal depth 4) dan tidak membaca `.repo/local_manifests`.

Jadi setelah `repo sync` selesai, `source build/envsetup.sh` otomatis
mengecek dan meng-clone project yang belum ada:

```
device/xiaomi/tanzanite-kernel      vanilla
device/mediatek/sepolicy_vndr       16.2
vendor/xiaomi/tanzanite             16.2
vendor/mediatek/ims                 16.2
hardware/xiaomi                     16.2
hardware/mediatek                   16.2
external/wpa_supplicant_8           16.2
```

Env yang didukung: `TZ_NO_AUTOCLONE=1`, `TZ_DEPTH=<n>` (default `1`, `0` =
full history), `TZ_REPLACE_WPA=1` (timpa wpa_supplicant_8 bawaan AOSP).
