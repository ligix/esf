interp: interp.nasm
	nasm -felf64 interp.nasm && ld interp.o -o interp

install:
	echo ":esf:M::\x7FESF::$(realpath interp):P" > /proc/sys/fs/binfmt_misc/register

uninstall:
	echo -1 > /proc/sys/fs/binfmt_misc/esf

clean:
	rm -f interp interp.o
