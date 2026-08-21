
loc_8000:  ; 0 xrefs: 
8000  4C 3E 80 JMP sub_803E            

loc_8003:  ; 0 xrefs: 
8003  4C D9 80 JMP sub_80D9            

loc_8006:  ; 0 xrefs: 
8006  4C 3E 80 JMP sub_803E            

loc_8009:  ; 0 xrefs: 
8009  4C 9D 85 JMP loc_859D            

loc_800C:  ; 0 xrefs: 
800C  4C 8A 8B JMP loc_8B8A            

loc_800F:  ; 0 xrefs: 
800F  4C 3E 80 JMP sub_803E            

loc_8012:  ; 0 xrefs: 
8012  4C 65 8E JMP sub_8E65            

loc_8015:  ; 0 xrefs: 
8015  4C D2 8D JMP loc_8DD2            

loc_8018:  ; 0 xrefs: 
8018  4C 72 96 JMP loc_9672            

loc_801B:  ; 0 xrefs: 
801B  4C 44 80 JMP sub_8044            

loc_801E:  ; 0 xrefs: 
801E  4C 80 80 JMP loc_8080            

loc_8021:  ; 0 xrefs: 
8021  4C AB 80 JMP sub_80AB            

loc_8024:  ; 0 xrefs: 
8024  4C C8 9E JMP loc_9EC8            

loc_8027:  ; 0 xrefs: 
8027  4C A4 A1 JMP loc_A1A4            

loc_802A:  ; 0 xrefs: 
802A  4C E5 A4 JMP loc_A4E5            

loc_802D:  ; 0 xrefs: 
802D  4C FF AF JMP loc_AFFF            

; ==== data $8030..$8031  (2 bytes) ====
8030  63 B1                                            |c.

loc_8032:  ; 0 xrefs: 
8032  E2 B1    NOP #$B1                

; ==== data $8034..$8037  (4 bytes) ====
8034  22 BB D2 B9                                      |"...

loc_8038:  ; 0 xrefs: 
8038  4C 40 BB JMP loc_BB40            

loc_803B:  ; 0 xrefs: 
803B  4C C0 BD JMP loc_BDC0            

sub_803E:  ; 8 xrefs: 8000 8006 800F 85FD 8CBC A4AC A558 A5FB
803E  20 44 80 JSR sub_8044            
8041  4C AB 80 JMP sub_80AB            

sub_8044:  ; 2 xrefs: 801B 803E
8044  85 93    STA $93                 
8046  0A       ASL A                   
8047  A8       TAY                     
8048  B9 1F 81 LDA $811F,Y             
804B  85 08    STA $08                 
804D  B9 20 81 LDA $8120,Y             
8050  85 09    STA $09                 
8052  A9 00    LDA #$00                
8054  85 0A    STA $0A                 
8056  AA       TAX                     

loc_8057:  ; 1 xrefs: 807D
8057  A4 0A    LDY $0A                 
8059  B1 08    LDA ($08),Y             
805B  A8       TAY                     
805C  B9 F5 82 LDA $82F5,Y             
805F  85 0B    STA $0B                 
8061  B9 7D 83 LDA $837D,Y             
8064  85 0C    STA $0C                 
8066  A9 0F    LDA #$0F                
8068  20 A6 80 JSR sub_80A6            
806B  A0 00    LDY #$00                

loc_806D:  ; 1 xrefs: 8075
806D  B1 0B    LDA ($0B),Y             
806F  20 A6 80 JSR sub_80A6            
8072  C8       INY                     
8073  C0 03    CPY #$03                
8075  D0 F6    BNE loc_806D            
8077  E6 0A    INC $0A                 
8079  A5 0A    LDA $0A                 
807B  C9 08    CMP #$08                
807D  D0 D8    BNE loc_8057            
807F  60       RTS                     

loc_8080:  ; 1 xrefs: 801E
8080  85 08    STA $08                 
8082  86 09    STX $09                 
8084  A8       TAY                     
8085  B9 F5 82 LDA $82F5,Y             
8088  85 0B    STA $0B                 
808A  B9 7D 83 LDA $837D,Y             
808D  85 0C    STA $0C                 
808F  A5 09    LDA $09                 
8091  0A       ASL A                   
8092  0A       ASL A                   
8093  AA       TAX                     
8094  A0 00    LDY #$00                
8096  A9 0F    LDA #$0F                
8098  20 A6 80 JSR sub_80A6            

loc_809B:  ; 1 xrefs: 80A3
809B  B1 0B    LDA ($0B),Y             
809D  20 A6 80 JSR sub_80A6            
80A0  C8       INY                     
80A1  C0 03    CPY #$03                
80A3  D0 F6    BNE loc_809B            
80A5  60       RTS                     

sub_80A6:  ; 4 xrefs: 8068 806F 8098 809D
80A6  9D E0 03 STA $03E0,X             

loc_80A9:  ; 0 xrefs: 
80A9  E8       INX                     
80AA  60       RTS                     

sub_80AB:  ; 3 xrefs: 8021 8041 8101
80AB  20 40 C8 JSR $C840               
80AE  A9 00    LDA #$00                
80B0  20 49 C8 JSR $C849               
80B3  A9 3F    LDA #$3F                
80B5  20 49 C8 JSR $C849               
80B8  A0 00    LDY #$00                

loc_80BA:  ; 1 xrefs: 80C3
80BA  B9 E0 03 LDA $03E0,Y             
80BD  20 49 C8 JSR $C849               
80C0  C8       INY                     
80C1  C0 20    CPY #$20                
80C3  D0 F5    BNE loc_80BA            
80C5  20 46 C8 JSR $C846               
80C8  20 40 C8 JSR $C840               
80CB  A0 00    LDY #$00                

loc_80CD:  ; 1 xrefs: 80D6
80CD  B9 18 81 LDA $8118,Y             
80D0  20 49 C8 JSR $C849               
80D3  C8       INY                     
80D4  C0 07    CPY #$07                
80D6  D0 F5    BNE loc_80CD            
80D8  60       RTS                     

sub_80D9:  ; 6 xrefs: 8003 85D2 8816 889F A5B5 B05C
80D9  20 06 81 JSR sub_8106            
80DC  90 01    BCC loc_80DF            
80DE  60       RTS                     

loc_80DF:  ; 1 xrefs: 80DC
80DF  A5 1C    LDA $1C                 
80E1  29 0F    AND #$0F                
80E3  D0 1F    BNE loc_8104            
80E5  A2 00    LDX #$00                

loc_80E7:  ; 1 xrefs: 80FF
80E7  BD E0 03 LDA $03E0,X             
80EA  C9 0F    CMP #$0F                
80EC  F0 0E    BEQ loc_80FC            
80EE  29 30    AND #$30                
80F0  D0 04    BNE loc_80F6            
80F2  A9 0F    LDA #$0F                
80F4  D0 03    BNE loc_80F9            

loc_80F6:  ; 1 xrefs: 80F0
80F6  38       SEC                     
80F7  E9 10    SBC #$10                

loc_80F9:  ; 1 xrefs: 80F4
80F9  9D E0 03 STA $03E0,X             

loc_80FC:  ; 1 xrefs: 80EC
80FC  E8       INX                     
80FD  E0 20    CPX #$20                
80FF  D0 E6    BNE loc_80E7            
8101  20 AB 80 JSR sub_80AB            

loc_8104:  ; 1 xrefs: 80E3
8104  18       CLC                     
8105  60       RTS                     

sub_8106:  ; 1 xrefs: 80D9
8106  A2 00    LDX #$00                

loc_8108:  ; 1 xrefs: 8112
8108  BD E0 03 LDA $03E0,X             
810B  C9 0F    CMP #$0F                
810D  D0 07    BNE loc_8116            
810F  E8       INX                     
8110  E0 20    CPX #$20                
8112  D0 F4    BNE loc_8108            
8114  38       SEC                     
8115  60       RTS                     

loc_8116:  ; 1 xrefs: 810D
8116  18       CLC                     
8117  60       RTS                     

; ==== data $8118..$81A4  (141 bytes) ====
8118  00 3F FF 01 00 00 FF 7D 81 85 81 8D 81 95 81 9D  |.?.....}........
8128  81 A5 81 AD 81 B5 81 BD 81 C5 81 CD 81 D5 81 DD  |................
8138  81 E5 81 ED 81 F5 81 FD 81 05 82 0D 82 15 82 1D  |................
8148  82 25 82 2D 82 35 82 3D 82 45 82 4D 82 55 82 5D  |.%.-.5.=.E.M.U.]
8158  82 65 82 6D 82 75 82 7D 82 85 82 8D 82 95 82 9D  |.e.m.u.}........
8168  82 A5 82 AD 82 B5 82 BD 82 C5 82 CD 82 D5 82 DD  |................
8178  82 E5 82 ED 82 16 17 18 19 62 0F 10 07 00 01 04  |.........b......
8188  05 0E 0F 10 07 00 01 02 03 0E 0F 10 07 06 07 08  |................
8198  09 0A 0B 0C 0D 00 11 12 13 0E 0F 10 07           |.............

loc_81A5:  ; 0 xrefs: 
81A5  00 11    BRK #$11                

