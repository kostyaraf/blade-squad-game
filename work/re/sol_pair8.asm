; ==== PRG bank pair 8/9 @ $8000/$A000 ====

; ---- data $8000-$8024 (37 bytes) ----
8000  08 00 00 00 4C 9C 86 4C 4C 81 4C 7B 81 4C E2 83  |....L..LL.L{.L..
8010  4C DE 80 4C B7 81 4C B5 93 4C 69 AE 4C 00 00 4C  |L..L..L..Li.L..L
8020  66 88 4C F6 88                                   |f.L..

sub_8025:  ; xrefs(2): $826C $8529
8025  84 2C    STY $2C                   
8027  0A       ASL A                     
8028  A8       TAY                       
8029  68       PLA                       
802A  85 29    STA $29                   
802C  68       PLA                       
802D  85 2A    STA $2A                   
802F  C8       INY                       
8030  B1 29    LDA ($29),Y               
8032  48       PHA                       
8033  C8       INY                       
8034  B1 29    LDA ($29),Y               
8036  A4 2C    LDY $2C                   
8038  85 2C    STA $2C                   
803A  68       PLA                       
803B  85 2B    STA $2B                   
803D  6C 2B 00 JMP ($002B)               

; ---- data $8040-$8058 (25 bytes) ----
8040  A9 00 85 90 85 91 85 92 85 93 60 85 26 84 27 60  |..........`.&.'`
8050  A5 80 69 80 A5 81 69 00 60                       |..i...i.`

sub_8059:  ; xrefs(1): $AED7
8059  A5 90    LDA $90                   
805B  C5 30    CMP $30                   
805D  A5 91    LDA $91                   
805F  E5 31    SBC $31                   
8061  18       CLC                       
8062  69 10    ADC #$10                  
8064  C9 30    CMP #$30                  
8066  B0 2B    BCS $8093                 
8068  4A       LSR A                     
8069  4A       LSR A                     
806A  AA       TAX                       
806B  A5 92    LDA $92                   
806D  C5 32    CMP $32                   
806F  A5 93    LDA $93                   
8071  E5 33    SBC $33                   
8073  18       CLC                       
8074  69 10    ADC #$10                  
8076  C9 30    CMP #$30                  
8078  B0 19    BCS $8093                 
807A  29 FC    AND #$FC                  
807C  85 94    STA $94                   
807E  0A       ASL A                     
807F  65 94    ADC $94                   
8081  85 94    STA $94                   
8083  8A       TXA                       
8084  65 94    ADC $94                   
8086  C9 24    CMP #$24                  
8088  90 09    BCC $8093                 
808A  C9 6C    CMP #$6C                  
808C  B0 05    BCS $8093                 
808E  AA       TAX                       
808F  BD 72 80 LDA $8072,X               
8092  60       RTS                       

loc_8093:  ; xrefs(4): $8066 $8078 $8088 $808C
8093  A9 FF    LDA #$FF                  
8095  60       RTS                       

; ---- data $8096-$80DD (72 bytes) ----
8096  FF FE FE 01 03 03 03 03 02 FE FE FF FF FE FE 01  |................
80A6  00 00 00 00 02 FE FE FF FF FE FE 01 00 00 00 00  |................
80B6  02 FE FE FF FF FE FE 01 00 00 00 00 02 FE FE FF  |................
80C6  FF FE FE 01 00 00 00 00 02 FE FE FF FF FE FE 01  |................
80D6  02 02 02 02 02 FE FE FF                          |........

loc_80DE:  ; xrefs(0): 
80DE  20 33 81 JSR $8133                 
80E1  85 54    STA $54                   
80E3  A0 04    LDY #$04                  
80E5  B1 1A    LDA ($1A),Y               
80E7  85 8C    STA $8C                   
80E9  C8       INY                       
80EA  B1 1A    LDA ($1A),Y               
80EC  85 8D    STA $8D                   
80EE  C8       INY                       
80EF  B1 1A    LDA ($1A),Y               
80F1  85 8E    STA $8E                   
80F3  C8       INY                       
80F4  B1 1A    LDA ($1A),Y               
80F6  85 8F    STA $8F                   
80F8  A0 00    LDY #$00                  
80FA  B1 1A    LDA ($1A),Y               
80FC  65 80    ADC $80                   
80FE  85 88    STA $88                   
8100  C8       INY                       
8101  B1 1A    LDA ($1A),Y               
8103  65 81    ADC $81                   
8105  85 89    STA $89                   
8107  C8       INY                       
8108  AD CB 05 LDA $05CB                 
810B  10 18    BPL $8125                 
810D  A5 82    LDA $82                   
810F  F1 1A    SBC ($1A),Y               
8111  85 8A    STA $8A                   
8113  C8       INY                       
8114  A5 83    LDA $83                   
8116  F1 1A    SBC ($1A),Y               
8118  48       PHA                       
8119  A5 8A    LDA $8A                   
811B  E5 8E    SBC $8E                   
811D  85 8A    STA $8A                   
811F  68       PLA                       
8120  E5 8F    SBC $8F                   
8122  85 8B    STA $8B                   
8124  60       RTS                       

loc_8125:  ; xrefs(1): $810B
8125  B1 1A    LDA ($1A),Y               
8127  65 82    ADC $82                   
8129  85 8A    STA $8A                   
812B  C8       INY                       
812C  B1 1A    LDA ($1A),Y               
812E  65 83    ADC $83                   
8130  85 8B    STA $8B                   
8132  60       RTS                       

sub_8133:  ; xrefs(1): $80DE
8133  AD A6 05 LDA $05A6                 
8136  0D A7 05 ORA $05A7                 
8139  F0 11    BEQ $814C                 
813B  AD B2 05 LDA $05B2                 
813E  0A       ASL A                     
813F  AD A6 05 LDA $05A6                 
8142  69 00    ADC #$00                  
8144  48       PHA                       
8145  AD A7 05 LDA $05A7                 
8148  69 00    ADC #$00                  
814A  A8       TAY                       
814B  68       PLA                       

loc_814C:  ; xrefs(1): $8139
814C  84 91    STY $91                   
814E  0A       ASL A                     
814F  26 91    ROL $91                   
8151  18       CLC                       
8152  69 19    ADC #$19                  
8154  85 90    STA $90                   
8156  A5 91    LDA $91                   
8158  69 8A    ADC #$8A                  
815A  85 91    STA $91                   
815C  A0 00    LDY #$00                  
815E  84 92    STY $92                   
8160  B1 90    LDA ($90),Y               
8162  48       PHA                       
8163  C8       INY                       
8164  B1 90    LDA ($90),Y               
8166  0A       ASL A                     
8167  26 92    ROL $92                   
8169  0A       ASL A                     
816A  26 92    ROL $92                   
816C  0A       ASL A                     
816D  26 92    ROL $92                   
816F  69 B5    ADC #$B5                  
8171  85 1A    STA $1A                   
8173  A5 92    LDA $92                   
8175  69 91    ADC #$91                  
8177  85 1B    STA $1B                   
8179  68       PLA                       
817A  60       RTS                       

loc_817B:  ; xrefs(0): 
817B  85 60    STA $60                   
817D  A0 00    LDY #$00                  
817F  B1 1A    LDA ($1A),Y               
8181  75 A0    ADC $A0,X                 
8183  85 94    STA $94                   
8185  85 61    STA $61                   
8187  C8       INY                       
8188  B1 1A    LDA ($1A),Y               
818A  75 B0    ADC $B0,X                 
818C  85 95    STA $95                   
818E  85 62    STA $62                   
8190  C8       INY                       
8191  B1 1A    LDA ($1A),Y               
8193  75 C0    ADC $C0,X                 
8195  85 96    STA $96                   
8197  85 63    STA $63                   
8199  C8       INY                       
819A  B1 1A    LDA ($1A),Y               
819C  75 D0    ADC $D0,X                 
819E  85 97    STA $97                   
81A0  85 64    STA $64                   
81A2  C8       INY                       
81A3  B1 1A    LDA ($1A),Y               
81A5  85 65    STA $65                   
81A7  C8       INY                       
81A8  B1 1A    LDA ($1A),Y               
81AA  85 66    STA $66                   
81AC  C8       INY                       
81AD  B1 1A    LDA ($1A),Y               
81AF  85 67    STA $67                   
81B1  C8       INY                       
81B2  B1 1A    LDA ($1A),Y               
81B4  85 68    STA $68                   
81B6  60       RTS                       

loc_81B7:  ; xrefs(0): 
81B7  A9 00    LDA #$00                  
81B9  85 9C    STA $9C                   
81BB  85 9D    STA $9D                   
81BD  A9 20    LDA #$20                  
81BF  85 9F    STA $9F                   
81C1  A5 88    LDA $88                   
81C3  C5 61    CMP $61                   
81C5  A5 89    LDA $89                   
81C7  E5 62    SBC $62                   
81C9  90 19    BCC $81E4                 
81CB  A5 61    LDA $61                   
81CD  65 65    ADC $65                   
81CF  85 94    STA $94                   
81D1  A5 62    LDA $62                   
81D3  65 66    ADC $66                   
81D5  85 95    STA $95                   
81D7  A5 88    LDA $88                   
81D9  C5 94    CMP $94                   
81DB  A5 89    LDA $89                   
81DD  E5 95    SBC $95                   
81DF  90 19    BCC $81FA                 
81E1  4C 41 82 JMP $8241                 

loc_81E4:  ; xrefs(1): $81C9
81E4  A5 61    LDA $61                   
81E6  E5 8C    SBC $8C                   
81E8  85 94    STA $94                   
81EA  A5 62    LDA $62                   
81EC  E5 8D    SBC $8D                   
81EE  85 95    STA $95                   
81F0  A5 88    LDA $88                   
81F2  C5 94    CMP $94                   
81F4  A5 89    LDA $89                   
81F6  E5 95    SBC $95                   
81F8  90 47    BCC $8241                 

loc_81FA:  ; xrefs(1): $81DF
81FA  A5 8A    LDA $8A                   
81FC  C5 63    CMP $63                   
81FE  A5 8B    LDA $8B                   
8200  E5 64    SBC $64                   
8202  90 1E    BCC $8222                 
8204  A5 63    LDA $63                   
8206  65 67    ADC $67                   
8208  85 96    STA $96                   
820A  A5 64    LDA $64                   
820C  65 68    ADC $68                   
820E  85 97    STA $97                   
8210  A5 96    LDA $96                   
8212  E5 8A    SBC $8A                   
8214  85 96    STA $96                   
8216  A5 97    LDA $97                   
8218  E5 8B    SBC $8B                   
821A  90 25    BCC $8241                 
821C  85 97    STA $97                   
821E  E6 9C    INC $9C                   
8220  B0 1C    BCS $823E                 

loc_8222:  ; xrefs(1): $8202
8222  A5 63    LDA $63                   
8224  E5 8E    SBC $8E                   
8226  85 96    STA $96                   
8228  A5 64    LDA $64                   
822A  E5 8F    SBC $8F                   
822C  85 97    STA $97                   
822E  A5 8A    LDA $8A                   
8230  E5 96    SBC $96                   
8232  85 96    STA $96                   
8234  A5 8B    LDA $8B                   
8236  E5 97    SBC $97                   
8238  90 07    BCC $8241                 
823A  85 97    STA $97                   
823C  E6 9D    INC $9D                   

loc_823E:  ; xrefs(1): $8220
823E  4C 44 82 JMP $8244                 

loc_8241:  ; xrefs(5): $81E1 $81F8 $821A $8238 $824E
8241  A9 00    LDA #$00                  
8243  60       RTS                       

loc_8244:  ; xrefs(1): $823E
8244  24 60    BIT $60                   
8246  30 1E    BMI $8266                 
8248  50 0A    BVC $8254                 
824A  A5 60    LDA $60                   
824C  29 0F    AND #$0F                  
824E  D0 F1    BNE $8241                 

loc_8250:  ; xrefs(1): $825D
8250  A9 01    LDA #$01                  
8252  D0 0F    BNE $8263                 

loc_8254:  ; xrefs(1): $8248
8254  AD C2 05 LDA $05C2                 
8257  F0 06    BEQ $825F                 
8259  A5 60    LDA $60                   
825B  29 20    AND #$20                  
825D  D0 F1    BNE $8250                 

loc_825F:  ; xrefs(1): $8257
825F  A5 60    LDA $60                   
8261  29 0F    AND #$0F                  

loc_8263:  ; xrefs(1): $8252
8263  4C 3C 83 JMP $833C                 

loc_8266:  ; xrefs(1): $8246
8266  A5 60    LDA $60                   
8268  29 07    AND #$07                  
826A  F0 11    BEQ $827D                 
826C  20 25 80 JSR $8025                 
826F  7E 82 7E ROR $7E82,X               
8272  82 99    NOP #$99                  
8274  82 AE    NOP #$AE                  
8276  82 B4    NOP #$B4                  
8278  82 B5    NOP #$B5                  
827A  82 F3    NOP #$F3                  
827C  82 60    NOP #$60                  
827E  A9 0F    LDA #$0F                  
8280  85 F1    STA $F1                   
8282  18       CLC                       
8283  AD C6 05 LDA $05C6                 
8286  69 05    ADC #$05                  
8288  8D C6 05 STA $05C6                 
828B  90 03    BCC $8290                 
828D  EE C7 05 INC $05C7                 

loc_8290:  ; xrefs(1): $828B
8290  BD 50 06 LDA $0650,X               
8293  09 80    ORA #$80                  
8295  9D 50 06 STA $0650,X               
8298  60       RTS                       

; ---- data $8299-$833B (163 bytes) ----
8299  A9 0F 85 F1 18 AD C6 05 69 14 8D C6 05 90 03 EE  |........i.......
82A9  C7 05 4C 90 82 A9 02 9D 90 06 60 60 A0 01 85 90  |..L.......``....
82B9  A9 00 85 91 AD C4 05 29 03 F0 16 E6 91 A0 04 AD  |.......)........
82C9  C4 05 29 0C F0 0B E6 91 A0 10 AD C4 05 29 30 D0  |..)..........)0.
82D9  5C A9 10 85 F1 98 0D C4 05 9D 20 06 A4 91 C0 02  |\......... .....
82E9  F0 43 A9 20 99 0C 07 4C 2E 83 A0 02 85 90 A9 00  |.C. ...L........
82F9  85 91 AD C4 05 29 03 F0 16 E6 91 A0 08 AD C4 05  |.....)..........
8309  29 0C F0 0B E6 91 A0 20 AD C4 05 29 30 D0 1E A9  |)...... ...)0...
8319  10 85 F1 98 0D C4 05 9D 20 06 A4 91 C0 02 F0 05  |........ .......
8329  A9 20 99 0C 07 A9 FF 9D 10 06 4C 90 82 A9 00 9D  |. ........L.....
8339  00 06 60                                         |..`

loc_833C:  ; xrefs(1): $8263
833C  85 9D    STA $9D                   
833E  AD C2 05 LDA $05C2                 
8341  F0 11    BEQ $8354                 
8343  BD E0 06 LDA $06E0,X               
8346  C9 08    CMP #$08                  
8348  90 6F    BCC $83B9                 
834A  A9 01    LDA #$01                  
834C  85 90    STA $90                   
834E  20 BC 83 JSR $83BC                 
8351  20 F2 87 JSR $87F2                 

loc_8354:  ; xrefs(2): $8341 $88F0
8354  AD C2 05 LDA $05C2                 
8357  F0 1E    BEQ $8377                 
8359  AD A3 05 LDA $05A3                 
835C  C9 20    CMP #$20                  
835E  90 59    BCC $83B9                 
8360  AD C2 05 LDA $05C2                 
8363  E9 10    SBC #$10                  
8365  B0 04    BCS $836B                 
8367  A9 02    LDA #$02                  
8369  90 02    BCC $836D                 

loc_836B:  ; xrefs(1): $8365
836B  09 07    ORA #$07                  

loc_836D:  ; xrefs(1): $8369
836D  8D C2 05 STA $05C2                 
8370  A9 00    LDA #$00                  
8372  8D A3 05 STA $05A3                 
8375  F0 42    BEQ $83B9                 

loc_8377:  ; xrefs(1): $8357
8377  AD C5 05 LDA $05C5                 
837A  F0 3D    BEQ $83B9                 
837C  AD A3 05 LDA $05A3                 
837F  C9 70    CMP #$70                  
8381  90 36    BCC $83B9                 
8383  AD C8 05 LDA $05C8                 
8386  F0 0C    BEQ $8394                 
8388  CE C8 05 DEC $05C8                 
838B  C9 01    CMP #$01                  
838D  D0 05    BNE $8394                 
838F  A9 28    LDA #$28                  
8391  8D 12 01 STA $0112                 

loc_8394:  ; xrefs(2): $8386 $838D
8394  A9 0A    LDA #$0A                  
8396  85 F1    STA $F1                   
8398  A9 00    LDA #$00                  
839A  8D A3 05 STA $05A3                 
839D  A5 9D    LDA $9D                   
839F  29 0F    AND #$0F                  
83A1  C9 08    CMP #$08                  
83A3  90 07    BCC $83AC                 
83A5  A9 01    LDA #$01                  
83A7  85 9D    STA $9D                   
83A9  8D CC 05 STA $05CC                 

loc_83AC:  ; xrefs(1): $83A3
83AC  38       SEC                       
83AD  AD C5 05 LDA $05C5                 
83B0  E5 9D    SBC $9D                   
83B2  B0 02    BCS $83B6                 
83B4  A9 00    LDA #$00                  

loc_83B6:  ; xrefs(1): $83B2
83B6  8D C5 05 STA $05C5                 

loc_83B9:  ; xrefs(5): $8348 $835E $8375 $837A $8381
83B9  A9 FF    LDA #$FF                  
83BB  60       RTS                       

sub_83BC:  ; xrefs(1): $834E
83BC  A9 00    LDA #$00                  
83BE  9D E0 06 STA $06E0,X               
83C1  BD 50 06 LDA $0650,X               
83C4  09 40    ORA #$40                  
83C6  9D 50 06 STA $0650,X               
83C9  38       SEC                       
83CA  BD F0 06 LDA $06F0,X               
83CD  E5 90    SBC $90                   
83CF  F0 02    BEQ $83D3                 
83D1  B0 0B    BCS $83DE                 

loc_83D3:  ; xrefs(1): $83CF
83D3  20 4F 88 JSR $884F                 
83D6  AD B2 05 LDA $05B2                 
83D9  20 50 88 JSR $8850                 
83DC  A9 00    LDA #$00                  

loc_83DE:  ; xrefs(1): $83D1
83DE  9D F0 06 STA $06F0,X               
83E1  60       RTS                       

loc_83E2:  ; xrefs(0): 
83E2  A5 60    LDA $60                   
83E4  30 06    BMI $83EC                 
83E6  A5 60    LDA $60                   
83E8  29 0F    AND #$0F                  
83EA  F0 61    BEQ $844D                 

loc_83EC:  ; xrefs(1): $83E4
83EC  20 B0 84 JSR $84B0                 
83EF  AD 0F 06 LDA $060F                 
83F2  F0 14    BEQ $8408                 
83F4  AD EF 06 LDA $06EF                 
83F7  C9 0C    CMP #$0C                  
83F9  90 0D    BCC $8408                 
83FB  A5 60    LDA $60                   
83FD  29 20    AND #$20                  
83FF  D0 07    BNE $8408                 
8401  A0 0F    LDY #$0F                  
8403  20 CD 84 JSR $84CD                 
8406  D0 46    BNE $844E                 

loc_8408:  ; xrefs(3): $83F2 $83F9 $83FF
8408  AD C2 05 LDA $05C2                 
840B  D0 40    BNE $844D                 
840D  A5 60    LDA $60                   
840F  30 3C    BMI $844D                 
8411  AD 0C 06 LDA $060C                 
8414  F0 0E    BEQ $8424                 
8416  AD EC 06 LDA $06EC                 
8419  C9 0C    CMP #$0C                  
841B  90 07    BCC $8424                 
841D  A0 0C    LDY #$0C                  
841F  20 CD 84 JSR $84CD                 
8422  D0 2A    BNE $844E                 

loc_8424:  ; xrefs(2): $8414 $841B
8424  20 B0 84 JSR $84B0                 
8427  AD 0D 06 LDA $060D                 
842A  F0 0E    BEQ $843A                 
842C  AD ED 06 LDA $06ED                 
842F  C9 0C    CMP #$0C                  
8431  90 07    BCC $843A                 
8433  A0 0D    LDY #$0D                  
8435  20 CD 84 JSR $84CD                 
8438  D0 14    BNE $844E                 

loc_843A:  ; xrefs(2): $842A $8431
843A  AD 0E 06 LDA $060E                 
843D  F0 0E    BEQ $844D                 
843F  AD EE 06 LDA $06EE                 
8442  C9 0C    CMP #$0C                  
8444  90 07    BCC $844D                 
8446  A0 0E    LDY #$0E                  
8448  20 CD 84 JSR $84CD                 
844B  D0 01    BNE $844E                 

loc_844D:  ; xrefs(5): $83EA $840B $840F $843D $8444
844D  60       RTS                       

loc_844E:  ; xrefs(4): $8406 $8422 $8438 $844B
844E  A5 60    LDA $60                   
8450  F0 5B    BEQ $84AD                 
8452  30 41    BMI $8495                 
8454  A9 00    LDA #$00                  
8456  99 E0 06 STA $06E0,Y               
8459  C0 0C    CPY #$0C                  
845B  D0 08    BNE $8465                 
845D  A5 F1    LDA $F1                   
845F  D0 04    BNE $8465                 
8461  A9 33    LDA #$33                  
8463  85 F1    STA $F1                   

loc_8465:  ; xrefs(2): $845B $845F
8465  A5 60    LDA $60                   
8467  29 0F    AND #$0F                  
8469  C9 08    CMP #$08                  
846B  90 02    BCC $846F                 
846D  A9 01    LDA #$01                  

loc_846F:  ; xrefs(1): $846B
846F  85 90    STA $90                   
8471  38       SEC                       
8472  B9 F0 06 LDA $06F0,Y               
8475  E5 90    SBC $90                   
8477  F0 02    BEQ $847B                 
8479  B0 16    BCS $8491                 

loc_847B:  ; xrefs(1): $8477
847B  A9 00    LDA #$00                  
847D  99 10 06 STA $0610,Y               
8480  C0 0C    CPY #$0C                  
8482  D0 07    BNE $848B                 
8484  A9 20    LDA #$20                  
8486  99 20 06 STA $0620,Y               
8489  A9 FF    LDA #$FF                  

loc_848B:  ; xrefs(1): $8482
848B  99 00 06 STA $0600,Y               
848E  A9 FF    LDA #$FF                  
8490  60       RTS                       

loc_8491:  ; xrefs(1): $8479
8491  99 F0 06 STA $06F0,Y               
8494  60       RTS                       

loc_8495:  ; xrefs(1): $8452
8495  C0 0F    CPY #$0F                  
8497  D0 11    BNE $84AA                 
8499  A9 00    LDA #$00                  
849B  99 E0 06 STA $06E0,Y               

sub_849E:  ; xrefs(2): $854A $855D
849E  A5 9B    LDA $9B                   
84A0  29 40    AND #$40                  
84A2  19 00 06 ORA $0600,Y               
84A5  09 80    ORA #$80                  
84A7  99 00 06 STA $0600,Y               

loc_84AA:  ; xrefs(1): $8497
84AA  A9 FF    LDA #$FF                  
84AC  60       RTS                       

loc_84AD:  ; xrefs(4): $8450 $84DB $84F3 $84FF
84AD  A9 00    LDA #$00                  
84AF  60       RTS                       

sub_84B0:  ; xrefs(2): $83EC $8424
84B0  A5 61    LDA $61                   
84B2  E9 80    SBC #$80                  
84B4  85 9C    STA $9C                   
84B6  A5 62    LDA $62                   
84B8  E9 00    SBC #$00                  
84BA  85 9D    STA $9D                   
84BC  A5 63    LDA $63                   
84BE  E9 80    SBC #$80                  
84C0  85 9E    STA $9E                   
84C2  A5 64    LDA $64                   
84C4  E9 00    SBC #$00                  
84C6  85 9F    STA $9F                   
84C8  E6 66    INC $66                   
84CA  E6 68    INC $68                   
84CC  60       RTS                       

sub_84CD:  ; xrefs(4): $8403 $841F $8435 $8448
84CD  A9 00    LDA #$00                  
84CF  85 9B    STA $9B                   
84D1  B9 A0 00 LDA $00A0,Y               
84D4  C5 9C    CMP $9C                   
84D6  B9 B0 00 LDA $00B0,Y               
84D9  E5 9D    SBC $9D                   
84DB  90 D0    BCC $84AD                 
84DD  A5 9C    LDA $9C                   
84DF  65 65    ADC $65                   
84E1  85 94    STA $94                   
84E3  A5 9D    LDA $9D                   
84E5  65 66    ADC $66                   
84E7  85 95    STA $95                   
84E9  B9 A0 00 LDA $00A0,Y               
84EC  C5 94    CMP $94                   
84EE  B9 B0 00 LDA $00B0,Y               
84F1  E5 95    SBC $95                   
84F3  B0 B8    BCS $84AD                 
84F5  B9 C0 00 LDA $00C0,Y               
84F8  C5 9E    CMP $9E                   
84FA  B9 D0 00 LDA $00D0,Y               
84FD  E5 9F    SBC $9F                   
84FF  90 AC    BCC $84AD                 
8501  C6 9B    DEC $9B                   
8503  A5 9E    LDA $9E                   
8505  65 67    ADC $67                   
8507  85 96    STA $96                   
8509  A5 9F    LDA $9F                   
850B  65 68    ADC $68                   
850D  85 97    STA $97                   
850F  A5 96    LDA $96                   
8511  F9 C0 00 SBC $00C0,Y               
8514  A5 97    LDA $97                   
8516  F9 D0 00 SBC $00D0,Y               
8519  B0 20    BCS $853B                 
851B  A9 00    LDA #$00                  
851D  60       RTS                       

loc_851E:  ; xrefs(1): $853D
851E  B9 50 06 LDA $0650,Y               
8521  C9 0A    CMP #$0A                  
8523  90 15    BCC $853A                 
8525  A5 60    LDA $60                   
8527  29 0F    AND #$0F                  
8529  20 25 80 JSR $8025                 
852C  3A       NOP                       
852D  85 F5    STA $F5                   
852F  85 F5    STA $F5                   
8531  85 AE    STA $AE                   
8533  82 EF    NOP #$EF                  
8535  85 F8    STA $F8                   
8537  85 FC    STA $FC                   
8539  85 60    STA $60                   

loc_853B:  ; xrefs(1): $8519
853B  24 60    BIT $60                   
853D  30 DF    BMI $851E                 
853F  50 16    BVC $8557                 
8541  A5 60    LDA $60                   
8543  29 0F    AND #$0F                  
8545  D0 03    BNE $854A                 

loc_8547:  ; xrefs(2): $855B $8565
8547  A9 FF    LDA #$FF                  
8549  60       RTS                       

loc_854A:  ; xrefs(1): $8545
854A  20 9E 84 JSR $849E                 
854D  B9 50 06 LDA $0650,Y               
8550  C9 0A    CMP #$0A                  
8552  B0 03    BCS $8557                 
8554  A9 00    LDA #$00                  
8556  60       RTS                       

loc_8557:  ; xrefs(2): $853F $8552
8557  A5 60    LDA $60                   
8559  29 20    AND #$20                  
855B  D0 EA    BNE $8547                 
855D  20 9E 84 JSR $849E                 
8560  BD E0 06 LDA $06E0,X               
8563  C9 08    CMP #$08                  
8565  90 E0    BCC $8547                 
8567  B9 70 06 LDA $0670,Y               
856A  85 4D    STA $4D                   
856C  B9 60 06 LDA $0660,Y               
856F  0A       ASL A                     
8570  26 4D    ROL $4D                   
8572  69 19    ADC #$19                  
8574  85 4C    STA $4C                   
8576  A5 4D    LDA $4D                   
8578  69 8A    ADC #$8A                  
857A  85 4D    STA $4D                   
857C  84 90    STY $90                   
857E  A0 00    LDY #$00                  
8580  B1 4C    LDA ($4C),Y               
8582  48       PHA                       
8583  A4 90    LDY $90                   
8585  68       PLA                       
8586  F0 6D    BEQ $85F5                 
8588  85 90    STA $90                   
858A  C0 0F    CPY #$0F                  
858C  D0 0C    BNE $859A                 
858E  AD C8 05 LDA $05C8                 
8591  F0 07    BEQ $859A                 
8593  AD C2 05 LDA $05C2                 
8596  D0 02    BNE $859A                 
8598  06 90    ASL $90                   

loc_859A:  ; xrefs(3): $858C $8591 $8596
859A  A9 00    LDA #$00                  
859C  9D E0 06 STA $06E0,X               
859F  BD 50 06 LDA $0650,X               
85A2  29 BF    AND #$BF                  
85A4  9D 50 06 STA $0650,X               
85A7  38       SEC                       
85A8  BD F0 06 LDA $06F0,X               
85AB  E5 90    SBC $90                   
85AD  F0 02    BEQ $85B1                 
85AF  B0 08    BCS $85B9                 

loc_85B1:  ; xrefs(1): $85AD
85B1  AD B2 05 LDA $05B2                 
85B4  20 50 88 JSR $8850                 
85B7  A9 00    LDA #$00                  

loc_85B9:  ; xrefs(1): $85AF
85B9  9D F0 06 STA $06F0,X               
85BC  C0 0F    CPY #$0F                  
85BE  D0 29    BNE $85E9                 
85C0  AD CD 05 LDA $05CD                 
85C3  C9 30    CMP #$30                  
85C5  D0 25    BNE $85EC                 
85C7  A5 90    LDA $90                   
85C9  C9 02    CMP #$02                  
85CB  90 0C    BCC $85D9                 
85CD  AD B2 05 LDA $05B2                 
85D0  0A       ASL A                     
85D1  A9 10    LDA #$10                  
85D3  B0 0E    BCS $85E3                 
85D5  A9 F0    LDA #$F0                  
85D7  D0 0A    BNE $85E3                 

loc_85D9:  ; xrefs(1): $85CB
85D9  AD B2 05 LDA $05B2                 
85DC  0A       ASL A                     
85DD  A9 08    LDA #$08                  
85DF  B0 02    BCS $85E3                 
85E1  A9 F8    LDA #$F8                  

loc_85E3:  ; xrefs(3): $85D3 $85D7 $85DF
85E3  65 35    ADC $35                   
85E5  85 35    STA $35                   
85E7  D0 03    BNE $85EC                 

loc_85E9:  ; xrefs(1): $85BE
85E9  20 F2 87 JSR $87F2                 

loc_85EC:  ; xrefs(2): $85C5 $85E7
85EC  A9 FF    LDA #$FF                  
85EE  60       RTS                       

; ---- data $85EF-$85F4 (6 bytes) ----
85EF  20 04 86 4C EC 85                                | ..L..

loc_85F5:  ; xrefs(1): $8586
85F5  A9 00    LDA #$00                  
85F7  60       RTS                       

; ---- data $85F8-$869B (164 bytes) ----
85F8  A9 09 D0 02 A9 08 9D 50 06 4C 67 85 84 90 A0 0B  |.......P.Lg.....
8608  B9 00 06 F0 06 88 10 F8 A4 90 60 99 A0 06 99 B0  |..........`.....
8618  06 99 C0 06 99 D0 06 99 60 06 99 70 06 A9 0A 99  |........`..p....
8628  50 06 99 F0 06 A9 20 99 90 06 B5 B0 99 B0 00 B5  |P..... .........
8638  D0 99 D0 00 B5 A0 99 A0 00 B5 C0 99 C0 00 A9 80  |................
8648  99 E0 06 99 00 06 BD 80 06 49 FF 9D 80 06 A9 B0  |.........I......
8658  99 30 06 A9 FF 99 40 06 99 20 06 A9 0D 85 F1 A9  |.0....@.. ......
8668  01 99 10 06 84 91 A4 90 B9 70 06 85 4D B9 60 06  |.........p..M.`.
8678  0A 26 4D 69 19 85 4C A5 4D 69 8A 85 4D A0 00 B1  |.&Mi..L.Mi..M...
8688  4C C9 02 90 0C A4 91 A9 02 99 10 06 A9 C0 99 30  |L..............0
8698  06 A4 90 60                                      |...`

loc_869C:  ; xrefs(0): 
869C  A5 60    LDA $60                   
869E  30 0E    BMI $86AE                 
86A0  29 20    AND #$20                  
86A2  D0 0A    BNE $86AE                 
86A4  BD 50 06 LDA $0650,X               
86A7  30 05    BMI $86AE                 
86A9  AD 0C 06 LDA $060C                 
86AC  D0 01    BNE $86AF                 

loc_86AE:  ; xrefs(3): $869E $86A2 $86A7
86AE  60       RTS                       

loc_86AF:  ; xrefs(1): $86AC
86AF  AD 5C 06 LDA $065C                 
86B2  29 7F    AND #$7F                  
86B4  A8       TAY                       
86B5  B9 59 87 LDA $8759,Y               
86B8  F0 47    BEQ $8701                 
86BA  C9 02    CMP #$02                  
86BC  90 2B    BCC $86E9                 
86BE  A5 0C    LDA $0C                   
86C0  6A       ROR A                     
86C1  B0 13    BCS $86D6                 
86C3  A0 05    LDY #$05                  
86C5  20 26 87 JSR $8726                 
86C8  A0 04    LDY #$04                  
86CA  20 26 87 JSR $8726                 
86CD  A0 01    LDY #$01                  
86CF  20 26 87 JSR $8726                 
86D2  A0 00    LDY #$00                  
86D4  D0 50    BNE $8726                 

loc_86D6:  ; xrefs(1): $86C1
86D6  A0 07    LDY #$07                  
86D8  20 26 87 JSR $8726                 
86DB  A0 06    LDY #$06                  
86DD  20 26 87 JSR $8726                 
86E0  A0 03    LDY #$03                  
86E2  20 26 87 JSR $8726                 
86E5  A0 02    LDY #$02                  
86E7  D0 3D    BNE $8726                 

loc_86E9:  ; xrefs(1): $86BC
86E9  A5 0C    LDA $0C                   
86EB  6A       ROR A                     
86EC  B0 27    BCS $8715                 
86EE  A0 07    LDY #$07                  
86F0  20 26 87 JSR $8726                 
86F3  A0 05    LDY #$05                  
86F5  20 26 87 JSR $8726                 
86F8  A0 03    LDY #$03                  
86FA  20 26 87 JSR $8726                 
86FD  A0 01    LDY #$01                  
86FF  D0 25    BNE $8726                 

loc_8701:  ; xrefs(1): $86B8
8701  A0 07    LDY #$07                  
8703  20 26 87 JSR $8726                 
8706  A0 05    LDY #$05                  
8708  20 26 87 JSR $8726                 
870B  A0 03    LDY #$03                  
870D  20 26 87 JSR $8726                 
8710  A0 01    LDY #$01                  
8712  20 26 87 JSR $8726                 

loc_8715:  ; xrefs(1): $86EC
8715  A0 06    LDY #$06                  
8717  20 26 87 JSR $8726                 
871A  A0 04    LDY #$04                  
871C  20 26 87 JSR $8726                 
871F  A0 02    LDY #$02                  
8721  20 26 87 JSR $8726                 
8724  A0 00    LDY #$00                  

sub_8726:  ; xrefs(19): $86C5 $86CA $86CF $86D4 $86D8 $86DD $86E2 $86E7 $86F0 $86F5
8726  B9 00 07 LDA $0700,Y               
8729  10 05    BPL $8730                 
872B  20 6D 87 JSR $876D                 
872E  D0 01    BNE $8731                 

loc_8730:  ; xrefs(1): $8729
8730  60       RTS                       

loc_8731:  ; xrefs(1): $872E
8731  A5 60    LDA $60                   
8733  29 0F    AND #$0F                  
8735  85 90    STA $90                   
8737  38       SEC                       
8738  B9 70 07 LDA $0770,Y               
873B  E5 90    SBC $90                   
873D  F0 02    BEQ $8741                 
873F  B0 0F    BCS $8750                 

loc_8741:  ; xrefs(1): $873D
8741  B9 00 07 LDA $0700,Y               
8744  29 7F    AND #$7F                  
8746  99 00 07 STA $0700,Y               
8749  A9 00    LDA #$00                  
874B  99 50 07 STA $0750,Y               
874E  A9 00    LDA #$00                  

loc_8750:  ; xrefs(1): $873F
8750  99 70 07 STA $0770,Y               
8753  A9 FF    LDA #$FF                  
8755  60       RTS                       

; ---- data $8756-$876C (23 bytes) ----
8756  A9 00 60 00 00 02 00 02 01 01 00 00 01 00 00 00  |..`.............
8766  00 00 00 00 00 00 00                             |.......

sub_876D:  ; xrefs(1): $872B
876D  B9 10 07 LDA $0710,Y               
8770  E5 61    SBC $61                   
8772  B9 20 07 LDA $0720,Y               
8775  E5 62    SBC $62                   
8777  90 66    BCC $87DF                 
8779  A5 61    LDA $61                   
877B  65 65    ADC $65                   
877D  85 94    STA $94                   
877F  A5 62    LDA $62                   
8781  65 66    ADC $66                   
8783  85 95    STA $95                   
8785  B9 10 07 LDA $0710,Y               
8788  E5 94    SBC $94                   
878A  B9 20 07 LDA $0720,Y               
878D  E5 95    SBC $95                   
878F  B0 4E    BCS $87DF                 
8791  B9 30 07 LDA $0730,Y               
8794  E5 63    SBC $63                   
8796  B9 40 07 LDA $0740,Y               
8799  E5 64    SBC $64                   
879B  90 42    BCC $87DF                 
879D  A5 63    LDA $63                   
879F  65 67    ADC $67                   
87A1  85 96    STA $96                   
87A3  A5 64    LDA $64                   
87A5  65 68    ADC $68                   
87A7  85 97    STA $97                   
87A9  A5 96    LDA $96                   
87AB  F9 30 07 SBC $0730,Y               
87AE  A5 97    LDA $97                   
87B0  F9 40 07 SBC $0740,Y               
87B3  90 2A    BCC $87DF                 
87B5  BD E0 06 LDA $06E0,X               
87B8  C9 09    CMP #$09                  
87BA  90 20    BCC $87DC                 
87BC  A9 00    LDA #$00                  
87BE  9D E0 06 STA $06E0,X               
87C1  BD 50 06 LDA $0650,X               
87C4  09 40    ORA #$40                  
87C6  9D 50 06 STA $0650,X               
87C9  38       SEC                       
87CA  BD F0 06 LDA $06F0,X               
87CD  E9 01    SBC #$01                  
87CF  F0 02    BEQ $87D3                 
87D1  B0 03    BCS $87D6                 

loc_87D3:  ; xrefs(1): $87CF
87D3  20 E2 87 JSR $87E2                 

loc_87D6:  ; xrefs(1): $87D1
87D6  9D F0 06 STA $06F0,X               
87D9  20 F2 87 JSR $87F2                 

loc_87DC:  ; xrefs(1): $87BA
87DC  A9 FF    LDA #$FF                  
87DE  60       RTS                       

loc_87DF:  ; xrefs(4): $8777 $878F $879B $87B3
87DF  A9 00    LDA #$00                  
87E1  60       RTS                       

sub_87E2:  ; xrefs(1): $87D3
87E2  98       TYA                       
87E3  48       PHA                       
87E4  20 4F 88 JSR $884F                 
87E7  AD B2 05 LDA $05B2                 
87EA  20 50 88 JSR $8850                 
87ED  68       PLA                       
87EE  A8       TAY                       
87EF  A9 00    LDA #$00                  
87F1  60       RTS                       

sub_87F2:  ; xrefs(3): $8351 $85E9 $87D9
87F2  84 96    STY $96                   
87F4  A5 F1    LDA $F1                   
87F6  C9 2E    CMP #$2E                  
87F8  F0 0D    BEQ $8807                 
87FA  BD 50 06 LDA $0650,X               
87FD  29 3F    AND #$3F                  
87FF  A8       TAY                       
8800  B9 0A 88 LDA $880A,Y               
8803  F0 02    BEQ $8807                 
8805  85 F1    STA $F1                   

loc_8807:  ; xrefs(2): $87F8 $8803
8807  A4 96    LDY $96                   
8809  60       RTS                       

; ---- data $880A-$884E (69 bytes) ----
880A  35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35  |5555555555555555
881A  35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35  |5555555555555555
882A  35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35  |5555555555555555
883A  35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35  |5555555555555555
884A  35 35 35 35 35                                   |55555

sub_884F:  ; xrefs(2): $83D3 $87E4
884F  60       RTS                       

sub_8850:  ; xrefs(3): $83D9 $85B4 $87EA
8850  BD 50 06 LDA $0650,X               
8853  30 10    BMI $8865                 
8855  09 80    ORA #$80                  
8857  9D 50 06 STA $0650,X               
885A  A9 00    LDA #$00                  
885C  9D C0 06 STA $06C0,X               
885F  9D D0 06 STA $06D0,X               
8862  9D 10 06 STA $0610,X               

loc_8865:  ; xrefs(1): $8853
8865  60       RTS                       

loc_8866:  ; xrefs(0): 
8866  A0 0F    LDY #$0F                  

loc_8868:  ; xrefs(1): $8873
8868  B9 80 07 LDA $0780,Y               
886B  10 05    BPL $8872                 
886D  20 9F 88 JSR $889F                 
8870  D0 04    BNE $8876                 

loc_8872:  ; xrefs(1): $886B
8872  88       DEY                       
8873  10 F3    BPL $8868                 
8875  60       RTS                       

loc_8876:  ; xrefs(1): $8870
8876  38       SEC                       
8877  B9 F0 07 LDA $07F0,Y               
887A  E9 01    SBC #$01                  
887C  F0 02    BEQ $8880                 
887E  B0 0D    BCS $888D                 

loc_8880:  ; xrefs(1): $887C
8880  B9 80 07 LDA $0780,Y               
8883  29 7F    AND #$7F                  
8885  99 80 07 STA $0780,Y               
8888  A9 00    LDA #$00                  
888A  99 D0 07 STA $07D0,Y               

loc_888D:  ; xrefs(1): $887E
888D  99 F0 07 STA $07F0,Y               
8890  AD C2 05 LDA $05C2                 
8893  F0 04    BEQ $8899                 
8895  A9 33    LDA #$33                  
8897  85 F1    STA $F1                   

loc_8899:  ; xrefs(1): $8893
8899  A9 FF    LDA #$FF                  
889B  60       RTS                       

; ---- data $889C-$889E (3 bytes) ----
889C  A9 00 60                                         |..`

sub_889F:  ; xrefs(1): $886D
889F  B9 90 07 LDA $0790,Y               
88A2  E5 88    SBC $88                   
88A4  B9 A0 07 LDA $07A0,Y               
88A7  E5 89    SBC $89                   
88A9  90 48    BCC $88F3                 
88AB  A5 88    LDA $88                   
88AD  65 8C    ADC $8C                   
88AF  85 94    STA $94                   
88B1  A5 89    LDA $89                   
88B3  65 8D    ADC $8D                   
88B5  85 95    STA $95                   
88B7  B9 90 07 LDA $0790,Y               
88BA  E5 94    SBC $94                   
88BC  B9 A0 07 LDA $07A0,Y               
88BF  E5 95    SBC $95                   
88C1  B0 30    BCS $88F3                 
88C3  B9 B0 07 LDA $07B0,Y               
88C6  E5 8A    SBC $8A                   
88C8  B9 C0 07 LDA $07C0,Y               
88CB  E5 8B    SBC $8B                   
88CD  90 24    BCC $88F3                 
88CF  A5 8A    LDA $8A                   
88D1  65 8E    ADC $8E                   
88D3  85 96    STA $96                   
88D5  A5 8B    LDA $8B                   
88D7  65 8F    ADC $8F                   
88D9  85 97    STA $97                   
88DB  A5 96    LDA $96                   
88DD  F9 B0 07 SBC $07B0,Y               
88E0  A5 97    LDA $97                   
88E2  F9 C0 07 SBC $07C0,Y               
88E5  90 0C    BCC $88F3                 
88E7  AD C5 05 LDA $05C5                 
88EA  F0 09    BEQ $88F5                 
88EC  A9 01    LDA #$01                  
88EE  85 9D    STA $9D                   
88F0  4C 54 83 JMP $8354                 

loc_88F3:  ; xrefs(4): $88A9 $88C1 $88CD $88E5
88F3  A9 00    LDA #$00                  

loc_88F5:  ; xrefs(1): $88EA
88F5  60       RTS                       

loc_88F6:  ; xrefs(0): 
88F6  B5 A0    LDA $A0,X                 
88F8  E9 80    SBC #$80                  
88FA  85 9C    STA $9C                   
88FC  B5 B0    LDA $B0,X                 
88FE  E9 00    SBC #$00                  
8900  85 9D    STA $9D                   
8902  B5 C0    LDA $C0,X                 
8904  E9 80    SBC #$80                  
8906  85 9E    STA $9E                   
8908  B5 D0    LDA $D0,X                 
890A  E9 00    SBC #$00                  
890C  85 9F    STA $9F                   
890E  A9 01    LDA #$01                  
8910  85 66    STA $66                   
8912  85 68    STA $68                   
8914  85 65    STA $65                   
8916  85 67    STA $67                   
8918  A0 0F    LDY #$0F                  

loc_891A:  ; xrefs(1): $8939
891A  B9 80 07 LDA $0780,Y               
891D  10 19    BPL $8938                 
891F  29 7F    AND #$7F                  
8921  86 90    STX $90                   
8923  AA       TAX                       
8924  BD 5C 89 LDA $895C,X               
8927  48       PHA                       
8928  A6 90    LDX $90                   
892A  68       PLA                       
892B  F0 06    BEQ $8933                 
892D  98       TYA                       
892E  45 0C    EOR $0C                   
8930  6A       ROR A                     
8931  B0 05    BCS $8938                 

loc_8933:  ; xrefs(1): $892B
8933  20 5F 89 JSR $895F                 
8936  D0 04    BNE $893C                 

loc_8938:  ; xrefs(2): $891D $8931
8938  88       DEY                       
8939  10 DF    BPL $891A                 
893B  60       RTS                       

loc_893C:  ; xrefs(1): $8936
893C  38       SEC                       
893D  B9 F0 07 LDA $07F0,Y               
8940  E9 01    SBC #$01                  
8942  F0 02    BEQ $8946                 
8944  B0 0D    BCS $8953                 

loc_8946:  ; xrefs(1): $8942
8946  B9 80 07 LDA $0780,Y               
8949  29 7F    AND #$7F                  
894B  99 80 07 STA $0780,Y               
894E  A9 00    LDA #$00                  
8950  99 D0 07 STA $07D0,Y               

loc_8953:  ; xrefs(1): $8944
8953  99 F0 07 STA $07F0,Y               
8956  A9 FF    LDA #$FF                  
8958  60       RTS                       

loc_8959:  ; xrefs(3): $8969 $8981 $898D
8959  A9 00    LDA #$00                  
895B  60       RTS                       

; ---- data $895C-$895E (3 bytes) ----
895C  00 00 00                                         |...

sub_895F:  ; xrefs(1): $8933
895F  B9 90 07 LDA $0790,Y               
8962  E5 9C    SBC $9C                   
8964  B9 A0 07 LDA $07A0,Y               
8967  E5 9D    SBC $9D                   
8969  90 EE    BCC $8959                 
896B  A5 9C    LDA $9C                   
896D  65 65    ADC $65                   
896F  85 94    STA $94                   
8971  A5 9D    LDA $9D                   
8973  65 66    ADC $66                   
8975  85 95    STA $95                   
8977  B9 90 07 LDA $0790,Y               
897A  E5 94    SBC $94                   
897C  B9 A0 07 LDA $07A0,Y               
897F  E5 95    SBC $95                   
8981  B0 D6    BCS $8959                 
8983  B9 B0 07 LDA $07B0,Y               
8986  E5 9E    SBC $9E                   
8988  B9 C0 07 LDA $07C0,Y               
898B  E5 9F    SBC $9F                   
898D  90 CA    BCC $8959                 
898F  A5 9E    LDA $9E                   
8991  65 67    ADC $67                   
8993  85 96    STA $96                   
8995  A5 9F    LDA $9F                   
8997  65 68    ADC $68                   
8999  85 97    STA $97                   
899B  A5 96    LDA $96                   
899D  F9 B0 07 SBC $07B0,Y               
89A0  A5 97    LDA $97                   
89A2  F9 C0 07 SBC $07C0,Y               
89A5  90 6F    BCC $8A16                 
89A7  BD 50 06 LDA $0650,X               
89AA  30 67    BMI $8A13                 
89AC  BD 70 06 LDA $0670,X               
89AF  85 4D    STA $4D                   
89B1  BD 60 06 LDA $0660,X               
89B4  0A       ASL A                     
89B5  26 4D    ROL $4D                   
89B7  69 19    ADC #$19                  
89B9  85 4C    STA $4C                   
89BB  A5 4D    LDA $4D                   
89BD  69 8A    ADC #$8A                  
89BF  85 4D    STA $4D                   
89C1  84 90    STY $90                   
89C3  A0 00    LDY #$00                  
89C5  B1 4C    LDA ($4C),Y               
89C7  48       PHA                       
89C8  A4 90    LDY $90                   
89CA  68       PLA                       
89CB  F0 49    BEQ $8A16                 
89CD  85 90    STA $90                   
89CF  A9 00    LDA #$00                  
89D1  9D E0 06 STA $06E0,X               
89D4  38       SEC                       
89D5  BD F0 06 LDA $06F0,X               
89D8  E9 01    SBC #$01                  
89DA  B0 1A    BCS $89F6                 
89DC  A9 00    LDA #$00                  
89DE  9D 10 06 STA $0610,X               
89E1  E0 0C    CPX #$0C                  
89E3  D0 0B    BNE $89F0                 
89E5  A9 20    LDA #$20                  
89E7  9D 20 06 STA $0620,X               
89EA  A9 0A    LDA #$0A                  
89EC  85 F1    STA $F1                   
89EE  A9 FF    LDA #$FF                  

loc_89F0:  ; xrefs(1): $89E3
89F0  9D 00 06 STA $0600,X               
89F3  A9 FF    LDA #$FF                  
89F5  60       RTS                       

loc_89F6:  ; xrefs(1): $89DA
89F6  9D F0 06 STA $06F0,X               
89F9  E0 0C    CPX #$0C                  
89FB  D0 04    BNE $8A01                 
89FD  A9 33    LDA #$33                  
89FF  85 F1    STA $F1                   

loc_8A01:  ; xrefs(1): $89FB
8A01  60       RTS                       

; ---- data $8A02-$8A12 (17 bytes) ----
8A02  E0 0F D0 0D A9 00 9D E0 06 BD 00 06 09 80 9D 00  |................
8A12  06                                               |.

loc_8A13:  ; xrefs(1): $89AA
8A13  A9 FF    LDA #$FF                  
8A15  60       RTS                       

loc_8A16:  ; xrefs(2): $89A5 $89CB
8A16  A9 00    LDA #$00                  
8A18  60       RTS                       

; ---- data $8A19-$93B4 (2460 bytes) ----
8A19  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8A29  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8A39  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8A49  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8A59  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8A69  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8A79  00 00 00 00 81 07 81 07 81 07 81 07 81 07 81 07  |................
8A89  82 07 82 07 82 07 82 07 82 07 82 07 84 07 84 07  |................
8A99  83 07 83 07 00 00 00 00 85 07 85 07 86 07 86 07  |................
8AA9  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8AB9  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8AC9  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8AD9  00 00 00 00 00 00 00 00 01 01 01 01 01 01 01 01  |................
8AE9  01 01 01 01 01 01 01 01 01 02 01 02 01 02 01 02  |................
8AF9  01 02 01 02 01 01 01 01 01 01 01 01 01 01 01 01  |................
8B09  01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01  |................
8B19  01 01 01 01 01 01 01 01 01 01 01 01 01 02 01 02  |................
8B29  01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02  |................
8B39  01 02 01 02 01 03 01 03 01 04 01 04 01 03 01 03  |................
8B49  01 03 01 03 01 03 01 03 01 03 01 03 01 03 01 03  |................
8B59  01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01  |................
8B69  01 01 01 01 01 01 01 01 01 02 01 02 01 02 01 02  |................
8B79  01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01  |................
8B89  01 01 01 01 00 00 00 00 00 00 00 00 00 00 00 00  |................
8B99  00 00 00 00 00 00 00 00 01 01 01 01 01 01 01 01  |................
8BA9  01 01 01 01 01 02 01 02 01 02 01 02 01 02 01 02  |................
8BB9  01 01 01 01 01 01 01 01 01 03 01 03 01 03 01 03  |................
8BC9  01 03 01 03 01 01 01 01 01 01 01 01 01 01 01 01  |................
8BD9  01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01  |................
8BE9  01 01 01 01 01 02 01 02 01 01 01 01 01 01 01 01  |................
8BF9  01 03 01 03 01 04 01 04 01 03 01 03 01 03 01 03  |................
8C09  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8C19  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8C29  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8C39  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8C49  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8C59  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8C69  00 00 00 00 00 00 00 00 01 00 01 00 01 00 01 00  |................
8C79  01 00 01 00 01 00 01 00 01 00 01 00 01 00 01 00  |................
8C89  01 00 01 00 01 00 01 00 01 00 01 00 01 00 01 00  |................
8C99  01 00 01 00 01 00 01 00 01 00 01 00 01 00 01 00  |................
8CA9  01 00 01 00 01 00 01 00 01 00 01 00 01 00 01 00  |................
8CB9  01 00 01 00 01 00 01 00 01 00 01 00 01 00 01 00  |................
8CC9  01 00 01 00 01 00 01 00 01 00 01 00 02 00 02 00  |................
8CD9  01 00 01 00 01 00 01 00 01 00 01 00 00 00 00 00  |................
8CE9  00 00 00 00 00 00 00 00 00 00 00 00 41 06 41 06  |............A.A.
8CF9  01 01 01 01 01 01 01 01 01 01 01 01 02 01 02 01  |................
8D09  01 33 01 33 40 0F 40 0F 01 00 01 00 02 00 02 00  |.3.3@.@.........
8D19  02 00 02 00 04 00 04 00 00 00 00 00 00 00 00 00  |................
8D29  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8D39  41 05 41 05 00 00 00 00 00 00 00 00 00 00 00 00  |A.A.............
8D49  00 00 00 00 00 00 00 00 21 08 21 08 21 08 21 08  |........!.!.!.!.
8D59  21 08 21 08 21 08 21 08 00 00 00 00 01 09 01 09  |!.!.!.!.........
8D69  01 09 01 09 01 09 01 09 01 09 01 09 01 09 01 09  |................
8D79  00 00 00 00 01 0A 01 0A 01 0A 01 0A 01 0B 01 0B  |................
8D89  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8D99  01 0B 01 0B 01 0B 01 0B 01 0D 01 0C 01 0D 01 0C  |................
8DA9  01 0D 01 0C 21 31 21 32 21 31 21 32 21 31 21 32  |....!1!2!1!2!1!2
8DB9  01 10 01 10 01 10 01 10 01 10 01 10 04 00 04 00  |................
8DC9  02 00 02 00 01 00 01 00 00 00 00 00 00 00 00 00  |................
8DD9  00 00 00 00 00 00 00 00 41 11 41 11 00 00 00 00  |........A.A.....
8DE9  01 04 01 04 01 04 01 04 01 04 01 04 01 04 01 04  |................
8DF9  01 04 01 04 01 04 01 04 01 04 01 04 00 00 00 00  |................
8E09  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8E19  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8E29  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8E39  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8E49  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8E59  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8E69  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8E79  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8E89  00 00 00 00 00 00 00 00 00 00 00 00 01 12 01 12  |................
8E99  01 12 01 12 01 12 01 12 01 12 01 12 01 12 01 12  |................
8EA9  01 12 01 12 01 12 01 12 01 12 01 12 01 12 01 12  |................
8EB9  01 12 01 12 01 12 01 12 01 12 01 12 00 00 00 00  |................
8EC9  2F 13 2F 13 2F 14 2F 14 00 00 00 00 00 00 00 00  |/./././.........
8ED9  00 00 00 00 00 00 00 00 01 15 01 15 01 15 01 15  |................
8EE9  00 00 00 00 01 15 01 15 01 15 01 15 01 15 01 15  |................
8EF9  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8F09  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
8F19  01 16 01 16 01 16 01 16 01 16 01 16 01 16 01 16  |................
8F29  01 16 01 16 01 16 01 16 01 16 01 16 01 16 01 16  |................
8F39  01 16 01 16 21 1A 21 1A 00 00 00 00 00 00 00 00  |....!.!.........
8F49  00 00 00 00 00 00 21 17 21 18 21 18 21 18 21 18  |......!.!.!.!.!.
8F59  21 19 21 19 01 1B 01 1B 01 1B 01 1B 01 1C 01 1C  |!.!.............
8F69  00 00 00 00 01 1C 01 1C 01 1C 01 1C 01 1C 01 1C  |................
8F79  01 1C 01 1C 00 00 00 00 00 00 00 00 00 00 00 00  |................
8F89  00 00 00 00 00 00 00 00 01 00 01 00 01 00 01 00  |................
8F99  01 00 01 00 01 00 01 00 01 00 01 00 01 00 01 00  |................
8FA9  01 00 01 00 01 24 01 24 01 24 01 24 01 24 01 24  |.....$.$.$.$.$.$
8FB9  00 00 00 00 01 24 01 24 01 24 01 24 01 24 01 24  |.....$.$.$.$.$.$
8FC9  01 24 01 24 01 24 01 24 01 24 01 24 01 24 01 24  |.$.$.$.$.$.$.$.$
8FD9  01 24 01 24 01 25 01 25 01 25 01 25 00 00 00 00  |.$.$.%.%.%.%....
8FE9  00 00 00 00 01 1D 01 1E 01 1D 01 1E 01 1D 01 1E  |................
8FF9  01 1D 01 1E 01 1D 01 1E 0F 1F 0F 1F 01 1D 01 1E  |................
9009  01 1D 01 1E 01 1D 01 1E 01 20 01 20 01 20 01 20  |......... . . . 
9019  01 20 01 20 01 21 01 21 01 20 01 20 01 20 01 20  |. . .!.!. . . . 
9029  01 20 01 20 01 20 01 20 01 22 01 22 01 21 01 21  |. . . . .".".!.!
9039  01 20 01 20 01 20 01 20 21 23 21 23 00 00 00 00  |. . . . !#!#....
9049  00 00 00 00 01 24 01 24 00 00 00 00 00 00 00 00  |.....$.$........
9059  00 00 00 00 00 00 00 00 01 20 01 20 01 20 01 20  |......... . . . 
9069  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9079  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9089  01 26 01 26 01 26 01 26 01 26 01 26 01 26 01 26  |.&.&.&.&.&.&.&.&
9099  01 26 01 26 01 27 01 28 21 29 21 2A 01 03 01 03  |.&.&.'.(!)!*....
90A9  01 03 01 03 01 03 01 03 01 01 01 01 01 01 01 01  |................
90B9  01 01 01 01 01 01 01 01 01 01 01 01 01 01 01 01  |................
90C9  01 01 01 01 01 01 01 01 01 01 01 01 01 15 01 15  |................
90D9  01 15 01 15 01 15 01 15 01 25 01 25 01 25 01 25  |.........%.%.%.%
90E9  01 2B 01 2B 01 2B 01 2B 01 2B 01 2B 01 2B 01 2B  |.+.+.+.+.+.+.+.+
90F9  01 1B 01 1B 01 1B 01 1B 01 1B 01 1B 01 25 01 25  |.............%.%
9109  01 25 01 25 01 2C 01 2C 01 2C 01 2C 01 2C 01 2C  |.%.%.,.,.,.,.,.,
9119  01 2C 01 2C 01 25 01 25 01 2E 01 2E 01 2E 01 2E  |.,.,.%.%........
9129  01 25 01 25 01 25 01 25 01 09 01 09 01 09 01 09  |.%.%.%.%........
9139  01 09 01 09 00 00 00 00 00 00 00 00 00 00 00 00  |................
9149  00 00 00 00 21 2F 21 2F 21 2F 21 2F 21 30 21 30  |....!/!/!/!/!0!0
9159  21 30 21 30 21 30 21 30 21 30 21 30 21 30 21 30  |!0!0!0!0!0!0!0!0
9169  21 30 21 30 00 00 00 00 21 25 21 25 21 25 21 25  |!0!0....!%!%!%!%
9179  21 25 21 25 21 25 21 25 00 00 00 00 01 0A 01 0A  |!%!%!%!%........
9189  01 0A 01 0A 01 0A 01 0A 00 00 00 00 00 00 00 00  |................
9199  00 00 00 00 01 0A 01 0A 01 0A 01 0A 01 0A 01 0A  |................
91A9  21 2D 21 2D 01 25 01 25 00 00 00 00 00 00 00 00  |!-!-.%.%........
91B9  00 00 00 00 C0 FF 00 FF 80 00 00 02 C0 FF C0 FF  |................
91C9  80 00 40 01 C0 FF 80 FF 80 00 80 01 80 FF 40 FF  |..@...........@.
91D9  80 00 80 01 10 FF 00 FD F0 01 F0 05 10 FF 10 FE  |................
91E9  F0 01 F0 03 C0 FF C0 FF 80 00 80 00 00 FF 00 FF  |................
91F9  00 02 00 02 90 FF 10 FF 00 01 00 02 A0 FF A0 FF  |................
9209  C0 00 C0 00 00 FF E0 FE 00 02 E0 00 E0 FF 40 FF  |..............@.
9219  20 01 80 01 20 FF 40 FF 20 01 80 01 20 FF 00 FF  | ... .@. ... ...
9229  C0 01 E0 00 C0 FF 00 00 80 00 00 03 80 FF 40 FD  |..............@.
9239  00 01 C0 03 00 FF 00 FF 00 02 00 02 C0 FF 80 FE  |................
9249  80 00 00 02 00 FE 80 FE 80 02 00 01 80 FF 80 FE  |................
9259  80 02 00 01 A0 FF 00 FF C0 00 00 02 80 FF 80 FE  |................
9269  00 01 00 02 C0 FF 00 FE 80 00 00 02 C0 FF 00 FD  |................
9279  80 00 00 03 C0 FF 00 FC 80 00 00 04 C0 FF 80 FF  |................
9289  80 00 80 01 C0 FF 80 FE 80 00 80 01 C0 FF 00 FF  |................
9299  80 00 80 01 80 FE 00 FF 80 01 00 02 00 00 00 FF  |................
92A9  80 01 00 02 00 FF 80 FF 00 02 20 01 A0 FF 80 FE  |.......... .....
92B9  C0 00 00 02 A0 FF 00 FF C0 00 80 01 A0 FF 00 FF  |................
92C9  C0 00 00 02 A0 FF 80 FF C0 00 00 01 40 FF 00 FF  |............@...
92D9  80 01 00 02 80 FF 80 FF 00 01 00 01 80 FF 00 FF  |................
92E9  00 01 00 02 00 FE 00 FF 80 02 00 02 80 FF 00 FF  |................
92F9  80 02 00 02 70 01 10 01 80 00 80 00 C0 FE 10 01  |....p...........
9309  80 00 80 00 80 FF 80 FE 00 01 00 02 C0 FE 80 FF  |................
9319  80 02 00 01 90 FF 50 FF E0 00 60 01 C0 FF 80 FF  |......P...`.....
9329  80 00 00 01 C0 FF C0 FE 80 00 C0 01 C0 FF 80 FC  |................
9339  80 00 80 03 80 FE B0 FF 80 01 A0 00 00 00 B0 FF  |................
9349  80 01 A0 00 FF FF FF FF 02 00 02 00 AD 00 06 D0  |................
9359  16 AD FA 05 D0 03 EE FA 05 AD FA 05 20 25 80 70  |............ %.p
9369  93 71 93 85 93 98 93 60 AD A2 05 F0 04 C9 08 D0  |.q.....`........
9379  08 A9 00 8D AB 05 EE FA 05 4C 73 9E CE AB 05 D0  |.........Ls.....
9389  0B A9 01 85 26 A9 FF 85 27 EE FA 05 4C 73 9E A5  |....&...'...Ls..
9399  26 D0 16 8D 0C 06 8D C2 05 A9 10 85 F0 A5 0D F0  |&...............
93A9  04 A9 24 D0 02 A9 1B 85 02 4C 73 9E              |..$......Ls.

loc_93B5:  ; xrefs(0): 
93B5  18       CLC                       
93B6  A5 31    LDA $31                   
93B8  69 08    ADC #$08                  
93BA  4A       LSR A                     
93BB  4A       LSR A                     
93BC  4A       LSR A                     
93BD  4A       LSR A                     
93BE  85 90    STA $90                   
93C0  18       CLC                       
93C1  A5 33    LDA $33                   
93C3  69 08    ADC #$08                  
93C5  29 F0    AND #$F0                  
93C7  18       CLC                       
93C8  65 90    ADC $90                   
93CA  A8       TAY                       
93CB  CD EB 05 CMP $05EB                 
93CE  F0 07    BEQ $93D7                 
93D0  8D EB 05 STA $05EB                 
93D3  A9 00    LDA #$00                  
93D5  85 7F    STA $7F                   

loc_93D7:  ; xrefs(1): $93CE
93D7  A5 55    LDA $55                   
93D9  0A       ASL A                     
93DA  AA       TAX                       
93DB  BD E8 93 LDA $93E8,X               
93DE  85 90    STA $90                   
93E0  BD E9 93 LDA $93E9,X               
93E3  85 91    STA $91                   
93E5  6C 90 00 JMP ($0090)               

; ---- data $93E8-$AE68 (6785 bytes) ----
93E8  10 94 A2 94 A2 94 C4 94 64 94 64 94 04 95 04 95  |........d.d.....
93F8  10 94 C4 94 DE 94 DE 94 04 95 88 94 DE 94 32 94  |..............2.
9408  32 94 64 94 C4 94 32 94 B9 7E 95 0A AA BD 22 94  |2.d...2..~....".
9418  85 90 BD 23 94 85 91 6C 90 00 AE AA BF AA D4 AA  |...#...l........
9428  E9 AA FE AA 13 AB 28 AB 94 AD B9 67 96 0A AA BD  |......(....g....
9438  44 94 85 90 BD 45 94 85 91 6C 90 00 BE 99 2F 99  |D....E...l..../.
9448  5A 99 6F 99 8C 99 23 9D 43 9D 85 9D C1 99 A0 9A  |Z.o...#.C.......
9458  E8 9B C5 9B 99 9B F9 9D 9A 9D 44 99 B9 00 97 0A  |..........D.....
9468  AA BD 76 94 85 90 BD 77 94 85 91 6C 90 00 A9 AA  |..v....w...l....
9478  2F A3 44 A3 73 A3 88 A3 AF A3 B0 A7 6E AA 4F A7  |/.D.s.......n.O.
9488  B9 C9 97 0A AA BD 9A 94 85 90 BD 9B 94 85 91 6C  |...............l
9498  90 00 AE AA 9A A8 E5 A8 4B A9 B9 79 97 0A AA BD  |........K..y....
94A8  B4 94 85 90 BD B5 94 85 91 6C 90 00 AE AA 35 A8  |.........l....5.
94B8  67 A8 7C A8 EB A8 46 AA C6 A9 67 A9 B9 34 95 0A  |g.|...F...g..4..
94C8  AA BD D6 94 85 90 BD D7 94 85 91 6C 90 00 58 AE  |...........l..X.
94D8  52 A2 3F A1 6F A2 B9 AF 98 0A AA BD F0 94 85 90  |R.?.o...........
94E8  BD F1 94 85 91 6C 90 00 58 AE DA A0 EF A0 FC A0  |.....l..X.......
94F8  09 A1 1E A1 CE A2 38 AE CF AD 2E AE B9 FB 95 0A  |......8.........
9508  AA BD 16 95 85 90 BD 17 95 85 91 6C 90 00 B0 A7  |...........l....
9518  26 A4 8D A5 8D A5 16 A6 3C A6 FB A6 EB A3 98 A5  |&.......<.......
9528  D7 A5 0A A4 F8 A6 CD A3 EC AC 7C A6 00 00 00 00  |..........|.....
9538  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9548  00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00  |................
9558  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9568  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9578  00 00 00 00 03 02 00 00 00 00 00 00 00 00 00 00  |................
9588  00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00  |................
9598  00 00 00 07 00 00 00 00 00 00 00 02 00 00 03 00  |................
95A8  00 00 00 07 00 00 00 00 00 00 00 00 00 00 00 00  |................
95B8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00  |................
95C8  00 00 05 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
95D8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
95E8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
95F8  00 00 06 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9608  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0C  |................
9618  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9628  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9638  00 00 00 00 00 07 01 00 02 08 00 00 00 00 00 00  |................
9648  00 00 00 00 00 00 0A 04 03 09 00 00 00 00 00 00  |................
9658  00 00 00 00 00 00 05 06 0B 06 06 0E 00 00 0D 00  |................
9668  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9678  00 00 00 00 00 00 00 00 00 00 00 0E 00 00 00 00  |................
9688  00 0D 0D 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9698  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
96A8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
96B8  00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00  |................
96C8  00 00 00 00 00 0F 00 06 0B 0A 0C 07 00 00 00 00  |................
96D8  03 00 08 00 00 02 00 0B 00 00 00 00 00 00 00 00  |................
96E8  00 00 00 00 00 00 00 0B 00 00 00 00 00 00 00 00  |................
96F8  04 00 00 00 09 0B 0B 05 00 00 00 00 00 00 00 00  |................
9708  00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00  |................
9718  00 03 00 00 00 00 00 00 00 00 00 00 00 00 01 00  |................
9728  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9738  00 04 05 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9748  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9758  00 00 00 00 00 00 00 00 00 06 06 06 06 06 06 06  |................
9768  08 00 00 00 07 00 00 00 00 06 06 06 06 06 06 06  |................
9778  06 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9788  00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00  |................
9798  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
97A8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
97B8  00 00 00 00 06 00 07 00 02 00 00 00 00 00 00 03  |................
97C8  00 00 00 00 05 00 00 00 00 00 00 00 00 00 00 00  |................
97D8  00 00 00 00 05 00 03 00 00 00 00 00 00 00 00 00  |................
97E8  00 00 00 00 05 00 02 00 00 00 00 00 00 00 00 00  |................
97F8  00 00 00 00 05 00 02 00 00 00 00 00 00 00 00 00  |................
9808  00 00 00 00 05 00 02 00 00 00 00 00 00 00 00 00  |................
9818  00 00 00 00 05 00 02 00 00 00 00 00 00 00 00 00  |................
9828  00 00 00 00 05 00 02 00 00 00 00 00 00 00 00 00  |................
9838  00 00 00 00 05 00 02 00 00 00 00 00 00 00 00 00  |................
9848  00 00 00 00 05 00 02 00 00 00 00 00 00 00 00 00  |................
9858  00 00 00 00 04 00 02 00 00 00 00 00 00 00 00 00  |................
9868  00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00  |................
9878  00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00  |................
9888  00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00  |................
9898  00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00  |................
98A8  00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00  |................
98B8  00 00 00 00 00 00 00 00 07 07 07 07 07 07 09 05  |................
98C8  07 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
98D8  00 00 00 00 00 00 00 00 00 00 00 06 00 00 00 00  |................
98E8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
98F8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9908  00 00 00 00 00 00 00 00 01 00 00 00 00 00 08 00  |................
9918  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |................
9928  00 00 00 00 00 00 00 A5 31 C9 60 D0 0C 85 39 A9  |........1.`...9.
9938  80 85 3F A9 00 85 38 85 3E 4C 58 AE A5 45 C9 73  |..?...8.>LX..E.s
9948  F0 0D A5 33 C9 60 D0 07 20 A5 99 A9 73 85 45 4C  |...3.`.. ...s.EL
9958  58 AE A5 33 C9 70 D0 0C 85 3D A9 30 85 39 A9 00  |X..3.p...=.0.9..
9968  85 38 85 3E 4C 58 AE A5 30 29 C0 D0 14 A5 31 C9  |.8.>LX..0)....1.
9978  10 D0 0E A9 20 85 3B A9 A0 85 3F A9 00 85 38 85  |.... .;...?...8.
9988  3E 4C 58 AE A5 33 C9 90 D0 10 C5 3D F0 0C 85 3D  |>LX..3.....=...=
9998  A9 60 85 3B 20 6E 9D 20 A5 99 4C 58 AE A2 0B BD  |.`.; n. ..LX....
99A8  00 06 F0 0E B5 D0 C5 33 B0 08 BD 50 06 09 80 9D  |.......3...P....
99B8  50 06 CA 10 EA 60 4C 58 AE A5 7F 0A AA BD D2 99  |P....`LX........
99C8  85 90 BD D3 99 85 91 6C 90 00 17 9A 0A 9A E4 99  |.......l........
99D8  0D 9A 4E 9A 53 9A 9A 9A 7D 9A 9D 9A A9 08 85 9D  |..N.S...}.......
99E8  20 40 80 A2 00 A9 3C 85 91 A9 70 85 93 A9 41 20  | @....<...p...A 
99F8  20 AF A9 75 85 44 20 66 C0 A9 06 A0 FF 20 4B 80  | ..u.D f..... K.
9A08  E6 7F 4C 58 AE AD 00 06 D0 02 E6 7F 4C AE AA A5  |..LX........L...
9A18  39 C9 10 F0 2E A5 30 29 C0 D0 28 A5 31 C9 30 D0  |9.....0)..(.1.0.
9A28  22 A9 40 85 3B A9 00 85 38 20 52 9E 20 5D 9E A9  |".@.;...8 R. ]..
9A38  3F 85 91 A9 76 85 93 20 6C A4 30 07 A9 06 9D 40  |?...v.. l.0....@
9A48  06 E6 7F 4C 58 AE E6 7F 4C 58 AE 20 6F C0 A9 06  |...LX...LX. o...
9A58  A0 FF 20 4B 80 A9 30 85 91 A9 7B 85 93 20 6C A4  |.. K..0...{.. l.
9A68  30 10 A9 AE 9D 50 06 A9 06 9D 40 06 A9 10 85 39  |0....P....@....9
9A78  E6 7F 4C 58 AE 38 A5 81 E5 31 90 16 C9 07 B0 0C  |..LX.8...1......
9A88  A5 30 E9 3F 85 30 B0 0A C6 31 90 06 A9 70 85 44  |.0.?.0...1...p.D
9A98  E6 7F 20 73 9E 4C 58 AE A5 7F 0A AA BD B1 9A 85  |.. s.LX.........
9AA8  90 BD B2 9A 85 91 6C 90 00 E4 9A 1A 9B 27 9B 4E  |......l......'.N
9AB8  9B 58 9B 67 9B C1 9A 1D 9B 38 A5 81 E5 31 90 16  |.X.g.....8...1..
9AC8  C9 09 90 0C A5 30 69 3F 85 30 90 0A E6 31 B0 06  |.....0i?.0...1..
9AD8  A9 70 85 44 E6 7F 20 73 9E 4C 1D 9B A5 3B C9 90  |.p.D.. s.L...;..
9AE8  F0 33 A5 31 C9 50 D0 2A 85 39 A9 00 85 38 20 52  |.3.1.P.*.9...8 R
9AF8  9E 20 5D 9E A9 50 85 91 A9 96 85 93 20 6C A4 30  |. ]..P...... l.0
9B08  11 A9 06 9D 40 06 20 69 C0 A9 06 A0 FF 20 4B 80  |....@. i..... K.
9B18  E6 7F 4C 58 AE 20 C8 9B A9 90 85 3B 4C 58 AE A9  |..LX. .....;LX..
9B28  BD 85 75 A9 10 85 9D 20 40 80 A2 00 A9 58 85 91  |..u.... @....X..
9B38  A9 90 85 93 A9 41 20 20 AF AD 80 06 49 FF 8D 80  |.....A  ....I...
9B48  06 E6 7F 4C 58 AE AD 00 06 D0 02 E6 7F 4C 58 AE  |...LX........LX.
9B58  E6 7F 20 60 C0 A9 06 A0 FF 20 4B 80 4C 58 AE 20  |.. `..... K.LX. 
9B68  52 9E 20 5D 9E A9 5F 85 91 A9 9B 85 93 20 6C A4  |R. ].._...... l.
9B78  30 1C A9 97 9D 50 06 A9 06 9D 40 06 A5 09 09 20  |0....P....@.... 
9B88  85 09 20 60 C0 A9 06 A0 FF 20 4B 80 E6 7F 4C 58  |.. `..... K...LX
9B98  AE A9 B0 C5 31 D0 23 C5 39 F0 1F 85 39 A9 00 85  |....1.#.9...9...
9BA8  38 A9 10 85 55 20 5D C0 A9 3C 85 40 A9 FF 8D 4D  |8...U ]..<.@...M
9BB8  05 8D 4E 05 8D 4F 05 8D 46 05 4C 58 AE 20 58 AE  |..N..O..F.LX. X.
9BC8  AD A2 05 C9 01 D0 16 AD AC 05 CD EA 05 D0 0E EE  |................
9BD8  AC 05 AD CB 05 49 80 20 37 A7 8D CB 05 4C 22 A7  |.....I. 7....L".
9BE8  A5 7F 0A AA BD F9 9B 85 90 BD FA 9B 85 91 6C 90  |..............l.
9BF8  00 28 9C 69 9C 73 9C 99 9C CE 9C E5 9C 09 9C 6C  |.(.i.s.........l
9C08  9C 38 A5 81 E5 31 90 12 C9 09 90 0C A5 30 69 3F  |.8...1.......0i?
9C18  85 30 90 06 E6 31 B0 02 E6 7F 20 73 9E 4C 6C 9C  |.0...1.... s.Ll.
9C28  A5 3B C9 D0 F0 3E 20 AA 9C A9 60 85 45 A9 6B 85  |.;...> ...`.E.k.
9C38  44 A5 31 C9 A0 D0 2A 85 39 A9 00 85 38 20 52 9E  |D.1...*.9...8 R.
9C48  20 5D 9E A9 A0 85 91 A9 66 85 93 20 6C A4 30 11  | ]......f.. l.0.
9C58  A9 06 9D 40 06 20 6C C0 A9 06 A0 FF 20 4B 80 E6  |...@. l..... K..
9C68  7F 4C 58 AE A9 D0 85 3B 4C 58 AE 20 AA 9C 20 5A  |.LX....;LX. .. Z
9C78  C0 A9 05 8D 99 03 A9 09 85 9D 20 40 80 A2 00 A9  |.......... @....
9C88  A8 85 91 A9 5E 85 93 A9 41 20 20 AF E6 7F 4C 58  |....^...A  ...LX
9C98  AE AD 99 03 C9 05 D0 03 20 AA 9C A9 00 85 7D 4C  |........ .....}L
9CA8  0D 9A A9 06 85 5B AD A2 05 C9 01 D0 16 AD AC 05  |.....[..........
9CB8  CD EA 05 D0 0E EE AC 05 AD CB 05 49 80 20 37 A7  |...........I. 7.
9CC8  8D CB 05 4C 22 A7 E6 7F 20 63 C0 A9 06 A0 FF 20  |...L"... c..... 
9CD8  4B 80 AD CB 05 29 7F 8D CB 05 4C 58 AE 20 52 9E  |K....)....LX. R.
9CE8  20 5D 9E A9 AF 85 91 A9 6B 85 93 20 6C A4 30 28  | ]......k.. l.0(
9CF8  A9 97 9D 50 06 A9 06 9D 40 06 A5 09 29 DF 85 09  |...P....@...)...
9D08  E6 7F A9 10 85 55 A2 3F A9 01 9D 60 05 CA 10 F8  |.....U.?...`....
9D18  A9 70 85 44 A9 7A 85 45 4C 58 AE 20 C8 9B A9 80  |.p.D.z.ELX. ....
9D28  C5 31 D0 14 C5 39 F0 10 85 39 A9 60 85 3D A9 00  |.1...9...9.`.=..
9D38  85 38 85 3E A9 70 85 44 4C 58 AE 20 C8 9B A0 90  |.8.>.p.DLX. ....
9D48  A9 A0 A6 83 E0 67 F0 04 B0 15 90 06 A6 82 E0 80  |.....g..........
9D58  B0 0D A6 81 E0 87 90 07 20 6E 9D A0 B0 A9 70 85  |........ n....p.
9D68  3F 84 3B 4C 58 AE A9 00 85 38 85 3E AD 4E 05 09  |?.;LX....8.>.N..
9D78  39 8D 4E 05 AD 4F 05 09 80 8D 4F 05 60 A5 31 C9  |9.N..O....O.`.1.
9D88  C0 D0 0C 85 39 A9 10 85 3D A9 00 85 38 85 3C 4C  |....9...=...8.<L
9D98  58 AE A5 7F 0A AA BD AB 9D 85 90 BD AC 9D 85 91  |X...............
9DA8  6C 90 00 BF 9D B3 9D B9 9D E8 9D 20 E2 AB 4C 58  |l.......... ..LX
9DB8  AE 20 96 AC 4C 58 AE AD C5 05 F0 21 20 50 80 C9  |. ..LX.....! P..
9DC8  CB D0 1A A5 83 C9 16 D0 14 AD A2 05 D0 0F 20 6A  |.............. j
9DD8  AB F0 0A A9 0F 85 F0 A9 05 85 F1 E6 7F 4C 58 AE  |.............LX.
9DE8  20 73 9E A5 26 D0 07 20 B1 AC A9 13 85 55 4C 58  | s..&.. .....ULX
9DF8  AE A5 58 0A AA BD 0A 9E 85 90 BD 0B 9E 85 91 6C  |..X............l
9E08  90 00 5B A0 91 A0 A6 A0 BF A0 D0 A0 84 9E 9C 9E  |..[.............
9E18  B5 9E E1 9E F8 9E 14 9F 23 9F 33 9F 4E 9F 64 9F  |........#.3.N.d.
9E28  74 9F 95 9F AD 9F C4 9F D5 9F F4 9F A5 A0 E5 80  |t...............
9E38  85 90 A5 B0 E5 81 85 91 8D B2 05 10 0C A9 00 E5  |................
9E48  90 85 90 A9 00 E5 91 85 91 60 A9 00 A2 0B 9D 00  |.........`......
9E58  06 CA 10 FA 60 A9 00 A2 0F 9D 80 07 CA 10 FA 60  |....`..........`
9E68  A9 00 A2 0A 9D 00 07 CA 10 FA 60 AD C5 05 F0 05  |..........`.....
9E78  A9 1F 8D A3 05 A9 00 85 06 85 04 60 A9 FF 85 F8  |...........`....
9E88  A9 70 85 57 E6 58 A9 0F 8D 90 06 20 34 9E 20 73  |.p.W.X..... 4. s
9E98  9E 4C 58 AE AD 90 06 C9 11 90 09 C6 57 D0 05 E6  |.LX.........W...
9EA8  58 EE 90 06 20 34 9E 20 73 9E 4C 58 AE 20 73 9E  |X... 4. s.LX. s.
9EB8  20 34 9E A0 01 AD B2 05 10 01 C8 84 06 A5 91 C9  | 4..............
9EC8  02 B0 13 A5 90 C9 80 B0 0D E6 58 EE 90 06 A9 10  |..........X.....
9ED8  85 57 A9 40 85 04 4C 58 AE 20 73 9E C6 57 D0 0A  |.W.@..LX. s..W..
9EE8  E6 58 A9 10 85 57 A9 40 85 04 20 34 9E 4C 58 AE  |.X...W.@.. 4.LX.
9EF8  20 73 9E C6 57 D0 0F E6 58 A9 10 85 57 A9 40 85  | s..W...X...W.@.
9F08  04 A9 02 8D CE 05 20 34 9E 4C 58 AE 20 73 9E C6  |...... 4.LX. s..
9F18  57 D0 02 E6 58 20 34 9E 4C 58 AE A9 14 8D 90 06  |W...X 4.LX......
9F28  E6 58 20 34 9E 20 73 9E 4C 58 AE 38 A5 D0 E5 33  |.X 4. s.LX.8...3
9F38  C9 10 90 09 A9 00 85 57 E6 58 EE 90 06 20 34 9E  |.......W.X... 4.
9F48  20 73 9E 4C 58 AE C6 57 D0 09 A9 00 85 57 EE 90  | s.LX..W.....W..
9F58  06 E6 58 20 34 9E 20 73 9E 4C 58 AE C6 57 D0 06  |..X 4. s.LX..W..
9F68  A9 C0 85 57 E6 58 20 73 9E 4C 58 AE A5 0C 6A B0  |...W.X s.LX...j.
9F78  0D C6 57 D0 09 A9 00 85 57 EE 90 06 E6 58 A5 0C  |..W.....W....X..
9F88  29 A0 D0 03 20 08 A0 20 73 9E 4C 58 AE A5 0C 6A  |)... .. s.LX...j
9F98  90 0A C6 57 D0 06 A9 18 85 57 E6 58 20 08 A0 20  |...W.....W.X .. 
9FA8  73 9E 4C 58 AE 20 73 9E A9 04 85 06 C6 57 D0 06  |s.LX. s......W..
9FB8  A9 3D 85 F1 E6 58 20 08 A0 4C 58 AE 20 26 A0 B0  |.=...X ..LX. &..
9FC8  06 A9 20 85 57 E6 58 20 08 A0 4C 58 AE 20 26 A0  |.. .W.X ..LX. &.
9FD8  C6 57 D0 0F A9 1E 85 28 85 25 A9 01 A0 FF 20 4B  |.W.....(.%.... K
9FE8  80 E6 58 20 08 A0 20 73 9E 4C 58 AE A5 26 D0 04  |..X .. s.LX..&..
9FF8  A9 4C 85 02 20 26 A0 20 08 A0 20 73 9E 4C 58 AE  |.L.. &. .. s.LX.
A008  A5 0E 29 03 D0 17 A5 0E 29 07 D0 04 A9 3C 85 F1  |..).....)....<..
A018  A5 0E 4A 4A 4A 18 29 03 69 04 8D F7 05 60 20 73  |..JJJ.).i....` s
A028  9E A9 80 85 06 85 04 A9 0C 8D EA 05 A9 40 8D AD  |.............@..
A038  05 A9 FF 8D AE 05 A9 80 8D C9 05 A9 01 8D A2 05  |................
A048  8D AC 05 A5 83 C9 21 B0 09 A9 10 85 83 A9 20 8D  |......!....... .
A058  A3 05 60 AD A2 05 D0 2E A9 11 85 9D 20 40 80 A2  |..`......... @..
A068  00 A9 37 85 91 A9 2A 85 93 A9 41 20 20 AF A9 12  |..7...*...A  ...
A078  85 9D 20 40 80 A2 0B A9 37 85 91 A9 2A 85 93 A9  |.. @....7...*...
A088  41 20 20 AF E6 58 4C 58 AE A5 81 C9 2C 90 04 E6  |A  ..XLX....,...
A098  58 D0 08 A9 00 85 04 A9 01 85 06 4C 58 AE 20 7D  |X..........LX. }
A0A8  9E 18 A5 30 69 10 85 30 90 02 E6 31 A5 31 C9 2A  |...0i..0...1.1.*
A0B8  D0 02 E6 58 4C 58 AE AD 50 06 29 3F C9 2F F0 02  |...XLX..P.)?./..
A0C8  E6 58 20 7D 9E 4C 58 AE AD 50 06 10 02 E6 58 4C  |.X }.LX..P....XL
A0D8  58 AE A5 33 C9 60 D0 0C 85 3D A9 80 85 3B A9 00  |X..3.`...=...;..
A0E8  85 3C 85 3A 4C 58 AE A9 11 8D 0A 01 A9 33 8D 0B  |.<.:LX.......3..
A0F8  01 4C 58 AE A9 00 8D 0A 01 A9 20 8D 0B 01 4C 58  |.LX....... ...LX
A108  AE A5 33 C9 40 D0 0C 85 3D A9 90 85 3B A9 00 85  |..3.@...=...;...
A118  38 85 3E 4C 58 AE AD C5 05 F0 19 A5 81 C9 8E 90  |8.>LX...........
A128  13 A9 00 85 7D A9 35 85 02 A9 03 A0 CF 20 4B 80  |....}.5...... K.
A138  A9 0B 85 55 4C 58 AE A5 7F 0A AA BD 50 A1 85 90  |...ULX......P...
A148  BD 51 A1 85 91 6C 90 00 69 A1 A8 A1 B8 A1 DB A1  |.Q...l..i.......
A158  1A A2 37 A2 5E A1 AD 01 06 D0 03 20 55 93 4C 58  |..7.^...... U.LX
A168  AE AD A2 05 D0 37 A9 0B 85 9D 20 40 80 A2 00 A9  |.....7.... @....
A178  9B 85 91 A9 40 85 93 A9 41 20 20 AF A9 0B 85 9D  |....@...A  .....
A188  A2 01 20 40 80 A9 94 85 91 A9 40 85 93 A9 41 20  |.. @......@...A 
A198  20 AF A9 FF 9D 10 06 A9 01 85 58 E6 7F 4C 58 AE  | .........X..LX.
A1A8  A5 0C 6A 90 02 E6 58 A5 58 D0 02 E6 7F 4C 58 AE  |..j...X.X....LX.
A1B8  AD 00 06 F0 0A AD 50 06 30 05 AD 90 06 10 11 AD  |......P.0.......
A1C8  01 06 F0 0A AD 51 06 30 05 AD 91 06 10 02 E6 7F  |.....Q.0........
A1D8  4C 58 AE AD 00 06 F0 13 AD 50 06 30 0E AD 90 06  |LX.......P.0....
A1E8  29 7F C9 08 D0 29 AD C0 06 10 24 AD 01 06 F0 17  |)....)....$.....
A1F8  AD 51 06 30 12 AD 91 06 29 7F C9 08 D0 11 AD C1  |.Q.0....).......
A208  06 10 0C A9 38 85 F1 E6 7F EE 90 06 EE 91 06 4C  |....8..........L
A218  58 AE AD 00 06 F0 0C E6 58 A5 58 C9 40 90 0D A9  |X.......X.X.@...
A228  38 85 F1 A9 00 85 58 E6 7F EE 90 06 4C 58 AE AD  |8.....X.....LX..
A238  01 06 F0 0C E6 58 A5 58 C9 20 90 0B A9 38 85 F1  |.....X.X. ...8..
A248  A9 01 85 7F EE 91 06 4C 58 AE AD C5 05 F0 15 A5  |.......LX.......
A258  81 C9 7E 90 0F A9 35 85 02 A9 03 A0 CF 20 4B 80  |..~...5...... K.
A268  A9 09 85 55 4C 58 AE A5 7F 0A AA BD 80 A2 85 90  |...ULX..........
A278  BD 81 A2 85 91 6C 90 00 94 A2 88 A2 8E A2 BD A2  |.....l..........
A288  20 E2 AB 4C 58 AE 20 96 AC 4C 58 AE AD C5 05 F0  | ..LX. ..LX.....
A298  21 20 50 80 C9 8D D0 1A A5 83 C9 46 D0 14 AD A2  |! P........F....
A2A8  05 D0 0F 20 6A AB F0 0A A9 0F 85 F0 A9 05 85 F1  |... j...........
A2B8  E6 7F 4C 58 AE 20 73 9E A5 26 D0 07 20 B1 AC A9  |..LX. s..&.. ...
A2C8  12 85 55 4C 58 AE A5 7F 0A AA BD DF A2 85 90 BD  |..ULX...........
A2D8  E0 A2 85 91 6C 90 00 E7 A2 F7 A2 0E A3 29 A3 AD  |....l........)..
A2E8  A2 05 C9 12 B0 06 A9 40 85 58 E6 7F 4C 58 AE C6  |.......@.X..LX..
A2F8  58 D0 02 E6 7F A5 58 C9 20 90 08 29 03 D0 04 A9  |X.....X. ..)....
A308  3A 85 F1 4C 58 AE A9 0E 85 9D 20 40 80 AA A9 3E  |:..LX..... @...>
A318  85 91 A9 34 85 93 A9 41 20 20 AF A9 38 85 F1 E6  |...4...A  ..8...
A328  7F 20 55 93 4C 58 AE A5 31 C9 60 D0 0C 85 39 A9  |. U.LX..1.`...9.
A338  10 85 3D A9 00 85 38 85 3C 4C A9 AA A5 83 C9 18  |..=...8.<L......
A348  A9 31 B0 14 A5 33 C9 10 90 0B 38 A5 32 E9 10 85  |.1...3....8.2...
A358  32 B0 02 C6 33 A9 1F 18 85 3F B0 0C A5 81 C9 67  |2...3....?.....g
A368  A9 A0 B0 02 A9 70 85 3B 4C A9 AA A5 31 C9 90 D0  |.....p.;L...1...
A378  0C 85 39 A9 41 85 3F A9 00 85 38 85 3E 4C A9 AA  |..9.A.?...8.>L..
A388  A5 83 C9 39 B0 0C A5 81 C9 98 B0 18 A0 A0 A9 10  |...9............
A398  D0 0E A5 81 C9 98 90 0C A9 70 85 44 A0 B0 A9 31  |.........p.D...1
A3A8  85 3D 84 3B 4C A9 AA AD C5 05 F0 16 A5 81 C9 AF  |.=.;L...........
A3B8  90 10 A9 35 85 02 A9 03 85 26 A9 CF 85 27 A9 05  |...5.....&...'..
A3C8  85 55 4C A9 AA AD C5 05 F0 16 A5 81 C9 CE 90 10  |.UL.............
A3D8  A9 35 85 02 A9 03 85 26 A9 CF 85 27 A9 07 85 55  |.5.....&...'...U
A3E8  4C 58 AE A0 30 A9 71 A6 83 E0 48 B0 0E A6 81 E0  |LX..0.q...H.....
A3F8  28 90 08 A9 00 85 57 A0 40 A9 51 85 3F 84 3B 4C  |(.....W.@.Q.?.;L
A408  AE AA A5 83 C9 5A D0 03 4C 8D A5 A5 31 C9 30 D0  |.....Z..L...1.0.
A418  0A 85 39 A9 40 85 3B A9 70 85 3F 4C 16 A6 A5 57  |..9.@.;.p.?L...W
A428  C9 01 90 03 4C 8A A5 A5 7F 0A AA BD 40 A4 85 90  |....L.......@...
A438  BD 41 A4 85 91 6C 90 00 4C A4 B5 A4 BB A4 00 A5  |.A...l..L.......
A448  7C A5 8A A5 A9 3C 85 91 A9 48 85 93 A9 3E C5 81  ||....<...H...>..
A458  D0 0F 20 6C A4 30 0A A9 03 85 26 A9 04 85 27 E6  |.. l.0....&...'.
A468  7F 4C AE AA A2 0B BD 00 06 F0 04 CA 10 F8 60 A9  |.L............`.
A478  00 95 A0 95 C0 A5 91 95 B0 A5 93 95 D0 A9 FF 9D  |................
A488  00 06 9D F0 06 A9 96 9D 50 06 A9 04 9D 40 06 A9  |........P....@..
A498  00 9D 10 06 9D 20 06 9D 30 06 9D D0 06 9D C0 06  |..... ..0.......
A4A8  9D A0 06 9D B0 06 9D 60 06 9D 70 06 60 20 73 9E  |.......`..p.` s.
A4B8  4C AE AA 20 73 9E A5 26 D0 29 18 A5 31 69 08 C5  |L.. s..&.)..1i..
A4C8  81 F0 1E 90 0E 38 A5 30 E9 10 85 30 B0 15 C6 31  |.....8.0...0...1
A4D8  4C EB A4 18 A5 30 69 10 85 30 90 07 E6 31 4C EB  |L....0i..0...1L.
A4E8  A4 E6 7F 4C AE AA A9 63 85 91 A9 47 85 93 A9 70  |...L...c...G...p
A4F8  85 3B 20 4B C0 4C 51 A5 A9 3F 85 91 A9 4B 85 93  |.; K.LQ..?...K..
A508  A9 70 85 3B 20 45 C0 4C 51 A5 A9 2C 85 39 A9 60  |.p.; E.LQ..,.9.`
A518  85 91 A9 5B 85 93 20 45 C0 4C 51 A5 A9 20 85 39  |...[.. E.LQ.. .9
A528  A9 3C 85 91 A9 57 85 93 20 4B C0 4C 51 A5 A9 3F  |.<...W.. K.LQ..?
A538  85 91 A9 6B 85 93 A9 60 85 3D A9 90 85 3B 20 48  |...k...`.=...; H
A548  C0 AD CB 05 49 80 8D CB 05 20 73 9E 20 6C A4 30  |....I.... s. l.0
A558  20 A9 97 9D 50 06 A9 06 85 26 A9 04 85 27 E6 7F  | ...P....&...'..
A568  EE AC 05 AD CB 05 49 80 20 37 A7 8D CB 05 20 22  |......I. 7.... "
A578  A7 4C AE AA 20 73 9E A5 26 D0 04 E6 57 E6 7F 4C  |.L.. s..&...W..L
A588  AE AA 4C AE AA A9 FF 8D 49 05 8D 4A 05 4C AE AA  |..L.....I..J.L..
A598  A5 31 C9 60 90 06 85 39 A9 60 85 3F A5 57 C9 02  |.1.`...9.`.?.W..
A5A8  90 03 4C 8A A5 A5 7F 0A AA BD BE A5 85 90 BD BF  |..L.............
A5B8  A5 85 91 6C 90 00 CA A5 B5 A4 BB A4 EE A4 7C A5  |...l..........|.
A5C8  8A A5 A9 60 85 91 A9 44 85 93 A9 62 4C 56 A4 A5  |...`...D...bLV..
A5D8  33 C9 49 D0 03 4C 8D A5 A5 83 C9 58 90 0A A5 81  |3.I..L.....X....
A5E8  C9 68 B0 04 A9 50 85 3D A5 57 C9 03 90 03 4C 8A  |.h...P.=.W....L.
A5F8  A5 A5 7F 0A AA BD 0A A6 85 90 BD 0B A6 85 91 6C  |...............l
A608  90 00 62 A6 B5 A4 BB A4 12 A5 7C A5 8A A5 A5 57  |..b.......|....W
A618  C9 04 90 03 4C 8A A5 A5 7F 0A AA BD 30 A6 85 90  |....L.......0...
A628  BD 31 A6 85 91 6C 90 00 6F A6 B5 A4 BB A4 24 A5  |.1...l..o.....$.
A638  7C A5 8A A5 A5 57 C9 05 90 03 4C 8A A5 A5 7F 0A  ||....W....L.....
A648  AA BD 56 A6 85 90 BD 57 A6 85 91 6C 90 00 E7 A6  |..V....W...l....
A658  B5 A4 BB A4 36 A5 7C A5 FB A6 A9 63 85 91 A9 58  |....6.|....c...X
A668  85 93 A9 61 4C 56 A4 A9 3F 85 91 A9 54 85 93 A9  |...aLV..?...T...
A678  3D 4C 56 A4 A5 7F 0A AA BD 8D A6 85 90 BD 8E A6  |=LV.............
A688  85 91 6C 90 00 A1 A6 95 A6 9B A6 CA A6 20 E2 AB  |..l.......... ..
A698  4C FB A6 20 96 AC 4C FB A6 AD C5 05 F0 21 20 50  |L.. ..L......! P
A6A8  80 C9 8D D0 1A A5 83 C9 6A D0 14 AD A2 05 D0 0F  |........j.......
A6B8  20 6A AB F0 0A A9 0F 85 F0 A9 05 85 F1 E6 7F 4C  | j.............L
A6C8  FB A6 20 73 9E A5 26 D0 13 20 B1 AC A9 0C 85 55  |.. s..&.. .....U
A6D8  A9 E0 85 75 A9 02 85 72 85 73 85 74 4C FB A6 A9  |...u...r.s.tL...
A6E8  90 85 3B A9 3C 85 91 A9 68 85 93 A9 3E 4C 56 A4  |..;.<...h...>LV.
A6F8  20 8D A5 20 01 A7 4C AE AA A9 06 85 5B AD A2 05  | .. ..L.....[...
A708  C9 01 D0 16 AD AC 05 CD EA 05 D0 0E EE AC 05 AD  |................
A718  CB 05 49 80 20 37 A7 8D CB 05 A9 00 8D CD 05 A9  |..I. 7..........
A728  B8 8D E8 05 A9 04 8D E9 05 A9 06 8D EA 05 60 48  |..............`H
A738  4D CB 05 10 10 A9 00 ED AD 05 8D AD 05 A9 00 ED  |M...............
A748  AE 05 8D AE 05 68 60 A5 7F 0A AA BD 60 A7 85 90  |.....h`.....`...
A758  BD 61 A7 85 91 6C 90 00 74 A7 68 A7 6E A7 9F A7  |.a...l..t.h.n...
A768  20 E2 AB 4C B0 A7 20 96 AC 4C B0 A7 AD C5 05 F0  | ..L.. ..L......
A778  23 20 50 80 69 00 C9 85 D0 1A A5 83 C9 68 D0 14  |# P.i........h..
A788  AD A2 05 D0 0F 20 6A AB F0 0A A9 0F 85 F0 A9 05  |..... j.........
A798  85 F1 E6 7F 4C B0 A7 20 73 9E A5 26 D0 07 20 B1  |....L.. s..&.. .
A7A8  AC A9 11 85 55 4C B0 A7 AD CA 05 29 78 C9 60 90  |....UL.....)x.`.
A7B8  08 29 18 F0 04 C9 10 90 0D A5 58 69 02 90 02 A9  |.)........Xi....
A7C8  FF 85 58 4C 32 A8 AD A3 05 C9 1F 90 0A A5 58 F0  |..XL2.........X.
A7D8  59 C6 58 C9 C0 90 53 A5 0C 29 03 D0 4D AD A2 05  |Y.X...S..)..M...
A7E8  C9 11 B0 46 A0 0F B9 80 07 F0 05 88 10 F8 30 3A  |...F..........0:
A7F8  A9 03 99 80 07 99 F0 07 A9 E0 99 E0 07 A5 80 E9  |................
A808  80 85 90 A5 81 E9 00 85 91 A5 82 99 B0 07 18 A5  |................
A818  83 69 01 99 C0 07 A5 0C 29 0C 0A 0A 0A 0A 65 90  |.i......).....e.
A828  99 90 07 A5 91 69 00 99 A0 07 4C A9 AA A5 31 C9  |.....i....L...1.
A838  70 90 29 85 39 A9 51 85 3F A9 00 85 38 85 3C AD  |p.).9.Q.?...8.<.
A848  A2 05 C9 01 F0 16 38 A5 83 E5 33 90 0F C9 08 90  |......8...3.....
A858  0B 18 A5 32 69 10 85 32 90 02 E6 33 4C AE AA A5  |...2i..2...3L...
A868  33 C9 40 D0 0C 85 3D A9 F0 85 3B A9 00 85 38 85  |3.@...=...;...8.
A878  3E 4C AE AA AD C5 05 F0 16 A5 81 C9 EE 90 10 A9  |>L..............
A888  35 85 02 A9 03 85 26 A9 CF 85 27 A9 02 85 55 4C  |5.....&...'...UL
A898  AE AA A5 7F 0A AA BD AB A8 85 90 BD AC A8 85 91  |................
A8A8  6C 90 00 AF A8 E5 A8 AD A2 05 D0 2E A9 0A 85 9D  |l...............
A8B8  20 40 80 A2 00 A9 5C 85 91 A9 E4 85 93 A9 41 20  | @....\.......A 
A8C8  20 AF E6 7F A9 3C 85 7D A9 20 85 76 85 72 A9 00  | ....<.}. .v.r..
A8D8  85 77 A9 03 85 7B A9 E0 85 75 4C AE AA 20 55 93  |.w...{...uL.. U.
A8E8  4C 46 AA A5 31 C9 30 D0 57 C5 39 F0 53 85 39 A9  |LF..1.0.W.9.S.9.
A8F8  40 85 3D A9 00 85 38 85 3C 85 57 85 58 BD 00 06  |@.=...8.<.W.X...
A908  F0 09 BD 50 06 29 3F C9 3F F0 16 A9 1C 85 9D 20  |...P.)?.?...... 
A918  40 80 A2 00 A9 38 85 91 A9 EE 85 93 A9 41 20 20  |@....8.......A  
A928  AF A9 3C C5 7D F0 19 A9 20 85 76 85 72 A9 00 85  |..<.}... .v.r...
A938  77 A9 03 85 7B A9 E0 85 75 A9 3C 85 7D 4C AE AA  |w...{...u.<.}L..
A948  4C 46 AA 20 55 93 A5 33 C9 10 D0 10 A5 32 29 E0  |LF. U..3.....2).
A958  D0 0A 85 32 A9 50 85 3F A9 00 85 34 4C AE AA A5  |...2.P.?...4L...
A968  7F 0A AA BD 78 A9 85 90 BD 79 A9 85 91 6C 90 00  |....x....y...l..
A978  8C A9 80 A9 86 A9 B5 A9 20 E2 AB 4C AE AA 20 96  |........ ..L.. .
A988  AC 4C AE AA AD C5 05 F0 21 20 50 80 C9 5B D0 1A  |.L......! P..[..
A998  A5 83 C9 48 D0 14 AD A2 05 D0 0F 20 6A AB F0 0A  |...H....... j...
A9A8  A9 0F 85 F0 A9 05 85 F1 E6 7F 4C AE AA 20 73 9E  |..........L.. s.
A9B8  A5 26 D0 07 20 B1 AC A9 0D 85 55 4C AE AA A5 33  |.&.. .....UL...3
A9C8  C9 40 D0 1E A5 32 29 E0 D0 18 85 32 A9 50 85 3F  |.@...2)....2.P.?
A9D8  A9 00 85 34 A5 57 F0 0D C9 02 90 16 F0 29 C9 04  |...4.W.......)..
A9E8  90 32 4C AE AA E6 58 10 06 A9 00 85 58 E6 57 4C  |.2L...X.....X.WL
A9F8  AE AA A5 0C 29 03 D0 0C A9 FF 85 74 A5 75 C9 60  |....)......t.u.`
AA08  D0 02 E6 57 4C AE AA E6 58 10 06 A9 00 85 58 E6  |...WL...X.....X.
AA18  57 4C AE AA A5 75 C9 A0 90 04 A9 00 85 72 A5 0C  |WL...u.......r..
AA28  29 03 D0 17 A9 01 85 74 A5 75 C9 E0 D0 0D A9 00  |)......t.u......
AA38  85 7D 8D 00 06 A9 60 85 3B E6 57 4C AE AA A5 09  |.}....`.;.WL....
AA48  29 FD 85 09 A9 00 85 74 A5 70 C9 3C D0 15 A5 75  |)......t.p.<...u
AA58  C9 A1 B0 06 A9 08 85 34 D0 09 A5 0C 6A 90 04 A9  |.......4....j...
AA68  FF 85 74 4C AE AA A5 7F 0A AA BD 7F AA 85 90 BD  |..tL............
AA78  80 AA 85 91 6C 90 00 83 AA A3 AA AD A2 05 D0 18  |....l...........
AA88  A9 0F 85 9D 20 40 80 A2 00 A9 C8 85 91 A9 5E 85  |.... @........^.
AA98  93 A9 41 20 20 AF E6 7F 4C AE AA 20 55 93 4C B0  |..A  ...L.. U.L.
AAA8  A7 A9 00 8D CD 05 A5 0C 4A 4A 29 03 AA BD BB AA  |........JJ).....
AAB8  85 41 60 22 26 2A 2E A5 31 C9 50 D0 0C 85 39 A9  |.A`"&*..1.P...9.
AAC8  31 85 3F A9 00 85 38 85 3E 4C AE AA A5 33 C9 20  |1.?...8.>L...3. 
AAD8  D0 0C 85 3D A9 90 85 3B A9 00 85 38 85 3E 4C AE  |...=...;...8.>L.
AAE8  AA A5 31 C9 80 D0 0C 85 39 A9 51 85 3F A9 00 85  |..1.....9.Q.?...
AAF8  38 85 3E 4C AE AA A5 33 C9 40 D0 0C 85 3D A9 D0  |8.>L...3.@...=..
AB08  85 3B A9 00 85 38 85 3E 4C AE AA A5 31 C9 C0 D0  |.;...8.>L...1...
AB18  0C 85 39 A9 81 85 3F A9 00 85 38 85 3E 4C AE AA  |..9...?...8.>L..
AB28  A5 7F 0A AA BD 39 AB 85 90 BD 3A AB 85 91 6C 90  |.....9....:...l.
AB38  00 41 AB E2 AB 96 AC CE AC AD C5 05 F0 21 20 50  |.A...........! P
AB48  80 C9 CB D0 1A A5 83 C9 79 90 14 AD A2 05 D0 0F  |........y.......
AB58  20 6A AB F0 0A A9 0F 85 F0 A9 05 85 F1 E6 7F 4C  | j.............L
AB68  AE AA AD C3 05 D0 60 AD A6 05 29 FE C9 64 F0 08  |......`...)..d..
AB78  C9 DA F0 04 C9 68 D0 4F 20 52 9E 20 5D 9E 20 68  |.....h.O R. ]. h
AB88  9E A9 01 8D 61 05 A9 00 8D 60 05 A5 80 E5 30 85  |....a....`....0.
AB98  90 A5 81 E5 31 20 D2 AB A5 82 E5 32 85 90 A5 83  |....1 .....2....
ABA8  E5 33 20 D2 AB 69 10 85 75 8D 00 02 A9 36 85 7D  |.3 ..i..u....6.}
ABB8  A9 00 85 7B A9 03 85 73 85 74 A9 18 85 72 A5 32  |...{...s.t...r.2
ABC8  85 3C A5 33 85 3D 60 A9 00 60 4A 66 90 4A 66 90  |.<.3.=`..`Jf.Jf.
ABD8  4A 66 90 4A 66 90 18 A5 90 60 20 E5 AC 29 07 D0  |Jf.Jf....` ..)..
ABE8  16 AD BE 05 C9 02 B0 0F EE BE 05 AD BE 05 8D BF  |................
ABF8  05 A9 FF 85 26 85 27 20 73 9E CE 61 05 D0 67 EE  |....&.' s..a..g.
AC08  61 05 A2 07 BD 00 07 F0 05 CA 10 F8 30 58 AC 60  |a...........0X.`
AC18  05 B9 7B AC 30 3F EE 60 05 A8 A9 04 8D 61 05 A9  |..{.0?.`.....a..
AC28  92 9D 00 07 9D 70 07 B9 8C AC 9D 50 07 B9 91 AC  |.....p.....P....
AC38  9D 60 07 9D 30 07 18 A5 83 69 01 9D 40 07 98 0A  |.`..0....i..@...
AC48  A8 B9 71 AC 9D 10 07 18 A5 81 29 FE 79 72 AC 9D  |..q.......).yr..
AC58  20 07 4C 6E AC A9 11 8D A2 05 AD 0C 06 F0 05 09  | .Ln............
AC68  80 8D 0C 06 E6 7F 4C AE AA 40 00 60 01 A0 00 D0  |......L..@.`....
AC78  01 00 01 04 01 02 03 00 01 02 03 04 00 01 03 02  |................
AC88  04 03 00 FF 00 60 60 00 00 06 05 05 06 0A 20 E5  |.....``....... .
AC98  AC 20 73 9E AD A6 05 0D A7 05 D0 0A A9 01 85 26  |. s............&
ACA8  A9 FF 85 27 E6 7F 4C AE AA 85 7D AD 0C 06 F0 11  |...'..L...}.....
ACB8  C9 FF F0 0D AD FC 06 F0 08 AD 0C 06 29 3F 8D 0C  |............)?..
ACC8  06 A9 40 85 02 60 A5 0C 09 10 85 0C 20 73 9E A5  |..@..`...... s..
ACD8  26 D0 07 20 B1 AC A9 08 85 55 4C AE AA A5 0C 09  |&.. .....UL.....
ACE8  08 85 0C 60 A5 7F 0A AA BD FD AC 85 90 BD FE AC  |...`............
ACF8  85 91 6C 90 00 01 AD 44 AD AD A2 05 D0 3B 20 5A  |..l....D.....; Z
AD08  C0 A9 01 85 73 A9 00 85 77 A9 40 85 75 A9 BD 8D  |....s...w.@.u...
AD18  00 02 A9 E0 8D 03 02 A9 81 8D 01 02 A9 21 8D 02  |.............!..
AD28  02 A9 09 85 9D 20 40 80 A2 00 A9 B8 85 91 A9 5E  |..... @........^
AD38  85 93 A9 41 20 20 AF E6 7F 4C AE AA AD FA 05 D0  |...A  ...L......
AD48  16 AD C8 05 F0 0C A5 0C 4A 29 03 A8 B9 6C AD 4C  |........J)...l.L
AD58  5C AD A9 28 8D A2 03 AD 99 03 C9 05 D0 03 20 70  |\..(.......... p
AD68  AD 4C C9 AD 15 24 05 24 A9 06 85 5B AD A2 05 C9  |.L...$.$...[....
AD78  01 D0 16 AD AC 05 CD EA 05 D0 0E EE AC 05 AD CB  |................
AD88  05 49 80 20 37 A7 8D CB 05 4C 22 A7 A5 7F 0A AA  |.I. 7....L".....
AD98  BD A5 AD 85 90 BD A6 AD 85 91 6C 90 00 A9 AD C9  |..........l.....
ADA8  AD AD A2 05 D0 18 A9 08 85 9D 20 40 80 A2 00 A9  |.......... @....
ADB8  DC 85 91 A9 10 85 93 A9 41 20 20 AF E6 7F 4C AE  |........A  ...L.
ADC8  AA 20 55 93 4C AE AA A5 7F 0A AA BD E0 AD 85 90  |. U.L...........
ADD8  BD E1 AD 85 91 6C 90 00 F4 AD E8 AD EE AD 1D AE  |.....l..........
ADE8  20 E2 AB 4C 58 AE 20 96 AC 4C 58 AE AD C5 05 F0  | ..LX. ..LX.....
ADF8  21 20 50 80 C9 7D D0 1A A5 83 C9 65 D0 14 AD A2  |! P..}.....e....
AE08  05 D0 0F 20 6A AB F0 0A A9 0F 85 F0 A9 05 85 F1  |... j...........
AE18  E6 7F 4C 58 AE 20 73 9E A5 26 D0 07 20 B1 AC A9  |..LX. s..&.. ...
AE28  0E 85 55 4C 58 AE A5 31 29 0F D0 04 A9 73 85 45  |..ULX..1)....s.E
AE38  A5 7F 0A AA BD 49 AE 85 90 BD 4A AE 85 91 6C 90  |.....I....J...l.
AE48  00 4D AE 58 AE A9 68 85 75 A9 57 85 7D E6 7F 60  |.M.X..h.u.W.}..`
AE58  A5 0C 4A 4A 29 03 AA BD 65 AE 85 41 60 32 36 3A  |..JJ)...e..A`26:
AE68  3E                                               |>

loc_AE69:  ; xrefs(0): 
AE69  AD EC 05 LDA $05EC                 
AE6C  F0 0D    BEQ $AE7B                 
AE6E  A5 37    LDA $37                   
AE70  05 36    ORA $36                   
AE72  D0 07    BNE $AE7B                 
AE74  AD A2 05 LDA $05A2                 
AE77  C9 12    CMP #$12                  
AE79  90 01    BCC $AE7C                 

loc_AE7B:  ; xrefs(2): $AE6C $AE72
AE7B  60       RTS                       

loc_AE7C:  ; xrefs(1): $AE79
AE7C  A9 00    LDA #$00                  
AE7E  8D EC 05 STA $05EC                 
AE81  A5 55    LDA $55                   
AE83  0A       ASL A                     
AE84  0A       ASL A                     
AE85  A8       TAY                       
AE86  B9 AD AF LDA $AFAD,Y               
AE89  85 9A    STA $9A                   
AE8B  B9 AE AF LDA $AFAE,Y               
AE8E  85 9B    STA $9B                   
AE90  B9 AF AF LDA $AFAF,Y               
AE93  85 9C    STA $9C                   
AE95  B9 B0 AF LDA $AFB0,Y               
AE98  85 9D    STA $9D                   
AE9A  AC EB 05 LDY $05EB                 
AE9D  B1 9A    LDA ($9A),Y               
AE9F  C9 FF    CMP #$FF                  
AEA1  F0 53    BEQ $AEF6                 
AEA3  0A       ASL A                     
AEA4  0A       ASL A                     
AEA5  A8       TAY                       
AEA6  B1 9C    LDA ($9C),Y               
AEA8  F0 4C    BEQ $AEF6                 
AEAA  85 9F    STA $9F                   
AEAC  C8       INY                       
AEAD  C8       INY                       
AEAE  B1 9C    LDA ($9C),Y               
AEB0  85 9A    STA $9A                   
AEB2  C8       INY                       
AEB3  B1 9C    LDA ($9C),Y               
AEB5  85 9B    STA $9B                   
AEB7  A0 00    LDY #$00                  

loc_AEB9:  ; xrefs(1): $AEF4
AEB9  B1 9A    LDA ($9A),Y               
AEBB  85 9C    STA $9C                   
AEBD  C8       INY                       
AEBE  B1 9A    LDA ($9A),Y               
AEC0  85 9D    STA $9D                   
AEC2  C8       INY                       
AEC3  B1 9A    LDA ($9A),Y               
AEC5  85 90    STA $90                   
AEC7  C8       INY                       
AEC8  B1 9A    LDA ($9A),Y               
AECA  85 91    STA $91                   
AECC  C8       INY                       
AECD  B1 9A    LDA ($9A),Y               
AECF  85 92    STA $92                   
AED1  C8       INY                       
AED2  B1 9A    LDA ($9A),Y               
AED4  85 93    STA $93                   
AED6  C8       INY                       
AED7  20 59 80 JSR $8059                 
AEDA  30 16    BMI $AEF2                 
AEDC  F0 14    BEQ $AEF2                 
AEDE  AA       TAX                       
AEDF  A5 9C    LDA $9C                   
AEE1  29 C0    AND #$C0                  
AEE3  F0 0A    BEQ $AEEF                 
AEE5  18       CLC                       
AEE6  2A       ROL A                     
AEE7  2A       ROL A                     
AEE8  2A       ROL A                     
AEE9  85 4C    STA $4C                   
AEEB  E4 4C    CPX $4C                   
AEED  D0 03    BNE $AEF2                 

loc_AEEF:  ; xrefs(1): $AEE3
AEEF  20 F7 AE JSR $AEF7                 

loc_AEF2:  ; xrefs(3): $AEDA $AEDC $AEED
AEF2  C6 9F    DEC $9F                   
AEF4  D0 C3    BNE $AEB9                 

loc_AEF6:  ; xrefs(2): $AEA1 $AEA8
AEF6  60       RTS                       

sub_AEF7:  ; xrefs(1): $AEEF
AEF7  98       TYA                       
AEF8  48       PHA                       
AEF9  A2 0B    LDX #$0B                  

loc_AEFB:  ; xrefs(1): $AF1B
AEFB  BD 00 06 LDA $0600,X               
AEFE  D0 18    BNE $AF18                 
AF00  A5 9C    LDA $9C                   
AF02  29 3F    AND #$3F                  
AF04  A8       TAY                       
AF05  B9 60 05 LDA $0560,Y               
AF08  F0 0E    BEQ $AF18                 
AF0A  30 0C    BMI $AF18                 
AF0C  09 80    ORA #$80                  
AF0E  99 60 05 STA $0560,Y               
AF11  98       TYA                       
AF12  20 20 AF JSR $AF20                 
AF15  4C 1D AF JMP $AF1D                 

loc_AF18:  ; xrefs(3): $AEFE $AF08 $AF0A
AF18  CA       DEX                       
AF19  E0 FF    CPX #$FF                  
AF1B  D0 DE    BNE $AEFB                 

loc_AF1D:  ; xrefs(1): $AF15
AF1D  68       PLA                       
AF1E  A8       TAY                       
AF1F  60       RTS                       

sub_AF20:  ; xrefs(1): $AF12
AF20  9D 00 06 STA $0600,X               
AF23  A5 90    LDA $90                   
AF25  95 A0    STA $A0,X                 
AF27  A5 91    LDA $91                   
AF29  95 B0    STA $B0,X                 
AF2B  A5 92    LDA $92                   
AF2D  95 C0    STA $C0,X                 
AF2F  A5 93    LDA $93                   
AF31  95 D0    STA $D0,X                 
AF33  A5 9D    LDA $9D                   
AF35  48       PHA                       
AF36  A9 00    LDA #$00                  
AF38  06 9D    ASL $9D                   
AF3A  2A       ROL A                     
AF3B  06 9D    ASL $9D                   
AF3D  2A       ROL A                     
AF3E  06 9D    ASL $9D                   
AF40  2A       ROL A                     
AF41  48       PHA                       
AF42  A5 9D    LDA $9D                   
AF44  69 CA    ADC #$CA                  
AF46  85 9D    STA $9D                   
AF48  68       PLA                       
AF49  69 BD    ADC #$BD                  
AF4B  85 9E    STA $9E                   
AF4D  68       PLA                       
AF4E  65 9D    ADC $9D                   
AF50  85 9D    STA $9D                   
AF52  90 02    BCC $AF56                 
AF54  E6 9E    INC $9E                   

loc_AF56:  ; xrefs(1): $AF52
AF56  A0 00    LDY #$00                  
AF58  B1 9D    LDA ($9D),Y               
AF5A  9D 50 06 STA $0650,X               
AF5D  C8       INY                       
AF5E  B1 9D    LDA ($9D),Y               
AF60  9D 60 06 STA $0660,X               
AF63  C8       INY                       
AF64  B1 9D    LDA ($9D),Y               
AF66  9D 70 06 STA $0670,X               
AF69  C8       INY                       
AF6A  B1 9D    LDA ($9D),Y               
AF6C  9D 10 06 STA $0610,X               
AF6F  C8       INY                       
AF70  B1 9D    LDA ($9D),Y               
AF72  9D 20 06 STA $0620,X               
AF75  C8       INY                       
AF76  B1 9D    LDA ($9D),Y               
AF78  9D 30 06 STA $0630,X               
AF7B  C8       INY                       
AF7C  B1 9D    LDA ($9D),Y               
AF7E  9D 40 06 STA $0640,X               
AF81  C8       INY                       
AF82  B1 9D    LDA ($9D),Y               
AF84  9D 90 06 STA $0690,X               
AF87  C8       INY                       
AF88  B1 9D    LDA ($9D),Y               
AF8A  9D F0 06 STA $06F0,X               
AF8D  C8       INY                       
AF8E  A5 80    LDA $80                   
AF90  D5 A0    CMP $A0,X                 
AF92  A5 81    LDA $81                   
AF94  F5 B0    SBC $B0,X                 
AF96  9D 80 06 STA $0680,X               
AF99  A9 00    LDA #$00                  
AF9B  9D D0 06 STA $06D0,X               
AF9E  9D C0 06 STA $06C0,X               
AFA1  9D A0 06 STA $06A0,X               
AFA4  9D B0 06 STA $06B0,X               
AFA7  A9 FF    LDA #$FF                  
AFA9  9D E0 06 STA $06E0,X               
AFAC  60       RTS                       

; ---- data $AFAD-$BFFF (4179 bytes) ----
AFAD  A8 B1 FD AF 51 B4 92 BD 51 B4 FC BA E5 B2 36 BA  |....Q...Q.....6.
AFBD  2F B1 46 B7 2F B1 0F B1 46 B5 DA BB 46 B5 C4 BC  |/.F./...F...F...
AFCD  25 B2 FD AF E5 B2 94 BA D8 B3 FC B5 D8 B3 70 B6  |%.............p.
AFDD  25 B2 FD AF 25 B2 FD AF 25 B2 FD AF 2F B3 4E B9  |%...%...%.../.N.
AFED  2F B3 4E B9 25 B2 FD AF 25 B2 FD AF 25 B2 FD AF  |/.N.%...%...%...
AFFD  02 00 3D B0 06 00 3D B0 09 00 3D B0 0A 00 49 B0  |..=...=...=...I.
B00D  08 00 61 B0 08 00 73 B0 09 00 85 B0 08 00 91 B0  |..a...s.........
B01D  06 00 A3 B0 04 00 BB B0 07 00 C1 B0 08 00 C7 B0  |................
B02D  08 00 D3 B0 06 00 EB B0 04 00 F7 B0 02 00 03 B1  |................
B03D  01 02 00 27 00 19 02 02 00 2D 00 19 43 02 00 30  |...'.....-..C..0
B04D  00 19 04 00 00 35 00 17 05 00 00 39 00 17 46 02  |.....5.....9..F.
B05D  00 33 00 19 07 04 30 41 00 17 08 00 00 43 00 17  |.3....0A.....C..
B06D  09 00 00 47 00 17 0A 02 00 53 00 17 0B 02 00 57  |...G.....S.....W
B07D  00 17 0C 03 00 59 F0 14 4D 02 00 54 00 2B 4E 02  |.....Y..M..T.+N.
B08D  00 5B 00 2B 0F 02 00 62 00 2B 10 02 00 68 00 2B  |.[.+...b.+...h.+
B09D  11 00 00 6B 00 29 12 02 00 73 00 2B 13 04 30 7D  |...k.)...s.+..0}
B0AD  00 26 14 04 30 7D 00 2B 15 00 00 7F 00 29 16 03  |.&..0}.+.....)..
B0BD  00 89 F0 24 17 03 00 89 F0 3A 18 06 00 83 00 4B  |...$.....:.....K
B0CD  19 06 00 8B 00 4B 1A 01 00 97 00 46 1B 07 00 97  |.....K.....F....
B0DD  00 4B 5C 2D 00 9D 00 4B 1D 03 00 9D F0 44 1E 06  |.K\-...K.....D..
B0ED  00 AD 00 47 1F 00 00 A5 00 49 20 03 00 B3 F0 44  |...G.....I ....D
B0FD  21 06 00 BB 00 49 22 2D 00 C7 00 45 23 03 00 C5  |!....I"-...E#...
B10D  F0 4A 02 00 7A B7 04 00 7A B7 06 00 80 B7 07 00  |.J..z...z.......
B11D  86 B7 08 00 92 B7 07 00 A4 B7 06 00 B0 B7 03 00  |................
B12D  C2 B7 FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B13D  FF FF FF FF FF FF FF FF 06 07 08 09 FF FF FF FF  |................
B14D  FF FF FF 00 01 02 03 04 05 FF FF 0A FF FF FF FF  |................
B15D  FF FF FF FF FF FF FF FF FF FF FF 0B 0C FF FF FF  |................
B16D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B17D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B18D  FF FF FF 00 01 02 03 04 05 06 07 FF FF FF FF FF  |................
B19D  FF FF FF 00 01 02 03 04 05 06 07 FF FF FF FF FF  |................
B1AD  FF FF FF FF FF FF FF FF FF FF FF FF 00 01 02 03  |................
B1BD  04 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B1CD  05 06 07 08 FF FF FF FF FF FF FF FF FF FF FF FF  |................
B1DD  FF FF FF 09 FF FF FF FF FF FF FF FF FF FF FF FF  |................
B1ED  FF FF 0A 0A 0B 0C 0D 0F FF FF FF FF FF FF FF FF  |................
B1FD  FF FF FF FF FF FF 0E 0F FF FF FF FF FF FF FF FF  |................
B20D  FF FF FF FF FF FF FF 0F FF FF FF FF FF FF FF FF  |................
B21D  FF FF FF FF FF FF FF 0F FF FF FF FF FF FF FF FF  |................
B22D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B23D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B24D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B25D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B26D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B27D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B28D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B29D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B2AD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B2BD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B2CD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B2DD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B2ED  FF FF FF FF FF FF FF FF FF 00 01 02 03 04 05 06  |................
B2FD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B30D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B31D  FF FF FF FF FF FF FF FF FF 00 01 02 03 04 05 06  |................
B32D  07 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B33D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF 21 FF  |..............!.
B34D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF 20 FF  |.............. .
B35D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF 1F FF  |................
B36D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF 1E FF  |................
B37D  FF FF FF 00 01 02 03 04 05 FF FF FF FF FF 1D FF  |................
B38D  FF FF FF FF FF FF FF FF 06 FF 18 19 FF 1B 1C FF  |................
B39D  FF FF FF 0C 0B 0A 09 08 07 FF 17 FF FF FF FF FF  |................
B3AD  FF FF FF 0D FF FF FF FF FF FF 16 FF FF FF FF FF  |................
B3BD  FF FF FF 0E 0F 10 11 12 13 14 15 FF FF FF FF FF  |................
B3CD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B3DD  FF FF FF FF FF FF FF FF FF FF FF FF 00 01 02 03  |................
B3ED  04 05 06 07 08 FF FF FF FF FF FF FF FF FF FF FF  |................
B3FD  FF FF FF FF FF FF FF FF FF FF FF FF 00 FF FF FF  |................
B40D  FF FF FF FF FF FF FF FF FF FF FF FF 01 FF FF FF  |................
B41D  FF FF FF FF FF FF FF FF FF FF FF FF 02 FF FF FF  |................
B42D  FF FF FF FF FF FF FF FF FF FF FF FF 03 04 05 06  |................
B43D  07 08 09 FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B44D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B45D  FF FF FF FF FF FF FF FF 00 01 02 03 FF FF FF FF  |................
B46D  FF FF FF FF FF FF FF FF FF FF FF 04 FF FF FF FF  |................
B47D  FF FF FF FF FF FF FF FF FF FF FF 05 FF FF FF FF  |................
B48D  FF FF FF FF FF FF FF 0D FF FF FF 06 07 08 09 0A  |................
B49D  0B 0C 0D FF FF FF FF 0C FF FF FF FF FF FF FF FF  |................
B4AD  FF FF FF FF FF FF FF 0B FF FF FF FF FF FF FF FF  |................
B4BD  FF FF FF FF FF FF FF 0A FF FF FF FF FF FF FF FF  |................
B4CD  FF FF FF FF FF FF FF 08 FF FF FF FF FF FF FF FF  |................
B4DD  FF FF FF FF FF FF FF 07 FF FF FF FF FF FF FF FF  |................
B4ED  FF FF FF FF FF FF FF 06 FF FF FF FF FF FF FF FF  |................
B4FD  FF FF FF FF FF FF FF 05 FF FF FF FF FF FF FF FF  |................
B50D  FF FF FF FF FF FF FF 04 FF FF FF FF FF FF FF FF  |................
B51D  FF FF FF FF FF FF FF 03 FF FF FF FF FF FF FF FF  |................
B52D  FF FF FF FF FF 00 01 02 FF FF FF FF FF FF FF FF  |................
B53D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B54D  FF FF FF FF FF FF FF FF FF FF 00 01 02 03 04 05  |................
B55D  06 07 08 09 0A FF FF FF FF FF FF FF FF FF FF FF  |................
B56D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B57D  FF FF FF FF FF FF FF FF FF FF FF 02 03 04 05 06  |................
B58D  FF FF FF FF FF FF FF FF FF FF FF 01 0A 09 08 07  |................
B59D  FF FF FF FF FF FF FF FF FF FF FF 00 0B 0C 0D 0E  |................
B5AD  0F 0A FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
B5BD  FF FF FF 01 23 00 2F 80 19 02 16 00 33 00 19 03  |....#./.....3...
B5CD  16 00 3C 00 1A 04 23 80 45 80 1B 05 23 80 49 80  |..<...#.E...#.I.
B5DD  1B 06 23 80 54 80 1B 07 17 00 63 00 19 08 17 00  |..#.T.....c.....
B5ED  77 00 19 09 17 00 84 00 19 0A 13 00 88 00 19 01  |w...............
B5FD  00 C0 B5 03 00 C0 B5 05 00 C0 B5 05 00 C6 B5 04  |................
B60D  00 D2 B5 03 00 DE B5 04 00 E4 B5 03 00 EA B5 01  |................
B61D  06 00 1B 00 45 02 03 00 13 D0 46 03 06 00 19 00  |....E.....F.....
B62D  53 04 06 80 1B 00 55 05 03 00 1F D0 67 06 03 00  |S.....U.....g...
B63D  2B D0 62 07 06 80 35 00 67 08 06 00 45 00 65 09  |+.b...5.g...E.e.
B64D  03 00 45 D0 67 0A 06 00 53 00 65 0B 03 30 59 D0  |..E.g...S.e..0Y.
B65D  64 0C 03 00 6B D0 62 0D 19 00 76 00 64 0E 19 00  |d...k.b...v.d...
B66D  77 00 68 02 00 1C B6 04 00 1C B6 05 00 1C B6 04  |w.h.............
B67D  00 28 B6 03 00 34 B6 04 00 3A B6 05 00 40 B6 05  |.(...4...:...@..
B68D  00 46 B6 05 00 52 B6 03 00 5E B6 41 2D 00 1B 00  |.F...R...^.A-...
B69D  28 02 2D 00 27 00 2A 03 2D 00 2D 00 27 04 17 00  |(.-.'.*.-.-.'...
B6AD  2B 00 29 05 17 00 35 00 27 06 2D 00 39 00 25 07  |+.)...5.'.-.9.%.
B6BD  06 00 45 00 2A 08 17 00 4B 00 27 09 2D 00 43 00  |..E.*...K.'.-.C.
B6CD  27 0A 2D 00 53 00 24 0B 17 00 59 00 28 0C 2D 00  |'.-.S.$...Y.(.-.
B6DD  5D 00 27 0D 06 00 55 00 2A 0E 17 00 6B 00 21 0F  |].'...U.*...k.!.
B6ED  06 00 66 00 27 10 17 80 6B 00 28 11 17 00 67 00  |..f.'...k.(...g.
B6FD  17 12 13 00 79 00 17 13 13 00 80 00 15 14 17 00  |....y...........
B70D  8B 00 17 15 17 00 93 00 15 16 21 00 99 00 23 D7  |..........!...#.
B71D  2D 00 5D 00 27 18 21 00 97 00 2D 19 17 00 97 00  |-.].'.!...-.....
B72D  27 1A 22 00 97 00 33 1B 21 00 97 00 39 1C 2D 00  |'."...3.!...9.-.
B73D  A5 00 3A 1D 03 00 AE 00 34 04 00 98 B6 06 00 98  |..:.....4.......
B74D  B6 08 00 9E B6 09 00 B0 B6 0A 00 BC B6 08 00 CE  |................
B75D  B6 05 00 E6 B6 04 00 F8 B6 04 00 FE B6 07 00 04  |................
B76D  B7 07 00 10 B7 08 00 16 B7 04 00 2E B7 01 1D 00  |................
B77D  1F 00 7B 02 20 00 2F 00 75 03 1D 00 38 00 73 04  |..{. ./.u...8.s.
B78D  20 00 3B 00 7B 05 29 00 42 00 75 06 20 00 4B 00  | .;.{.).B.u. .K.
B79D  73 07 29 00 4C 00 7A 08 20 00 56 00 7B 09 1D 00  |s.).L.z. .V.{...
B7AD  59 00 76 0A 1D 00 63 00 7B 0B 29 00 6C 00 7A 0C  |Y.v...c.{.).l.z.
B7BD  20 00 6F 00 70 0D 20 00 71 00 7B 0E 1D 00 7C 00  | .o.p. .q.{...|.
B7CD  7B 0F 1D 00 89 00 73 01 17 00 28 00 55 02 24 00  |{.....s...(.U.$.
B7DD  2D 50 53 03 16 00 2D 00 57 04 16 00 37 00 55 05  |-PS...-.W...7.U.
B7ED  24 00 3D 50 53 06 17 80 3B 00 59 07 1B 00 48 00  |$.=PS...;.Y...H.
B7FD  55 08 14 00 45 00 59 09 14 00 4D 00 59 0A 17 00  |U...E.Y...M.Y...
B80D  4B 00 5B 0B 17 00 57 00 5B 0C 18 00 62 00 5B 0D  |K.[...W.[...b.[.
B81D  17 80 64 00 59 0E 18 00 69 00 57 0F 17 00 65 00  |..d.Y...i.W...e.
B82D  69 10 17 50 68 00 6E 11 24 00 65 50 73 12 16 00  |i..Ph.n.$.ePs...
B83D  68 00 7B 13 17 00 57 00 75 14 17 00 4B 00 7B 15  |h.{...W.u...K.{.
B84D  13 00 47 00 7B 16 18 00 20 00 7B 17 27 00 24 00  |..G.{... .{.'.$.
B85D  7B 18 18 00 17 00 77 19 18 00 1B 00 79 1A 03 00  |{.....w.....y...
B86D  1B 00 85 1B 03 00 17 00 8B 1C 18 00 1A 00 8D 1E  |................
B87D  19 00 23 00 94 1F 24 00 2B 50 92 20 19 00 31 00  |..#...$.+P. ..1.
B88D  98 21 19 00 33 00 93 22 28 00 3F 00 93 23 03 00  |.!..3.."(.?..#..
B89D  45 00 97 24 28 00 4F 00 97 25 18 00 69 00 9B 26  |E..$(.O..%..i..&
B8AD  27 00 7F 00 9B 27 18 00 83 00 9B 28 18 00 88 00  |'....'.....(....
B8BD  97 29 27 00 8B 00 99 2A 03 00 8B 00 83 2B 18 00  |.)'....*.....+..
B8CD  84 00 8F 2C 27 00 85 00 89 2D 27 00 83 00 83 2E  |...,'....-'.....
B8DD  18 00 87 00 75 2F 27 00 83 00 79 30 18 00 89 00  |....u/'...y0....
B8ED  65 31 03 00 87 00 68 32 27 00 99 00 69 33 28 00  |e1....h2'...i3(.
B8FD  BA 00 68 34 03 00 C1 00 67 35 03 00 CA 00 61 36  |..h4....g5....a6
B90D  28 00 C9 00 69 37 1E 80 C8 80 53 38 1E 80 CA 80  |(...i7....S8....
B91D  56 39 24 80 C6 60 4B 3A 23 00 C3 80 45 3B 1E 80  |V9$..`K:#...E;..
B92D  C8 80 33 3C 1E 80 CA 80 36 3D 23 00 C3 80 25 3E  |..3<....6=#...%>
B93D  03 00 C9 00 2A 01 03 00 C5 00 15 02 03 00 CD 00  |....*...........
B94D  1A 03 00 D4 B7 06 00 D4 B7 0A 00 D4 B7 08 00 E6  |................
B95D  B7 08 00 F8 B7 06 00 10 B8 07 00 16 B8 06 00 28  |...............(
B96D  B8 06 00 34 B8 04 00 40 B8 04 00 46 B8 04 00 52  |...4...@...F...R
B97D  B8 07 00 52 B8 05 00 5E B8 05 00 6A B8 05 00 7C  |...R...^...j...|
B98D  B8 07 00 7C B8 05 00 88 B8 03 00 9A B8 02 00 A6  |...|............
B99D  B8 05 00 A6 B8 08 00 AC B8 09 00 B2 B8 08 00 C4  |................
B9AD  B8 05 00 DC B8 03 00 E8 B8 02 00 F4 B8 04 00 FA  |................
B9BD  B8 06 00 FA B8 07 00 00 B9 06 00 12 B9 06 00 1E  |................
B9CD  B9 06 00 2A B9 04 00 36 B9 41 02 00 20 00 1B 02  |...*...6.A.. ...
B9DD  02 00 2B 00 19 03 17 00 2F 00 1A 04 02 00 33 00  |..+...../.....3.
B9ED  19 05 17 00 3A 00 17 06 02 00 3E 00 17 07 17 00  |....:.....>.....
B9FD  4B 00 18 08 02 00 47 00 17 4B 02 00 53 00 17 0A  |K.....G..K..S...
BA0D  17 00 55 00 1A 0B 17 00 5F 00 1A 0C 02 00 65 00  |..U....._.....e.
BA1D  1A 0D 02 00 6B 00 19 4E 02 00 6D 00 19 0F 17 00  |....k..N..m.....
BA2D  75 00 17 10 17 00 7B 00 19 03 00 D6 B9 06 00 D6  |u.....{.........
BA3D  B9 08 00 D6 B9 08 00 E8 B9 08 00 FA B9 08 00 06  |................
BA4D  BA 05 00 18 BA 01 2C 00 2A 00 43 02 16 00 37 00  |......,.*.C...7.
BA5D  47 43 16 00 3A 00 47 04 03 00 4B 00 47 05 2C 00  |GC..:.G...K.G.,.
BA6D  51 00 41 46 16 00 53 00 47 07 2C 00 61 00 41 48  |Q.AF..S.G.,.a.AH
BA7D  16 00 6E 00 47 09 16 00 74 00 43 0A 16 00 81 00  |..n.G...t.C.....
BA8D  47 0B 03 00 87 00 45 01 00 52 BA 03 00 52 BA 04  |G.....E..R...R..
BA9D  00 52 BA 05 00 58 BA 05 00 64 BA 05 00 6A BA 05  |.R...X...d...j..
BAAD  00 76 BA 03 00 82 BA 01 03 00 2D 00 E7 02 2C 00  |.v........-...,.
BABD  3D 00 DC 03 1F 00 38 00 BE 04 2C 00 38 00 A4 05  |=.....8...,.8...
BACD  25 00 37 00 75 06 25 00 3B 00 75 07 25 00 39 00  |%.7.u.%.;.u.%.9.
BADD  7D 08 25 00 3A 80 6B 09 2C 00 35 00 5A 0A 25 00  |}.%.:.k.,.5.Z.%.
BAED  45 80 41 0B 25 00 4B 80 41 0C 25 00 57 80 43 01  |E.A.%.K.A.%.W.C.
BAFD  00 B4 BA 01 00 B4 BA 02 00 B4 BA 01 00 BA BA 02  |................
BB0D  00 BA BA 02 00 C0 BA 02 00 C0 BA 01 00 C6 BA 03  |................
BB1D  00 CC BA 04 00 CC BA 05 00 CC BA 02 00 DE BA 03  |................
BB2D  00 E4 BA 03 00 EA BA 03 00 EA BA 01 2D 00 2C 00  |............-.,.
BB3D  19 02 2D 00 34 00 19 03 2D 00 3A 00 17 44 2D 00  |..-.4...-.:..D-.
BB4D  38 00 17 05 26 00 39 00 10 06 26 00 4A 00 10 07  |8...&.9...&.J...
BB5D  26 00 4F 00 10 08 26 00 47 00 10 09 26 00 4D 00  |&.O...&.G...&.M.
BB6D  10 4A 2D 00 51 00 17 0B 2D 00 5E 00 17 4C 2D 00  |.J-.Q...-.^..L-.
BB7D  5D 00 17 4D 2D 00 6C 00 19 0E 2D 00 6B 00 19 0F  |]..M-.l...-.k...
BB8D  26 00 7D 00 10 10 2D 00 7E 00 19 11 26 00 80 00  |&.}...-.~...&...
BB9D  10 12 2D 00 83 00 19 53 2D 00 86 00 19 14 26 00  |..-....S-.....&.
BBAD  83 00 10 55 2D 00 85 00 18 16 2D 00 90 00 1B 17  |...U-.....-.....
BBBD  2D 00 99 00 1B 18 26 00 9E 00 10 19 2D 00 A4 00  |-.....&.....-...
BBCD  19 1A 26 00 A2 00 10 1B 13 00 C8 00 19 01 00 38  |..&............8
BBDD  BB 05 00 38 BB 09 00 38 BB 0B 00 3E BB 09 00 56  |...8...8...>...V
BBED  BB 07 00 6E BB 09 00 80 BB 09 00 8C BB 09 00 98  |...n............
BBFD  BB 04 00 B6 BB 03 00 C8 BB 01 00 D4 BB 01 19 00  |................
BC0D  2D 00 58 02 17 00 29 00 53 03 19 00 2D 00 52 04  |-.X...).S...-.R.
BC1D  19 00 27 00 4C 05 19 00 25 00 47 06 17 00 2E 00  |..'.L...%.G.....
BC2D  47 07 23 00 37 80 49 08 28 00 49 00 47 09 28 00  |G.#.7.I.(.I.G.(.
BC3D  4E 00 46 0A 28 00 55 00 46 0B 23 00 69 80 47 0C  |N.F.(.U.F.#.i.G.
BC4D  28 00 65 00 58 0D 23 00 57 80 57 0E 28 00 4C 00  |(.e.X.#.W.W.(.L.
BC5D  58 0F 28 00 44 00 56 10 24 00 39 80 59 11 28 00  |X.(.D.V.$.9.Y.(.
BC6D  39 00 5E 12 17 00 35 00 63 13 17 00 39 00 66 14  |9.^...5.c...9.f.
BC7D  24 00 4B 80 64 15 17 00 4E 00 6B 16 28 00 58 00  |$.K.d...N.k.(.X.
BC8D  66 17 23 00 5B 80 6B 18 28 00 61 00 6B 19 28 00  |f.#.[.k.(.a.k.(.
BC9D  65 00 65 1A 28 00 6A 00 66 1B 23 00 6F 80 6B 1C  |e.e.(.j.f.#.o.k.
BCAD  17 00 76 00 6B 1D 28 00 75 00 65 1E 23 00 81 80  |..v.k.(.u.e.#...
BCBD  66 1F 17 00 89 00 66 03 00 0A BC 06 00 0A BC 07  |f.....f.........
BCCD  00 0A BC 06 00 1C BC 04 00 2E BC 04 00 34 BC 03  |.............4..
BCDD  00 40 BC 03 00 46 BC 04 00 4C BC 05 00 52 BC 06  |.@...F...L...R..
BCED  00 58 BC 06 00 64 BC 06 00 70 BC 08 00 7C BC 08  |.X...d...p...|..
BCFD  00 88 BC 08 00 94 BC 04 00 AC BC 01 16 00 58 00  |..............X.
BD0D  1A 02 1F 00 56 00 10 03 16 00 62 00 1A 04 16 00  |....V.....b.....
BD1D  71 00 1A 05 16 00 79 00 19 06 17 00 75 00 27 07  |q.....y.....u.'.
BD2D  17 80 72 00 33 08 25 00 79 80 31 49 2C 00 76 00  |..r.3.%.y.1I,.v.
BD3D  43 4A 2C 00 8B 00 43 0B 17 00 85 00 49 0C 25 00  |CJ,...C.....I.%.
BD4D  A3 80 41 0D 16 00 AD 00 49 0E 25 00 B5 80 41 0F  |..A.....I.%...A.
BD5D  25 00 BB 80 41 10 17 00 BE 00 49 51 16 00 C2 00  |%...A.....IQ....
BD6D  49 12 16 00 CF 00 49 13 2C 00 8B 00 43 14 16 00  |I.....I.,...C...
BD7D  D7 00 45 55 2C 00 D9 00 43 16 16 00 E2 00 49 17  |..EU,...C.....I.
BD8D  17 00 EB 00 45 02 00 08 BD 03 00 08 BD 05 00 08  |....E...........
BD9D  BD 04 00 14 BD 05 00 1A BD 04 00 26 BD 05 00 2C  |...........&...,
BDAD  BD 03 00 38 BD 04 00 3E BD 05 00 4A BD 08 00 4A  |...8...>...J...J
BDBD  BD 08 00 56 BD 07 00 68 BD 04 00 7A BD 01 90 01  |...V...h...z....
BDCD  00 00 00 00 00 04 01 6E 01 00 00 00 00 00 04 0B  |.......n........
BDDD  00 00 00 00 00 00 00 01 0D B6 01 FF 00 00 00 00  |................
BDED  04 0F 00 00 00 00 00 00 00 02 11 00 00 00 00 00  |................
BDFD  00 00 02 12 00 00 00 00 00 00 00 0A 13 E4 01 00  |................
BE0D  00 00 00 00 04 5A 00 00 00 00 00 00 00 20 5E 00  |.....Z....... ^.
BE1D  00 00 00 00 00 03 20 61 00 00 00 00 00 00 00 40  |...... a.......@
BE2D  65 00 00 00 00 00 00 03 20 66 00 00 00 00 00 00  |e....... f......
BE3D  00 06 67 00 00 00 00 00 00 00 80 69 F4 02 00 00  |..g........i....
BE4D  00 00 00 50 6B D2 02 46 00 00 00 00 40 6D 00 00  |...Pk..F....@m..
BE5D  FF 00 00 00 0A 40 6F 18 03 00 00 00 00 00 50 72  |.....@o.......Pr
BE6D  1C 03 2B 00 00 00 00 40 35 00 00 00 00 00 00 00  |..+....@5.......
BE7D  06 36 90 01 00 00 00 00 00 08 37 6E 01 00 00 00  |.6........7n....
BE8D  00 00 04 38 00 00 00 00 00 00 00 06 39 00 00 00  |...8........9...
BE9D  00 00 00 00 04 3A 00 00 00 00 00 00 00 04 3B 00  |.....:........;.
BEAD  00 00 00 00 00 00 04 3C 00 00 00 00 00 FF 00 03  |.......<........
BEBD  3E 00 00 00 00 00 00 00 08 10 00 00 00 00 00 00  |>...............
BECD  00 08 3F 00 00 00 00 00 00 00 06 3F 00 00 00 00  |..?........?....
BEDD  04 FF 06 10 3F 00 00 00 00 00 00 2C 01 3F 00 00  |....?......,.?..
BEED  00 00 00 00 0C 01 3F 00 00 00 00 00 00 0E 04 3F  |......?........?
BEFD  00 00 00 00 00 00 10 04 3F 00 00 00 00 00 00 12  |........?.......
BF0D  02 3F 00 00 00 00 00 00 14 02 3F 00 00 00 00 00  |.?........?.....
BF1D  00 16 02 3F C8 03 00 00 00 00 18 02 3F 00 00 00  |...?........?...
BF2D  00 00 00 1A 02 3F 82 03 00 00 00 00 1C 08 3F C6  |.....?........?.
BF3D  03 00 00 00 10 1E 01 3F 00 00 00 00 00 00 20 01  |.......?...... .
BF4D  3F 00 00 00 00 00 00 22 01 28 00 00 00 00 00 00  |?......".(......
BF5D  00 06 18 00 00 00 00 00 00 00 02 3F 00 00 00 00  |...........?....
BF6D  00 00 2A 02 FF FF FF FF FF FF FF FF FF FF FF FF  |..*.............
BF7D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF8D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF9D  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFAD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFBD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFCD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFDD  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFED  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFFD  FF FF 00                                         |...
