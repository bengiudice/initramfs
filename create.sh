#!/bin/sh

mkdir minfs
doas apk --root minfs --initdb --allow-untrusted add
echo "http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community" | doas tee minfs/etc/apk/repositories
doas apk --root minfs --allow-untrusted add alpine-keys
doas apk --root minfs update
doas apk --root minfs upgrade

doas apk --root minfs add busybox-static
doas apk --root minfs add linux-firmware-none
doas apk --root minfs add --no-scripts linux-edge
cd minfs
mkdir initramfs
cp bin/busybox.static initramfs/busybox
mkdir initramfs/lib
mkdir initramfs/lib/modules
cp -r lib/modules/`uname -r` initramfs/lib/modules/`uname -r`
echo "#!/busybox sh
echo '    -- custom init --'
exec /busybox ash" > initramfs/init.sh
chmod +x initramfs/init.sh
find initramfs/ | cpio -H newc -o > ../initramfs.cpio

doas apk --root . add --no-scripts alpine-base
echo "search gateway
nameserver 8.8.8.8
nameserver 8.8.4.4" | doas tee etc/resolv.conf

doas mount -t proc proc proc
doas mount -t sysfs sys sys
doas mount -t devtmpfs dev dev
doas chroot .
doas umount proc
doas umount sys
doas umount dev
