#/bin/bash

SCRIPT_DIR=$(dirname "$0")
BASE_DIR="$1"

mkdir -p "$BASE_DIR/system/rofikkernel"
mkdir -p "$BASE_DIR/system/rofikkernel/vo"

cp -r "$BASE_DIR/vendor/overlay/." "$BASE_DIR/system/rofikkernel/vo/"
cp "$BASE_DIR/vendor/etc/passwd" "$BASE_DIR/system/rofikkernel/passwd"
cp "$BASE_DIR/vendor/etc/group" "$BASE_DIR/system/rofikkernel/group"

echo "" >> "$BASE_DIR/system/bin/rw-system.sh" && cat "$SCRIPT_DIR/rw-system-add.sh" >> "$BASE_DIR/system/bin/rw-system.sh"
