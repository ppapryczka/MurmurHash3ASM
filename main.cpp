// std
#include <cstdint>
#include <ctime>
#include <iostream>

// original MurmurrHash3
#include "MurmurHash3.h"


extern "C"
#ifdef _cplusplus
{
#endif
	void MurmurHash3_x86_32_assembler (const void* key, int len, 
		uint32_t seed, void * out);
#ifdef _cplusplus
}
#endif


int main(void)
{
	srand(time(NULL));
	
	uint32_t seed = static_cast<char>(rand()%100);
	char *table; 
	uint32_t cppResult; 
	uint32_t asmResult;
	uint32_t tableSize=1000;
	
	table = new char[tableSize];
	
	// fulfill table with random numbers
	for(int k = 0; k<tableSize; ++k){
			table[k] = static_cast<char>(rand()%100);
	}

	// run asm version
	MurmurHash3_x86_32_assembler(table, tableSize, seed, &asmResult);
	
	// run cpp version
	MurmurHash3_x86_32(table, tableSize, seed, &cppResult);
	
	delete []table;
	
	std::cout<<"CPP result: "<<cppResult<<std::endl;
	std::cout<<"ASM result: "<<asmResult<<std::endl;
	
	return 0;
}
