	AREA sd_file_util, CODE, READONLY

sdfile_set_uninitialized PROC
	;R0: file control block address
	LDR		R1, [R0, #FILECB_STATE_OFFSET]
	MOVS	R2, #FILECB_STATE_INITIALIZED_MASK
	MVNS	R2, R2
	ANDS	R1, R2
	STR		R1, [R0, #FILECB_STATE_OFFSET]
	BX		LR
	ENDP

sdfile_set_initialized PROC
	;R0: file control block address
	LDR		R1, [R0, #FILECB_STATE_OFFSET]
	MOVS	R2, #FILECB_STATE_INITIALIZED_MASK
	ORRS	R1, R2
	STR		R1, [R0, #FILECB_STATE_OFFSET]
	BX		LR
	ENDP

	ROUT
sdfile_init PROC
	EXPORT	sdfile_init
	;R0: file control block address
	;R1: fat control block address
	;R2: sdcard control block address
	;R3: file name address
	PUSH	{LR,R4-R7}
	[ :DEF:__DEBUG__
		MOV		R7, R8
		PUSH	{R7}
	]
	MOV		R4, R0
	MOV		R5, R1
	MOV		R6, R2
	MOV		R7, R3
	BL		sdfile_set_uninitialized
	MOV		R0, R5
	BL		fat_is_initialized
	CMP		R0, #0x00
	BEQ		%0
	STR		R5, [R4, #FILECB_FAT_ADDR_OFFSET]
	STR		R6, [R4, #FILECB_SDCARD_ADDR_OFFSET]
	STR		R7, [R4, #FILECB_NAME_ADDR_OFFSET]
	MOV		R0, R4
	BL		sdfile_find_first
	[ :DEF:__DEBUG__
		MOV	R8, R0
		LDR	R0, =TEXT_FINDFIRST
		LDR	R1, =TEXT_FINDFIRST_END
		MOV	R2, R8
		BL	uart_send_text_byte
		MOV	R0, R8
	]
	CMP		R0, #0x00
	BEQ		%0
	MOV		R0, R4	
	BL		sdfile_read_status
	CMP		R0, #0x00
	BEQ		%0
	MOV		R0, R4
	BL		sdfile_set_initialized
	MOVS	R0, #0x01	;success
	[ :DEF:__DEBUG__
		POP		{R7}
		MOV		R8, R7
	]
0	POP		{PC,R4-R7}
    ENDP

	ROUT
sdfile_find_first PROC
	;R0: file control block address
	PUSH	{LR,R4-R7}
	MOV		R4, R0
	LDR		R0, [R4, #FILECB_FAT_ADDR_OFFSET]
	BL		fat_lba_get
	MOV		R5, R0
	LDR		R0, [R4, #FILECB_FAT_ADDR_OFFSET]
	BL		fat_reserved_get
	MOV		R6, R0
	LDR		R0, [R4, #FILECB_FAT_ADDR_OFFSET]
	BL		fat_secs_per_fat_get
	MOV		R7, R0
	MOV		R1, R5
	ADD		R1, R6	;lba+reserved
	ADD		R1, R7	;lba+reserved+fat
	ADD		R1, R7	;lba+reserved+fat*2 -> data
	LDR		R2, =BLOCK_SIZE
	ADDS	R1, #0x20	;skip the root directory cluster
	MULS	R1, R2, R1
	LDR		R0, [R4, #FILECB_SDCARD_ADDR_OFFSET]
	STR		R1, [R4, #FILECB_FILE_BYTE_OFFSET]	;save the 1st file data sector address (table) in bytes (on SD)
	LDR		R2, =TABLE
	BL		sdcard_cmd17
	CMP		R0, #0x00
	BEQ		%1
	CMP		R1, #KEVIN_TOCKEN
	BNE		%1
	LDR		R2, =TABLE
	LDR		R3, [R2, #FILETABLE_SECTOR_ID_OFFSET]			;read sector index. index of the table sector is 0
	STR		R3, [R4, #FILECB_SECTOR_ID_OFFSET]				;save it in control block
	LDR		R5, [R2, #FILETABLE_CURRENT_POINT_BYTE_OFFSET]	;read the next free byte in the current sector
	STR		R5, [R4, #FILECB_CURRENT_POINT_BYTE_OFFSET]		;save it in control block
	LDR		R1, [R4, #FILECB_FILE_BYTE_OFFSET]
	LDR		R2, =BLOCK_SIZE
	MULS	R3, R2, R3
	ADDS	R1, R3
	MOV		R6, R1	;save sector byte address
	LDR		R0, [R4, #FILECB_SDCARD_ADDR_OFFSET]
	LDR		R2, =CURRENT_BLOCK
	BL		sdcard_cmd17
	CMP		R0, #0x00
	BEQ		%1
	CMP		R1, #0xFF
	BNE		%1
	STR		R6, [R4, #FILECB_SECTOR_BYTE_OFFSET]		;save it in control block
	MOVS	R0, #0x01	;success
	B		%2
1	NOP		;failure
	EORS	R0,R0,R0	;return false
2	POP		{PC,R4-R7}
    ENDP

	ROUT
sdfile_add_record PROC
	EXPORT	sdfile_add_record
	;R0: file control block address
	;R1: record address
	;R2: record size
	PUSH	{LR,R4-R7}
	MOV		R4, R0
	MOV		R5, R1
	MOV		R6, R2
	LDR		R0, [R4, #FILECB_CURRENT_POINT_BYTE_OFFSET]
	ADDS	R2, R0
	LDR		R3, =BLOCK_SIZE
	CMP		R2, R3
	BLS		%0		;add and flash
	;read the next block
	LDR		R0, [R4, #FILECB_SDCARD_ADDR_OFFSET]
	LDR		R1, [R4, #FILECB_SECTOR_BYTE_OFFSET]
	ADDS	R1, R3	;R3 still contains block size
	LDR		R2, =CURRENT_BLOCK
	BL		sdcard_cmd17
	[ :DEF:__DEBUG__
		MOV	R7, R0
		LDR	R0, =TEXT_sdcard_cmd17_RET
		LDR	R1, =TEXT_sdcard_cmd17_RET_END
		MOV	R2, R7
		BL	uart_send_text_byte
		MOV	R0, R7
	]
	CMP		R0, #0x00
	BEQ		%2	;failed
	;update current sector and point in the table & cb
	LDR		R2, =TABLE
	LDR		R0, [R2, #FILETABLE_SECTOR_ID_OFFSET]
	ADDS	R0, #0x01
	STR		R0, [R2, #FILETABLE_SECTOR_ID_OFFSET]
	EORS	R0,R0,R0
	STR		R0, [R2, #FILETABLE_CURRENT_POINT_BYTE_OFFSET]
	LDR		R0, [R4, #FILECB_SECTOR_BYTE_OFFSET]
	LDR		R1, =BLOCK_SIZE
	ADDS	R0, R1	;R3 still contains block size
	STR		R0, [R4, #FILECB_SECTOR_BYTE_OFFSET]
	EORS	R0,R0,R0
	STR		R0, [R4, #FILECB_CURRENT_POINT_BYTE_OFFSET]
0	NOP	;add and flash
	LDR		R0, =CURRENT_BLOCK
	LDR		R1, [R4, #FILECB_CURRENT_POINT_BYTE_OFFSET]
	ADDS	R0, R1
	MOV		R1, R5
	MOV		R2, R1
	ADDS	R2, R6
	BL		copy_mem
	;flash
	LDR		R0, [R4, #FILECB_SDCARD_ADDR_OFFSET]
	LDR		R1, [R4, #FILECB_SECTOR_BYTE_OFFSET]
	LDR		R2, =CURRENT_BLOCK
	BL		sdcard_cmd24
	[ :DEF:__DEBUG__
		MOV	R7, R0
		LDR	R0, =TEXT_sdcard_cmd24_CURRENT_RET
		LDR	R1, =TEXT_sdcard_cmd24_RET_CURRENT_END
		MOV	R2, R7
		BL	uart_send_text_byte
		MOV	R0, R7
	]
	CMP		R0, #0x00
	BEQ		%2
	LDR		R1, [R4, #FILECB_CURRENT_POINT_BYTE_OFFSET]
	ADDS	R1, R6
	STR		R1, [R4, #FILECB_CURRENT_POINT_BYTE_OFFSET]
	LDR		R2, =TABLE
	STR		R1, [R2, #FILETABLE_CURRENT_POINT_BYTE_OFFSET]			;save the next free byte in the current sector to the table
	LDR		R0, [R4, #FILECB_SDCARD_ADDR_OFFSET]
	LDR		R1, [R4, #FILECB_FILE_BYTE_OFFSET]
	BL		sdcard_cmd24
	[ :DEF:__DEBUG__
		MOV	R7, R0
		LDR	R0, =TEXT_sdcard_cmd24_TABLE_RET
		LDR	R1, =TEXT_sdcard_cmd24_RET_TABLE_END
		MOV	R2, R7
		BL	uart_send_text_byte
		MOV	R0, R7
	]
	CMP		R0, #0x00
	BEQ		%2
	B		%4
2	EORS	R0,R0,R0
4	POP		{PC,R4-R7}
    ENDP
;
; I don't know exactly what the "status" is. Leaved till later...
;
	ROUT
sdfile_read_status PROC
	;R0: file control block address
	PUSH	{LR,R4,R5}
	MOV		R4, R0
	MOVS	R0, #0x01 ;simulate success
0	POP		{PC,R4,R5}
    ENDP

;******************

	EXTERN	copy_mem

	EXTERN	sdcard_cmd17
	EXTERN	sdcard_cmd24
	EXTERN	DATA_BLOCK
	EXTERN	BLOCK_SIZE

;file control block structure
	EXPORT	FILECB_STATE_OFFSET			[WEAK]
	EXPORT	FILECB_FAT_ADDR_OFFSET		[WEAK]
	EXPORT	FILECB_SDCARD_ADDR_OFFSET	[WEAK]
	EXPORT	FILECB_NAME_ADDR_OFFSET		[WEAK]
	EXPORT	FILECB_FILE_BYTE_OFFSET		[WEAK]
	EXPORT	FILECB_SECTOR_BYTE_OFFSET	[WEAK]
FILECB_STATE_OFFSET					EQU		0x00
FILECB_SDCARD_ADDR_OFFSET			EQU		0x04
FILECB_FAT_ADDR_OFFSET				EQU		0x08
FILECB_FILE_BYTE_OFFSET				EQU		0x0C	;offset of the 1st file data sector (table) in bytes (on SD)
FILECB_SECTOR_ID_OFFSET				EQU		0x10	;offset of sector index. index of the table sector is 0
FILECB_SECTOR_BYTE_OFFSET			EQU		0x14	;offset of current sector address in bytes (on SD)
FILECB_CURRENT_POINT_BYTE_OFFSET	EQU		0x18	;offset of the next free byte in the current sector
FILECB_NAME_ADDR_OFFSET				EQU		0x1C
	
FILECB_STATE_INITIALIZED_MASK	EQU	0x01
;...

FILETABLE_SECTOR_ID_OFFSET			EQU		0x00
FILETABLE_CURRENT_POINT_BYTE_OFFSET	EQU		0x04
	
KEVIN_TOCKEN						EQU		0xB2

	[ :DEF:__DEBUG__
		EXTERN	uart_send_text_byte
		EXTERN	uart_send
	]

	EXTERN	fat_lba_get
	EXTERN	fat_reserved_get
	EXTERN	fat_secs_per_fat_get
	EXTERN	fat_sectors_per_cluster_get
	EXTERN	fat_is_initialized

	ALIGN
	AREA    data, DATA
TABLE			SPACE	512
CURRENT_BLOCK	SPACE	512
	[ :DEF:__DEBUG__
TEXT_FINDFIRST						DCB	"find first ret:"
TEXT_FINDFIRST_END
TEXT_sdcard_cmd24_CURRENT_RET		DCB	"cmd24 current ret:"
TEXT_sdcard_cmd24_RET_CURRENT_END
TEXT_sdcard_cmd24_TABLE_RET			DCB	"cmd24 table ret:"
TEXT_sdcard_cmd24_RET_TABLE_END
TEXT_sdcard_cmd17_RET				DCB	"cmd17 add record ret:"
TEXT_sdcard_cmd17_RET_END
	]
	END
