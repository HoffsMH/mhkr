#!/bin/bash

set -e
export root_partition=/dev/sda3
export boot_partition=/dev/sda1
export swap=/dev/sda2
export machine_hostname="test-machine"

curl https://mhkr.xyz/run/prep.sh > prep.sh
chmod +x prep.sh

./prep.sh
