#!/bin/bash

set -e
export root_partition=/dev/nvme0n1p4
export boot_partition=/dev/nvme0n1p1
export efi_partition=/dev/nvme0n1p2
export swap=/dev/nvme0n1p3
export machine_hostname="danube"

curl https://mhkr.io/prep.sh > prep.sh
chmod +x prep.sh

./prep.sh
