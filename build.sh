#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
for SHED_PKG_LOCAL_OPTION in "${!SHED_PKG_LOCAL_OPTIONS[@]}"; do
    case "$SHED_PKG_LOCAL_OPTION" in
        allh5cc|nanopik1plus|nanopineo2|nanopineoplus2|orangepipc2)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
            # Provide path to bl31.bin built by ARM Trusted Firmware (atf)
            SHED_PKG_UBOOT_ENVARS="PYTHON=python3 BL31=/boot/u-boot/sun50i_a64-bl31.bin"
            SHED_PKG_UBOOT_TYPE="sunxi"
            ;;
        rock64)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
            # Provide path to bl31.elf built by ARM Trusted Firmware (atf)
            SHED_PKG_UBOOT_ENVARS="PYTHON=python3 BL31=/boot/u-boot/rk3328-bl31.elf"
            SHED_PKG_UBOOT_TYPE="rockchip"
            ;;
        allh3cc|nanopineo|nanopim1plus|orangepione|orangepipc|orangepilite)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
            SHED_PKG_UBOOT_ENVARS="PYTHON=python3"
            SHED_PKG_UBOOT_TYPE="sunxi"
            ;;
    esac
done
# Patch
for SHED_PKG_LOCAL_PATCH in "${SHED_PKG_PATCH_DIR}"/*; do
     patch -Np1 -i "$SHED_PKG_LOCAL_PATCH" || exit 1
done
# Increase default max gunzip size to 16M to accommodate larger kernels
sed -i 's/#define CONFIG_SYS_BOOTM_LEN.*/#define CONFIG_SYS_BOOTM_LEN 0x1000000/g' common/bootm.c &&
# Copy Supplemental Device Trees
cp -v "${SHED_PKG_CONTRIB_DIR}/dts"/* arch/arm/dts &&
# Configure
cp "${SHED_PKG_CONTRIB_DIR}/configs/${SHED_PKG_LOCAL_DEVICE}.config" .config &&
# Build
make $SHED_PKG_UBOOT_ENVARS -j $SHED_NUM_JOBS &&
# Install the mkimage tool used to wrap the kernel
install -Dm755 tools/mkimage "${SHED_FAKE_ROOT}/usr/bin/mkimage" || exit 1
# Store the bootloader in /boot so it can be written to SD or eMMC in post-install
if [ "$SHED_PKG_UBOOT_TYPE" == 'rockchip' ]; then
    install -Dm644 idbloader.img "${SHED_FAKE_ROOT}/boot/u-boot/${SHED_PKG_VERSION}_${SHED_PKG_LOCAL_DEVICE}.img" &&
    install -m644 u-boot.itb "${SHED_FAKE_ROOT}/boot/u-boot/${SHED_PKG_VERSION}_${SHED_PKG_LOCAL_DEVICE}.itb" || exit 1
else
    install -Dm644 u-boot-sunxi-with-spl.bin "${SHED_FAKE_ROOT}/boot/u-boot/${SHED_PKG_VERSION}_${SHED_PKG_LOCAL_DEVICE}.bin" || exit 1
fi
# Install the default extlinux config file
install -Dm644 "${SHED_PKG_CONTRIB_DIR}/extlinux/extlinux.conf" "${SHED_FAKE_ROOT}${SHED_PKG_DEFAULTS_INSTALL_DIR}/boot/extlinux/extlinux.conf"
