#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
SHED_PKG_LOCAL_LAST_DEVICE_VALUE=''
for $SHED_PKG_LOCAL_OPTION in "${!SHED_PKG_LOCAL_OPTIONS[@]}"; do
    SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
    case "$SHED_PKG_LOCAL_OPTION" in
        nanopi-neo2|nanopi-neo-plus2|orangepi-pc2)
            SHED_PKG_LOCAL_BOARDTYPE='sunxi-h5'
            SHED_PKG_LOCAL_BOOTLOADER_FILE='u-boot-sunxi-with-spl.bin'
            # Copy over bl31.bin built by Allwinner ARM Trusted Firmware (atf-sunxi)
            cp /boot/u-boot/bl31.bin . || exit 1
            ;;
        all-h3-cc|nanopi-neo|nanopi-m1-plus|orangepi-one|orangepi-pc|orangepi-lite)
            SHED_PKG_LOCAL_BOARDTYPE='sunxi-h3'
            SHED_PKG_LOCAL_BOOTLOADER_FILE='u-boot-sunxi-with-spl.bin'
            ;;
        aml-s905x-cc)
            SHED_PKG_LOCAL_BOARDTYPE='amlogic-gxl'
            SHED_PKG_LOCAL_BOOTLOADER_FILE='u-boot.bin'
            ;;
        *)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_LAST_DEVICE_VALUE"
            ;;
    esac
done
# Patch for the specific device
if [ -e "${SHED_PKG_PATCH_DIR}/${SHED_PKG_LOCAL_DEVICE}.patch" ]; then
    patch -Np1 -i "${SHED_PKG_PATCH_DIR}/${SHED_PKG_LOCAL_DEVICE}.patch" || exit 1
fi
# Increase default max gunzip size to 16M to accommodate larger kernels
sed -i 's/#define CONFIG_SYS_BOOTM_LEN.*/#define CONFIG_SYS_BOOTM_LEN 0x1000000/g' common/bootm.c || exit 1
if [ "$SHED_PKG_LOCAL_BOARDTYPE" == 'sunxi-h3' ] || [ "$SHED_PKG_LOCAL_BOARDTYPE" == 'sunxi-h5' ]; then
    patch -Np1 -i "${SHED_PKG_PATCH_DIR}/2018.05-sunxi-no-env.patch" || exit 1
fi
# Configure
cp "${SHED_PKG_CONTRIB_DIR}/${SHED_PKG_LOCAL_DEVICE}.config" .config &&
# Build
make -j $SHED_NUM_JOBS || exit 1
# For H5 boards, concatenate the SPL and ITB files to create a final bootloader
if [ "$SHED_PKG_LOCAL_BOARDTYPE" == 'sunxi-h5' ]; then
    cat spl/sunxi-spl.bin u-boot.itb > "$SHED_PKG_LOCAL_BOOTLOADER_FILE" || exit 1
fi
# Install the mkimage tool used to wrap the kernel
install -Dm755 tools/mkimage "${SHED_FAKE_ROOT}/usr/bin/mkimage" &&
# Store the bootloader in /boot so it can be written to SD or eMMC in post-install
install -Dm644 "$SHED_PKG_LOCAL_BOOTLOADER_FILE" "${SHED_FAKE_ROOT}/boot/u-boot/${SHED_PKG_VERSION}_${SHED_PKG_LOCAL_DEVICE}.bin" &&
install -Dm644 "${SHED_PKG_CONTRIB_DIR}/extlinux/extlinux.conf" "${SHED_FAKE_ROOT}/usr/share/defaults/extlinux/extlinux.conf"
