#!/bin/bash
if [ ! -e /boot/extlinux/extlinux.conf ]; then
    install -vDm644 /usr/share/defaults/extlinux/extlinux.conf /boot/extlinux/extlinux.conf
fi
echo "The u-boot bootloader has been copied to /boot/u-boot"
echo "Please refer to the documentation for you board to properly update it."
