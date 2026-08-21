; ---------------------------------------------------------------------------
; PB3 architecture proof: the contents of block B position 31 (physical bank
; 63), which is what the mapper-45 power-on state maps to $E000.
;
; It programs the outer bank registers for its own block, then uses a RAM
; trampoline to switch to a game block and take that block's reset vector.
; ---------------------------------------------------------------------------
        .setcpu "6502"

; --- mapper 45 outer register values, one row per 256K block ----------------
; reg0 = CHR-OR, reg1 = PRG-OR, reg2 = CHR-AND + CHR high, reg3 = PRG-AND, unlocked
BLK_PB2_R0 = $00
BLK_PB2_R1 = $00
BLK_PB2_R2 = $0F
BLK_PB2_R3 = $20

BLK_SHL_R0 = $00
BLK_SHL_R1 = $20
BLK_SHL_R2 = $0F
BLK_SHL_R3 = $20

BLK_SOL_R0 = $00
BLK_SOL_R1 = $40
BLK_SOL_R2 = $1F
BLK_SOL_R3 = $20

OUTER      = $6000

; --- PB3 globals, in the page the engines' RAM-clear loops will be patched to
;     leave alone -------------------------------------------------------------
PB3_MAGIC  = $07F0          ; $5A when the shell has run
PB3_GAME   = $07F1          ; 0 = Power Blade 2, 1 = Solbrain
PB3_STAGE  = $07F2          ; engine-local stage number
PB3_PLAYERS= $07F3          ; 1 or 2
MAGIC_VAL  = $5A

; --- the RAM trampoline lives here; banking never touches RAM ---------------
TRAMP      = $0180

        .segment "BANK31"

; ===========================================================================
Reset:
        sei
        cld
        ldx #$FF
        txs
        inx                     ; X = 0
        stx $2000
        stx $2001

        ; program our own block; $E000 keeps pointing at this same bank
        lda #BLK_SHL_R0
        sta OUTER
        lda #BLK_SHL_R1
        sta OUTER
        lda #BLK_SHL_R2
        sta OUTER
        lda #BLK_SHL_R3
        sta OUTER

        ; wait for the PPU to warm up
        bit $2002
:       bit $2002
        bpl :-
:       bit $2002
        bpl :-

        ; --- stand-in for the shell menu: choose Power Blade 2, stage 1, 2P ---
        .ifndef BOOTGAME
        BOOTGAME = 0
        .endif
        lda #BOOTGAME
        sta PB3_GAME
        lda #1
        sta PB3_STAGE
        lda #2
        sta PB3_PLAYERS

        jsr LaunchGame
        ; never returns

; ===========================================================================
; LaunchGame: PB3_GAME selects the block.  Copies the trampoline into RAM,
; seeds the globals, then jumps to RAM so that changing what is mapped at
; $E000 cannot pull the ground out from under the running code.
; ===========================================================================
LaunchGame:
        sei
        lda #0
        sta $2000               ; NMI off before the banks move
        sta $2001

        ; copy the trampoline
        ldx #TrampEnd - TrampSrc - 1
:       lda TrampSrc,x
        sta TRAMP,x
        dex
        bpl :-

        ; patch the four register values into the trampoline for this block
        lda PB3_GAME
        asl a
        asl a
        tax                     ; X = game * 4
        ldy #1                  ; the immediates sit at trampoline offsets 1,6,11,16
:       lda BlockRegs,x
        sta TRAMP,y
        inx
        tya
        clc
        adc #5                  ; each "lda #imm / sta OUTER" pair is 5 bytes
        tay
        cpy #20
        bcc :-

        ; clear the globals page, then re-seed what the engine must see
        lda PB3_GAME
        pha
        lda PB3_STAGE
        pha
        lda PB3_PLAYERS
        pha
        lda #0
        ldx #0
:       sta $0700,x
        inx
        bne :-
        pla
        sta PB3_PLAYERS
        pla
        sta PB3_STAGE
        pla
        sta PB3_GAME
        lda #MAGIC_VAL
        sta PB3_MAGIC

        jmp TRAMP

; --- the routine that actually runs from RAM --------------------------------
TrampSrc:
TrampR0:
        lda #BLK_PB2_R0
        sta OUTER
        lda #BLK_PB2_R1
        sta OUTER
        lda #BLK_PB2_R2
        sta OUTER
        lda #BLK_PB2_R3
        sta OUTER
        jmp ($FFFC)             ; take the new block's own reset vector
TrampEnd:

; --- outer register rows, indexed by PB3_GAME -------------------------------
BlockRegs:
        .byte BLK_PB2_R0, BLK_PB2_R1, BLK_PB2_R2, BLK_PB2_R3
        .byte BLK_SOL_R0, BLK_SOL_R1, BLK_SOL_R2, BLK_SOL_R3

Nmi:    rti
Irq:    rti

        .segment "VECTORS"
        .word Nmi, Reset, Irq
