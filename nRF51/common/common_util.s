	AREA common_utilities, CODE, READONLY

	;GET	constants.inc

	EXTERN	nvic_set_priority
	EXTERN	nvic_clear_pending_irq
	EXTERN	nvic_enable_irq
	EXTERN	nvic_disable_irq

drv_common_irq_enable	PROC
	EXPORT	drv_common_irq_enable
	PUSH	{R4,R5,LR}
	;R0 contains irq number
	;R1 contains priority
	MOV		R4, R0
	MOV		R5, R1
	BL		nvic_set_priority
	MOV		R0, R4
	BL		nvic_clear_pending_irq
	MOV		R0, R4
	BL		nvic_enable_irq
	POP		{R4,R5,PC}
	ENDP

drv_common_irq_disable	PROC
	EXPORT	drv_common_irq_disable
	PUSH	{R4,LR}
	;R0: irq number
	MOV		R4, R0
	BL		nvic_clear_pending_irq
	MOV		R0, R4
	BL		nvic_disable_irq
	POP		{R4,PC}
	ENDP

	MACRO
    BITS_SET
	;R0: address
	;R1: mask
	;R2: value
	PUSH	{R3}
	LDR		R3, [R0]
	MVNS	R1, R1				; negate mask
	ORRS	R3, R1				; zero bits
	ORRS	R3, R2				; set bits
	STR	 	R3, [R0]
	POP		{R3}
	MEND
	
	END
