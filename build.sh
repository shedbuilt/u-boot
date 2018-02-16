#!/bin/bash
case "$SHED_DEVICE" in
    orangepi-one)
        UBOOTCFG='orangepi_one_defconfig'
        BOOTLOADER='u-boot-sunxi-with-spl.bin'
        ;;
    orangepi-pc)
        UBOOTCFG='orangepi_pc_defconfig'
        BOOTLOADER='u-boot-sunxi-with-spl.bin'
        ;;
    aml-s905x-cc)
        UBOOTCFG='libretech-cc_defconfig'
        BOOTLOADER='u-boot.bin'
        ;;
    *)
        echo "Unsupported config: '$SHED_DEVICE'"
        exit 1
        ;;
esac
# Increase default max gunzip size to 16M to accommodate larger kernels
sed -i 's/#define CONFIG_SYS_BOOTM_LEN.*/#define CONFIG_SYS_BOOTM_LEN 0x1000000/g' common/bootm.c && \
make $UBOOTCFG && \
make -j $SHED_NUMJOBS || exit 1
install -Dm755 tools/mkimage "${SHED_FAKEROOT}/usr/bin/mkimage"
install -Dm644 "$BOOTLOADER" "${SHED_FAKEROOT}/boot/u-boot/2018.03rc2_${SHED_HWCONFIG}.bin"
install -Dm644 "${SHED_CONTRIBDIR}/extlinux.sample" "${SHED_FAKEROOT}/boot/extlinux/extlinux.sample"
