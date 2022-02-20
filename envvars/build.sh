#!/bin/bash

set -xe

yasm -felf64 -g dwarf2 main.asm
ld -o main main.o
rm main.o
