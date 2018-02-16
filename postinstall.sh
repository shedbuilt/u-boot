#!/bin/bash
if [ ! -e /boot/extlinux/extlinux.conf ]; then
    install -m644 /boot/extlinux/extlinux.sample /boot/extlinux/extlinux.conf
fi
