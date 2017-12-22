	AREA independent_utilities, CODE, READONLY

	ROUT
	
nrf_delay_mcs	PROC
	EXPORT	nrf_delay_mcs
	;R0: number or microseconds
0	CMP		R0, #0x00
	BEQ		exit_delay
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	SUBS	R0, R0, #0x01
	B		%0	
exit_delay
	BX		LR
	ENDP

test_breakpiont	PROC
	EXPORT	test_breakpiont
	BX		LR
	ENDP
		
zero_mem	PROC
	EXPORT	zero_mem
	;R0: first word address
	;R1, address of the word after the last one
	EORS	R2, R2, R2
loop_proc_zero
	STR		R2, [R0]
	ADDS	R0, #4
	CMP		R0, R1
	BLO		loop_proc_zero
	BX		LR
	ENDP
	
copy_words	PROC
	EXPORT	copy_words
	;R0: destination address
	;R1: source address
	;R2: address of the word beyond the end of the souce region
loop_copy_words
	LDR		R3, [R1]
	STR		R3, [R0]
	ADDS	R1, #0x04
	CMP		R1, R2
	BHS		exit_copy_words
	ADDS	R0, #0x04
	B		loop_copy_words
exit_copy_words
	BX		LR
	ENDP

;void * memcpy ( void * destination, const void * source, size_t num );
	ROUT
memcpy	PROC
	EXPORT	memcpy
	;R0: destination buffer
	;R1: source buffer
	;R2: number of bytes to copy
	PUSH	{LR}
	CMP		R2, #0x00
	BEQ		%1
0	LDRB	R3, [R1]
	STRB	R3, [R0]
	SUBS	R2, #0x01
	CMP		R2, #0x00
	BEQ		%1
	ADDS	R0, #0x01
	ADDS	R1, #0x01
	B		%0
1	POP		{PC}
	ENDP

;int memcmp( const void* lhs, const void* rhs, std::size_t count );
	ROUT
memcmp	PROC
	EXPORT	memcmp
	;R0: 1st memory buffer to compare
	;R1: 2nd memory buffer to compare
	;R2: number of bytes to examine
	;returns 0xFF(0xFFFFFFFF) if the value in R0 < value in R1, 0x00 if equal, 0x01 vR0 > vR1
	;if R2 == 0, returns 0x00
	PUSH	{LR,R4,R5}
	EORS	R5,R5,R5	
	CMP		R2, #0x00
	BEQ		%4
0	LDRB	R3, [R0]
	LDRB	R4, [R1]
	CMP		R3, R4
	BLO		%1
	BHI		%2
	;equal
	EORS	R5,R5,R5
	B		%3
1	MOVS	R5, #0xFF
	SXTB	R5, R5
	B		%4
2	MOVS	R5, #0x01
	B		%4
3	SUBS	R2, #0x01
	CMP		R2, #0x00
	BEQ		%4
	ADDS	R0, #0x01
	ADDS	R1, #0x01
	
	B		%0
4	MOV		R0, R5
	POP		{PC,R4,R5}
	ENDP

	ROUT
copy_mem	PROC
	EXPORT	copy_mem
	;R0: destination address
	;R1: source address
	;R2: address of the byte beyond the end of the souce region
0	LDRB	R3, [R1]
	STRB	R3, [R0]
	ADDS	R1, #0x01
	CMP		R1, R2
	BHS		%1
	ADDS	R0, #0x01
	B		%0
1	BX		LR
	ENDP

	END
