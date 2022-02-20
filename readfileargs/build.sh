set -xe

yasm -felf64 main.asm
ld -o main main.o
rm main.o
