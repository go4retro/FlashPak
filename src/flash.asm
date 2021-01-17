        ORG     4000

REG_BANK = $ff40
BANK .db $0 ; 4000
ADDR .dw $0  ; 4001-02
DATA .db $0  ; 4003
SLOT .db $0
    
    org 4010
START:
    bra ERASEALL
    *bra ERASE
    bra STORE
    bra READ

PREP:
    lda #$aa
    sta $c555
    lda #$55
    sta $c2aa
*    lda #$a0
    stb $c555
    rts

SETBANK
    lda BANK
    ora #128
    sta REG_BANK
    rts

SLOT_SET:
    lda $ff7f
    sta SLOT
    lda #0
    sta $ff7f
    sta $ffde ; switch ROMs in
    rts

SLOT_RESET:
    lda SLOT
    sta $ff7f
    rts

STORE:
    PSHS   D,X,CC     * save the registers our setup code will effect
    ORCC   #$50       * = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET
    jsr SETBANK
    ldb #$a0
    jsr PREP
    lda DATA
    sta $c000
    jmp END

READ:
    PSHS   D,X,CC     * save the registers our setup code will effect
    ORCC   #$50       * = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET
    jsr SETBANK
    lda $c000
    sta DATA
    jmp END
  
ERASEALL:
    PSHS   D,X,CC     * save the registers our setup code will effect
    ORCC   #$50       * = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET
    jsr SETBANK
    ldb #$80
    jsr PREP
    ldb #$10
    jsr PREP
    jmp END

END:
* go back to BASIC
    lda #0
    sta REG_BANK
    jsr SLOT_RESET
    sta $ffdf
    PULS    D,X,CC,PC * Restore the registers and the Condition Code which will reactive the FIRQ and IRQ and return back to BASIC
    END     START     * Tell assembler when creating an DECB ML program to set the 'EXEC' address to wherever the label START is in RAM (above)
