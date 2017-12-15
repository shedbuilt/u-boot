#!/bin/bash
if [ ! -e /boot/extlinux/extlinux.conf ]; then
    mkdir -pv /boot/extlinux
    cp -v /boot/extlinux/extlinux.template /boot/extlinux/extlinux.conf
fi
