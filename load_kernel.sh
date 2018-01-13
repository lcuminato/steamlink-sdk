#!/bin/sh
killall powermanager.sh
killall powermanager   
killall shell.sh
killall shell
killall PE_Single_CPU 
killall bluetooth.sh
killall bluetoothd
killall wpa_supplicant.sh
killall wpa_supplicant
ifconfig mlan0 down
rmmod sd8897
rmmod 8897mlan
rmmod bt8xxx
rmmod galois_pe
rmmod gfx
/bin/wifi_reset

mkdir -p /home/steam/nfs
mount -t nfs -o nolock $MOUNT_DIR /home/steam/nfs
cd /home/steam/nfs
insmod ./kexec-module/kexec_load.ko
./tools/kexec -d -l --dtb=images/berlin2cd-dongle.dtb --initrd=images/initrd.cpio --append="console=ttyS0,115200 root=/dev/mtdblock9 rootfstype=yaffs2 ro root_part_name=rootfs init=/sbin/init mtdparts=mv_nand:1M(block0),8M(bootloader),11M(env),512M(sysconf),32M(factory_setting),32M(bootimgs),128M(recovery),32M(fts),384M(factory),1G(rootfs),1924M(cache),8M(bbt)" images/zImage
./tools/kexec -d -e
