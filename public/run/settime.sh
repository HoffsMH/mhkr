#!/bin/bash

sudo ntpd -qg
sudo timedatectl set-timezone "$(curl --fail https://ipapi.co/timezone)"
sudo hwclock -w
