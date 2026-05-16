#!/system/bin/sh

echo "ROFIKKERNEL DEBUG STARTED" > /dev/kmsg

sleep 15

echo "===== LOGCAT =====" > /data/rofik-logcat.txt
logcat -b all -d >> /data/rofik-logcat.txt

echo "===== DMESG =====" > /data/rofik-dmesg.txt
dmesg >> /data/rofik-dmesg.txt

echo "===== MOUNTS =====" > /data/rofik-mounts.txt
mount >> /data/rofik-mounts.txt

echo "===== GETPROP =====" > /data/rofik-getprop.txt
getprop >> /data/rofik-getprop.txt

echo "===== SELINUX =====" >> /data/rofik-getprop.txt
getenforce >> /data/rofik-getprop.txt

echo "===== ROFIKKERNELDEVGSI =====" > /data/rofik-gsi.txt
ls -l /system/rofikkernel >> /data/rofik-gsi.txt 2>&1
mount | grep vendor >> /data/rofik-gsi.txt 2>&1

echo "ROFIKKERNEL DEBUG FINISHED" > /dev/kmsg
