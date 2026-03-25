#!/usr/bin/bash

# Check input
if [ -z "$1" ]; then
    echo "Usage: ./create_memory.sh <filename_without_extension>"
    exit 1
fi

FILE=$1

echo "Compiling $FILE.s..."

riscv32-unknown-elf-gcc -o $FILE $FILE.s \
-march=rv32i -mabi=ilp32 -nostdlib \
-Tcse4372_riscv.ld

echo "Converting to binary..."
riscv32-unknown-elf-objcopy $FILE -O binary $FILE.bin

echo "Generating memory.mem..."
hexdump -v -e '1/4 "%08x\n"' $FILE.bin > memory.mem

echo "Done. Generated memory.mem"
