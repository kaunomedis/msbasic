.feature force_range
.debuginfo +

.setcpu "65C02"
.macpack longbranch


ACIA_DATA       = $5000 ;RX/TX data
ACIA_STATUS     = $5001 ;B0-data in rx buffer, B1-txReady, B2-txDone
ACIA_CMD        = $5002 ;no
ACIA_CTRL       = $5003 ;no

ZP_START0		= $10

.zeropage
                .org ZP_START0
READ_PTR:       .res 1
WRITE_PTR:      .res 1

.segment "INPUT_BUFFER"
.org $300
INPUT_BUFFER:   .res $FF

.segment "HEADER"
.segment "DUMMY"
.segment "VECTORS"
.segment "KEYWORDS"
.segment "ERROR"
.segment "CHRGET"
.segment "INIT"
.segment "EXTRA"

.segment "BIOS"
.org $FE00
RESET2:
				;lda #$5A
				;jsr CHROUT
				;jsr CRLF
				;jmp RESET

				sei
				cld
				;ldx #$FF
				;txs
				CLI
LOOP1:			nop
				JSR CHRIN
				jmp LOOP1

; Input a character from the serial interface.
; On return, carry flag indicates whether a key was pressed
; If a key was pressed, the key value will be in the A register
;
; Modifies: flags, A
MONRDKEY:
CHRIN:			phx
                jsr     BUFFER_SIZE
                beq     @no_keypressed
                jsr     READ_BUFFER
                jsr     CHROUT                  ; echo
                plx
                sec
                rts
@no_keypressed:
                plx
                clc
                rts
; Output a character (from the A register) to the serial interface.
;
; Modifies: flags
MONCOUT:
CHROUT:
				pha ;push a to stack
@tx_chk:		lda		ACIA_STATUS
				and #2
				BEQ @tx_chk
				pla
                sta     ACIA_DATA
                rts

; Initialize the circular input buffer
; Modifies: flags, A
INIT_BUFFER:
                lda $2; READ_PTR
                sta $1; WRITE_PTR
                rts

; Write a character (from the A register) to the circular input buffer
; Modifies: flags, X
WRITE_BUFFER:
                ldx $1; WRITE_PTR
                sta INPUT_BUFFER,x
                inc $1; WRITE_PTR
                rts

; Read a character from the circular input buffer and put it in the A register
; Modifies: flags, A, X
READ_BUFFER:
                ldx $2; READ_PTR
                lda INPUT_BUFFER,x
                inc $2; READ_PTR
                rts

; Return (in A) the number of unread bytes in the circular input buffer
; Modifies: flags, A
BUFFER_SIZE:
                lda $1; WRITE_PTR
                sec
                sbc $2; READ_PTR
                rts
SAVE:
LOAD:			rts

IRQ_HANDLER:	
                pha
                phx
				
                ; lda     ACIA_STATUS
                ; For now, assume the only source of interrupts is incoming data
                lda     ACIA_DATA
				sta     $166
                ;jsr     WRITE_BUFFER
				
				ldx $1 ;WRITE_PTR
                sta INPUT_BUFFER,x
                inc $1; WRITE_PTR
				sta     ACIA_DATA
				
                plx
                pla
                rti

.org $FF00
.include "wozmon.s"
.segment "RESETVEC"
                .word   $0F00           ; NMI vector
                .word   RESET2           ; RESET vector
                .word   IRQ_HANDLER     ; IRQ vector
				