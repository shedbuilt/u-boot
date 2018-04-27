#!/bin/bash
if [ ! -e /boot/extlinux/extlinux.conf ]; then
    install -m644 /boot/extlinux/extlinux.sample /boot/extlinux/extlinux.conf
fi
echo "The u-boot bootloader has been installed to /boot/u-boot/2018.03_${SHED_DEVICE}.bin"
echo "Please refer to the documentation for you board to properly update it."
