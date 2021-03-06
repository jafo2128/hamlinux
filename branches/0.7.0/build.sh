#!/bin/bash

DISTRO="hamlinux"
MOUNT_PROC_SH=/usr/local/sbin/mount-proc.sh

# define squashfs options here
export MKSQUASHFS_OPTIONS="-b 1048576"

# define linux packages here for different editions
VOYAGE_LINUX_PACKAGES="linux-image-2.6.37"

if [ $(uname -m) == "x86_64" ] ; then
	ARCH="_amd64"
	lb config -a amd64
fi

Chroot ()
{
    # Execute commands in chroot
    chroot "${1}" /usr/bin/env -i HOME="/root" DEBIAN_FRONTEND="noninteractive" \
        TERM="${TERM}" PATH="/usr/sbin:/usr/local/sbin:/usr/bin:/sbin:/bin" \
        ftp_proxy="${LIVE_FTPPROXY}" http_proxy="${LIVE_HTTPPROXY}" ${2}
}

Chroot_MountProc ()
{
    if [ -f ${1}/${MOUNT_PROC_SH} ] ;
    then
        # Execute commands in chroot
        chroot "${1}" /usr/bin/env -i HOME="/root" DEBIAN_FRONTEND="noninteractive" \
			 TERM="${TERM}" PATH="/usr/sbin:/usr/local/sbin:/usr/bin:/sbin:/bin" \
            ftp_proxy="${LIVE_FTPPROXY}" http_proxy="${LIVE_HTTPPROXY}" ${MOUNT_PROC_SH} ${2}
    else
        echo "No ${MOUNT_PROC_SH}, call Chroot() instead"
        Chroot "${1}" "${2}"
    fi
}

BuildTar()
{
	lb clean
	lb config -b tar --chroot-filesystem plain --packages-lists "voyage" --linux-packages="$VOYAGE_LINUX_PACKAGES"
	lb build

	Chroot_MountProc binary/live/filesystem.dir "apt-get -y remove --purge busybox live-initramfs"
	Chroot_MountProc binary/live/filesystem.dir "apt-get -y autoremove --purge"
	rm -f binary/live/filesystem.dir/boot/*.bak
	
	if [ -d binary/live/filesystem.dir ] ; then
		mv binary/live/filesystem.dir binary/live/$DISTRO-current$ARCH
		tar -jcf $DISTRO-current$ARCH.tar.bz2 -C binary/live/	$DISTRO-current$ARCH/. 
		mv binary/live/$DISTRO-current$ARCH binary/live/filesystem.dir
	else
		echo "binary/live/filesystem.dir not found!"
	fi
}

BuildImg()
{
	lb clean
	lb config -b usb-hdd --binary-filesystem fat16 --chroot-filesystem squashfs --packages-lists "voyage-cd" --linux-packages="$VOYAGE_LINUX_PACKAGES"
	lb build

	if [ -f binary.img ] ; then
		mv binary.img $DISTRO-current$ARCH.img
	else
		echo "binary.img not found!"
	fi
}

BuildISO()
{
	lb clean
	lb config -b iso --chroot-filesystem squashfs --packages-lists "voyage-cd" --linux-packages="$VOYAGE_LINUX_PACKAGES"
	lb build
	
	if [ -f binary.iso ] ; then
		mv binary.iso $DISTRO-current$ARCH.iso
	else
		echo "binary.iso not found!"
	fi
}

BuildSDK()
{
	lb clean
	lb config -b iso --chroot-filesystem squashfs --packages-lists "voyage-sdk" --linux-packages="$VOYAGE_LINUX_PACKAGES"
	lb build
	
	if [ -f binary.iso ] ; then
		mv binary.iso $DISTRO-sdk$ARCH.iso
	else
		echo "binary.iso not found!"
	fi
}

#
# $1 - package list name (e.g. voyage-one-cd)
# $2 - distro name (e.g. one, mpd)
# $3 - linux packages 
#
BuildDistro()
{
	lb clean
	lb config -b tar --chroot-filesystem plain --packages-lists "$1" --linux-packages="$3"
	lb build

	Chroot_MountProc binary/live/filesystem.dir "apt-get -y remove --purge busybox live-initramfs"
	Chroot_MountProc binary/live/filesystem.dir "apt-get -y autoremove --purge"
	rm binary/live/filesystem.dir/boot/*.bak
	
	if [ -d binary/live/filesystem.dir ] ; then
		mv binary/live/filesystem.dir binary/live/$DISTRO-$2-current$ARCH
		tar -jcf $DISTRO-$2-current$ARCH.tar.bz2 -C binary/live/	$DISTRO-$2-current$ARCH/. 
		mv binary/live/$DISTRO-$2-current$ARCH binary/live/filesystem.dir
	else
		echo "binary/live/filesystem.dir not found!"
	fi
}

#
# $1 - package list name (e.g. voyage-one-cd)
# $2 - distro name (e.g. one, mpd)
# $3 - linux packages
#
BuildCD()
{
	lb clean
	lb config -b iso --chroot-filesystem squashfs --packages-lists "$1" --linux-packages="$3"
	lb build
	
	if [ -f binary.iso ] ; then
		mv binary.iso $DISTRO-$2-current$ARCH.iso
	else
		echo "binary.iso not found!"
	fi
}

#
# $1 - local package list to use by the distro
#
PreparePackageList()
{
	rm -f config/chroot_local-packageslists/*.list
	LISTS=`echo "$1" | sed -e "s/ /\n/g"`
	for LIST in $LISTS ; do
		echo "cp -p config/chroot_local-packageslists/$LIST config/chroot_local-packageslists/$LIST.list"
		cp -p config/chroot_local-packageslists/$LIST config/chroot_local-packageslists/$LIST.list
	done
	
}

for TYPE in $1; do
	case "$TYPE" in
		img)
			PreparePackageList "voyage voyage-cd"
			BuildImg
		;;
		tar)
			PreparePackageList "voyage"
			BuildTar
		;;
		iso)
			PreparePackageList "voyage voyage-cd"
			BuildISO
		;;
		sdk)
			PreparePackageList "voyage voyage-cd voyage-sdk"
			BuildSDK
		;;
		test)
			Chroot_MountProc binary/live/filesystem.dir "apt-get -y remove busybox live-initramfs"
			Chroot_MountProc binary/live/filesystem.dir "apt-get -y autoremove"
		;;
		*)
			echo "unknown build type $TYPE"
		;;
	esac
done

