REG_BANK = $ff40

    ORG 4000


BANK  .db $0          ; 4000
ADDR  .dw $0          ; 4001-02
DATA  .db $0          ; 4003
BUF   .dw $0          ; 4004-5
LEN   .dw $0          ; 4006-7
SLOT_FLASH .db 0      ; 4008
SLOT .db $0           ; 4009
    
    org 4010
START:                ; jump table
    jmp ERASEALL      ; +0
    *bra ERASE        ;
    jmp STORE         ; +3
    jmp READ          ; +6
    jmp FIND          ; +9
    jmp STOREBLOCK    ; +12
    jmp READBLOCK     ; +15

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

; TODO Should ensure this address is not more than 1eff
ADDR_GET:
    ldd ADDR        ; 0-16K value
    ora #%11000000  ; shift to $c000-$ffff
    tfr d,x
    rts

SLOT_SET:
    lda $ff7f       ; save off current MPI slot data
    sta SLOT
    clra            ; for now, assume MPI slot is #1
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
    jmp END

STOREBLOCK:
    PSHS D,X,CC     ; save the registers our setup code will effect
    ORCC #$50       ; = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET
    jsr BANK_SET
    jsr ADDR_GET    ; at the end of this, X = ADDR OR $c000
    tfr x,y
    ldu BUF
    ldx LEN
!:
    lda ,u+
    pshs D
    ldb #$a0
    jsr CMD_SEND    ; trashes a and b
    puls D
    sta ,y+
    leax -1,x
    bne <
    jmp END

READ:
    PSHS D,X,CC     ; save the registers our setup code will effect
    ORCC #$50       ; = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET
    jsr BANK_SET
    jsr ADDR_GET
    lda 0,x
    sta DATA
    jmp END

READBLOCK:
    PSHS D,X,CC     ; save the registers our setup code will effect
    ORCC #$50       ; = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET
    jsr BANK_SET
    jsr ADDR_GET    ; at the end of this, X = ADDR OR $c000
    tfr x,y
    ldu BUF
    ldx LEN
!:
    lda ,y+
    sta ,u+
    leax -1,x
    bne <
    jmp END

FIND:
    PSHS D,X,CC     ; save the registers our setup code will effect
    ORCC #$50       ; = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value
    jsr SLOT_SET    ; save off current slot setting
    clra
FINDLOOP:
    sta SLOT_FLASH  ; save off potentially correct Slot value
    sta $ff7f
    ldb #$90        ; read manufacturer ID
    jsr CMD_SEND
    ldb $c000       ; get manufacturer ID
    cmpb #01        ; Are we AMD?
    beq FOUND_AMD
    lda SLOT_FLASH
    adda #$11
    bcc FINDLOOP
    lda #$5a        ; no FLASH found
    sta SLOT_FLASH
    jmp END
FOUND_AMD:
    ldb #$90
    jsr CMD_SEND
    lda $c001       ; get product ID
    cmpa #$a4       ; Are we 29F040B
    beq END
    lda #$a5        ; No 29F040B found
    sta SLOT_FLASH
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
    clra            ; turn off programming mode
    sta REG_BANK
    jsr SLOT_RESET  ; move back to previous MPI slot setting
    sta $ffdf
    PULS D,X,CC,PC  ; Restore the registers and the Condition Code which will reactive the FIRQ and IRQ and return back to BASIC
    END     START   ; Tell assembler when creating an DECB ML program to set the 'EXEC' address to wherever the label START is in RAM (above)
