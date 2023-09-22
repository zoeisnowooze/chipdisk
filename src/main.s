.segment "ZEROPAGE": zeropage

TMP = $57
TMP2 = $58

setwavefrequency = $59
setwaveshiftreg = $60

.segment "CODE"

main:
    lda #255      ; gfx mode
    sta 36869
    lda #8        ; screen and border colors
    sta 36879
    lda #16+1     ; aux col, volume
    sta 36878
    
ldx #0                 ; clrscr
cll:
    lda #1
    sta 38400,x     ; color memory
    sta 38400+256,x
    lda #32+128
    sta 7680,x      ; screen memory
    sta 7680+256,x
    lda #0
    sta 7168,x
    sta 7168+256,x
    dex
    bne cll

ldx #21
clo:
    lda #7
    sta 38400+(22*20),x
    lda #2
    sta 38400+(22*21),x
    lda #7
    sta 38400+(22*18),x
    lda #2
    sta 38400+(22*17),x
    lda #7
    sta 38400+(22*15),x
    lda #2
    sta 38400+(22*14),x
    dex
    bpl clo

ldx #0
clc
huu:
    lda alapesu,x
    and #1
    adc #77+128
    sta 7680,x
    inx
    bne huu

    ldx #21
    lda #1
    clc
alapesu:
    sta 7680+(22*20),x
    sta 7680+(22*17),x
    sta 7680+(22*14),x
    adc #1
    sta 7680+(22*21),x
    sta 7680+(22*18),x
    sta 7680+(22*15),x
    adc #1
    dex
    bpl alapesu

    lda #15
    sta 36878

    lda #$ff         ; blayerin juttuja
    sta 251
    sta 252
    sta 253

    sei

    lda #<irq       ; set irq
    sta $314
    lda #>irq
    sta $315

    lda #0          ; reset lowtimer
    sta 162

    lda #$c0
    sta $912e       ; enable tym
    cli

    jsr waitr
    brk

    sei
    lda #<60095
    sta $314
    lda #>60095
    sta $315
    cli

    rts

waitr:
    ldx #1
    bne waitr
    lda #1
    sta waitr+1
    rts

irq:
    lda $9124       ; akn  tartteeko???

    lda #1
    bit 162
    bne irqsg

    jsr player

irqsg:
    ldx #7

sgjo:
    clc
    rol 7168+( 0*16),x
    rol 7168+( 1*16)-2,x
    rol 7168+( 2*16)-4,x
    rol 7168+( 3*16)-6,x
    rol 7168+( 4*16)-8,x
    rol 7168+( 5*16)-6,x
    rol 7168+( 6*16)-4,x
    rol 7168+( 7*16)-2,x
    rol 7168+( 8*16)-0,x
    rol 7168+( 9*16)-2,x
    rol 7168+(10*16)-4,x
    rol 7168+(11*16)-6,x
    rol 7168+(12*16)-8,x
    rol 7168+(13*16)-6,x
    rol 7168+(14*16)-4,x
    rol 7168+(15*16)-2,x
    rol 7168+(16*16)-0,x
    rol 7168+(17*16)-2,x
    rol 7168+(18*16)-4,x
    rol 7168+(19*16)-6,x
    rol 7168+(20*16)-8,x
    rol 7168+(21*16)-6,x
    rol 7168+(22*16)-4,x
    rol 7168+(23*16)-2,x
    dex
    bpl sgjo

plumps:
    ldx #7          ; jookountteri
    dex
    stx plumps+1
    bne hii

    lda #7
    sta plumps+1

plum2:
    ldx #0          ; text counter
niin:
    lda text,x
    inc plum2+1
    bne luu
    ldy #0
    sty waitr+1
luu:
    sta 254
    lda #17
    sta 255

    clc
    rol 254
    rol 255
    clc
    rol 254
    rol 255
    clc
    rol 254
    rol 255

    ldy #7
plum3:
    lda (254),y
    sta 7168,y
    dey
    bpl plum3

hii:
    jmp 60095       ; exit

text:
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "
    .byte "hello titigre   "

player:
    lda 252         ; volume
    asl
    asl
    and #$f
    eor #$f
    sta 36878
    lsr             ; drumz
    lsr
    clc
    adc 253       ; 253=current drum
    tax
    lda drums,x
    sta 36877

    ldy 252
    iny
    tya
    and #$3
    sta 252
    beq nextnote
    rts

nextnote:
    inc 251

    lda 251         ; melody
    and #15
    tax
    lda drumtrak,x
    sta 253         ; tai suoraan koodiin.

    lda 251         ; melody
    and #127
    tax
    lda melody,x
    sta setwavefrequency

    and #15
    tax
    lda viznutwaveforms,x
    sta setwaveshiftreg

    ldy #11
    ldx setwavefrequency
    lda setwaveshiftreg
    jsr setwave

    rts

drums:
    .byte 0,0,0,0
    .byte 135,160,147,128
    .byte 230,221,232,223

drumtrak:
    .byte 4,0,0,0,8,0,0,0,4,0,0,0,8,0,4,0

melody:
    .byte 163,163,163,163,163,163,163,163, 163,163,163,163,163,163,163,163
    .byte 163,163,163,163,179,000,195,000, 187,187,187,000,187,179,000,163
    .byte 163,163,163,163,000,000,000,135, 163,163,163,135,163,163,163,135
    .byte 163,163,163,163,000,000,000,000, 000,000,000,000,000,000,000,000

    .byte 163,163,163,163,163,163,163,163, 163,195,000,187,187,179,000,163
    .byte 163,163,163,163,179,000,195,000, 187,187,187,000,187,179,000,163
    .byte 163,163,163,163,000,000,000,135, 163,163,163,135,163,163,163,135
    .byte 163,163,163,163,000,000,000,000, 000,000,000,000,000,000,000,000

setwave:
    .include "setwave.asm"
