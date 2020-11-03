#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
for SHED_PKG_LOCAL_OPTION in "${!SHED_PKG_LOCAL_OPTIONS[@]}"; do
    case "$SHED_PKG_LOCAL_OPTION" in
        allh5cc|nanopik1plus|nanopineo2|nanopineoplus2|orangepipc2|allh3cc|nanopineo|nanopim1plus|orangepione|orangepipc|orangepilite)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
            SHED_PKG_UBOOT_TYPE="sunxi"
            ;;
        rock64)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
            SHED_PKG_UBOOT_TYPE="rockchip"
            ;;
    esac
done
SHED_PKG_LOCAL_UBOOT_PREFIX="/boot/u-boot/${SHED_PKG_VERSION}_${SHED_PKG_LOCAL_DEVICE}"
if [ "$SHED_PKG_UBOOT_TYPE" == 'rockchip' ]; then
    dd if="${SHED_PKG_LOCAL_UBOOT_PREFIX}.img" of=/dev/mmcblk0 seek=64 &&
    dd if="${SHED_PKG_LOCAL_UBOOT_PREFIX}.itb" of=/dev/mmcblk0 seek=16384 &&
    sync || exit 1
else
    dd if="${SHED_PKG_LOCAL_UBOOT_PREFIX}.bin" of=/dev/mmcblk0 bs=1024 seek=8 &&
    sync || exit 1
fi
echo "An updated u-boot bootloader has been written to /dev/mmcblk0."
echo "Please reboot your device."
