        ORG     4000

REG_BANK = $ff40

BANK .db $0 ; 4000
ADDR .dw $0  ; 4001-02
DATA .db $0  ; 4003
SLOT .db $0
    
    org 4010
START:        ; jump table
    bra ERASEALL
    *bra ERASE
    bra STORE
    bra READ

CMD_SEND:
    lda #$aa
    sta $c555         ; store preamble byte #1
    lda #$55
    sta $c2aa         ; store preamble byte #2
    stb $c555         ; store command
    rts

BANK_SET:
    lda BANK
    ora #128        ; turn on programming bit
    sta REG_BANK
    rts

ADDR_GET:
    ldd ADDR
    ora #%11000000
    tfr d,x
    rts

SLOT_SET:
    lda $ff7f       ; save off current MPI slot data
    sta SLOT
    lda #0          ; for now, assume MPI slot is #1
    sta $ff7f
    sta $ffde       ; switch ROMs in
    rts

SLOT_RESET:
    lda SLOT        ; restore slot value
    sta $ff7f
    rts

STORE:
    PSHS D,X,CC     ; save the registers our setup code will effect
    ORCC #$50       ; = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET
    jsr BANK_SET
    ldb #$a0
    jsr CMD_SEND
    jsr ADDR_GET
    lda DATA
    sta 0,x
    ;sta $c000
    jmp END

READ:
    PSHS D,X,CC     ; save the registers our setup code will effect
    ORCC #$50       ; = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET
    jsr BANK_SET
    jsr ADDR_GET
    lda 0,x
    *lda $c000
    sta DATA
    jmp END
  
ERASEALL:
    PSHS D,X,CC     ; save the registers our setup code will effect
    ORCC #$50       ; = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET
    jsr BANK_SET
    ldb #$80
    jsr CMD_SEND
    ldb #$10
    jsr CMD_SEND
    jmp END

END:
* go back to BASIC
    lda #0          ; turn off programming mode
    sta REG_BANK
    jsr SLOT_RESET  ; move back to previous MPI slot setting
    sta $ffdf
    PULS D,X,CC,PC  ; Restore the registers and the Condition Code which will reactive the FIRQ and IRQ and return back to BASIC
    END     START   ; Tell assembler when creating an DECB ML program to set the 'EXEC' address to wherever the label START is in RAM (above)
