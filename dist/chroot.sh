#!/bin/bash

set -e

sudo echo "LANG=en_US.UTF-8" >> /etc/locale.conf
sudo echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
sudo echo "en_US ISO-8859-1" >> /etc/locale.gen

locale-gen

echo "$1" > /etc/hostname

# sudoers thing
if [  -f /etc/sudoers.d/10-installer ]; then
  sed -i 's/^\s*\(%wheel\s\+ALL=(ALL)\)\sALL/\1 NOPASSWD: ALL/' /etc/sudoers.d/10-installer
fi

sed -i 's/^\s*\(%wheel\s\+ALL=(ALL)\)\sALL/\1 NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers


systemctl enable iwd.service || echo "no iwd"
systemctl start iwd.service || echo "no iwd"

systemctl enable dhcpcd.service || echo "no dhcpcd"
systemctl start dhcpcd.service || echo "no dhcpcd"

systemctl enable NetworkManager.service || echo "no network manager"
systemctl start NetworkManager.service || echo "no network manager"

echo "###############################################"
echo "ROOT PASSWORD"
echo "###############################################"

passwd

echo "###############################################"
echo "hoffs PASSWORD"
echo "###############################################"

useradd -m -G wheel,tty,input,network,sys,video,storage,lp,audio,video -s /usr/bin/zsh hoffs || echo "user already exists"

passwd hoffs

echo "###############################################"
echo "Edit /etc/fstab"
echo "###############################################"
echo ''
echo "edit swap uuid to be correct" >> /etc/fstab
blkid >> /etc/fstab

nvim /etc/fstab

if [ -d "/boot/efi" ]; then
  echo "###############################################"
  echo "refind install"
  echo "###############################################"

  refind-install
else
  echo "###############################################"
  echo "grub install"
  echo "###############################################"

  grub-install /dev/sda

fi

echo "###############################################"
echo "Edit /etc/mkinitcpio.conf"
echo "###############################################"
echo ''
echo 'HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)'

echo 'HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt filesystems fsck)' >> /etc/mkinitcpio.conf

nvim /etc/mkinitcpio.conf

if [ -d "/boot/efi" ]; then
  echo "###############################################"
  echo "Edit /boot/refind_linux.conf"
  echo "###############################################"
  echo ''
  echo 'ro cryptdevice=UUID=<device-UUID-from-blkid-here>:cryptroot root=/dev/mapper/cryptroot'

  echo '"ro cryptdevice=UUID=<device-UUID-from-blkid-here>:cryptroot root=/dev/mapper/cryptroot"' >> /boot/refind_linux.conf
  blkid >> /boot/refind_linux.conf

  nvim /boot/refind_linux.conf
fi


mhwd -a pci nonfree 0300

mkinitcpio -P
