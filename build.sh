#!/bin/bash
if [ "$SHED_DEVICE" == 'orangepi-pc2' ]; then
    # Copy over bl31.bin built by Allwinner ARM Trusted Firmware
    cp /boot/u-boot/bl31.bin . || exit 1
fi
# Increase default max gunzip size to 16M to accommodate larger kernels
sed -i 's/#define CONFIG_SYS_BOOTM_LEN.*/#define CONFIG_SYS_BOOTM_LEN 0x1000000/g' common/bootm.c &&
cp "${SHED_CONTRIBDIR}/${SHED_DEVICE}.config" .config &&
make -j $SHED_NUMJOBS || exit 1
case "$SHED_DEVICE" in
    orangepi-one|orangepi-pc|orangepi-lite|all-h3-cc)
        SHDPKG_BOOTLOADER='u-boot-sunxi-with-spl.bin'
        ;;
    orangepi-pc2)
	SHDPKG_BOOTLOADER='u-boot-sunxi-with-spl.bin'
	cat spl/sunxi-spl.bin u-boot.itb > u-boot-sunxi-with-spl.bin || exit 1
        ;;
    aml-s905x-cc)
        SHDPKG_BOOTLOADER='u-boot.bin'
        ;;
esac
install -Dm755 tools/mkimage "${SHED_FAKEROOT}/usr/bin/mkimage" &&
install -Dm644 "$SHDPKG_BOOTLOADER" "${SHED_FAKEROOT}/boot/u-boot/2018.03_${SHED_DEVICE}.bin" &&
install -Dm644 "${SHED_CONTRIBDIR}/extlinux.sample" "${SHED_FAKEROOT}/boot/extlinux/extlinux.sample"
