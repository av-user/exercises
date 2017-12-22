	AREA fifo_utilities, CODE, READONLY

	INCLUDE ../common/constants.inc

MIN_FIFOSTRUCT_SIZE	EQU		0x10		;three words for head/tail/end + 4 bytes for buffer

;fifo
;fifo_head			DCD	0
;fifo_tail			DCD	0
;fifo_end_ptr		DCD 0
;fifo_buffer		DCD 0
;fifo_end

	ROUT
fifo_is_empty	PROC
	EXPORT	fifo_is_empty
	;R0: fifo structure address
	MOVS	R2, #0xFF
	SXTB	R2, R2
	LDR		R1, [R0]		;read head
	CMP		R1, R2
	BNE		%0				;not empty
	;LDR		R1, [R0, #0x04]	;read tail
	;CMP		R1, R2
	;BNE		%0				;not empty
	MOVS	R0, #0x01			;is empty
	B		%1
0	EORS	R0,R0,R0
1	BX		LR
	ENDP

fifo_get_capacity	PROC
	EXPORT	fifo_get_capacity
	;R0: fifo structure address
	LDR		R1, [R0, #0x08]	;end_ptr
	ADDS	R0, #0x0C
	SUBS	R1, R0
	MOV		R0, R1
	BX		LR
	ENDP

fifo_get_free_count	PROC
	EXPORT	fifo_get_free_count
	PUSH	{LR}
	;R0: fifo structure address
	BL		sync_crsect_enter
	LDR		R1, [R0]		;head
	MOV		R2, R1
	LSRS	R2, #0x18
	CMP		R2, #0xFF
	BEQ		return_empty
	LDR		R2, [R0, #0x04]	;tail
	CMP		R1, R2			;compare head with tail
	BEQ		return_but_one
	BGT		head_gt_tail
	;head less than tail
	MOV		R0, R2
	SUBS	R0, R1
	SUBS	R0, #0x01
	B		exit_free_count
head_gt_tail
	LDR		R3, [R0, #0x08]	;end
	SUBS	R3, #0x01	;last possible address
	SUBS	R3, R1		;free bytes right from the head
	SUBS	R2, R0		;free left from the tail + 0xC bytes
	SUBS	R2, #0x0C	;free left from the tail
	MOV		R0, R3
	ADD		R0, R2
	B		exit_free_count
return_but_one
	BL		fifo_get_capacity
	SUBS	R0, #0x01
	B		exit_free_count
return_empty
	BL		fifo_get_capacity
exit_free_count
	BL		sync_crsect_exit
	POP		{PC}
	ENDP

;fifo
;fifo_head			DCD	0
;fifo_tail			DCD	0
;fifo_end_ptr		DCD 0
;fifo_buffer		DCD 0
;fifo_end

fifo_dequeue	PROC
	EXPORT	fifo_dequeue
	;R0: fifo structure address
	;return byte in R1
	PUSH	{LR}
	BL		sync_crsect_enter
	LDR		R2, [R0]	;head
	MOV		R3, R2
	LSRS	R3, #0x18
	CMP		R3, #0xFF
	BEQ		denq_failure	;queue is empty
	;queue is not empty
	LDR		R3, [R0, #0x04]	;tail
	LDRB	R1, [R3]		;read byte
	CMP		R2, R3			;compare head with tail
	BEQ		denq_the_last
	ADDS	R3, #0x01		;increment tail
	LDR		R4, [R0, #0x08]	;end
	CMP		R4, R3			;compare end with tail
	BEQ		denq_tail_to_begin
	STR		R3, [R0, #0x04]	;save new tail
	B		denq_success
denq_tail_to_begin
	MOV		R3, R0
	ADDS	R3, #0x0C
	STR		R3, [R0, #0x04]	;save new tail
	B		denq_success
denq_the_last
	MOVS	R2, #0xFF
	SXTB	R2, R2
	STR		R2, [R0]		;write head
	STR		R2, [R0, #0x04]	;write tail
	B		denq_success
denq_failure
	LDR		R0, =RETURN_FAILURE
	B		exit_enq
denq_success
	LDR		R0, =RETURN_SUCCESS
exit_denq
	BL		sync_crsect_exit
	POP		{PC}
	ENDP
		
;fifo
;fifo_head			DCD	0
;fifo_tail			DCD	0
;fifo_end_ptr		DCD 0
;fifo_buffer		DCD 0
;fifo_end

;routine returns 0 on success
;or number of non-enqued bytes if no space
;or 0xFFFFFFFF if invalid range
fifo_enqueue_range	PROC
	EXPORT	fifo_enqueue_range
	;R0: fifo structure address
	;R1: address of the 1st byte to enqueue
	;R2: address of the 1st byte after
	;used registers
	;R3: head
	;R4: tail
	;R5: input bytes counter
	;R6: fifo_end_ptr
	;R7: tmp
	PUSH	{LR}
	SUBS	R5, R2, R1
	BGT		range_valid
	;invalid range (start address >= end address)
	MOVS	R5, #0xFF
	SXTB	R5, R5
	B		enq_range_failure
range_valid
	BL		sync_crsect_enter
	;we have 3 general cases: queue empty, head >= tail, head < tail
	LDR		R6, [R0, #0x08]	;fifo_end_ptr
	LDR		R3, [R0]	;head
	MOV		R7, R3
	LSRS	R7, #0x18
	CMP		R7, #0xFF
	BNE		enq_range_not_empty
	;queue is empty
	MOV		R3, R0
	ADDS	R3, #0x0C		;fifo_buffer address
	MOV		R4, R3
	STR		R4, [R0, #0x04]	;save tail
0
	LDRB	R7, [R1]
	STRB	R7, [R3]		;enqueue byte
	SUBS	R5, #0x01
	ADDS	R1, #0x01		;next input byte
	CMP		R1, R2
	BHS		end_range_0
	ADDS	R3, #0x01
	CMP		R3, R6
	BHS		no_space_0
	B		%0
end_range_0
	STR		R3, [R0]	;save head
	B		enq_range_success
no_space_0
	SUBS	R3, #0x01
	STR		R3, [R0]	;save head
	B		enq_range_failure
enq_range_not_empty
	LDR		R4, [R0, #0x04]	;tail
	CMP		R3, R4		;compare head with tail
	BPL		enq_range_head_ge_tail
	;head < tail
	ADDS	R3, #0x01
	CMP		R3, R4
	BHS		no_space_4
3
	LDRB	R7, [R1]
	STRB	R7, [R3]		;enqueue byte
	SUBS	R5, #0x01
	ADDS	R1, #0x01		;next input byte
	CMP		R1, R2
	BHS		end_range_3
	ADDS	R3, #0x01
	CMP		R3, R4
	BLO		%3
no_space_4
	SUBS	R3, #0x01
	STR		R3, [R0]	;save head
	B		enq_range_failure
end_range_3
	STR		R3, [R0]	;save head
	B		enq_range_success
enq_range_head_ge_tail
	ADDS	R3, #0x01
	CMP		R3, R6
	BHS		try_left_0
1
	LDRB	R7, [R1]
	STRB	R7, [R3]		;enqueue byte
	SUBS	R5, #0x01
	ADDS	R1, #0x01		;next input byte
	CMP		R1, R2
	BHS		end_range_1
	ADDS	R3, #0x01
	CMP		R3, R6
	BLO		%1
try_left_0
	SUBS	R3, #0x01
	STR		R3, [R0]		;save head
	MOV		R3, R0
	ADDS	R3, #0x0C	;fifo buffer address
	CMP		R3, R4
	BHS		enq_range_failure
2
	LDRB	R7, [R1]
	STRB	R7, [R3]		;enqueue byte
	SUBS	R5, #0x01
	ADDS	R1, #0x01		;next input byte
	CMP		R1, R2
	BHS		end_range_1
	ADDS	R3, #0x01
	CMP		R3, R4
	BHS		no_space_2
	B		%2
end_range_1
	STR		R3, [R0]	;save head
	B		enq_range_success
no_space_2
	SUBS	R3, #0x01
	STR		R3, [R0]	;save head
	B		enq_range_failure
enq_range_failure
	MOV		R0, R5
	B		exit_enq
enq_range_success
	LDR		R0, =RETURN_SUCCESS
exit_enq_range
	BL		sync_crsect_exit	
	POP		{PC}
	ENDP

fifo_enqueue	PROC
	EXPORT	fifo_enqueue
	;R0: fifo structure address
	;R1: byte to enqueue
	PUSH	{LR}
	BL		sync_crsect_enter
	LDR		R2, [R0]	;head
	MOV		R3, R2
	LSRS	R3, #0x18
	CMP		R3, #0xFF
	BNE		enq_not_empty
	;queue is empty save the byte at the buffer beginning and point there head and tail
	MOV		R2, R0
	ADDS	R2, #0x0C	;buffer address
	STRB	R1, [R2]	;save byte
	STR		R2, [R0]	;save new head
	STR		R2, [R0, #0x04]	;save new tail
	B		enq_success
enq_not_empty
	LDR		R3, [R0, #0x04]	;tail
	CMP		R2, R3		;compare head with tail
	BPL		enq_between_head_and_end
	;tail gt head
	MOV		R4, R3
	SUBS	R4, R2
	CMP		R4, #0x01
	BLS		enq_failure	;no free space
	ADDS	R2, #0x01	;increment head
	STRB	R1, [R2]
	STR		R2, [R0]	;save new head
	B		enq_success
enq_between_head_and_end
	LDR		R4, [R0, #0x08]
	SUBS	R4, #0x01	;last possible address
	CMP		R4, R2
	BLS		try_begin_left_from_tail
	;there is a space between head and the end
	ADDS	R2, #0x01	;next byte
	STRB	R1, [R2]	;save byte
	STR		R2, [R0]	;save new head
	B		enq_success
try_begin_left_from_tail
	MOV		R2, R0		;we dont need head value any more
	ADDS	R2, #0x0C
	CMP		R3, R2		;compare tail with begin
	BLS		enq_failure ;no free space
	;begin is free, we save byte there and update the head
	STRB	R1, [R2]	;save byte
	STR		R2, [R0]	;save new head
	B		enq_success
enq_failure
	LDR		R0, =RETURN_FAILURE
	B		exit_enq
enq_success
	LDR		R0, =RETURN_SUCCESS
exit_enq
	BL		sync_crsect_exit
	POP		{PC}
	ENDP
	
fifo_init	PROC
	EXPORT	fifo_init
	;R0: fifo structure address
	;R1: address of the word next to the structure
	PUSH	{LR}
	SUBS	R2, R1, R0	;structure size
	MOVS	R3, #MIN_FIFOSTRUCT_SIZE
	CMP		R2, R3
	BLO		not_enough
	BL		sync_crsect_enter
	MOVS	R2, #0xFF
	SXTB	R2, R2
	STR		R2, [R0]		;write head
	STR		R2, [R0, #0x04]	;write tail
	STR		R1, [R0, #0x08]	;write end
	EORS	R0,R0,R0
	B		exit_fifo_init
not_enough
	MOVS	R0, #1		;error: struct too short
exit_fifo_init
	BL		sync_crsect_exit
	POP		{PC}
	ENDP

	EXTERN	test_breakpiont
		
	EXTERN	sync_crsect_enter
	EXTERN	sync_crsect_exit
		
	END