; ==== data $81A7..$83A4  (510 bytes) ====
81A7  12 14 0E 0F 10 07 00 11 15 13 0E 0F 10 07 00 1A  |................
81B7  1B 1C 0E 0F 10 07 00 1D 1E 1F 0E 0F 10 07 00 20  |............... 
81C7  21 22 0E 0F 10 07 00 1D 23 24 0E 0F 10 07 00 01  |!"......#$......
81D7  25 26 0E 0F 10 07 00 27 28 29 0E 0F 10 07 00 2A  |%&.....'().....*
81E7  2B 2C 0E 0F 10 07 00 2A 2B 2D 0E 0F 10 07 00 2A  |+,.....*+-.....*
81F7  2E 2F 0E 0F 10 07 00 2A 2B 49 0E 0F 10 07 00 30  |./.....*+I.....0
8207  31 32 0E 0F 10 07 00 33 31 34 0E 0F 10 07 00 35  |12.....314.....5
8217  31 34 0E 0F 10 07 00 36 37 38 0E 0F 10 07 39 3A  |14.....678....9:
8227  3B 3C 62 0F 10 07 00 42 43 44 0E 0F 10 07 00 42  |;<b....BCD.....B
8237  34 45 0E 0F 10 07 00 42 46 36 0E 0F 10 07 00 42  |4E.....BF6.....B
8247  38 37 0E 0F 10 07 00 48 49 4A 0E 0F 10 07 00 4B  |87.....HIJ.....K
8257  4C 4D 0E 0F 10 07 00 4B 4E 4D 0E 0F 10 07 00 4B  |LM.....KNM.....K
8267  4F 4D 0E 0F 10 07 00 4B 49 4D 0E 0F 10 07 00 4B  |OM.....KIM.....K
8277  4D 4C 0E 0F 10 07 00 4B 48 4D 0E 0F 10 07 51 52  |ML.....KHM....QR
8287  53 54 0E 0F 10 07 84 85 56 57 60 61 61 61 51 55  |ST......VW`aaaQU
8297  58 55 60 61 10 07 51 55 59 55 60 61 10 07 51 5A  |XU`a..QUYU`a..QZ
82A7  5B 54 0E 0F 10 07 5C 5D 5E 5F 0E 0F 10 07 51 54  |[T....\]^_....QT
82B7  54 54 0E 0F 10 07 51 55 56 57 60 61 10 07 67 68  |TT....QUVW`a..gh
82C7  69 6A 63 64 65 66 67 6B 6C 6D 63 64 65 66 67 6C  |ijcdefgklmcdefgl
82D7  6E 6F 63 64 65 66 67 80 81 82 63 64 65 66 84 85  |nocdefg...cdef..
82E7  56 57 0E 0F 10 07 87 87 87 87 87 87 87 87 05 08  |VW..............
82F7  0B 0E 11 14 17 1A 1D 20 23 26 29 2C 2F 32 35 38  |....... #&),/258
8307  3B 3E 41 44 47 4A 4D 50 53 56 59 5C 5F 62 65 68  |;>ADGJMPSVY\_beh
8317  6B 6E 71 74 77 7A 7D 80 83 86 89 8C 8F 92 95 98  |knqtwz}.........
8327  9B 9E A1 A4 A7 AA AD B0 B3 B6 B9 BC BF C2 C8 C5  |................
8337  CB CE D1 D4 D7 DA DD E0 E3 E6 E9 EC EF F2 F5 F8  |................
8347  FB FE 01 04 07 0A 0D 10 13 16 19 1C 1F 22 25 28  |............."%(
8357  2B 2E 31 34 37 3A 3D 40 43 46 49 4C 4F 52 55 58  |+.147:=@CFILORUX
8367  5B 5E 61 64 67 6A 6D 70 73 76 79 7F 7C 82 85 88  |[^adgjmpsvy.|...
8377  8B 8E 91 94 97 9A 84 84 84 84 84 84 84 84 84 84  |................
8387  84 84 84 84 84 84 84 84 84 84 84 84 84 84 84 84  |................
8397  84 84 84 84 84 84 84 84 84 84 84 84 84 84        |..............

loc_83A5:  ; 0 xrefs: 
83A5  84 84    STY $84                 
83A7  84 84    STY $84                 
83A9  84 84    STY $84                 
83AB  84 84    STY $84                 
83AD  84 84    STY $84                 
83AF  84 84    STY $84                 
83B1  84 84    STY $84                 
83B3  84 84    STY $84                 
83B5  84 84    STY $84                 
83B7  84 84    STY $84                 
83B9  84 84    STY $84                 
83BB  84 84    STY $84                 
83BD  84 84    STY $84                 
83BF  84 84    STY $84                 
83C1  84 84    STY $84                 
83C3  84 84    STY $84                 
83C5  84 84    STY $84                 
83C7  84 84    STY $84                 
83C9  84 84    STY $84                 
83CB  84 84    STY $84                 
83CD  84 84    STY $84                 
83CF  84 84    STY $84                 
83D1  85 85    STA $85                 
83D3  85 85    STA $85                 
83D5  85 85    STA $85                 
83D7  85 85    STA $85                 
83D9  85 85    STA $85                 
83DB  85 85    STA $85                 
83DD  85 85    STA $85                 
83DF  85 85    STA $85                 
83E1  85 85    STA $85                 
83E3  85 85    STA $85                 
83E5  85 85    STA $85                 
83E7  85 85    STA $85                 
83E9  85 85    STA $85                 
83EB  85 85    STA $85                 
83ED  85 85    STA $85                 
83EF  85 85    STA $85                 
83F1  85 85    STA $85                 
83F3  85 85    STA $85                 
83F5  85 85    STA $85                 
83F7  85 85    STA $85                 
83F9  85 85    STA $85                 
83FB  85 85    STA $85                 
83FD  85 85    STA $85                 
83FF  85 85    STA $85                 
8401  85 85    STA $85                 
8403  85 85    STA $85                 
8405  27 16    RLA $16                 
8407  38       SEC                     
8408  17 06    SLO $06,X               
840A  38       SEC                     
840B  11 01    ORA ($01),Y             
840D  23 1A    RLA ($1A,X)             
840F  08       PHP                     
8410  39 1A 08 AND $081A,Y             
8413  39 18 06 AND $0618,Y             
8416  36 00    ROL $00,X               
8418  10 20    BPL loc_843A            
841A  07 18    SLO $18                 
841C  27 07    RLA $07                 
841E  18       CLC                     
841F  37 01    RLA $01,X               
8421  11 21    ORA ($21),Y             
8423  0F 18 37 SLO $3718               
8426  0F 22 31 SLO $3122               
8429  0F 16 36 SLO $3616               
842C  20 28 18 JSR $1828               
842F  0F 11 20 SLO $2011               
8432  0F 17 38 SLO $3817               
8435  0F 15 20 SLO $2015               
8438  10 00    BPL loc_843A            

loc_843A:  ; 2 xrefs: 8418 8438
843A  20 12 02 JSR $0212               

; ==== data $843D..$8580  (324 bytes) ====
843D  22 1C 0C 3C 18 08 28 15 05 35 21 15 10 21 11 20  |"..<..(..5!..!. 
844D  3C 2C 20 38 27 20 1C 0C 2C 16 06 36 1A 0A 3A 08  |<, 8' ..,..6..:.
845D  0F 18 10 00 20 19 09 29 04 0F 14 11 01 31 06 0F  |.... ..).....1..
846D  16 10 00 20 13 03 23 12 11 31 15 04 34 00 00 20  |... ..#..1..4.. 
847D  0B 0F 1B 1C 0F 2C 10 00 20 11 01 21 14 04 24 1C  |.....,.. ..!..$.
848D  0C 2C 2B 1B 3B 27 17 37 27 16 36 15 05 25 1C 0C  |.,+.;'.7'.6..%..
849D  21 2B 1B 20 1C 0C 2C 28 18 20 10 00 20 16 06 26  |!+. ..,(. .. ..&
84AD  1B 0B 2B 37 27 20 27 17 30 15 15 15 37 37 37 0F  |..+7' '.0...777.
84BD  18 37 0F 25 35 0F 27 38 0F 2B 3B 0F 22 31 16 05  |.7.%5.'8.+;."1..
84CD  25 11 01 22 14 04 34 1A 0A 2A 13 03 23 1A 09 3A  |%.."..4..*..#..:
84DD  18 08 28 15 05 25 11 01 21 10 00 20 1B 0B 2B 1C  |..(..%..!.. ..+.
84ED  0C 2C 13 03 23 11 01 21 1B 0B 2B 28 37 20 34 24  |.,..#..!..+(7 4$
84FD  16 28 37 34 28 37 12 28 37 0F 31 0F 0F 28 37 31  |.(74(7.(7.1..(71
850D  0F 31 0F 0F 0F 31 37 14 12 28 37 14 1A 2A 20 1A  |.1...17..(7..* .
851D  2A 15 1A 2A 3A 19 29 12 0F 37 28 31 31 31 15 25  |*..*:.)..7(111.%
852D  35 0F 17 37 0F 22 31 0F 16 36 0F 0F 30 10 00 20  |5..7."1..6..0.. 
853D  0F 01 22 22 23 24 10 00 0F 01 22 23 23 24 25 10  |..""#$...."##$%.
854D  00 01 25 37 27 10 00 23 0F 00 20 0F 16 36 15 26  |..%7'..#.. ..6.&
855D  37 0F 14 34 0F 1A 3A 0F 17 37 0F 31 33 0F 17 37  |7..4..:..7.13..7
856D  0F 1B 3B 0F 04 24 0F 15 35 0F 19 39 05 15 25 01  |..;..$..5..9..%.
857D  1C 2C 07 17                                      |.,..

loc_8581:  ; 0 xrefs: 
8581  27 0A    RLA $0A                 
8583  1A       NOP                     
8584  2A       ROL A                   
8585  33 34    RLA ($34),Y             
8587  35 35    AND $35,X               
8589  36 37    ROL $37,X               
858B  10 00    BPL loc_858D            

loc_858D:  ; 1 xrefs: 858B
858D  33 10    RLA ($10),Y             
858F  00 20    BRK #$20                

; ==== data $8591..$859C  (12 bytes) ====
8591  28 37 30 15 12 28 0F 17 37 0F 0F 0F              |(70..(..7...

loc_859D:  ; 1 xrefs: 8009
859D  A5 19    LDA $19                 
859F  20 4F C8 JSR $C84F               

; ==== data $85A2..$85D1  (48 bytes) ====
85A2  D2 85 24 86 35 86 5E 86 67 86 74 86 7D 86 A0 86  |..$.5.^.g.t.}...
85B2  AC 86 C5 86 D8 86 14 87 1C 87 8A 87 A2 87 A7 87  |................
85C2  C0 87 EF 87 16 88 2F 88 38 88 81 88 9F 88 C3 88  |....../.8.......

loc_85D2:  ; 0 xrefs: 
85D2  20 D9 80 JSR sub_80D9            
85D5  B0 01    BCS loc_85D8            
85D7  60       RTS                     

loc_85D8:  ; 1 xrefs: 85D5
85D8  20 3D C8 JSR $C83D               
85DB  A9 45    LDA #$45                
85DD  20 1C C8 JSR $C81C               
85E0  20 82 C8 JSR $C882               
85E3  20 13 C8 JSR $C813               
85E6  A9 0C    LDA #$0C                
85E8  85 87    STA $87                 
85EA  A9 00    LDA #$00                
85EC  85 50    STA $50                 
85EE  85 4F    STA $4F                 
85F0  8D 6C 01 STA $016C               
85F3  8D 6F 01 STA $016F               
85F6  A2 18    LDX #$18                
85F8  20 4C C8 JSR $C84C               
85FB  A9 22    LDA #$22                
85FD  20 3E 80 JSR sub_803E            
8600  A0 1A    LDY #$1A                
8602  84 42    STY $42                 
8604  C8       INY                     
8605  84 43    STY $43                 
8607  A0 3C    LDY #$3C                
8609  84 44    STY $44                 
860B  C8       INY                     
860C  84 45    STY $45                 
860E  A9 5B    LDA #$5B                
8610  8D 42 04 STA $0442               
8613  A9 80    LDA #$80                
8615  8D 08 05 STA $0508               
8618  A9 60    LDA #$60                
861A  8D C6 04 STA $04C6               
861D  A9 D0    LDA #$D0                
861F  85 51    STA $51                 
8621  4C 9A C8 JMP $C89A               

; ==== data $8624..$8629  (6 bytes) ====
8624  20 7C 8B 90 01 60                                | |...`

loc_862A:  ; 0 xrefs: 
862A  20 B7 A4 JSR sub_A4B7            
862D  C6 51    DEC $51                 
862F  F0 01    BEQ loc_8632            
8631  60       RTS                     

loc_8632:  ; 1 xrefs: 862F
8632  4C 9A C8 JMP $C89A               

; ==== data $8635..$86C4  (144 bytes) ====
8635  20 7C 8B 90 01 60 20 B7 A4 20 D9 80 B0 01 60 A9  | |...` .. ....`.
8645  00 85 FD 85 50 8D 6C 01 8D 6F 01 A9 A8 85 FF 20  |....P.l..o..... 
8655  3E A7 A9 02 85 87 4C 9A C8 20 7C 8B 90 01 60 4C  |>.....L.. |...`L
8665  32 A6 20 7C 8B 90 01 60 A9 04 A2 1A 4C E0 A5 20  |2. |...`....L.. 
8675  7C 8B 90 01 60 4C E6 A5 20 7C 8B 90 01 60 A9 5E  ||...`L.. |...`.^
8685  8D 42 04 A9 50 8D C6 04 A9 00 85 50 8D 6C 01 8D  |.B..P......P.l..
8695  6F 01 A9 80 85 51 A9 28 4C FB A5 20 7C 8B 90 01  |o....Q.(L.. |...
86A5  60 20 82 A4 4C AA A5 20 7C 8B 90 01 60 A9 00 85  |` ..L.. |...`...
86B5  51 85 4F 8D 6C 01 8D 6F 01 85 50 85 87 4C B5 A5  |Q.O.l..o..P..L..

loc_86C5:  ; 0 xrefs: 
86C5  20 CE 88 JSR sub_88CE            
86C8  A9 02    LDA #$02                
86CA  85 9F    STA $9F                 
86CC  A9 00    LDA #$00                
86CE  85 98    STA $98                 
86D0  A9 10    LDA #$10                
86D2  8D 9A 04 STA $049A               
86D5  4C 9A C8 JMP $C89A               

; ==== data $86D8..$87A5  (206 bytes) ====
86D8  20 3D C8 A9 44 20 1C C8 A9 03 85 87 A9 A8 85 89  | =..D ..........
86E8  A9 00 85 88 A9 D8 8D 09 05 A9 50 8D 43 04 A9 18  |..........P.C...
86F8  8D C7 04 A9 00 A2 00 20 3A C8 A9 80 8D 08 05 A9  |....... :.......
8708  C8 8D C6 04 A9 03 20 3E 80 4C 9A C8 A2 00 20 37  |...... >.L.... 7
8718  C8 4C F2 88 A2 00 20 37 C8 A5 48 29 10 D0 09 A5  |.L.... 7..H)....
8728  48 4A B0 1A 4A B0 37 60 20 69 89 B0 FA A9 12 85  |HJ..J.7` i......
8738  19 A9 53 8D 42 04 20 3D C8 A9 29 4C 1C C8 AD 2C  |..S.B. =..)L...,
8748  04 29 40 D0 2A A5 5B C9 0F D0 07 A5 22 C9 04 D0  |.)@.*.[....."...
8758  08 60 A5 22 C9 03 D0 01 60 E6 22 4C 9A C8 AD 2C  |.`."....`."L...,
8768  04 29 40 F0 0A A5 22 D0 01 60 C6 22 4C 9A C8 A9  |.)@..."..`."L...
8778  54 8D 42 04 A9 08 8D A2 05 A9 0F 85 19 A9 36 4C  |T.B...........6L
8788  1C C8 A2 00 20 37 C8 20 85 89 90 01 60 AD 2C 04  |.... 7. ....`.,.
8798  29 40 D0 03 4C F2 88 4C 23 89 A9 0C 85 19        |)@..L..L#.....

loc_87A6:  ; 0 xrefs: 
87A6  60       RTS                     

; ==== data $87A7..$8809  (99 bytes) ====
87A7  CE A2 05 D0 13 AD 2C 04 49 40 8D 2C 04 A9 00 A2  |......,.I@.,....
87B7  00 20 3A C8 A9 0C 85 19 60 20 DB 89 CE CE 05 F0  |. :.....` ......
87C7  15 AD 2C 04 29 40 D0 07 EE 08 05 EE 08 05 60 CE  |..,.)@........`.
87D7  08 05 CE 08 05 60 AD 2C 04 49 40 8D 2C 04 A2 00  |.....`.,.I@.,...
87E7  A9 00 20 3A C8 4C 9A C8 A2 00 20 37 C8 AD 2C 04  |.. :.L.... 7..,.
87F7  29 40 D0 09 EE 08 05 EE 08 05 4C 0A 88 CE 08 05  |)@........L.....
8807  CE 08 05                                         |...

loc_880A:  ; 0 xrefs: 
880A  AD 08 05 LDA $0508               
880D  C9 80    CMP #$80                
880F  D0 04    BNE loc_8815            
8811  A9 0D    LDA #$0D                
8813  85 19    STA $19                 

loc_8815:  ; 1 xrefs: 880F
8815  60       RTS                     

loc_8816:  ; 0 xrefs: 
8816  20 D9 80 JSR sub_80D9            
8819  B0 01    BCS loc_881C            
881B  60       RTS                     

loc_881C:  ; 1 xrefs: 8819
881C  20 82 C8 JSR $C882               
881F  A5 22    LDA $22                 
8821  85 53    STA $53                 
8823  A9 00    LDA #$00                
8825  85 9C    STA $9C                 
8827  85 87    STA $87                 
8829  20 13 C8 JSR $C813               
882C  4C 9A C8 JMP $C89A               

; ==== data $882F..$889E  (112 bytes) ====
882F  A9 00 85 19 85 1A E6 18 60 20 CE 88 20 13 C8 A5  |........` .. ...
883F  53 85 22 0A A8 B9 FA 89 85 00 B9 FB 89 85 01 A0  |S.".............
884F  00 B1 00 85 FD C8 B1 00 85 FF C8 B1 00 8D 09 05  |................
885F  A9 50 8D 43 04 A9 18 8D C7 04 A9 00 85 9A 85 27  |.P.C...........'
886F  A2 00 20 3A C8 A9 80 8D 08 05 A9 C8 8D C6 04 4C  |.. :...........L
887F  9A C8 20 3D C8 A9 44 20 1C C8 A9 03 85 87 A9 A8  |.. =..D ........
888F  85 89 A9 00 85 88 A9 0C 85 19 A9 03 20 3E 80 60  |............ >.`

loc_889F:  ; 0 xrefs: 
889F  20 D9 80 JSR sub_80D9            
88A2  B0 01    BCS loc_88A5            
88A4  60       RTS                     

loc_88A5:  ; 1 xrefs: 88A2
88A5  20 3D C8 JSR $C83D               
88A8  20 82 C8 JSR $C882               
88AB  20 13 C8 JSR $C813               
88AE  A9 00    LDA #$00                
88B0  85 51    STA $51                 
88B2  85 50    STA $50                 
88B4  85 4F    STA $4F                 
88B6  85 87    STA $87                 
88B8  85 FD    STA $FD                 
88BA  A9 A8    LDA #$A8                
88BC  85 FF    STA $FF                 
88BE  A9 09    LDA #$09                
88C0  85 19    STA $19                 
88C2  60       RTS                     

; ==== data $88C3..$88CD  (11 bytes) ====
88C3  20 D9 80 B0 01 60 A9 14 85 19 60                 | ....`....`

sub_88CE:  ; 1 xrefs: 86C5
88CE  20 82 C8 JSR $C882               
88D1  A0 24    LDY #$24                
88D3  84 42    STY $42                 
88D5  C8       INY                     
88D6  84 43    STY $43                 
88D8  A0 46    LDY #$46                
88DA  84 44    STY $44                 
88DC  C8       INY                     
88DD  84 45    STY $45                 
88DF  A9 00    LDA #$00                
88E1  85 22    STA $22                 
88E3  A2 08    LDX #$08                
88E5  20 4C C8 JSR $C84C               
88E8  20 13 8A JSR sub_8A13            
88EB  A9 20    LDA #$20                
88ED  85 FD    STA $FD                 
88EF  4C 13 C8 JMP $C813               

loc_88F2:  ; 0 xrefs: 
88F2  E6 88    INC $88                 
88F4  E6 88    INC $88                 
88F6  E6 88    INC $88                 
88F8  E6 88    INC $88                 
88FA  D0 0D    BNE loc_8909            
88FC  A5 89    LDA $89                 
88FE  49 01    EOR #$01                
8900  85 89    STA $89                 
8902  29 01    AND #$01                
8904  D0 03    BNE loc_8909            
8906  20 9A C8 JSR $C89A               

loc_8909:  ; 2 xrefs: 88FA 8904
8909  A5 88    LDA $88                 
890B  29 07    AND #$07                
890D  D0 0A    BNE loc_8919            
890F  E6 FD    INC $FD                 
8911  D0 06    BNE loc_8919            
8913  A5 FF    LDA $FF                 
8915  49 01    EOR #$01                
8917  85 FF    STA $FF                 

loc_8919:  ; 2 xrefs: 890D 8911
8919  A5 88    LDA $88                 
891B  29 0F    AND #$0F                
891D  D0 03    BNE loc_8922            
891F  CE 09 05 DEC $0509               

loc_8922:  ; 1 xrefs: 891D
8922  60       RTS                     

loc_8923:  ; 0 xrefs: 
8923  C6 88    DEC $88                 
8925  C6 88    DEC $88                 
8927  C6 88    DEC $88                 
8929  C6 88    DEC $88                 
892B  A5 88    LDA $88                 
892D  C9 FC    CMP #$FC                
892F  D0 09    BNE loc_893A            
8931  A5 89    LDA $89                 
8933  49 01    EOR #$01                
8935  85 89    STA $89                 
8937  4C 47 89 JMP loc_8947            

loc_893A:  ; 1 xrefs: 892F
893A  A5 88    LDA $88                 
893C  D0 09    BNE loc_8947            
893E  A5 89    LDA $89                 
8940  29 01    AND #$01                
8942  D0 03    BNE loc_8947            
8944  20 9A C8 JSR $C89A               

loc_8947:  ; 3 xrefs: 8937 893C 8942
8947  A5 88    LDA $88                 
8949  29 07    AND #$07                
894B  C9 04    CMP #$04                
894D  D0 0E    BNE loc_895D            
894F  C6 FD    DEC $FD                 
8951  A5 FD    LDA $FD                 
8953  C9 FF    CMP #$FF                
8955  D0 06    BNE loc_895D            
8957  A5 FF    LDA $FF                 
8959  49 01    EOR #$01                
895B  85 FF    STA $FF                 

loc_895D:  ; 2 xrefs: 894D 8955
895D  A5 88    LDA $88                 
895F  29 0F    AND #$0F                
8961  C9 0C    CMP #$0C                
8963  D0 03    BNE loc_8968            
8965  EE 09 05 INC $0509               

loc_8968:  ; 1 xrefs: 8963
8968  60       RTS                     

loc_8969:  ; 0 xrefs: 
8969  A4 22    LDY $22                 
896B  B9 7D 89 LDA $897D,Y             
896E  25 5B    AND $5B                 
8970  F0 09    BEQ loc_897B            
8972  B9 7D 89 LDA $897D,Y             
8975  25 56    AND $56                 
8977  F0 02    BEQ loc_897B            
8979  38       SEC                     
897A  60       RTS                     

loc_897B:  ; 2 xrefs: 8970 8977
897B  18       CLC                     
897C  60       RTS                     

; ==== data $897D..$8984  (8 bytes) ====
897D  01 02 04 08 10 20 40 80                          |..... @.

loc_8985:  ; 0 xrefs: 
8985  A5 48    LDA $48                 
8987  4A       LSR A                   
8988  B0 04    BCS loc_898E            
898A  4A       LSR A                   
898B  B0 0A    BCS loc_8997            
898D  60       RTS                     

loc_898E:  ; 1 xrefs: 8988
898E  AD 2C 04 LDA $042C               
8991  29 40    AND #$40                
8993  D0 0B    BNE loc_89A0            
8995  F0 07    BEQ loc_899E            

loc_8997:  ; 1 xrefs: 898B
8997  AD 2C 04 LDA $042C               
899A  29 40    AND #$40                
899C  F0 07    BEQ loc_89A5            

loc_899E:  ; 1 xrefs: 8995
899E  18       CLC                     
899F  60       RTS                     

loc_89A0:  ; 1 xrefs: 8993
89A0  E6 22    INC $22                 
89A2  4C A7 89 JMP loc_89A7            

loc_89A5:  ; 1 xrefs: 899C
89A5  C6 22    DEC $22                 

loc_89A7:  ; 1 xrefs: 89A2
89A7  A9 54    LDA #$54                
89A9  8D 42 04 STA $0442               
89AC  A9 10    LDA #$10                
89AE  8D CE 05 STA $05CE               
89B1  A9 36    LDA #$36                
89B3  20 1C C8 JSR $C81C               
89B6  A9 55    LDA #$55                
89B8  8D 44 04 STA $0444               
89BB  8D E6 05 STA $05E6               
89BE  AD 08 05 LDA $0508               
89C1  8D 0A 05 STA $050A               
89C4  AD C6 04 LDA $04C6               
89C7  8D C8 04 STA $04C8               
89CA  AD 2C 04 LDA $042C               
89CD  8D 2E 04 STA $042E               
89D0  A9 00    LDA #$00                
89D2  8D D0 05 STA $05D0               
89D5  A9 10    LDA #$10                
89D7  85 19    STA $19                 
89D9  38       SEC                     
89DA  60       RTS                     

loc_89DB:  ; 0 xrefs: 
89DB  EE D0 05 INC $05D0               
89DE  AD D0 05 LDA $05D0               
89E1  C9 05    CMP #$05                
89E3  D0 14    BNE loc_89F9            
89E5  A9 00    LDA #$00                
89E7  8D D0 05 STA $05D0               
89EA  EE 44 04 INC $0444               
89ED  AD 44 04 LDA $0444               
89F0  C9 58    CMP #$58                
89F2  D0 05    BNE loc_89F9            
89F4  A2 02    LDX #$02                
89F6  4C 10 C8 JMP $C810               

loc_89F9:  ; 2 xrefs: 89E3 89F2
89F9  60       RTS                     

; ==== data $89FA..$8A12  (25 bytes) ====
89FA  04 8A 07 8A 0A 8A 0D 8A 10 8A 60 A8 B8 A0 A8 98  |..........`.....
8A0A  E0 A8 78 20 A9 58 60 A9 38                       |..x .X`.8

sub_8A13:  ; 1 xrefs: 88E8
8A13  20 B8 C8 JSR $C8B8               
8A16  A0 00    LDY #$00                
8A18  A5 5B    LDA $5B                 
8A1A  85 17    STA $17                 

loc_8A1C:  ; 1 xrefs: 8A2D
8A1C  84 16    STY $16                 
8A1E  A5 17    LDA $17                 
8A20  4A       LSR A                   
8A21  85 17    STA $17                 
8A23  90 05    BCC loc_8A2A            
8A25  20 51 8A JSR sub_8A51            
8A28  A4 16    LDY $16                 

loc_8A2A:  ; 1 xrefs: 8A23
8A2A  C8       INY                     
8A2B  C0 04    CPY #$04                
8A2D  D0 ED    BNE loc_8A1C            
8A2F  A5 5B    LDA $5B                 
8A31  C9 0F    CMP #$0F                
8A33  D0 19    BNE loc_8A4E            
8A35  A9 04    LDA #$04                
8A37  0A       ASL A                   
8A38  A8       TAY                     
8A39  B9 E2 8A LDA $8AE2,Y             
8A3C  85 0A    STA $0A                 
8A3E  B9 E3 8A LDA $8AE3,Y             
8A41  85 0B    STA $0B                 
8A43  A9 74    LDA #$74                
8A45  85 02    STA $02                 
8A47  A9 8B    LDA #$8B                
8A49  85 03    STA $03                 
8A4B  20 AB 8A JSR sub_8AAB            

loc_8A4E:  ; 1 xrefs: 8A33
8A4E  4C BB C8 JMP $C8BB               

sub_8A51:  ; 1 xrefs: 8A25
8A51  A5 16    LDA $16                 
8A53  0A       ASL A                   
8A54  A8       TAY                     
8A55  B9 DA 8A LDA $8ADA,Y             
8A58  85 08    STA $08                 
8A5A  B9 DB 8A LDA $8ADB,Y             
8A5D  85 09    STA $09                 
8A5F  A5 16    LDA $16                 
8A61  0A       ASL A                   
8A62  A8       TAY                     
8A63  B9 E2 8A LDA $8AE2,Y             
8A66  85 0A    STA $0A                 
8A68  B9 E3 8A LDA $8AE3,Y             
8A6B  85 0B    STA $0B                 
8A6D  A9 EC    LDA #$EC                
8A6F  85 00    STA $00                 
8A71  A9 8A    LDA #$8A                
8A73  85 01    STA $01                 
8A75  A9 6C    LDA #$6C                
8A77  85 02    STA $02                 
8A79  A9 8B    LDA #$8B                
8A7B  85 03    STA $03                 
8A7D  A0 00    LDY #$00                

loc_8A7F:  ; 1 xrefs: 8AA8
8A7F  AD 02 20 LDA $2002               
8A82  A5 08    LDA $08                 
8A84  8D 06 20 STA $2006               
8A87  A5 09    LDA $09                 
8A89  8D 06 20 STA $2006               

loc_8A8C:  ; 1 xrefs: 8A99
8A8C  B1 00    LDA ($00),Y             
8A8E  8D 07 20 STA $2007               
8A91  C8       INY                     
8A92  C0 80    CPY #$80                
8A94  F0 15    BEQ loc_8AAB            
8A96  98       TYA                     
8A97  29 07    AND #$07                
8A99  D0 F1    BNE loc_8A8C            
8A9B  A5 09    LDA $09                 
8A9D  18       CLC                     
8A9E  69 20    ADC #$20                
8AA0  85 09    STA $09                 
8AA2  A5 08    LDA $08                 
8AA4  69 00    ADC #$00                
8AA6  85 08    STA $08                 
8AA8  4C 7F 8A JMP loc_8A7F            

sub_8AAB:  ; 2 xrefs: 8A4B 8A94
8AAB  A0 00    LDY #$00                

loc_8AAD:  ; 1 xrefs: 8AD6
8AAD  AD 02 20 LDA $2002               
8AB0  A5 0A    LDA $0A                 
8AB2  8D 06 20 STA $2006               
8AB5  A5 0B    LDA $0B                 
8AB7  8D 06 20 STA $2006               

loc_8ABA:  ; 1 xrefs: 8AC7
8ABA  B1 02    LDA ($02),Y             
8ABC  8D 07 20 STA $2007               
8ABF  C8       INY                     
8AC0  C0 08    CPY #$08                
8AC2  F0 15    BEQ loc_8AD9            
8AC4  98       TYA                     
8AC5  29 01    AND #$01                
8AC7  D0 F1    BNE loc_8ABA            
8AC9  A5 0B    LDA $0B                 
8ACB  18       CLC                     
8ACC  69 08    ADC #$08                
8ACE  85 0B    STA $0B                 
8AD0  A5 0A    LDA $0A                 
8AD2  69 00    ADC #$00                
8AD4  85 0A    STA $0A                 
8AD6  4C AD 8A JMP loc_8AAD            

loc_8AD9:  ; 1 xrefs: 8AC2
8AD9  60       RTS                     

; ==== data $8ADA..$8B7B  (162 bytes) ====
8ADA  20 18 24 00 24 08 24 10 23 C6 27 C0 27 C2 27 C4  | .$.$.$.#.'.'.'.
8AEA  27 C6 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |'...............
8AFA  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8B0A  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8B1A  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8B2A  00 00 00 01 59 00 00 00 00 00 00 29 00 28 59 00  |....Y......).(Y.
8B3A  63 64 00 2D 00 2D 00 00 66 6F 5F 59 4B 59 00 28  |cd.-.-..fo_YKY.(
8B4A  59 59 28 59 2D 5F 62 29 00 00 00 6F 00 66 00 2D  |YY(Y-_b)...o.f.-
8B5A  00 64 00 79 88 69 4D 8F FE 00 87 97 A7 B7 C7 78  |.d.y.iM........x
8B6A  F7 88 00 00 00 00 FF FF 0F 0F 00 03 30 00 30 C0  |............0.0.
8B7A  03 0C                                            |..

loc_8B7C:  ; 0 xrefs: 
8B7C  A5 48    LDA $48                 
8B7E  29 10    AND #$10                
8B80  D0 02    BNE loc_8B84            
8B82  18       CLC                     
8B83  60       RTS                     

loc_8B84:  ; 1 xrefs: 8B80
8B84  A9 16    LDA #$16                
8B86  85 19    STA $19                 
8B88  38       SEC                     
8B89  60       RTS                     

loc_8B8A:  ; 1 xrefs: 800C
8B8A  A5 19    LDA $19                 
8B8C  20 4F C8 JSR $C84F               
8B8F  97 8B    SAX $8B,Y               
8B91  C3 8B    DCP ($8B,X)             
8B93  C6 8B    DEC $8B                 
8B95  DB 8B 20 DCP $208B,Y             
8B98  D9 80 B0 CMP $B080,Y             
8B9B  01 60    ORA ($60,X)             
8B9D  20 82 C8 JSR $C882               
8BA0  A0 0E    LDY #$0E                
8BA2  84 42    STY $42                 
8BA4  C8       INY                     
8BA5  84 43    STY $43                 
8BA7  A0 00    LDY #$00                
8BA9  84 44    STY $44                 
8BAB  C8       INY                     
8BAC  84 45    STY $45                 
8BAE  A0 10    LDY #$10                
8BB0  84 46    STY $46                 
8BB2  84 47    STY $47                 
8BB4  A9 20    LDA #$20                
8BB6  85 66    STA $66                 
8BB8  A9 EA    LDA #$EA                
8BBA  85 67    STA $67                 
8BBC  A9 00    LDA #$00                
8BBE  85 74    STA $74                 
8BC0  4C 9A C8 JMP $C89A               

; ==== data $8BC3..$8C34  (114 bytes) ====
8BC3  4C 7D 8C A9 5A 8D 42 04 A9 62 8D C6 04 A9 5A 8D  |L}..Z.B..b....Z.
8BD3  08 05 20 35 8C 4C 9A C8 A5 48 0A B0 4A 0A B0 4F  |.. 5.L...H..J..O
8BE3  0A 0A 0A B0 24 0A B0 01 60 A5 73 C9 10 F0 19 E6  |....$...`.s.....
8BF3  73 A5 74 18 69 07 C5 73 D0 05 E6 74 4C 35 8C AD  |s.t.i..s...tL5..
8C03  C6 04 18 69 08 8D C6 04 60 A5 73 F0 19 C6 73 A5  |...i....`.s...s.
8C13  74 38 E9 01 C5 73 D0 05 C6 74 4C 35 8C AD C6 04  |t8...s...tL5....
8C23  38 E9 08 8D C6 04 60 A4 73 B9 C1 8D 4C 1C C8 4C  |8.....`.s...L..L
8C33  3D C8                                            |=.

loc_8C35:  ; 0 xrefs: 
8C35  A9 21    LDA #$21                
8C37  85 66    STA $66                 
8C39  A9 8C    LDA #$8C                
8C3B  85 67    STA $67                 
8C3D  A5 74    LDA $74                 
8C3F  85 0A    STA $0A                 
8C41  A9 00    LDA #$00                
8C43  85 0B    STA $0B                 

loc_8C45:  ; 1 xrefs: 8C7A
8C45  A5 0A    LDA $0A                 
8C47  0A       ASL A                   
8C48  A8       TAY                     
8C49  B9 17 8D LDA $8D17,Y             
8C4C  85 08    STA $08                 
8C4E  B9 18 8D LDA $8D18,Y             
8C51  85 09    STA $09                 
8C53  20 40 C8 JSR $C840               
8C56  A5 67    LDA $67                 
8C58  20 49 C8 JSR $C849               
8C5B  A5 66    LDA $66                 
8C5D  20 49 C8 JSR $C849               
8C60  A0 00    LDY #$00                

loc_8C62:  ; 1 xrefs: 8C6A
8C62  B1 08    LDA ($08),Y             
8C64  20 49 C8 JSR $C849               
8C67  C8       INY                     
8C68  C0 08    CPY #$08                
8C6A  D0 F6    BNE loc_8C62            
8C6C  20 46 C8 JSR $C846               
8C6F  20 BF 8C JSR sub_8CBF            
8C72  E6 0A    INC $0A                 
8C74  E6 0B    INC $0B                 
8C76  A5 0B    LDA $0B                 
8C78  C9 07    CMP #$07                
8C7A  D0 C9    BNE loc_8C45            
8C7C  60       RTS                     

loc_8C7D:  ; 0 xrefs: 
8C7D  A5 74    LDA $74                 
8C7F  0A       ASL A                   
8C80  A8       TAY                     
8C81  B9 CD 8C LDA $8CCD,Y             
8C84  85 08    STA $08                 
8C86  B9 CE 8C LDA $8CCE,Y             
8C89  85 09    STA $09                 
8C8B  20 40 C8 JSR $C840               
8C8E  A5 67    LDA $67                 
8C90  20 49 C8 JSR $C849               
8C93  A5 66    LDA $66                 
8C95  20 49 C8 JSR $C849               
8C98  A0 00    LDY #$00                

loc_8C9A:  ; 1 xrefs: 8CA2
8C9A  B1 08    LDA ($08),Y             
8C9C  20 49 C8 JSR $C849               
8C9F  C8       INY                     
8CA0  C0 0C    CPY #$0C                
8CA2  D0 F6    BNE loc_8C9A            
8CA4  20 46 C8 JSR $C846               
8CA7  E6 74    INC $74                 
8CA9  A5 74    LDA $74                 
8CAB  C9 0D    CMP #$0D                
8CAD  D0 10    BNE loc_8CBF            
8CAF  A9 00    LDA #$00                
8CB1  85 74    STA $74                 
8CB3  E6 19    INC $19                 
8CB5  A9 04    LDA #$04                
8CB7  20 34 C8 JSR $C834               
8CBA  A9 00    LDA #$00                
8CBC  4C 3E 80 JMP sub_803E            

sub_8CBF:  ; 2 xrefs: 8C6F 8CAD
8CBF  A5 67    LDA $67                 
8CC1  18       CLC                     
8CC2  69 20    ADC #$20                
8CC4  85 67    STA $67                 
8CC6  A5 66    LDA $66                 
8CC8  69 00    ADC #$00                
8CCA  85 66    STA $66                 
8CCC  60       RTS                     

; ==== data $8CCD..$8DD1  (261 bytes) ====
8CCD  E7 8C F3 8C FF 8C 0B 8D E7 8C F3 8C F3 8C F3 8C  |................
8CDD  F3 8C F3 8C F3 8C F3 8C FF 8C D7 D9 D9 D9 D9 D9  |................
8CED  D9 D9 D9 D9 D9 D6 DB 00 00 00 00 00 00 00 00 00  |................
8CFD  00 DA D5 D8 D8 D8 D8 D8 D8 D8 D8 D8 D8 D4 00 00  |................
8D0D  00 00 00 00 00 00 00 00 00 00 A9 8D 41 8D 49 8D  |............A.I.
8D1D  51 8D 59 8D 61 8D 69 8D 71 8D 79 8D 81 8D 39 8D  |Q.Y.a.i.q.y...9.
8D2D  89 8D 91 8D B9 8D A1 8D 99 8D B1 8D 13 05 0C 05  |................
8D3D  03 14 00 00 13 14 01 07 05 21 00 00 13 14 01 07  |.........!......
8D4D  05 22 00 00 13 14 01 07 05 23 00 00 13 14 01 07  |.".......#......
8D5D  05 24 00 00 13 14 01 07 05 25 00 00 13 14 01 07  |.$.......%......
8D6D  05 26 00 00 0D 05 05 14 00 00 00 00 09 0E 10 15  |.&..............
8D7D  14 00 00 00 13 14 01 12 14 00 00 00 05 0E 05 0D  |................
8D8D  19 21 00 00 10 12 0F 04 15 03 05 21 07 01 0D 05  |.!.........!....
8D9D  0F 16 05 12 03 0C 05 01 12 00 00 00 10 12 0F 0C  |................
8DAD  0F 07 15 05 05 10 09 0C 0F 07 15 05 05 0E 05 0D  |................
8DBD  19 22 00 00 4A 3C 3D 3E 3F 40 41 42 43 45 44 46  |."..J<=>?@ABCEDF
8DCD  47 3B 49 48 4B                                   |G;IHK

loc_8DD2:  ; 1 xrefs: 8015
8DD2  A5 90    LDA $90                 
8DD4  D0 01    BNE loc_8DD7            

loc_8DD6:  ; 1 xrefs: 8DDD
8DD6  60       RTS                     

loc_8DD7:  ; 1 xrefs: 8DD4
8DD7  E6 7A    INC $7A                 
8DD9  A5 7A    LDA $7A                 
8DDB  29 03    AND #$03                
8DDD  D0 F7    BNE loc_8DD6            
8DDF  A9 00    LDA #$00                
8DE1  85 7A    STA $7A                 
8DE3  A5 90    LDA $90                 
8DE5  0A       ASL A                   
8DE6  A8       TAY                     
8DE7  B9 88 8E LDA $8E88,Y             
8DEA  85 08    STA $08                 
8DEC  B9 89 8E LDA $8E89,Y             
8DEF  85 09    STA $09                 
8DF1  A4 78    LDY $78                 
8DF3  B1 08    LDA ($08),Y             
8DF5  85 0A    STA $0A                 
8DF7  E6 78    INC $78                 
8DF9  C9 FF    CMP #$FF                
8DFB  F0 3A    BEQ loc_8E37            
8DFD  C9 FE    CMP #$FE                
8DFF  F0 3F    BEQ loc_8E40            
8E01  C9 FD    CMP #$FD                
8E03  F0 4D    BEQ loc_8E52            
8E05  A5 78    LDA $78                 
8E07  29 01    AND #$01                
8E09  D0 0A    BNE loc_8E15            
8E0B  AD 6B 01 LDA $016B               
8E0E  D0 05    BNE loc_8E15            
8E10  A9 35    LDA #$35                

loc_8E12:  ; 0 xrefs: 
8E12  20 1C C8 JSR $C81C               

loc_8E15:  ; 2 xrefs: 8E09 8E0E
8E15  A5 92    LDA $92                 
8E17  18       CLC                     
8E18  65 84    ADC $84                 
8E1A  85 00    STA $00                 
8E1C  A5 91    LDA $91                 
8E1E  85 01    STA $01                 
8E20  E6 84    INC $84                 
8E22  20 40 C8 JSR $C840               
8E25  A5 00    LDA $00                 
8E27  20 49 C8 JSR $C849               
8E2A  A5 01    LDA $01                 
8E2C  20 49 C8 JSR $C849               
8E2F  A5 0A    LDA $0A                 
8E31  20 49 C8 JSR $C849               
8E34  4C 46 C8 JMP $C846               

loc_8E37:  ; 1 xrefs: 8DFB
8E37  A9 00    LDA #$00                
8E39  85 78    STA $78                 
8E3B  85 90    STA $90                 
8E3D  85 7A    STA $7A                 
8E3F  60       RTS                     

loc_8E40:  ; 1 xrefs: 8DFF
8E40  A9 00    LDA #$00                
8E42  85 84    STA $84                 
8E44  A5 92    LDA $92                 
8E46  18       CLC                     
8E47  69 40    ADC #$40                
8E49  85 92    STA $92                 
8E4B  A5 91    LDA $91                 
8E4D  69 00    ADC #$00                
8E4F  85 91    STA $91                 
8E51  60       RTS                     

loc_8E52:  ; 1 xrefs: 8E03
8E52  A9 00    LDA #$00                
8E54  85 84    STA $84                 
8E56  A4 78    LDY $78                 
8E58  B1 08    LDA ($08),Y             
8E5A  85 92    STA $92                 
8E5C  C8       INY                     
8E5D  B1 08    LDA ($08),Y             
8E5F  85 91    STA $91                 
8E61  C8       INY                     
8E62  84 78    STY $78                 
8E64  60       RTS                     

sub_8E65:  ; 2 xrefs: 8012 A590
8E65  85 90    STA $90                 
8E67  0A       ASL A                   
8E68  A8       TAY                     
8E69  B9 88 8E LDA $8E88,Y             
8E6C  85 08    STA $08                 
8E6E  B9 89 8E LDA $8E89,Y             
8E71  85 09    STA $09                 
8E73  A0 00    LDY #$00                
8E75  B1 08    LDA ($08),Y             
8E77  85 92    STA $92                 
8E79  C8       INY                     
8E7A  B1 08    LDA ($08),Y             
8E7C  85 91    STA $91                 
8E7E  C8       INY                     
8E7F  84 78    STY $78                 
8E81  A9 00    LDA #$00                
8E83  85 7A    STA $7A                 
8E85  85 84    STA $84                 
8E87  60       RTS                     

; ==== data $8E88..$9671  (2026 bytes) ====
8E88  D2 8E D2 8E F1 8E 0D 8F 5C 8F 97 8F DD 8F 54 90  |........\.....T.
8E98  89 90 F5 90 57 91 B3 91 DA 91 F1 91 33 92 5C 92  |....W.......3.\.
8EA8  84 92 EC 92 37 93 9A 93 F7 93 30 94 54 94 D2 8E  |....7.....0.T...
8EB8  69 94 95 94 DB 94 1B 95 39 95 56 95 76 95 97 95  |i.......9.V.v...
8EC8  B6 95 E6 95 13 96 2E 96 59 96 42 22 04 05 03 05  |........Y.B"....
8ED8  0D 02 05 12 00 22 24 1D 00 22 22 20 20 2F 00 18  |....."$..""  /..
8EE8  2C 0D 01 13 00 05 16 05 FF 42 22 0D 05 12 12 19  |,........B".....
8EF8  00 18 2C 0D 01 13 1D 0D 12 1B 10 12 05 13 09 04  |..,.............
8F08  05 0E 14 2A FF 42 22 17 05 1D 01 14 00 14 08 05  |...*.B".........
8F18  00 04 05 0C 14 01 00 06 0F 15 0E 04 01 14 09 0F  |................
8F28  0E 1D FE 08 01 16 05 00 0A 15 13 14 00 06 09 0E  |................
8F38  09 13 08 05 04 FE 04 05 16 05 0C 0F 10 0D 05 0E  |................
8F48  14 00 0F 06 00 01 00 03 19 02 0F 12 07 FE 15 0E  |................
8F58  09 14 1D FF 42 22 17 08 09 03 08 00 12 05 10 12  |....B"..........
8F68  05 13 05 0E 14 13 00 14 08 05 00 0E 05 18 14 FE  |................
8F78  07 05 0E 05 12 01 14 09 0F 0E 00 0F 06 00 06 09  |................
8F88  07 08 14 09 0E 07 FE 12 0F 02 0F 14 13 2A FF 42  |.............*.B
8F98  22 17 05 00 17 0F 15 0C 04 00 0C 09 0B 05 00 14  |"...............
8FA8  0F 00 13 05 0C 0C 00 09 14 00 14 0F FE 0F 15 12  |................
8FB8  00 07 0F 16 05 12 0E 0D 05 0E 14 2C 13 00 04 05  |...........,....
8FC8  10 01 12 14 0D 05 0E 14 FE 0F 06 00 04 05 06 05  |................
8FD8  0E 13 05 2A FF 42 22 19 0F 15 00 12 05 01 0C 09  |...*.B".........
8FE8  1A 05 1D 0F 06 00 03 0F 15 12 13 05 1D 14 08 01  |................
8FF8  14 FE 14 08 09 13 00 03 19 02 0F 12 07 00 17 0F  |................
9008  15 0C 04 00 02 05 FE 01 00 14 08 12 05 01 14 00  |................
9018  14 0F 00 14 08 05 00 13 05 03 15 12 09 14 19 00  |................
9028  0F 06 FE 0F 15 12 00 0E 01 14 09 0F 0E 00 09 06  |................
9038  00 13 0F 0C 04 00 14 0F FE 01 00 06 0F 12 05 09  |................
9048  07 0E 00 03 0F 15 0E 14 12 19 2A FF 42 22 10 0C  |..........*.B"..
9058  05 01 13 05 00 03 0F 0E 13 09 04 05 12 00 0F 15  |................
9068  12 00 0F 06 06 05 12 FE 01 0E 04 00 12 05 13 10  |................
9078  0F 0E 04 00 09 0E 00 0F 0E 05 00 17 05 05 0B 2A  |...............*
9088  FF E2 20 14 08 05 00 07 0F 16 05 12 0E 0D 05 0E  |.. .............
9098  14 00 03 0F 0E 13 09 04 05 12 05 04 FE 14 08 05  |................
90A8  00 0D 01 14 14 05 12 00 16 05 12 19 00 13 05 12  |................
90B8  09 0F 15 13 0C 19 FE 01 0E 04 00 01 13 13 09 07  |................
90C8  0E 05 04 00 01 00 14 0F 10 00 13 05 03 12 05 14  |................
90D8  FE 0D 09 13 13 09 0F 0E 00 14 0F 00 13 10 00 08  |................
90E8  05 01 04 11 15 01 12 14 05 12 13 2A FF 42 22 19  |...........*.B".
90F8  0F 15 12 00 0D 09 13 13 09 0F 0E 1D 09 13 13 15  |................
9108  05 04 00 13 05 03 12 05 14 0C 19 FE 06 12 0F 0D  |................
9118  00 14 08 05 00 04 05 10 01 12 14 0D 05 0E 14 00  |................
9128  0F 06 FE 04 05 06 05 0E 13 05 1D 09 13 00 14 0F  |................
9138  00 04 05 13 14 12 0F 19 00 14 08 05 FE 04 05 0C  |................
9148  14 01 00 06 0F 15 0E 04 01 14 09 0F 0E 2A FF 42  |.............*.B
9158  22 01 13 00 0F 15 12 00 10 0F 0C 09 03 19 00 13  |"...............
9168  14 01 14 05 13 1D FE 17 05 00 03 01 0E 0E 0F 14  |................
9178  00 07 05 14 00 09 0E 16 0F 0C 16 05 04 00 09 0E  |................
9188  FE 14 08 05 00 05 16 05 0E 14 00 13 0F 0D 05 14  |................
9198  08 09 0E 07 00 13 08 0F 15 0C 04 FE 08 01 10 10  |................
91A8  05 0E 00 14 0F 00 19 0F 15 2A FF 42 22 0C 05 14  |.........*.B"...
91B8  2C 13 00 14 0F 12 03 08 00 14 08 09 13 00 10 0C  |,...............
91C8  01 03 05 00 01 0E 04 FE 07 05 14 00 01 17 01 19  |................
91D8  1F FF 46 21 01 00 13 15 03 03 05 13 13 06 15 0C  |..F!............
91E8  00 05 13 03 01 10 05 1F FF 42 22 0F 0F 10 13 1F  |.........B".....
91F8  FE 14 08 05 00 06 0C 0F 0F 12 00 03 0F 0C 0C 01  |................
9208  10 13 05 04 00 01 0E 04 FE 01 00 10 01 13 13 01  |................
9218  07 05 17 01 19 00 01 10 10 05 01 12 05 04 FE 15  |................
9228  0E 04 05 12 0E 05 01 14 08 2A FF 42 22 0A 01 03  |.........*.B"...
9238  11 15 05 0C 09 0E 05 1F FE 14 08 01 0E 0B 00 07  |................
9248  0F 0F 04 0E 05 13 13 00 19 0F 15 2C 12 05 00 0F  |...........,....
9258  2A 0B 2A FF 42 22 13 0F 0D 05 14 08 09 0E 07 00  |*.*.B"..........
9268  14 05 12 12 09 02 0C 05 00 09 13 FE 08 01 10 10  |................
9278  05 0E 09 0E 07 00 08 05 12 05 2A FF 42 22 09 00  |..........*.B"..
9288  04 09 13 03 0F 16 05 12 05 04 00 14 08 05 00 14  |................
9298  12 15 05 FE 09 04 05 0E 14 09 14 19 00 0F 06 00  |................
92A8  14 08 05 00 10 12 05 13 09 04 05 0E 14 FE 0F 06  |................
92B8  00 14 08 05 00 04 05 0C 14 01 00 06 0F 15 0E 04  |................
92C8  01 14 09 0F 0E 00 09 13 FE 01 0E 00 01 0C 09 05  |................
92D8  0E 00 06 12 0F 0D 00 0F 15 14 05 12 00 13 10 01  |................
92E8  03 05 2A FF 42 22 08 05 00 09 13 00 0E 0F 17 00  |..*.B"..........
92F8  13 10 12 05 01 04 09 0E 07 00 08 09 13 FE 14 12  |................
9308  0F 0F 10 13 00 01 0C 0C 00 01 12 0F 15 0E 04 1D  |................
9318  10 12 05 10 01 12 09 0E 07 FE 14 0F 00 09 0E 16  |................
9328  01 04 05 00 14 08 05 00 05 01 12 14 08 2A FF 42  |.............*.B
9338  22 14 08 05 00 0F 06 06 05 12 00 08 05 00 0D 01  |"...............
9348  04 05 00 14 0F FE 14 08 05 00 07 0F 16 05 12 0E  |................
9358  0D 05 0E 14 00 17 01 13 00 0D 05 01 0E 14 00 14  |................
9368  0F 00 FE 12 01 09 13 05 00 06 15 0E 04 13 00 14  |................
9378  0F 00 03 01 12 12 19 00 0F 15 14 00 08 09 13 FE  |................
9388  10 0C 01 0E 00 0F 06 00 09 0E 16 01 13 09 0F 0E  |................
9398  2A FF 42 22 17 05 00 0D 15 13 14 00 05 18 14 05  |*.B"............
93A8  12 0D 09 0E 01 14 05 FE 14 08 05 00 04 05 0C 14  |................
93B8  01 00 06 0F 15 0E 04 01 14 09 0F 0E 2A FE 09 0D  |............*...
93C8  0D 05 04 09 01 14 05 0C 19 1D 0F 14 08 05 12 17  |................
93D8  09 13 05 FE 0F 15 12 00 04 01 19 13 00 17 09 0C  |................
93E8  0C 00 02 05 00 0E 15 0D 02 05 12 05 04 2A FF 42  |.............*.B
93F8  22 19 0F 15 2C 04 00 02 05 14 14 05 12 00 07 05  |"...,...........
9408  14 00 0F 15 14 00 0F 06 00 08 05 12 05 FE 01 0E  |................
9418  04 00 0C 05 01 16 05 00 14 08 05 00 12 05 13 14  |................
9428  00 14 0F 00 0D 05 2A FF 42 22 13 0F 00 01 14 00  |......*.B"......
9438  0C 01 13 14 1D FE 19 0F 15 2C 16 05 00 03 0F 0D  |.........,......
9448  05 00 14 08 09 13 00 06 01 12 2A FF 46 21 0D 09  |..........*.F!..
9458  13 13 09 0F 0E 00 03 0F 0D 10 0C 05 14 05 04 1F  |................
9468  FF 42 22 0D 01 0E 0B 09 0E 04 00 08 01 13 00 02  |.B".............
9478  05 05 0E 00 13 01 16 05 04 00 02 19 FE 14 08 09  |................
9488  13 00 0D 01 0E 00 01 07 01 09 0E 2A FF 42 22 08  |...........*.B".
9498  0F 17 05 16 05 12 1D 08 09 13 00 01 03 08 09 05  |................
94A8  16 05 0D 05 0E 14 13 FE 17 09 0C 0C 00 0E 05 16  |................
94B8  05 12 00 02 05 00 0B 0E 0F 17 0E 00 14 0F FE 14  |................
94C8  08 05 00 07 05 0E 05 12 01 0C 00 10 15 02 0C 09  |................
94D8  03 2A FF 42 22 08 05 00 09 13 00 01 0E 00 13 10  |.*.B"...........
94E8  00 01 0E 04 00 09 13 00 0E 0F 14 00 05 16 05 0E  |................
94F8  FE 13 15 10 10 0F 13 05 04 00 14 0F 00 05 18 09  |................
9508  13 14 00 09 0E FE 0F 15 12 00 13 0F 03 09 05 14  |................
9518  19 2A FF C8 22 19 0F 15 2C 16 05 00 0F 02 14 01  |.*.."...,.......
9528  09 0E 05 04 FE 0E 05 17 14 00 13 15 09 14 13 2A  |...............*
9538  FF C8 22 19 0F 15 2C 16 05 00 0F 02 14 01 09 0E  |.."...,.........
9548  05 04 FE 17 05 14 00 13 15 09 14 13 2A FF C8 22  |............*.."
9558  19 0F 15 2C 16 05 00 0F 02 14 01 09 0E 05 04 FE  |...,............
9568  12 0F 03 0B 05 14 00 13 15 09 14 13 2A FF C8 22  |............*.."
9578  19 0F 15 2C 16 05 00 0F 02 14 01 09 0E 05 04 FE  |...,............
9588  10 01 14 12 09 0F 14 00 13 15 09 14 13 2A FF 4D  |.............*.M
9598  22 10 0C 01 0E 0E 05 12 FD 87 22 0E 0F 12 09 19  |".........".....
95A8  01 13 15 00 14 0F 07 01 0B 15 13 08 09 FF 4B 22  |..............K"
95B8  10 12 0F 07 12 01 0D 0D 05 12 FD 89 22 14 0F 13  |............"...
95C8  08 09 0B 01 1A 15 00 09 17 01 13 01 FD C9 22 0B  |..............".
95D8  05 09 09 03 08 09 00 19 01 0D 01 04 01 FF 4C 22  |..............L"
95E8  04 05 13 09 07 0E 05 12 FD 8B 22 0B 05 09 1A 0F  |..........".....
95F8  00 0B 01 14 0F FD C7 22 0E 0F 12 09 19 01 13 15  |......."........
9608  00 14 0F 07 01 0B 15 13 08 09 FF 4E 22 13 0F 15  |...........N"...
9618  0E 04 FD 88 22 0B 09 0E 15 19 0F 00 19 01 0D 01  |...."...........
9628  13 08 09 14 01 FF 4D 22 14 08 01 0E 0B 13 FD 89  |......M"........
9638  22 19 0F 13 08 09 0F 00 09 0D 01 0D 15 12 01 FD  |"...............
9648  C9 22 13 08 09 0E 10 05 09 00 08 01 12 01 04 01  |."..............
9658  FF 4C 22 10 12 05 13 05 0E 14 05 04 FD 8F 22 02  |.L"...........".
9668  19 FD CE 22 14 01 09 14 0F FF                    |..."......

loc_9672:  ; 1 xrefs: 8018
9672  A5 19    LDA $19                 
9674  20 4F C8 JSR $C84F               

; ==== data $9677..$97D7  (353 bytes) ====
9677  93 96 CE 96 2A 97 32 97 60 97 A7 97 B7 97 BA 97  |....*.2.`.......
9687  E1 97 FC 97 10 98 1A 98 2A 97 35 98 A0 0E 84 42  |........*.5....B
9697  C8 84 43 A0 00 84 44 C8 84 45 A0 10 84 46 84 47  |..C...D..E...F.G
96A7  20 82 C8 A2 16 20 4C C8 20 3D C8 A9 43 20 1C C8  | .... L. =..C ..
96B7  A9 15 20 3E 80 A9 00 85 51 85 87 20 14 99 20 EB  |.. >....Q.. .. .
96C7  99 20 F7 99 4C 9A C8 A5 48 29 10 D0 03 4C 7A 98  |. ..L...H)...Lz.
96D7  A9 00 8D 42 04 20 03 9A 90 1C A9 00 85 48 20 3D  |...B. .......H =
96E7  C8 A9 31 20 1C C8 A9 07 20 34 C8 A9 40 85 50 A9  |..1 .... 4..@.P.
96F7  0C 85 19 4C 13 C8 20 12 9D A0 00 A5 5B C9 1F D0  |...L.. .....[...
9707  02 A0 05 84 53 A9 00 85 9C 20 3D C8 A9 28 20 1C  |....S.... =..( .
9717  C8 A9 00 8D 08 05 8D C6 04 8D 42 04 A9 32 85 50  |..........B..2.P
9727  4C 9A C8 C6 50 D0 03 4C 9A C8 60 20 D9 80 90 28  |L...P..L..` ...(
9737  A9 00 85 1A 85 1B 85 19 A5 5B C9 1F F0 0A A9 03  |.........[......
9747  85 18 A9 14 85 19 D0 04 A9 04 85 18 A9 02 85 9F  |................
9757  A9 10 8D 9A 04 20 96 C9 60 A0 0E 84 42 C8 84 43  |..... ..`...B..C
9767  A0 00 84 44 C8 84 45 A0 10 84 46 84 47 A9 15 20  |...D..E...F.G.. 
9777  3E 80 20 82 C8 20 3D C8 A9 48 20 1C C8 A9 09 20  |>. .. =..H .... 
9787  34 C8 A9 01 85 50 A9 00 85 79 85 88 85 89 85 87  |4....P...y......
9797  85 AD 85 55 85 A2 85 57 85 4F 20 96 C9 4C 9A C8  |...U...W.O ..L..
97A7  A5 C8 F0 01 60 A9 08 20 34 C8 20 5D 98 4C 9A C8  |....`.. 4. ].L..
97B7  4C 3F 98 A5 4F F0 0C 20 3D C8 20 EB 99 20 F7 99  |L?..O.. =. .. ..
97C7  4C 9A C8 20 3D C8 A9 29 20 1C C8 A9 00 85 1A 85  |L.. =..) .......
97D7  27                                               |'

loc_97D8:  ; 0 xrefs: 
97D8  85 98    STA $98                 
97DA  85 4F    STA $4F                 
97DC  A9 02    LDA #$02                
97DE  85 19    STA $19                 
97E0  60       RTS                     

; ==== data $97E1..$983E  (94 bytes) ====
97E1  20 D9 80 B0 01 60 20 82 C8 20 13 C8 A2 16 20 4C  | ....` .. .... L
97F1  C8 A9 00 85 51 20 1C 9A 4C 9A C8 20 72 98 E6 51  |....Q ..L.. r..Q
9801  A5 51 C9 0C F0 01 60 A9 15 20 3E 80 4C 9A C8 A5  |.Q....`.. >.L...
9811  48 29 10 F0 03 4C 9A C8 60 20 D9 80 B0 01 60 A9  |H)...L..` ....`.
9821  00 85 18 85 19 85 5B 85 56 85 2B 85 2C 85 57 85  |......[.V.+.,.W.
9831  53 4C 13 C8 20 D9 80 90 04 A9 00 85 19 60        |SL.. ........`

loc_983F:  ; 0 xrefs: 
983F  A5 48    LDA $48                 
9841  4A       LSR A                   
9842  4A       LSR A                   
9843  4A       LSR A                   
9844  4A       LSR A                   
9845  4A       LSR A                   
9846  B0 04    BCS loc_984C            
9848  4A       LSR A                   
9849  B0 04    BCS loc_984F            
984B  60       RTS                     

loc_984C:  ; 1 xrefs: 9846
984C  4C 9A C8 JMP $C89A               

loc_984F:  ; 1 xrefs: 9849
984F  A9 39    LDA #$39                
9851  20 1C C8 JSR $C81C               
9854  A5 4F    LDA $4F                 
9856  49 01    EOR #$01                
9858  85 4F    STA $4F                 
985A  4C 5D 98 JMP loc_985D            

loc_985D:  ; 1 xrefs: 985A
985D  A4 4F    LDY $4F                 
985F  B9 70 98 LDA $9870,Y             
9862  8D C6 04 STA $04C6               
9865  A9 5A    LDA #$5A                
9867  8D 08 05 STA $0508               
986A  A9 5A    LDA #$5A                
986C  8D 42 04 STA $0442               
986F  60       RTS                     

; ==== data $9870..$9871  (2 bytes) ====
9870  7A 8A                                            |z.

loc_9872:  ; 0 xrefs: 
9872  A4 51    LDY $51                 
9874  B9 90 06 LDA $0690,Y             
9877  4C 40 99 JMP loc_9940            

loc_987A:  ; 0 xrefs: 
987A  A5 48    LDA $48                 
987C  4A       LSR A                   
987D  B0 12    BCS loc_9891            
987F  4A       LSR A                   
9880  B0 21    BCS loc_98A3            
9882  4A       LSR A                   
9883  B0 2E    BCS loc_98B3            
9885  4A       LSR A                   
9886  B0 45    BCS loc_98CD            
9888  4A       LSR A                   
9889  4A       LSR A                   
988A  4A       LSR A                   
988B  B0 58    BCS loc_98E5            
988D  4A       LSR A                   
988E  B0 6A    BCS loc_98FA            
9890  60       RTS                     

loc_9891:  ; 1 xrefs: 987D
9891  A5 51    LDA $51                 
9893  C9 0B    CMP #$0B                
9895  F0 05    BEQ loc_989C            
9897  E6 51    INC $51                 
9899  4C 0F 99 JMP loc_990F            

loc_989C:  ; 1 xrefs: 9895
989C  A9 00    LDA #$00                
989E  85 51    STA $51                 
98A0  4C 0F 99 JMP loc_990F            

loc_98A3:  ; 1 xrefs: 9880
98A3  A5 51    LDA $51                 
98A5  F0 05    BEQ loc_98AC            
98A7  C6 51    DEC $51                 
98A9  4C 0F 99 JMP loc_990F            

loc_98AC:  ; 1 xrefs: 98A5
98AC  A9 0B    LDA #$0B                
98AE  85 51    STA $51                 
98B0  4C 0F 99 JMP loc_990F            

loc_98B3:  ; 1 xrefs: 9883
98B3  A5 51    LDA $51                 
98B5  18       CLC                     
98B6  69 04    ADC #$04                
98B8  85 51    STA $51                 
98BA  C9 0C    CMP #$0C                
98BC  B0 03    BCS loc_98C1            
98BE  4C 0F 99 JMP loc_990F            

loc_98C1:  ; 1 xrefs: 98BC
98C1  A5 51    LDA $51                 
98C3  18       CLC                     
98C4  69 04    ADC #$04                
98C6  29 0F    AND #$0F                
98C8  85 51    STA $51                 
98CA  4C 0F 99 JMP loc_990F            

loc_98CD:  ; 1 xrefs: 9886
98CD  A5 51    LDA $51                 
98CF  38       SEC                     
98D0  E9 04    SBC #$04                
98D2  85 51    STA $51                 
98D4  30 03    BMI loc_98D9            
98D6  4C 0F 99 JMP loc_990F            

loc_98D9:  ; 1 xrefs: 98D4
98D9  A5 51    LDA $51                 
98DB  29 0F    AND #$0F                
98DD  38       SEC                     
98DE  E9 04    SBC #$04                
98E0  85 51    STA $51                 
98E2  4C 0F 99 JMP loc_990F            

loc_98E5:  ; 1 xrefs: 988B
98E5  A9 1D    LDA #$1D                
98E7  20 1C C8 JSR $C81C               
98EA  A4 51    LDY $51                 
98EC  B9 90 06 LDA $0690,Y             
98EF  38       SEC                     
98F0  E9 01    SBC #$01                
98F2  29 07    AND #$07                
98F4  99 90 06 STA $0690,Y             
98F7  4C 40 99 JMP loc_9940            

loc_98FA:  ; 1 xrefs: 988E
98FA  A9 1D    LDA #$1D                
98FC  20 1C C8 JSR $C81C               
98FF  A4 51    LDY $51                 
9901  B9 90 06 LDA $0690,Y             
9904  18       CLC                     
9905  69 01    ADC #$01                
9907  29 07    AND #$07                
9909  99 90 06 STA $0690,Y             
990C  4C 40 99 JMP loc_9940            

loc_990F:  ; 8 xrefs: 9899 98A0 98A9 98B0 98BE 98CA 98D6 98E2
990F  A9 39    LDA #$39                
9911  20 1C C8 JSR $C81C               

loc_9914:  ; 0 xrefs: 
9914  A9 59    LDA #$59                
9916  8D 42 04 STA $0442               
9919  A4 51    LDY $51                 
991B  B9 28 99 LDA $9928,Y             
991E  8D 08 05 STA $0508               
9921  B9 34 99 LDA $9934,Y             
9924  8D C6 04 STA $04C6               
9927  60       RTS                     

; ==== data $9928..$993F  (24 bytes) ====
9928  50 70 90 B0 50 70 90 B0 50 70 90 B0 68 68 68 68  |Pp..Pp..Pp..hhhh
9938  88 88 88 88 A8 A8 A8 A8                          |........

loc_9940:  ; 3 xrefs: 9877 98F7 990C
9940  0A       ASL A                   
9941  A8       TAY                     
9942  84 08    STY $08                 
9944  B9 A3 99 LDA $99A3,Y             
9947  85 00    STA $00                 
9949  B9 A4 99 LDA $99A4,Y             
994C  85 01    STA $01                 
994E  A5 51    LDA $51                 
9950  0A       ASL A                   
9951  A8       TAY                     
9952  B9 D3 99 LDA $99D3,Y             
9955  85 03    STA $03                 
9957  C8       INY                     
9958  B9 D3 99 LDA $99D3,Y             
995B  85 02    STA $02                 
995D  A0 00    LDY #$00                
995F  20 40 C8 JSR $C840               
9962  A5 02    LDA $02                 
9964  20 49 C8 JSR $C849               
9967  A5 03    LDA $03                 
9969  20 49 C8 JSR $C849               
996C  B1 00    LDA ($00),Y             
996E  20 49 C8 JSR $C849               
9971  C8       INY                     
9972  B1 00    LDA ($00),Y             
9974  20 49 C8 JSR $C849               
9977  C8       INY                     
9978  20 46 C8 JSR $C846               
997B  A5 02    LDA $02                 
997D  18       CLC                     
997E  69 20    ADC #$20                
9980  85 02    STA $02                 
9982  A5 03    LDA $03                 
9984  69 00    ADC #$00                
9986  85 03    STA $03                 
9988  20 40 C8 JSR $C840               
998B  A5 02    LDA $02                 
998D  20 49 C8 JSR $C849               
9990  A5 03    LDA $03                 
9992  20 49 C8 JSR $C849               
9995  B1 00    LDA ($00),Y             
9997  20 49 C8 JSR $C849               
999A  C8       INY                     
999B  B1 00    LDA ($00),Y             
999D  20 49 C8 JSR $C849               
99A0  4C 46 C8 JMP $C846               

; ==== data $99A3..$99EA  (72 bytes) ====
99A3  B3 99 B7 99 BB 99 BF 99 C3 99 C7 99 CB 99 CF 99  |................
99B3  00 00 00 00 E0 E1 F0 F1 E2 E3 F2 F3 E4 E5 F4 F5  |................
99C3  E6 E7 F6 F7 E8 E9 F8 F9 42 43 45 46 3D 3E 4D 4E  |........BCEF=>MN
99D3  21 89 21 8D 21 91 21 95 22 09 22 0D 22 11 22 15  |!.!.!.!.".".".".
99E3  22 89 22 8D 22 91 22 95                          |".".".".

loc_99EB:  ; 0 xrefs: 
99EB  A9 00    LDA #$00                
99ED  A8       TAY                     

loc_99EE:  ; 1 xrefs: 99F4
99EE  99 80 06 STA $0680,Y             
99F1  C8       INY                     
99F2  C0 10    CPY #$10                
99F4  D0 F8    BNE loc_99EE            
99F6  60       RTS                     

loc_99F7:  ; 0 xrefs: 
99F7  A9 00    LDA #$00                
99F9  A8       TAY                     

loc_99FA:  ; 1 xrefs: 9A00
99FA  99 90 06 STA $0690,Y             
99FD  C8       INY                     
99FE  C0 20    CPY #$20                
9A00  D0 F8    BNE loc_99FA            
9A02  60       RTS                     

loc_9A03:  ; 0 xrefs: 
9A03  20 09 9B JSR sub_9B09            
9A06  20 C4 9B JSR sub_9BC4            
9A09  20 2B 9C JSR sub_9C2B            
9A0C  B0 0C    BCS loc_9A1A            
9A0E  20 CF 9C JSR sub_9CCF            
9A11  B0 07    BCS loc_9A1A            
9A13  20 6C 9D JSR sub_9D6C            
9A16  B0 02    BCS loc_9A1A            
9A18  18       CLC                     
9A19  60       RTS                     

loc_9A1A:  ; 3 xrefs: 9A0C 9A11 9A16
9A1A  38       SEC                     
9A1B  60       RTS                     

loc_9A1C:  ; 0 xrefs: 
9A1C  A5 5B    LDA $5B                 
9A1E  C9 1F    CMP #$1F                
9A20  D0 03    BNE loc_9A25            
9A22  4C 58 9A JMP loc_9A58            

loc_9A25:  ; 1 xrefs: 9A20
9A25  18       CLC                     
9A26  A5 5B    LDA $5B                 
9A28  29 03    AND #$03                
9A2A  0A       ASL A                   
9A2B  8D 87 06 STA $0687               
9A2E  A5 5B    LDA $5B                 
9A30  29 0C    AND #$0C                
9A32  4A       LSR A                   
9A33  8D 89 06 STA $0689               
9A36  A5 5B    LDA $5B                 
9A38  29 10    AND #$10                
9A3A  4A       LSR A                   
9A3B  4A       LSR A                   
9A3C  8D 8B 06 STA $068B               
9A3F  A5 56    LDA $56                 
9A41  29 03    AND #$03                
9A43  0A       ASL A                   
9A44  8D 88 06 STA $0688               
9A47  A5 56    LDA $56                 
9A49  29 0C    AND #$0C                
9A4B  4A       LSR A                   
9A4C  8D 8A 06 STA $068A               
9A4F  20 8A 9A JSR sub_9A8A            
9A52  20 21 9B JSR sub_9B21            
9A55  4C E9 9A JMP loc_9AE9            

loc_9A58:  ; 1 xrefs: 9A22
9A58  A5 5B    LDA $5B                 
9A5A  29 03    AND #$03                
9A5C  0A       ASL A                   
9A5D  8D 87 06 STA $0687               
9A60  A5 5B    LDA $5B                 
9A62  29 0C    AND #$0C                
9A64  4A       LSR A                   
9A65  8D 89 06 STA $0689               
9A68  A5 5B    LDA $5B                 
9A6A  29 10    AND #$10                
9A6C  4A       LSR A                   
9A6D  4A       LSR A                   
9A6E  8D 8B 06 STA $068B               
9A71  A5 56    LDA $56                 
9A73  29 03    AND #$03                
9A75  0A       ASL A                   
9A76  8D 88 06 STA $0688               
9A79  A5 56    LDA $56                 
9A7B  29 0C    AND #$0C                
9A7D  4A       LSR A                   
9A7E  8D 8A 06 STA $068A               
9A81  20 8A 9A JSR sub_9A8A            
9A84  20 21 9B JSR sub_9B21            
9A87  4C E9 9A JMP loc_9AE9            

sub_9A8A:  ; 2 xrefs: 9A4F 9A81
9A8A  A9 00    LDA #$00                
9A8C  85 00    STA $00                 
9A8E  A0 00    LDY #$00                

loc_9A90:  ; 1 xrefs: 9A9B
9A90  A5 00    LDA $00                 
9A92  18       CLC                     
9A93  79 80 06 ADC $0680,Y             
9A96  85 00    STA $00                 
9A98  C8       INY                     
9A99  C0 0C    CPY #$0C                
9A9B  D0 F3    BNE loc_9A90            
9A9D  A5 00    LDA $00                 
9A9F  29 01    AND #$01                
9AA1  0D 86 06 ORA $0686               
9AA4  8D 86 06 STA $0686               
9AA7  A5 00    LDA $00                 
9AA9  29 02    AND #$02                
9AAB  4A       LSR A                   
9AAC  0D 87 06 ORA $0687               
9AAF  8D 87 06 STA $0687               
9AB2  A5 00    LDA $00                 
9AB4  29 04    AND #$04                
9AB6  4A       LSR A                   
9AB7  4A       LSR A                   
9AB8  0D 88 06 ORA $0688               
9ABB  8D 88 06 STA $0688               
9ABE  A5 00    LDA $00                 
9AC0  29 08    AND #$08                
9AC2  4A       LSR A                   
9AC3  4A       LSR A                   
9AC4  4A       LSR A                   
9AC5  0D 89 06 ORA $0689               
9AC8  8D 89 06 STA $0689               
9ACB  A5 00    LDA $00                 
9ACD  29 10    AND #$10                
9ACF  4A       LSR A                   
9AD0  4A       LSR A                   
9AD1  4A       LSR A                   
9AD2  4A       LSR A                   
9AD3  0D 8A 06 ORA $068A               
9AD6  8D 8A 06 STA $068A               
9AD9  A5 00    LDA $00                 
9ADB  29 60    AND #$60                
9ADD  4A       LSR A                   
9ADE  4A       LSR A                   
9ADF  4A       LSR A                   
9AE0  4A       LSR A                   
9AE1  4A       LSR A                   
9AE2  0D 8B 06 ORA $068B               
9AE5  8D 8B 06 STA $068B               
9AE8  60       RTS                     

loc_9AE9:  ; 2 xrefs: 9A55 9A87
9AE9  A0 00    LDY #$00                

loc_9AEB:  ; 1 xrefs: 9AFA
9AEB  B9 FD 9A LDA $9AFD,Y             
9AEE  18       CLC                     
9AEF  79 90 06 ADC $0690,Y             
9AF2  29 07    AND #$07                
9AF4  99 90 06 STA $0690,Y             
9AF7  C8       INY                     
9AF8  C0 0C    CPY #$0C                
9AFA  D0 EF    BNE loc_9AEB            
9AFC  60       RTS                     

; ==== data $9AFD..$9B08  (12 bytes) ====
9AFD  04 01 03 02 07 01 03 05 06 04 05 02              |............

sub_9B09:  ; 1 xrefs: 9A03
9B09  A0 00    LDY #$00                

loc_9B0B:  ; 1 xrefs: 9B1E
9B0B  B9 FD 9A LDA $9AFD,Y             
9B0E  85 10    STA $10                 
9B10  B9 90 06 LDA $0690,Y             
9B13  38       SEC                     
9B14  E5 10    SBC $10                 
9B16  29 07    AND #$07                
9B18  99 90 06 STA $0690,Y             
9B1B  C8       INY                     
9B1C  C0 0C    CPY #$0C                
9B1E  D0 EB    BNE loc_9B0B            
9B20  60       RTS                     

sub_9B21:  ; 2 xrefs: 9A52 9A84
9B21  A5 5B    LDA $5B                 
9B23  C9 1F    CMP #$1F                
9B25  F0 27    BEQ loc_9B4E            
9B27  A5 5B    LDA $5B                 
9B29  0A       ASL A                   
9B2A  A8       TAY                     
9B2B  B9 74 9B LDA $9B74,Y             
9B2E  85 08    STA $08                 
9B30  B9 75 9B LDA $9B75,Y             
9B33  85 09    STA $09                 
9B35  A0 00    LDY #$00                
9B37  84 26    STY $26                 

loc_9B39:  ; 1 xrefs: 9B4B
9B39  A4 26    LDY $26                 
9B3B  B1 08    LDA ($08),Y             
9B3D  A8       TAY                     
9B3E  B9 80 06 LDA $0680,Y             
9B41  A4 26    LDY $26                 
9B43  99 90 06 STA $0690,Y             
9B46  C8       INY                     
9B47  84 26    STY $26                 
9B49  C0 0C    CPY #$0C                
9B4B  D0 EC    BNE loc_9B39            
9B4D  60       RTS                     

loc_9B4E:  ; 1 xrefs: 9B25
9B4E  A9 00    LDA #$00                
9B50  85 26    STA $26                 

loc_9B52:  ; 1 xrefs: 9B65
9B52  A4 26    LDY $26                 
9B54  B9 68 9B LDA $9B68,Y             
9B57  A8       TAY                     
9B58  B9 80 06 LDA $0680,Y             
9B5B  A4 26    LDY $26                 
9B5D  99 90 06 STA $0690,Y             
9B60  C8       INY                     
9B61  84 26    STY $26                 
9B63  C0 0C    CPY #$0C                
9B65  D0 EB    BNE loc_9B52            
9B67  60       RTS                     

; ==== data $9B68..$9BC3  (92 bytes) ====
9B68  00 06 05 04 0A 01 09 03 07 08 02 0B 94 9B A0 9B  |................
9B78  AC 9B B8 9B 94 9B A0 9B AC 9B B8 9B 94 9B A0 9B  |................
9B88  AC 9B B8 9B 94 9B A0 9B AC 9B B8 9B 00 02 03 01  |................
9B98  04 06 09 05 07 08 0A 0B 08 02 03 06 0A 01 09 05  |................
9BA8  07 00 04 0B 05 04 03 0A 06 00 09 08 07 01 02 0B  |................
9BB8  03 04 01 02 06 05 09 0A 07 08 00 0B              |............

sub_9BC4:  ; 1 xrefs: 9A06
9BC4  AD 98 06 LDA $0698               
9BC7  29 06    AND #$06                
9BC9  4A       LSR A                   
9BCA  8D A0 06 STA $06A0               
9BCD  AD 96 06 LDA $0696               
9BD0  29 06    AND #$06                
9BD2  0A       ASL A                   
9BD3  0D A0 06 ORA $06A0               
9BD6  8D A0 06 STA $06A0               
9BD9  AD 9B 06 LDA $069B               
9BDC  29 04    AND #$04                
9BDE  0A       ASL A                   
9BDF  0A       ASL A                   
9BE0  0D A0 06 ORA $06A0               
9BE3  8D A0 06 STA $06A0               
9BE6  C9 1F    CMP #$1F                
9BE8  F0 27    BEQ loc_9C11            
9BEA  29 0F    AND #$0F                
9BEC  0A       ASL A                   
9BED  A8       TAY                     
9BEE  B9 74 9B LDA $9B74,Y             
9BF1  85 08    STA $08                 
9BF3  B9 75 9B LDA $9B75,Y             
9BF6  85 09    STA $09                 
9BF8  A0 00    LDY #$00                
9BFA  84 26    STY $26                 

loc_9BFC:  ; 1 xrefs: 9C0E
9BFC  B9 90 06 LDA $0690,Y             
9BFF  AA       TAX                     
9C00  B1 08    LDA ($08),Y             
9C02  A8       TAY                     
9C03  8A       TXA                     
9C04  99 80 06 STA $0680,Y             
9C07  A4 26    LDY $26                 
9C09  C8       INY                     
9C0A  84 26    STY $26                 
9C0C  C0 0C    CPY #$0C                
9C0E  D0 EC    BNE loc_9BFC            
9C10  60       RTS                     

loc_9C11:  ; 1 xrefs: 9BE8
9C11  A0 00    LDY #$00                
9C13  84 26    STY $26                 

loc_9C15:  ; 1 xrefs: 9C28
9C15  B9 90 06 LDA $0690,Y             
9C18  AA       TAX                     
9C19  B9 68 9B LDA $9B68,Y             
9C1C  A8       TAY                     
9C1D  8A       TXA                     
9C1E  99 80 06 STA $0680,Y             
9C21  A4 26    LDY $26                 
9C23  C8       INY                     
9C24  84 26    STY $26                 
9C26  C0 0C    CPY #$0C                
9C28  D0 EB    BNE loc_9C15            
9C2A  60       RTS                     

sub_9C2B:  ; 1 xrefs: 9A09
9C2B  A0 00    LDY #$00                
9C2D  8C A5 06 STY $06A5               

loc_9C30:  ; 1 xrefs: 9C3D
9C30  B9 80 06 LDA $0680,Y             
9C33  18       CLC                     
9C34  6D A5 06 ADC $06A5               
9C37  8D A5 06 STA $06A5               
9C3A  C8       INY                     
9C3B  C0 06    CPY #$06                
9C3D  D0 F1    BNE loc_9C30            

loc_9C3F:  ; 1 xrefs: 9C4E
9C3F  B9 80 06 LDA $0680,Y             
9C42  29 06    AND #$06                
9C44  18       CLC                     
9C45  6D A5 06 ADC $06A5               
9C48  8D A5 06 STA $06A5               
9C4B  C8       INY                     
9C4C  C0 0B    CPY #$0B                
9C4E  D0 EF    BNE loc_9C3F            
9C50  B9 80 06 LDA $0680,Y             
9C53  29 04    AND #$04                
9C55  18       CLC                     
9C56  6D A5 06 ADC $06A5               
9C59  8D A5 06 STA $06A5               
9C5C  AD A5 06 LDA $06A5               
9C5F  29 01    AND #$01                
9C61  85 02    STA $02                 
9C63  AD 86 06 LDA $0686               
9C66  29 01    AND #$01                
9C68  C5 02    CMP $02                 
9C6A  D0 61    BNE loc_9CCD            
9C6C  AD A5 06 LDA $06A5               
9C6F  29 02    AND #$02                
9C71  4A       LSR A                   
9C72  85 02    STA $02                 
9C74  AD 87 06 LDA $0687               
9C77  29 01    AND #$01                
9C79  C5 02    CMP $02                 
9C7B  D0 50    BNE loc_9CCD            
9C7D  AD A5 06 LDA $06A5               
9C80  29 04    AND #$04                
9C82  4A       LSR A                   
9C83  4A       LSR A                   
9C84  85 02    STA $02                 
9C86  AD 88 06 LDA $0688               
9C89  29 01    AND #$01                
9C8B  C5 02    CMP $02                 
9C8D  D0 3E    BNE loc_9CCD            
9C8F  AD A5 06 LDA $06A5               
9C92  29 08    AND #$08                
9C94  4A       LSR A                   
9C95  4A       LSR A                   
9C96  4A       LSR A                   
9C97  85 02    STA $02                 
9C99  AD 89 06 LDA $0689               
9C9C  29 01    AND #$01                
9C9E  C5 02    CMP $02                 
9CA0  D0 2B    BNE loc_9CCD            
9CA2  AD A5 06 LDA $06A5               
9CA5  29 10    AND #$10                
9CA7  4A       LSR A                   
9CA8  4A       LSR A                   
9CA9  4A       LSR A                   
9CAA  4A       LSR A                   
9CAB  85 02    STA $02                 
9CAD  AD 8A 06 LDA $068A               
9CB0  29 01    AND #$01                
9CB2  C5 02    CMP $02                 
9CB4  D0 17    BNE loc_9CCD            
9CB6  AD A5 06 LDA $06A5               
9CB9  29 60    AND #$60                
9CBB  4A       LSR A                   
9CBC  4A       LSR A                   
9CBD  4A       LSR A                   
9CBE  4A       LSR A                   
9CBF  4A       LSR A                   
9CC0  85 02    STA $02                 
9CC2  AD 8B 06 LDA $068B               
9CC5  29 03    AND #$03                
9CC7  C5 02    CMP $02                 
9CC9  D0 02    BNE loc_9CCD            
9CCB  18       CLC                     
9CCC  60       RTS                     

loc_9CCD:  ; 6 xrefs: 9C6A 9C7B 9C8D 9CA0 9CB4 9CC9
9CCD  38       SEC                     
9CCE  60       RTS                     

sub_9CCF:  ; 1 xrefs: 9A0E
9CCF  AD A0 06 LDA $06A0               
9CD2  C9 1F    CMP #$1F                
9CD4  D0 33    BNE loc_9D09            
9CD6  AD 80 06 LDA $0680               
9CD9  29 02    AND #$02                
9CDB  D0 2A    BNE loc_9D07            
9CDD  AD 81 06 LDA $0681               
9CE0  29 06    AND #$06                
9CE2  D0 23    BNE loc_9D07            
9CE4  AD 82 06 LDA $0682               
9CE7  29 06    AND #$06                
9CE9  D0 1C    BNE loc_9D07            
9CEB  AD 83 06 LDA $0683               
9CEE  29 02    AND #$02                
9CF0  D0 15    BNE loc_9D07            
9CF2  AD 84 06 LDA $0684               
9CF5  29 02    AND #$02                
9CF7  D0 0E    BNE loc_9D07            
9CF9  AD 85 06 LDA $0685               
9CFC  29 06    AND #$06                
9CFE  D0 07    BNE loc_9D07            
9D00  AD 86 06 LDA $0686               
9D03  29 04    AND #$04                
9D05  F0 09    BEQ loc_9D10            

loc_9D07:  ; 7 xrefs: 9CDB 9CE2 9CE9 9CF0 9CF7 9CFE 9D0E
9D07  38       SEC                     
9D08  60       RTS                     

loc_9D09:  ; 1 xrefs: 9CD4
9D09  AD A0 06 LDA $06A0               
9D0C  29 10    AND #$10                
9D0E  D0 F7    BNE loc_9D07            

loc_9D10:  ; 1 xrefs: 9D05
9D10  18       CLC                     
9D11  60       RTS                     

loc_9D12:  ; 0 xrefs: 
9D12  AD A0 06 LDA $06A0               
9D15  85 5B    STA $5B                 
9D17  C9 1F    CMP #$1F                
9D19  D0 03    BNE loc_9D1E            
9D1B  4C 45 9D JMP loc_9D45            

loc_9D1E:  ; 1 xrefs: 9D19
9D1E  AD A1 06 LDA $06A1               
9D21  85 2C    STA $2C                 
9D23  AD A3 06 LDA $06A3               
9D26  85 2B    STA $2B                 
9D28  AD A2 06 LDA $06A2               
9D2B  85 9E    STA $9E                 
9D2D  AD A4 06 LDA $06A4               
9D30  85 9D    STA $9D                 
9D32  AD 88 06 LDA $0688               
9D35  29 06    AND #$06                
9D37  4A       LSR A                   
9D38  85 56    STA $56                 
9D3A  AD 8A 06 LDA $068A               
9D3D  29 06    AND #$06                
9D3F  0A       ASL A                   
9D40  05 56    ORA $56                 
9D42  85 56    STA $56                 
9D44  60       RTS                     

loc_9D45:  ; 1 xrefs: 9D1B
9D45  AD A1 06 LDA $06A1               
9D48  85 2C    STA $2C                 
9D4A  AD A3 06 LDA $06A3               
9D4D  85 2B    STA $2B                 
9D4F  AD A2 06 LDA $06A2               
9D52  85 9E    STA $9E                 
9D54  AD A4 06 LDA $06A4               
9D57  85 9D    STA $9D                 
9D59  AD 88 06 LDA $0688               
9D5C  29 06    AND #$06                
9D5E  4A       LSR A                   
9D5F  85 56    STA $56                 
9D61  AD 8A 06 LDA $068A               
9D64  29 06    AND #$06                
9D66  0A       ASL A                   
9D67  05 56    ORA $56                 
9D69  85 56    STA $56                 
9D6B  60       RTS                     

sub_9D6C:  ; 1 xrefs: 9A13
9D6C  AD A0 06 LDA $06A0               
9D6F  C9 1F    CMP #$1F                
9D71  D0 03    BNE loc_9D76            
9D73  4C 8F 9D JMP loc_9D8F            

loc_9D76:  ; 1 xrefs: 9D71
9D76  20 AA 9D JSR sub_9DAA            
9D79  AD A1 06 LDA $06A1               
9D7C  D0 2A    BNE loc_9DA8            
9D7E  AD A2 06 LDA $06A2               
9D81  D0 25    BNE loc_9DA8            
9D83  AD A3 06 LDA $06A3               
9D86  D0 20    BNE loc_9DA8            
9D88  AD A4 06 LDA $06A4               
9D8B  D0 1B    BNE loc_9DA8            
9D8D  F0 17    BEQ loc_9DA6            

loc_9D8F:  ; 1 xrefs: 9D73
9D8F  20 52 9E JSR sub_9E52            
9D92  AD A1 06 LDA $06A1               
9D95  D0 11    BNE loc_9DA8            
9D97  AD A2 06 LDA $06A2               
9D9A  D0 0C    BNE loc_9DA8            
9D9C  AD A3 06 LDA $06A3               
9D9F  D0 07    BNE loc_9DA8            
9DA1  AD A4 06 LDA $06A4               
9DA4  D0 02    BNE loc_9DA8            

loc_9DA6:  ; 1 xrefs: 9D8D
9DA6  18       CLC                     
9DA7  60       RTS                     

loc_9DA8:  ; 8 xrefs: 9D7C 9D81 9D86 9D8B 9D95 9D9A 9D9F 9DA4
9DA8  38       SEC                     
9DA9  60       RTS                     

sub_9DAA:  ; 1 xrefs: 9D76
9DAA  AD 80 06 LDA $0680               
9DAD  29 06    AND #$06                
9DAF  4A       LSR A                   
9DB0  8D A1 06 STA $06A1               
9DB3  AD 81 06 LDA $0681               
9DB6  29 06    AND #$06                
9DB8  0A       ASL A                   
9DB9  0D A1 06 ORA $06A1               
9DBC  8D A1 06 STA $06A1               
9DBF  AD 82 06 LDA $0682               
9DC2  29 06    AND #$06                
9DC4  0A       ASL A                   
9DC5  0A       ASL A                   
9DC6  0A       ASL A                   
9DC7  0D A1 06 ORA $06A1               
9DCA  8D A1 06 STA $06A1               
9DCD  AD 83 06 LDA $0683               
9DD0  29 04    AND #$04                
9DD2  0A       ASL A                   
9DD3  0A       ASL A                   
9DD4  0A       ASL A                   
9DD5  0A       ASL A                   
9DD6  0D A1 06 ORA $06A1               
9DD9  8D A1 06 STA $06A1               
9DDC  AD 86 06 LDA $0686               
9DDF  29 06    AND #$06                
9DE1  4A       LSR A                   
9DE2  8D A3 06 STA $06A3               
9DE5  AD 85 06 LDA $0685               
9DE8  29 06    AND #$06                
9DEA  0A       ASL A                   
9DEB  0D A3 06 ORA $06A3               
9DEE  8D A3 06 STA $06A3               
9DF1  AD 84 06 LDA $0684               
9DF4  29 06    AND #$06                
9DF6  0A       ASL A                   
9DF7  0A       ASL A                   
9DF8  0A       ASL A                   
9DF9  0D A3 06 ORA $06A3               
9DFC  8D A3 06 STA $06A3               
9DFF  AD 83 06 LDA $0683               
9E02  29 02    AND #$02                
9E04  0A       ASL A                   
9E05  0A       ASL A                   
9E06  0A       ASL A                   
9E07  0A       ASL A                   
9E08  0A       ASL A                   
9E09  0D A3 06 ORA $06A3               
9E0C  8D A3 06 STA $06A3               
9E0F  AD 80 06 LDA $0680               
9E12  29 01    AND #$01                
9E14  8D A2 06 STA $06A2               
9E17  AD 81 06 LDA $0681               
9E1A  29 01    AND #$01                
9E1C  0A       ASL A                   
9E1D  0D A2 06 ORA $06A2               
9E20  8D A2 06 STA $06A2               
9E23  AD 82 06 LDA $0682               
9E26  29 01    AND #$01                
9E28  0A       ASL A                   
9E29  0A       ASL A                   
9E2A  0D A2 06 ORA $06A2               
9E2D  8D A2 06 STA $06A2               
9E30  AD 83 06 LDA $0683               
9E33  29 01    AND #$01                
9E35  8D A4 06 STA $06A4               
9E38  AD 84 06 LDA $0684               
9E3B  29 01    AND #$01                
9E3D  0A       ASL A                   
9E3E  0D A4 06 ORA $06A4               
9E41  8D A4 06 STA $06A4               
9E44  AD 85 06 LDA $0685               
9E47  29 01    AND #$01                
9E49  0A       ASL A                   
9E4A  0A       ASL A                   
9E4B  0D A4 06 ORA $06A4               
9E4E  8D A4 06 STA $06A4               
9E51  60       RTS                     

sub_9E52:  ; 1 xrefs: 9D8F
9E52  AD 80 06 LDA $0680               
9E55  29 04    AND #$04                
9E57  0A       ASL A                   
9E58  0A       ASL A                   
9E59  0A       ASL A                   
9E5A  0A       ASL A                   
9E5B  0A       ASL A                   
9E5C  8D A1 06 STA $06A1               
9E5F  AD 84 06 LDA $0684               
9E62  29 04    AND #$04                
9E64  0A       ASL A                   
9E65  0A       ASL A                   
9E66  0A       ASL A                   
9E67  0A       ASL A                   
9E68  0A       ASL A                   
9E69  8D A3 06 STA $06A3               
9E6C  AD 80 06 LDA $0680               
9E6F  29 01    AND #$01                
9E71  8D A2 06 STA $06A2               
9E74  AD 81 06 LDA $0681               
9E77  29 01    AND #$01                
9E79  0A       ASL A                   
9E7A  0D A2 06 ORA $06A2               
9E7D  8D A2 06 STA $06A2               
9E80  AD 82 06 LDA $0682               
9E83  29 01    AND #$01                
9E85  0A       ASL A                   
9E86  0A       ASL A                   
9E87  0D A2 06 ORA $06A2               
9E8A  8D A2 06 STA $06A2               
9E8D  AD 83 06 LDA $0683               
9E90  29 04    AND #$04                
9E92  0A       ASL A                   
9E93  0D A2 06 ORA $06A2               
9E96  8D A2 06 STA $06A2               
9E99  AD 83 06 LDA $0683               
9E9C  29 01    AND #$01                
9E9E  8D A4 06 STA $06A4               
9EA1  AD 84 06 LDA $0684               
9EA4  29 01    AND #$01                
9EA6  0A       ASL A                   
9EA7  0D A4 06 ORA $06A4               
9EAA  8D A4 06 STA $06A4               
9EAD  AD 85 06 LDA $0685               
9EB0  29 01    AND #$01                
9EB2  0A       ASL A                   
9EB3  0A       ASL A                   
9EB4  0D A4 06 ORA $06A4               
9EB7  8D A4 06 STA $06A4               
9EBA  AD 86 06 LDA $0686               
9EBD  29 02    AND #$02                
9EBF  0A       ASL A                   
9EC0  0A       ASL A                   
9EC1  0D A4 06 ORA $06A4               
9EC4  8D A4 06 STA $06A4               
9EC7  60       RTS                     

loc_9EC8:  ; 1 xrefs: 8024
9EC8  A5 19    LDA $19                 
9ECA  20 4F C8 JSR $C84F               
9ECD  0F 9F 56 SLO $569F               

; ==== data $9ED0..$A05C  (397 bytes) ====
9ED0  9F E6 A5 5D 9F 62 9F 99 A5 AA A5 B5 A5 0B A6 32  |...].b.........2
9EE0  A6 69 9F E6 A5 70 9F 7B 9F 95 9F E1 9F B5 A5 32  |.i...p.{.......2
9EF0  A6 FB 9F 08 A0 99 A5 AA A5 18 A0 43 A0 6D A0 E6  |...........C.m..
9F00  A5 74 A0 AA A5 88 A0 99 A5 AA A5 B5 A5 8F A0 20  |.t............. 
9F10  D9 80 B0 01 60 20 82 C8 20 13 C8 A9 00 85 87 85  |....` .. .......
9F20  2E 85 4E 85 AD 85 51 85 50 85 4F A9 02 85 87 20  |..N...Q.P.O.... 
9F30  3D C8 A2 1A 20 4C C8 A0 0E 84 42 A0 18 84 43 A5  |=... L....B...C.
9F40  9A D0 04 A0 01 D0 07 A9 01 8D 2C 04 A0 07 84 44  |..........,....D
9F50  20 3E A7 4C 9A C8 A9 09 A2 1A 4C E0 A5 A9 27 4C  | >.L......L...'L
9F60  FB A5 A9 0B A0 80 4C 8E A5 A9 05 A2 1A 4C E0 A5  |......L......L..
9F70  A9 2D 20 44 80 20 CA C8 4C 9A C8 A9 00 8D 08 05  |.- D. ..L.......
9F80  8D FA 05 A9 80 8D C6 04 A9 06 8D 42 04 A9 20 8D  |...........B.. .
9F90  E4 05 4C 9A C8 20 B4 A0 20 82 A1 20 D8 C9 20 A4  |..L.. .. .. .. .
9FA0  A0 A5 1C 29 07 D0 0F EE CE 05 AD CE 05 29 03 A8  |...).........)..
9FB0  B9 DD 9F 8D 42 04 EE 08 05 AD 08 05 C9 FF F0 01  |....B...........
9FC0  60 A9 00 8D 08 05 8D C6 04 8D 42 04 8D CE 05 85  |`.........B.....
9FD0  9A 85 FD A9 A8 85 FF 20 D8 C9 4C 9A C8 07 08 05  |....... ..L.....
9FE0  06 20 B4 A0 A9 00 8D CE 05 8D E4 05 8D FA 05 8D  |. ..............
9FF0  2C 04 85 FD A9 A8 85 FF 4C 9A C8 20 3D C8 A9 49  |,.......L.. =..I
A000  20 1C C8 A9 00 4C FB A5 A2 0C A5 53 C9 05 D0 02  | ....L.....S....
A010  A2 16 8A A0 80 4C 8E A5 20 D9 80 B0 01 60 20 3D  |.....L.. ....` =
A020  C8 20 82 C8 20 13 C8 A5 53 C9 05 F0 0D A9 03 85  |. .. ...S.......
A030  18 A9 14 85 19 A9 00 85 9A 60 A9 07 85 18 A9 00  |.........`......
A040  85 19 60 20 D9 80 B0 01 60 A9 00 85 87 85 2E 85  |..` ....`.......
A050  4E 85 AD 85 50 85 4F 85 51 A0 0E 84 42           |N...P.O.Q...B

loc_A05D:  ; 1 xrefs: A0D6
A05D  C8       INY                     
A05E  84 43    STY $43                 
A060  20 82 C8 JSR $C882               
A063  20 3E A7 JSR sub_A73E            
A066  A9 02    LDA #$02                
A068  85 87    STA $87                 
A06A  4C 9A C8 JMP $C89A               

; ==== data $A06D..$A0A3  (55 bytes) ====
A06D  A9 08 A2 1A 4C E0 A5 A9 27 20 3E 80 20 3D C8 A9  |....L...' >. =..
A07D  37 20 1C C8 A9 80 85 51 4C 9A C8 A9 0D A0 80 4C  |7 .....QL......L
A08D  8E A5 A9 04 85 18 A9 00 85 19 A9 00 85 1A 85 9A  |................
A09D  85 9C A9 05 85 53 60                             |.....S`

loc_A0A4:  ; 0 xrefs: 
A0A4  A5 FD    LDA $FD                 
A0A6  18       CLC                     
A0A7  69 10    ADC #$10                
A0A9  85 FD    STA $FD                 
A0AB  D0 06    BNE loc_A0B3            
A0AD  A5 FF    LDA $FF                 
A0AF  49 01    EOR #$01                
A0B1  85 FF    STA $FF                 

loc_A0B3:  ; 1 xrefs: A0AB
A0B3  60       RTS                     

loc_A0B4:  ; 0 xrefs: 
A0B4  A2 06    LDX #$06                

loc_A0B6:  ; 1 xrefs: A0BC
A0B6  20 C7 A0 JSR sub_A0C7            
A0B9  E8       INX                     
A0BA  E0 0C    CPX #$0C                
A0BC  D0 F8    BNE loc_A0B6            

loc_A0BE:  ; 1 xrefs: A0C4
A0BE  20 44 A1 JSR sub_A144            
A0C1  E8       INX                     
A0C2  E0 16    CPX #$16                
A0C4  D0 F8    BNE loc_A0BE            
A0C6  60       RTS                     

sub_A0C7:  ; 1 xrefs: A0B6
A0C7  BD 8C 05 LDA $058C,X             
A0CA  D0 54    BNE loc_A120            
A0CC  FE 8C 05 INC $058C,X             

loc_A0CF:  ; 1 xrefs: A141
A0CF  20 39 C9 JSR $C939               
A0D2  29 1F    AND #$1F                
A0D4  18       CLC                     
A0D5  69 10    ADC #$10                
A0D7  85 08    STA $08                 
A0D9  20 39 C9 JSR $C939               
A0DC  29 1F    AND #$1F                
A0DE  18       CLC                     
A0DF  69 10    ADC #$10                
A0E1  85 09    STA $09                 

loc_A0E3:  ; 1 xrefs: A15E
A0E3  AD 08 05 LDA $0508               
A0E6  38       SEC                     
A0E7  E5 08    SBC $08                 
A0E9  9D 08 05 STA $0508,X             
A0EC  BD F2 04 LDA $04F2,X             
A0EF  E9 00    SBC #$00                
A0F1  9D F2 04 STA $04F2,X             
A0F4  AD C6 04 LDA $04C6               
A0F7  38       SEC                     
A0F8  E5 09    SBC $09                 
A0FA  9D C6 04 STA $04C6,X             
A0FD  BD B0 04 LDA $04B0,X             
A100  E9 00    SBC #$00                
A102  9D B0 04 STA $04B0,X             
A105  A9 01    LDA #$01                
A107  20 3A C8 JSR $C83A               
A10A  A9 10    LDA #$10                
A10C  9D CE 05 STA $05CE,X             
A10F  20 39 C9 JSR $C939               
A112  29 1F    AND #$1F                
A114  9D E4 05 STA $05E4,X             
A117  BD 2C 04 LDA $042C,X             
A11A  09 80    ORA #$80                
A11C  9D 2C 04 STA $042C,X             
A11F  60       RTS                     

loc_A120:  ; 1 xrefs: A0CA
A120  BD E4 05 LDA $05E4,X             
A123  F0 04    BEQ loc_A129            
A125  DE E4 05 DEC $05E4,X             
A128  60       RTS                     

loc_A129:  ; 1 xrefs: A123
A129  BD 2C 04 LDA $042C,X             
A12C  29 7F    AND #$7F                
A12E  9D 2C 04 STA $042C,X             
A131  DE CE 05 DEC $05CE,X             
A134  F0 03    BEQ loc_A139            
A136  4C 37 C8 JMP $C837               

loc_A139:  ; 1 xrefs: A134
A139  A9 00    LDA #$00                
A13B  9D F2 04 STA $04F2,X             
A13E  9D B0 04 STA $04B0,X             
A141  4C CF A0 JMP loc_A0CF            

sub_A144:  ; 1 xrefs: A0BE
A144  BD 8C 05 LDA $058C,X             
A147  D0 18    BNE loc_A161            
A149  FE 8C 05 INC $058C,X             

loc_A14C:  ; 1 xrefs: A17F
A14C  20 39 C9 JSR $C939               
A14F  18       CLC                     
A150  69 30    ADC #$30                
A152  85 08    STA $08                 
A154  20 39 C9 JSR $C939               
A157  29 1F    AND #$1F                
A159  18       CLC                     
A15A  69 10    ADC #$10                
A15C  85 09    STA $09                 
A15E  4C E3 A0 JMP loc_A0E3            

loc_A161:  ; 1 xrefs: A147
A161  BD E4 05 LDA $05E4,X             
A164  F0 04    BEQ loc_A16A            
A166  DE E4 05 DEC $05E4,X             
A169  60       RTS                     

loc_A16A:  ; 1 xrefs: A164
A16A  A9 00    LDA #$00                
A16C  9D 2C 04 STA $042C,X             
A16F  DE CE 05 DEC $05CE,X             
A172  F0 03    BEQ loc_A177            
A174  4C 37 C8 JMP $C837               

loc_A177:  ; 1 xrefs: A172
A177  A9 00    LDA #$00                
A179  9D F2 04 STA $04F2,X             
A17C  9D B0 04 STA $04B0,X             
A17F  4C 4C A1 JMP loc_A14C            

loc_A182:  ; 0 xrefs: 
A182  CE E4 05 DEC $05E4               
A185  F0 01    BEQ loc_A188            

loc_A187:  ; 1 xrefs: A18D
A187  60       RTS                     

loc_A188:  ; 1 xrefs: A185
A188  AD FA 05 LDA $05FA               
A18B  C9 03    CMP #$03                
A18D  F0 F8    BEQ loc_A187            
A18F  AD FA 05 LDA $05FA               
A192  A8       TAY                     
A193  B9 A1 A1 LDA $A1A1,Y             
A196  8D E4 05 STA $05E4               
A199  EE FA 05 INC $05FA               
A19C  A9 2D    LDA #$2D                
A19E  4C 1C C8 JMP $C81C               

; ==== data $A1A1..$A1A3  (3 bytes) ====
A1A1  30 40 38                                         |0@8

loc_A1A4:  ; 1 xrefs: 8027
A1A4  A5 19    LDA $19                 
A1A6  20 4F C8 JSR $C84F               
A1A9  F1 A1    SBC ($A1),Y             
A1AB  41 A2    EOR ($A2,X)             
A1AD  4C A2 32 JMP $32A2               

; ==== data $A1B0..$A25F  (176 bytes) ====
A1B0  A6 6B A2 E6 A5 72 A2 8F A2 9C A2 A2 A2 A8 A2 AE  |.k...r..........
A1C0  A2 B5 A5 0B A6 32 A6 C5 A2 E6 A5 D4 A2 AA A5 E0  |.....2..........
A1D0  A2 AA A5 F8 A2 1E A3 50 A3 78 A3 BA A3 F0 A3 03  |.......P.x......
A1E0  A4 19 A4 2D A4 33 A4 40 A4 46 A4 2D A4 6F A4 7F  |...-.3.@.F.-.o..
A1F0  A4 20 D9 80 B0 01 60 20 3D C8 A9 4B 20 1C C8 20  |. ....` =..K .. 
A200  82 C8 20 13 C8 A9 0C 85 87 A9 00 85 50 85 4F 8D  |.. .........P.O.
A210  6C 01 8D 6F 01 85 51 A2 18 20 4C C8 A9 22 20 3E  |l..o..Q.. L.." >
A220  80 A0 1A 84 42 C8 84 43 A0 3C 84 44 C8 84 45 A9  |....B..C.<.D..E.
A230  5B 8D 42 04 A9 80 8D 08 05 A9 60 8D C6 04 4C 9A  |[.B.......`...L.
A240  C8 20 B7 A4 C6 51 F0 01 60 4C 9A C8 20 B7 A4 20  |. ...Q..`L.. .. 
A250  D9 80 B0 01 60 A9 00 85 FD 85 50 85 51 A9 A8 85  |....`.....P.Q...

loc_A260:  ; 0 xrefs: 
A260  FF 20 3E ISC $3E20,X             
A263  A7 A9    LAX $A9                 

; ==== data $A265..$A457  (499 bytes) ====
A265  02 85 87 4C 9A C8 A9 04 A2 1A 4C E0 A5 A9 5E 8D  |...L......L...^.
A275  42 04 A9 50 8D C6 04 A9 00 85 50 85 51 85 4F 8D  |B..P......P.Q.O.
A285  6C 01 8D 6F 01 A9 28 4C FB A5 20 82 A4 A9 18 18  |l..o..(L.. .....
A295  65 4F A0 60 4C 8E A5 20 82 A4 4C 99 A5 20 82 A4  |eO.`L.. ..L.. ..
A2A5  4C AA A5 20 82 A4 4C 0B A6 20 82 A4 E6 4F A5 4F  |L.. ..L.. ...O.O
A2B5  C9 03 F0 05 A9 07 85 19 60 A9 00 85 4F 4C 9A C8  |........`...OL..
A2C5  20 13 C8 A9 1F 85 42 A9 03 20 C1 A7 4C 9A C8 A9  | .....B.. ..L...
A2D5  40 85 51 A9 29 18 65 4F 4C FB A5 E6 4F A5 4F C9  |@.Q.).eOL...O.O.
A2E5  04 F0 05 A9 11 85 19 60 A9 00 85 4F A9 40 85 51  |.......`...O.@.Q
A2F5  4C 9A C8 A0 46 84 44 C8 84 45 A0 2E 84 46 C8 84  |L...F.D..E...F..
A305  47 A9 FF 8D F2 04 A9 F0 8D 08 05 A9 7E 8D C6 04  |G...........~...
A315  A9 00 AA 20 3A C8 4C 9A C8 A2 00 20 37 C8 AD 08  |... :.L.... 7...
A325  05 18 69 02 8D 08 05 AD F2 04 69 00 8D F2 04 D0  |..i.......i.....
A335  19 AD 08 05 C9 80 D0 12 A9 61 8D 42 04 A9 04 8D  |.........a.B....
A345  CE 05 A9 00 8D E4 05 4C 9A C8 60 CE CE 05 F0 01  |.......L..`.....
A355  60 AD E4 05 C9 01 F0 0E A9 62 8D 42 04 EE E4 05  |`........b.B....
A365  A9 04 8D CE 05 60 A9 63 8D 42 04 A9 00 8D E4 05  |.....`.c.B......
A375  4C 9A C8 A5 1C 29 03 D0 12 EE E4 05 AD E4 05 C9  |L....)..........
A385  40 F0 09 29 01 18 69 63 8D 42 04 60 A9 65 8D 42  |@..)..ic.B.`.e.B
A395  04 A9 6A 8D 43 04 AD 08 05 18 69 20 8D 09 05 AD  |..j.C.....i ....
A3A5  C6 04 38 E9 30 8D C7 04 A9 00 8D CE 05 A9 20 8D  |..8.0......... .
A3B5  E4 05 4C 9A C8 AD E4 05 F0 04 CE E4 05 60 A5 1C  |..L..........`..
A3C5  29 0F D0 15 A9 00 8D 43 04 EE CE 05 AD CE 05 C9  |)......C........
A3D5  04 F0 07 18 69 65 8D 42 04 60 A9 6B 8D 42 04 AD  |....ie.B.`.k.B..
A3E5  C6 04 18 69 02 8D C6 04 4C 9A C8 EE 08 05 F0 01  |...i....L.......
A3F5  60 A9 00 8D 42 04 A9 40 8D CE 05 4C 9A C8 CE CE  |`...B..@...L....
A405  05 F0 01 60 20 13 C8 A9 00 85 4F A9 20 85 51 A9  |...` .....O. .Q.
A415  2C 4C FB A5 C6 51 F0 01 60 20 83 A6 A9 FF 8D 6B  |,L...Q..` .....k
A425  01 A9 1F A0 00 4C 8E A5 20 83 A6 4C 99 A5 20 83  |.....L.. ..L.. .
A435  A6 A5 1C 29 01 F0 01 60 4C AA A5 20 83 A6 4C 0B  |...)...`L.. ..L.
A445  A6 20 83 A6 A9 00 85 51 A9 20 18 65 4F 20 65 8E  |. .....Q. .eO e.
A455  E6 4F A5                                         |.O.

loc_A458:  ; 0 xrefs: 
A458  4F C9 05 SRE $05C9               
A45B  F0 05    BEQ loc_A462            
A45D  A9 1D    LDA #$1D                
A45F  85 19    STA $19                 
A461  60       RTS                     

loc_A462:  ; 1 xrefs: A45B
A462  A9 00    LDA #$00                
A464  8D 6F 01 STA $016F               
A467  A9 02    LDA #$02                
A469  8D 6C 01 STA $016C               
A46C  4C 9A C8 JMP $C89A               

; ==== data $A46F..$A481  (19 bytes) ====
A46F  CE 6F 01 D0 08 CE 6C 01 D0 03 4C 9A C8 4C 83 A6  |.o....l...L..L..
A47F  4C DB C9                                         |L..

loc_A482:  ; 0 xrefs: 
A482  A5 1C    LDA $1C                 
A484  29 01    AND #$01                
A486  F0 27    BEQ loc_A4AF            
A488  EE 6F 01 INC $016F               
A48B  AD 6F 01 LDA $016F               
A48E  29 03    AND #$03                
A490  A8       TAY                     
A491  B9 B3 A4 LDA $A4B3,Y             
A494  8D 42 04 STA $0442               
A497  EE 6C 01 INC $016C               
A49A  AD 6C 01 LDA $016C               
A49D  C9 03    CMP #$03                
A49F  D0 05    BNE loc_A4A6            
A4A1  A9 00    LDA #$00                
A4A3  8D 6C 01 STA $016C               

loc_A4A6:  ; 1 xrefs: A49F
A4A6  AC 6C 01 LDY $016C               
A4A9  B9 B0 A4 LDA $A4B0,Y             
A4AC  20 3E 80 JSR sub_803E            

loc_A4AF:  ; 1 xrefs: A486
A4AF  60       RTS                     
A4B0  28       PLP                     
A4B1  23 24    RLA ($24,X)             
A4B3  5E 5F 60 LSR $605F,X             
A4B6  00 A5    BRK #$A5                

; ==== data $A4B8..$A4B8  (1 bytes) ====
A4B8  1C                                               |.
A4B9  29 01    AND #$01                
A4BB  F0 18    BEQ loc_A4D5            
A4BD  EE 6C 01 INC $016C               
A4C0  AD 6C 01 LDA $016C               
A4C3  C9 03    CMP #$03                
A4C5  D0 05    BNE loc_A4CC            
A4C7  A9 00    LDA #$00                
A4C9  8D 6C 01 STA $016C               

loc_A4CC:  ; 1 xrefs: A4C5
A4CC  AD 6C 01 LDA $016C               
A4CF  18       CLC                     
A4D0  69 5B    ADC #$5B                
A4D2  8D 42 04 STA $0442               

loc_A4D5:  ; 1 xrefs: A4BB
A4D5  A5 FD    LDA $FD                 
A4D7  18       CLC                     
A4D8  69 10    ADC #$10                
A4DA  85 FD    STA $FD                 
A4DC  D0 06    BNE loc_A4E4            
A4DE  A5 FF    LDA $FF                 
A4E0  49 01    EOR #$01                
A4E2  85 FF    STA $FF                 

loc_A4E4:  ; 1 xrefs: A4DC
A4E4  60       RTS                     

loc_A4E5:  ; 1 xrefs: 802A
A4E5  A5 19    LDA $19                 
A4E7  20 4F C8 JSR $C84F               
A4EA  40       RTI                     

; ==== data $A4EB..$A51F  (53 bytes) ====
A4EB  A5 6D A5 79 A5 7F A5 87 A5 96 A5 A1 A5 B2 A5 0B  |.m.y............
A4FB  A6 DC A5 E6 A5 F9 A5 01 A6 99 A5 AA A5 0B A6 1E  |................
A50B  A6 B5 A5 0B A6 32 A6 45 A6 4A A6 99 A5 AA A5 B5  |.....2.E.J......
A51B  A5 C9 A5 51 A6                                   |...Q.

loc_A520:  ; 0 xrefs: 
A520  E6 A5    INC $A5                 
A522  58       CLI                     
A523  A6 5D    LDX $5D                 
A525  A6 99    LDX $99                 
A527  A5 AA    LDA $AA                 
A529  A5 B5    LDA $B5                 
A52B  A5 0B    LDA $0B                 
A52D  A6 32    LDX $32                 
A52F  A6 64    LDX $64                 
A531  A6 E6    LDX $E6                 
A533  A5 6B    LDA $6B                 
A535  A6 70    LDX $70                 
A537  A6 99    LDX $99                 
A539  A5 AA    LDA $AA                 
A53B  A5 B5    LDA $B5                 
A53D  A5 77    LDA $77                 
A53F  A6 20    LDX $20                 
A541  3D C8 A9 AND $A9C8,X             
A544  4A       LSR A                   
A545  20 1C C8 JSR $C81C               
A548  20 13 C8 JSR $C813               
A54B  20 82 C8 JSR $C882               
A54E  A0 0E    LDY #$0E                
A550  84 42    STY $42                 
A552  A0 19    LDY #$19                
A554  84 43    STY $43                 
A556  A9 2E    LDA #$2E                
A558  20 3E 80 JSR sub_803E            
A55B  A9 02    LDA #$02                
A55D  85 87    STA $87                 
A55F  A9 00    LDA #$00                
A561  85 51    STA $51                 
A563  85 50    STA $50                 
A565  85 4F    STA $4F                 
A567  20 3E A7 JSR sub_A73E            
A56A  4C 9A C8 JMP $C89A               

; ==== data $A56D..$A58D  (33 bytes) ====
A56D  A9 1F 85 42 A9 03 20 C1 A7 4C 9A C8 20 83 A6 4C  |...B.. ..L.. ..L
A57D  E6 A5 20 83 A6 A9 29 4C FB A5 20 83 A6 A9 01 A0  |.. ...)L.. .....
A58D  2E                                               |.

loc_A58E:  ; 1 xrefs: B0AD
A58E  84 51    STY $51                 
A590  20 65 8E JSR sub_8E65            
A593  4C 9A C8 JMP $C89A               

; ==== data $A596..$A598  (3 bytes) ====
A596  20 83 A6                                         | ..

loc_A599:  ; 0 xrefs: 
A599  A5 90    LDA $90                 
A59B  F0 01    BEQ loc_A59E            
A59D  60       RTS                     

loc_A59E:  ; 1 xrefs: A59B
A59E  4C 9A C8 JMP $C89A               

; ==== data $A5A1..$A5A9  (9 bytes) ====
A5A1  20 83 A6 A5 1C 29 0F D0 04                       | ....)...

loc_A5AA:  ; 0 xrefs: 
A5AA  C6 51    DEC $51                 
A5AC  F0 01    BEQ loc_A5AF            
A5AE  60       RTS                     

loc_A5AF:  ; 1 xrefs: A5AC
A5AF  4C 9A C8 JMP $C89A               

; ==== data $A5B2..$A5B4  (3 bytes) ====
A5B2  20 83 A6                                         | ..

loc_A5B5:  ; 0 xrefs: 
A5B5  20 D9 80 JSR sub_80D9            
A5B8  B0 01    BCS loc_A5BB            
A5BA  60       RTS                     

loc_A5BB:  ; 1 xrefs: A5B8
A5BB  AD 2C 04 LDA $042C               
A5BE  48       PHA                     
A5BF  20 13 C8 JSR $C813               
A5C2  68       PLA                     
A5C3  8D 2C 04 STA $042C               
A5C6  4C 9A C8 JMP $C89A               

; ==== data $A5C9..$A5DF  (23 bytes) ====
A5C9  20 1B A7 E6 50 A5 50 C9 04 F0 01 60 A9 00 85 50  | ...P.P....`...P
A5D9  4C 9A C8 A9 00 A2 18                             |L......

loc_A5E0:  ; 0 xrefs: 
A5E0  20 BC A7 JSR sub_A7BC            
A5E3  4C 9A C8 JMP $C89A               

loc_A5E6:  ; 0 xrefs: 
A5E6  20 E0 A7 JSR sub_A7E0            
A5E9  E6 50    INC $50                 
A5EB  A5 50    LDA $50                 
A5ED  C9 0B    CMP #$0B                
A5EF  F0 01    BEQ loc_A5F2            
A5F1  60       RTS                     

loc_A5F2:  ; 1 xrefs: A5EF
A5F2  A9 00    LDA #$00                
A5F4  85 50    STA $50                 
A5F6  4C 9A C8 JMP $C89A               

; ==== data $A5F9..$A5FA  (2 bytes) ====
A5F9  A9 21                                            |.!

loc_A5FB:  ; 0 xrefs: 
A5FB  20 3E 80 JSR sub_803E            
A5FE  4C 9A C8 JMP $C89A               

; ==== data $A601..$A60A  (10 bytes) ====
A601  A9 02 18 65 4F A0 80 4C 8E A5                    |...eO..L..

loc_A60B:  ; 0 xrefs: 
A60B  20 F4 A6 JSR sub_A6F4            
A60E  E6 50    INC $50                 
A610  A5 50    LDA $50                 
A612  C9 05    CMP #$05                
A614  F0 01    BEQ loc_A617            
A616  60       RTS                     

loc_A617:  ; 1 xrefs: A614
A617  A9 00    LDA #$00                
A619  85 50    STA $50                 
A61B  4C 9A C8 JMP $C89A               

; ==== data $A61E..$A631  (20 bytes) ====
A61E  E6 4F A5 4F C9 06 F0 05 A9 0C 85 19 60 A9 00 85  |.O.O........`...
A62E  4F 4C 9A C8                                      |OL..

loc_A632:  ; 0 xrefs: 
A632  20 70 A7 JSR sub_A770            
A635  E6 50    INC $50                 
A637  A5 50    LDA $50                 
A639  C9 0B    CMP #$0B                
A63B  F0 01    BEQ loc_A63E            
A63D  60       RTS                     

loc_A63E:  ; 1 xrefs: A63B
A63E  A9 00    LDA #$00                
A640  85 50    STA $50                 
A642  4C 9A C8 JMP $C89A               

; ==== data $A645..$A682  (62 bytes) ====
A645  A9 00 4C FB A5 A9 08 A0 80 4C 8E A5 A9 01 A2 1C  |..L......L......
A655  4C E0 A5 A9 21 4C FB A5 A9 09 A0 80 4C 8E A5 A9  |L...!L......L...
A665  02 A2 18 4C E0 A5 A9 21 4C FB A5 A9 0A A0 80 4C  |...L...!L......L
A675  8E A5 20 13 C8 A9 00 85 18 85 19 4C 3D C8        |.. ........L=.

loc_A683:  ; 0 xrefs: 
A683  A2 06    LDX #$06                

loc_A685:  ; 1 xrefs: A68B
A685  20 8E A6 JSR sub_A68E            
A688  E8       INX                     
A689  E0 16    CPX #$16                
A68B  D0 F8    BNE loc_A685            
A68D  60       RTS                     

sub_A68E:  ; 1 xrefs: A685
A68E  BD 8C 05 LDA $058C,X             
A691  D0 23    BNE loc_A6B6            
A693  A9 11    LDA #$11                
A695  85 45    STA $45                 
A697  FE 8C 05 INC $058C,X             

loc_A69A:  ; 1 xrefs: A6F2
A69A  A9 30    LDA #$30                
A69C  9D C6 04 STA $04C6,X             
A69F  20 39 C9 JSR $C939               
A6A2  9D 08 05 STA $0508,X             
A6A5  20 39 C9 JSR $C939               
A6A8  29 3F    AND #$3F                
A6AA  9D CE 05 STA $05CE,X             
A6AD  A9 00    LDA #$00                
A6AF  9D 42 04 STA $0442,X             
A6B2  9D DC 04 STA $04DC,X             
A6B5  60       RTS                     

loc_A6B6:  ; 1 xrefs: A691
A6B6  BD CE 05 LDA $05CE,X             
A6B9  F0 04    BEQ loc_A6BF            
A6BB  DE CE 05 DEC $05CE,X             

loc_A6BE:  ; 1 xrefs: A6F0
A6BE  60       RTS                     

loc_A6BF:  ; 1 xrefs: A6B9
A6BF  86 17    STX $17                 
A6C1  A9 29    LDA #$29                
A6C3  9D 42 04 STA $0442,X             
A6C6  BD 08 05 LDA $0508,X             
A6C9  18       CLC                     
A6CA  69 80    ADC #$80                
A6CC  9D 08 05 STA $0508,X             
A6CF  A5 17    LDA $17                 
A6D1  4A       LSR A                   
A6D2  B0 14    BCS loc_A6E8            
A6D4  BD DC 04 LDA $04DC,X             
A6D7  18       CLC                     
A6D8  69 80    ADC #$80                
A6DA  9D DC 04 STA $04DC,X             
A6DD  BD C6 04 LDA $04C6,X             
A6E0  69 00    ADC #$00                
A6E2  9D C6 04 STA $04C6,X             
A6E5  4C EB A6 JMP loc_A6EB            

loc_A6E8:  ; 1 xrefs: A6D2
A6E8  FE C6 04 INC $04C6,X             

loc_A6EB:  ; 1 xrefs: A6E5
A6EB  BD C6 04 LDA $04C6,X             
A6EE  C9 80    CMP #$80                
A6F0  90 CC    BCC loc_A6BE            
A6F2  B0 A6    BCS loc_A69A            

sub_A6F4:  ; 1 xrefs: A60B
A6F4  A5 50    LDA $50                 
A6F6  0A       ASL A                   
A6F7  A8       TAY                     
A6F8  B9 2C A7 LDA $A72C,Y             
A6FB  85 00    STA $00                 
A6FD  B9 2D A7 LDA $A72D,Y             
A700  85 01    STA $01                 

loc_A702:  ; 1 xrefs: A729
A702  A9 03    LDA #$03                
A704  20 49 C8 JSR $C849               
A707  A5 00    LDA $00                 
A709  20 49 C8 JSR $C849               
A70C  A5 01    LDA $01                 
A70E  20 49 C8 JSR $C849               
A711  A9 1C    LDA #$1C                
A713  20 49 C8 JSR $C849               
A716  A9 00    LDA #$00                
A718  4C 49 C8 JMP $C849               

loc_A71B:  ; 0 xrefs: 
A71B  A5 50    LDA $50                 
A71D  0A       ASL A                   
A71E  A8       TAY                     
A71F  B9 36 A7 LDA $A736,Y             
A722  85 00    STA $00                 
A724  B9 37 A7 LDA $A737,Y             
A727  85 01    STA $01                 
A729  4C 02 A7 JMP loc_A702            

; ==== data $A72C..$A73D  (18 bytes) ====
A72C  42 22 82 22 C2 22 02 23 42 23 E2 20 22 21 62 21  |B".".".#B#. "!b!
A73C  A2 21                                            |.!

sub_A73E:  ; 3 xrefs: A063 A567 B07B
A73E  A9 03    LDA #$03                
A740  20 49 C8 JSR $C849               
A743  A9 A0    LDA #$A0                
A745  20 49 C8 JSR $C849               
A748  A9 20    LDA #$20                
A74A  20 49 C8 JSR $C849               
A74D  A9 20    LDA #$20                
A74F  20 49 C8 JSR $C849               
A752  A9 FD    LDA #$FD                
A754  20 49 C8 JSR $C849               
A757  A9 03    LDA #$03                
A759  20 49 C8 JSR $C849               
A75C  A9 00    LDA #$00                
A75E  20 49 C8 JSR $C849               
A761  A9 22    LDA #$22                
A763  20 49 C8 JSR $C849               
A766  A9 20    LDA #$20                
A768  20 49 C8 JSR $C849               
A76B  A9 FE    LDA #$FE                
A76D  4C 49 C8 JMP $C849               

sub_A770:  ; 1 xrefs: A632
A770  A5 50    LDA $50                 
A772  C9 0A    CMP #$0A                
A774  F0 25    BEQ loc_A79B            
A776  0A       ASL A                   
A777  A8       TAY                     
A778  B9 27 A9 LDA $A927,Y             
A77B  85 00    STA $00                 
A77D  B9 28 A9 LDA $A928,Y             
A780  85 01    STA $01                 
A782  A9 03    LDA #$03                
A784  20 49 C8 JSR $C849               
A787  A5 00    LDA $00                 
A789  20 49 C8 JSR $C849               
A78C  A5 01    LDA $01                 
A78E  20 49 C8 JSR $C849               
A791  A9 20    LDA #$20                
A793  20 49 C8 JSR $C849               
A796  A9 00    LDA #$00                
A798  4C 49 C8 JMP $C849               

loc_A79B:  ; 1 xrefs: A774
A79B  A9 0E    LDA #$0E                
A79D  85 42    STA $42                 
A79F  A9 19    LDA #$19                
A7A1  85 43    STA $43                 
A7A3  A9 03    LDA #$03                
A7A5  20 49 C8 JSR $C849               
A7A8  A9 C8    LDA #$C8                
A7AA  20 49 C8 JSR $C849               
A7AD  A9 23    LDA #$23                
A7AF  20 49 C8 JSR $C849               
A7B2  A9 18    LDA #$18                
A7B4  20 49 C8 JSR $C849               
A7B7  A9 00    LDA #$00                
A7B9  4C 49 C8 JMP $C849               

sub_A7BC:  ; 1 xrefs: A5E0
A7BC  86 42    STX $42                 
A7BE  E8       INX                     
A7BF  86 43    STX $43                 

loc_A7C1:  ; 0 xrefs: 
A7C1  85 06    STA $06                 
A7C3  0A       ASL A                   
A7C4  A8       TAY                     
A7C5  B9 3B A9 LDA $A93B,Y             
A7C8  8D 80 06 STA $0680               
A7CB  B9 3C A9 LDA $A93C,Y             
A7CE  8D 81 06 STA $0681               
A7D1  A9 00    LDA #$00                
A7D3  8D 82 06 STA $0682               
A7D6  8D 83 06 STA $0683               
A7D9  8D 84 06 STA $0684               
A7DC  8D 85 06 STA $0685               
A7DF  60       RTS                     

sub_A7E0:  ; 1 xrefs: A5E6
A7E0  A5 50    LDA $50                 
A7E2  C9 0A    CMP #$0A                
A7E4  D0 03    BNE loc_A7E9            
A7E6  4C A5 A8 JMP loc_A8A5            

loc_A7E9:  ; 1 xrefs: A7E4
A7E9  AD 80 06 LDA $0680               
A7EC  85 04    STA $04                 
A7EE  AD 81 06 LDA $0681               
A7F1  85 05    STA $05                 
A7F3  A5 50    LDA $50                 
A7F5  0A       ASL A                   
A7F6  A8       TAY                     
A7F7  B9 27 A9 LDA $A927,Y             
A7FA  85 00    STA $00                 
A7FC  B9 28 A9 LDA $A928,Y             
A7FF  85 01    STA $01                 
A801  20 40 C8 JSR $C840               
A804  A5 00    LDA $00                 
A806  20 49 C8 JSR $C849               
A809  A5 01    LDA $01                 
A80B  20 49 C8 JSR $C849               
A80E  AE 85 06 LDX $0685               
A811  F0 05    BEQ loc_A818            
A813  CA       DEX                     
A814  F0 15    BEQ loc_A82B            
A816  D0 58    BNE loc_A870            

loc_A818:  ; 3 xrefs: A811 A844 A888
A818  A0 00    LDY #$00                
A81A  B1 04    LDA ($04),Y             
A81C  10 40    BPL loc_A85E            
A81E  29 7F    AND #$7F                
A820  8D 84 06 STA $0684               
A823  20 05 A9 JSR sub_A905            
A826  A9 01    LDA #$01                
A828  8D 85 06 STA $0685               

loc_A82B:  ; 2 xrefs: A814 A83D
A82B  A0 00    LDY #$00                
A82D  B1 04    LDA ($04),Y             
A82F  20 49 C8 JSR $C849               
A832  20 05 A9 JSR sub_A905            
A835  20 F7 A8 JSR sub_A8F7            
A838  B0 0D    BCS loc_A847            
A83A  CE 84 06 DEC $0684               
A83D  D0 EC    BNE loc_A82B            
A83F  A9 00    LDA #$00                
A841  8D 85 06 STA $0685               
A844  4C 18 A8 JMP loc_A818            

loc_A847:  ; 1 xrefs: A838
A847  CE 84 06 DEC $0684               
A84A  D0 05    BNE loc_A851            
A84C  A9 00    LDA #$00                
A84E  8D 85 06 STA $0685               

loc_A851:  ; 1 xrefs: A84A
A851  A5 04    LDA $04                 
A853  8D 80 06 STA $0680               
A856  A5 05    LDA $05                 
A858  8D 81 06 STA $0681               
A85B  4C 46 C8 JMP $C846               

loc_A85E:  ; 1 xrefs: A81C
A85E  8D 84 06 STA $0684               
A861  20 05 A9 JSR sub_A905            
A864  A9 02    LDA #$02                
A866  8D 85 06 STA $0685               
A869  A0 00    LDY #$00                
A86B  B1 04    LDA ($04),Y             
A86D  8D 83 06 STA $0683               

loc_A870:  ; 2 xrefs: A816 A87E
A870  AD 83 06 LDA $0683               
A873  20 49 C8 JSR $C849               
A876  20 F7 A8 JSR sub_A8F7            
A879  B0 10    BCS loc_A88B            
A87B  CE 84 06 DEC $0684               
A87E  D0 F0    BNE loc_A870            
A880  20 05 A9 JSR sub_A905            
A883  A9 00    LDA #$00                
A885  8D 85 06 STA $0685               
A888  4C 18 A8 JMP loc_A818            

loc_A88B:  ; 1 xrefs: A879
A88B  CE 84 06 DEC $0684               
A88E  D0 08    BNE loc_A898            
A890  20 05 A9 JSR sub_A905            
A893  A9 00    LDA #$00                
A895  8D 85 06 STA $0685               

loc_A898:  ; 1 xrefs: A88E
A898  A5 04    LDA $04                 
A89A  8D 80 06 STA $0680               
A89D  A5 05    LDA $05                 
A89F  8D 81 06 STA $0681               
A8A2  4C 46 C8 JMP $C846               

loc_A8A5:  ; 1 xrefs: A7E6
A8A5  20 40 C8 JSR $C840               
A8A8  A9 C8    LDA #$C8                
A8AA  20 49 C8 JSR $C849               
A8AD  A9 23    LDA #$23                
A8AF  20 49 C8 JSR $C849               
A8B2  A5 06    LDA $06                 
A8B4  0A       ASL A                   
A8B5  A8       TAY                     
A8B6  B9 13 A9 LDA $A913,Y             
A8B9  85 04    STA $04                 
A8BB  B9 14 A9 LDA $A914,Y             
A8BE  85 05    STA $05                 
A8C0  A0 00    LDY #$00                
A8C2  84 03    STY $03                 

loc_A8C4:  ; 2 xrefs: A8DF A8F1
A8C4  A5 03    LDA $03                 
A8C6  C9 18    CMP #$18                
A8C8  F0 2A    BEQ loc_A8F4            
A8CA  B1 04    LDA ($04),Y             
A8CC  10 14    BPL loc_A8E2            
A8CE  29 7F    AND #$7F                
A8D0  85 02    STA $02                 

loc_A8D2:  ; 1 xrefs: A8DC
A8D2  C8       INY                     
A8D3  B1 04    LDA ($04),Y             
A8D5  20 49 C8 JSR $C849               
A8D8  E6 03    INC $03                 
A8DA  C6 02    DEC $02                 
A8DC  D0 F4    BNE loc_A8D2            
A8DE  C8       INY                     
A8DF  4C C4 A8 JMP loc_A8C4            

loc_A8E2:  ; 1 xrefs: A8CC
A8E2  85 02    STA $02                 
A8E4  C8       INY                     
A8E5  B1 04    LDA ($04),Y             

loc_A8E7:  ; 1 xrefs: A8EE
A8E7  20 49 C8 JSR $C849               
A8EA  E6 03    INC $03                 
A8EC  C6 02    DEC $02                 
A8EE  D0 F7    BNE loc_A8E7            
A8F0  C8       INY                     
A8F1  4C C4 A8 JMP loc_A8C4            

loc_A8F4:  ; 1 xrefs: A8C8
A8F4  4C 46 C8 JMP $C846               

sub_A8F7:  ; 2 xrefs: A835 A876
A8F7  EE 82 06 INC $0682               
A8FA  AD 82 06 LDA $0682               
A8FD  29 1F    AND #$1F                
A8FF  D0 02    BNE loc_A903            
A901  38       SEC                     
A902  60       RTS                     

loc_A903:  ; 1 xrefs: A8FF
A903  18       CLC                     
A904  60       RTS                     

sub_A905:  ; 5 xrefs: A823 A832 A861 A880 A890
A905  A5 04    LDA $04                 
A907  18       CLC                     
A908  69 01    ADC #$01                
A90A  85 04    STA $04                 
A90C  A5 05    LDA $05                 
A90E  69 00    ADC #$00                
A910  85 05    STA $05                 
A912  60       RTS                     

; ==== data $A913..$A94D  (59 bytes) ====
A913  CA A9 B4 AA 40 AB A5 AC A8 AD 47 AE DC AE CA A9  |....@.....G.....
A923  7E AF FB AF C0 20 E0 20 00 21 20 21 40 21 60 21  |~.... . .! !@!`!
A933  80 21 A0 21 C0 21 E0 21 4F A9 DF A9 B8 AA 50 AB  |.!.!.!.!O.....P.
A943  C7 AC C9 AD 4B AE 4F A9 F0 AE 86                 |....K.O....

loc_A94E:  ; 1 xrefs: A9CB
A94E  AF 0D 05 LAX $050D               
A951  86 06    STX $06                 
A953  07 08    SLO $08                 
A955  09 0A    ORA #$0A                
A957  0B 19    ANC #$19                
A959  05 88    ORA $88                 
A95B  0C 0D 0E NOP $0E0D               
A95E  0F 10 11 SLO $1110               

; ==== data $A961..$A961  (1 bytes) ====
A961  12                                               |.
A962  13 18    SLO ($18),Y             
A964  05 88    ORA $88                 
A966  14 15    NOP $15,X               
A968  16 17    ASL $17,X               
A96A  18       CLC                     
A96B  19 1A 1B ORA $1B1A,Y             
A96E  19 05 86 ORA $8605,Y             
A971  1C 1D 1E NOP $1E1D,X             
A974  1F 20 21 SLO $2120,X             
A977  1A       NOP                     
A978  05 86    ORA $86                 

; ==== data $A97A..$A9A8  (47 bytes) ====
A97A  22 23 24 25 26 27 1A 05 88 28 29 2A 2B 2C 2D 2E  |"#$%&'...()*+,-.
A98A  2F 15 05 88 30 31 32 00 34 35 36 37 02 00 82 39  |/...012.4567...9
A99A  13 13 05 81 38 04 00 84 3F 40 41 42 03 00 81     |....8...?@AB...

loc_A9A9:  ; 0 xrefs: 
A9A9  3B 12 05 RLA $0512,Y             
A9AC  81 3A    STA ($3A,X)             
A9AE  05 00    ORA $00                 
A9B0  84 43    STY $43                 
A9B2  44 45    NOP $45                 
A9B4  46 03    LSR $03                 
A9B6  00 81    BRK #$81                

; ==== data $A9B8..$A9C7  (16 bytes) ====
A9B8  3D 12 05 81 3C 05 00 84 47 48 49 4A 03 00 81 3E  |=...<...GHIJ...>

loc_A9C8:  ; 0 xrefs: 
A9C8  0A       ASL A                   
A9C9  05 03    ORA $03                 
A9CB  F0 81    BEQ loc_A94E            
A9CD  30 04    BMI loc_A9D3            
A9CF  F0 03    BEQ loc_A9D4            
A9D1  FF 81 33 ISC $3381,X             

loc_A9D4:  ; 1 xrefs: A9CF
A9D4  81 CC    STA ($CC,X)             
A9D6  05 FF    ORA $FF                 
A9D8  82 3F    NOP #$3F                
A9DA  5B 81 DE SRE $DE81,Y             
A9DD  03 FF    SLO ($FF,X)             
A9DF  05 03    ORA $03                 
A9E1  84 60    STY $60                 
A9E3  61 62    ADC ($62,X)             
A9E5  63 0B    RRA ($0B,X)             
A9E7  03 88    SLO ($88,X)             
A9E9  C3 C4    DCP ($C4,X)             
A9EB  C5 00    CMP $00                 
A9ED  A3 00    LAX ($00,X)             
A9EF  C6 C7    DEC $C7                 
A9F1  09 03    ORA #$03                
A9F3  85 70    STA $70                 
A9F5  71 72    ADC ($72),Y             
A9F7  73 74    RRA ($74),Y             

loc_A9F9:  ; 1 xrefs: AA06
A9F9  09 03    ORA #$03                
A9FB  83 D3    SAX ($D3,X)             
A9FD  D4 D5    NOP $D5,X               
A9FF  06 00    ASL $00                 
AA01  81 D6    STA ($D6,X)             
AA03  08       PHP                     
AA04  03 84    SLO ($84,X)             
AA06  F0 F1    BEQ loc_A9F9            

; ==== data $AA08..$ADC7  (960 bytes) ====
AA08  F2 F3 0A 03 83 C0 02 C1 06 00 81 C2 08 03 84 57  |...............W
AA18  58 59 5A 0A 03 83 D0 02 D1 06 00 81 D2 06 03 87  |XYZ.............
AA28  64 65 66 67 68 69 6A 09 03 84 E0 02 E1 E2 05 00  |defghij.........
AA38  81 D2 05 03 89 75 76 77 78 79 7A 7B 7C 7D 08 03  |.....uvwxyz{|}..
AA48  84 AD 02 AE AF 05 00 81 CF 05 03 89 F5 F6 F7 F8  |................
AA58  00 F9 FA FB FC 08 03 84 E3 02 E5 E6 05 00 81 E7  |................
AA68  05 03 84 6B 6C 6D 6E 04 00 81 6F 08 03 86 C8 02  |...klmn...o.....
AA78  C9 CA CB CC 02 CD 81 CE 06 03 84 5B 5C A6 A8 02  |...........[\...
AA88  A9 83 AA AB AC 09 03 85 D7 D8 D9 DA DB 02 DC 82  |................
AA98  DD DE 05 03 83 7E 7F 5D 04 00 82 5E 5F 09 03 82  |.....~.]...^_...
AAA8  E8 E9 03 EA 02 EB 85 EC ED EE EF DF 08 F0 10 FF  |................
AAB8  11 05 84 50 51 52 53 03 00 82 54 55 16 05 81 56  |...PQRS...TU...V
AAC8  03 04 81 57 04 00 81 58 16 05 85 59 5A 04 5B 5C  |...W...X...YZ.[\
AAD8  05 00 16 05 88 5D 5E 5F 60 61 62 63 64 02 00 16  |.....]^_`abcd...
AAE8  05 88 65 66 67 68 69 6A 6B 6C 02 00 16 05 8A 6D  |..efghijkl.....m
AAF8  6E 6F 70 71 72 73 74 00 75 16 05 87 76 77 78 79  |nopqrst.u...vwxy
AB08  7A 03 7B 02 00 81 7C 16 05 8B 7D 7E 7F E0 03 E1  |z.{...|...}~....
AB18  E2 E3 E4 E5 E6 15 05 8E E7 E8 E9 EA EB EC ED EE  |................
AB28  EF F0 F1 F2 F3 F4 13 05 89 F5 F6 F7 F8 F9 FA FB  |................
AB38  FC DA 03 04 83 DB DC 05 08 F0 04 FF 81 33 81 FF  |.............3..
AB48  81 FC 05 FF 81 F3 03 FF 06 4A 82 5F 01 02 4A 86  |.........J._..J.
AB58  62 05 06 07 08 09 02 4A 82 0C 0D 06 62 02 4A 02  |b......J....b.J.
AB68  62 08 4A 82 10 11 02 4A 86 62 05 06 07 18 19 02  |b.J....J.b......
AB78  4A 82 1C 1D 03 62 83 2B 2C 2D 02 4A 82 30 31 02  |J....b.+,-.J.01.
AB88  4A 06 4B 82 20 21 02 4B 81 02 02 03 83 04 0A 0B  |J.K. !.K........
AB98  02 4B 88 1C 1D 0E 0F 3E 3B 3C 3D 02 4B 82 40 41  |.K.....>;<=.K.@A
ABA8  02 4B 06 4C 82 20 21 02 4C 81 12 02 13 83 14 1A  |.K.L. !.L.......
ABB8  1B 02 4C 83 1C 15 16 02 17 83 2F 3C 3D 02 4C 82  |..L......./<=.L.
ABC8  50 51 02 4C 02 4D 82 40 41 02 4D 82 20 21 02 4D  |PQ.L.M.@A.M. !.M
ABD8  81 12 02 13 88 14 1A 22 23 24 1C 15 16 02 17 83  |......."#$......
ABE8  2F 3C 3D 02 4D 82 50 51 02 4D 02 4E 82 50 51 02  |/<=.M.PQ.M.N.PQ.
ABF8  4E 82 20 21 02 4E 81 12 02 13 88 1E 1F 32 33 34  |N. !.N.......234
AC08  1C 15 16 02 17 83 2F 3C 3D 02 4E 82 50 51 02 4E  |....../<=.N.PQ.N
AC18  02 4F 82 50 51 02 4F 82 20 21 02 4F 8B 12 13 25  |.O.PQ.O. !.O...%
AC28  26 1F 32 33 34 1C 15 16 02 17 83 2F 3C 3D 02 4F  |&.234....../<=.O
AC38  82 50 51 02 4F 02 3F 82 50 51 02 3F 82 20 21 02  |.PQ.O.?.PQ.?. !.
AC48  3F 8B 12 13 35 36 1F 32 33 5B 5C 5D 5E 02 17 83  |?...56.23[\]^...
AC58  25 26 3D 02 3F 82 50 51 02 3F 95 44 45 46 47 48  |%&=.?.PQ.?.DEFGH
AC68  49 20 27 28 29 2A 13 35 36 1F 32 33 6B 6C 6D 6E  |I '()*.56.23klmn
AC78  02 17 9E 35 36 3D 44 45 46 47 48 49 54 55 56 57  |...56=DEFGHITUVW
AC88  58 59 20 37 38 39 3A 63 35 36 64 65 66 7B 7C 7D  |XY 789:c56def{|}
AC98  7E 02 17 89 35 36 3D 54 55 56 57 58 59 81 50 02  |~...56=TUVWXY.P.
ACA8  D0 81 F0 82 D0 F0 02 70 82 25 ED 81 21 81 00 82  |.......p.%..!...
ACB8  01 0C 83 87 B7 E2 81 22 81 02 03 00 82 88 BB 03  |......."........
ACC8  48 81 49 08 00 88 45 F5 F6 F7 F8 F9 06 07 08 00  |H.I...E.........
ACD8  81 68 07 48 81 49 07 00 88 10 11 12 13 14 15 16  |.h.H.I..........
ACE8  17 07 00 81 68 08 48 82 4A 4C 06 00 83 20 21 22  |....h.H.JL... !"
ACF8  02 04 83 25 26 27 06 00 82 66 65 04 48 84 58 59  |...%&'...fe.H.XY
AD08  48 4A 02 04 81 4C 05 00 88 30 31 32 33 34 35 36  |HJ...L...0123456
AD18  37 05 00 81 66 02 04 84 65 48 73 74 02 00 82 5A  |7...f...eHst...Z
AD28  5B 03 04 81 4C 04 00 88 40 41 42 43 44 00 46 47  |[...L...@ABCD.FG
AD38  04 00 81 66 03 04 82 71 72 06 00 85 5C 5B 04 4D  |...f...qr...\[.M
AD48  4F 03 00 88 50 51 52 53 54 55 56 57 03 00 85 63  |O...PQRSTUVW...c
AD58  64 04 71 67 0A 00 84 5D 5E 5F 4F 02 00 88 05 08  |d.qg...]^_O.....
AD68  09 0A 0B 0C 0D 05 02 00 84 63 5F 6E 70 0E 00 90  |.........c_np...
AD78  6F 4E 60 00 05 18 19 1A 1B 1C 1D 05 00 6B 6C 6D  |oN`..........klm
AD88  12 00 8C 61 62 28 29 2A 2B 2C 2D 2E 2F 23 24 14  |...ab()*+,-./#$.
AD98  00 8C 7C 7D 38 39 3A 3B 3C 3D 3E 3F 69 6A 0A 00  |..|}89:;<=>?ij..
ADA8  81 A0 81 60 04 50 81 90 81 A0 82 9A AA 81 65 02  |...`.P........e.
ADB8  55 82 95 AA 81 6A 83 55 59 DA 02 55 81 7A 82 56  |U....j.UY..U.z.V

loc_ADC8:  ; 0 xrefs: 
ADC8  55 06    EOR $06,X               
ADCA  78       SEI                     

; ==== data $ADCB..$AF99  (463 bytes) ====
ADCB  02 7A 02 00 81 7E 0A FA 81 7E 02 00 02 76 06 78  |.z...~...~...v.x
ADDB  09 7F 03 7B 02 00 02 75 0A 02 02 FC 81 00 03 FB  |...{...u........
ADEB  02 01 03 00 81 77 0B 79 81 77 02 00 0C 01 04 02  |.....w.y.w......
ADFB  02 75 02 00 14 77 02 00 02 FC 02 FB 02 00 0A 77  |.u...w.........w
AE0B  02 00 02 7B 0C 7F 02 FB 02 79 81 77 02 00 81 01  |...{.....y.w....
AE1B  0D 4B 82 01 00 05 77 82 00 77 04 79 0A FA 81 7E  |.K....w..w.y...~
AE2B  02 00 02 7A 0A 78 02 76 81 00 02 7E 02 FA 04 00  |...z.x.v...~....
AE3B  02 75 07 02 02 FC 81 00 0A 77 46 00 08 50 10 55  |.u.......wF..P.U
AE4B  06 03 83 10 11 12 05 00 81 13 16 03 8B 20 21 22  |............. !"
AE5B  23 24 25 26 27 28 00 29 15 03 83 30 31 32 02 33  |#$%&'(.)...012.3
AE6B  86 34 35 36 37 38 39 14 03 81 50 05 00 82 51 52  |.456789...P...QR
AE7B  02 02 82 53 54 13 03 82 14 15 02 16 89 17 00 18  |...ST...........
AE8B  19 1A 1B 1C 1D 1E 12 03 8E 40 41 42 43 44 45 46  |.........@ABCDEF
AE9B  47 48 49 4A 4B 4C 4D 12 03 81 2A 05 00 87 2B 2C  |GHIJKLM...*...+,
AEAB  2D 02 2E 2F 1F 13 03 81 3A 05 00 86 3B 3C 3D 02  |-../....:...;<=.
AEBB  3E 3F 14 03 81 55 04 00 87 56 4E 4F 04 05 06 07  |>?...U...VNO....
AECB  14 03 81 08 03 00 88 09 0A 0B 0C 00 0D 0E 0F 12  |................
AEDB  03 83 F0 50 A0 05 F0 83 7F 55 2A 81 C4 05 FF 81  |...P.....U*.....
AEEB  5D 81 F0 05 FF 10 05 8A 80 81 82 83 84 85 86 03  |]...............
AEFB  87 88 16 05 8A 90 91 04 93 94 95 96 03 97 98 16  |................
AF0B  05 8A A0 A1 04 A3 A4 A5 A6 03 A7 A8 16 05 8A B0  |................
AF1B  B1 B2 B3 B4 B5 B6 03 B7 B8 16 05 82 C0 C1 02 00  |................
AF2B  86 C4 C5 C6 C7 C8 C9 16 05 8A D0 D1 D2 D3 D4 D5  |................
AF3B  D6 D7 D8 D9 16 05 8A CD CE CF 03 DA DB DC DD DE  |................
AF4B  DF 16 05 83 8F 9F AF 02 03 86 BF C2 C3 CA CB CC  |................
AF5B  15 05 8E 89 8A 8B 8C 8D 8E A9 AA AB AC AD AE 92  |................
AF6B  A2 13 05 8F 9A 9B 9C 00 9E B9 BA BB BC BD BE 04  |................
AF7B  99 9D 05 08 50 0D 55 81 45 02 55 0C 05 88 45 F5  |....P.U.E.U...E.
AF8B  F6 F7 F8 F9 06 07 18 05 88 10 11 12 13 14 15     |...............

loc_AF9A:  ; 1 xrefs: B00B
AF9A  16 17    ASL $17,X               
AF9C  18       CLC                     
AF9D  05 83    ORA $83                 
AF9F  20 21 22 JSR $2221               

; ==== data $AFA2..$AFA2  (1 bytes) ====
AFA2  02                                               |.

loc_AFA3:  ; 1 xrefs: B00D
AFA3  04 83    NOP $83                 
AFA5  25 26    AND $26                 
AFA7  27 18    RLA $18                 
AFA9  05 88    ORA $88                 
AFAB  30 31    BMI loc_AFDE            

; ==== data $AFAD..$AFB4  (8 bytes) ====
AFAD  32 33 34 35 36 37 18 05                          |234567..

loc_AFB5:  ; 1 xrefs: B01F
AFB5  88       DEY                     
AFB6  40       RTI                     

; ==== data $AFB7..$AFBA  (4 bytes) ====
AFB7  41 42 43 44                                      |ABCD

loc_AFBB:  ; 1 xrefs: B00F
AFBB  00 46    BRK #$46                

; ==== data $AFBD..$AFC4  (8 bytes) ====
AFBD  47 18 05 88 50 51 52 53                          |G...PQRS

loc_AFC5:  ; 1 xrefs: B01D
AFC5  54 55    NOP $55,X               
AFC7  56 57    LSR $57,X               
AFC9  14 05    NOP $05,X               
AFCB  81 5F    STA ($5F,X)             

loc_AFCD:  ; 1 xrefs: B021
AFCD  04 05    NOP $05                 

loc_AFCF:  ; 1 xrefs: B039
AFCF  86 08    STX $08                 
AFD1  09 0A    ORA #$0A                
AFD3  0B 0C    ANC #$0C                
AFD5  0D 1A 05 ORA $051A               
AFD8  86 18    STX $18                 
AFDA  19 1A 1B ORA $1B1A,Y             
AFDD  1C 1D 19 NOP $191D,X             
AFE0  05 88    ORA $88                 

loc_AFE2:  ; 1 xrefs: B02B
AFE2  28       PLP                     
AFE3  29 2A    AND #$2A                
AFE5  2B 2C    ANC #$2C                

loc_AFE7:  ; 1 xrefs: B03B
AFE7  2D 2E 2F AND $2F2E               
AFEA  16 05    ASL $05,X               
AFEC  8C 0E 0F STY $0F0E               

loc_AFEF:  ; 1 xrefs: B007
AFEF  38       SEC                     
AFF0  39 3A 3B AND $3B3A,Y             
AFF3  3C 3D 3E NOP $3E3D,X             
AFF6  3F 1E 1F RLA $1F1E,X             
AFF9  0A       ASL A                   
AFFA  05 08    ORA $08                 
AFFC  50 10    BVC loc_B00E            
AFFE  55 A5    EOR $A5,X               
B000  19 20 4F ORA $4F20,Y             
B003  C8       INY                     
B004  5C B0 81 NOP $81B0,X             
B007  B0 E6    BCS loc_AFEF            

loc_B009:  ; 1 xrefs: B037
B009  A5 88    LDA $88                 
B00B  B0 8D    BCS loc_AF9A            
B00D  B0 94    BCS loc_AFA3            
B00F  B0 AA    BCS loc_AFBB            
B011  A5 B5    LDA $B5                 
B013  A5 0B    LDA $0B                 
B015  A6 32    LDX $32                 
B017  A6 9A    LDX $9A                 
B019  B0 E6    BCS loc_B001            

loc_B01B:  ; 1 xrefs: B033
B01B  A5 A1    LDA $A1                 
B01D  B0 A6    BCS loc_AFC5            
B01F  B0 94    BCS loc_AFB5            
B021  B0 AA    BCS loc_AFCD            
B023  A5 0B    LDA $0B                 
B025  A6 B0    LDX $B0                 

loc_B027:  ; 1 xrefs: B041
B027  B0 7E    BCS loc_B0A7            
B029  B0 7E    BCS loc_B0A9            
B02B  B0 B5    BCS loc_AFE2            
B02D  A5 0B    LDA $0B                 
B02F  A6 32    LDX $32                 
B031  A6 C4    LDX $C4                 
B033  B0 E6    BCS loc_B01B            
B035  A5 CB    LDA $CB                 
B037  B0 D0    BCS loc_B009            
B039  B0 94    BCS loc_AFCF            
B03B  B0 AA    BCS loc_AFE7            
B03D  A5 B5    LDA $B5                 
B03F  A5 D7    LDA $D7                 
B041  B0 E4    BCS loc_B027            
B043  B0 17    BCS loc_B05C            
B045  B1 E6    LDA ($E6),Y             
B047  A5 1E    LDA $1E                 
B049  B1 23    LDA ($23),Y             
B04B  B1 99    LDA ($99),Y             
B04D  A5 AA    LDA $AA                 
B04F  A5 0B    LDA $0B                 
B051  A6 2A    LDX $2A                 
B053  B1 33    LDA ($33),Y             
B055  B1 AA    LDA ($AA),Y             
B057  A5 B5    LDA $B5                 
B059  A5 3E    LDA $3E                 
B05B  B1 20    LDA ($20),Y             
B05D  D9 80 B0 CMP $B080,Y             
B060  01 60    ORA ($60,X)             

loc_B062:  ; 1 xrefs: B05F
B062  20 13 C8 JSR $C813               
B065  20 C1 C8 JSR $C8C1               
B068  A0 0E    LDY #$0E                
B06A  84 42    STY $42                 
B06C  C8       INY                     
B06D  84 43    STY $43                 
B06F  A9 02    LDA #$02                
B071  85 87    STA $87                 
B073  A9 00    LDA #$00                
B075  85 51    STA $51                 
B077  85 50    STA $50                 
B079  85 4F    STA $4F                 
B07B  20 3E A7 JSR sub_A73E            
B07E  4C 9A C8 JMP $C89A               

; ==== data $B081..$B0A6  (38 bytes) ====
B081  A9 08 A2 1A 4C E0 A5 A9 27 4C FB A5 A9 0E A0 80  |....L...'L......
B091  4C 8E A5 20 4A B1 4C 99 A5 A9 06 A2 1C 4C E0 A5  |L.. J.L......L..
B0A1  A9 25 4C FB A5 A9                                |.%L...

loc_B0A7:  ; 1 xrefs: B027
B0A7  0F 18 65 SLO $6518               
B0AA  4F A0 80 SRE $80A0               
B0AD  4C 8E A5 JMP loc_A58E            

; ==== data $B0B0..$B149  (154 bytes) ====
B0B0  E6 4F A5 4F C9 05 F0 05 A9 0D 85 19 60 A9 00 85  |.O.O........`...
B0C0  4F 4C 9A C8 A9 09 A2 1A 4C E0 A5 A9 27 4C FB A5  |OL......L...'L..
B0D0  A9 14 A0 80 4C 8E A5 A9 04 85 18 A9 00 85 19 A9  |....L...........
B0E0  0C 85 1A 60 20 D9 80 B0 01 60 20 3D C8 A9 47 20  |...` ....` =..G 
B0F0  1C C8 20 13 C8 20 C1 C8 A0 0E 84 42 A0 19 84 43  |.. .. .....B...C
B100  A2 1C 20 4C C8 A9 02 85 87 A9 00 85 51 85 50 85  |.. L........Q.P.
B110  4F 20 3E A7 4C 9A C8 A9 00 A2 18 4C E0 A5 A9 21  |O >.L......L...!
B120  4C FB A5 A9 15 A0 C0 4C 8E A5 A5 FF 49 01 85 FF  |L......L....I...
B130  4C AA A5 A9 A9 85 FF A9 50 85 51 4C 9A C8 20 3D  |L.......P.QL.. =
B140  C8 A9 04 85 18 A9 06 85 1A 60                    |.........`

loc_B14A:  ; 0 xrefs: 
B14A  A5 4A    LDA $4A                 
B14C  29 10    AND #$10                
B14E  D0 01    BNE loc_B151            
B150  60       RTS                     

loc_B151:  ; 1 xrefs: B14E
B151  A9 1C    LDA #$1C                
B153  85 19    STA $19                 
B155  A9 00    LDA #$00                
B157  85 90    STA $90                 
B159  85 51    STA $51                 
B15B  85 50    STA $50                 
B15D  85 4F    STA $4F                 
B15F  8D 6C 01 STA $016C               
B162  60       RTS                     

; ==== data $B163..$B187  (37 bytes) ====
B163  00 95 A5 A5 A5 A5 A5 A5 65 99 AA AA AA AA AA AA  |........e.......
B173  66 99 AA AA AA AA AA AA 66 99 AA AA AA AA AA AA  |f.......f.......
B183  66 19 0A 0A 0A                                   |f....

loc_B188:  ; 0 xrefs: 
B188  0A       ASL A                   
B189  0A       ASL A                   
B18A  0A       ASL A                   
B18B  46 B5    LSR $B5                 
B18D  A5 A5    LDA $A5                 
B18F  A5 E5    LDA $E5                 

; ==== data $B191..$B44B  (699 bytes) ====
B191  BB AA EE BB EE BB EE FB FA FA FE 19 0A 0A 0A 0A  |................
B1A1  0A 0A 46 1D 0F 0F 47 19 0A AA 0A 46 99 AA AA AA  |..F...G....F....
B1B1  66 95 B5 E5 65 99 BB EE 66 99 BB EE 66 99 BB EE  |f...e...f...f...
B1C1  66 DD FF FF FF 77 CA FA FA 3A CC FF FF FF 33 CC  |f....w...:....3.
B1D1  FF FF FF FF 33 CC FF FF 33 8C AF AF AF 23 44 55  |....3...3....#DU
B1E1  11 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
B1F1  00 6C 6D 60 5A 64 65 63 5B 6C 6D 00 00 64 65 15  |.lm`Zdec[lm..de.
B201  16 63 63 5E 60 5C 5D 5F 63 00 00 00 00 1B 19 19  |.cc^`\]_c.......
B211  19 60 61 62 60 63 63 63 63 00 00 00 00 1B 19 19  |.`ab`cccc.......
B221  19 60 61 62 60 63 63 63 63 00 00 00 00 1B 19 07  |.`ab`cccc.......
B231  08 60 61 62 60 63 63 63 63 00 00 00 00 05 06 19  |.`ab`cccc.......
B241  1B 60 61 62 60 63 63 63 63 00 00 00 00 19 19 19  |.`ab`cccc.......
B251  1B 60 5A 63 63 63 5B 5C 5D 00 00 00 00 19 19 19  |.`Zccc[\].......
B261  1B 5E 60 76 77 5F 63 6E 6F 00 00 76 77 15 00 6E  |.^`vw_cno..vw..n
B271  6F 6C 6D 15 16 64 65 15 16 6C 6D 17 18 66 67 1B  |olm..de..lm..fg.
B281  19 1C 1A 1A 1A 3F 3E 0D 0E 3F 3E 11 12 07 08 00  |.....?>..?>.....
B291  00 1C 1A 1A 1A 0F 10 3E 3F 13 14 3E 3F 00 00 00  |.......>?..>?...
B2A1  00 1C 1A 0B 0C 3F 3E 15 16 3F 3E 15 16 00 00 17  |.....?>..?>.....
B2B1  18 09 0A 1A 1C 15 16 3E 3F 15 16 3E 3F 17 18 00  |.......>?..>?...
B2C1  00 1A 1A 1A 1C 3F 3E 0D 0E 3F 3E 11 12 00 00 00  |.....?>..?>.....
B2D1  00 1A 1A 1A 1C 0F 10 3E 3F 13 14 3E 3F 00 00 05  |.......>?..>?...
B2E1  06 15 00 76 77 15 00 6E 6F 17 00 76 77 19 00 70  |...vw..no..vw..p
B2F1  71 65 68 1C 1A 65 69 00 00 6A 6B 36 37 6C 6D 38  |qeh..ei..jk67lm8
B301  39 0B 0C 28 01 15 16 28 01 17 18 28 01 15 16 25  |9..(...(...(...%
B311  26 01 29 00 00 01 29 36 37 01 29 38 39 26 27 3A  |&.)...)67.)89&':
B321  3B 02 02 15 16 02 02 15 16 02 02 15 16 3E 3F 17  |;............>?.
B331  18 15 16 02 02 15 16 02 02 15 16 03 2A 17 18 00  |............*...
B341  2E 00 00 28 01 36 37 28 01 2B 2C 2D 01 2F 30 31  |...(.67(.+,-./01
B351  26 01 29 09 0A 01 29 15 16 01 29 17 18 26 27 15  |&.)...)...)..&'.
B361  16 1A 00 72 6E 00 00 73 6E 36 00 74 75 38 00 76  |...rn..sn6.tu8.v
B371  77 64 65 3A 3B 6C 6D 3C 3D 64 65 38 39 66 67 36  |wde:;lm<=de89fg6
B381  37 15 16 28 01 15 16 28 01 15 16 28 01 17 18 28  |7..(...(...(...(
B391  01 01 29 3C 3D 01 29 38 39 01 29 36 37 01 29 36  |..)<=.)89.)67.)6
B3A1  37 3E 3F 15 16 02 02 15 16 02 02 15 16 02 02 17  |7>?.............
B3B1  18 15 16 00 2E 15 16 00 32 04 2A 2B 2C 00 2E 2F  |........2.*+,../
B3C1  30 2F 30 31 01 33 34 35 01 2D 2A 2B 2C 31 2E 2F  |0/01.345.-*+,1./
B3D1  30 01 29 15 16 01 29 15 16 2D 29 15 16 31 29 17  |0.)...)..-)..1).
B3E1  18 3A 00 6E 6F 3C 00 76 77 38 00 6E 6F 36 00 70  |.:.no<.vw8.no6.p
B3F1  71 65 68 3F 1D 65 69 3F 21 6A 6B 79 7B 6C 6D 7D  |qeh?.ei?!jky{lm}
B401  7F 1E 1F 20 3F 22 23 24 3F 78 79 7A 79 7C 7D 7E  |... ?"#$?xyzy|}~
B411  7D 3E 3F 3F 3E 3E 3F 3F 3E 79 7A 79 7B 7D 7E 7D  |}>??>>??>yzy{}~}
B421  7F 3F 3F 3E 3F 3F 3F 3E 3F 78 79 7A 79 7C 7D 7E  |.??>???>?xyzy|}~
B431  7D 00 2E 2F 30 00 32 33 34 79 7A 79 7B 7D 7E 7D  |}../0.234yzy{}~}
B441  7F 31 2E 2F 30 35 32 33 34 78 79                 |.1./05234xy

