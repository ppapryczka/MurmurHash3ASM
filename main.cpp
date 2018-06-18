#include <stdio.h>
#include <stdint.h>

#include <iostream>

#include <stdlib.h>    
#include <time.h>
#include <chrono>
#include <ctime>



extern "C"
#ifdef _cplusplus
{
#endif
	void MurmurHash3_x86_32_assembler ( const void * key, int len, uint32_t seed, void * out );
#ifdef _cplusplus
}
#endif


int main(void)
{
	srand(time(NULL));
	
	uint32_t seed = 120;
	char *table; 
	uint32_t cppResult; 
	uint32_t asmResult;
	
	
	for(int i = 500; i<=100000; i=i+500)
	{
		
		table = new char[i];
		
		for(int k = 0; k<i; ++k)
		{
			table[k] = static_cast<char>(rand()%100);
		}

		auto startASM = std::chrono::system_clock::now();
		MurmurHash3_x86_32_assembler(table, i, seed, &asmResult);
		auto endASM = std::chrono::system_clock::now();
		std::chrono::duration<double> diffASM = endASM - startASM;
		
		std::cout<<"MurmurHash3ASM performance time  "<<diffASM.count()<<std::endl;
		
		delete []table;
	}
	
	
	
	
	return 0;
}
