# Executable Shellcode Format

A custom executable binary format that holds shellcode to be executed.

### File Format
It's the magick number `\x7FESF` followed by the shellcode to be executed:
```
offset:  0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
       +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
       | 7F| 45| 53| 46|  shellcode (opaque, N bytes) ...              |
       +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
```

### How to run it
As long as you have nasm installed and your kernel supports binfmt (check if `/proc/sys/fs/binfmt_misc/register` exists):
```bash
cd interp
make
sudo make install
cd ../examples/hello_world
make
./hello_world.esf```
