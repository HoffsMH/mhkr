#!/bin/bash

set -e
root_partition=/dev/nvme0n1p4
boot_partition=/dev/nvme0n1p1
efi_partition=/dev/nvme0n1p2
swap=/dev/nvme0n1p3
machine_hostname="euphrates"

curl https://mhkr.io/prep.sh > prep.sh
chmod +x prep.sh

./prep.sh
