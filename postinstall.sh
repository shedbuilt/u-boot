#!/bin/bash
if [ ! -e /boot/extlinux/extlinux.conf ]; then
    install -m644 /usr/share/defaults/extlinux/extlinux.conf /boot/extlinux/extlinux.conf
fi
