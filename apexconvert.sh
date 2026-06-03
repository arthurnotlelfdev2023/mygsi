#!/bin/bash

# =========================================================

# Android APEX -> EXT4 Repacker

# Final Ubuntu PC Version

# By RofikKernelDev

# =========================================================

set +e

IN="$1"
OUT="$2"

WORK="./apex_work"

# =========================================================

# CHECK ARGUMENTS

# =========================================================

if [ -z "$IN" ] || [ -z "$OUT" ]; then
echo ""
echo "Usage:"
echo "sudo apexconvert <input_apex_folder> <output_folder>"
echo ""
echo "Example:"
echo "sudo apexconvert ./system/system/apex ./out"
echo ""
exit 1
fi

# =========================================================

# CHECK DEPENDENCIES

# =========================================================

REQS=(
7z
fsck.erofs
mke2fs
resize2fs
img2simg
simg2img
mount
umount
zip
unzip
file
)

for BIN in "${REQS[@]}"; do
if ! command -v "$BIN" >/dev/null 2>&1; then
echo "[-] Missing dependency: $BIN"
exit 1
fi
done

# =========================================================

# CLEANUP HANDLER

# =========================================================

cleanup_mounts() {


find "$WORK" -type d -name mnt 2>/dev/null | while read m; do
    sudo umount -lf "$m" 2>/dev/null
done


}

trap cleanup_mounts EXIT

# =========================================================

# PREPARE

# =========================================================

mkdir -p "$OUT"

rm -rf "$WORK"
mkdir -p "$WORK"

echo "[*] Starting batch APEX -> EXT4 sparse conversion"

# =========================================================

# LOOP ALL APEX

# =========================================================

for apex in "$IN"/*.apex; do


[ -f "$apex" ] || continue

NAME=$(basename "$apex" .apex)

echo ""
echo "[*] Processing: $NAME"

CUR="$WORK/$NAME"

rm -rf "$CUR"
mkdir -p "$CUR"

# =====================================================
# Extract original apex
# =====================================================

7z x "$apex" -o"$CUR" > /dev/null

PAYLOAD="$CUR/apex_payload.img"

if [ ! -f "$PAYLOAD" ]; then
    echo "[-] apex_payload.img missing"
    continue
fi

# =====================================================
# Handle sparse image
# =====================================================

if file "$PAYLOAD" | grep -qi "Android sparse image"; then

    echo "    Sparse image detected"

    simg2img \
        "$PAYLOAD" \
        "$CUR/raw.img"

    PAYLOAD="$CUR/raw.img"
fi

TYPE=$(file "$PAYLOAD")

mkdir -p "$CUR/fs"

# =====================================================
# Handle EROFS
# =====================================================

if echo "$TYPE" | grep -qi erofs; then

    echo "    EROFS detected -> converting to EXT4"

    fsck.erofs --extract="$CUR/fs" "$PAYLOAD"

# =====================================================
# Handle EXT filesystem
# =====================================================

elif echo "$TYPE" | grep -Eqi 'ext2|ext3|ext4'; then

    echo "    EXT filesystem detected"

    mkdir -p "$CUR/mnt"

    sudo mount -o loop,ro "$PAYLOAD" "$CUR/mnt"

    cp -a "$CUR/mnt"/. "$CUR/fs"/

    sudo umount "$CUR/mnt"

else

    echo "[-] Unsupported filesystem"
    echo "    $TYPE"

    continue

fi

# =====================================================
# Remove old payload
# =====================================================

rm -f "$CUR/apex_payload.img"
rm -f "$CUR/raw.img"

# =====================================================
# Build EXT4 RAW image
# =====================================================

echo "    Building EXT4 payload"

RAW_IMG="$CUR/apex_payload_raw.img"

mke2fs \
    -t ext4 \
    -O ^metadata_csum,^64bit,^orphan_file \
    -d "$CUR/fs" \
    "$RAW_IMG" \
    512M > /dev/null 2>&1

# =====================================================
# Shrink filesystem
# =====================================================

echo "    Shrinking filesystem"

resize2fs -M "$RAW_IMG" > /dev/null 2>&1

# =====================================================
# Convert RAW -> Sparse EXT4
# =====================================================

echo "    Converting to sparse EXT4"

img2simg \
    "$RAW_IMG" \
    "$CUR/apex_payload.img"

rm -f "$RAW_IMG"

# =====================================================
# Cleanup temp dirs
# =====================================================

rm -rf "$CUR/fs"
rm -rf "$CUR/mnt"

# =====================================================
# Remove old output
# =====================================================

rm -f "$OUT/$NAME.apex"

# =====================================================
# Repack apex
# =====================================================

echo "    Repacking APEX"

(
    cd "$CUR"

    zip -0 -r \
        "$OLDPWD/$OUT/$NAME.apex" \
        . > /dev/null
)

echo "    DONE"


done

# =========================================================

# CREATE FINAL ZIP PACKAGE

# =========================================================

FINAL_ZIP="converted_apex_ext4.zip"

echo ""
echo "[*] Creating final ZIP package"

cd "$OUT"

zip -r "../$FINAL_ZIP" ./*.apex > /dev/null

cd "$OLDPWD"

# =========================================================

# CLEANUP

# =========================================================

rm -rf "$WORK"

echo ""
echo "[*] ALL DONE"
echo "[*] Final converted APEX files:"
echo "    $OUT"
echo ""
echo "[*] Final ZIP package:"
echo "    $FINAL_ZIP"
echo ""

