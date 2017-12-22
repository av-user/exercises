	AREA timer_utilities, CODE, READONLY

timer_prescaler_set	PROC
	EXPORT	timer_prescaler_set
	PUSH	{LR}
	;R0 contains timer base address
	;R1 contains prescaler
	LDR		R2, =TIMER_PRESCALER_OFFSET
	ADD		R0, R2, R0
	STR		R1, [R0]
	POP		{PC}
	ENDP

timer_start	PROC
	EXPORT	timer_start
	PUSH	{LR}
	;R0 contains timer base address
	MOVS	R1, #1
	STR		R1, [R0]
	POP		{PC}
	ENDP

timer_stop	PROC
	EXPORT	timer_stop
	PUSH	{LR}
	;R0 contains timer base address
	MOVS	R1, #1
	STR		R1, [R0, #4]
	POP		{PC}
	ENDP

timer_increment	PROC	;counter mode only
	EXPORT	timer_increment
	PUSH	{LR}
	;R0 contains timer base address
	MOVS	R1, #1
	STR		R1, [R0, #8]
	POP		{PC}
	ENDP

timer_clear	PROC
	EXPORT	timer_clear
	PUSH	{LR}
	;R0 contains timer base address
	MOVS	R1, #1
	STR		R1, [R0, #0x0C]
	POP		{PC}
	ENDP

timer_shutdown	PROC
	EXPORT	timer_shutdown
	PUSH	{LR}
	;R0 contains timer base address
	MOVS	R1, #1
	STR		R1, [R0, #0x10]
	POP		{PC}
	ENDP

timer_select_mode_timer	PROC
	EXPORT	timer_select_mode_timer
	PUSH	{LR}
	;R0 contains timer base address
	LDR		R1, =TIMER_MODE_OFFSET
	ADD		R0, R1, R0
	MOVS	R1, #TIMER_MODE_TIMER
	STR		R1, [R0]
	POP		{PC}
	ENDP

timer_select_mode_counter	PROC
	EXPORT	timer_select_mode_counter
	PUSH	{LR}
	;R0 contains timer base address
	LDR		R1, =TIMER_MODE_OFFSET
	ADD		R0, R1, R0
	MOVS	R1, #TIMER_MODE_COUNTER
	STR		R1, [R0]
	POP		{PC}
	ENDP

timer_select_bitmode_08	PROC
	EXPORT	timer_select_bitmode_08
	PUSH	{LR}
	;R0 contains timer base address
	LDR		R1, =TIMER_BITMODE_OFFSET
	ADD		R0, R1, R0
	MOVS	R1, #TIMER_BITMODE_08
	STR		R1, [R0]
	POP		{PC}
	ENDP
timer_select_bitmode_16	PROC
	EXPORT	timer_select_bitmode_16
	PUSH	{LR}
	;R0 contains timer base address
	LDR		R1, =TIMER_BITMODE_OFFSET
	ADD		R0, R1, R0
	MOVS	R1, #TIMER_BITMODE_16
	STR		R1, [R0]
	POP		{PC}
	ENDP
timer_select_bitmode_24	PROC
	EXPORT	timer_select_bitmode_24
	PUSH	{LR}
	;R0 contains timer base address
	LDR		R1, =TIMER_BITMODE_OFFSET
	ADD		R0, R1, R0
	MOVS	R1, #TIMER_BITMODE_24
	STR		R1, [R0]
	POP		{PC}
	ENDP
timer_select_bitmode_32	PROC
	EXPORT	timer_select_bitmode_32
	PUSH	{LR}
	;R0 contains timer base address
	LDR		R1, =TIMER_BITMODE_OFFSET
	ADD		R0, R1, R0
	MOVS	R1, #TIMER_BITMODE_32
	STR		R1, [R0]
	POP		{PC}
	ENDP

timer_short_clear_all	PROC
	EXPORT	timer_short_clear_all
	PUSH	{LR}
	;R0 contains timer base address
	LDR		R1, =TIMER_SHORTS_OFFSET
	ADD		R0, R1, R0
	EORS	R1, R1, R1
	STR		R1, [R0]
	POP		{PC}
	ENDP

timer_int_short_clear_0 PROC
	EXPORT	timer_int_short_clear_0
	PUSH	{LR}
	;R0: timer base address
	LDR		R1, =TIMER_SHORTS_OFFSET
	ADD		R0, R1
	LDR		R1, [R0]
	MOVS	R2, #1
	ORRS	R1, R1, R2
	STR		R1, [R0]
	POP		{PC}
	ENDP
		
timer_int_short_stop_0 PROC
	EXPORT	timer_int_short_stop_0
	PUSH	{LR}
	;R0: timer base address
	LDR		R1, =TIMER_SHORTS_OFFSET
	ADD		R0, R1
	LDR		R1, [R0]
	MOVS	R2, #1
	LSLS	R2, #8
	ORRS	R1, R1, R2
	STR		R1, [R0]
	POP		{PC}
	ENDP

timer_int_compare_0_enable PROC
	EXPORT	timer_int_compare_0_enable
	PUSH	{LR}
	;R0: timer base address
	MOVS	R1, #1
	LSLS	R1, #16
	BL	timer_int_enable
	POP		{PC}
	ENDP
		
timer_int_enable PROC
	PUSH	{LR}
	;R0: timer base address
	;R1: mask
	LDR		R2, =TIMER_INTENSET_OFFSET	
	ADD		R0, R2, R0
	STR		R1, [R0]
	POP		{PC}
	ENDP

timer_compare0_event_clear	PROC
	EXPORT	timer_compare0_event_clear
	PUSH	{LR}
	;R0: timer base address
	LDR		R1, =TIMER_COMPARE_0_OFFSET	
	ADD		R0, R1, R0
	EORS	R1,R1,R1
	STR		R1, [R0]
	POP		{PC}
	ENDP

timer_cc0_set	PROC
	EXPORT	timer_cc0_set
	PUSH	{LR}
	;R0: timer base address
	;R1: value
	LDR		R2, =TIMER_CC_0_OFFSET	
	ADD		R0, R2, R0
	STR		R1, [R0]
	POP		{PC}
	ENDP
	
	EXPORT	TIMER0_BASE_ADDRESS		[WEAK]
TIMER0_BASE_ADDRESS			EQU		0x40008000
	EXPORT	TIMER1_BASE_ADDRESS		[WEAK]
TIMER1_BASE_ADDRESS			EQU		0x40009000
	EXPORT	TIMER2_BASE_ADDRESS		[WEAK]
TIMER2_BASE_ADDRESS			EQU		0x4000A000
	
	EXPORT	TIMER_START_OFFSET		[WEAK]
TIMER_START_OFFSET			EQU		0x000 	;Start Timer
	EXPORT	TIMER_STOP_OFFSET		[WEAK]
TIMER_STOP_OFFSET			EQU		0x004 	;Stop Timer
	EXPORT	TIMER_COUNT_OFFSET		[WEAK]
TIMER_COUNT_OFFSET			EQU		0x008 	;Increment Timer (Counter mode only)
	EXPORT	TIMER_CLEAR_OFFSET		[WEAK]
TIMER_CLEAR_OFFSET			EQU		0x00C 	;Clear time
	EXPORT	TIMER_SHUTDOWN_OFFSET	[WEAK]
TIMER_SHUTDOWN_OFFSET		EQU		0x010 	;Shut down timer
	EXPORT	TIMER_CAPTURE_0_OFFSET	[WEAK]
TIMER_CAPTURE_0_OFFSET		EQU		0x040 	;Capture Timer value to CC[0] register
	EXPORT	TIMER_COMPARE_0_OFFSET	[WEAK]
TIMER_COMPARE_0_OFFSET		EQU		0x140 	;Compare event on CC[0] match	
	EXPORT	TIMER_SHORTS_OFFSET		[WEAK]
TIMER_SHORTS_OFFSET			EQU		0x200	;Shortcut register
	EXPORT	TIMER_INTENSET_OFFSET	[WEAK]
TIMER_INTENSET_OFFSET		EQU		0x304	;Enable interrupt
	EXPORT	TIMER_INTENCLR_OFFSET	[WEAK]
TIMER_INTENCLR_OFFSET		EQU		0x308	;Disable interrupt
	EXPORT	TIMER_MODE_OFFSET		[WEAK]
TIMER_MODE_OFFSET			EQU		0x504	;Timer mode selection
	EXPORT	TIMER_BITMODE_OFFSET	[WEAK]
TIMER_BITMODE_OFFSET		EQU		0x508	;Configure the number of bits used by the TIMER
	EXPORT	TIMER_PRESCALER_OFFSET	[WEAK]
TIMER_PRESCALER_OFFSET		EQU		0x510	;Timer prescaler register
	EXPORT	TIMER_CC_0_OFFSET		[WEAK]
TIMER_CC_0_OFFSET			EQU		0x540	;Capture/Compare register 0

TIMER_MODE_TIMER			EQU		0x00000000	;Select Timer mode
TIMER_MODE_COUNTER			EQU		0x00000001	;Select Counter mode
	
TIMER_BITMODE_16			EQU		0x00000000	;16 bit timer bit width
TIMER_BITMODE_08			EQU		0x00000001	;8 bit timer bit width
TIMER_BITMODE_24			EQU		0x00000002	;24 bit timer bit width
TIMER_BITMODE_32			EQU		0x00000003	;32 bit timer bit width

	END
