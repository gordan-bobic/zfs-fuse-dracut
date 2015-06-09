# zfs-fuse-dracut
dracut module for zfs-fuse rootfs

This is a fork of ZoL zfs-dracut module, with the minimum required 
modifications to make it work with zfs-fuse.

To use:

1) Drop the 90zfs folder into your dracut modules.d folder 
(on EL7 that is /usr/lib/dracut/modules.d/) 

2) Add zfs module and fuse driver to your /etc/dracut.conf:
add_dracutmodules+="zfs"

3) Build your initrd:
dracut -f -v /boot/initramfs-zfs-fuse-$(uname -r).img $(uname -r)

Then tell your boot-loader to use that initrd.
