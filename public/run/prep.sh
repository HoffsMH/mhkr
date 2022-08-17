#!/bin/bash

sudo pacman -S neovim zsh

# cleanup from any prev attempts
if [ -z ${boot_partition+x} ]; then
  echo "no boot!"
else
  umount -l $boot_partition || echo "cleanup failed on umounting boot"
fi

if [ -z ${efi_partition+x} ]; then
  echo "no efi!"
else
  umount -l $efi_partition || echo "cleanup failed on umounting efi"
fi
umount -l /dev/mapper/cryptroot || echo "cleanup failed on umounting cryptroot"
cryptsetup close cryptroot || echo "cleanup failed on closing cryptroot"
umount -l $root_partition || echo "cleanup failed on umounting root_partition"
swapoff $swap || echo "cleanup failed"


mkswap $swap || echo "mkswap failed"
swapon $swap || echo "swapon failed"

echo "###############################################"
echo "disk password"
echo "###############################################"
cryptsetup luksFormat $root_partition
cryptsetup open $root_partition cryptroot

mkfs.ext4 /dev/mapper/cryptroot

if [ -z ${boot_partition+x} ]; then
  echo "no boot! no mkfs"
else
  mkfs.vfat -F 32 $boot_partition
fi

if [ -z ${efi_partition+x} ]; then
  echo "no efi!"
else
  echo "efi found!"
  mkfs.vfat -F 32 $efi_partition
  mkdir -p /mnt/boot/efi
  mount $efi_partition /mnt/boot/efi
fi


mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
if [ -z ${boot_partition+x} ]; then
  echo "no boot! no mkfs"
else
  mount $boot_partition /mnt/boot
fi

pacman-mirrors -f
# pacman -Syu --noconfirm
# pacman -S vim --noconfirm

basestrap \
  /mnt \
  polkit\
  linux515 \
  linux515-headers \
  linux-firmware \
  dhclient \
  refind \
  mkinitcpio \
  efibootmgr \
  neovim \
  vim \
  base-devel \
  openssh \
  zsh \
  systemd-sysvcompat \
  mhwd \
  yay \
  networkmanager \
  manjaro-tools \
  man-db \
  ntp

fstabgen -U /mnt > /mnt/etc/fstab

curl https://mhkr.xyz/run/chroot.sh > /mnt/chroot.sh

manjaro-chroot /mnt zsh /chroot.sh $machine_hostname $efi_partition
