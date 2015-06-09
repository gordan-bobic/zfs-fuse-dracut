#!/bin/sh

_do_zpool_export() {
	local ret=0
	local final=$1
	local force
	local OLDIFS="$IFS"
	local NEWLINE="
"

	if [ "x$final" != "x" ]; then
		force="-f"
	fi

	info "Exporting ZFS storage pools"
	# Change IFS to allow for blanks in pool names.
	IFS="$NEWLINE"
	for fs in `zpool list -H -o name` ; do
		zpool export $force "$fs" || ret=$?
	done
	IFS="$OLDIFS"

	if [ "x$final" != "x" ]; then
		info "zpool list"
		zpool list 2>&1 | vinfo
	fi

	return $ret
}

if command -v zpool >/dev/null; then
	_do_zpool_export $1
else
	:
fi
