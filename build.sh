#!/bin/bash

# make -C build clean --no-print-directory
rm -rf build VNExos_v0.1.img VNExos_v0.1.iso || true
cmake -B build
make -C build --no-print-directory
