	AREA radio_utilities, CODE, READONLY

radio_init	PROC
	EXPORT	radio_init
	;R0: radio control block address
	PUSH	{LR,R4}
	MOV		R4, R0
	LDR		R2, [R4, #RADIOCB_TXPOWER_OFFSET]
	BL		radio_TXPOWER_set
	LDR		R0, [R4, #RADIOCB_FREQ_OFFSET]
	BL		radio_FREQUENCY_write
	LDR		R2, [R4, #RADIOCB_MODE_OFFSET]
	BL		radio_MODE_set
	LDR		R0, [R4, #RADIOCB_PREFIX0_OFFSET]
	BL		radio_PREFIX0_write
	LDR		R0, [R4, #RADIOCB_PREFIX1_OFFSET]
	BL		radio_PREFIX1_write
	LDR		R0, [R4, #RADIOCB_BASE0_OFFSET]
	BL		radio_BASE0_write
	LDR		R0, [R4, #RADIOCB_BASE1_OFFSET]
	BL		radio_BASE1_write
	LDRB	R0, [R4, #RADIOCB_TXADDRESS_OFFSET]
	BL		radio_TXADDRESS_write
	LDRB	R0, [R4, #RADIOCB_RXADDRESSES_OFFSET]
	BL		radio_RXADDRESSES_write
	LDR		R0, [R4, #RADIOCB_PCNF0_OFFSET]
	BL		radio_PCNF0_write
	LDR		R0, [R4, #RADIOCB_PCNF1_OFFSET]
	BL		radio_PCNF1_write
	LDRH	R0, [R4, #RADIOCB_CRCCNF_OFFSET]
	BL		radio_CRCCNF_set_bytes_addr_include
	LDR		R0, [R4, #RADIOCB_CRCINIT_OFFSET]
	BL		radio_CRCINIT_write
	LDR		R0, [R4, #RADIOCB_CRCPOLY_OFFSET]
	BL		radio_CRCPOLY_write
	MOV		R0, R4
	ADDS	R0, #PACKET_BUFFER_OFFSET
	BL		radio_PACKETPTR_write
	POP		{PC,R4}
	ENDP

;Tasks
;RADIO_TXEN_OFFSET  			EQU		0x000 ;Enable RADIO in TX mode
radio_TXEN_task_enable	PROC
	EXPORT	radio_TXEN_task_enable
	MOVS	R0, #0x01
	B		radio_TXEN_task
	ENDP

radio_TXEN_task_disable	PROC	
	EXPORT	radio_TXEN_task_disable
	EORS	R0,R0,R0
	B		radio_TXEN_task
	ENDP
		
radio_TXEN_task	PROC
	;R0: task value (1 to enable, 0 to disable)
	LDR		R2, =RADIO_BASE_ADDRESS
	LDR		R1, =RADIO_TXEN_OFFSET
	ADDS	R2, R1
	STR		R0, [R2]
	BX		LR
	ENDP

;RADIO_RXEN_OFFSET  			EQU		0x004 ;Enable RADIO in RX mode
radio_RXEN_task_enable	PROC
	EXPORT	radio_RXEN_task_enable
	MOVS	R0, #0x01
	B		radio_RXEN_task
	ENDP

radio_RXEN_task_disable	PROC
	EXPORT	radio_RXEN_task_disable
	EORS	R0,R0,R0
	B		radio_RXEN_task
	ENDP
		
radio_RXEN_task	PROC
	;R0: task value (1 to enable, 0 to disable)
	LDR		R2, =RADIO_BASE_ADDRESS
	LDR		R1, =RADIO_RXEN_OFFSET
	ADDS	R2, R1
	STR		R0, [R2]
	BX		LR
	ENDP

;RADIO_START_OFFSET  		EQU		0x008 ;Start RADIO
radio_START	PROC
	EXPORT	radio_START
	LDR		R1, =RADIO_START_OFFSET
	B		radio_write_one
	ENDP

;RADIO_STOP_OFFSET  			EQU		0x00C ;Stop RADIO
radio_STOP	PROC
	EXPORT	radio_STOP
	LDR		R1, =RADIO_STOP_OFFSET
	B		radio_write_one
	ENDP

;RADIO_DISABLE_OFFSET  		EQU		0x010 ;Disable RADIO
radio_DISABLE	PROC
	EXPORT	radio_DISABLE
	LDR		R1, =RADIO_DISABLE_OFFSET
	B		radio_write_one
	ENDP

;RADIO_RSSISTART_OFFSET  	EQU		0x014 ;Start the RSSI and take one single sample of the receive signal strength
radio_RSSISTART	PROC	;Start the RSSI and take one single sample of the receive signal strength
	EXPORT	radio_RSSISTART
	LDR		R1, =RADIO_RSSISTART_OFFSET
	B		radio_write_one
	ENDP

;RADIO_RSSISTOP_OFFSET  		EQU		0x018 ;Stop the RSSI measurement
radio_RSSISTOP	PROC	;Stop the RSSI measurement
	EXPORT	radio_RSSISTOP
	LDR		R1, =RADIO_RSSISTOP_OFFSET
	B		radio_write_one
	ENDP

;RADIO_BCSTART_OFFSET  		EQU		0x01C ;Start the bit counter
radio_BCSTART	PROC	;Start the bit counter
	EXPORT	radio_BCSTART
	LDR		R1, =RADIO_BCSTART_OFFSET
	B		radio_write_one
	ENDP

;RADIO_BCSTOP_OFFSET  		EQU		0x020 ;Stop the bit counter
radio_BCSTOP	PROC	;Stop the bit counter
	EXPORT	radio_BCSTOP
	LDR		R1, =RADIO_BCSTOP_OFFSET
	B		radio_write_one
	ENDP

;Events

;RADIO_READY_OFFSET  		EQU		0x100 ;RADIO has ramped up and is ready to be started
radio_READY_event_read	PROC
	EXPORT	radio_READY_event_read
	LDR		R1, =RADIO_READY_OFFSET
	B		radio_read
	ENDP

radio_READY_event_clear	PROC
	EXPORT	radio_READY_event_clear
	LDR		R1, =RADIO_READY_OFFSET
	B		radio_write_zero
	ENDP

radio_READY_event_wait PROC
	EXPORT	radio_READY_event_wait
	LDR		R1, =RADIO_READY_OFFSET
	B		radio_event_wait
	ENDP

;RADIO_ADDRESS_OFFSET  		EQU		0x104 ;Address sent or received
radio_ADDRESS_event_read	PROC	;Address sent or received
	EXPORT	radio_ADDRESS_event_read
	LDR		R1, =RADIO_ADDRESS_OFFSET
	B		radio_read
	ENDP
		
radio_ADDRESS_event_clear	PROC
	EXPORT	radio_ADDRESS_event_clear
	LDR		R1, =RADIO_ADDRESS_OFFSET
	B		radio_write_zero
	ENDP

;RADIO_PAYLOAD_OFFSET  		EQU		0x108 ;Packet payload sent or received
radio_PAYLOAD_event_read	PROC	;Packet payload sent or received
	EXPORT	radio_PAYLOAD_event_read
	LDR		R1, =RADIO_PAYLOAD_OFFSET
	B		radio_read
	ENDP
		
radio_PAYLOAD_event_clear	PROC
	EXPORT	radio_PAYLOAD_event_clear
	LDR		R1, =RADIO_PAYLOAD_OFFSET
	B		radio_write_zero
	ENDP

;RADIO_END_OFFSET  			EQU		0x10C ;Packet sent or received
radio_END_event_read	PROC	;Packet sent or received
	EXPORT	radio_END_event_read
	LDR		R1, =RADIO_END_OFFSET
	B		radio_read
	ENDP
		
radio_END_event_clear	PROC
	EXPORT	radio_END_event_clear
	LDR		R1, =RADIO_END_OFFSET
	B		radio_write_zero
	ENDP

radio_END_event_wait PROC
	EXPORT	radio_END_event_wait
	LDR		R1, =RADIO_END_OFFSET
	B		radio_event_wait
	ENDP

;RADIO_DISABLED_OFFSET 	 	EQU		0x110 ;RADIO has been disabled
radio_DISABLED_event_read	PROC	;RADIO has been disabled
	EXPORT	radio_DISABLED_event_read
	LDR		R1, =RADIO_DISABLED_OFFSET
	B		radio_read
	ENDP
		
radio_DISABLED_event_clear	PROC
	EXPORT	radio_DISABLED_event_clear
	LDR		R1, =RADIO_DISABLED_OFFSET
	B		radio_write_zero
	ENDP

radio_DISABLED_event_set	PROC
	EXPORT	radio_DISABLED_event_set
	LDR		R1, =RADIO_DISABLED_OFFSET
	B		radio_write_one
	ENDP

radio_DISABLED_event_wait PROC
	EXPORT	radio_DISABLED_event_wait
	LDR		R1, =RADIO_DISABLED_OFFSET
	B		radio_event_wait
	ENDP

;RADIO_DEVMATCH_OFFSET 	 	EQU		0x114 ;A device address match occurred on the last received packet
radio_DEVMATCH_event_read	PROC	;A device address match occurred on the last received packet
	EXPORT	radio_DEVMATCH_event_read
	LDR		R1, =RADIO_DEVMATCH_OFFSET
	B		radio_read
	ENDP
		
radio_DEVMATCH_event_clear	PROC
	EXPORT	radio_DEVMATCH_event_clear
	LDR		R1, =RADIO_DEVMATCH_OFFSET
	B		radio_write_zero
	ENDP

;RADIO_DEVMISS_OFFSET  		EQU		0x118 ;No device address match occurred on the last received packet
radio_DEVMISS_event_read	PROC	;No device address match occurred on the last received packet
	EXPORT	radio_DEVMISS_event_read
	LDR		R1, =RADIO_DEVMISS_OFFSET
	B		radio_read
	ENDP
		
radio_DEVMISS_event_clear	PROC
	EXPORT	radio_DEVMISS_event_clear
	LDR		R1, =RADIO_DEVMISS_OFFSET
	B		radio_write_zero
	ENDP


;RADIO_RSSIEND_OFFSET  		EQU		0x11C ;Sampling of receive signal strength complete. 
										  ;A new RSSI sample is ready for readout from the RSSISAMPLE register.
radio_RSSIEND_event_read	PROC	;Sampling of receive signal strength complete. 
										;;A new RSSI sample is ready for readout from the RSSISAMPLE register.
	EXPORT	radio_RSSIEND_event_read
	LDR		R1, =RADIO_RSSIEND_OFFSET
	B		radio_read
	ENDP
		
radio_RSSIEND_event_clear	PROC
	EXPORT	radio_RSSIEND_event_clear
	LDR		R1, =RADIO_RSSIEND_OFFSET
	B		radio_write_zero
	ENDP

;RADIO_BCMATCH_OFFSET  		EQU		0x128 ;Bit counter reached bit count value specified in the BCC register
radio_BCMATCH_event_read	PROC	;Bit counter reached bit count value specified in the BCC register
	EXPORT	radio_BCMATCH_event_read
	LDR		R1, =RADIO_BCMATCH_OFFSET
	B		radio_read
	ENDP
		
radio_BCMATCH_event_clear	PROC
	EXPORT	radio_BCMATCH_event_clear
	LDR		R1, =RADIO_BCMATCH_OFFSET
	B		radio_write_zero
	ENDP


;Registers

;RADIO_SHORTS_OFFSET  		EQU		0x200 ;Shortcut register
radio_SHORTS_set	PROC
	EXPORT	radio_SHORTS_set
	;R0: shortcuts value
	LDR		R1, =RADIO_SHORTS_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_INTENSET_OFFSET 	 	EQU		0x304 ;Enable interrupt
;RADIO_INTENCLR_OFFSET 	 	EQU		0x308 ;Disable interrupt
radio_READY_event_IRQ_enable	PROC
	EXPORT	radio_READY_event_IRQ_enable
	LDR		R1, =RADIO_INTENSET_OFFSET
	MOVS	R2, #0x00	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_READY_event_IRQ_disable	PROC
	EXPORT	radio_READY_event_IRQ_disable
	LDR		R1, =RADIO_INTENCLR_OFFSET
	MOVS	R2, #0x00	;shift left mask bit
	B		radio_shift_write
	ENDP
		
radio_ADDRESS_event_IRQ_enable	PROC
	EXPORT	radio_ADDRESS_event_IRQ_enable
	LDR		R1, =RADIO_INTENSET_OFFSET
	MOVS	R2, #0x01	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_ADDRESS_event_IRQ_disable	PROC
	EXPORT	radio_ADDRESS_event_IRQ_disable
	LDR		R1, =RADIO_INTENCLR_OFFSET
	MOVS	R2, #0x01	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_PAYLOAD_event_IRQ_enable	PROC
	EXPORT	radio_PAYLOAD_event_IRQ_enable
	LDR		R1, =RADIO_INTENSET_OFFSET
	MOVS	R2, #0x02	;shift left mask bit
	B		radio_shift_write
	ENDP
		
radio_PAYLOAD_event_IRQ_disable	PROC
	EXPORT	radio_PAYLOAD_event_IRQ_disable
	LDR		R1, =RADIO_INTENCLR_OFFSET
	MOVS	R2, #0x02	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_END_event_IRQ_enable	PROC
	EXPORT	radio_END_event_IRQ_enable
	LDR		R1, =RADIO_INTENSET_OFFSET
	MOVS	R2, #0x03	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_END_event_IRQ_disable	PROC
	EXPORT	radio_END_event_IRQ_disable
	LDR		R1, =RADIO_INTENCLR_OFFSET
	MOVS	R2, #0x03	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_DISABLED_event_IRQ_enable	PROC
	EXPORT	radio_DISABLED_event_IRQ_enable
	LDR		R1, =RADIO_INTENSET_OFFSET
	MOVS	R2, #0x04	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_DISABLED_event_IRQ_disable	PROC
	EXPORT	radio_DISABLED_event_IRQ_disable
	LDR		R1, =RADIO_INTENCLR_OFFSET
	MOVS	R2, #0x04	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_DEVMATCH_event_IRQ_enable	PROC
	EXPORT	radio_DEVMATCH_event_IRQ_enable
	LDR		R1, =RADIO_INTENSET_OFFSET
	MOVS	R2, #0x05	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_DEVMATCH_event_IRQ_disable	PROC
	EXPORT	radio_DEVMATCH_event_IRQ_disable
	LDR		R1, =RADIO_INTENCLR_OFFSET
	MOVS	R2, #0x05	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_DEVMISS_event_IRQ_enable	PROC
	EXPORT	radio_DEVMISS_event_IRQ_enable
	LDR		R1, =RADIO_INTENSET_OFFSET
	MOVS	R2, #0x06	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_DEVMISS_event_IRQ_disable	PROC
	EXPORT	radio_DEVMISS_event_IRQ_disable
	LDR		R1, =RADIO_INTENCLR_OFFSET
	MOVS	R2, #0x06	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_RSSIEND_event_IRQ_enable	PROC
	EXPORT	radio_RSSIEND_event_IRQ_enable
	LDR		R1, =RADIO_INTENSET_OFFSET
	MOVS	R2, #0x07	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_RSSIEND_event_IRQ_disable	PROC
	EXPORT	radio_RSSIEND_event_IRQ_disable
	LDR		R1, =RADIO_INTENCLR_OFFSET
	MOVS	R2, #0x07	;shift left mask bit
	B		radio_shift_write
	ENDP
		
radio_BCMATCH_event_IRQ_enable	PROC
	EXPORT	radio_BCMATCH_event_IRQ_enable
	LDR		R1, =RADIO_INTENSET_OFFSET
	MOVS	R2, #0x0A	;shift left mask bit
	B		radio_shift_write
	ENDP

radio_BCMATCH_event_IRQ_disable	PROC
	EXPORT	radio_BCMATCH_event_IRQ_disable
	LDR		R1, =RADIO_INTENCLR_OFFSET
	MOVS	R2, #0x0A	;shift left mask bit
	B		radio_shift_write
	ENDP

;RADIO_CRCSTATUS_OFFSET	 	EQU		0x400 ;CRC status
radio_CRCSTATUS_read	PROC
	EXPORT	radio_CRCSTATUS_read
	LDR		R1, =RADIO_CRCSTATUS_OFFSET
	B		radio_read
	ENDP

;RADIO_RXMATCH_OFFSET  		EQU		0x408 ;Received address
radio_RXMATCH_read	PROC
	EXPORT	radio_RXMATCH_read
	LDR		R1, =RADIO_RXMATCH_OFFSET
	B		radio_read
	ENDP

;RADIO_RXCRC_OFFSET  		EQU		0x40C ;CRC field of previously received packet
radio_RXCRC_read	PROC
	EXPORT	radio_RXCRC_read
	LDR		R1, =RADIO_RXCRC_OFFSET
	B		radio_read
	ENDP

;RADIO_DAI_OFFSET  			EQU		0x410 ;Device address match index
radio_DAI_read	PROC
	EXPORT	radio_DAI_read
	LDR		R1, =RADIO_DAI_OFFSET
	B		radio_read
	ENDP

;RADIO_PACKETPTR_OFFSET 		EQU		0x504 ;Packet pointer
radio_PACKETPTR_read	PROC
	EXPORT	radio_PACKETPTR_read
	LDR		R1, =RADIO_PACKETPTR_OFFSET
	B		radio_read
	ENDP

radio_PACKETPTR_write	PROC
	EXPORT	radio_PACKETPTR_write
	;R0: value to write
	LDR		R1, =RADIO_PACKETPTR_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_FREQUENCY_OFFSET 	 	EQU		0x508 ;Frequency
;[0..100] Radio channel frequency
;Frequency = 2400 + FREQUENCY (MHz).
radio_FREQUENCY_write	PROC
	EXPORT	radio_FREQUENCY_write
	;R0: value to write
	LDR		R1, =RADIO_FREQUENCY_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_TXPOWER_OFFSET  		EQU		0x50C ;Output power
radio_TXPOWER_set_Pos4dBm	PROC
	EXPORT	radio_TXPOWER_set_Pos4dBm
	MOVS	R2, #RADIO_POWER_Pos4dBm
	B		radio_TXPOWER_set
	ENDP
radio_TXPOWER_set_0dBm	PROC
	EXPORT	radio_TXPOWER_set_0dBm
	MOVS	R2, #RADIO_POWER_0dBm
	B		radio_TXPOWER_set
	ENDP
radio_TXPOWER_set_Neg4dBm	PROC
	EXPORT	radio_TXPOWER_set_Neg4dBm
	MOVS	R2, #RADIO_POWER_Neg4dBm
	B		radio_TXPOWER_set
	ENDP
radio_TXPOWER_set_Neg8dBm	PROC
	EXPORT	radio_TXPOWER_set_Neg8dBm
	MOVS	R2, #RADIO_POWER_Neg8dBm
	B		radio_TXPOWER_set
	ENDP
radio_TXPOWER_set_Neg12dBm	PROC
	EXPORT	radio_TXPOWER_set_Neg12dBm
	MOVS	R2, #RADIO_POWER_Neg12dBm
	B		radio_TXPOWER_set
	ENDP
radio_TXPOWER_set_Neg16dBm	PROC
	EXPORT	radio_TXPOWER_set_Neg16dBm
	MOVS	R2, #RADIO_POWER_Neg16dBm
	B		radio_TXPOWER_set
	ENDP
radio_TXPOWER_set_Neg20dBm	PROC
	EXPORT	radio_TXPOWER_set_Neg20dBm
	MOVS	R2, #RADIO_POWER_Neg20dBm
	B		radio_TXPOWER_set
	ENDP
radio_TXPOWER_set_Neg30dBm	PROC
	EXPORT	radio_TXPOWER_set_Neg30dBm
	MOVS	R2, #RADIO_POWER_Neg30dBm
	B		radio_TXPOWER_set
	ENDP
		
radio_TXPOWER_set	PROC
	;R2: power value
	LDR		R0, =RADIO_BASE_ADDRESS
	LDR		R1, =RADIO_TXPOWER_OFFSET
	STR		R2, [R0,R1]
	BX		LR
	ENDP

;RADIO_MODE_OFFSET  			EQU		0x510 ;Data rate and modulation
radio_MODE_set_Nrf_1Mbit	PROC
	EXPORT	radio_MODE_set_Nrf_1Mbit
	MOVS	R2, #RADIO_MODE_Nrf_1Mbit
	B		radio_MODE_set
	ENDP
radio_MODE_set_Nrf_2Mbit	PROC
	EXPORT	radio_MODE_set_Nrf_2Mbit
	MOVS	R2, #RADIO_MODE_Nrf_2Mbit
	B		radio_MODE_set
	ENDP
radio_MODE_set_Nrf_250Kbit	PROC
	EXPORT	radio_MODE_set_Nrf_250Kbit
	MOVS	R2, #RADIO_MODE_Nrf_250Kbit
	B		radio_MODE_set
	ENDP
radio_MODE_set_Ble_1Mbit	PROC
	EXPORT	radio_MODE_set_Ble_1Mbit
	MOVS	R2, #RADIO_MODE_Ble_1Mbit
	B		radio_MODE_set
	ENDP
		
radio_MODE_set	PROC
	;R2: power value
	LDR		R0, =RADIO_BASE_ADDRESS
	LDR		R1, =RADIO_MODE_OFFSET
	STR		R2, [R0,R1]
	BX		LR
	ENDP

;RADIO_PCNF0_OFFSET  		EQU		0x514 ;Packet configuration register 0
radio_PCNF0_write	PROC
	EXPORT	radio_PCNF0_write
	;R0: value to write
	LDR		R1, =RADIO_PCNF0_OFFSET
	B		radio_write_R0
	ENDP

radio_PCNF0_clear PROC
	EXPORT	radio_PCNF0_clear
	EORS	R0,R0,R0
	LDR		R1, =RADIO_PCNF0_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_PCNF1_OFFSET  		EQU		0x518 ;Packet configuration register 1
radio_PCNF1_write	PROC
	EXPORT	radio_PCNF1_write
	;R0: value to write
	LDR		R1, =RADIO_PCNF1_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_BASE0_OFFSET  		EQU		0x51C ;Base address 0
radio_BASE0_write	PROC
	EXPORT	radio_BASE0_write
	;R0: value to write
	LDR		R1, =RADIO_BASE0_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_BASE1_OFFSET  		EQU		0x520 ;Base address 1
radio_BASE1_write	PROC
	EXPORT	radio_BASE1_write
	;R0: value to write
	LDR		R1, =RADIO_BASE1_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_PREFIX0_OFFSET  		EQU		0x524 ;Prefixes bytes for logical addresses 0-3
radio_PREFIX0_write	PROC
	EXPORT	radio_PREFIX0_write
	;R0: value to write
	LDR		R1, =RADIO_PREFIX0_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_PREFIX1_OFFSET  		EQU		0x528 ;Prefixes bytes for logical addresses 4-7
radio_PREFIX1_write	PROC
	EXPORT	radio_PREFIX1_write
	;R0: value to write
	LDR		R1, =RADIO_PREFIX1_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_TXADDRESS_OFFSET  	EQU		0x52C ;Transmit address select
radio_TXADDRESS_write	PROC
	EXPORT	radio_TXADDRESS_write
	;R0: value to write
	LDR		R1, =RADIO_TXADDRESS_OFFSET
	B		radio_write_R0	
	ENDP

;RADIO_RXADDRESSES_OFFSET	EQU		0x530 ;Receive address select
radio_RXADDRESSES_write	PROC
	EXPORT	radio_RXADDRESSES_write
	;R0: value to write
	LDR		R1, =RADIO_RXADDRESSES_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_CRCCNF_OFFSET  		EQU		0x534 ;CRC configuration
radio_CRCCNF_write	PROC
	EXPORT	radio_CRCCNF_write
	;R0: value to write
	LDR		R1, =RADIO_CRCCNF_OFFSET
	B		radio_write_R0
	ENDP
		
radio_CRCCNF_set_bytes_addr_include	PROC
	EXPORT	radio_CRCCNF_set_bytes_addr_include
	;R0:	number of bytes for CRC (0: CRC length is zero and CRC calculation is disabled)
	MOVS	R2, #0x03	;mask
	ANDS	R2, R0
	B		radio_CRCCNF_write
	ENDP
	
radio_CRCCNF_set_bytes_addr_exclude	PROC
	EXPORT	radio_CRCCNF_set_bytes_addr_exclude
	;R0:	number of bytes for CRC (0: CRC length is zero and CRC calculation is disabled)
	MOVS	R2, #0x03	;mask
	ADDS	R2, R0
	MOVS	R0, #0x80
	ORRS	R2, R0
	B		radio_CRCCNF_write
	ENDP
	
;RADIO_CRCPOLY_OFFSET  		EQU		0x538 ;CRC polynomial
radio_CRCPOLY_write	PROC
	EXPORT	radio_CRCPOLY_write
	;R0: value to write
	LDR		R1, =RADIO_CRCPOLY_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_CRCINIT_OFFSET  		EQU		0x53C ;CRC initial value
radio_CRCINIT_write	PROC
	EXPORT	radio_CRCINIT_write
	;R0: value to write
	LDR		R1, =RADIO_CRCINIT_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_TEST_OFFSET  			EQU		0x540 ;Test features enable register
radio_TEST_write	PROC
	EXPORT	radio_TEST_write
	;R0: value to write
	LDR		R1, =RADIO_TEST_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_TIFS_OFFSET  			EQU		0x544 ;Inter Frame Spacing in us
radio_TIFS_write	PROC
	EXPORT	radio_TIFS_write
	;R0: value to write
	LDR		R1, =RADIO_TIFS_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_RSSISAMPLE_OFFSET		EQU		0x548 ;RSSI sample
radio_RSSISAMPLE_read	PROC
	EXPORT	radio_RSSISAMPLE_read
	LDR		R1, =RADIO_RSSISAMPLE_OFFSET
	B		radio_read
	ENDP

;RADIO_STATE_OFFSET  		EQU		0x550 ;Current radio state
radio_STATE_read	PROC
	EXPORT	radio_STATE_read
	LDR		R1, =RADIO_STATE_OFFSET
	B		radio_read
	ENDP

;RADIO_DATAWHITEIV_OFFSET	EQU		0x554 ;Data whitening initial value
radio_DATAWHITEIV_write	PROC
	EXPORT	radio_DATAWHITEIV_write
	;R0: value to write
	LDR		R1, =RADIO_DATAWHITEIV_OFFSET
	B		radio_write_R0
	ENDP

;RADIO_BCC_OFFSET  			EQU		0x560 ;Bit counter compare
radio_BCC_write	PROC
	EXPORT	radio_BCC_write
	;R0: value to write
	LDR		R1, =RADIO_BCC_OFFSET
	B		radio_write_R0
	ENDP

;todo ???
;RADIO_DAB_0__OFFSET  		EQU		0x600 ;Device address base segment 0
;RADIO_DAB_1__OFFSET  		EQU		0x604 ;Device address base segment 1
;RADIO_DAB_2__OFFSET  		EQU		0x608 ;Device address base segment 2
;RADIO_DAB_3__OFFSET  		EQU		0x60C ;Device address base segment 3
;RADIO_DAB_4__OFFSET  		EQU		0x610 ;Device address base segment 4
;RADIO_DAB_5__OFFSET  		EQU		0x614 ;Device address base segment 5
;RADIO_DAB_6__OFFSET  		EQU		0x618 ;Device address base segment 6
;RADIO_DAB_7__OFFSET  		EQU		0x61C ;Device address base segment 7
;RADIO_DAP_0__OFFSET  		EQU		0x620 ;Device address prefix 0
;RADIO_DAP_1__OFFSET  		EQU		0x624 ;Device address prefix 1
;RADIO_DAP_2__OFFSET  		EQU		0x628 ;Device address prefix 2
;RADIO_DAP_3__OFFSET  		EQU		0x62C ;Device address prefix 3
;RADIO_DAP_4__OFFSET  		EQU		0x630 ;Device address prefix 4
;RADIO_DAP_5__OFFSET  		EQU		0x634 ;Device address prefix 5
;RADIO_DAP_6__OFFSET  		EQU		0x638 ;Device address prefix 6
;RADIO_DAP_7__OFFSET  		EQU		0x63C ;Device address prefix 7
;RADIO_DACNF_OFFSET  		EQU		0x640 ;Device address match configuration
;RADIO_OVERRIDE0_OFFSET  	EQU		0x724 ;Trim value override register 0
;RADIO_OVERRIDE1_OFFSET  	EQU		0x728 ;Trim value override register 1
;RADIO_OVERRIDE2_OFFSET  	EQU		0x72C ;Trim value override register 2
;RADIO_OVERRIDE3_OFFSET  	EQU		0x730 ;Trim value override register 3
;RADIO_OVERRIDE4_OFFSET  	EQU		0x734 ;Trim value override register 4
;RADIO_POWER_OFFSET  		EQU		0xFFC ;Peripheral power control

radio_PREFIX0_set	PROC
	EXPORT	radio_PREFIX0_set
	LDR		R0, =RADIO_PREFIX0_value
	B		radio_PREFIX0_write
	ENDP

radio_PREFIX1_set	PROC
	EXPORT	radio_PREFIX1_set
	LDR		R0, =RADIO_PREFIX1_value
	B		radio_PREFIX1_write
	ENDP

radio_BASE0_set	PROC
	EXPORT	radio_BASE0_set
	LDR		R0, =RADIO_BASE0_value
	B		radio_BASE0_write
	ENDP

radio_BASE1_set	PROC
	EXPORT	radio_BASE1_set
	LDR		R0, =RADIO_BASE1_value
	B		radio_BASE1_write
	ENDP
	
	ROUT
radio_write_R0	PROC
	;R0: value to write
	;R1: offset to write R0 to
	LDR		R2, =RADIO_BASE_ADDRESS
	STR		R0, [R2,R1]
	BX		LR
	ENDP

radio_shift_write	PROC
	;R1: offset to write shifted one to
	;R2: number of bits to left schift mask bit
	LDR		R0, =RADIO_BASE_ADDRESS
	ADDS	R0, R1
	MOVS	R1, #0x01
	LSLS	R1, R2
	LDR		R1, [R0]
	BX		LR
	ENDP

radio_read	PROC
	;R1: offset to write one to
	LDR		R0, =RADIO_BASE_ADDRESS
	ADDS	R0, R1
	LDR		R0, [R0]
	BX		LR
	ENDP

radio_write_one	PROC
	;R1: offset to write one to
	LDR		R0, =RADIO_BASE_ADDRESS
	ADDS	R0, R1
	MOVS	R1, #0x01
	STR		R1, [R0]
	BX		LR
	ENDP

radio_write_zero	PROC
	;R1: offset to write zero to
	LDR		R0, =RADIO_BASE_ADDRESS
	ADDS	R0, R1
	EORS	R1,R1,R1
	STR		R1, [R0]
	BX		LR
	ENDP

	ROUT
radio_event_wait PROC
	;R1: event offset
	LDR		R0, =RADIO_BASE_ADDRESS
	ADDS	R0, R1
0	LDR		R1, [R0]
	CMP		R1, #0x00
	BEQ		%0
	BX		LR
	ENDP

;******************
	EXPORT	RADIO_POWER_0dBm		[WEAK]
	EXPORT	RADIO_MODE_Nrf_1Mbit	[WEAK]
	EXPORT	RADIO_PREFIX0_value		[WEAK]
	EXPORT	RADIO_PREFIX1_value		[WEAK]
	EXPORT	RADIO_BASE0_value		[WEAK]
	EXPORT	RADIO_BASE1_value		[WEAK]

;radio control block structure
RADIOCB_TXADDRESS_OFFSET	EQU	0x00
RADIOCB_RXADDRESSES_OFFSET	EQU	0x01
RADIOCB_CRCCNF_OFFSET		EQU	0x02
RADIOCB_CRCINIT_OFFSET		EQU	0x04
RADIOCB_CRCPOLY_OFFSET		EQU	0x08
RADIOCB_TXPOWER_OFFSET		EQU	0x0C
RADIOCB_FREQ_OFFSET			EQU	0x10
RADIOCB_MODE_OFFSET			EQU	0x14
RADIOCB_PREFIX0_OFFSET		EQU	0x18
RADIOCB_PREFIX1_OFFSET		EQU	0x1C
RADIOCB_BASE0_OFFSET		EQU	0x20
RADIOCB_BASE1_OFFSET		EQU	0x24
RADIOCB_PCNF0_OFFSET		EQU	0x28
RADIOCB_PCNF1_OFFSET		EQU	0x2C
PACKET_BUFFER_OFFSET		EQU	0x30

RADIO_BASE_ADDRESS			EQU		0x40001000	;2.4 GHz Radio
;Tasks
RADIO_TXEN_OFFSET  			EQU		0x000 ;Enable RADIO in TX mode
RADIO_RXEN_OFFSET  			EQU		0x004 ;Enable RADIO in RX mode
RADIO_START_OFFSET  		EQU		0x008 ;Start RADIO
RADIO_STOP_OFFSET  			EQU		0x00C ;Stop RADIO
RADIO_DISABLE_OFFSET  		EQU		0x010 ;Disable RADIO
RADIO_RSSISTART_OFFSET  	EQU		0x014 ;Start the RSSI and take one single sample of the receive signal strength
RADIO_RSSISTOP_OFFSET  		EQU		0x018 ;Stop the RSSI measurement
RADIO_BCSTART_OFFSET  		EQU		0x01C ;Start the bit counter
RADIO_BCSTOP_OFFSET  		EQU		0x020 ;Stop the bit counter
;Events
RADIO_READY_OFFSET  		EQU		0x100 ;RADIO has ramped up and is ready to be started
RADIO_ADDRESS_OFFSET  		EQU		0x104 ;Address sent or received
RADIO_PAYLOAD_OFFSET  		EQU		0x108 ;Packet payload sent or received
RADIO_END_OFFSET  			EQU		0x10C ;Packet sent or received
RADIO_DISABLED_OFFSET 	 	EQU		0x110 ;RADIO has been disabled
RADIO_DEVMATCH_OFFSET 	 	EQU		0x114 ;A device address match occurred on the last received packet
RADIO_DEVMISS_OFFSET  		EQU		0x118 ;No device address match occurred on the last received packet
RADIO_RSSIEND_OFFSET  		EQU		0x11C ;Sampling of receive signal strength complete. 
										;A new RSSI sample is ready for readout from the RSSISAMPLE register.
RADIO_BCMATCH_OFFSET  		EQU		0x128 ;Bit counter reached bit count value specified in the BCC register
;Registers
RADIO_SHORTS_OFFSET  		EQU		0x200 ;Shortcut register
RADIO_INTENSET_OFFSET 	 	EQU		0x304 ;Enable interrupt
RADIO_INTENCLR_OFFSET 	 	EQU		0x308 ;Disable interrupt
RADIO_CRCSTATUS_OFFSET	 	EQU		0x400 ;CRC status
RADIO_RXMATCH_OFFSET  		EQU		0x408 ;Received address
RADIO_RXCRC_OFFSET  		EQU		0x40C ;CRC field of previously received packet
RADIO_DAI_OFFSET  			EQU		0x410 ;Device address match index
RADIO_PACKETPTR_OFFSET 		EQU		0x504 ;Packet pointer
RADIO_FREQUENCY_OFFSET 	 	EQU		0x508 ;Frequency
RADIO_TXPOWER_OFFSET  		EQU		0x50C ;Output power
RADIO_MODE_OFFSET  			EQU		0x510 ;Data rate and modulation
RADIO_PCNF0_OFFSET  		EQU		0x514 ;Packet configuration register 0
RADIO_PCNF1_OFFSET  		EQU		0x518 ;Packet configuration register 1
RADIO_BASE0_OFFSET  		EQU		0x51C ;Base address 0
RADIO_BASE1_OFFSET  		EQU		0x520 ;Base address 1
RADIO_PREFIX0_OFFSET  		EQU		0x524 ;Prefixes bytes for logical addresses 0-3
RADIO_PREFIX1_OFFSET  		EQU		0x528 ;Prefixes bytes for logical addresses 4-7
RADIO_TXADDRESS_OFFSET  	EQU		0x52C ;Transmit address select
RADIO_RXADDRESSES_OFFSET	EQU		0x530 ;Receive address select
RADIO_CRCCNF_OFFSET  		EQU		0x534 ;CRC configuration
RADIO_CRCPOLY_OFFSET  		EQU		0x538 ;CRC polynomial
RADIO_CRCINIT_OFFSET  		EQU		0x53C ;CRC initial value
RADIO_TEST_OFFSET  			EQU		0x540 ;Test features enable register
RADIO_TIFS_OFFSET  			EQU		0x544 ;Inter Frame Spacing in us
RADIO_RSSISAMPLE_OFFSET		EQU		0x548 ;RSSI sample
RADIO_STATE_OFFSET  		EQU		0x550 ;Current radio state
RADIO_DATAWHITEIV_OFFSET	EQU		0x554 ;Data whitening initial value
RADIO_BCC_OFFSET  			EQU		0x560 ;Bit counter compare
RADIO_DAB_0__OFFSET  		EQU		0x600 ;Device address base segment 0
RADIO_DAB_1__OFFSET  		EQU		0x604 ;Device address base segment 1
RADIO_DAB_2__OFFSET  		EQU		0x608 ;Device address base segment 2
RADIO_DAB_3__OFFSET  		EQU		0x60C ;Device address base segment 3
RADIO_DAB_4__OFFSET  		EQU		0x610 ;Device address base segment 4
RADIO_DAB_5__OFFSET  		EQU		0x614 ;Device address base segment 5
RADIO_DAB_6__OFFSET  		EQU		0x618 ;Device address base segment 6
RADIO_DAB_7__OFFSET  		EQU		0x61C ;Device address base segment 7
RADIO_DAP_0__OFFSET  		EQU		0x620 ;Device address prefix 0
RADIO_DAP_1__OFFSET  		EQU		0x624 ;Device address prefix 1
RADIO_DAP_2__OFFSET  		EQU		0x628 ;Device address prefix 2
RADIO_DAP_3__OFFSET  		EQU		0x62C ;Device address prefix 3
RADIO_DAP_4__OFFSET  		EQU		0x630 ;Device address prefix 4
RADIO_DAP_5__OFFSET  		EQU		0x634 ;Device address prefix 5
RADIO_DAP_6__OFFSET  		EQU		0x638 ;Device address prefix 6
RADIO_DAP_7__OFFSET  		EQU		0x63C ;Device address prefix 7
RADIO_DACNF_OFFSET  		EQU		0x640 ;Device address match configuration
RADIO_OVERRIDE0_OFFSET  	EQU		0x724 ;Trim value override register 0
RADIO_OVERRIDE1_OFFSET  	EQU		0x728 ;Trim value override register 1
RADIO_OVERRIDE2_OFFSET  	EQU		0x72C ;Trim value override register 2
RADIO_OVERRIDE3_OFFSET  	EQU		0x730 ;Trim value override register 3
RADIO_OVERRIDE4_OFFSET  	EQU		0x734 ;Trim value override register 4
RADIO_POWER_OFFSET  		EQU		0xFFC ;Peripheral power control

RADIO_PREFIX0_value			EQU		0xC3438303
RADIO_PREFIX1_value			EQU		0xE3630023
	
RADIO_BASE0_value			EQU		0x80C4A2E6
RADIO_BASE1_value			EQU		0x91D5B3F7

;TXPOWER RADIO output power. Decision point: TXEN task
;Output power in number of dBm, i.e. if the value -20 is
;specified the output power will be set to -20 dBm.
RADIO_POWER_Pos4dBm		EQU	0x04	;+4 dBm
RADIO_POWER_0dBm		EQU	0x00	;0 dBm
RADIO_POWER_Neg4dBm		EQU	0xFC	;-4 dBm
RADIO_POWER_Neg8dBm		EQU	0xF8	;-8 dBm
RADIO_POWER_Neg12dBm	EQU	0xF4	;-12 dBm
RADIO_POWER_Neg16dBm	EQU	0xF0	;-16 dBm
RADIO_POWER_Neg20dBm	EQU	0xEC	;-20 dBm
RADIO_POWER_Neg30dBm	EQU	0xD8	;-30 dBm

;Radio data rate and modulation setting. The radio supports
;Frequency-shift Keying (FSK) modulation.
RADIO_MODE_Nrf_1Mbit	EQU	0	;1 Mbit/s Nordic proprietary radio mode
RADIO_MODE_Nrf_2Mbit	EQU	1	;2 Mbit/s Nordic proprietary radio mode
RADIO_MODE_Nrf_250Kbit	EQU	2	;250 kbit/s Nordic proprietary radio mode
RADIO_MODE_Ble_1Mbit	EQU	3	;1 Mbit/s Bluetooth Low Energy

	END
