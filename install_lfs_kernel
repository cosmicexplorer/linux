#!/bin/bash

if [ -d "/mnt/boot/" ]; then
    sudo cp -v arch/x86_64/boot/bzImage /mnt/boot/vmlinuz-linux-current
    sudo cp -v System.map /mnt/boot/System.map
else
    echo "/mnt/boot not found" 1>&2
fi
