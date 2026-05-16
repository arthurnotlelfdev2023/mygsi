#!/system/bin/sh

LOGTAG="ROFIKKERNELDEVGSI"

logi() {
    echo "$LOGTAG: $1" > /dev/kmsg
}

logi "rw-system-add.sh started"

# Verify source paths
ls -l /system/rofikkernel > /dev/kmsg 2>&1
ls -l /system/rofikkernel/vo > /dev/kmsg 2>&1

# Vendor overlay
if mount -o bind /system/rofikkernel/vo /vendor/overlay; then
    logi "overlay bind mounted"
else
    logi "overlay bind FAILED"
fi

# passwd
if mount -o bind /system/rofikkernel/passwd /vendor/etc/passwd; then
    logi "passwd bind mounted"
else
    logi "passwd bind FAILED"
fi

# group
if mount -o bind /system/rofikkernel/group /vendor/etc/group; then
    logi "group bind mounted"
else
    logi "group bind FAILED"
fi

# Final mount verify
mount | grep vendor > /dev/kmsg 2>&1

logi "rw-system-add.sh finished"
