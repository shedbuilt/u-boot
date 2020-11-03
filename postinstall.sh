#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
for SHED_PKG_LOCAL_OPTION in "${!SHED_PKG_LOCAL_OPTIONS[@]}"; do
    case "$SHED_PKG_LOCAL_OPTION" in
        allh5cc|nanopik1plus|nanopineo2|nanopineoplus2|orangepipc2|allh3cc|nanopineo|nanopim1plus|orangepione|orangepipc|orangepilite)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
            SHED_PKG_LOCAL_BOOTLOADER_OFFSET='16'
            ;;
        rock64)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
            SHED_PKG_LOCAL_BOOTLOADER_OFFSET='64'
            ;;
    esac
done
dd if="/boot/u-boot/${SHED_PKG_VERSION}_${SHED_PKG_LOCAL_DEVICE}.bin" of=/dev/mmcblk0 seek=${SHED_PKG_LOCAL_BOOTLOADER_OFFSET} &&
sync &&
echo "An updated u-boot bootloader has been written to /dev/mmcblk0." &&
echo "Please reboot your device."
