	AREA gpiote_utilities, CODE, READONLY

	get macro.s

gpiote_event_lotohi_0_config	PROC
	EXPORT	gpiote_event_lotohi_0_config
	;R0: pin number
	LSLS	R0, #8
	MOVS	R1, #1
	LSLS	R1, #16
	ADDS	R1, R0, R1
	ADDS	R1, #1
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R2, =GPIOTE_CONFIG_OFFSET
	ADDS	R0, R2, R0
	STR		R1, [R0]
	BX		LR
	ENDP
		
gpiote_event_hitolo_0_config	PROC
	EXPORT	gpiote_event_hitolo_0_config
	;R0: pin number
	LSLS	R0, #8
	MOVS	R1, #1
	LSLS	R1, #17
	ADDS	R1, R0, R1
	ADDS	R1, #1
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R2, =GPIOTE_CONFIG_OFFSET
	ADDS	R0, R2, R0
	STR		R1, [R0]
	BX		LR
	ENDP

gpiote_event_toggle_0_config	PROC
	EXPORT	gpiote_event_toggle_0_config
	;R0: pin number
	LSLS	R0, #8
	MOVS	R1, #3
	LSLS	R1, #16
	ADDS	R1, R0, R1
	ADDS	R1, #1
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R2, =GPIOTE_CONFIG_OFFSET
	ADDS	R0, R2, R0
	STR		R1, [R0]
	BX		LR
	ENDP

gpiote_event_int_port_enable	PROC
	EXPORT	gpiote_event_int_port_enable
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_INTEN_OFFSET
	ADDS	R2, R1, R0
	LDR		R2, [R2]
	MOVS	R1, #1
	LSLS	R1, #31
	ORRS	R2, R1
	LDR		R1, =GPIOTE_INTENSET_OFFSET
	ADDS	R0, R1, R0
	STR		R2, [R0]
	BX		LR
	ENDP

gpiote_event_int_in_0_enable	PROC
	EXPORT	gpiote_event_int_in_0_enable
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_INTENSET_OFFSET
	ADDS	R0, R1, R0
	MOVS	R1, #1
	STR		R1, [R0]
	BX		LR
	ENDP
		
gpiote_event_int_in_0_disable	PROC
	EXPORT	gpiote_event_int_in_0_disable
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_INTENCLR_OFFSET
	ADDS	R0, R1, R0
	MOVS	R1, #1
	STR		R1, [R0]
	BX		LR
	ENDP

gpiote_event_0_clear	PROC
	EXPORT	gpiote_event_0_clear
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_IN_0_OFFSET
	ADD		R0, R1, R0
	EORS	R1,R1,R1
	STR		R1, [R0]
	BX		LR
	ENDP

gpiote_event_port_clear	PROC
	EXPORT	gpiote_event_port_clear
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_PORT_OFFSET
	ADD		R0, R1, R0
	EORS	R1,R1,R1
	STR		R1, [R0]
	BX		LR
	ENDP

gpiote_event_hitolo_1_config	PROC
	EXPORT	gpiote_event_hitolo_1_config
	;R0: pin number
	LSLS	R0, #8
	MOVS	R1, #1
	LSLS	R1, #17
	ADDS	R1, R0, R1
	ADDS	R1, #1
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R2, =GPIOTE_CONFIG_OFFSET
	ADDS	R2, #4
	ADDS	R0, R2, R0
	STR		R1, [R0]
	BX		LR
	ENDP
		
gpiote_event_toggle_1_config	PROC
	EXPORT	gpiote_event_toggle_1_config
	;R0: pin number
	LSLS	R0, #8
	MOVS	R1, #3
	LSLS	R1, #16
	ADDS	R1, R0, R1
	ADDS	R1, #1
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R2, =GPIOTE_CONFIG_OFFSET
	ADDS	R0, R2, R0
	STR		R1, [R0, #4]
	BX		LR
	ENDP

gpiote_event_int_in_1_enable	PROC
	EXPORT	gpiote_event_int_in_1_enable
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_INTENSET_OFFSET
	ADDS	R0, R1, R0
	MOVS	R1, #0x02		;mask
	MOVS	R2, #0x02		;value
    BITS_SET
	BX		LR
	ENDP
		
gpiote_event_1_clear	PROC
	EXPORT	gpiote_event_1_clear
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_IN_0_OFFSET
	ADDS	R1, #4
	ADD		R0, R1, R0
	EORS	R1,R1,R1
	STR		R1, [R0]
	BX		LR
	ENDP

gpiote_is_event_irq_enabled	PROC
	EXPORT	gpiote_is_event_irq_enabled
	;R0: event mask
	LDR		R2, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_INTEN_OFFSET
	ADD		R2, R1, R2
	LDR		R1, [R2]
	TST		R1, R0
	BEQ		clear_result
	MOVS	R0, #1
	B		exit_prog
clear_result
	EORS	R0,R0,R0
exit_prog
	;return value in R0
	BX		LR
	ENDP

gpiote_is_event_pending	PROC
	EXPORT	gpiote_is_event_pending
	;R0: event index (4 for PORT event)
	LDR		R2, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_IN_0_OFFSET
	ADD		R2, R1, R2
	MOVS	R1, #4
	MULS	R1, R0, R1
	ADD		R2, R1
	LDR		R1, [R2]
	CMP		R1, #0
	BEQ		clear_result_pend
	MOVS	R0, #1
	B		exit_prog_pend
clear_result_pend
	EORS	R0,R0,R0
exit_prog_pend
	;return value in R0
	BX		LR
	ENDP
		
gpiote_is_port_event_pending	PROC
	EXPORT	gpiote_is_port_event_pending
	LDR		R0, =GPIOTE_BASE_ADDRESS
	LDR		R1, =GPIOTE_PORT_OFFSET
	ADD		R0, R1, R0
	LDR		R0, [R0]
	BX		LR
	ENDP

GPIOTE_BASE_ADDRESS			EQU		0x40006000
	
GPIOTE_OUT_0_OFFSET			EQU		0x000		;Task for writing to pin specified in CONFIG[0].PSEL. Action on pin is configured in CONFIG[0].POLARITY.
GPIOTE_IN_0_OFFSET			EQU		0x100		;Event generated from pin specified in CONFIG[0].PSEL
GPIOTE_PORT_OFFSET			EQU		0x17C		;Event generated from multiple input pins
GPIOTE_INTEN_OFFSET			EQU		0x300		;Enable or disable interrupt
GPIOTE_INTENSET_OFFSET		EQU		0x304		;Enable interrupt
GPIOTE_INTENCLR_OFFSET		EQU		0x308		;Disable interrupt
GPIOTE_CONFIG_OFFSET		EQU		0x510		;Configuration for OUT[n] task and IN[n] event
	
	END