loc_B44C:  ; 0 xrefs: 
B44C  7A       NOP                     
B44D  79 7C 7D ADC $7D7C,Y             
B450  7E 7D 31 ROR $317D,X             
B453  1D 1E 1F ORA $1F1E,X             
B456  35 21    AND $21,X               

; ==== data $B458..$BB3F  (1768 bytes) ====
B458  22 23 79 7A 79 7B 7D 7E 7D 7F 20 00 72 6E 24 00  |"#yzy{}~}. .rn$.
B468  73 6E 78 79 74 75 7C 7D 76 77 61 62 60 5A 63 63  |snxytu|}vwab`Zcc
B478  63 5B 6C 6D 93 94 64 65 95 96 63 63 5E 60 5C 5D  |c[lm..de..cc^`\]
B488  5F 63 93 94 93 94 95 96 95 96 60 61 62 60 63 63  |_c........`ab`cc
B498  63 63 93 94 93 94 95 96 95 96 60 5A 63 63 63 5B  |cc........`Zccc[
B4A8  5C 5D 93 94 93 94 95 96 95 96 5E 60 61 62 5F 63  |\]........^`ab_c
B4B8  63 63 93 94 76 77 95 96 6E 6F 6C 6D 97 98 64 65  |cc..vw..nolm..de
B4C8  95 96 6C 6D 97 98 66 67 95 96 97 98 97 98 95 96  |..lm..fg........
B4D8  95 96 97 98 97 98 95 96 95 96 97 98 76 77 95 96  |............vw..
B4E8  6E 6F 97 98 76 77 95 96 70 71 65 68 97 98 65 69  |no..vw..pqeh..ei
B4F8  95 96 6A 6B 97 98 6C 6D 95 96 97 98 72 6E 95 96  |..jk..lm....rn..
B508  73 6E 97 98 74 75 95 96 76 77 64 65 97 98 6C 6D  |sn..tu..vwde..lm
B518  95 96 64 65 97 98 66 67 95 96 97 98 6E 6F 95 96  |..de..fg....no..
B528  76 77 97 98 6E 6F 95 96 70 71 65 68 97 98 65 69  |vw..no..pqeh..ei
B538  95 96 6A 6B 79 7B 6C 6D 7D 7F 97 98 97 98 95 96  |..jky{lm}.......
B548  95 96 78 79 7A 79 7C 7D 7E 7D 97 98 97 98 95 96  |..xyzy|}~}......
B558  95 96 79 7A 79 7B 7D 7E 7D 7F 97 98 72 6E 95 96  |..yzy{}~}...rn..
B568  73 6E 78 79 74 75 7C 7D 76 77 65 68 3F 1D 65 69  |snxytu|}vweh?.ei
B578  3F 21 6A 6B A9 AA 6C 6D C1 C5 1E 1F 20 3F 22 23  |?!jk..lm.... ?"#
B588  24 3F AB AF AA AB C7 C6 C6 C7 3E 3F 3F 3E 3E 3F  |$?........>??>>?
B598  3F 3E AF AA AB AF C6 C6 C7 C6 3F 3F 3E 3F 3F 3F  |?>........??>???
B5A8  3E 3F AA AB AF AD C2 C3 C5 C4 00 2E 2F 30 00 32  |>?........../0.2
B5B8  33 34 A2 A3 A4 A8 C1 C5 C7 C6 31 2E 2F 30 35 32  |34........1./052
B5C8  33 34 A3 A4 A8 A3 C6 C7 C6 C6 31 1D 1E 1F 35 21  |34........1...5!
B5D8  22 23 A4 A8 A3 A4 C7 C6 C2 C3 20 00 72 6E 24 00  |"#........ .rn$.
B5E8  73 6E A8 A6 74 75 C5 C4 76 77 65 68 BE BF 65 69  |sn..tu..vweh..ei
B5F8  C0 C1 6A 6B 79 7B 6C 6D 7D 7F BE BF BE BF C0 C1  |..jky{lm}.......
B608  C0 C1 78 79 7A 79 7C 7D 7E 7D BE BF BE BF C0 C1  |..xyzy|}~}......
B618  C0 C1 79 7A 79 7B 7D 7E 7D 7F BE BF 72 6E C0 C1  |..yzy{}~}...rn..
B628  73 6E 78 79 74 75 7C 7D 76 77 65 68 1C 1A 65 69  |snxytu|}vweh..ei
B638  00 00 6A 6B 78 7A 6C 6D 7C 7E 0B 0C 28 01 15 16  |..jkxzlm|~..(...
B648  28 01 79 79 7A 7B 7D 7D 7E 7F 00 00 28 01 36 37  |(.yyz{}}~...(.67
B658  28 01 2B 2C 2D 41 2F 30 31 00 01 29 09 0A 01 29  |(.+,-A/01..)...)
B668  15 16 78 7A 79 79 7C 7E 7D 7D 1A 00 72 6E 00 00  |..xzyy|~}}..rn..
B678  73 6E 7A 7B 74 75 7E 7F 76 77 64 65 00 00 6C 6D  |snz{tu~.vwde..lm
B688  3C 3D 64 65 38 39 66 67 36 37 00 00 00 40 15 16  |<=de89fg67...@..
B698  28 01 15 16 28 01 17 18 28 01 2F 30 31 00 33 34  |(...(...(./01.34
B6A8  35 01 2D 2A 2B 2C 31 2E 2F 30 00 00 00 00 01 29  |5.-*+,1./0.....)
B6B8  15 16 2D 29 15 16 31 29 17 18 00 00 6E 6F 3C 00  |..-)..1)....no<.
B6C8  76 77 38 00 6E 6F 36 00 70 71 54 56 60 5A 54 56  |vw8.no6.pqTV`ZTV
B6D8  63 5B 54 56 00 00 54 56 15 16 63 63 5E 60 5C 5D  |c[TV..TV..cc^`\]
B6E8  5F 63 A0 A1 00 00 A2 A3 19 19 60 5A 63 63 63 5B  |_c........`Zccc[
B6F8  5C 5D 00 00 A0 A1 19 19 A2 A3 5E 60 57 54 5F 63  |\]........^`WT_c
B708  57 54 00 00 57 54 15 00 57 54 54 56 15 16 59 55  |WT..WT..WTTV..YU
B718  15 16 54 56 17 18 54 56 1B 19 A0 A1 1A 1A A2 A3  |..TV..TV........
B728  0D 0E A0 A1 11 12 A2 A3 00 00 1A 1A A0 A1 0F 10  |................
B738  A2 A3 13 14 A0 A1 00 00 A2 A3 15 00 57 54 15 00  |............WT..
B748  58 59 17 00 57 54 19 00 57 54 54 56 1C 1A 54 56  |XY..WT..WTTV..TV
B758  00 00 54 56 36 37 54 56 38 39 A0 A1 28 01 A2 A3  |..TV67TV89..(...
B768  28 01 A0 A1 28 01 A2 A3 25 26 01 29 A0 A1 01 29  |(...(...%&.)...)
B778  A2 A3 01 29 A0 A1 26 27 A2 A3 1A 00 57 54 00 00  |...)..&'....WT..
B788  57 54 36 00 57 54 38 00 57 54 54 56 3A 3B 54 56  |WT6.WT8.WTTV:;TV
B798  3C 3D 54 56 38 39 54 56 36 37 A0 A1 28 01 A2 A3  |<=TV89TV67..(...
B7A8  28 01 A0 A1 28 01 A2 A3 28 01 01 29 A0 A1 01 29  |(...(...(..)...)
B7B8  A2 A3 2D 29 A0 A1 31 29 A2 A3 3A 00 57 54 3C 00  |..-)..1)..:.WT<.
B7C8  57 54 38 00 57 54 36 00 57 54 54 56 A8 A8 54 56  |WT8.WT6.WTTV..TV
B7D8  A8 A8 59 55 79 7B 54 56 7D 7F A8 A8 A8 A8 A8 A8  |..YUy{TV}.......
B7E8  A8 A8 78 79 7A 79 7C 7D 7E 7D A8 A8 A8 A8 A8 A8  |..xyzy|}~}......
B7F8  A8 A8 79 7A 79 7B 7D 7E 7D 7F A8 A8 A8 A8 A8 A8  |..yzy{}~}.......
B808  A8 A8 A8 A8 A8 A8 A8 A8 A8 A8 A8 A8 57 54 A8 A8  |............WT..
B818  57 54 78 79 58 59 7C 7D 57 54 5A 5B 5C 5D 5E 5F  |WTxyXY|}WTZ[\]^_
B828  60 61 6C 6D 00 00 6E 6F 16 17 5A 5B 5C 5D 5E 5F  |`alm..no..Z[\]^_
B838  60 61 2C 2D 2E 2F 3C 3D 3E 3F 5A 5B 5C 5D 5E 5F  |`a,-./<=>?Z[\]^_
B848  60 61 00 00 00 00 14 15 16 17 5A 5B 5C 5D 5E 5F  |`a........Z[\]^_
B858  60 61 00 00 76 77 14 15 78 79 6D 70 26 27 6D 71  |`a..vw..xymp&'mq
B868  36 37 72 73 00 00 74 75 44 00 0C 0D 0E 0F 1C 1D  |67rs..tuD.......
B878  1E 1F 2C 2D 2E 2F 3C 3D 3E 3F 24 25 26 27 00 35  |..,-./<=>?$%&'.5
B888  36 37 00 00 00 00 46 47 44 45 24 25 26 27 00 35  |67....FGDE$%&'.5
B898  36 37 00 00 00 00 46 47 44 00 24 25 7A 7E 00 35  |67....FGD.$%z~.5
B8A8  7B 7E 00 00 7C 7D 46 00 7E 7F 6C 6D 48 00 74 75  |{~..|}F.~.lmH.tu
B8B8  4C 00 6C 6D 40 00 74 75 44 00 0C 0D 0E 0F 1C 1D  |L.lm@.tuD.......
B8C8  1E 53 2C 2D 2E 54 3C 3D 3E 55 0A 0B 48 49 1A 1B  |.S,-.T<=>U..HI..
B8D8  4C 4D 2A 2B 40 41 3A 3B 44 45 4A 4B 08 09 4E 4F  |LM*+@A:;DEJK..NO
B8E8  18 19 42 43 28 29 46 47 38 39 4A 4B 08 00 4E 4F  |..BC()FG89JK..NO
B8F8  18 00 42 43 28 00 46 47 38 00 4A 00 76 77 4E 00  |..BC(.FG8.J.vwN.
B908  7E 7F 42 00 76 77 46 00 7E 7F 6C 6D 48 00 6E 6F  |~.B.vwF.~.lmH.no
B918  4C 00 6D 70 02 50 6D 71 12 51 4A 4B 48 49 4E 4F  |L.mp.Pmq.QJKHINO
B928  4C 4D 42 01 02 03 10 11 12 13 4A 4B 48 00 4E 4F  |LMB.......JKH.NO
B938  4C 00 42 01 02 50 10 11 12 51 4A 00 76 77 4E 00  |L.B..P...QJ.vwN.
B948  78 79 42 34 7A 7E 10 11 7B 7E 72 73 22 52 74 75  |xyB4z~..{~rs"Rtu
B958  32 33 6C 6D 64 65 74 75 58 59 0C 0D 0E 0F 1C 1D  |23lmdetuXY......
B968  1E 1F 62 63 64 65 56 57 58 59 20 21 22 23 30 31  |..bcdeVWXY !"#01
B978  32 33 62 63 64 65 56 57 58 59 20 21 22 52 30 31  |23bcdeVWXY !"R01
B988  32 33 62 63 64 65 56 57 58 59 20 21 7C 7D 30 31  |23bcdeVWXY !|}01
B998  7E 7F 62 63 76 77 56 57 7E 7F 72 73 9B 9C 74 75  |~.bcvwVW~.rs..tu
B9A8  9D 9E 6C 6D 9E A0 74 75 9D 9E 9B 9C 9B 9C 9D 9E  |..lm..tu........
B9B8  9D 9E 9E A0 9E A0 9D 9E 9D 9E 9B 9C 7C 7D 9D 9E  |............|}..
B9C8  7E 7F 9E A0 76 77 9D 9E 7E 7F E2 B9 0A BA 32 BA  |~...vw..~.....2.
B9D8  5A BA 82 BA AA BA D2 BA FA BA 01 02 03 04 05 06  |Z...............
B9E8  07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16  |................
B9F8  17 18 19 1A 1B 1C 1D 1E 1F 20 21 22 23 24 25 26  |......... !"#$%&
BA08  27 28 29 2A 2B 2B 2B 2B 2C 2D 2E 2F 2F 2F 2F 2F  |'()*++++,-./////
BA18  2F 30 31 2F 2F 2F 2F 2F 2F 32 33 2F 2F 2F 2F 2F  |/01//////23/////
BA28  2F 34 35 36 37 36 37 36 37 38 01 02 03 04 05 06  |/456767678......
BA38  07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16  |................
BA48  17 18 19 1A 1B 1C 1D 1E 1F 20 39 3A 3B 3C 3D 3E  |......... 9:;<=>
BA58  3F 40 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E  |?@..............
BA68  0F 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E  |................
BA78  1F 20 41 42 43 42 43 42 43 44 01 02 03 04 05 06  |. ABCBCBCD......
BA88  07 08 09 0A 0B 0C 0D 0E 0F 10 45 46 13 14 15 47  |..........EF...G
BA98  48 49 4A 4B 1B 1C 1D 4C 4D 4E 21 22 23 24 25 26  |HIJK...LMN!"#$%&
BAA8  27 28 4F 50 03 04 05 06 51 52 53 54 0B 0C 0D 0E  |'(OP....QRST....
BAB8  55 56 57 58 13 14 15 16 59 5A 5B 5C 1B 1C 1D 1E  |UVWX....YZ[\....
BAC8  5D 5E 5F 60 61 62 62 60 61 63 64 65 66 66 66 66  |]^_`abb`acdeffff
BAD8  65 67 68 69 6A 6A 6A 6B 69 6C 6D 6E 6F 70 6F 71  |eghijjjkilmnopoq
BAE8  69 72 73 69 74 74 74 75 69 76 77 78 79 79 79 7A  |irsitttuivwxyyyz
BAF8  78 7B 64 65 66 66 66 66 65 67 68 69 6A 6A 6A 6B  |x{deffffeghijjjk
BB08  69 6C 6D 6E 6F 70 6F 71 69 72 73 69 74 74 74 75  |ilmnopoqirsitttu
BB18  69 76 7C 7D 7D 7D 7D 7D 7D 7E 36 BB 37 BB 38 BB  |iv|}}}}}}~6.7.8.
BB28  39 BB 3A BB 3B BB 3C BB 3D BB 3E BB 3F BB 04 05  |9.:.;.<.=.>.?...
BB38  00 00 06 07 00 01 02 03                          |........

