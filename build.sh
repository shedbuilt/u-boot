#!/bin/bash
declare -A SHED_PKG_LOCAL_OPTIONS=${SHED_PKG_OPTIONS_ASSOC}
for SHED_PKG_LOCAL_OPTION in "${!SHED_PKG_LOCAL_OPTIONS[@]}"; do
    case "$SHED_PKG_LOCAL_OPTION" in
        allh5cc|nanopik1plus|nanopineo2|nanopineoplus2|orangepipc2)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
            SHED_PKG_LOCAL_BOARDTYPE='sunxi-h5'
            SHED_PKG_LOCAL_BOOTLOADER_FILE='u-boot-sunxi-with-spl.bin'
            # Copy over bl31.bin built by Allwinner ARM Trusted Firmware (atf-sunxi)
            cp /boot/u-boot/bl31.bin . || exit 1
            ;;
        allh3cc|nanopineo|nanopim1plus|orangepione|orangepipc|orangepilite)
            SHED_PKG_LOCAL_DEVICE="$SHED_PKG_LOCAL_OPTION"
            SHED_PKG_LOCAL_BOARDTYPE='sunxi-h3'
            SHED_PKG_LOCAL_BOOTLOADER_FILE='u-boot-sunxi-with-spl.bin'
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
make PYTHON=python3 -j $SHED_NUM_JOBS || exit 1
if [ "$SHED_PKG_LOCAL_BOARDTYPE" == 'sunxi-h3' ]; then
    # For 32-bit sunxi boards, pad the SPL to 32K then concatenate u-boot.bin to create a bootloader
    dd if=/dev/zero bs=1024 count=32 | tr "\000" "\377" > u-boot-sunxi-spl-padded.bin &&
    dd if=spl/sunxi-spl.bin of=u-boot-sunxi-spl-padded.bin conv=notrunc &&
    cat u-boot-sunxi-spl-padded.bin u-boot.img > "$SHED_PKG_LOCAL_BOOTLOADER_FILE" || exit 1
fi
# Install the mkimage tool used to wrap the kernel
install -Dm755 tools/mkimage "${SHED_FAKE_ROOT}/usr/bin/mkimage" &&
# Store the bootloader in /boot so it can be written to SD or eMMC in post-install
install -Dm644 "$SHED_PKG_LOCAL_BOOTLOADER_FILE" "${SHED_FAKE_ROOT}/boot/u-boot/${SHED_PKG_VERSION}_${SHED_PKG_LOCAL_DEVICE}.bin" &&
# Install the default extlinux config file
install -Dm644 "${SHED_PKG_CONTRIB_DIR}/extlinux/extlinux.conf" "${SHED_FAKE_ROOT}${SHED_PKG_DEFAULTS_INSTALL_DIR}/boot/extlinux/extlinux.conf"
