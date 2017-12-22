	AREA rtc_utilities, CODE, READONLY

	;MACRO
    ;rtc0_cc_set    $value
	;LDR		R0, =RTC0_BASE_ADDRESS
	;LDR		R1, =RTC_CC0_REG_OFFSET
	;MOVS	R2, #$value
	;ADD		R0, R1, R0
	;STR		R2, [R0]
	;MEND

rtc_start	PROC
	EXPORT	rtc_start
	;R0: rtc base address
	MOVS	R1, #0x01
	STR		R1, [R0]
	BX		LR
	ENDP

rtc_stop	PROC
	EXPORT	rtc_stop
	;R0: rtc base address
	LDR		R1, =RTC_STOP_OFFSET
	ADDS	R0, R1
	MOVS	R1, #0x01
	STR		R1, [R0]
	BX		LR
	ENDP

rtc_clear	PROC
	EXPORT	rtc_clear
	;R0: rtc base address
	LDR		R1, =RTC_CLEAR_OFFSET
	ADDS	R0, R1
	MOVS	R1, #0x01
	STR		R1, [R0]
	BX		LR
	ENDP

rtc_prescaler_set	PROC
	EXPORT	rtc_prescaler_set
	PUSH	{LR}
	;R0 contains rtc base address
	;R1 contains prescaler
	LDR		R2, =RTC_PRESCALER_OFFSET
	ADD		R0, R2, R0
	STR		R1, [R0]			;set rtc prescaler
	POP		{PC}
	ENDP

rtc_counter_read	PROC
	EXPORT	rtc_counter_read
	PUSH	{R1,LR}
	;R0: rtc base address
	LDR		R1, =RTC_COUNTER_OFFSET
	ADD		R1, R0, R1
	LDR		R0, [R1]
	POP		{R1,PC}
	ENDP

;rtc_tick_enable	PROC
	;EXPORT	rtc_tick_enable
	;PUSH	{LR}
	;;R0: rtc base address
	;LDR		R1, =RTC_TICK_OFFSET
	;ADD		R1, R0, R1
	;EORS	R2, R2, R2		;zero R2
	;STR		R2, [R1]		;clear tick event
	;MOVS	R2, #1			;bit0 mask (Write '1' to Enable interrupt on TICK event)
	;LDR		R1, =RTC_EVTENSET_OFFSET
	;ADD		R1, R0, R1
	;STR		R2, [R1]		;enable tick event
	;LDR		R1, =RTC_INTENSET_OFFSET
	;ADD		R1, R0, R1
	;STR		R2, [R1]		;enable rtc irq
	;POP		{PC}
	;ENDP

rtc_event_disable PROC
	EXPORT	rtc_event_disable
	PUSH	{LR}
	;R0: rtc base address
	;R1: mask
	LDR		R2, =RTC_EVTENCLR_OFFSET	
	ADD		R0, R2, R0
	STR		R1, [R0]
	POP		{PC}
	ENDP

rtc_events_enable PROC
	EXPORT	rtc_events_enable
	PUSH	{LR}
	;R0: rtc base address
	;R1: mask
	LDR		R2, =RTC_EVTENSET_OFFSET	
	ADD		R0, R2, R0
	STR		R1, [R0]
	POP		{PC}
	ENDP
		
rtc_int_disable PROC
	EXPORT	rtc_int_disable
	PUSH	{LR}
	;R0: rtc base address
	;R1: mask
	LDR		R2, =RTC_INTENCLR_OFFSET	
	ADD		R0, R2, R0
	STR		R1, [R0]
	POP		{PC}
	ENDP
		
rtc_int_enable PROC
	EXPORT	rtc_int_enable
	PUSH	{LR}
	;R0: rtc base address
	;R1: mask
	LDR		R2, =RTC_INTENSET_OFFSET	
	ADD		R0, R2, R0
	STR		R1, [R0]
	POP		{PC}
	ENDP

rtc_cc0_set	PROC
	EXPORT	rtc_cc0_set
	;R0: rtc base address
	;R1: cc
	LDR		R2, =RTC_CC0_OFFSET
	ADD		R0, R2, R0
	STR		R1, [R0]
	BX		LR
	ENDP

rtc_cc0_event_clear	PROC
	EXPORT	rtc_cc0_event_clear
	PUSH	{LR}
	;R0: rtc base address
	LDR		R1, =RTC_COMPARE0_OFFSET	
	ADD		R0, R1, R0
	EORS	R1, R1, R1		;zero R1
	STR		R1, [R0]
	POP		{PC}
	ENDP

rtc_compare0_event_enable PROC
	EXPORT	rtc_compare0_event_enable
	;R0: base address
	MOVS	R1, #0x10
	B		rtc_event_enable
    ENDP

