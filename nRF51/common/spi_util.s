	AREA spi_util, CODE, READONLY

	ROUT
spi_init	PROC
	EXPORT	spi_init
	;R0: spi control block address
	PUSH	{LR,R4}
	MOV		R4, R0
	LDRB	R0, [R4, #SPICB_MOSI_GPIO_NUMBER_OFFSET]
	BL		gpio_config_output
	LDRB	R0, [R4, #SPICB_MOSI_GPIO_NUMBER_OFFSET]
	BL		gpio_config_pullup
	LDRB	R0, [R4, #SPICB_MISO_GPIO_NUMBER_OFFSET]
	BL		gpio_config_input
	LDRB	R0, [R4, #SPICB_MISO_GPIO_NUMBER_OFFSET]
	BL		gpio_config_pullup
	LDRB	R0, [R4, #SPICB_SCK_GPIO_NUMBER_OFFSET]
	BL		gpio_config_output
	LDRB	R0, [R4, #SPICB_SCK_GPIO_NUMBER_OFFSET]
	BL		gpio_config_pullup
	LDRB	R0, [R4, #SPICB_CS_GPIO_NUMBER_OFFSET]
	BL		gpio_config_output
	LDRB	R0, [R4, #SPICB_CS_GPIO_NUMBER_OFFSET]
	BL		gpio_config_pullup
	MOV		R0, R4
	BL		spi_pin_SCK_select
	MOV		R0, R4
	LDRB	R1, [R4, #SPICB_MOSI_GPIO_NUMBER_OFFSET]
	BL		spi_pin_MOSI_select
	MOV		R0, R4
	LDRB	R1, [R4, #SPICB_MISO_GPIO_NUMBER_OFFSET]
	BL		spi_pin_MISO_select
	MOV		R0, R4
	LDR		R1, [R4, #SPICB_FREQ_OFFSET]
	BL		spi_FREQ_master_data_rate_set
	MOV		R0, R4
	LDRB	R1, [R4, #SPICB_MODE_OFFSET]
	BL		spi_MSB_mode_set
	LDRB	R0, [R4, #SPICB_CS_GPIO_NUMBER_OFFSET]
	BL		gpio_set_high
	MOV		R0, R4
	BL		spi_int_enable
	MOV		R0, R4
	BL		spi_enable
	POP		{PC,R4}
    ENDP
		
spi_ready_clear	PROC
	EXPORT	spi_ready_clear
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_READY_OFFSET
	EORS	R1, R1, R1
	STR		R1, [R0, R2]
	BX		LR
    ENDP
	
	ROUT
spi_is_ready_pending	PROC		;TXD byte sent and RXD byte received
	EXPORT	spi_is_ready_pending
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_READY_OFFSET	
	LDR		R1, [R0, R2]
	EORS	R0, R0, R0	;return no
	CMP		R1, R0
	BEQ		%0
	MOVS	R0, #1		;return pending
0	BX		LR
    ENDP

	ROUT
spi_READY_event_wait PROC
	EXPORT	spi_READY_event_wait
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_READY_OFFSET
0	LDR		R1, [R0, R2]
	CMP		R1, #0x00
	BEQ		%0
	BX		LR
	ENDP

	ROUT
spi_READY_event_wait_clear PROC
	EXPORT	spi_READY_event_wait_clear
	;R0: spi control block address
	LDR		R1, [R0, #SPICB_BASE_OFFSET]
	LDR		R3, =SPI_READY_OFFSET
0	LDR		R2, [R1, R3]
	CMP		R2, #0x00
	BEQ		%0
	B		spi_ready_clear
	ENDP

spi_int_enable PROC
	EXPORT	spi_int_enable
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_INTENSET_OFFSET	
	MOVS	R1, #SPI_INTEN_MASK
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_int_disable PROC
	EXPORT	spi_int_disable
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_INTENCLR_OFFSET	
	MOVS	R1, #SPI_INTEN_MASK
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_enable PROC
	EXPORT	spi_enable
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_ENABLE_OFFSET	
	MOVS	R1, #0x01
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_disable PROC
	EXPORT	spi_disable
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_ENABLE_OFFSET	
	EORS	R1,R1,R1
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_pin_SCK_select	PROC
	EXPORT	spi_pin_SCK_select
	;R0: spi control block address
	LDR		R1, [R0, #SPICB_BASE_OFFSET]
	LDRB	R2, [R0, #SPICB_SCK_GPIO_NUMBER_OFFSET]
	LDR		R3, =SPI_PSELSCK_OFFSET	
	STR		R2, [R1, R3]
	BX		LR
	ENDP
		
spi_pin_SCK_disconnect	PROC
	EXPORT	spi_pin_SCK_disconnect
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_PSELSCK_OFFSET	
	LDR		R1, =0xFFFFFFFF
	STR		R1, [R0, R2]
	BX		LR
	ENDP
		
spi_pin_MOSI_select	PROC
	EXPORT	spi_pin_MOSI_select
	;R0: spi control block address
	LDR		R1, [R0, #SPICB_BASE_OFFSET]
	LDRB	R2, [R0, #SPICB_MOSI_GPIO_NUMBER_OFFSET]
	LDR		R3, =SPI_PSELMOSI_OFFSET	
	STR		R2, [R1, R3]
	BX		LR
	ENDP
		
spi_pin_MOSI_disconnect	PROC
	EXPORT	spi_pin_MOSI_disconnect
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R1, =SPI_PSELMOSI_OFFSET	
	LDR		R2, =0xFFFFFFFF
	STR		R2, [R0, R1]
	BX		LR
	ENDP
		
spi_pin_MISO_select	PROC
	EXPORT	spi_pin_MISO_select
	;R0: spi control block address
	LDR		R1, [R0, #SPICB_BASE_OFFSET]
	LDRB	R2, [R0, #SPICB_MISO_GPIO_NUMBER_OFFSET]
	LDR		R3, =SPI_PSELMISO_OFFSET	
	STR		R2, [R1, R3]
	BX		LR
	ENDP
		
spi_pin_MISO_disconnect	PROC
	EXPORT	spi_pin_MISO_disconnect
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_PSELMISO_OFFSET	
	MOVS	R1, #0xFF
	SXTB	R1, R1
	STR		R1, [R0, R2]
	BX		LR
	ENDP
		
spi_RXD_get	PROC
	EXPORT	spi_RXD_get
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R1, =SPI_RXD_OFFSET	
	LDRB	R0, [R0, R1]
	BX		LR
	ENDP

spi_TXD_set	PROC
	EXPORT	spi_TXD_set
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_TXD_OFFSET	
	STRB	R1, [R0, R2]
	BX		LR
	ENDP

spi_FREQ_master_data_rate_set	PROC
	;R0: spi control block address
	LDR		R1, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, [R0, #SPICB_FREQ_OFFSET]
	LDR		R3, =SPI_FREQUENCY_OFFSET	
	STR		R2, [R1, R3]
	BX		LR
	ENDP

spi_FREQ_master_data_rate_K125	PROC
	EXPORT	spi_FREQ_master_data_rate_K125
	;R0: spi control block address
	PUSH	{LR}
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_FREQUENCY_OFFSET	
	LDR		R1, =SPI_MDR_K125
	STR		R1, [R0, R2]
	POP		{PC}
	ENDP
	
spi_FREQ_master_data_rate_K250	PROC
	EXPORT	spi_FREQ_master_data_rate_K250
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_FREQUENCY_OFFSET	
	LDR		R1, =SPI_MDR_K250
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_FREQ_master_data_rate_K500	PROC
	EXPORT	spi_FREQ_master_data_rate_K500
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_FREQUENCY_OFFSET	
	LDR		R1, =SPI_MDR_K500
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_FREQ_master_data_rate_M1	PROC
	EXPORT	spi_FREQ_master_data_rate_M1
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_FREQUENCY_OFFSET	
	LDR		R1, =SPI_MDR_M1
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_FREQ_master_data_rate_M2	PROC
	EXPORT	spi_FREQ_master_data_rate_M2
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_FREQUENCY_OFFSET	
	LDR		R1, =SPI_MDR_M2
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_FREQ_master_data_rate_M4	PROC
	EXPORT	spi_FREQ_master_data_rate_M4
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_FREQUENCY_OFFSET	
	LDR		R1, =SPI_MDR_M4
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_FREQ_master_data_rate_M8	PROC
	EXPORT	spi_FREQ_master_data_rate_M8
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_FREQUENCY_OFFSET	
	LDR		R1, =SPI_MDR_M8
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_shift_MSB_first	PROC
	EXPORT	spi_shift_MSB_first
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	MOVS	R1, #0x01
	B		spi_CONFIG_bit_reset
	ENDP

spi_shift_LSB_first	PROC
	EXPORT	spi_shift_LSB_first
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	MOVS	R1, #0x01
	B		spi_CONFIG_bit_set
	ENDP

spi_MSB_mode_set	PROC
	;R0: spi control block address
	LDR		R1, [R0, #SPICB_BASE_OFFSET]
	LDRB	R2, [R0, #SPICB_MODE_OFFSET]
	LDR		R3, =SPI_CONFIG_OFFSET
	STR		R2, [R1, R3]
	BX		LR
	ENDP

spi_MSB_mode_0	PROC
	EXPORT	spi_MSB_mode_0
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_CONFIG_OFFSET
	MOVS	R1, #SPI_CFG_MSB_MODE_0
	STR		R1, [R0, R2]
	BX		LR
	ENDP
	
spi_MSB_mode_1	PROC
	EXPORT	spi_MSB_mode_1
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_CONFIG_OFFSET
	MOVS	R1, #SPI_CFG_MSB_MODE_1
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_MSB_mode_2	PROC
	EXPORT	spi_MSB_mode_2
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_CONFIG_OFFSET
	MOVS	R1, #SPI_CFG_MSB_MODE_2
	STR		R1, [R0, R2]
	BX		LR
	ENDP

spi_MSB_mode_3	PROC
	EXPORT	spi_MSB_mode_3
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	LDR		R2, =SPI_CONFIG_OFFSET
	MOVS	R1, #SPI_CFG_MSB_MODE_3
	STR		R1, [R0, R2]
	BX		LR
	ENDP

;Serial clock (SCK) phase
spi_CPHA_leading PROC				;Sample on leading edge of clock, shift serial data on trailing
	EXPORT	spi_CPHA_leading
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	MOVS	R1, #0x02
	B		spi_CONFIG_bit_reset
	ENDP

spi_CPHA_trailing PROC				;Sample on trailing edge of clock, shift serial data on leading edge
	EXPORT	spi_CPHA_trailing
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	MOVS	R1, #0x02
	B		spi_CONFIG_bit_set
	ENDP

;Serial clock (SCK) polarity
spi_CPOL_active_high	PROC
	EXPORT	spi_CPOL_active_high
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	MOVS	R1, #0x04
	B		spi_CONFIG_bit_reset
	ENDP
	
spi_CPOL_active_low PROC
	EXPORT	spi_CPOL_active_low
	;R0: spi control block address
	LDR		R0, [R0, #SPICB_BASE_OFFSET]
	MOVS	R1, #0x04
	B		spi_CONFIG_bit_set
	ENDP

spi_CONFIG_bit_set	PROC
	;R0: spi base address
	;R1: mask
	LDR		R2, =SPI_CONFIG_OFFSET	
	ADD		R0, R2, R0
	LDR		R2, [R0]
	ORRS	R1, R2
	STR		R1, [R0]
	BX		LR
	ENDP

spi_CONFIG_bit_reset	PROC
	;R0: spi base address
	;R1: mask
	LDR		R2, =SPI_CONFIG_OFFSET	
	ADD		R0, R2, R0
	LDR		R2, [R0]
	MVNS	R1, R1
	ANDS	R1, R2
	STR		R1, [R0]
	BX		LR
	ENDP

;******************

	EXTERN	gpio_config_output
	EXTERN	gpio_config_pullup
	EXTERN	gpio_config_input
	EXTERN	gpio_set_high


;spi control block structure
	EXPORT	SPICB_CS_GPIO_NUMBER_OFFSET		[WEAK]
	EXPORT	SPICB_MOSI_GPIO_NUMBER_OFFSET	[WEAK]
		
SPICB_BASE_OFFSET				EQU		0x00
SPICB_CS_GPIO_NUMBER_OFFSET		EQU		0x04
SPICB_SCK_GPIO_NUMBER_OFFSET	EQU		0x05
SPICB_MOSI_GPIO_NUMBER_OFFSET	EQU		0x06
SPICB_MISO_GPIO_NUMBER_OFFSET	EQU		0x07
SPICB_FREQ_OFFSET				EQU		0x08
SPICB_MODE_OFFSET				EQU		0x0C


	EXPORT	SPI0_BASE_ADDRESS			[WEAK]
	EXPORT	SPI1_BASE_ADDRESS			[WEAK]

SPI_INTEN_MASK			EQU		0x04

;config register value for different modes and endiannesses
	EXPORT	SPI_CFG_MSB_MODE_0			[WEAK]
SPI_CFG_MSB_MODE_0			EQU		0x00
SPI_CFG_MSB_MODE_1			EQU		0x02
SPI_CFG_MSB_MODE_2			EQU		0x04
SPI_CFG_MSB_MODE_3			EQU		0x06
SPI_CFG_LSB_MODE_0			EQU		0x01
SPI_CFG_LSB_MODE_1			EQU		0x03
SPI_CFG_LSB_MODE_2			EQU		0x05
SPI_CFG_LSB_MODE_3			EQU		0x07
	
;master data rate values
	EXPORT	SPI_MDR_K250			[WEAK]
SPI_MDR_K125 				EQU		0x02000000 ;125 kbps
SPI_MDR_K250 				EQU		0x04000000 ;250 kbps
SPI_MDR_K500 				EQU		0x08000000 ;500 kbps
SPI_MDR_M1 					EQU		0x10000000 ;1 Mbps
SPI_MDR_M2 					EQU		0x20000000 ;2 Mbps
SPI_MDR_M4 					EQU		0x40000000 ;4 Mbps
SPI_MDR_M8 					EQU		0x80000000 ;8 Mbps

SPI0_BASE_ADDRESS		EQU		0x40003000
SPI1_BASE_ADDRESS		EQU		0x40004000

;Events
SPI_READY_OFFSET 		EQU		0x108 ;TXD byte sent and RXD byte received
;Registers
SPI_INTEN_OFFSET		EQU		0x300 ;Enable or disable interrupt
SPI_INTENSET_OFFSET		EQU		0x304 ;Enable interrupt
SPI_INTENCLR_OFFSET		EQU		0x308 ;Disable interrupt
SPI_ENABLE_OFFSET		EQU		0x500 ;Enable SPI
SPI_PSELSCK_OFFSET		EQU		0x508 ;Pin select for SCK
SPI_PSELMOSI_OFFSET		EQU		0x50C ;Pin select for MOSI
SPI_PSELMISO_OFFSET		EQU		0x510 ;Pin select for MISO
SPI_RXD_OFFSET			EQU		0x518 ;RXD register
SPI_TXD_OFFSET			EQU		0x51C ;TXD register
SPI_FREQUENCY_OFFSET	EQU		0x524 ;SPI frequency
SPI_CONFIG_OFFSET		EQU		0x554 ;Configuration register
	
	END
