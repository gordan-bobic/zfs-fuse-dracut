#!/bin/sh

check() {
	# Verify the zfs tool chain
	which zpool >/dev/null 2>&1 || return 1
	which zfs >/dev/null 2>&1 || return 1

	return 0
}

depends() {
	return 0
}

installkernel() {
	instmods fuse
}

install() {
	dracut_install /sbin/mount.zfs
	dracut_install /sbin/zfs-fuse
	dracut_install /sbin/zfs
	dracut_install /sbin/zpool
	dracut_install /etc/fuse.conf
	dracut_install fusermount
	dracut_install ulockmgr_server
	dracut_install mount.fuse
	dracut_install hostid
	dracut_install awk
	dracut_install head
	inst_hook cmdline 95 "$moddir/parse-zfs.sh"
	inst_hook mount 98 "$moddir/mount-zfs.sh"
	inst_hook shutdown 30 "$moddir/export-zfs.sh"

	if [ -e /etc/zfs/zpool.cache ]; then
		inst /etc/zfs/zpool.cache
	fi

	if [ -e /etc/zfs/zfsrc ]; then
		inst /etc/zfs/zfsrc
	fi

	inst_simple "$moddir/zfs-fuse-initramfs.service" "$systemdsystemunitdir/zfs-fuse-initramfs.service"
	ln_r "$systemdsystemunitdir/zfs-fuse-initramfs.service" "$systemdsystemunitdir/initrd.target.wants/zfs-fuse-initramfs.service"

	# Synchronize initramfs and system hostid
	AA=`hostid | cut -b 1,2`
	BB=`hostid | cut -b 3,4`
	CC=`hostid | cut -b 5,6`
	DD=`hostid | cut -b 7,8`
	printf "\x$DD\x$CC\x$BB\x$AA" > "$initdir/etc/hostid"
}