rtc_is_compare0_event_irq_enabled	PROC
	EXPORT	rtc_is_compare0_event_irq_enabled
	PUSH	{LR}
	;is interrupt on COMPARE[0] event enabled
	LDR		R1, =RTC_INTENSET_OFFSET	;enable interrupt
	ADD		R0, R1
	LDR		R1, [R0]
	MOVS	R2, #1
	LSLS	R2, #16	;mask to Enable interrupt on COMPARE[0] event.
	EORS	R0, R0, R0	;return no
	TST		R1, R2
	BEQ		label0
	MOVS	R0, #1		;return enabled
label0
	POP		{PC}
    ENDP

rtc_is_compare0_pending	PROC
	EXPORT	rtc_is_compare0_pending
	PUSH	{LR}
	;is interrupt on COMPARE[0] event enabled
	LDR		R1, =RTC_COMPARE0_OFFSET
	ADD		R0, R1
	LDR		R1, [R0]
	EORS	R0, R0, R0	;return no
	CMP		R1, R0
	BEQ		label1
	MOVS	R0, #1		;return pending
label1
	POP		{PC}
    ENDP

rtc_compare0_irq_enable PROC
	EXPORT	rtc_compare0_irq_enable
	;R0: base address
	MOVS	R1, #0x10
	B		rtc_irq_enable
    ENDP

rtc_cc1_set	PROC
	EXPORT	rtc_cc1_set
	;R0: rtc base address
	;R1: cc
	LDR		R2, =RTC_CC1_OFFSET
	ADD		R0, R2, R0
	STR		R1, [R0]
	BX		LR
	ENDP

rtc_cc1_event_clear	PROC
	EXPORT	rtc_cc1_event_clear
	PUSH	{LR}
	;R0: rtc base address
	LDR		R1, =RTC_COMPARE1_OFFSET	
	ADD		R0, R1, R0
	EORS	R1, R1, R1		;zero R1
	STR		R1, [R0]
	POP		{PC}
	ENDP

rtc_compare1_event_enable PROC
	EXPORT	rtc_compare1_event_enable
	;R0: base address
	MOVS	R1, #0x11
	B		rtc_event_enable
    ENDP

	ROUT
rtc_is_compare1_event_irq_enabled	PROC
	EXPORT	rtc_is_compare1_event_irq_enabled
	PUSH	{LR}
	;is interrupt on COMPARE[1] event enabled
	LDR		R1, =RTC_INTENSET_OFFSET	;enable interrupt
	ADD		R0, R1
	LDR		R1, [R0]
	MOVS	R2, #1
	LSLS	R2, #17	;mask to Enable interrupt on COMPARE[1] event.
	EORS	R0, R0, R0	;return no
	TST		R1, R2
	BEQ		%1
	MOVS	R0, #1		;return enabled
1	POP		{PC}
    ENDP

	ROUT
rtc_is_compare1_pending	PROC
	EXPORT	rtc_is_compare1_pending
	PUSH	{LR}
	;is interrupt on COMPARE[1] event enabled
	LDR		R1, =RTC_COMPARE1_OFFSET
	ADD		R0, R1
	LDR		R1, [R0]
	EORS	R0, R0, R0	;return no
	CMP		R1, R0
	BEQ		%1
	MOVS	R0, #1		;return pendding
1	POP		{PC}
    ENDP

rtc_compare1_irq_enable PROC
	EXPORT	rtc_compare1_irq_enable
	;R0: base address
	MOVS	R1, #0x11
	B		rtc_irq_enable
    ENDP

rtc_counter_start	PROC
	EXPORT	rtc_counter_start
	PUSH	{LR}
	;R0: rtc base address
	MOVS	R1, #1
	STR		R1, [R0]
	POP		{PC}
	ENDP
		
