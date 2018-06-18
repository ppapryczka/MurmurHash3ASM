; 	void MurmurHash3_x86_32  ( const void * key, int len, uint32_t seed, void * out );

;	[ebp+8]  = const void * key
;	[ebp+12] = int len
;	[ebp+16] = uint32_t seed
;	[ebp+20] = void * out



section .data
c1 dd 0xcc9e2d51, 0xcc9e2d51, 0xcc9e2d51, 0xcc9e2d51
	  
c2 dd 0x1b873593, 0x1b873593, 0x1b873593, 0x1b873593

	  
section	.text
global  MurmurHash3_x86_32_assembler
		
	
Count_new_result_value_xmm:
	; h1 ^= k1;	
	pxor xmm0, xmm2
	
	; h1 = ROTL32(h1,13);
	movdqa xmm3, xmm0 
	pslld xmm0, 13
	psrld xmm3, 19
	por xmm0, xmm3
	
	; h1 = h1*5+0xe6546b64;
	pmulld xmm0, xmm4
	paddd xmm0, xmm5
	
	ret
		
MurmurHash3_x86_32_assembler:

prolog:
	push ebp
	mov ebp, esp
	
	push ebx
	push esi
	push edi

body:
	mov eax, [ebp+16] 	; setting seed as a result
	movd xmm0, eax 
	
	mov ebx, [ebp+12] 
	shr ebx, 2		 	; number of blocks 

	
	mov edi, ebx		
	shl edi, 2		

	
	mov ecx, [ebp+8]	
	add ecx, edi		; actual block adres 
	neg edi				; loop iterator  
	
	mov eax, 5
	movd xmm4, eax
	mov eax, 0xe6546b64
	movd xmm5, eax
	movdqu xmm6, [c1]
	movdqu xmm7, [c2]
			
	shr ebx, 2			
	neg ebx				; -number of blocks		
			
					
					
					vector_unit_main_loop: 
					
						jz befor_no_vector_unit_main_loop
						
						; uint32_t k1 = getblock32(blocks,i);
						movdqu xmm2, [ecx + edi]
						
						; k1 *= c1;
						pmulld xmm2, xmm6
						
						; k1 = ROTL32(k1,15);
						movdqa xmm3 , xmm2 
						pslld xmm3, 15
						psrld xmm2, 17	
						por xmm2, xmm3 
						
						; k1 *= c2;
						pmulld xmm2, xmm7
						
						; h1 ^= k1;
						; h1 = ROTL32(h1,13); 
						; h1 = h1*5+0xe6546b64;
						
						call Count_new_result_value_xmm
						
						psrldq xmm2, 4
						call Count_new_result_value_xmm
						
						psrldq xmm2, 4
						call Count_new_result_value_xmm
						
						psrldq xmm2, 4
						call Count_new_result_value_xmm
						
						add edi, 16
						inc ebx	
						jmp vector_unit_main_loop
							
		
befor_no_vector_unit_main_loop:
	pextrd ebx, xmm0, 0	
		
no_vector_unit_main_loop:	
	test edi, edi
	jz tail
		
	; uint32_t k1 = getblock32(blocks,i);
	mov eax, [ecx + edi]
	
	; k1 *= c1;
	mov esi, [c1]
	mul esi 
	
	; k1 = ROTL32(k1,15);
	mov edx, eax 
	shl edx, 15
	shr eax, 17
	or eax, edx  
	
	; k1 *= c2;
	mov esi, [c2]
	mul esi
	
	; h1 ^= k1;
    ; h1 = ROTL32(h1,13); 
    ; h1 = h1*5+0xe6546b64;

	; h1 ^= k1;
	xor ebx, eax	
	
	; h1 = ROTL32(h1,13); 
	mov esi, ebx
	shl esi, 13
	shr ebx, 19 
	or ebx, esi 
	
	; h1 = h1*5+0xe6546b64;
	lea ebx, [ebx + ebx*4]
	add ebx,  0xe6546b64
	
	add edi, 4
	jmp no_vector_unit_main_loop
	
	
tail:

	; in edi will be stored the value 'k1'
	xor edi, edi 
	mov edx, [ebp+12]
	and edx, 3
	
	jz tail_0 	

	cmp edx, 2
	jg tail_3
	je tail_2
	jl tail_1
							
						tail_3:
							; k1 ^= tail[2] << 16;
							xor eax, eax 
							mov al, [ecx + 2]
							shl eax, 16
							xor edi, eax
							
						tail_2:
							; k1 ^= tail[1] << 8; 
							xor eax, eax
							mov al, [ecx + 1]
							shl eax, 8
							xor edi, eax  
							
						tail_1:
							; k1 ^= tail[0];
							xor eax, eax
							mov al, [ecx]
							xor edi, eax 
							
						tail_0:
							; 'k1' goes to eax, because of mul operation
							mov eax, edi
								
							; k1 *= c1; 
							mov edx, [c1]
							mul edx
							
							; k1 = ROTL32(k1,15);	
							mov edi, eax 
							shl edi, 15
							shr eax, 17
							or eax, edi
								
							; k1 *= c2;
							mov edx, [c2]
							mul edx
							
							; h1 ^= k1;
							xor ebx, eax
	
finalization:	
	mov eax, ebx 
	; h1 ^= len;
	
	mov edi, [ebp+12]
	xor eax, edi 
	
	; h1 = fmix32(h1);
	mov ebx, eax 
	shr ebx, 16
	xor eax, ebx
	mov edi, 0x85ebca6b
	mul edi 
	mov ebx, eax 
	shr ebx, 13
	xor eax, ebx 
	mov edi, 0xc2b2ae35
	mul edi
	mov ebx, eax
	shr ebx, 16
	xor eax, ebx
	
epilog: 
	mov ebx, [ebp+20]
	mov [ebx], eax
	pop edi
	pop esi
	pop ebx

	mov esp, ebp
	pop ebp
	ret

	

	