loc_BB40:  ; 1 xrefs: 8038
BB40  BC CE 05 LDY $05CE,X             
BB43  B9 50 BB LDA $BB50,Y             
BB46  85 00    STA $00                 
BB48  B9 56 BB LDA $BB56,Y             
BB4B  85 01    STA $01                 
BB4D  6C 00 00 JMP ($0000)             

; ==== data $BB50..$BB5B  (12 bytes) ====
BB50  64 94 C7 1F 45 97 BB BB BB BC BC BC              |d...E.......

loc_BB5C:  ; 0 xrefs: 
BB5C  FE CE 05 INC $05CE,X             
BB5F  60       RTS                     

loc_BB60:  ; 1 xrefs: BB91
BB60  9D CE 05 STA $05CE,X             
BB63  60       RTS                     

; ==== data $BB64..$BB73  (16 bytes) ====
BB64  86 25 20 74 BB 20 74 BB FE CE 05 A6 25 4C 7D BB  |.% t. t.....%L}.

loc_BB74:  ; 0 xrefs: 
BB74  20 6A C8 JSR $C86A               
BB77  A9 4D    LDA #$4D                
BB79  9D 00 04 STA $0400,X             
BB7C  60       RTS                     

loc_BB7D:  ; 0 xrefs: 
BB7D  A9 3C    LDA #$3C                
BB7F  20 3A C8 JSR $C83A               
BB82  A9 80    LDA #$80                
BB84  9D C6 04 STA $04C6,X             
BB87  20 FD C8 JSR $C8FD               
BB8A  A9 18    LDA #$18                
BB8C  9D E4 05 STA $05E4,X             
BB8F  A9 01    LDA #$01                
BB91  4C 60 BB JMP loc_BB60            

