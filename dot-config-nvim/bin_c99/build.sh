#!/usr/bin/bash

# gcc -o sysinfo sysinfo.c $(pkg-config --cflags --libs msgpack)

# gcc -o sysinfo sysinfo.c -L/usr/local/lib -lmsgpack -I/usr/local/include

# gcc -o sysinfo sysinfo.c \
#     -I/opt/homebrew/include \
#     -L/opt/homebrew/lib \
#     -lmsgpackc

gcc -o something something.c
