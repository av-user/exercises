	AREA gpio_utilities, CODE, READONLY

	get macro.s

gpio_config_clear	PROC
	EXPORT	gpio_config_clear
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		out_cfg_clear
	BL		get_cfg_pin_address
	EORS	R1,R1,R1
	STR		R1, [R0]
out_cfg_clear
	POP		{PC}
	ENDP

gpio_cfg_out_disconnect	PROC
	EXPORT	gpio_cfg_out_disconnect
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		exit_cfg_out_dcon
	BL		get_cfg_pin_address
	MOVS	R1, #GPIO_CNF_DIR_OUT_DISCONNECT
	STR		R1, [R0]
exit_cfg_out_dcon
	POP		{PC}
	ENDP

gpio_config_output	PROC
	EXPORT	gpio_config_output
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		exit_cfg_output
	BL		get_cfg_pin_address
	MOVS	R1, #GPIO_CNF_DIR_MASK
	MOVS	R2, #GPIO_CNF_DIR_OUTPUT
    BITS_SET
exit_cfg_output
	POP		{PC}
	ENDP
	
	ROUT
gpio_config_input	PROC
	EXPORT	gpio_config_input
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		%0
	BL		get_cfg_pin_address
	MOVS	R1, #GPIO_CNF_DIR_MASK
	MOVS	R2, #GPIO_CNF_DIR_OUTPUT
    BITS_SET
0	POP		{PC}
	ENDP

gpio_input_buffer_connect	PROC
	EXPORT	gpio_input_buffer_connect
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		exit_inbuf_conn
	BL		get_cfg_pin_address
	MOVS	R1, #GPIO_CNF_INBUF_MASK
	MOVS	R2, #GPIO_CNF_INBUF_CONNECT
    BITS_SET
exit_inbuf_conn
	POP		{PC}
	ENDP

gpio_input_buffer_disconnect	PROC
	EXPORT	gpio_input_buffer_disconnect
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		exit_inbuf_dconn
	BL		get_cfg_pin_address
	MOVS	R1, #GPIO_CNF_INBUF_MASK
	MOVS	R2, #GPIO_CNF_INBUF_DISCONNECT
    BITS_SET
exit_inbuf_dconn
	POP		{PC}
	ENDP

	ROUT
gpio_config_pulldown	PROC
	EXPORT	gpio_config_pulldown
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		%0
	BL		get_cfg_pin_address
	MOVS	R1, #GPIO_CNF_PULL_MASK
	MOVS	R2, #GPIO_CNF_PULLDOWN
    BITS_SET
0	POP		{PC}
	ENDP

	ROUT
gpio_config_pullup	PROC
	EXPORT	gpio_config_pullup
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		%0
	BL		get_cfg_pin_address
	MOVS	R1, #GPIO_CNF_PULL_MASK
	MOVS	R2, #GPIO_CNF_PULLUP
    BITS_SET
0	POP		{PC}
	ENDP

	ROUT
gpio_config_nopull	PROC
	EXPORT	gpio_config_nopull
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		%0
	BL		get_cfg_pin_address
	MOVS	R1, #GPIO_CNF_PULL_MASK
	MOVS	R2, #GPIO_CNF_NOPULL
    BITS_SET
0	POP		{PC}
	ENDP

gpio_config_sense_high PROC
	EXPORT	gpio_config_sense_high
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		exit_config_sense_high
	BL		get_cfg_pin_address
	LDR		R1, =GPIO_CNF_SENSE_MASK
	LDR		R2, =GPIO_CNF_SENSE_HIGH
    BITS_SET
exit_config_sense_high
	POP		{PC}
	ENDP

get_cfg_pin_address PROC
	;R0: pin number
	LDR		R1, =GPIO_BASE_ADDRESS
	LDR 	R3, =GPIO_PIN_CNF_BASE_OFFSET
	ADD 	R3, R1, R3			; R0 points to PIN_CNF[0]
	MOVS	R2, #4				; 4 bytes (length)
	MULS	R0, R2, R0			; R0 <- offset of the pin in cfg array
	ADD 	R0, R3, R0			; R0 <- address of the pin in cfg array
	BX		LR
	ENDP

