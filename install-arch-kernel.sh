#!/bin/bash

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKING_DIR"

KERNEL_SUFFIX="-danny"

if [ "$1" = "config" ]; then
  echo -e "\033[1;36m---GETTING LOCAL KERNEL CONFIG---\033[1;0m"
  make localmodconfig           # get current kernel params
  # set our own kernel suffix
  echo -e "\033[1;36m---SETTING VERSION CONFIG---\033[1;0m"
  perl -pe "s/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=\"$KERNEL_SUFFIX\"/g" \
       .config > .config2
  # don't append the git info to the kernel name
  perl -pe 's/CONFIG_LOCALVERSION_AUTO=y/CONFIG_LOCALVERSION_AUTO=n/g' \
       .config2 > .config3
  echo -e "\033[1;36m---CLEANING UP---\033[1;0m"
  rm .config .config2
  mv .config3 .config
  # get the full name
  grep -Po "(?<=Linux/x86 )[0-9\.\-a-z]+(?= Kernel Configuration)" \
       .config > .arch-config-prefix
elif [ "$1" = "make" ]; then
  echo -e "\033[1;36m---BUILDING YOUR OPERATING SYSTEM, DOO DOO DOO---\033[1;0m"
  make -j8
elif [ "$1" = "mounted" ]; then
  # have to install modules at some point, let's add later
  if [ "$2" != "" ]; then
    sudo cp -v arch/x86_64/boot/bzImage "$1/boot"
    sudo cp -v System.map "$1/boot"
  else
    sudo cp -v arch/x86_64/boot/bzImage /mnt/boot/
    sudo cp -v System.map /mnt/boot/
  fi
elif [ "$1" = "running" ]; then
  # https://wiki.archlinux.org/index.php/Kernels/Compilation/Traditional
  config_prefix="$(grep -P ".*" .arch-config-prefix)"
  # the below installs into /lib/modules/$config_prefix$KERNEL_SUFFIX+
  # not sure why the plus is there at the end; let's just roll with it
  echo -e "\033[1;36m---INSTALLING MODULES---\033[1;0m"
  sudo make modules_install
  # get those headers in there
  echo -e "\033[1;36m---INSTALLING HEADERS---\033[1;0m"
  sudo make headers_install_all INSTALL_HDR_PATH=/usr
  # funnily enough, the x86_64 bzImage is just a symlink to the x86 image...not
  # sure what to make of that
  echo -e "\033[1;36m---INSTALLING SYSTEM IMAGE---\033[1;0m"
  sudo cp -v arch/x86_64/boot/bzImage \
       "/boot/vmlinuz-$config_prefix$KERNEL_SUFFIX+"
  echo -e "\033[1;36m---INSTALLING/SYMLINKING SYSTEM.MAP---\033[1;0m"
  sudo cp -v System.map "/boot/System.map-$config_prefix$KERNEL_SUFFIX+"
  sudo ln -sfv "/boot/System.map-$config_prefix$KERNEL_SUFFIX+" /boot/System.map
  echo -e "\033[1;36m---RUNNING ARCH LINUX-SPECIFIC MKINITCPIO---\033[1;0m"
  sudo mkinitcpio -k "$config_prefix$KERNEL_SUFFIX+" \
       -c /etc/mkinitcpio.conf \
       -g "/boot/initramfs-$config_prefix$KERNEL_SUFFIX+.img"
else
  echo "Please specify \"config,\" \"running\" or \"mounted.\""
  exit -1
fi
