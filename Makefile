CPP=g++
CPPFLAGS=-m32 -std=c++11 -O1 

ASM=nasm
AFLAGS=-f elf32

all:MurmurHash3ASM 

main.o: main.cpp
	$(CPP) $(CPPFLAGS) -c main.cpp

MurmurHash_x86_32_assembler.o: MurmurHash_x86_32_assembler.asm
	$(ASM) $(AFLAGS) MurmurHash_x86_32_assembler.asm	

MurmurHash3ASM: main.o MurmurHash_x86_32_assembler.o
	$(CPP) $(CPPFLAGS) main.o MurmurHash_x86_32_assembler.o -o MurmurHash3