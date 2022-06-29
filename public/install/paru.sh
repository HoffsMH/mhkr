#! /bin/bash
echo "###############################################"
echo "PARU"
echo "###############################################"

mkdir -p "$HOME/code/util"
pushd "$HOME/code/util"

rm -fr paru

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
