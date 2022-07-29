#!/bin/bash

set -e
export root_partition=/dev/nvme0n1p7
export boot_partition=/dev/nvme0n1p4
export efi_partition=/dev/nvme0n1p5
export swap=/dev/nvme0n1p6
export machine_hostname="nile"

curl https://mhkr.io/prep.sh > prep.sh
chmod +x prep.sh

./prep.sh
