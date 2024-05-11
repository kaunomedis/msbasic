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
				ldx #$FF
				txs
				
				ldx     #$FF
				lda     #$00
crloop1:		sta     $00,x       ;Clear zero page
				sta		$100,x		;Clear page 1
				inx
				bne     crloop1
				CLI
				lda #'H'
				jsr CHROUT
				lda #'U'
				jsr CHROUT
				lda #13
				jsr CHROUT
				lda #10
				jsr CHROUT
				;CLI
LOOP1:			nop
				lda $10
				;sta $5555
				;cmp #0
				beq LOOP1
				jsr CHROUT
				lda #0
				sta $10
				jmp LOOP1


IRQ_HANDLER:	
                pha
                ;phx
				
                ; lda     ACIA_STATUS
                ; For now, assume the only source of interrupts is incoming data
                lda     ACIA_DATA
				sta     $10
                
                ;plx
                pla
NMI:            rti
				jmp LOOP1
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

.org $FF00
.segment "WOZMON"
.segment "RESETVEC"
                .word   NMI           ; NMI vector
                .word   RESET2           ; RESET vector
                .word   IRQ_HANDLER     ; IRQ vector
				