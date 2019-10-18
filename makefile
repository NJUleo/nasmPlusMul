install:
	nasm -g -felf32 kkp.asm
	ld  -m elf_i386 -o kkp kkp.o
	./kk.sh
clean:
	rm kkp kkp.o
