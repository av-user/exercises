	AREA power_utilities, CODE, READONLY

power_irq_enable PROC
	EXPORT	power_irq_enable
	LDR		R0, =POWER_BASE_ADDRESS
	LDR		R1, =POWER_INTENSET_OFFSET
	ADD		R0, R1, R0
	MOVS	R1, #0x01
	STR		R1, [R0]
	BX		LR
	ENDP
		
power_irq_disable PROC
	EXPORT	power_irq_disable
	LDR		R0, =POWER_BASE_ADDRESS
	LDR		R1, =POWER_INTENCLR_OFFSET
	ADD		R0, R1, R0
	MOVS	R1, #0x01
	STR		R1, [R0]
	BX		LR
	ENDP

power_POF_comparator_enable PROC
	EXPORT	power_POF_comparator_enable
	;do we really need this proc? is there any reason to enable it without setting the threshold?
	MOVS	R0, #0x01
	B		power_POF_comparator_set
	ENDP

power_POF_comparator_disable PROC
	EXPORT	power_POF_comparator_disable
	MOVS	R0, #0x00
	B		power_POF_comparator_set
	ENDP

power_POF_comparator_set PROC
	;R0: POF value (0 or 1)
	LDR		R1, =POWER_BASE_ADDRESS
	LDR		R2, =POWER_POFCON_OFFSET
	ADD		R1, R2, R1
	LDR		R2, [R1]
	ORRS	R2, R0
	STR		R2, [R1]
	BX		LR
	ENDP

power_POF_comparator_threshold_V21 PROC
	EXPORT	power_POF_comparator_threshold_V21
	MOVS	R0, #THRESHOLD_V21
	B		power_POF_comparator_threshold_set
	ENDP

power_POF_comparator_threshold_V23 PROC
	EXPORT	power_POF_comparator_threshold_V23
	MOVS	R0, #THRESHOLD_V23
	B		power_POF_comparator_threshold_set
	ENDP

power_POF_comparator_threshold_V25 PROC
	EXPORT	power_POF_comparator_threshold_V25
	MOVS	R0, #THRESHOLD_V25
	B		power_POF_comparator_threshold_set
	ENDP

power_POF_comparator_threshold_V27 PROC
	EXPORT	power_POF_comparator_threshold_V27
	MOVS	R0, #THRESHOLD_V27
	B		power_POF_comparator_threshold_set
	ENDP

power_POF_comparator_threshold_set PROC
	LDR		R1, =POWER_BASE_ADDRESS
	LDR		R2, =POWER_POFCON_OFFSET
	ADD		R1, R2, R1
	LDR		R2, [R1]
	LSLS	R0, #1
	ORRS	R2, R0
	STR		R2, [R1]
	BX		LR
	ENDP	

power_is_pof_event_pending	PROC
	EXPORT	power_is_pof_event_pending
	LDR		R0, =POWER_BASE_ADDRESS
	LDR		R1, =POWER_POFWARN_OFFSET
	ADD		R0, R1, R0
	LDR		R0, [R0]
	BX		LR
	ENDP

power_event_pof_clear	PROC
	EXPORT	power_event_pof_clear
	LDR		R0, =POWER_BASE_ADDRESS
	LDR		R1, =POWER_POFWARN_OFFSET
	ADD		R0, R1, R0
	EORS	R1,R1,R1
	STR		R1, [R0]
	BX		LR
	ENDP

THRESHOLD_V21				EQU		0		;Set threshold to 2.1 V
THRESHOLD_V23				EQU		1		;Set threshold to 2.3 V
THRESHOLD_V25				EQU		2		;Set threshold to 2.5 V
THRESHOLD_V27				EQU		3		;Set threshold to 2.7 V


POWER_BASE_ADDRESS			EQU		0x40000000

;Tasks
POWER_CONSTLAT_OFFSET		EQU		0x078 	;Enable constant latency mode
POWER_LOWPWR_OFFSET			EQU		0x07C 	;Enable low power mode (variable latency)
;Events
POWER_POFWARN_OFFSET		EQU		0x108 	;Power failure warning
;Registers
POWER_INTENSET_OFFSET		EQU		0x304 	;Enable interrupt
POWER_INTENCLR_OFFSET		EQU		0x308 	;Disable interrupt
POWER_RESETREAS_OFFSET		EQU		0x400 	;Reset reason
POWER_RAMSTATUS_OFFSET		EQU		0x428 	;RAM status register
POWER_SYSTEMOFF_OFFSET		EQU		0x500 	;System OFF register
POWER_POFCON_OFFSET			EQU		0x510 	;Power failure comparator configuration
POWER_GPREGRET_OFFSET		EQU		0x51C 	;General purpose retention register
POWER_RAMON_OFFSET			EQU		0x524 	;RAM on/off register (this register is retained)
POWER_RESET_OFFSET			EQU		0x544 	;Reset configuration register
POWER_RAMONB_OFFSET			EQU		0x554 	;RAM on/off register (this

	END
