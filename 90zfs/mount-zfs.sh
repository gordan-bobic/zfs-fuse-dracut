#!/bin/sh

. /lib/dracut-lib.sh

ZPOOL_FORCE=""
OLDIFS="$IFS"
NEWLINE="
"

if getargbool 0 zfs_force -y zfs.force -y zfsforce ; then
	warn "ZFS: Will force-import pools if necessary."
	ZPOOL_FORCE="-f"
fi

# Delay until all required block devices are present.
udevadm settle

modprobe fuse
zfs-fuse --pidfile /var/run/zfs/zfs-fuse.pid

case "$root" in
	zfs:*)
		# We have ZFS modules loaded, so we're able to import pools now.
		if [ "$root" = "zfs:AUTO" ] ; then
			# Need to parse bootfs attribute
			info "ZFS: Attempting to detect root from imported ZFS pools."

			# Might be imported by the kernel module, so try searching before
			# we import anything.
			zfsbootfs=`zpool list -H -o bootfs | sed -n '/^-$/ !p' | sed 'q'`
			if [ $? -ne 0 ] || [ -z "$zfsbootfs" ] || \
				[ "$zfsbootfs" = "no pools available" ] ; then
				# Not there, so we need to import everything.
				info "ZFS: Attempting to import additional pools."
				zpool import -a ${ZPOOL_FORCE}
				zfsbootfs=`zpool list -H -o bootfs | sed -n '/^-$/ !p' | sed 'q'`
				if [ $? -ne 0 ] || [ -z "$zfsbootfs" ] || \
					[ "$zfsbootfs" = "no pools available" ] ; then
					rootok=0
					pool=""

					warn "ZFS: No bootfs attribute found in importable pools."

					# Re-export everything since we're not prepared to take
					# responsibility for them.
					# Change IFS to allow for blanks in pool names.
					IFS="$NEWLINE"
					for fs in `zpool list -H -o name` ; do
						zpool export "$fs"
					done
					IFS="$OLDIFS"

					return 1
				fi
			fi
			info "ZFS: Using ${zfsbootfs} as root."
		else
			# Should have an explicit pool set, so just import it and we're done.
			zfsbootfs="${root#zfs:}"
			pool="${zfsbootfs%%/*}"
			if ! zpool list -H "$pool" > /dev/null ; then
				# pool wasn't imported automatically by the kernel module, so
				# try it manually.
				info "ZFS: Importing pool ${pool}..."
				if ! zpool import ${ZPOOL_FORCE} "$pool" ; then
					warn "ZFS: Unable to import pool ${pool}."
					rootok=0

					return 1
				fi
			fi
		fi

		# Above should have left our rpool imported and pool/dataset in $root.
		# zfs-fuse doesn't support legacy mounts too well. :(
		zfs set mountpoint="$NEWROOT" "$zfsbootfs" && ROOTFS_MOUNTED=yes
		mkdir -p "$NEWROOT"/var/run/zfs
		mount --bind /dev		"$NEWROOT"/dev
		mount --bind /var/run/zfs	"$NEWROOT"/var/run/zfs

		need_shutdown
		;;
esac
