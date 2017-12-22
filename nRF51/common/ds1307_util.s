	AREA ds1307_util, CODE, READONLY

;works with ds3231 as well

ds1307_set_uninitialized PROC
	;R0: ds1307 control block address
	LDR		R1, [R0, #DS1307CB_STATE_OFFSET]
	MOVS	R2, #DS1307CB_STATE_INITIALIZED_MASK
	MVNS	R2, R2
	ANDS	R1, R2
	STR		R1, [R0, #DS1307CB_STATE_OFFSET]
	BX		LR
	ENDP

ds1307_set_initialized PROC
	;R0: ds1307 control block address
	LDR		R1, [R0, #DS1307CB_STATE_OFFSET]
	MOVS	R2, #DS1307CB_STATE_INITIALIZED_MASK
	ORRS	R1, R2
	STR		R1, [R0, #DS1307CB_STATE_OFFSET]
	BX		LR
	ENDP

ds1307_is_initialized PROC
	EXPORT	ds1307_is_initialized
	;R0: ds1307 control block address
	LDR		R0, [R0, #DS1307CB_STATE_OFFSET]
	MOVS	R1, #DS1307CB_STATE_INITIALIZED_MASK
	ANDS	R0, R1
	BX		LR
	ENDP

	ROUT
ds1307_init	PROC
	EXPORT	ds1307_init
	;R0: ds1307 control block address
	;R1: twi control block address
	PUSH	{LR,R4-R6}
	MOV		R4,	R0
	MOV		R5, R1
	BL		ds1307_set_uninitialized
	STR		R5, [R4, #DS1307CB_TWI_ADDR_OFFSET]
	MOV		R0, R5
	BL		twi_is_initialized
	CMP		R0, #0x00
	BNE		%4
3	EORS	R0,R0,R0	;failure
	B		%5
4	MOV		R0, R4
	BL		ds1307_set_initialized
	MOVS	R0, #0x01	;success
5	POP		{PC,R4-R6}
	ENDP

;the  DS3231  I2C interface may be placed into a known state by toggling SCL 
;until SDA is observed to be at a high level. At that point the microcontroller
;should pull SDA low while SCL is high, generating a START condition.
	ROUT
ds1307_reset PROC
	EXPORT	ds1307_reset
	;R0: twi (!!!) control block address
	PUSH	{LR,R4-R7}
	MOV		R4, R0
	LDR		R1, =TWICB_SCL_PIN_OFFSET
	LDRB	R5, [R4, R1]	;SCL pin - to R5
	LDR		R1, =TWICB_SDA_PIN_OFFSET
	LDRB	R6, [R4, R1]	;SDA pin - to R6
	;configure SDA
	MOV		R0, R6
	BL		gpio_input_buffer_connect
	MOV		R0, R6
	BL		gpio_config_pullup
	;configure SCL
	MOV		R0, R5
	BL		gpio_config_output
	EORS	R7,R7,R7
	CMP		R7, #0xFF
	BEQ		%3	;error
0	MOV		R0, R6
	BL		gpio_is_pin_high
	CMP		R0, #0x01
	BEQ		%1
	ADDS	R7, #0x01
	MOV		R0, R5
	BL		gpio_toggle
	B		%0
1	NOP	;SDA is high
	;At that point the microcontroller
	;should pull SDA low while SCL is high,
	;generating a START condition.
	MOV		R0, R5
	BL		gpio_is_pin_high
	CMP		R0, #0x01
	BEQ		%2
	MOV		R0, R5
	BL		gpio_set_high
2	NOP
	;reconfigure SDA
	MOV		R0, R6
	BL		gpio_cfg_out_disconnect
	MOV		R0, R6
	BL		gpio_config_nopull
	MOV		R0, R6
	BL		gpio_set_low
	MOVS	R0, #0x01
	B		%4
3	EORS	R0,R0,R0
4	POP		{PC,R4-R7}
	ENDP

	ROUT
ds1307_datetime_set	PROC
	EXPORT	ds1307_datetime_set
	;R0: ds1307 control block address
	PUSH	{LR,R4-R6}
	MOV		R4, R0
	LDR		R5, [R0, #DS1307CB_TWI_ADDR_OFFSET]
	MOV		R0, R5
	BL		twi_short_disable
	MOV		R0, R5
	MOVS	R1, #DS1307REG_SECONDS_OFFSET
	MOVS	R2, #0x01	;start transmission
	BL		twi_write_byte
	CMP		R0, #0x00
	BEQ		%3
	MOV		R0, R5
	LDRB	R1, [R4, #DS1307CB_TWICB_SECONDS_OFFSET]
	EORS	R2,R2,R2
	BL		twi_write_byte
	CMP		R0, #0x00
	BEQ		%3
	MOV		R0, R5
	LDRB	R1, [R4, #DS1307CB_TWICB_MINUTES_OFFSET]
	EORS	R2,R2,R2
	BL		twi_write_byte
	CMP		R0, #0x00
	BEQ		%3
	MOV		R0, R5
	LDRB	R1, [R4, #DS1307CB_TWICB_HOURS_OFFSET]
	EORS	R2,R2,R2
	BL		twi_write_byte
	CMP		R0, #0x00
	BEQ		%3
	MOV		R0, R5
	LDRB	R1, [R4, #DS1307CB_TWICB_DAYOFWEEK_OFFSET]
	EORS	R2,R2,R2
	BL		twi_write_byte
	CMP		R0, #0x00
	BEQ		%3
	MOV		R0, R5
	LDRB	R1, [R4, #DS1307CB_TWICB_DAY_OFFSET]
	EORS	R2,R2,R2
	BL		twi_write_byte
	CMP		R0, #0x00
	BEQ		%3
	MOV		R0, R5
	LDRB	R1, [R4, #DS1307CB_TWICB_MONTH_OFFSET]
	EORS	R2,R2,R2
	BL		twi_write_byte
	CMP		R0, #0x00
	BEQ		%3
	MOV		R0, R5
	LDRB	R1, [R4, #DS1307CB_TWICB_YEAR_OFFSET]
	EORS	R2,R2,R2
	BL		twi_write_byte
	CMP		R0, #0x00
	BEQ		%3
	MOV		R0, R5
	BL		twi_transaction_stop
	MOV		R0, R5
	BL		twi_STOPPED_event_wait_clear
	MOVS	R0, #0x01
	B		%4
3	MOV		R0, R5
	BL		twi_transaction_stop
	MOV		R0, R5
	BL		twi_STOPPED_event_wait_clear
	EORS	R0,R0,R0
4	POP		{PC,R4-R6}
	ENDP

	ROUT
ds1307_datetime_get	PROC
	EXPORT	ds1307_datetime_get
	;R0: ds1307 control block address
	PUSH	{LR,R4-R6}
	MOV		R4, R0
	LDR		R5, [R0, #DS1307CB_TWI_ADDR_OFFSET]
	MOV		R0, R5
	BL		twi_short_disable
	MOV		R0, R5
	MOVS	R1, #DS1307REG_SECONDS_OFFSET
	MOVS	R2, #0x01	;start transmission
	BL		twi_write_byte
	CMP		R0, #0x00
	BEQ		%0
	MOV		R0, R5
	BL		twi_short_BB_SUSPEND
	MOV		R0, R5
	MOVS	R1, #0x01	;new start
	BL		twi_read_byte
	CMP		R0, #0x00
	BEQ		%0
	STRB	R1, [R4, #DS1307CB_TWICB_SECONDS_OFFSET]
	MOV		R0, R5
	EORS	R1,R1,R1
	BL		twi_read_byte
	CMP		R0, #0x00
	BEQ		%0
	STRB	R1, [R4, #DS1307CB_TWICB_MINUTES_OFFSET]
	MOV		R0, R5
	EORS	R1,R1,R1
	BL		twi_read_byte
	CMP		R0, #0x00
	BEQ		%0
	STRB	R1, [R4, #DS1307CB_TWICB_HOURS_OFFSET]
	MOV		R0, R5
	EORS	R1,R1,R1
	BL		twi_read_byte
	CMP		R0, #0x00
	BEQ		%0
	STRB	R1, [R4, #DS1307CB_TWICB_DAYOFWEEK_OFFSET]
	MOV		R0, R5
	EORS	R1,R1,R1
	BL		twi_read_byte
	CMP		R0, #0x00
	BEQ		%0
	STRB	R1, [R4, #DS1307CB_TWICB_DAY_OFFSET]
	MOV		R0, R5
	EORS	R1,R1,R1
	BL		twi_read_byte
	CMP		R0, #0x00
	BEQ		%0
	STRB	R1, [R4, #DS1307CB_TWICB_MONTH_OFFSET]
	MOV		R0, R5
	BL		twi_transaction_stop
	MOV		R0, R5
	BL		twi_short_BB_STOP
	MOV		R0, R5
	EORS	R1,R1,R1
	BL		twi_read_byte
	CMP		R0, #0x00
	BEQ		%0
	STRB	R1, [R4, #DS1307CB_TWICB_YEAR_OFFSET]
	MOV		R0, R5
	BL		twi_STOPPED_event_clear
	MOV		R0, R5
	MOVS	R0, #0x01
	B		%1
0	MOV		R0, R5
	BL		twi_transaction_stop
	MOV		R0, R5
	BL		twi_short_BB_STOP
	MOV		R0, R5
	EORS	R1,R1,R1
	BL		twi_read_byte
	EORS	R0,R0,R0
1	POP		{PC,R4-R6}
	ENDP

;******************
	EXPORT	DS1307_ADDRESS	[WEAK]
		
DS1307_ADDRESS					EQU	0x68

;ds1307 control block structure
DS1307CB_STATE_OFFSET			EQU	0x00
DS1307CB_TWI_ADDR_OFFSET		EQU	0x04
DS1307CB_TWICB_YEAR_OFFSET		EQU	0x08
DS1307CB_TWICB_MONTH_OFFSET		EQU	0x09
DS1307CB_TWICB_DAY_OFFSET		EQU	0x0A
DS1307CB_TWICB_DAYOFWEEK_OFFSET	EQU	0x0B
DS1307CB_TWICB_HOURS_OFFSET		EQU	0x0C
DS1307CB_TWICB_MINUTES_OFFSET	EQU	0x0D
DS1307CB_TWICB_SECONDS_OFFSET	EQU	0x0E

DS1307CB_STATE_INITIALIZED_MASK	EQU	0x01
DS1307_DEFAULT_ADDRESS 			EQU	0x68

;ds1307 registers
DS1307REG_SECONDS_OFFSET		EQU	0x00
DS1307REG_MINUTES_OFFSET		EQU	0x01
DS1307REG_HOUS_OFFSET			EQU	0x02
DS1307REG_DAYOFWEEK_OFFSET		EQU	0x03
DS1307REG_DAY_OFFSET			EQU	0x04
DS1307REG_MONTH_OFFSET			EQU	0x05
DS1307REG_YEAR_OFFSET			EQU	0x06
	
	EXTERN	SPICB_CS_GPIO_NUMBER_OFFSET
	EXTERN	SPICB_MOSI_GPIO_NUMBER_OFFSET

	EXTERN	TWICB_SDA_PIN_OFFSET
	EXTERN	TWICB_SCL_PIN_OFFSET

	EXTERN	twi_is_initialized
	EXTERN	twi_txd_write
	EXTERN	twi_rxd_read
	EXTERN	twi_transmission_start
	EXTERN	twi_receiving_start
	EXTERN	twi_transaction_stop
	EXTERN	twi_init
	EXTERN	twi_RTD_sent_wait_clear
	EXTERN	twi_RXD_ready_wait_clear
	EXTERN	twi_stopped_wait_clear
	EXTERN	twi_STOPPED_event_wait_clear
	EXTERN	twi_BB_event_clear
	EXTERN	twi_ERROR_event_get
	EXTERN	twi_ERRORSRC_get
	EXTERN	twi_ERROR_event_clear
	EXTERN	twi_RESUME
	EXTERN	twi_SUSPENDED_event_clear
	EXTERN	twi_STOPPED_event_clear
	EXTERN	twi_read_byte
	EXTERN	twi_write_byte
	EXTERN	twi_short_BB_STOP
	EXTERN	twi_short_BB_SUSPEND
	EXTERN	twi_short_disable

	EXTERN	gpio_set_high
	EXTERN	gpio_set_low
	EXTERN	gpio_toggle
	EXTERN	gpio_is_pin_high
	EXTERN	gpio_config_pullup
	EXTERN	gpio_config_output
	EXTERN	gpio_input_buffer_connect
	EXTERN	gpio_cfg_out_disconnect
	EXTERN	gpio_config_nopull
	
	EXTERN	spi_TXD_set
	EXTERN	spi_RXD_get
	EXTERN	spi_READY_event_wait
	EXTERN	spi_READY_event_wait_clear

	EXTERN	nrf_delay_mcs

	ALIGN
	AREA    data, DATA

	END
