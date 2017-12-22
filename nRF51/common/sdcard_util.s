	AREA sdcard_util, CODE, READONLY

sdcard_set_uninitialized PROC
	;R0: sdcard control block address
	LDR		R1, [R0, #SDCARDCB_STATE_OFFSET]
	MOVS	R2, #SDCARDCB_STATE_INITIALIZED_MASK
	MVNS	R2, R2
	ANDS	R1, R2
	STR		R1, [R0, #SDCARDCB_STATE_OFFSET]
	BX		LR
	ENDP

sdcard_set_initialized PROC
	;R0: sdcard control block address
	LDR		R1, [R0, #SDCARDCB_STATE_OFFSET]
	MOVS	R2, #SDCARDCB_STATE_INITIALIZED_MASK
	ORRS	R1, R2
	STR		R1, [R0, #SDCARDCB_STATE_OFFSET]
	BX		LR
	ENDP

sdcard_is_initialized PROC
	EXPORT	sdcard_is_initialized
	;R0: sdcard control block address
	LDR		R0, [R0, #SDCARDCB_STATE_OFFSET]
	MOVS	R1, #SDCARDCB_STATE_INITIALIZED_MASK
	ANDS	R0, R1
	BX		LR
	ENDP

sdcard_reset	PROC
	EXPORT	sdcard_reset
	;R0: sdcard control block address
	PUSH	{LR,R4}
	MOV		R4, R0
	BL		sdcard_cmd0
	MOV		R0, R4
	BL		sdcard_set_uninitialized
	POP		{PC,R4}
	ENDP

	ROUT
sdcard_toggle_SD_CLK	PROC
	EXPORT	sdcard_toggle_SD_CLK
	;R0: sdcard control block address
	PUSH	{LR,R5,R6}
	MOV		R5, R0
	LDR		R6, [R5, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R1, =SPICB_MOSI_GPIO_NUMBER_OFFSET
	LDRB	R0, [R6, R1]
	BL		gpio_set_high
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R6, R1]
	BL		gpio_set_high
	MOVS	R6, #20	;"MOSI and CS lines to logic value 1 and toggle SD CLK for at least 74 cycles"
0	MOV		R0, R5
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	SUBS	R6, #0x01
	BNE		%0
	POP		{PC,R5,R6}
	ENDP

	LTORG

	ROUT
sdcard_init	PROC
	EXPORT	sdcard_init
	;R0: sdcard control block address
	;R1: spi control block address
	PUSH	{LR,R4-R7}
	MOV		R4,	R0
	MOV		R5, R1
	BL		sdcard_set_uninitialized
	STR		R5, [R4, #SDCARDCB_SPI_ADDR_OFFSET]
	MOV		R0, R4
	BL		sdcard_toggle_SD_CLK
	EORS	R6,R6,R6	;loop counter
0	MOV		R0, R4
	BL		sdcard_cmd0
	[ :DEF:__DEBUG__
		MOV	R7, R0
		LDR	R0, =TEXT_CMD0
		LDR	R1, =TEXT_CMD0_END
		MOV	R2, R7
		BL	uart_send_text_byte
		MOV	R0, R7
	]
	CMP		R0, #0x01
	BEQ		%1
	ADDS	R6, #0x01
	CMP		R6, #5
	BNE		%0
	B		%3
1	MOV		R0, R4
	BL		sdcard_cmd8
	MOVS	R1, #0x01
	MVNS	R1, R1
	TST		R0, R1
	BNE		%3
	MOV		R0, R4
	BL		sdcard_cmd58
	LDR		R0, =REPONSE_TAIL
	LDR		R0, [R0]
	MOVS	R6, #0x08
33	LDR		R0, =1000
	BL		nrf_delay_mcs
	MOV		R0, R4
	BL		sdcard_acmd41
	[ :DEF:__DEBUG__
		MOV	R7, R0
		LDR	R0, =TEXT_CMD41
		LDR	R1, =TEXT_CMD41_END
		MOV	R2, R7
		BL	uart_send_text_byte
		MOV	R0, R7
	]
	CMP		R0, #0x00
	BEQ		%4
	SUBS	R6, #0x01
	CMP		R6, #0x00
	BNE		%33
3	EORS	R0,R0,R0	;failure
	B		%5
4	MOV		R0, R4
	BL		sdcard_set_initialized
	MOVS	R0, #0x01	;success
5	POP		{PC,R4-R7}
	ENDP

	LTORG

	ROUT
sdcard_cmd	PROC
	;R0: sdcard control block address
	;R1: command address
	PUSH	{LR,R4-R6}
	LDR		R4, [R0, #SDCARDCB_SPI_ADDR_OFFSET]
	MOV		R5, R1
	EORS	R6,R6,R6	;loop counter
0	LDRB	R1, [R5,R6]
	MOV		R0, R4
	BL		spi_TXD_set
	MOV		R0, R4
	BL		spi_READY_event_wait_clear
	MOV		R0, R4
	BL		spi_RXD_get
	ADDS	R6, #0x01
	CMP		R6, #6
	BNE		%0
	POP		{PC,R4-R6}
	ENDP
	
	ROUT
sdcard_write_byte	PROC
	;R0: sdcard control block address
	;R1: byte of data
	PUSH	{LR,R4}
	LDR		R4, [R0, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R0, =10
	BL		nrf_delay_mcs
	MOV		R0, R4
	BL		spi_TXD_set
	MOV		R0, R4
	BL		spi_READY_event_wait_clear
	MOV		R0, R4
	BL		spi_RXD_get
	POP		{PC,R4}
	ENDP

	ROUT
sdcard_read_response_byte	PROC
	;R0: sdcard control block address
	PUSH	{LR,R4-R6}
	MOV		R6, R0
	MOVS	R5, #0xFF
	MOVS	R4, #0x80
0	CMP		R5, #0x00
	BEQ		%1
	MOV		R0, R6
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	SUBS	R5, #0x01
	TST		R0, R4
	BNE		%0
1	POP		{PC,R4-R6}
	ENDP

sdcard_read_4_bytes	PROC
	;R0: sdcard control block address
	PUSH	{LR,R4,R5}
	MOV		R4, R0
	LDR		R5, =REPONSE_TAIL
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	STRB	R0, [R5]
	MOV		R0, R4
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	STRB	R0, [R5, #0x01]
	MOV		R0, R4
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	STRB	R0, [R5, #0x02]
	MOV		R0, R4
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	STRB	R0, [R5, #0x03]
	POP		{PC,R4,R5}
	ENDP

sdcard_read_R7	PROC
	;R0: sdcard control block address
	B		sdcard_read_4_bytes
	ENDP

sdcard_read_R1	PROC
	;R0: sdcard control block address
	PUSH	{LR}
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	LDR		R1, =R1_RESPONSE
	STRB	R0, [R1]
	POP		{PC}
	ENDP

	ROUT
sdcard_read_R2	PROC
	;R0: sdcard control block address
	PUSH	{LR,R4-R6}
	MOV		R4, R0
	LDR		R5, =R2_RESPONSE
	MOVS	R6, #0x00	;loop counter
0	MOV		R0, R4
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	STRB	R0, [R5, R6]
	ADDS	R6, #0x01
	CMP		R6, #0x11
	BNE		%0
	POP		{PC,R4-R6}
	ENDP

sdcard_read_crc	PROC
	;R0: sdcard control block address
	PUSH	{LR}
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	LDR		R1, =CRC
	STRB	R0, [R1]
	POP		{PC}
	ENDP

sdcard_read_R3	PROC
	;R0: sdcard control block address
	B		sdcard_read_4_bytes
	ENDP

	ROUT
sdcard_cmd0	PROC
	PUSH	{LR,R4}
	;R0: sdcard control block address
	MOV		R4, R0
	LDR		R0, [R4, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R0, R1]
	BL		gpio_set_low
	;MOVS	R1, #0xFF
	;BL		sdcard_write_byte
	MOV		R0, R4
	LDR		R1, =CMD0
	BL		sdcard_cmd
	MOV		R0, R4
	BL		sdcard_read_response_byte
	POP		{PC,R4}
	ENDP

	ROUT
sdcard_cmd1	PROC
	PUSH	{LR,R4,R5}
	;R0: sdcard control block address
	MOV		R4, R0
	LDR		R0, [R4, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R0, R1]
	BL		gpio_set_low
	MOV		R0, R4
	LDR		R1, =CMD1
	BL		sdcard_cmd
	MOV		R0, R4
	BL		sdcard_read_response_byte
	MOV		R5, R0	;save return value
	MOVS	R1, #0x01
	MVNS	R1, R1
	TST		R0, R1
	BNE		%0
	MOVS	R0, R4
	BL		sdcard_read_R1
	MOVS	R0, R5	;restore return value
0	POP		{PC,R4,R5}
	ENDP

	ROUT
sdcard_cmd8	PROC
	PUSH	{LR,R4,R5}
	;R0: sdcard control block address
	MOV		R4, R0
	LDR		R0, [R4, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R0, R1]
	BL		gpio_set_low
	MOV		R0, R4
	LDR		R1, =CMD8
	BL		sdcard_cmd
	MOV		R0, R4
	BL		sdcard_read_response_byte
	MOV		R5, R0	;save return value
	MOVS	R1, #0x01
	MVNS	R1, R1
	TST		R0, R1
	BNE		%0
	MOVS	R0, R4
	BL		sdcard_read_R7
	MOVS	R0, R5	;restore return value
0	POP		{PC,R4,R5}
	ENDP

	ROUT
sdcard_cmd13	PROC
	PUSH	{LR,R4,R5}
	;todo: my currently used card responses with 0x09, i will not use this routine
	;R0: spi control block address
	MOV		R4, R0
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R0, R1]
	BL		gpio_set_low
	LDR		R0, =CMD13
	BL		sdcard_cmd
	MOV		R0, R4
	BL		sdcard_read_response_byte
	MOV		R5, R0	;save return value
	MOVS	R1, #0x01
	MVNS	R1, R1
	TST		R0, R1
	BNE		%0
	MOVS	R0, R4
	BL		sdcard_read_R2
	MOVS	R0, R5	;restore return value
0	POP		{PC,R4,R5}
	ENDP

	ROUT
sdcard_cmd16	PROC
	PUSH	{LR,R4,R5}
	;R0: spi control block address
	;R1: block size
	MOV		R4,R0
	MOV		R5,R1
	LDR		R0, [R4, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R0, R1]
	BL		gpio_set_low
	LDR		R1, =CMD16
	STRB	R5, [R1,#4]
	LSRS	R5, #8
	STRB	R5, [R1,#3]
	LSRS	R5, #8
	STRB	R5, [R1,#2]
	LSRS	R5, #8
	STRB	R5, [R1,#1]
	MOV		R0, R4
	BL		sdcard_cmd
	MOV		R0, R4
	BL		sdcard_read_response_byte
	MOV		R5, R0	;save return value
	MOVS	R1, #0x01
	MVNS	R1, R1
	TST		R0, R1
	BNE		%0
	MOVS	R0, R4
	BL		sdcard_read_R1
	MOVS	R0, R5	;restore return value
0	POP		{PC,R4,R5}
	ENDP

	ROUT
sdcard_cmd17	PROC
	EXPORT	sdcard_cmd17
 	PUSH	{LR,R4-R6}
	;R0: sdcard control block address
	;R1: Data address is in byte units in a Standard Capacity SD Memory Card
	;R2: destination address (512 bytes should be reserved!)
	;returns success (1)/faulure (0) in R0, the last received byte in R1 on success
	MOV		R4, R0
	MOV		R5, R2
	MOV		R6, R1
	LDR		R0, [R4, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R0, R1]
	BL		gpio_set_low
	LDR		R1, =CMD17
	STRB	R6, [R1,#4]
	LSRS	R6, #8
	STRB	R6, [R1,#3]
	LSRS	R6, #8
	STRB	R6, [R1,#2]
	LSRS	R6, #8
	STRB	R6, [R1,#1]
	MOV		R0, R4
	BL		sdcard_cmd
	MOV		R0, R4
	BL		sdcard_read_response_byte
	CMP		R0, #0x00
	BNE		%0
	MOV		R0, R4
	MOV		R1, R5
	BL		sdcard_read_block
	CMP		R0, #0x00
	BEQ		%0	;faulure
	MOV		R5, R1	;save last byte
	MOV		R0, R4
	BL		sdcard_read_crc
	MOV		R1, R5	;restore last data byte
	MOVS	R0, #0x01
0	POP		{PC,R4-R6}
	ENDP

	ROUT
sdcard_cmd24	PROC
	EXPORT	sdcard_cmd24
 	PUSH	{LR,R4-R7}
	;R0: sdcard control block address
	;R1: Data address is in byte units in a Standard Capacity SD Memory Card and in block (512 Byte) units in a High Capacity SD Memory Card.
	;R2: source address (512 bytes of data will be transmitted)
	MOV		R4, R0
	MOV		R5, R2
	MOV		R6, R1
	[ :DEF:__DEBUG__
		BL	uart_send_text_dword
		LDR	R0, =TEXT_CMD24_ARG
		LDR	R1, =TEXT_CMD24_ARG_END
		MOV	R2, R4
		BL	uart_send_text_dword
		LDR	R0, =TEXT_CMD24_ARG
		LDR	R1, =TEXT_CMD24_ARG_END
		MOV	R2, R6
		BL	uart_send_text_dword
		LDR	R0, =TEXT_CMD24_ARG
		LDR	R1, =TEXT_CMD24_ARG_END
		MOV	R2, R5
		BL	uart_send_text_dword
	]
	LDR		R0, [R4, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R0, R1]
	BL		gpio_set_low
	LDR		R1, =CMD24
	STRB	R6, [R1,#4]
	LSRS	R6, #8
	STRB	R6, [R1,#3]
	LSRS	R6, #8
	STRB	R6, [R1,#2]
	LSRS	R6, #8
	STRB	R6, [R1,#1]
	MOV		R0, R4
	BL		sdcard_cmd
	EORS	R6,R6,R6	;loop counter
0	CMP		R6, #0x10
	BEQ		%1	;failure
	MOV		R0, R4
	BL		sdcard_read_R1
	[ :DEF:__DEBUG__
		MOV	R7, R0
		MOV	R2, R0
		LDR	R0, =TEXT_CMD24_read_R1
		LDR	R1, =TEXT_CMD24_read_R1_END
		BL	uart_send_text_byte
		MOV	R0, R7
	]
	ADDS	R6, #0x01
	CMP		R0, #0x00
	BNE		%0
	MOV		R0, R4
	MOV		R1, R5
	BL		sdcard_write_block
	[ :DEF:__DEBUG__
		MOV	R7, R0
		MOV	R2, R0
		LDR	R0, =TEXT_CMD24_write_block
		LDR	R1, =TEXT_CMD24_write_block_END
		BL	uart_send_text_byte
		MOV	R0, R7
	]
	CMP		R0, #0x00
	BNE		%2
1	EORS	R0,R0,R0
2	POP		{PC,R4-R7}
	ENDP

	ROUT
sdcard_acmd41	PROC
	EXPORT	sdcard_acmd41
	PUSH	{LR,R4,R5}
	;R0: sdcard control block address
	MOV		R4, R0
	LDR		R0, [R4, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R0, R1]
	BL		gpio_set_low
	MOV		R0, R4
	BL		sdcard_cmd55
	MOVS	R1, #0x01
	MVNS	R1, R1
	TST		R0, R1
	BNE		%1
	MOV		R0, R4
	LDR		R1, =ACMD41
	BL		sdcard_cmd
	MOV		R0, R4
	BL		sdcard_read_response_byte
	MOV		R5, R0	;save return value
	MOVS	R1, #0x01
	MVNS	R1, R1
	TST		R0, R1
	BNE		%1
	MOV		R0, R4
	BL		sdcard_read_R3
	MOVS	R0, R5	;restore return value
1	POP		{PC,R4,R5}
	ENDP

	ROUT
sdcard_cmd55	PROC
	PUSH	{LR,R4,R5}
	;R0: sdcard control block address
	MOV		R4, R0
	LDR		R1, =CMD55
	BL		sdcard_cmd
	MOV		R0, R4
	BL		sdcard_read_response_byte
	MOV		R5, R0	;save return value
	MOVS	R1, #0x01
	MVNS	R1, R1
	TST		R0, R1
	BNE		%1
	MOV		R0, R4
	BL		sdcard_read_R1
	MOVS	R0, R5	;restore return value
1	POP		{PC,R4,R5}
	ENDP

	ROUT
sdcard_cmd58	PROC
	PUSH	{LR,R4,R5}
	;R0: sdcard control block address
	MOV		R4, R0
	LDR		R0, [R4, #SDCARDCB_SPI_ADDR_OFFSET]
	LDR		R1, =SPICB_CS_GPIO_NUMBER_OFFSET
	LDRB	R0, [R0, R1]
	BL		gpio_set_low
	MOV		R0, R4
	LDR		R1, =CMD58
	BL		sdcard_cmd
	MOV		R0, R4
	BL		sdcard_read_response_byte
	MOV		R5, R0	;save return value
	MOVS	R1, #0x01
	MVNS	R1, R1
	TST		R0, R1
	BNE		%1
	MOV		R0, R4
	BL		sdcard_read_R1
	MOVS	R0, R5	;restore return value
1	POP		{PC,R4,R5}
	ENDP

	ROUT
sdcard_read_block	PROC
	PUSH	{LR,R4-R7}
	;R0: sdcard control block address
	;R1: destination address (512 bytes should be reserved!)
	;returns success (1)/faulure (0) in R0, the last received byte in R1 on success
	MOV		R7, R0
	MOV		R4, R1
	MOVS	R6, #0x00	;loop counter
0	CMP		R6, #0xFF
	BEQ		%2
	MOV		R0, R7
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	ADDS	R6, #0x01
	CMP		R0, #0xFE
	BNE		%0
	LDR		R6, =512
	EORS	R5,R5,R5
1	MOV		R0, R7
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	STRB	R0, [R4, R5]
	ADDS	R5, #0x01
	CMP		R5, R6
	BNE		%1
	MOV		R1, R0
	MOVS	R0, #0x01	;success
	B		%3
2	EORS	R0,R0,R0	;faulure
3	POP		{PC,R4-R7}
	ENDP

	ROUT
sdcard_write_block	PROC
	PUSH	{LR,R4-R7}
	MOV		R7, R8
	PUSH	{R7}
	;R0: sdcard control block address
	;R1: data address (512 bytes)
	MOV		R7, R0
	MOV		R4, R1
	MOVS	R1, #START_TOKEN
	BL		sdcard_write_byte
	LDR		R6, =512
	EORS	R5,R5,R5
1	MOV		R0, R7
	LDRB	R1, [R4, R5]
	BL		sdcard_write_byte
	ADDS	R5, #0x01
	CMP		R5, R6
	BNE		%1
	;crc
	MOV		R0, R7
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	;read until data response token
	EORS	R6,R6,R6	;loop counter
2	CMP		R6, #0xFF
	BEQ		%4	;failed
	MOV		R0, R7
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	[ :DEF:__DEBUG__
		MOV	R8, R0
		MOV	R2, R0
		LDR	R0, =TEXT_write_block_write_byte
		LDR	R1, =TEXT_write_block_write_byte_END
		BL	uart_send_text_byte
		MOV	R0, R8
	]
	ADDS	R6, #0x01
	MOVS	R1, #DATA_RESPONSE_TOKEN_MASK
	ANDS	R1, R0
	CMP		R1, #DATA_RESPONSE_TOKEN
	BNE		%2
	;data response token read. check status
	CMP		R0, #DATA_RESPONSE_TOKEN_STATUS_ACCEPTED
	BNE		%10	;failed
	;keep reading while 0x00 (busy)
	EORS	R6,R6,R6	;loop counter
3	CMP		R6, #0xFF
	BEQ		%11	;failed
	LDR		R0, =1000
	BL		nrf_delay_mcs
	MOV		R0, R7
	MOVS	R1, #0xFF
	BL		sdcard_write_byte
	ADDS	R6, #0x01
	[ :DEF:__DEBUG__
		MOV	R8, R0
		MOV	R2, R0
		LDR		R0, =TEXT_wait_busy
		LDR		R1, =TEXT_wait_busy_END
		BL	uart_send_text_byte
		MOV	R0, R8
	]
	CMP		R0, #0x00
	BEQ		%3
	MOVS	R0, #0x01	;success
	B		%5
10	NOP
	[ :DEF:__DEBUG__
		LDR		R0, =TEXT_write_failed
		LDR		R1, =TEXT_write_failed_END
		MOVS	R2, #10
		BL	uart_send_text_byte
	]
11	NOP
	[ :DEF:__DEBUG__
		LDR		R0, =TEXT_write_failed
		LDR		R1, =TEXT_write_failed_END
		MOVS	R2, #11
		BL	uart_send_text_byte
	]
4	NOP
	[ :DEF:__DEBUG__
		LDR		R0, =TEXT_write_failed
		LDR		R1, =TEXT_write_failed_END
		MOVS	R2, #4
		BL	uart_send_text_byte
	]
	EORS	R0,R0,R0	;faulure
5	POP	{R7}
	MOV		R8, R7
	POP		{PC,R4-R7}
	ENDP

sdcard_get_response_address	PROC
	EXPORT	sdcard_get_response_address
	LDR		R0, =REPONSE_TAIL
	BX		LR
	ENDP

;******************

DATA_RESPONSE_TOKEN_MASK				EQU	0xF1
DATA_RESPONSE_TOKEN						EQU 0xE1
DATA_RESPONSE_TOKEN_STATUS_ACCEPTED		EQU	0xE5
DATA_RESPONSE_TOKEN_STATUS_CRC_ERROR	EQU	0xEB
DATA_RESPONSE_TOKEN_STATUS_WRITE_ERROR	EQU	0xED

;sdcard control block structure
SDCARDCB_STATE_OFFSET			EQU	0x00
SDCARDCB_SPI_ADDR_OFFSET		EQU	0x04
	
SDCARDCB_STATE_INITIALIZED_MASK	EQU	0x01

START_TOKEN						EQU	0xFE

	EXTERN	SPICB_CS_GPIO_NUMBER_OFFSET
	EXTERN	SPICB_MOSI_GPIO_NUMBER_OFFSET

	EXTERN	gpio_set_high
	EXTERN	gpio_set_low

	[ :DEF:__DEBUG__
		EXTERN	uart_send_text_byte
		EXTERN	uart_send_text_dword
		EXTERN	uart_send
	]


	EXTERN	spi_TXD_set
	EXTERN	spi_RXD_get
	EXTERN	spi_READY_event_wait
	EXTERN	spi_READY_event_wait_clear

	EXTERN	nrf_delay_mcs

	ALIGN
	AREA    data, DATA
REPONSE_TAIL			SPACE	0x04
R2_RESPONSE				SPACE	0x11	;136 bits
R1_RESPONSE				SPACE	0x01
CRC						SPACE	0x01

	[ :DEF:__DEBUG__
TEXT_CMD0					DCB	"cmd0 ret:"
TEXT_CMD0_END
TEXT_CMD41					DCB	"cmd41 ret:"
TEXT_CMD41_END
TEXT_CMD24_ARG				DCB	"cmd24 arg:"
TEXT_CMD24_ARG_END
TEXT_CMD24_read_R1			DCB	"cmd24 read R1 ret:"
TEXT_CMD24_read_R1_END
TEXT_CMD24_write_block		DCB	"cmd24 write block ret:"
TEXT_CMD24_write_block_END
TEXT_write_failed			DCB	"write failed label:"
TEXT_write_failed_END
TEXT_write_block_write_byte	DCB	"write byte:"
TEXT_write_block_write_byte_END
TEXT_wait_busy				DCB	"wait_busy:"
TEXT_wait_busy_END
	]


;Command CMD16: 01 010000 00000000 00000000 00000000 00000000 0101010 1
CMD16		DCB	0x50, 0x00, 0x00, 0x00, 0x00, 0x55
;Command CMD17: 01 010001 00000000 00000000 00000000 00000000 0101010 1
;				01 010001 00000000 00000000 00000000 00000000 "0101010" 1
CMD17		DCB	0x51, 0x00, 0x00, 0x00, 0x00, 0x55
;Command CMD24: 01 011000 00000000 00000000 00000000 00000000 0101010 1
CMD24		DCB	0x58, 0x00, 0x00, 0x00, 0x00, 0x55

	ALIGN
	AREA    commands, DATA, READONLY

;command CMD0: 01 000000 00000000 00000000 00000000 00000000 1001010 1
CMD0		DCB	0x40, 0x00, 0x00, 0x00, 0x00, 0x95
;command CMD1: 01 000001 00000000 00000000 00000000 00000000 1001010 1
CMD1		DCB	0x41, 0x00, 0x00, 0x00, 0x00, 0x95
;Command CMD8: 01 001000 00000000 00000000 00000001 10101010 1000011 1
CMD8		DCB	0x48, 0x00, 0x00, 0x01, 0xAA, 0x87
;Command CMD13: 01 001101 00000000 00000000 00000001 10101010 1000011 1
CMD13		DCB	0x4D, 0x00, 0x00, 0x00, 0x00, 0x95
;Command ACMD41: 01 101001 01010001 00000000 00000000 00000000 0000000 1
ACMD41		DCB	0x69, 0x40, 0x00, 0x00, 0x00, 0xFF
;Command CMD55 01 110111 00000000 00000000 00000000 00000000 0000000 1
CMD55		DCB	0x77, 0x00, 0x00, 0x00, 0x00, 0x95
;Command CMD58: 01 111010 00000000 00000000 00000000 00000000 0111010 1
CMD58		DCB	0x7A, 0x00, 0x00, 0x00, 0x00, 0x95

	END
