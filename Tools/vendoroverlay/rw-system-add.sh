# Vendor overlays
mount -o bind /system/rkkernel/vo /vendor/overlay || true
mount -o bind /system/rkkernel/group /vendor/etc/group || true
mount -o bind /system/rkkernel/passwd /vendor/etc/passwd || true
