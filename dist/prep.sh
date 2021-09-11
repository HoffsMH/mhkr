#!/bin/bash

# cleanup from any prev attempts
umount -l $boot_partition || echo "cleanup failed on umounting"
umount -l /dev/nvme0n1p2 || echo "cleanup failed on umounting "
umount -l /dev/mapper/cryptroot || echo "cleanup failed on umounting cryptroot"
cryptsetup close cryptroot || echo "cleanup failed on closing cryptroot"
swapoff $swap || echo "cleanup failed"


mkswap $swap || echo "mkswap failed"
swapon $swap || echo "swapon failed"

echo "###############################################"
echo "disk password"
echo "###############################################"
cryptsetup luksFormat $root_partition
cryptsetup open $root_partition cryptroot

mkfs.ext4 /dev/mapper/cryptroot
mkfs.vfat -F 32 $boot_partition
mkfs.vfat -F 32 $efi_partition

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount $boot_partition /mnt/boot
mkdir -p /mnt/boot/efi
mount $efi_partition /mnt/boot/efi

pacman-mirrors -f
# pacman -Syu --noconfirm
# pacman -S vim --noconfirm

basestrap \
  /mnt \
  linux510 \
  linux-firmware \
  dhclient \
  refind \
  mkinitcpio \
  efibootmgr \
  neovim \
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

curl https://mhkr.io/chroot.sh > /mnt/chroot.sh

manjaro-chroot /mnt zsh /chroot.sh $machine_hostname
