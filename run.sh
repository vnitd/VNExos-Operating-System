#!/bin/bash

# qemu-system-x86_64 -enable-kvm -m 2G -drive format=raw,file=VNExos_v0.1.img,if=ide,index=0,media=disk
qemu-system-x86_64 \
    -m 1G \
    -drive format=raw,file=VNExos_v0.1.img \
    -smp 2 -machine pc,accel=kvm \
    -cpu host -global PIIX4_PM.disable_s3=1 \
    -global PIIX4_PM.disable_s4=1 \
    -boot d \
    # -enable-kvm \