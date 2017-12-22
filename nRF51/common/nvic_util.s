	AREA nvic_utilities, CODE, READONLY

NVIC_BASE_ADDRESS			EQU		0xE000E000
NVIC_SETENAB_OFFSET			EQU		0x100
NVIC_CLRENAB_OFFSET			EQU		0x180
NVIC_SET_PENDING_REG_OFFSET	EQU		0x200
NVIC_CLR_PENDING_REG_OFFSET	EQU		0x280
NVIC_PRIORITY_REGS_OFFSET	EQU		0x400
		
nvic_set_priority	PROC
	EXPORT nvic_set_priority
	PUSH	{R4,R5,LR}
	;R0 contains irq number
	;R1 contains priority
	CMP		R0, #31
	BGT		out_set_priority
	CMP		R0, #64
	BGT		out_set_priority
	MOVS	R2, #8	;byte length
	EORS	R3, R3, R3	;clear destination for reversed priority
reverting_loop
	LSRS	R1, R1, #1
	BCC		shifted_out_0
	ADDS	R3, #1
shifted_out_0
	SUBS	R2, #1
	BEQ		end_of_reverting_loop
	LSLS	R3, R3, #1
	B		reverting_loop
;at this point R3 contains reverted priority in its LSByte
end_of_reverting_loop
	;calculate priority offset
	MOVS	R4, #0x03 	;mask
	MOVS	R5, #0xFF 	;priority mask
	ANDS	R4, R4, R0	;get number of bytes to shift
	LSRS	R0, #2		;get words to offset
	LDR 	R1, =NVIC_BASE_ADDRESS
	LDR		R2, =NVIC_PRIORITY_REGS_OFFSET
	ADD		R1, R2
	MOVS	R2, #8 	;byte length
	MULS	R4, R2, R4
	LSLS	R3, R4
	LSLS	R5, R4
	MOVS	R2, #4	;word lengh in bytes
	MULS	R0, R2, R0
	ADD		R1, R0
	LDR		R2, [R1]
	MVNS	R4, R5
	ANDS	R4, R4, R2
	ADD		R4, R3
	STR		R4, [R1]
out_set_priority
	POP		{R4,R5,PC}
	ENDP

nvic_clear_pending_irq	PROC
	EXPORT nvic_clear_pending_irq
	PUSH	{LR}
	;R0 contains irq number
	CMP		R0, #31
	BGT		out_clear_pending_irq
	MOVS	R1, #1	;mask
	LSLS	R1, R0
	LDR 	R0, =NVIC_BASE_ADDRESS
	LDR		R2, =NVIC_CLR_PENDING_REG_OFFSET
	ADD		R0, R2
	STR		R1, [R0]
out_clear_pending_irq
	POP		{PC}
	ENDP

nvic_enable_irq	PROC
	EXPORT nvic_enable_irq
	PUSH	{LR}
	;R0 contains irq number
	CMP		R0, #31
	BGT		out_enable_irq
	MOVS	R1, #1	;mask
	LSLS	R1, R0
	LDR 	R0, =NVIC_BASE_ADDRESS
	LDR		R2, =NVIC_SETENAB_OFFSET
	ADD		R0, R2
	STR		R1, [R0]
out_enable_irq
	POP		{PC}
	ENDP

nvic_disable_irq	PROC
	EXPORT nvic_disable_irq
	PUSH	{LR}
	;R0 contains irq number
	CMP		R0, #31
	BGT		out_disable_irq
	MOVS	R1, #1	;mask
	LSLS	R1, R0
	LDR 	R0, =NVIC_BASE_ADDRESS
	LDR		R2, =NVIC_CLRENAB_OFFSET
	ADD		R0, R2
	STR		R1, [R0]
out_disable_irq
	POP		{PC}
	ENDP

	END
