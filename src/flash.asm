        ORG     4000

DATA = $ff40
START:
    PSHS   D,X,CC     * save the registers our setup code will effect
    ORCC   #$50       * = %01010000 this will Disable the FIRQ and the IRQs using the Condition Code register is [EFHINZVC] a high or 1 will disable that value

    lda #$aa
    sta $c555
    lda #$55
    sta $c2aa
    lda #$a0
    sta $c555
    lda #43
    sta $c000

* go back to BASIC
    PULS    D,X,CC,PC * Restore the registers and the Condition Code which will reactive the FIRQ and IRQ and return back to BASIC
    END     START     * Tell assembler when creating an DECB ML program to set the 'EXEC' address to wherever the label START is in RAM (above)
