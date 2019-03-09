CPP=g++
CPPFLAGS=-m32 -std=c++11 -O3 

ASM=nasm
AFLAGS=-f elf32

all: MurmurHash3ASM clean 

main.o: main.cpp
	$(CPP) $(CPPFLAGS) -c main.cpp

MurmurHash_x86_32_assembler.o: MurmurHash_x86_32_assembler.asm
	$(ASM) $(AFLAGS) MurmurHash_x86_32_assembler.asm

MurmurHash3.o: MurmurHash3.cpp
	$(CPP) $(CPPFLAGS) -c MurmurHash3.cpp

MurmurHash3ASM: main.o MurmurHash_x86_32_assembler.o MurmurHash3.o
	$(CPP) $(CPPFLAGS) main.o MurmurHash_x86_32_assembler.o MurmurHash3.o -o MurmurHash3

clean:
	rm *.o