;GPIO_CNF_DRV_STD_0_STD_1	EQU		0
;GPIO_CNF_DRV_HIGH_0_STD_1	EQU		1
;GPIO_CNF_DRV_STD_0_HIGH_1	EQU		2
;GPIO_CNF_DRV_HIGH_0_HIGH_1	EQU		3
;GPIO_CNF_DRV_DISCONN_0_STD_1	EQU		4
;GPIO_CNF_DRV_DISCONN_0_HIGH_1	EQU		5
;GPIO_CNF_DRV_STD_0_DISCONN_1	EQU		6
;GPIO_CNF_DRV_HIGH_0_DISCONN_1	EQU		7

	ROUT
gpio_is_pin_high	PROC
	EXPORT	gpio_is_pin_high
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		%0
	MOVS	R2, #1
	LSLS	R2, R0
	LDR		R0, =GPIO_BASE_ADDRESS
	LDR		R1, =GPIO_IN_OFFSET
	LDR		R0, [R0,R1]
	ANDS	R0, R2, R0
	CMP		R0, #0x00
	BEQ		%0
	MOVS	R0, #0x01	;is high
0	POP		{PC}
	ENDP

gpio_pins_read	PROC
	EXPORT	gpio_pins_read
	PUSH	{LR}
	LDR		R1, =GPIO_BASE_ADDRESS
	LDR		R2, =GPIO_IN_OFFSET
	LDR		R0, [R1,R2]
	POP		{PC}
	ENDP

	ROUT
gpio_config_strength	PROC
	EXPORT	gpio_config_strength
	;R0: pin number
	;R1: drive strength
	PUSH	{LR,R4}
	CMP		R0, #31
	BGT		%0
	CMP		R1, #GPIO_DRIVE_STRENGTH_MAX
	BGT		%0
	MOV		R4, R1
	BL		get_cfg_pin_address
	LDR		R1, =GPIO_CNF_DRIVE_MASK
	MOV		R2, R4
	LSLS	R2, #GPIO_CNF_DRIVE_OFFSET
    BITS_SET
0	POP		{PC,R4}
	ENDP

gpio_drive_cnf_std_0_high_1	PROC
	EXPORT	gpio_drive_cnf_std_0_high_1
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		exit_drv_cfg_s0h1
	BL		get_cfg_pin_address
	LDR		R1, =GPIO_CNF_DRIVE_MASK
	LDR		R2, =GPIO_CNF_DRV_STD_0_HIGH_1
    BITS_SET
exit_drv_cfg_s0h1
	POP		{PC}
	ENDP

gpio_drive_cnf_high_0_std_1	PROC
	EXPORT	gpio_drive_cnf_high_0_std_1
	;R0: pin number
	PUSH	{LR}
	CMP		R0, #31
	BGT		exit_drv_cfg_h0s1
	BL		get_cfg_pin_address
	LDR		R1, =GPIO_CNF_DRIVE_MASK
	LDR		R2, =GPIO_CNF_DRV_HIGH_0_STD_1
    BITS_SET
exit_drv_cfg_h0s1
	POP		{PC}
	ENDP

