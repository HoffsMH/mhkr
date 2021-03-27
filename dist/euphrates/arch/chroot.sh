#!/bin/bash

set -e


ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc

sudo echo "LANG=en_US.UTF-8" >> /etc/locale.conf
sudo echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
sudo echo "en_US ISO-8859-1" >> /etc/locale.gen
locale-gen

localectl set-keymap --no-convert us
loadkeys us

echo "euphrates" >> /etc/hostname

# sudoers thing
if [  -f /etc/sudoers.d/10-installer ]; then
  sed -i 's/^\s*\(%wheel\s\+ALL=(ALL)\)\sALL/\1 NOPASSWD: ALL/' /etc/sudoers.d/10-installer
fi

sed -i 's/^\s*\(%wheel\s\+ALL=(ALL)\)\sALL/\1 NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers


systemctl enable iwd.service
systemctl start iwd.service

systemctl enable dhcpcd.service
systemctl start dhcpcd.service

echo "###############################################"
echo "ROOT PASSWORD"
echo "###############################################"

passwd

echo "###############################################"
echo "hoffs PASSWORD"
echo "###############################################"

useradd -m -G wheel,tty,input,network,sys,video,storage,lp,audio,video -s /usr/bin/zsh hoffs

passwd hoffs

echo "###############################################"
echo "refind install"
echo "###############################################"


refind-install

echo "###############################################"
echo "Edit /etc/mkinitcpio.conf"
echo "###############################################"
echo ''
echo 'HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)'

echo 'HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)' >> /etc/mkinitcpio.conf

nvim /etc/mkinitcpio.conf

echo "###############################################"
echo "Edit /boot/refind_linux.conf"
echo "###############################################"
echo ''
echo 'ro cryptdevice=UUID=<device-UUID-from-blkid-here>:cryptroot root=/dev/mapper/cryptroot'

echo '"ro cryptdevice=UUID=<device-UUID-from-blkid-here>:cryptroot root=/dev/mapper/cryptroot"' >> /boot/refind_linux.conf
blkid >> /boot/refind_linux.conf

nvim /boot/refind_linux.conf

mkinitcpio -P
