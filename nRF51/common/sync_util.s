	AREA fifo_utilities, CODE, READONLY

	INCLUDE ../common/constants.inc

;if critical section is being used, R9 should be zeroed at the beginning
;and not touched during execution. in any case using it directly
;by critical section must be taken into account

sync_crsect_init	PROC
	EXPORT	sync_crsect_init
	EORS	R0,R0,R0
	MOV		R9,	R0
	BX		LR
	ENDP
		
sync_crsect_enter	PROC
	EXPORT	sync_crsect_enter
	;R9: critical section counter
	CPSID i
	MOVS	R7,	#0x01
	ADD		R9, R7
	BX		LR
	ENDP

	ROUT
sync_crsect_exit	PROC
	EXPORT	sync_crsect_exit
	;R9: critical section counter
	MOV		R7,	R9
	SUBS	R7, #0x01
	MOV		R9,	R7
	CMP		R7, #0x00
	BNE		%0
	CPSIE	i
0	BX		LR
	ENDP

	END