rtc_counter_stop	PROC
	EXPORT	rtc_counter_stop
	PUSH	{LR}
	;R0: rtc base address
	MOVS	R1, #1
	STR		R1, [R0, #4]
	POP		{PC}
	ENDP
		
rtc_counter_clear	PROC
	EXPORT	rtc_counter_clear
	PUSH	{LR}
	;R0: rtc base address
	MOVS	R1, #1
	STR		R1, [R0, #8]
	POP		{PC}
	ENDP

rtc_irq_disable_all PROC
	EXPORT	rtc_irq_disable_all
	;R0: base address
	PUSH	{LR}
	LDR		R1, =RTC_INTEN_OFFSET
	ADD		R0, R1
	EORS	R1, R1, R1
	STR		R1, [R0]
	POP		{PC}
    ENDP
	
rtc_tick_irq_enable PROC
	EXPORT	rtc_tick_irq_enable
	;R0: base address
	MOVS	R1, #0x01
	B		rtc_irq_enable
    ENDP

rtc_irq_enable PROC
	;R0: base address
	;R1: bits to shift mask
	LDR		R2, =RTC_INTENSET_OFFSET
	ADD		R0, R2
	MOVS	R2, #0x01
	LSLS	R2, R1
	STR		R2, [R0]
	BX		LR
    ENDP

rtc_tick_event_clear	PROC
	EXPORT	rtc_tick_event_clear
	;R0: base address
	PUSH	{LR}
	LDR		R1, =RTC_TICK_OFFSET
	ADD		R0, R1
	EORS	R1, R1, R1
	STR		R1, [R0]
	POP		{PC}
    ENDP

rtc_compare0_event_clear	PROC
	EXPORT	rtc_compare0_event_clear
	;R0: base address
	PUSH	{LR}
	LDR		R1, =RTC_COMPARE0_OFFSET
	ADD		R0, R1
	EORS	R1, R1, R1
	STR		R1, [R0]
	POP		{PC}
    ENDP

rtc_event_disable_all PROC
	EXPORT	rtc_event_disable_all
	;R0: base address
	PUSH	{LR}
	LDR		R1, =RTC_EVTEN_OFFSET
	ADD		R0, R1
	EORS	R1, R1, R1
	STR		R1, [R0]
	POP		{PC}
    ENDP
	
rtc_tick_event_enable PROC
	EXPORT	rtc_tick_event_enable
	;R0: base address
	MOVS	R1, #0x01
	B		rtc_event_enable
    ENDP

rtc_event_enable PROC
	;R0: base address
	;R1: bits to shift mask
	LDR		R2, =RTC_EVTENSET_OFFSET
	ADD		R0, R2
	MOVS	R2, #0x01
	LSLS	R2, R1
	STR		R2, [R0]
	BX		LR
    ENDP

rtc_is_tick_event_irq_enabled	PROC
	EXPORT	rtc_is_tick_event_irq_enabled
	PUSH	{LR}
	;is interrupt on COMPARE[0] event enabled
	LDR		R0, =RTC0_BASE_ADDRESS
	LDR		R1, =RTC_INTENSET_OFFSET	;enable interrupt
	ADD		R0, R1
	LDR		R1, [R0]
	MOVS	R2, #1 ;mask to Enable interrupt on tick event.
	EORS	R0, R0, R0	;return no
	TST		R1, R2
	BEQ		label2
	MOVS	R0, #1		;return enabled
label2
	POP		{PC}
    ENDP

rtc_is_tick_pending	PROC
	EXPORT	rtc_is_tick_pending
	PUSH	{LR}
	;is interrupt on COMPARE[0] event enabled
	LDR		R0, =RTC0_BASE_ADDRESS
	LDR		R1, =RTC_TICK_OFFSET
	ADD		R0, R1
	LDR		R1, [R0]
	EORS	R0, R0, R0	;return no
	CMP		R1, R0
	BEQ		label3
	MOVS	R0, #1		;return pendding
label3
	POP		{PC}
    ENDP

	EXTERN	drv_common_irq_enable

	EXPORT	RTC0_BASE_ADDRESS			[WEAK]
	EXPORT	RTC1_BASE_ADDRESS			[WEAK]

RTC0_BASE_ADDRESS		EQU		0x4000B000
RTC1_BASE_ADDRESS		EQU		0x40011000
RTC2_BASE_ADDRESS		EQU		0x40024000
	
;Tasks
RTC_START_OFFSET		EQU		0x000 ;Start RTC COUNTER
RTC_STOP_OFFSET			EQU		0x004 ;Stop RTC COUNTER
RTC_CLEAR_OFFSET		EQU		0x008 ;Clear RTC COUNTER
RTC_TRIGOVRFLW_OFFSET	EQU		0x00C ;Set COUNTER to 0xFFFFF0
;Events
RTC_TICK_OFFSET			EQU		0x100 ;Event on COUNTER increment
RTC_OVRFLW_OFFSET		EQU		0x104 ;Event on COUNTER overflow
RTC_COMPARE0_OFFSET		EQU		0x140 ;Compare event on CC[0] match
RTC_COMPARE1_OFFSET		EQU		0x144 ;Compare event on CC[1] match
RTC_COMPARE2_OFFSET		EQU		0x148 ;Compare event on CC[2] match
RTC_COMPARE3_OFFSET		EQU		0x14C ;Compare event on CC[3] match
;Registers
RTC_INTEN_OFFSET		EQU		0x300 ;Enable or disable interrupt
RTC_INTENSET_OFFSET		EQU		0x304 ;Enable interrupt
RTC_INTENCLR_OFFSET		EQU		0x308 ;Disable interrupt
RTC_EVTEN_OFFSET		EQU		0x340 ;Enable or disable event routing
RTC_EVTENSET_OFFSET		EQU		0x344 ;Enable event routing
RTC_EVTENCLR_OFFSET		EQU		0x348 ;Disable event routing
RTC_COUNTER_OFFSET		EQU		0x504 ;Current COUNTER value
RTC_PRESCALER_OFFSET	EQU		0x508 ;12 bit prescaler for COUNTER frequency (32768/(PRESCALER+1)).Must be written when RTC is stopped
RTC_CC0_OFFSET			EQU		0x540 ;Compare register 0
RTC_CC1_OFFSET			EQU		0x544 ;Compare register 1
RTC_CC2_OFFSET			EQU		0x548 ;Compare register 2
RTC_CC3_OFFSET			EQU		0x54C ;Compare register 3
	
	END
