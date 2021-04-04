#!/bin/bash

set -e

# pacman -Syu --noconfirm
# pacman -S vim --noconfirm

# cleanup from any prev attempts
umount -l /dev/nvme0n1p1 || echo "cleanup failed"
umount -l /dev/nvme0n1p2 || echo "cleanup failed"
umount -l /dev/mapper/cryptroot || echo "cleanup failed"
cryptsetup close cryptroot || echo "cleanup failed"
swapoff /dev/nvme0n1p3 || echo "cleanup failed"


mkswap /dev/nvme0n1p3 || echo "mkswap failed"
swapon /dev/nvme0n1p3 || echo "swapon failed"

echo "###############################################"
echo "disk password"
echo "###############################################"
cryptsetup luksFormat /dev/nvme0n1p4
cryptsetup open /dev/nvme0n1p4 cryptroot

mkfs.btrfs /dev/mapper/cryptroot
mkfs.vfat -F 32 /dev/nvme0n1p1
mkfs.vfat -F 32 /dev/nvme0n1p2

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p2 /mnt/boot/efi

pacman-mirrors -f
# pacman -Syu --noconfirm
# pacman -S vim --noconfirm

basestrap \
  /mnt \
  linux54 \
  linux-firmware \
  dhcpcd \
  refind \
  mkinitcpio \
  efibootmgr \
  neovim \
  base-devel \
  openssh \
  zsh \
  systemd-sysvcompat \
  mhwd \
  btrfs-progs



fstabgen -U /mnt > /mnt/etc/fstab

curl https://mhkr.io/euphrates/manjaro-chroot.sh > /mnt/chroot.sh

manjaro-chroot /mnt zsh /chroot.sh
