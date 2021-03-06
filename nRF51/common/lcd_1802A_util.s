	AREA lcd1602A_utilities, CODE, READONLY

	ROUT
lcd1602A_init	PROC
	EXPORT	lcd1602A_init
	;R0: LCD1602A_PINS address
	;R1: LCD1602A_CFG address
	PUSH	{LR}
	PUSH	{R0,R1}
	BL		lcd1602A_gpio_congig_output
	LDR		R0, =60000
	BL		nrf_delay_mcs
	POP		{R0,R1}
	PUSH	{R0,R1}
	BL		lcd1602A_function_set
	LDR		R0, =6000
	BL		nrf_delay_mcs
	POP		{R0,R1}
	PUSH	{R0,R1}
	BL		lcd1602A_function_set
	LDR		R0, =200
	BL		nrf_delay_mcs
	POP		{R0,R1}
	PUSH	{R0,R1}
	BL		lcd1602A_function_set
	POP		{R0,R1}
	PUSH	{R0,R1}
	BL		lcd1602A_function_set
	POP		{R0,R1}
	PUSH	{R0,R1}
	BL		lcd1602A_on_off_set
	POP		{R0,R1}
	PUSH	{R0,R1}
	BL		lcd1602A_display_clear
	POP		{R0,R1}
	BL		lcd1602A_entry_mode_set
	POP		{PC}
    ENDP

	ROUT
lcd1602A_gpio_congig_output	PROC
	;R0: LCD1602A_PINS address
	PUSH	{LR}
	MOV		R5, R0
	MOVS	R7, #LCD1602A_SEL_GPIO_NUMBER_OFFSET
0	LDRB	R0, [R5,R7]
	BL		gpio_config_output
2	ADDS	R7, #0x01
	CMP		R7, #LCD1602A_BL_GPIO_NUMBER_OFFSET
	BLS		%0
	POP		{PC}
    ENDP

