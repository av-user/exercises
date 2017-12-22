	AREA uart_utilities, CODE, READONLY

init_IRQs	PROC
	EXPORT	init_IRQs
	;R0: uart control block address
	;returns in R0 the value set
	LDRB	R2, [R0, #UARTCB_IRQ_RXTO_ENABLE_OFFSET]
	LSLS	R2, #17
	LDRB	R3, [R0, #UARTCB_IRQ_ERROR_ENABLE_OFFSET]
	LSLS	R3, #9
	ADDS	R2, R3
	LDRB	R3, [R0, #UARTCB_IRQ_TXDRDY_ENABLE_OFFSET]
	LSLS	R3, #7
	ADDS	R2, R3
	LDRB	R3, [R0, #UARTCB_IRQ_RXDRDY_ENABLE_OFFSET]
	LSLS	R3, #2
	ADDS	R2, R3
	LDRB	R3, [R0, #UARTCB_IRQ_NCTS_ENABLE_OFFSET]
	LSLS	R3, #1
	ADDS	R2, R3
	LDRB	R3, [R0, #UARTCB_IRQ_CTS_ENABLE_OFFSET]
	ADDS	R2, R3
	LDR		R3, =UART_BASE_ADDRESS
	LDR		R1, =UART_INTEN_OFFSET
	STR		R2, [R3,R1]
	MOV		R0, R2
	BX		LR
	ENDP

	ROUT
uart_init	PROC
	EXPORT	uart_init
	;R0: uart control block address
	PUSH	{LR,R4}
	MOV		R4, R0
	LDRB	R0, [R4, #UARTCB_RXD_GPIO_NUMBER_OFFSET]
	BL		gpio_config_input
	LDRB	R0, [R4, #UARTCB_CTS_GPIO_NUMBER_OFFSET]
	BL		gpio_config_input
	LDRB	R0, [R4, #UARTCB_RTS_GPIO_NUMBER_OFFSET]
	BL		gpio_config_output
	LDRB	R0, [R4, #UARTCB_RTS_GPIO_NUMBER_OFFSET]
	BL		gpio_set_high
	LDRB	R0, [R4, #UARTCB_TXD_GPIO_NUMBER_OFFSET]
	BL		gpio_config_output
	LDRB	R0, [R4, #UARTCB_TXD_GPIO_NUMBER_OFFSET]
	BL		gpio_set_high
	LDR		R0, [R4, #UARTCB_BAUDRATE_OFFSET]
	BL		uart_baudrate_set
	LDRB	R0, [R4, #UARTCB_RTS_GPIO_NUMBER_OFFSET]
	BL		uart_PSELRTS_select
	LDRB	R0, [R4, #UARTCB_TXD_GPIO_NUMBER_OFFSET]
	BL		uart_PSELTXD_select
	LDRB	R0, [R4, #UARTCB_CTS_GPIO_NUMBER_OFFSET]
	BL		uart_PSELCTS_select
	LDRB	R0, [R4, #UARTCB_RXD_GPIO_NUMBER_OFFSET]
	BL		uart_PSELRXD_select
	BL		uart_event_TXDRDY_clear
	BL		uart_event_RXTO_clear	;Receiver timeout
	MOV		R0, R4
	BL		init_IRQs
	CMP		R0, #0x00
	BEQ		%0
	;enable IRQ
	LDR		R0, =UART0_IRQn
	MOVS	R1, #3	;priority
	BL		drv_common_irq_enable
	BL		uart_event_ERROR_clear
	BL		uart_event_RXDRDY_clear
	BL		uart_event_TXDRDY_clear
0	NOP
	BL		uart_enable
	POP		{PC,R4}
	ENDP

	ROUT
uart_send_text_byte	PROC
	EXPORT	uart_send_text_byte
	;R0: text begin
	;R1: text end
	;R2: byte to append
	PUSH	{LR,R4-R6}
	MOV		R4, R0
	MOV		R5, R1
	MOV		R6, R2
	LSLS	R6, #24
	LSRS	R6, #24
	BL		uart_STARTTX_trigger
	MOV		R0, R4
	MOV		R1, R5
	BL		uart_transmit
	MOVS	R0, #0x20	;' '
	BL		uart_transmit_byte
	MOVS	R0, #0x30	;'0'
	BL		uart_transmit_byte
	MOVS	R0, #0x78	;'x'
	BL		uart_transmit_byte
	MOV		R0, R6
	LSLS	R0, #24
	BL		uart_transmit_left_byte
	MOVS	R0, #0x0A	;'\n'
	BL		uart_transmit_byte
	BL		uart_STOPTX_trigger	
	POP		{PC,R4-R6}
	ENDP

	ROUT
uart_transmit_left_byte	PROC
	;R0: dword which left byte to transmit
	PUSH	{LR,R4}
	MOV		R4, R0
	;the 1st hex digit
	LSRS	R0, #28
	CMP		R0, #0x09
	BLS		%0	;0-9
	;A-F
	ADDS	R0, #0x37
	B		%1
0	ADDS	R0, #0x30
1	BL		uart_transmit_byte
	;the 2nd hex digit
	MOV		R0, R4
	LSLS	R0, #4
	LSRS	R0, #28
	CMP		R0, #0x09
	BLS		%2	;0-9
	;A-F
	ADDS	R0, #0x37
	B		%3
2	ADDS	R0, #0x30
3	BL		uart_transmit_byte
	POP		{PC,R4}
	ENDP

	ROUT
uart_send_text_dword	PROC
	EXPORT	uart_send_text_dword
	;R0: text begin
	;R1: text end
	;R2: dword to append
	PUSH	{LR,R4-R6}
	MOV		R4, R0
	MOV		R5, R1
	MOV		R6, R2
	BL		uart_STARTTX_trigger
	MOV		R0, R4
	MOV		R1, R5
	BL		uart_transmit
	MOVS	R0, #0x20	;' '
	BL		uart_transmit_byte
	MOVS	R0, #0x30	;'0'
	BL		uart_transmit_byte
	MOVS	R0, #0x78	;'x'
	BL		uart_transmit_byte

	MOV		R0, R6
	BL		uart_transmit_left_byte
	MOV		R0, R6
	LSLS	R0, #8
	BL		uart_transmit_left_byte
	MOV		R0, R6
	LSLS	R0, #16
	BL		uart_transmit_left_byte
	MOV		R0, R6
	LSLS	R0, #24
	BL		uart_transmit_left_byte
	MOVS	R0, #0x0A	;'\n'
	BL		uart_transmit_byte
	BL		uart_STOPTX_trigger	
	POP		{PC,R4-R6}
	ENDP

	ROUT
uart_transmit_byte	PROC
	;R0: byte
	PUSH	{LR,R4,R5}
	BL		uart_TXD_set
0	BL		uart_event_TXDRDY_check
	CMP		R0, #0x01
	BNE		%0
	BL		uart_event_TXDRDY_clear
	POP		{PC,R4,R5}
	ENDP

	ROUT
uart_transmit	PROC
	;R0: data begin
	;R1: data end
	PUSH	{LR,R4,R5}
	MOV		R4, R0
	MOV		R5, R1
0	CMP		R4, R5
	BGE		%2
	LDRB	R0, [R4]
	BL		uart_TXD_set
1	BL		uart_event_TXDRDY_check
	CMP		R0, #0x01
	BNE		%1
	BL		uart_event_TXDRDY_clear
	ADDS	R4, #0x01
	B		%0
2	POP		{PC,R4,R5}
	ENDP

	ROUT
uart_send	PROC
	EXPORT	uart_send
	;R0: data begin
	;R1: data end
	PUSH	{LR,R4,R5}
	MOV		R4, R0
	MOV		R5, R1
	BL		uart_STARTTX_trigger
	MOV		R0, R4
	MOV		R1, R5
	BL		uart_transmit
	BL		uart_STOPTX_trigger	
	POP		{PC,R4,R5}
	ENDP

uart_baudrate_set	PROC
	;R0: baude rate in nRF51 uart notation
	LDR		R2, =UART_BASE_ADDRESS
	LDR		R1, =UART_BAUDRATE_OFFSET
	STR		R0, [R2,R1]
	BX		LR
	ENDP

uart_baudrate_set_115200	PROC
	EXPORT	uart_baudrate_set_115200
	LDR		R0, =UART_BASE_ADDRESS
	LDR		R1, =UART_BAUDRATE_OFFSET
	ADD		R0, R1
	LDR		R1, =UART_Baud115200
	STR		R1, [R0]
	BX		LR
	ENDP

uart_cfg	PROC	;Configuration of parity and hardware flow control
	;R0: value
	LDR		R2, =UART_BASE_ADDRESS
	LDR		R1, =UART_CONFIG_OFFSET
	ADD		R2, R1
	STR		R0, [R2]
	BX		LR
	ENDP

uart_cfg_HWFC_NOPARITY	PROC
	EXPORT	uart_cfg_HWFC_NOPARITY
	PUSH	{LR}
	MOVS	R0, #0x01
	BL		uart_cfg
	POP		{PC}
	ENDP
		
uart_cfg_NOHWFC_NOPARITY	PROC
	EXPORT	uart_cfg_NOHWFC_NOPARITY
	PUSH	{LR}
	EORS	R0,R0,R0
	BL		uart_cfg
	POP		{PC}
	ENDP

uart_cfg_HWFC_PARITY	PROC
	EXPORT	uart_cfg_HWFC_PARITY
	PUSH	{LR}
	MOVS	R0,	#0x0F
	BL		uart_cfg
	POP		{PC}
	ENDP

uart_cfg_NOHWFC_PARITY	PROC
	EXPORT	uart_cfg_NOHWFC_PARITY
	PUSH	{LR}
	MOVS	R0,	#0x0E
	BL		uart_cfg
	POP		{PC}
	ENDP

uart_event_clear	PROC
	;R1: event offset
	LDR		R0, =UART_BASE_ADDRESS
	ADD		R0, R1
	EORS	R1, R1, R1
	STR		R1, [R0]
	BX		LR
	ENDP

uart_event_TXDRDY_clear	PROC		;Data sent from TXD
	EXPORT	uart_event_TXDRDY_clear
	LDR		R1, =UART_TXDRDY_OFFSET
	B		uart_event_clear
	ENDP
		
uart_event_RXTO_clear	PROC		;Receiver timeout
	EXPORT	uart_event_RXTO_clear
	LDR		R1, =UART_RXTO_OFFSET
	B		uart_event_clear
	ENDP

uart_event_ERROR_clear	PROC
	EXPORT	uart_event_ERROR_clear
	LDR		R1, =UART_ERROR_OFFSET
	B		uart_event_clear
	ENDP
		
uart_event_RXDRDY_clear	PROC		;Data sent from TXD
	EXPORT	uart_event_RXDRDY_clear
	LDR		R1, =UART_RXDRDY_OFFSET
	B		uart_event_clear
	ENDP

uart_STARTRX_trigger	PROC		;Start UART receiver
	EXPORT	uart_STARTRX_trigger
	LDR		R0, =UART_BASE_ADDRESS
	;UART_STARTRX_OFFSET == 0x000
	MOVS	R1, #1
	STR		R1, [R0]
	BX		LR
	ENDP

uart_STOPRX_trigger	PROC			;Stop UART receiver
	EXPORT	uart_STOPTX_trigger
	LDR		R0, =UART_BASE_ADDRESS
	LDR		R1, =UART_STOPRX_OFFSET
	ADD		R0, R1
	MOVS	R1, #1
	STR		R1, [R0]
	BX		LR
	ENDP

uart_STARTTX_trigger	PROC		;Start UART transmitter
	EXPORT	uart_STARTTX_trigger
	LDR		R0, =UART_BASE_ADDRESS
	LDR		R1, =UART_STARTTX_OFFSET
	ADD		R0, R1
	MOVS	R1, #1
	STR		R1, [R0]
	BX		LR
	ENDP

uart_STOPTX_trigger	PROC			;Stop UART transmitter
	EXPORT	uart_STOPTX_trigger
	LDR		R0, =UART_BASE_ADDRESS
	LDR		R1, =UART_STOPTX_OFFSET
	ADD		R0, R1
	MOVS	R1, #1
	STR		R1, [R0]
	BX		LR
	ENDP

uart_event_check	PROC
	;R0: event offset
	LDR		R1, =UART_BASE_ADDRESS
	LDR		R0, [R0,R1]
	BX		LR
	ENDP

uart_event_ERROR_check	PROC
	EXPORT	uart_event_ERROR_check
	LDR		R0, =UART_ERROR_OFFSET
	B		uart_event_check
	ENDP

uart_event_TXDRDY_check	PROC	;Data sent from TXD
	EXPORT	uart_event_TXDRDY_check
	LDR		R0, =UART_TXDRDY_OFFSET
	B		uart_event_check
	ENDP

uart_event_RXTO_check	PROC	;Receiver timeout
	EXPORT	uart_event_RXTO_check
	LDR		R0, =UART_RXTO_OFFSET
	B		uart_event_check
	ENDP

uart_event_RXDRDY_check	PROC	;Data received in RXD
	EXPORT	uart_event_RXDRDY_check
	LDR		R0, =UART_RXDRDY_OFFSET
	B		uart_event_check
	ENDP

uart_pin_select	PROC
	;R0: pin number
	;R1: register offset
	LDR		R2, =UART_BASE_ADDRESS
	ADD		R1, R2
	STR		R0, [R1]
	BX		LR
	ENDP

uart_PSELRTS_select	PROC	;Pin select for RTS
	EXPORT	uart_PSELRTS_select
	;R0: pin number
	LDR		R1, =UART_PSELRTS_OFFSET
	B		uart_pin_select
	ENDP
		
uart_PSELTXD_select	PROC	;Pin select for TXD
	EXPORT	uart_PSELTXD_select
	;R0: pin number
	LDR		R1, =UART_PSELTXD_OFFSET
	B		uart_pin_select
	ENDP

uart_PSELCTS_select	PROC	;Pin select for CTS
	EXPORT	uart_PSELCTS_select
	;R0: pin number
	LDR		R1, =UART_PSELCTS_OFFSET
	B		uart_pin_select
	ENDP

uart_PSELRXD_select	PROC	;Pin select for RXD
	EXPORT	uart_PSELRXD_select
	;R0: pin number
	LDR		R1, =UART_PSELRXD_OFFSET
	B		uart_pin_select
	ENDP

uart_INTENSET_set	PROC	;Enable interrupts
	EXPORT	uart_INTENSET_set
	;R0: value
	LDR		R1, =UART_BASE_ADDRESS
	LDR		R2, =UART_INTENSET_OFFSET
	STR		R0, [R1, R2]
	BX		LR
	ENDP

uart_INTENCLR_set	PROC	;Disable interrupts
	EXPORT	uart_INTENCLR_set
	;R0: value
	LDR		R1, =UART_BASE_ADDRESS
	LDR		R2, =UART_INTENCLR_OFFSET
	STR		R0, [R1, R2]
	BX		LR
	ENDP


;uart_IRQ_enable	PROC	;Enable interrupt
	;EXPORT	uart_IRQ_enable
	;LDR		R0, =UART_BASE_ADDRESS
	;LDR		R1, =UART_INTENSET_OFFSET
	;MOVS	R2, #0x01
	;STR		R2, [R0,R1]
	;BX		LR
	;ENDP

;uart_IRQ_disable	PROC
	;EXPORT	uart_IRQ_disable
	;LDR		R0, =UART_BASE_ADDRESS
	;LDR		R1, =UART_INTENCLR_OFFSET
	;MOVS	R2, #0x01
	;STR		R2, [R0,R1]
	;BX		LR
	;ENDP

uart_enable PROC	;Enable UART
	EXPORT	uart_enable
	LDR		R0, =UART_BASE_ADDRESS
	LDR		R1, =UART_ENABLE_OFFSET
	MOVS	R2, #UART_ENABLE
	STR		R2, [R0, R1]
	BX		LR
	ENDP

uart_disable PROC	;Disable UART
	EXPORT	uart_disable
	LDR		R0, =UART_BASE_ADDRESS
	LDR		R2, =UART_ENABLE_OFFSET
	EORS	R1,R1,R1
	STR		R1, [R0, R2]
	BX		LR
	ENDP

uart_TXD_set	PROC
	EXPORT	uart_TXD_set
	;R0: TX data to be transferred
	LDR		R1, =UART_BASE_ADDRESS
	LDR		R2, =UART_TXD_OFFSET
	STR		R0, [R1,R2]
	BX		LR
	ENDP

;returns RX register content in R0
uart_RXD_get	PROC
	EXPORT	uart_RXD_get
	LDR		R1, =UART_BASE_ADDRESS
	LDR		R2, =UART_RXD_OFFSET
	LDR		R0, [R1,R2]
	BX		LR
	ENDP

uart_irq_enable_check	PROC
	;R0: number of bits to schift mask
	MOV		R2, R0
	LDR		R0, =UART_BASE_ADDRESS
	LDR		R1, =UART_INTENSET_OFFSET
	LDR		R1, [R0,R1]
	MOVS	R0, #0x01
	LSLS	R0, R0, R2
	ANDS	R0, R1
	LSRS	R0, R0, R2
	BX		LR
	ENDP

uart_irq_ERROR_enable_check	PROC
	EXPORT	uart_irq_ERROR_enable_check
	MOVS	R0, #UART_IRQ_ERROR_SHIFT
	B		uart_irq_enable_check
	ENDP

uart_errorsrc_get	PROC
	EXPORT	uart_errorsrc_get
	LDR		R0, =UART_BASE_ADDRESS
	LDR		R1, =UART_ERRORSRC_OFFSET
	LDR		R0, [R0,R1]
	BX		LR
	ENDP

uart_errorsrc_clear	PROC
	EXPORT	uart_errorsrc_clear
	LDR		R0, =UART_BASE_ADDRESS
	LDR		R1, =UART_ERRORSRC_OFFSET
	MOVS	R2, #0x0F
	STR		R2, [R0, R1]
	BX		LR
	ENDP

uart_irq_RXDRDY_enable_check	PROC
	EXPORT	uart_irq_RXDRDY_enable_check
	MOVS	R0, #UART_IRQ_RXDRDY_SHIFT
	B		uart_irq_enable_check
	ENDP

	EXTERN	drv_common_irq_enable

	EXTERN	gpio_config_input
	EXTERN	gpio_config_output
	EXTERN	gpio_set_high

	EXTERN	UART0_IRQn


;UARTCB *********************
	EXPORT	UARTCB_NOPARITY_HW_FLOWCTL_ENABLE	[WEAK]
	EXPORT	UARTCB_NOPARITY_HW_FLOWCTL_DISABLE	[WEAK]
	EXPORT	UARTCB_PARITY_HW_FLOWCTL_ENABLE		[WEAK]
	EXPORT	UARTCB_PARITY_HW_FLOWCTL_DISABLE	[WEAK]
		
UARTCB_IRQ_DISABLE					EQU	0x00
UARTCB_IRQ_ENABLE					EQU	0x01
	
UARTCB_NOPARITY_HW_FLOWCTL_ENABLE	EQU	0x01
UARTCB_NOPARITY_HW_FLOWCTL_DISABLE	EQU	0x00
UARTCB_PARITY_HW_FLOWCTL_ENABLE		EQU	0x0F
UARTCB_PARITY_HW_FLOWCTL_DISABLE	EQU	0x0E

;uart control block structure
UARTCB_RTS_GPIO_NUMBER_OFFSET	EQU	0x00
UARTCB_TXD_GPIO_NUMBER_OFFSET	EQU	0x01
UARTCB_CTS_GPIO_NUMBER_OFFSET	EQU	0x02
UARTCB_RXD_GPIO_NUMBER_OFFSET	EQU	0x03
UARTCB_BAUDRATE_OFFSET			EQU	0x04
UARTCB_PARITY_OFFSET			EQU	0x08
UART_PARITY_HW_FLOWCTL			EQU	0x09
UARTCB_IRQ_CTS_ENABLE_OFFSET	EQU	0x0A
UARTCB_IRQ_NCTS_ENABLE_OFFSET	EQU	0x0B
UARTCB_IRQ_RXDRDY_ENABLE_OFFSET	EQU	0x0C
UARTCB_IRQ_TXDRDY_ENABLE_OFFSET	EQU	0x0D
UARTCB_IRQ_ERROR_ENABLE_OFFSET	EQU	0x0E
UARTCB_IRQ_RXTO_ENABLE_OFFSET	EQU	0x0F
;uart control block structure end
;UARTCB ********************* END


UART_BASE_ADDRESS		EQU		0x40002000	;Universal Asynchronous Receiver/Transmitter
;Tasks
UART_STARTRX_OFFSET 	EQU		0x000 		;Start UART receiver
UART_STOPRX_OFFSET  	EQU		0x004 		;Stop UART receiver
UART_STARTTX_OFFSET  	EQU		0x008 		;Start UART transmitter
UART_STOPTX_OFFSET  	EQU		0x00C 		;Stop UART transmitter
UART_SUSPEND_OFFSET  	EQU		0x01C 		;Suspend UART
;Events
UART_CTS_OFFSET  		EQU		0x100 		;CTS is activated (set low). Clear To Send.
UART_NCTS_OFFSET  		EQU		0x104 		;CTS is deactivated (set high). Not Clear To Send.
UART_RXDRDY_OFFSET  	EQU		0x108 		;Data received in RXD
UART_TXDRDY_OFFSET  	EQU		0x11C 		;Data sent from TXD
UART_ERROR_OFFSET  		EQU		0x124 		;Error detected
UART_RXTO_OFFSET  		EQU		0x144 		;Receiver timeout
;Registers
UART_INTEN_OFFSET  		EQU		0x300 		;Enable or disable interrupt
UART_INTENSET_OFFSET  	EQU		0x304 		;Enable interrupt
UART_INTENCLR_OFFSET  	EQU		0x308 		;Clear interrupt
UART_ERRORSRC_OFFSET  	EQU		0x480 		;Error source
UART_ENABLE_OFFSET  	EQU		0x500 		;Enable UART
UART_PSELRTS_OFFSET  	EQU		0x508 		;Pin select for RTS
UART_PSELTXD_OFFSET  	EQU		0x50C 		;Pin select for TXD
UART_PSELCTS_OFFSET  	EQU		0x510 		;Pin select for CTS
UART_PSELRXD_OFFSET  	EQU		0x514 		;Pin select for RXD
UART_RXD_OFFSET  		EQU		0x518 		;RXD register
UART_TXD_OFFSET  		EQU		0x51C 		;TXD register
UART_BAUDRATE_OFFSET  	EQU		0x524 		;Baud rate
UART_CONFIG_OFFSET  	EQU		0x56C 		;Configuration of parity and hardware flow control

UART_ENABLE				EQU		0x04
UART_IRQ_ERROR_SHIFT	EQU		0x09
UART_IRQ_RXDRDY_SHIFT	EQU		0x02

	EXPORT	UART_Baud1200	[WEAK]
	EXPORT	UART_Baud2400	[WEAK]
	EXPORT	UART_Baud4800	[WEAK]
	EXPORT	UART_Baud9600	[WEAK]
	EXPORT	UART_Baud14400	[WEAK]
	EXPORT	UART_Baud19200	[WEAK]
	EXPORT	UART_Baud28800	[WEAK]
	EXPORT	UART_Baud38400	[WEAK]
	EXPORT	UART_Baud57600	[WEAK]
	EXPORT	UART_Baud76800	[WEAK]
	EXPORT	UART_Baud115200	[WEAK]
	EXPORT	UART_Baud230400	[WEAK]
	EXPORT	UART_Baud250000	[WEAK]
	EXPORT	UART_Baud460800	[WEAK]
	EXPORT	UART_Baud921600	[WEAK]
	EXPORT	UART_Baud1M		[WEAK]

UART_Baud1200   	EQU		0x0004F000 		;1200 baud
UART_Baud2400   	EQU		0x0009D000 		;2400 baud
UART_Baud4800   	EQU		0x0013B000 		;4800 baud
UART_Baud9600   	EQU		0x00275000 		;9600 baud
UART_Baud14400   	EQU		0x003B0000 		;14400 baud
UART_Baud19200   	EQU		0x004EA000 		;19200 baud
UART_Baud28800   	EQU		0x0075F000 		;28800 baud
UART_Baud38400   	EQU		0x009D5000 		;38400 baud
UART_Baud57600   	EQU		0x00EBF000 		;57600 baud
UART_Baud76800   	EQU		0x013A9000 		;76800 baud
UART_Baud115200   	EQU		0x01D7E000 		;115200 baud
UART_Baud230400   	EQU		0x03AFB000 		;230400 baud
UART_Baud250000   	EQU		0x04000000 		;250000 baud
UART_Baud460800   	EQU		0x075F7000 		;460800 baud
UART_Baud921600   	EQU		0x0EBEDFA4 		;921600 baud
UART_Baud1M 	  	EQU		0x10000000 		;1Mega baud

	END
