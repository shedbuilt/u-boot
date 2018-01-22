#!/bin/bash
case $SHED_HWCONFIG in
    orangepi-one)
        UBOOTCFG=orangepi_one_defconfig
        BOOTLOADER=u-boot-sunxi-with-spl.bin
        ;;
    orangepi-pc)
        UBOOTCFG=orangepi_pc_defconfig
        BOOTLOADER=u-boot-sunxi-with-spl.bin
        ;;
    aml-s905x-cc)
        UBOOTCFG=libretech-cc_defconfig
        BOOTLOADER=u-boot.bin
        ;;
    *)
        echo "Unsupported config: '$SHED_HWCONFIG'"
        exit 1
        ;;
esac
make $UBOOTCFG && \
make -j $SHED_NUMJOBS || exit 1
mkdir -pv "${SHED_FAKEROOT}/boot/u-boot"
install -m644 "$BOOTLOADER" "${SHED_FAKEROOT}/boot/u-boot/${SHED_HWCONFIG}.bin"
mkdir -v "${SHED_FAKEROOT}/boot/extlinux"
install -m644 "${SHED_CONTRIBDIR}/extlinux.template" "${SHED_FAKEROOT}/boot/extlinux/"
