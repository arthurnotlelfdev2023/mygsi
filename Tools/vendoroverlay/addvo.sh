#/bin/bash

SCRIPT_DIR=$(dirname "$0")
BASE_DIR="$1"

mkdir -p "$BASE_DIR/system/rkkernel"
mkdir -p "$BASE_DIR/system/rkkernel/vo"

cp -r "$BASE_DIR/vendor/overlay/." "$BASE_DIR/system/rkkernel/vo/"
cp "$BASE_DIR/vendor/etc/passwd" "$BASE_DIR/system/rkkernel/"
cp "$BASE_DIR/vendor/etc/group" "$BASE_DIR/system/rkkernel/"

echo "" >> "$BASE_DIR/system/bin/rw-system.sh" && cat "$SCRIPT_DIR/rw-system-add.sh" >> "$BASE_DIR/system/bin/rw-system.sh"