; ==== data $BB94..$BCA9  (278 bytes) ====
BB94  DE E4 05 F0 12 BD E4 05 29 07 D0 03 20 FD C8 20  |........)... .. 
BBA4  3C C9 C9 11 90 01 60 A9 FE A0 00 20 00 C9 A9 00  |<.....`.... ....
BBB4  9D E4 05 9D FA 05 9D 10 06 9D 26 06 A8 20 09 C9  |..........&.. ..
BBC4  4C 5C BB 20 AA BC 20 EE C8 20 C4 BC A9 E8 85 00  |L\. .. .. ......
BBD4  A9 04 A0 F4 20 57 C9 10 0B BD 26 06 D0 27 FE 26  |.... W....&..'.&
BBE4  06 20 1B C9 20 8D C9 B0 1B BD 10 06 D0 11 20 3C  |. .. ......... <
BBF4  C9 C9 28 B0 0A FE 10 06 AD C6 04 C9 70 90 09 20  |..(.........p.. 
BC04  75 BD 90 04 60 4C 7D BB A9 00 A8 20 09 C9 20 06  |u...`L}.... .. .
BC14  C9 A9 3B 20 3A C8 A9 03 4C 60 BB A9 20 20 0F C9  |..; :...L`..  ..
BC24  20 EE C8 BD C6 04 C9 40 90 01 60 A9 FE A0 00 20  | ......@..`.... 
BC34  00 C9 A9 10 9D FA 05 A9 B0 9D E4 05 A9 04 4C 60  |..............L`
BC44  BB 20 28 BD 20 EE C8 BD E4 05 D0 09 20 3C C9 C9  |. (. ....... <..
BC54  15 90 30 B0 03 DE E4 05 A9 E8 85 00 A9 04 A0 F4  |..0.............
BC64  20 57 C9 10 03 20 1B C9 DE FA 05 D0 15 A9 20 9D  | W... ........ .
BC74  FA 05 A9 40 85 06 A9 25 85 24 A9 00 85 26 A8 20  |...@...%.$...&. 
BC84  E5 C8 60 A9 00 A8 20 06 C9 A9 01 A0 00 20 09 C9  |..`... ...... ..
BC94  4C 5C BB A9 38 20 0C C9 20 EE C8 BD C6 04 C9 80  |L\..8 .. .......
BCA4  B0 01 60 4C 7D BB                                |..`L}.

loc_BCAA:  ; 0 xrefs: 
BCAA  A9 06    LDA #$06                

loc_BCAC:  ; 1 xrefs: BD25
BCAC  85 00    STA $00                 
BCAE  A9 8E    LDA #$8E                
BCB0  85 01    STA $01                 
BCB2  A9 A0    LDA #$A0                
BCB4  9D C6 04 STA $04C6,X             
BCB7  A9 10    LDA #$10                
BCB9  A0 E0    LDY #$E0                
BCBB  20 CD C8 JSR $C8CD               
BCBE  A9 80    LDA #$80                
BCC0  9D C6 04 STA $04C6,X             
BCC3  60       RTS                     

loc_BCC4:  ; 0 xrefs: 
BCC4  BD FA 05 LDA $05FA,X             
BCC7  F0 04    BEQ loc_BCCD            
BCC9  DE FA 05 DEC $05FA,X             

loc_BCCC:  ; 3 xrefs: BCD7 BCDE BCE3
BCCC  60       RTS                     

loc_BCCD:  ; 1 xrefs: BCC7
BCCD  AD 16 04 LDA $0416               
BCD0  29 60    AND #$60                
BCD2  D0 4F    BNE loc_BD23            
BCD4  20 8D C9 JSR $C98D               
BCD7  B0 F3    BCS loc_BCCC            
BCD9  AD 64 01 LDA $0164               
BCDC  C9 03    CMP #$03                
BCDE  90 EC    BCC loc_BCCC            
BCE0  AD B8 05 LDA $05B8               
BCE3  F0 E7    BEQ loc_BCCC            
BCE5  AD 16 04 LDA $0416               
BCE8  4A       LSR A                   
BCE9  90 07    BCC loc_BCF2            
BCEB  A9 60    LDA #$60                
BCED  9D FA 05 STA $05FA,X             
BCF0  D0 05    BNE loc_BCF7            

loc_BCF2:  ; 1 xrefs: BCE9
BCF2  A9 F8    LDA #$F8                
BCF4  8D 10 06 STA $0610               

loc_BCF7:  ; 1 xrefs: BCF0
BCF7  A9 FC    LDA #$FC                
BCF9  8D 34 05 STA $0534               
BCFC  A9 08    LDA #$08                
BCFE  BC 60 05 LDY $0560,X             
BD01  10 02    BPL loc_BD05            
BD03  A9 F8    LDA #$F8                

loc_BD05:  ; 1 xrefs: BD01
BD05  8D 60 05 STA $0560               
BD08  A9 00    LDA #$00                
BD0A  8D 76 05 STA $0576               
BD0D  8D 4A 05 STA $054A               
BD10  BD 9A 04 LDA $049A,X             
BD13  18       CLC                     
BD14  69 04    ADC #$04                
BD16  C9 41    CMP #$41                
BD18  90 02    BCC loc_BD1C            
BD1A  A9 40    LDA #$40                

loc_BD1C:  ; 1 xrefs: BD18
BD1C  9D 9A 04 STA $049A,X             
BD1F  20 C4 C8 JSR $C8C4               
BD22  60       RTS                     

loc_BD23:  ; 1 xrefs: BCD2
BD23  A9 09    LDA #$09                
BD25  4C AC BC JMP loc_BCAC            

loc_BD28:  ; 0 xrefs: 
BD28  FE 3C 06 INC $063C,X             
BD2B  BD 3C 06 LDA $063C,X             
BD2E  48       PHA                     
BD2F  48       PHA                     
BD30  29 1F    AND #$1F                
BD32  A8       TAY                     
BD33  68       PLA                     
BD34  29 20    AND #$20                
BD36  F0 06    BEQ loc_BD3E            
BD38  98       TYA                     
BD39  49 FF    EOR #$FF                
BD3B  29 1F    AND #$1F                
BD3D  A8       TAY                     

loc_BD3E:  ; 1 xrefs: BD36
BD3E  B9 55 BD LDA $BD55,Y             
BD41  A8       TAY                     
BD42  68       PLA                     
BD43  18       CLC                     
BD44  69 20    ADC #$20                
BD46  29 40    AND #$40                
BD48  F0 05    BEQ loc_BD4F            
BD4A  98       TYA                     
BD4B  20 58 C8 JSR $C858               
BD4E  A8       TAY                     

loc_BD4F:  ; 1 xrefs: BD48
BD4F  98       TYA                     
BD50  A0 00    LDY #$00                
BD52  4C 09 C9 JMP $C909               

; ==== data $BD55..$BD74  (32 bytes) ====
BD55  00 01 00 00 01 00 00 01 00 00 00 01 00 00 00 01  |................
BD65  00 00 00 00 01 00 00 00 00 01 00 00 00 00 00 01  |................

loc_BD75:  ; 0 xrefs: 
BD75  A0 01    LDY #$01                

loc_BD77:  ; 1 xrefs: BDBA
BD77  B9 60 05 LDA $0560,Y             
BD7A  19 76 05 ORA $0576,Y             
BD7D  F0 38    BEQ loc_BDB7            
BD7F  B9 34 05 LDA $0534,Y             
BD82  19 4A 05 ORA $054A,Y             
BD85  D0 30    BNE loc_BDB7            
BD87  BD C6 04 LDA $04C6,X             
BD8A  38       SEC                     
BD8B  F9 C6 04 SBC $04C6,Y             
BD8E  B0 03    BCS loc_BD93            
BD90  20 58 C8 JSR $C858               

loc_BD93:  ; 1 xrefs: BD8E
BD93  C9 20    CMP #$20                
BD95  B0 20    BCS loc_BDB7            
BD97  BD 08 05 LDA $0508,X             
BD9A  38       SEC                     
BD9B  F9 08 05 SBC $0508,Y             
BD9E  08       PHP                     
BD9F  B0 03    BCS loc_BDA4            
BDA1  20 58 C8 JSR $C858               

loc_BDA4:  ; 1 xrefs: BD9F
BDA4  C9 50    CMP #$50                
BDA6  B0 0E    BCS loc_BDB6            
BDA8  28       PLP                     
BDA9  B9 60 05 LDA $0560,Y             
BDAC  30 04    BMI loc_BDB2            
BDAE  B0 0E    BCS loc_BDBE            
BDB0  90 05    BCC loc_BDB7            

loc_BDB2:  ; 1 xrefs: BDAC
BDB2  90 0A    BCC loc_BDBE            
BDB4  B0 01    BCS loc_BDB7            

loc_BDB6:  ; 1 xrefs: BDA6
BDB6  28       PLP                     

loc_BDB7:  ; 5 xrefs: BD7D BD85 BD95 BDB0 BDB4
BDB7  C8       INY                     
BDB8  C0 04    CPY #$04                
BDBA  D0 BB    BNE loc_BD77            
BDBC  38       SEC                     
BDBD  60       RTS                     

loc_BDBE:  ; 2 xrefs: BDAE BDB2
BDBE  18       CLC                     
BDBF  60       RTS                     

loc_BDC0:  ; 1 xrefs: 803B
BDC0  20 87 BF JSR sub_BF87            
BDC3  BC CE 05 LDY $05CE,X             
BDC6  B9 D3 BD LDA $BDD3,Y             
BDC9  85 00    STA $00                 
BDCB  B9 DC BD LDA $BDDC,Y             
BDCE  85 01    STA $01                 
BDD0  6C 00 00 JMP ($0000)             

; ==== data $BDD3..$BDE4  (18 bytes) ====
BDD3  E9 F9 42 73 A2 B5 EE 0B 7E BD BD BE BE BE BE BE  |..Bs....~.......
BDE3  BF BF                                            |..

loc_BDE5:  ; 1 xrefs: BE1F
BDE5  FE CE 05 INC $05CE,X             
BDE8  60       RTS                     

; ==== data $BDE9..$BDEB  (3 bytes) ====
BDE9  4C EC BD                                         |L..

loc_BDEC:  ; 0 xrefs: 
BDEC  A9 20    LDA #$20                
BDEE  9D E4 05 STA $05E4,X             
BDF1  A9 01    LDA #$01                
BDF3  9D CE 05 STA $05CE,X             
BDF6  4C AB C9 JMP $C9AB               

; ==== data $BDF9..$BDFC  (4 bytes) ====
BDF9  DE E4 05 F0                                      |....

loc_BDFD:  ; 0 xrefs: 
BDFD  0F BC E4 SLO $E4BC               
BE00  05 BD    ORA $BD                 
BE02  2C 04 29 BIT $2904               
BE05  7F 19 22 RRA $2219,X             
BE08  BE 9D 2C LDX $2C9D,Y             
BE0B  04 60    NOP $60                 
BE0D  A9 00    LDA #$00                
BE0F  9D 42 04 STA $0442,X             
BE12  9D 2C 04 STA $042C,X             
BE15  A9 80    LDA #$80                
BE17  9D E4 05 STA $05E4,X             
BE1A  A9 01    LDA #$01                
BE1C  9D 68 06 STA $0668,X             
BE1F  4C E5 BD JMP loc_BDE5            

; ==== data $BE22..$BF86  (357 bytes) ====
BE22  00 80 00 80 00 80 00 80 00 80 80 00 80 80 00 80  |................
BE32  80 00 00 80 80 00 00 80 80 80 00 00 00 80 80 80  |................
BE42  DE E4 05 F0 01 60 20 39 C9 29 3F 69 38 9D C6 04  |.....` 9.)?i8...
BE52  A0 60 AD 08 05 10 02 A0 A0 98 18 6D 08 05 9D 08  |.`.........m....
BE62  05 20 FD C8 A9 ED 9D 42 04 A9 20 9D E4 05 4C E5  |. .....B.. ...L.
BE72  BD DE E4 05 F0 17 BD E4 05 49 FF 18 69 01 29 1F  |.........I..i.).
BE82  A8 BD 2C 04 29 7F 19 22 BE 9D 2C 04 60 A9 00 9D  |..,.).."..,.`...
BE92  2C 04 20 FD C8 20 9F C9 A9 10 9D E4 05 4C E5 BD  |,. .. .......L..
BEA2  DE E4 05 F0 01 60 A9 EE 9D 42 04 A9 20 9D E4 05  |.....`...B.. ...
BEB2  4C E5 BD DE E4 05 F0 27 BD E4 05 C9 18 D0 1F FE  |L......'........
BEC2  42 04 A9 4B 85 24 A9 14 85 26 20 90 C9 A9 E8 A0  |B..K.$...& .....
BED2  58 90 04 A9 18 A0 28 84 06 A0 F0 20 E5 C8 60 A9  |X.....(.... ..`.
BEE2  20 9D E4 05 A9 ED 9D 42 04 4C E5 BD BD 68 06 C9  | ......B.L...h..
BEF2  02 D0 05 DE E4 05 F0 01 60 20 FD C8 A9 F0 9D 42  |........` .....B
BF02  04 A9 20 9D E4 05 4C E5 BD DE E4 05 F0 61 BD E4  |.. ...L......a..
BF12  05 C9 1E F0 05 C9 14 F0 25 60 20 FD C8 BD 08 05  |........%` .....
BF22  85 00 BD C6 04 85 01 AD 08 05 85 02 AD C6 04 18  |................
BF32  69 F6 85 03 20 B2 C8 38 E9 20 9D FA 05 60 FE 42  |i... ..8. ...`.B
BF42  04 BD FA 05 8D 60 01 A9 06 8D 61 01 A9 4C 85 24  |.....`....a..L.$
BF52  A9 10 85 26 AD 60 01 85 06 18 69 0C 8D 60 01 A9  |...&.`....i..`..
BF62  00 A8 20 E5 C8 CE 61 01 D0 E2 A9 33 4C 1C C8 A9  |.. ...a....3L...
BF72  20 9D E4 05 A9 ED 9D 42 04 4C E5 BD DE E4 05 D0  | ......B.L......
BF82  03 4C EC BD 60                                   |.L..`

sub_BF87:  ; 1 xrefs: BDC0
BF87  AD 77 06 LDA $0677               
BF8A  C9 02    CMP #$02                
BF8C  D0 26    BNE loc_BFB4            
BF8E  A9 00    LDA #$00                
BF90  85 5C    STA $5C                 
BF92  AD C6 04 LDA $04C6               
BF95  C9 8E    CMP #$8E                
BF97  90 1B    BCC loc_BFB4            
BF99  C9 94    CMP #$94                
BF9B  B0 12    BCS loc_BFAF            
BF9D  A9 8E    LDA #$8E                
BF9F  38       SEC                     
BFA0  ED C6 04 SBC $04C6               
BFA3  8D 52 06 STA $0652               
BFA6  AD 68 06 LDA $0668               
BFA9  09 40    ORA #$40                
BFAB  8D 68 06 STA $0668               
BFAE  60       RTS                     

loc_BFAF:  ; 1 xrefs: BF9B
BFAF  A9 F0    LDA #$F0                
BFB1  8D 68 06 STA $0668               

loc_BFB4:  ; 2 xrefs: BF8C BF97
BFB4  60       RTS                     

; ==== data $BFB5..$BFFF  (75 bytes) ====
BFB5  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFC5  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFD5  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFE5  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFF5  FF FF FF FF FF FF FF FF FF FF FF                 |...........