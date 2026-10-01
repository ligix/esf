.PHONY: default clean

NASM_SRCS := $(wildcard *.nasm)
ESF_TARGETS := $(NASM_SRCS:.nasm=.esf)

default: $(ESF_TARGETS)

%.esf: %.bin
	(printf '\x7FESF'; cat $<) > $@
	chmod +x $@

%.bin: %.nasm
	nasm -f bin $< -o $@

clean:
	rm -f *.bin *.esf
