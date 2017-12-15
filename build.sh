#!/bin/bash
UBOOTCFG=defconfig
BOOTLOADER=u-boot-sunxi-with-spl.bin
case $SHED_HWCONFIG in
    orangepi-one)
        UBOOTCFG=orangepi_one_defconfig
        BOOTLOADER=u-boot-sunxi-with-spl.bin
        ;;
    orangepi-pc)
        UBOOTCFG=orangepi_pc_defconfig
        BOOTLOADER=u-boot-sunxi-with-spl.bin
        ;;
esac
make $UBOOTCFG
make -j $SHED_NUMJOBS
mkdir -v "${SHED_FAKEROOT}/boot"
install -m644 "$BOOTLOADER" "${SHED_FAKEROOT}/boot"
mkdir -v "${SHED_FAKEROOT}/boot/extlinux"
install -m644 "${SHED_CONTRIBDIR}/extlinux.template" "${SHED_FAKEROOT}/boot/extlinux/"
