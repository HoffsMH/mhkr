#!/bin/bash

set -e
export root_partition=/dev/nvme0n1p7
export boot_partition=/dev/nvme0n1p8
export efi_partition=/dev/nvme0n1p9
export swap=/dev/nvme0n1p10
export machine_hostname="rigel"

curl https://mhkr.xyz/run/prep.sh > prep.sh
chmod +x prep.sh

./prep.sh
