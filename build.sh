#!/bin/bash
case "$SHED_DEVICE" in
    nanopi-neo2|nanopi-neo-plus2|orangepi-pc2)
        SHDPKG_BOARDTYPE='sunxi-h5'
        SHDPKG_BOOTLOADER='u-boot-sunxi-with-spl.bin'
        # Copy over bl31.bin built by Allwinner ARM Trusted Firmware (atf-sunxi)
        cp /boot/u-boot/bl31.bin . || exit 1
        ;;
    all-h3-cc|nanopi-neo|nanopi-m1-plus|orangepi-one|orangepi-pc|orangepi-lite)
        SHDPKG_BOARDTYPE='sunxi-h3'
        SHDPKG_BOOTLOADER='u-boot-sunxi-with-spl.bin'
        ;;
    aml-s905x-cc)
        SHDPKG_BOARDTYPE='amlogic-gxl'
        SHDPKG_BOOTLOADER='u-boot.bin'
        ;;
    *)
        echo "Unsupported device: '$SHED_DEVICE'"
        exit 1
        ;;
esac

# Increase default max gunzip size to 16M to accommodate larger kernels
sed -i 's/#define CONFIG_SYS_BOOTM_LEN.*/#define CONFIG_SYS_BOOTM_LEN 0x1000000/g' common/bootm.c &&
if [ "$SHDPKG_BOARDTYPE" == 'sunxi-h3' ] || [ "$SHDPKG_BOARDTYPE" == 'sunxi-h5' ]; then
    patch -Np1 -i "${SHED_PATCHDIR}/u-boot-2018.03-sunxi-no-env.patch" || exit 1
fi
cp "${SHED_CONTRIBDIR}/${SHED_DEVICE}.config" .config &&
make -j $SHED_NUMJOBS || exit 1

# Store the bootloader in /boot so it can be written to MMC in post-install
if [ "$SHDPKG_BOARDTYPE" == 'sunxi-h5' ]; then
    cat spl/sunxi-spl.bin u-boot.itb > u-boot-sunxi-with-spl.bin || exit 1
fi
install -Dm755 tools/mkimage "${SHED_FAKEROOT}/usr/bin/mkimage" &&
install -Dm644 "$SHDPKG_BOOTLOADER" "${SHED_FAKEROOT}/boot/u-boot/2018.03_${SHED_DEVICE}.bin" &&
install -Dm644 "${SHED_CONTRIBDIR}/extlinux.sample" "${SHED_FAKEROOT}/boot/extlinux/extlinux.sample"