lcd1602A_on_off_set	PROC
	;R0: LCD1602A_PINS address
	;R1: LCD1602A_CFG address
	PUSH	{LR}
	MOVS	R2, #0x01
	LSLS	R2, #0x03	;cmd
	LDRB	R3, [R1,#LCD1602A_MODE_DSPL_DISPL_OFFSET]
	LSLS	R3, #0x02
	EORS	R2, R3
	LDRB	R3, [R1,#LCD1602A_MODE_DSPL_CURS_OFFSET]
	LSLS	R3, #0x01
	EORS	R2, R3
	LDRB	R3, [R1,#LCD1602A_MODE_DSPL_CBLINK_OFFSET]
	EORS	R2, R3
	MOV		R1, R2
	BL		lcd1602A_cmd_write
	POP		{PC}
    ENDP

lcd1602A_entry_mode_set	PROC
	;R0: LCD1602A_PINS address
	;R1: LCD1602A_CFG address
	PUSH	{LR}
	MOVS	R2, #0x01
	LSLS	R2, #0x02	;cmd
	LDRB	R3, [R1, #LCD1602A_MODE_ENTRY_DIR_OFFSET]
	LSLS	R3, #0x01
	EORS	R2, R3
	LDRB	R3, [R1,#LCD1602A_MODE_ENTRY_SHIFT_OFFSET]
	EORS	R2, R3
	MOV		R1, R2
	BL		lcd1602A_cmd_write
	POP		{PC}
    ENDP

lcd1602A_function_set	PROC
	;R0: LCD1602A_PINS address
	;R1: LCD1602A_CFG address
	PUSH	{LR}
	MOVS	R2, #0x01
	LSLS	R2, #0x05	;cmd
	LDRB	R3, [R1, #LCD1602A_MODE_x_PIN_BUS_OFFSET]
	LSLS	R3, #0x04	;pin bus mode
	EORS	R2, R3
	LDRB	R3, [R1,#LCD1602A_MODE_x_LINES_OFFSET]
	LSLS	R3, #0x03	;one or two lines
	EORS	R2, R3
	LDRB	R3, [R1,#LCD1602A_MODE_XxXX_DOTS_OFFSET]
	LSLS	R3, #0x02	;font format dots
	EORS	R2, R3
	MOV		R1, R2
	BL		lcd1602A_cmd_write
	LDR		R0, =5000
	BL		nrf_delay_mcs
	POP		{PC}
    ENDP

lcd1602A_cmd_write	PROC
	;R0: LCD1602A_PINS address
	;R1: command byte
	PUSH	{LR}
	MOV		R5, R0
	MOV		R6, R1
	LDRB	R0, [R0,#LCD1602A_SEL_GPIO_NUMBER_OFFSET]
	BL		gpio_set_low
	LDRB	R0, [R5,#LCD1602A_RW_GPIO_NUMBER_OFFSET]
	BL		gpio_set_low
	MOV		R0, R5
	MOV		R1, R6
	BL		lcd1602A_byte_write
	POP		{PC}
    ENDP

lcd1602A_data_write	PROC
	;R0: LCD1602A_PINS address
	;R1: data byte
	PUSH	{LR}
	PUSH	{R1}
	PUSH	{R0}
	LDRB	R0, [R0,#LCD1602A_SEL_GPIO_NUMBER_OFFSET]
	BL		gpio_set_high
	POP		{R0}
	PUSH	{R0}
	LDRB	R0, [R0,#LCD1602A_RW_GPIO_NUMBER_OFFSET]
	BL		gpio_set_low
	POP		{R0}
	POP		{R1}
	BL		lcd1602A_byte_write
	POP		{PC}
    ENDP

	ROUT
lcd1602A_byte_write	PROC
	;R0: LCD1602A_PINS address
	;R1: data byte
	PUSH	{LR}
	MOV		R5, R0
	MOV		R6, R1
	;LDRB	R0, [R5,#LCD1602A_ENAB_GPIO_NUMBER_OFFSET]
	;BL		gpio_set_low
	LDR		R0, =DELAY_MCS
	BL		nrf_delay_mcs
	MOVS	R7, #LCD1602A_D0_GPIO_NUMBER_OFFSET
0	LDRB	R0, [R5,R7]
	LSRS	R6, #0x01
	BCS		%1
	BL		gpio_set_low
	B		%2
1	BL		gpio_set_high
2	ADDS	R7, #0x01
	CMP		R7, #LCD1602A_D7_GPIO_NUMBER_OFFSET
	BLS		%0
	LDR		R0, =DELAY_MCS
	BL		nrf_delay_mcs
	
 ;digitalWrite(_enable_pin, LOW);
  ;delayMicroseconds(1);    
  ;digitalWrite(_enable_pin, HIGH);
  ;delayMicroseconds(1);    // enable pulse must be >450ns
  ;digitalWrite(_enable_pin, LOW);
;delayMicroseconds(100); // commands need > 37us to settle
	LDRB	R0, [R5,#LCD1602A_ENAB_GPIO_NUMBER_OFFSET]
	BL		gpio_set_low
	MOVS	R0, #0x02
	BL		nrf_delay_mcs
	LDRB	R0, [R5,#LCD1602A_ENAB_GPIO_NUMBER_OFFSET]
	BL		gpio_set_high
	MOVS	R0, #0x02
	BL		nrf_delay_mcs
	LDRB	R0, [R5,#LCD1602A_ENAB_GPIO_NUMBER_OFFSET]
	BL		gpio_set_low
	MOVS	R0, #120
	BL		nrf_delay_mcs
	;LDR		R0, =DELAY_MCS
	;BL		nrf_delay_mcs
	POP		{PC}
    ENDP

lcd1602A_display_clear	PROC
	;R0: LCD1602A_PINS address
	PUSH	{LR}
	MOVS	R1, #0x01
	BL		lcd1602A_cmd_write
	POP		{PC}
    ENDP

	ROUT
lcd1602A_write_str	PROC
	EXPORT	lcd1602A_write_str
	;R0: LCD1602A_PINS address
	;R1: string address
	PUSH	{LR}
	PUSH	{R0,R1}
	BL		lcd1602A_display_clear
	POP		{R0,R1}
0	LDRB	R2, [R1]
	CMP		R2, #0x00
	BEQ		%1
	PUSH	{R0,R1}
	MOV		R1, R2
	BL		lcd1602A_data_write
	POP		{R0,R1}
	ADDS	R1, #0x01
	B		%0
1	POP		{PC}
    ENDP

;******************

	EXTERN	gpio_set_high
	EXTERN	gpio_set_low
	EXTERN	gpio_config_output
		
	EXTERN	nrf_delay_mcs

	EXPORT	LCD1602A_MODE_4_PIN_BUS			[WEAK]
	EXPORT	LCD1602A_MODE_8_PIN_BUS			[WEAK]
	EXPORT	LCD1602A_MODE_1_LINE			[WEAK]
	EXPORT	LCD1602A_MODE_2_LINES			[WEAK]
	EXPORT	LCD1602A_MODE_5x8_DOTS			[WEAK]
	EXPORT	LCD1602A_MODE_5x11_DOTS			[WEAK]
	EXPORT	LCD1602A_MODE_ENTRY_DIR_LEFT	[WEAK]
	EXPORT	LCD1602A_MODE_ENTRY_DIR_RIGHT	[WEAK]
	EXPORT	LCD1602A_MODE_ENTRY_SHIFT_OFF	[WEAK]
	EXPORT	LCD1602A_MODE_ENTRY_SHIFT_ON	[WEAK]
	EXPORT	LCD1602A_MODE_DSPL_DISPL_ON		[WEAK]
	EXPORT	LCD1602A_MODE_DSPL_CURS_ON		[WEAK]
	EXPORT	LCD1602A_MODE_DSPL_CBLINK_OFF	[WEAK]
	EXPORT	LCD1602A_MODE_DSPL_CBLINK_ON	[WEAK]

LCD1602A_MODE_4_PIN_BUS			EQU	0x00
LCD1602A_MODE_8_PIN_BUS			EQU	0x01
LCD1602A_MODE_1_LINE			EQU	0x00
LCD1602A_MODE_2_LINES			EQU	0x01
LCD1602A_MODE_5x8_DOTS			EQU	0x00
LCD1602A_MODE_5x11_DOTS			EQU	0x01
LCD1602A_MODE_ENTRY_DIR_LEFT	EQU	0x00
LCD1602A_MODE_ENTRY_DIR_RIGHT	EQU	0x01
LCD1602A_MODE_ENTRY_SHIFT_OFF	EQU	0x00
LCD1602A_MODE_ENTRY_SHIFT_ON	EQU	0x01
LCD1602A_MODE_DSPL_DISPL_OFF	EQU	0x00
LCD1602A_MODE_DSPL_DISPL_ON		EQU	0x01
LCD1602A_MODE_DSPL_CURS_OFF		EQU	0x00
LCD1602A_MODE_DSPL_CURS_ON		EQU	0x01
LCD1602A_MODE_DSPL_CBLINK_OFF	EQU	0x00
LCD1602A_MODE_DSPL_CBLINK_ON	EQU	0x01
	

DELAY_MCS			EQU		100000

LCD1602A_SEL_GPIO_NUMBER_OFFSET		EQU	0x00
LCD1602A_RW_GPIO_NUMBER_OFFSET		EQU	0x01
LCD1602A_ENAB_GPIO_NUMBER_OFFSET	EQU	0x02
LCD1602A_D0_GPIO_NUMBER_OFFSET		EQU	0x03
LCD1602A_D1_GPIO_NUMBER_OFFSET		EQU	0x04
LCD1602A_D2_GPIO_NUMBER_OFFSET		EQU	0x05
LCD1602A_D3_GPIO_NUMBER_OFFSET		EQU	0x06
LCD1602A_D4_GPIO_NUMBER_OFFSET		EQU	0x07
LCD1602A_D5_GPIO_NUMBER_OFFSET		EQU	0x08
LCD1602A_D6_GPIO_NUMBER_OFFSET		EQU	0x09
LCD1602A_D7_GPIO_NUMBER_OFFSET		EQU	0x0A
LCD1602A_BL_GPIO_NUMBER_OFFSET		EQU	0x0B

LCD1602A_MODE_x_PIN_BUS_OFFSET		EQU	0x00
LCD1602A_MODE_x_LINES_OFFSET		EQU	0x01
LCD1602A_MODE_XxXX_DOTS_OFFSET		EQU	0x02
LCD1602A_MODE_ENTRY_DIR_OFFSET		EQU	0x03
LCD1602A_MODE_ENTRY_SHIFT_OFFSET	EQU	0x04
LCD1602A_MODE_DSPL_DISPL_OFFSET		EQU	0x05
LCD1602A_MODE_DSPL_CURS_OFFSET		EQU	0x06
LCD1602A_MODE_DSPL_CBLINK_OFFSET	EQU	0x07


	END