gpio_toggle	PROC
	EXPORT	gpio_toggle
	;R0: pin number
	CMP		R0, #31
	BGT		out_toggle
	MOVS	R1, #1
	LSLS	R1, R0				;mask for the pin
	LDR 	R0, =GPIO_BASE_ADDRESS
	LDR		R2, =GPIO_OUTSET_OFFSET
	ADD		R0, R2, R0
	LDR		R3, [R0]
	TST		R3, R1				;test under mask
	BEQ		set_pin
	;clear pin
	STR		R1, [R0, #4] ;OUTCLR
	B		out_toggle
set_pin	
	STR		R1, [R0]
out_toggle
	BX      LR
	ENDP
		
gpio_set_high	PROC
	EXPORT	gpio_set_high
	PUSH	{LR}
	;R0: pin number
	CMP		R0, #31
	BGT		out_set_gpio_high
	MOVS	R1, #1
	LSLS	R1, R0				;mask for the pin
	LDR		R0, =GPIO_BASE_ADDRESS
	LDR		R2, =GPIO_OUTSET_OFFSET
	ADD		R0, R2, R0
	STR		R1, [R0]
out_set_gpio_high
	POP		{PC}
    ENDP; End of SystemInit routine
   
gpio_set_low	PROC
	EXPORT	gpio_set_low
	PUSH	{LR}
	;R0: pin number
	CMP		R0, #31
	BGT		out_set_gpio_low
	MOVS	R1, #1
	LSLS	R1, R0				;mask for the pin
	LDR		R0, =GPIO_BASE_ADDRESS
	LDR		R2, =GPIO_OUTCLR_OFFSET
	ADD		R0, R2, R0
	STR		R1, [R0]
out_set_gpio_low
	POP		{PC}
    ENDP; End of SystemInit routine

	EXPORT	GPIO_DRIVE_STRENGTH_H0S1	[WEAK]
	EXPORT	GPIO_DRIVE_STRENGTH_S0H1	[WEAK]
	EXPORT	GPIO_DRIVE_STRENGTH_H0H1	[WEAK]
	EXPORT	GPIO_DRIVE_STRENGTH_D0S1	[WEAK]
	EXPORT	GPIO_DRIVE_STRENGTH_D0H1	[WEAK]
	EXPORT	GPIO_DRIVE_STRENGTH_S0D1	[WEAK]
	EXPORT	GPIO_DRIVE_STRENGTH_H0D1	[WEAK]

GPIO_DRIVE_STRENGTH_H0S1	EQU		1 ;High drive '0', standard '1'
GPIO_DRIVE_STRENGTH_S0H1	EQU		2 ;Standard '0', high drive '1'
GPIO_DRIVE_STRENGTH_H0H1	EQU		3 ;High drive '0', high 'drive '1''
GPIO_DRIVE_STRENGTH_D0S1	EQU		4 ;Disconnect '0' standard '1'
GPIO_DRIVE_STRENGTH_D0H1	EQU		5 ;Disconnect '0', high drive '1'
GPIO_DRIVE_STRENGTH_S0D1	EQU		6 ;Standard '0'. disconnect '1'
GPIO_DRIVE_STRENGTH_H0D1	EQU		7 ;High drive '0', disconnect '1'
GPIO_DRIVE_STRENGTH_MAX		EQU		GPIO_DRIVE_STRENGTH_H0D1

GPIO_BASE_ADDRESS			EQU		0x50000000
GPIO_OUT_OFFSET				EQU		0x504		; Write GPIO port	
GPIO_OUTSET_OFFSET			EQU		0x508		; Set individual bits in GPIO port
GPIO_OUTCLR_OFFSET			EQU		0x50C		; Clear individual bits in GPIO port
GPIO_IN_OFFSET				EQU		0x510		; Read GPIO port
GPIO_DIR_OFFSET				EQU		0x514		; Direction of GPIO pins
GPIO_DIRSET_OFFSET			EQU		0x518		; DIR set register
GPIO_DIRCLR_OFFSET			EQU		0x51C		; DIR clear register
GPIO_PIN_CNF_BASE_OFFSET	EQU		0x700		; Configuration of GPIO pins

GPIO_CNF_DIR_MASK			EQU		0x01
GPIO_CNF_DIR_INPUT			EQU		0x00
GPIO_CNF_DIR_OUTPUT			EQU		0x01
GPIO_CNF_INBUF_MASK			EQU		0x02
GPIO_CNF_INBUF_CONNECT		EQU		0x00
GPIO_CNF_INBUF_DISCONNECT	EQU		0x02
GPIO_CNF_PULL_MASK			EQU		0x0C
GPIO_CNF_NOPULL				EQU		0x00
GPIO_CNF_PULLDOWN			EQU		0x04
GPIO_CNF_PULLUP				EQU		0x0C
GPIO_CNF_DIR_OUT_DISCONNECT	EQU		0x03
	
GPIO_CNF_SENSE_MASK			EQU		0x00030000
GPIO_CNF_SENSE_HIGH			EQU		0x00020000
	
GPIO_CNF_DRIVE_MASK			EQU		0x0700
GPIO_CNF_DRIVE_OFFSET		EQU		0x08
GPIO_CNF_DRV_STD_0_STD_1	EQU		0x0000
GPIO_CNF_DRV_HIGH_0_STD_1	EQU		0x0100
GPIO_CNF_DRV_STD_0_HIGH_1	EQU		0x0200
GPIO_CNF_DRV_HIGH_0_HIGH_1	EQU		0x0300
GPIO_CNF_DRV_DISCONN_0_STD_1	EQU		0x0400
GPIO_CNF_DRV_DISCONN_0_HIGH_1	EQU		0x0500
GPIO_CNF_DRV_STD_0_DISCONN_1	EQU		0x0600
GPIO_CNF_DRV_HIGH_0_DISCONN_1	EQU		0x0700
	
	END
