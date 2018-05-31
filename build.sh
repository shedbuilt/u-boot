#!/bin/bash
case "$SHED_DEVICE" in
    nanopi-k1-plus|nanopi-neo2|nanopi-neo-plus2|orangepi-pc2)
        SHED_PKG_LOCAL_BOARDTYPE='sunxi-h5'
        SHED_PKG_LOCAL_BOOTLOADER_NAME='u-boot-sunxi-with-spl.bin'
        # Copy over bl31.bin built by Allwinner ARM Trusted Firmware (atf-sunxi)
        cp /boot/u-boot/bl31.bin . || exit 1
        ;;
    all-h3-cc|nanopi-neo|nanopi-m1-plus|orangepi-one|orangepi-pc|orangepi-lite)
        SHED_PKG_LOCAL_BOARDTYPE='sunxi-h3'
        SHED_PKG_LOCAL_BOOTLOADER_NAME='u-boot-sunxi-with-spl.bin'
        ;;
    aml-s905x-cc)
        SHED_PKG_LOCAL_BOARDTYPE='amlogic-gxl'
        SHED_PKG_LOCAL_BOOTLOADER_NAME='u-boot.bin'
        ;;
    *)
        echo "Unsupported device: '$SHED_DEVICE'"
        exit 1
        ;;
esac
# Increase default max gunzip size to 16M to accommodate larger kernels
sed -i 's/#define CONFIG_SYS_BOOTM_LEN.*/#define CONFIG_SYS_BOOTM_LEN 0x1000000/g' common/bootm.c || exit 1
if [ "$SHDPKG_BOARDTYPE" == 'sunxi-h3' ] || [ "$SHDPKG_BOARDTYPE" == 'sunxi-h5' ]; then
    patch -Np1 -i "${SHED_PATCHDIR}/u-boot-2018.03-sunxi-no-env.patch" || exit 1
fi
# Configure
cp "${SHED_PKG_CONTRIB_DIR}/${SHED_DEVICE}.config" .config &&
# Build
make -j $SHED_NUM_JOBS || exit 1
# For H5 boards, concatenate the SPL and ITB files to create a final bootloader
if [ "$SHDPKG_BOARDTYPE" == 'sunxi-h5' ]; then
    cat spl/sunxi-spl.bin u-boot.itb > u-boot-sunxi-with-spl.bin || exit 1
fi
# Install the mkimage tool used to wrap the kernel
install -Dm755 tools/mkimage "${SHED_FAKE_ROOT}/usr/bin/mkimage" &&
# Store the bootloader in /boot so it can be written to SD or eMMC in post-install
install -Dm644 "$SHDPKG_BOOTLOADER" "${SHED_FAKE_ROOT}/boot/u-boot/${SHED_PKG_VERSION}_${SHED_DEVICE}.bin" &&
install -Dm644 "${SHED_PKG_CONTRIB_DIR}/extlinux/extlinux.conf" "${SHED_FAKE_ROOT}/usr/share/defaults/extlinux/extlinux.conf"
