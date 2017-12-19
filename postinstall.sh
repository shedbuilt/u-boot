#!/bin/bash
if [ ! -e /boot/extlinux/extlinux.conf ]; then
    cp -v /boot/extlinux/extlinux.template /boot/extlinux/extlinux.conf
fi
