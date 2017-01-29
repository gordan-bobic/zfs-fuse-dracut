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

Known limitations:

1) When using zfs as root file system using zfs-fuse, additional pools cannot be imported after booting.

Because zfs-fuse in this instance runs in the initrd, it will not be able to import additional pools after the switchroot occurs. Switchroot unmounts all file systems in the initrd, which in turn results in block device nodes under /dev/ disappearing. zfs-fuse keeps open file handles to the device nodes it needs for the root pool so this survives the switchroot, but it does prevent it from seeing any device nodes that it didn't keep open file handles to during the initrd startup stage.

2) SELinux will not work with zfs-fuse root file systems

Standard SELinux policies label all fuse file systems as fuse_t, rather than applying the labels as required for SELinux to operate in enforcing mode. You can run it in permissive mode, but that will just flood the audit log since pretty much every disk access will be a policy violation. This could be made to work with a custom policy (happy to accept a patch custom policy that addresses this :-). Consequently, at the moment the recommendation is to disable xattr support in zfsrc, and boot the kernel with selinux=0.
