
loc_8000:  ; 0 xrefs: 
8000  4C 09 80 JMP loc_8009            

loc_8003:  ; 0 xrefs: 
8003  4C 2B 84 JMP loc_842B            

loc_8006:  ; 0 xrefs: 
8006  4C 42 BA JMP loc_BA42            

loc_8009:  ; 1 xrefs: 8000
8009  85 B8    STA $B8                 
800B  8A       TXA                     

loc_800C:  ; 0 xrefs: 
800C  48       PHA                     
800D  98       TYA                     
800E  48       PHA                     
800F  A5 B8    LDA $B8                 
8011  F0 0C    BEQ loc_801F            
8013  C9 4C    CMP #$4C                

loc_8015:  ; 0 xrefs: 
8015  B0 03    BCS loc_801A            
8017  20 7B 80 JSR sub_807B            

loc_801A:  ; 2 xrefs: 8015 803B
801A  68       PLA                     

loc_801B:  ; 0 xrefs: 
801B  A8       TAY                     
801C  68       PLA                     
801D  AA       TAX                     

loc_801E:  ; 0 xrefs: 
801E  60       RTS                     

loc_801F:  ; 1 xrefs: 8011
801F  20 3E 80 JSR sub_803E            
8022  A2 07    LDX #$07                

loc_8024:  ; 1 xrefs: 8028
8024  20 29 81 JSR sub_8129            

loc_8027:  ; 0 xrefs: 
8027  CA       DEX                     
8028  10 FA    BPL loc_8024            

loc_802A:  ; 0 xrefs: 
802A  A9 00    LDA #$00                
802C  8D E6 07 STA $07E6               

loc_802F:  ; 0 xrefs: 
802F  8D BF 07 STA $07BF               

loc_8032:  ; 0 xrefs: 
8032  8D BE 07 STA $07BE               

loc_8035:  ; 0 xrefs: 
8035  8D 54 07 STA $0754               

loc_8038:  ; 0 xrefs: 
8038  8D 55 07 STA $0755               

loc_803B:  ; 0 xrefs: 
803B  4C 1A 80 JMP loc_801A            

sub_803E:  ; 2 xrefs: 801F 84F8
803E  A9 30    LDA #$30                

loc_8040:  ; 0 xrefs: 
8040  8D 00 40 STA $4000               
8043  8D 04 40 STA $4004               
8046  8D 0C 40 STA $400C               
8049  85 DC    STA $DC                 
804B  85 E0    STA $E0                 
804D  85 E8    STA $E8                 
804F  A9 00    LDA #$00                
8051  8D 08 40 STA $4008               
8054  85 E4    STA $E4                 
8056  A9 FF    LDA #$FF                
8058  8D 0A 40 STA $400A               
805B  85 E6    STA $E6                 
805D  A9 7F    LDA #$7F                
805F  8D 01 40 STA $4001               
8062  8D 05 40 STA $4005               
8065  85 DD    STA $DD                 
8067  85 E1    STA $E1                 
8069  A9 FF    LDA #$FF                
806B  8D 03 40 STA $4003               
806E  8D 07 40 STA $4007               
8071  8D 0B 40 STA $400B               
8074  85 DF    STA $DF                 
8076  85 E3    STA $E3                 
8078  85 E7    STA $E7                 
807A  60       RTS                     

sub_807B:  ; 2 xrefs: 8017 85A2
807B  A5 B8    LDA $B8                 
807D  0A       ASL A                   
807E  A8       TAY                     
807F  B9 E9 8A LDA $8AE9,Y             
8082  85 B2    STA $B2                 
8084  B9 EA 8A LDA $8AEA,Y             
8087  85 B3    STA $B3                 
8089  A0 00    LDY #$00                
808B  B1 B2    LDA ($B2),Y             
808D  18       CLC                     
808E  2A       ROL A                   
808F  2A       ROL A                   
8090  2A       ROL A                   
8091  29 03    AND #$03                
8093  85 B4    STA $B4                 
8095  B1 B2    LDA ($B2),Y             
8097  29 3F    AND #$3F                
8099  85 B5    STA $B5                 

loc_809B:  ; 1 xrefs: 80D5
809B  C8       INY                     
809C  B1 B2    LDA ($B2),Y             
809E  29 08    AND #$08                
80A0  F0 03    BEQ loc_80A5            
80A2  4C 5B 81 JMP loc_815B            

loc_80A5:  ; 1 xrefs: 80A0
80A5  B1 B2    LDA ($B2),Y             
80A7  29 07    AND #$07                

loc_80A9:  ; 0 xrefs: 
80A9  AA       TAX                     
80AA  A5 B5    LDA $B5                 
80AC  DD 00 07 CMP $0700,X             
80AF  90 27    BCC loc_80D8            
80B1  20 29 81 JSR sub_8129            
80B4  A5 B5    LDA $B5                 
80B6  9D 00 07 STA $0700,X             
80B9  B1 B2    LDA ($B2),Y             
80BB  29 80    AND #$80                
80BD  95 C0    STA $C0,X               
80BF  A5 B8    LDA $B8                 
80C1  95 C8    STA $C8,X               
80C3  C8       INY                     
80C4  B1 B2    LDA ($B2),Y             
80C6  9D 08 07 STA $0708,X             
80C9  C8       INY                     
80CA  B1 B2    LDA ($B2),Y             
80CC  9D 10 07 STA $0710,X             
80CF  8A       TXA                     
80D0  20 DC 80 JSR sub_80DC            

loc_80D3:  ; 2 xrefs: 80DA 818C
80D3  C6 B4    DEC $B4                 
80D5  10 C4    BPL loc_809B            
80D7  60       RTS                     

loc_80D8:  ; 1 xrefs: 80AF
80D8  C8       INY                     
80D9  C8       INY                     
80DA  D0 F7    BNE loc_80D3            

sub_80DC:  ; 2 xrefs: 80D0 857C
80DC  C9 03    CMP #$03                
80DE  F0 48    BEQ loc_8128            
80E0  C9 04    CMP #$04                
80E2  B0 06    BCS loc_80EA            
80E4  AA       TAX                     
80E5  B5 CC    LDA $CC,X               
80E7  D0 3F    BNE loc_8128            
80E9  8A       TXA                     

loc_80EA:  ; 1 xrefs: 80E2
80EA  29 03    AND #$03                
80EC  C9 02    CMP #$02                
80EE  D0 19    BNE loc_8109            
80F0  A2 FF    LDX #$FF                
80F2  8E 0A 40 STX $400A               
80F5  8E 0B 40 STX $400B               
80F8  86 E6    STX $E6                 
80FA  86 E7    STX $E7                 
80FC  A2 00    LDX #$00                
80FE  8E 08 40 STX $4008               
8101  8E 09 40 STX $4009               
8104  86 E4    STX $E4                 
8106  86 E5    STX $E5                 
8108  60       RTS                     

loc_8109:  ; 1 xrefs: 80EE
8109  0A       ASL A                   
810A  0A       ASL A                   
810B  AA       TAX                     
810C  A9 30    LDA #$30                
810E  9D 00 40 STA $4000,X             
8111  95 DC    STA $DC,X               
8113  A9 7F    LDA #$7F                
8115  9D 01 40 STA $4001,X             
8118  95 DD    STA $DD,X               
811A  A9 00    LDA #$00                
811C  9D 02 40 STA $4002,X             
811F  95 DE    STA $DE,X               
8121  A9 FF    LDA #$FF                
8123  9D 03 40 STA $4003,X             
8126  95 DF    STA $DF,X               

loc_8128:  ; 2 xrefs: 80DE 80E7
8128  60       RTS                     

sub_8129:  ; 2 xrefs: 8024 80B1
8129  A9 00    LDA #$00                
812B  E0 03    CPX #$03                
812D  B0 0E    BCS loc_813D            
812F  E0 00    CPX #$00                
8131  9D 80 07 STA $0780,X             
8134  9D 50 07 STA $0750,X             
8137  9D F3 07 STA $07F3,X             
813A  9D FE 07 STA $07FE,X             

loc_813D:  ; 1 xrefs: 812D
813D  95 C8    STA $C8,X               
813F  9D 00 07 STA $0700,X             
8142  95 C0    STA $C0,X               
8144  9D 30 07 STA $0730,X             
8147  9D 78 07 STA $0778,X             
814A  A9 01    LDA #$01                
814C  9D 28 07 STA $0728,X             
814F  B5 C0    LDA $C0,X               
8151  29 FE    AND #$FE                
8153  95 C0    STA $C0,X               
8155  A9 7F    LDA #$7F                
8157  9D 90 07 STA $0790,X             
815A  60       RTS                     

loc_815B:  ; 1 xrefs: 80A2
815B  A9 0F    LDA #$0F                
815D  8D 15 40 STA $4015               
8160  C8       INY                     
8161  B1 B2    LDA ($B2),Y             
8163  85 BC    STA $BC                 
8165  C8       INY                     
8166  B1 B2    LDA ($B2),Y             
8168  85 BD    STA $BD                 
816A  84 B5    STY $B5                 
816C  A0 00    LDY #$00                
816E  B1 BC    LDA ($BC),Y             
8170  8D 10 40 STA $4010               
8173  C8       INY                     
8174  B1 BC    LDA ($BC),Y             
8176  8D 11 40 STA $4011               
8179  C8       INY                     
817A  B1 BC    LDA ($BC),Y             
817C  8D 12 40 STA $4012               
817F  C8       INY                     
8180  B1 BC    LDA ($BC),Y             
8182  8D 13 40 STA $4013               
8185  A9 1F    LDA #$1F                
8187  8D 15 40 STA $4015               
818A  A4 B5    LDY $B5                 
818C  4C D3 80 JMP loc_80D3            

loc_818F:  ; 2 xrefs: 8534 8704
818F  C9 E0    CMP #$E0                
8191  90 16    BCC loc_81A9            
8193  38       SEC                     
8194  E9 E0    SBC #$E0                
8196  0A       ASL A                   
8197  AA       TAX                     
8198  BD EB 83 LDA $83EB,X             
819B  85 BC    STA $BC                 
819D  BD EC 83 LDA $83EC,X             
81A0  85 BD    STA $BD                 
81A2  A6 B9    LDX $B9                 
81A4  B1 BA    LDA ($BA),Y             
81A6  6C BC 00 JMP ($00BC)             

loc_81A9:  ; 1 xrefs: 8191
81A9  29 0F    AND #$0F                
81AB  9D 18 07 STA $0718,X             
81AE  E0 03    CPX #$03                
81B0  F0 30    BEQ loc_81E2            
81B2  C8       INY                     
81B3  B1 BA    LDA ($BA),Y             
81B5  9D 20 07 STA $0720,X             
81B8  E0 02    CPX #$02                
81BA  F0 22    BEQ loc_81DE            
81BC  C8       INY                     
81BD  B1 BA    LDA ($BA),Y             
81BF  F0 28    BEQ loc_81E9            
81C1  9D A8 07 STA $07A8,X             
81C4  B5 C0    LDA $C0,X               
81C6  29 F7    AND #$F7                
81C8  95 C0    STA $C0,X               
81CA  C8       INY                     
81CB  B1 BA    LDA ($BA),Y             
81CD  29 1F    AND #$1F                
81CF  9D AA 07 STA $07AA,X             
81D2  C8       INY                     
81D3  B1 BA    LDA ($BA),Y             
81D5  9D AE 07 STA $07AE,X             
81D8  C8       INY                     
81D9  B1 BA    LDA ($BA),Y             
81DB  9D AC 07 STA $07AC,X             

loc_81DE:  ; 2 xrefs: 81BA 81E7
81DE  C8       INY                     
81DF  4C 2E 85 JMP loc_852E            

loc_81E2:  ; 1 xrefs: 81B0
81E2  A9 00    LDA #$00                
81E4  8D DA 07 STA $07DA               
81E7  F0 F5    BEQ loc_81DE            

loc_81E9:  ; 1 xrefs: 81BF
81E9  C8       INY                     
81EA  B1 BA    LDA ($BA),Y             
81EC  84 BF    STY $BF                 
81EE  29 3F    AND #$3F                
81F0  0A       ASL A                   
81F1  85 BE    STA $BE                 
81F3  A4 BE    LDY $BE                 
81F5  B9 A7 8D LDA $8DA7,Y             
81F8  85 BC    STA $BC                 
81FA  9D C4 07 STA $07C4,X             
81FD  B9 A8 8D LDA $8DA8,Y             
8200  85 BD    STA $BD                 
8202  9D C6 07 STA $07C6,X             
8205  B5 C0    LDA $C0,X               
8207  09 08    ORA #$08                
8209  95 C0    STA $C0,X               
820B  A4 BF    LDY $BF                 
820D  C8       INY                     
820E  4C 2E 85 JMP loc_852E            

; ==== data $8211..$824F  (63 bytes) ====
8211  29 0F 9D 48 07 10 C6 C8 B1 BA 9D A8 07 B5 C0 29  |)..H...........)
8221  F7 95 C0 C8 4C 2E 85 C8 B1 BA 29 1F 9D AA 07 B5  |....L.....).....
8231  C0 29 F7 95 C0 C8 4C 2E 85 C8 B1 BA 9D AE 07 C8  |.)....L.........
8241  B1 BA 9D AC 07 B5 C0 29 F7 95 C0 C8 4C 2E 85     |.......)....L..

loc_8250:  ; 0 xrefs: 
8250  C8       INY                     
8251  B1 BA    LDA ($BA),Y             
8253  F0 2E    BEQ loc_8283            
8255  0A       ASL A                   
8256  85 BE    STA $BE                 
8258  C8       INY                     
8259  B1 BA    LDA ($BA),Y             
825B  9D CC 07 STA $07CC,X             
825E  84 BF    STY $BF                 
8260  A4 BE    LDY $BE                 
8262  B9 CC 8E LDA $8ECC,Y             
8265  85 BC    STA $BC                 
8267  9D B8 07 STA $07B8,X             
826A  B9 CD 8E LDA $8ECD,Y             
826D  85 BD    STA $BD                 
826F  9D BB 07 STA $07BB,X             
8272  A9 00    LDA #$00                
8274  9D B0 07 STA $07B0,X             
8277  B5 C0    LDA $C0,X               
8279  09 04    ORA #$04                
827B  95 C0    STA $C0,X               
827D  A4 BF    LDY $BF                 
827F  C8       INY                     
8280  4C 2E 85 JMP loc_852E            

loc_8283:  ; 1 xrefs: 8253
8283  B5 C0    LDA $C0,X               
8285  29 FB    AND #$FB                
8287  95 C0    STA $C0,X               
8289  C8       INY                     
828A  4C 2E 85 JMP loc_852E            

; ==== data $828D..$82BC  (48 bytes) ====
828D  C8 B1 BA 9D 50 07 C8 4C 27 85 C8 B1 BA 9D 80 07  |....P..L'.......
829D  C8 4C 27 85 C8 A6 B9 E0 02 B0 07 B1 BA 29 0F 9D  |.L'..........)..
82AD  D8 07 C8 4C 27 85 C8 B1 BA 8D DA 07 C8 4C 2E 85  |...L'........L..

loc_82BD:  ; 0 xrefs: 
82BD  A9 01    LDA #$01                
82BF  9D F3 07 STA $07F3,X             
82C2  4C CA 82 JMP loc_82CA            

; ==== data $82C5..$82C9  (5 bytes) ====
82C5  A9 03 9D F3 07                                   |.....

loc_82CA:  ; 1 xrefs: 82C2
82CA  C8       INY                     
82CB  B1 BA    LDA ($BA),Y             
82CD  F0 36    BEQ loc_8305            
82CF  9D E8 07 STA $07E8,X             
82D2  C8       INY                     
82D3  B1 BA    LDA ($BA),Y             
82D5  9D E0 07 STA $07E0,X             
82D8  C8       INY                     
82D9  84 BF    STY $BF                 
82DB  A9 00    LDA #$00                
82DD  9D EB 07 STA $07EB,X             
82E0  9D F0 07 STA $07F0,X             
82E3  BC E0 07 LDY $07E0,X             
82E6  BD E8 07 LDA $07E8,X             

loc_82E9:  ; 1 xrefs: 82FE
82E9  18       CLC                     
82EA  BD E8 07 LDA $07E8,X             
82ED  7D EB 07 ADC $07EB,X             
82F0  9D EB 07 STA $07EB,X             
82F3  90 08    BCC loc_82FD            
82F5  A9 00    LDA #$00                
82F7  7D F0 07 ADC $07F0,X             
82FA  9D F0 07 STA $07F0,X             

loc_82FD:  ; 1 xrefs: 82F3
82FD  88       DEY                     
82FE  D0 E9    BNE loc_82E9            
8300  A4 BF    LDY $BF                 
8302  4C 2E 85 JMP loc_852E            

loc_8305:  ; 1 xrefs: 82CD
8305  A9 00    LDA #$00                
8307  9D F0 07 STA $07F0,X             
830A  9D EB 07 STA $07EB,X             
830D  9D F3 07 STA $07F3,X             
8310  9D E0 07 STA $07E0,X             
8313  9D E3 07 STA $07E3,X             
8316  9D E8 07 STA $07E8,X             
8319  C8       INY                     
831A  4C 2E 85 JMP loc_852E            

; ==== data $831D..$8342  (38 bytes) ====
831D  C8 B1 BA 9D FE 07 C8 4C 2E 85 C8 B1 BA 9D 18 07  |.......L........
832D  C8 4C 27 85 C8 B1 BA 9D 20 07 C8 4C 27 85 C8 20  |.L'..... ..L'.. 
833D  D1 83 C8 4C 27 85                                |...L'.

loc_8343:  ; 0 xrefs: 
8343  C8       INY                     
8344  98       TYA                     
8345  18       CLC                     
8346  65 BA    ADC $BA                 
8348  9D 68 07 STA $0768,X             
834B  A9 00    LDA #$00                
834D  65 BB    ADC $BB                 
834F  9D 70 07 STA $0770,X             
8352  4C 27 85 JMP loc_8527            

; ==== data $8355..$83A4  (80 bytes) ====
8355  BD 58 07 85 BA BD 60 07 85 BB A5 C0 29 BF 85 C0  |.X....`.....)...
8365  A0 00 4C 27 85 C8 B1 BA 9D 08 07 C8 B1 BA 9D 10  |..L'............
8375  07 B5 C0 09 40 95 C0 C8 98 18 65 BA 9D 58 07 A9  |....@.....e..X..
8385  00 A8 65 BB 9D 60 07 4C 1B 85 C8 B1 BA 30 03 FE  |..e..`.L.....0..
8395  78 07 BD 78 07 D1 BA B0 0F BD 68 07 85 BA BD 70  |x..x......h....p

loc_83A5:  ; 0 xrefs: 
83A5  07 85    SLO $85                 

; ==== data $83A7..$83BD  (23 bytes) ====
83A7  BB A0 00 4C 27 85 A9 00 9D 78 07 C8 4C 27 85 20  |...L'....x..L'. 
83B7  29 81 8A 20 DC 80 60                             |).. ..`

loc_83BE:  ; 1 xrefs: 86FB
83BE  B1 BA    LDA ($BA),Y             
83C0  9D 18 07 STA $0718,X             
83C3  C8       INY                     
83C4  B1 BA    LDA ($BA),Y             
83C6  9D 20 07 STA $0720,X             
83C9  C8       INY                     
83CA  20 D1 83 JSR sub_83D1            
83CD  C8       INY                     
83CE  4C F5 86 JMP loc_86F5            

sub_83D1:  ; 1 xrefs: 83CA
83D1  B1 BA    LDA ($BA),Y             
83D3  9D 90 07 STA $0790,X             
83D6  10 07    BPL loc_83DF            
83D8  B5 C0    LDA $C0,X               
83DA  09 01    ORA #$01                
83DC  95 C0    STA $C0,X               
83DE  60       RTS                     

loc_83DF:  ; 1 xrefs: 83D6
83DF  B5 C0    LDA $C0,X               
83E1  29 FE    AND #$FE                
83E3  95 C0    STA $C0,X               
83E5  A9 7F    LDA #$7F                
83E7  9D 90 07 STA $0790,X             
83EA  60       RTS                     

; ==== data $83EB..$842A  (64 bytes) ====
83EB  11 82 11 82 11 82 11 82 11 82 11 82 DE 81 DE 81  |................
83FB  18 82 28 82 3A 82 50 82 8D 82 DE 81 97 82 B3 82  |..(.:.P.........
840B  A1 82 B3 82 BD 82 C5 82 E9 81 1D 83 DE 81 DE 81  |................
841B  27 83 31 83 3B 83 43 83 55 83 6A 83 8F 83 B6 83  |'.1.;.C.U.j.....

loc_842B:  ; 1 xrefs: 8003
842B  8A       TXA                     
842C  48       PHA                     
842D  98       TYA                     
842E  48       PHA                     
842F  20 EA 84 JSR sub_84EA            
8432  A2 00    LDX #$00                

loc_8434:  ; 1 xrefs: 8453
8434  86 B9    STX $B9                 
8436  B5 C8    LDA $C8,X               
8438  F0 14    BEQ loc_844E            
843A  AC DB 07 LDY $07DB               
843D  F0 0C    BEQ loc_844B            
843F  C9 30    CMP #$30                
8441  F0 08    BEQ loc_844B            
8443  C9 1F    CMP #$1F                
8445  F0 04    BEQ loc_844B            
8447  C9 17    CMP #$17                
8449  D0 03    BNE loc_844E            

loc_844B:  ; 3 xrefs: 843D 8441 8445
844B  20 FD 84 JSR sub_84FD            

loc_844E:  ; 2 xrefs: 8438 8449
844E  A6 B9    LDX $B9                 
8450  E8       INX                     
8451  E0 08    CPX #$08                
8453  90 DF    BCC loc_8434            
8455  A0 00    LDY #$00                
8457  A2 04    LDX #$04                

loc_8459:  ; 1 xrefs: 84E2
8459  86 BE    STX $BE                 
845B  8A       TXA                     
845C  29 03    AND #$03                
845E  85 BF    STA $BF                 
8460  B5 C8    LDA $C8,X               
8462  D0 06    BNE loc_846A            
8464  A6 BF    LDX $BF                 
8466  B5 C8    LDA $C8,X               
8468  F0 71    BEQ loc_84DB            

loc_846A:  ; 1 xrefs: 8462
846A  C9 30    CMP #$30                
846C  F0 0D    BEQ loc_847B            
846E  C9 1F    CMP #$1F                
8470  F0 09    BEQ loc_847B            
8472  C9 17    CMP #$17                
8474  F0 05    BEQ loc_847B            
8476  AD DB 07 LDA $07DB               
8479  D0 60    BNE loc_84DB            

loc_847B:  ; 3 xrefs: 846C 8470 8474
847B  B5 C0    LDA $C0,X               
847D  29 02    AND #$02                
847F  D0 5A    BNE loc_84DB            
8481  E0 03    CPX #$03                
8483  F0 56    BEQ loc_84DB            
8485  8A       TXA                     
8486  0A       ASL A                   
8487  0A       ASL A                   
8488  29 0F    AND #$0F                
848A  A8       TAY                     
848B  BD 88 07 LDA $0788,X             
848E  D9 DC 00 CMP $00DC,Y             
8491  F0 06    BEQ loc_8499            
8493  99 00 40 STA $4000,Y             
8496  99 DC 00 STA $00DC,Y             

loc_8499:  ; 1 xrefs: 8491
8499  BD 90 07 LDA $0790,X             
849C  D9 DD 00 CMP $00DD,Y             
849F  F0 06    BEQ loc_84A7            
84A1  99 01 40 STA $4001,Y             
84A4  99 DD 00 STA $00DD,Y             

loc_84A7:  ; 1 xrefs: 849F
84A7  B5 C0    LDA $C0,X               
84A9  29 01    AND #$01                
84AB  D0 0A    BNE loc_84B7            

loc_84AD:  ; 1 xrefs: 84BA
84AD  BD 98 07 LDA $0798,X             
84B0  D9 DE 00 CMP $00DE,Y             
84B3  F0 10    BEQ loc_84C5            
84B5  D0 05    BNE loc_84BC            

loc_84B7:  ; 1 xrefs: 84AB
84B7  BD 30 07 LDA $0730,X             
84BA  D0 F1    BNE loc_84AD            

loc_84BC:  ; 1 xrefs: 84B5
84BC  BD 98 07 LDA $0798,X             
84BF  99 02 40 STA $4002,Y             
84C2  99 DE 00 STA $00DE,Y             

loc_84C5:  ; 1 xrefs: 84B3
84C5  BD 30 07 LDA $0730,X             
84C8  F0 08    BEQ loc_84D2            
84CA  BD A0 07 LDA $07A0,X             
84CD  D9 DF 00 CMP $00DF,Y             
84D0  F0 09    BEQ loc_84DB            

loc_84D2:  ; 1 xrefs: 84C8
84D2  BD A0 07 LDA $07A0,X             
84D5  99 03 40 STA $4003,Y             
84D8  99 DF 00 STA $00DF,Y             

loc_84DB:  ; 5 xrefs: 8468 8479 847F 8483 84D0
84DB  A6 BE    LDX $BE                 
84DD  E8       INX                     
84DE  E0 08    CPX #$08                
84E0  B0 03    BCS loc_84E5            
84E2  4C 59 84 JMP loc_8459            

loc_84E5:  ; 1 xrefs: 84E0
84E5  68       PLA                     
84E6  A8       TAY                     
84E7  68       PLA                     
84E8  AA       TAX                     

loc_84E9:  ; 1 xrefs: 84EF
84E9  60       RTS                     

sub_84EA:  ; 1 xrefs: 842F
84EA  A5 4D    LDA $4D                 
84EC  CD DB 07 CMP $07DB               
84EF  F0 F8    BEQ loc_84E9            
84F1  8D DB 07 STA $07DB               
84F4  C9 00    CMP #$00                
84F6  F0 03    BEQ loc_84FB            
84F8  4C 3E 80 JMP sub_803E            

loc_84FB:  ; 1 xrefs: 84F6
84FB  60       RTS                     

loc_84FC:  ; 1 xrefs: 8510
84FC  60       RTS                     

sub_84FD:  ; 1 xrefs: 844B
84FD  AD DB 07 LDA $07DB               
8500  F0 11    BEQ loc_8513            
8502  B5 C8    LDA $C8,X               
8504  C9 30    CMP #$30                
8506  F0 0B    BEQ loc_8513            
8508  C9 1F    CMP #$1F                
850A  F0 07    BEQ loc_8513            
850C  C9 17    CMP #$17                
850E  F0 03    BEQ loc_8513            
8510  4C FC 84 JMP loc_84FC            

loc_8513:  ; 4 xrefs: 8500 8506 850A 850E
8513  FE 30 07 INC $0730,X             
8516  DE 28 07 DEC $0728,X             
8519  D0 1C    BNE loc_8537            

loc_851B:  ; 0 xrefs: 
851B  BD 08 07 LDA $0708,X             
851E  85 BA    STA $BA                 
8520  BD 10 07 LDA $0710,X             
8523  85 BB    STA $BB                 
8525  A0 00    LDY #$00                

loc_8527:  ; 1 xrefs: 8352
8527  B5 C0    LDA $C0,X               
8529  10 03    BPL loc_852E            
852B  4C F5 86 JMP loc_86F5            

loc_852E:  ; 7 xrefs: 81DF 820E 8280 828A 8302 831A 8529
852E  B1 BA    LDA ($BA),Y             
8530  C9 D0    CMP #$D0                
8532  90 78    BCC loc_85AC            
8534  4C 8F 81 JMP loc_818F            

loc_8537:  ; 1 xrefs: 8519
8537  8A       TXA                     
8538  C9 02    CMP #$02                
853A  F0 15    BEQ loc_8551            
853C  29 02    AND #$02                
853E  D0 04    BNE loc_8544            
8540  B5 C0    LDA $C0,X               
8542  10 01    BPL loc_8545            

loc_8544:  ; 1 xrefs: 853E
8544  60       RTS                     

loc_8545:  ; 1 xrefs: 8542
8545  20 66 89 JSR sub_8966            
8548  20 4F 89 JSR sub_894F            
854B  1D D0 07 ORA $07D0,X             
854E  9D 88 07 STA $0788,X             

loc_8551:  ; 1 xrefs: 853A
8551  B5 C0    LDA $C0,X               
8553  29 04    AND #$04                
8555  F0 11    BEQ loc_8568            
8557  20 43 87 JSR sub_8743            
855A  BD D2 07 LDA $07D2,X             
855D  9D 98 07 STA $0798,X             
8560  BD D5 07 LDA $07D5,X             
8563  09 F8    ORA #$F8                
8565  9D A0 07 STA $07A0,X             

loc_8568:  ; 1 xrefs: 8555
8568  BD F3 07 LDA $07F3,X             
856B  F0 07    BEQ loc_8574            
856D  29 04    AND #$04                
856F  F0 03    BEQ loc_8574            
8571  20 64 88 JSR sub_8864            

loc_8574:  ; 2 xrefs: 856B 856F
8574  60       RTS                     

loc_8575:  ; 1 xrefs: 85E3
8575  B5 C0    LDA $C0,X               
8577  09 02    ORA #$02                
8579  95 C0    STA $C0,X               
857B  8A       TXA                     
857C  20 DC 80 JSR sub_80DC            
857F  A6 B9    LDX $B9                 
8581  4C 71 86 JMP loc_8671            

loc_8584:  ; 1 xrefs: 85ED
8584  B1 BA    LDA ($BA),Y             
8586  4A       LSR A                   
8587  4A       LSR A                   
8588  4A       LSR A                   
8589  4A       LSR A                   
858A  AE DA 07 LDX $07DA               

loc_858D:  ; 1 xrefs: 8593
858D  CA       DEX                     
858E  30 05    BMI loc_8595            
8590  18       CLC                     
8591  69 0C    ADC #$0C                
8593  D0 F8    BNE loc_858D            

loc_8595:  ; 1 xrefs: 858E
8595  84 BE    STY $BE                 
8597  A8       TAY                     
8598  B9 95 90 LDA $9095,Y             
859B  85 B8    STA $B8                 
859D  AD 55 07 LDA $0755               
85A0  D0 03    BNE loc_85A5            
85A2  20 7B 80 JSR sub_807B            

loc_85A5:  ; 1 xrefs: 85A0
85A5  A4 BE    LDY $BE                 
85A7  A6 B9    LDX $B9                 
85A9  4C 71 86 JMP loc_8671            

loc_85AC:  ; 1 xrefs: 8532
85AC  4C B8 85 JMP loc_85B8            

loc_85AF:  ; 1 xrefs: 85BC
85AF  BD 18 07 LDA $0718,X             
85B2  0A       ASL A                   
85B3  0A       ASL A                   
85B4  0A       ASL A                   
85B5  0A       ASL A                   
85B6  D0 1F    BNE loc_85D7            

loc_85B8:  ; 1 xrefs: 85AC
85B8  B1 BA    LDA ($BA),Y             
85BA  29 0F    AND #$0F                
85BC  F0 F1    BEQ loc_85AF            
85BE  85 BE    STA $BE                 
85C0  BD 18 07 LDA $0718,X             
85C3  85 BF    STA $BF                 
85C5  A9 00    LDA #$00                
85C7  A2 04    LDX #$04                

loc_85C9:  ; 1 xrefs: 85D3
85C9  46 BF    LSR $BF                 
85CB  90 03    BCC loc_85D0            
85CD  18       CLC                     
85CE  65 BE    ADC $BE                 

loc_85D0:  ; 1 xrefs: 85CB
85D0  06 BE    ASL $BE                 
85D2  CA       DEX                     
85D3  D0 F4    BNE loc_85C9            
85D5  A6 B9    LDX $B9                 

loc_85D7:  ; 1 xrefs: 85B6
85D7  9D 28 07 STA $0728,X             
85DA  A9 00    LDA #$00                
85DC  9D 30 07 STA $0730,X             
85DF  B1 BA    LDA ($BA),Y             
85E1  C9 C0    CMP #$C0                
85E3  B0 90    BCS loc_8575            
85E5  B5 C0    LDA $C0,X               
85E7  29 FD    AND #$FD                
85E9  95 C0    STA $C0,X               
85EB  E0 03    CPX #$03                
85ED  F0 95    BEQ loc_8584            
85EF  BD 48 07 LDA $0748,X             
85F2  AA       TAX                     
85F3  A9 00    LDA #$00                

loc_85F5:  ; 1 xrefs: 85FD
85F5  E0 05    CPX #$05                
85F7  F0 06    BEQ loc_85FF            
85F9  18       CLC                     
85FA  69 0C    ADC #$0C                
85FC  E8       INX                     
85FD  D0 F6    BNE loc_85F5            

loc_85FF:  ; 1 xrefs: 85F7
85FF  A6 B9    LDX $B9                 
8601  85 BE    STA $BE                 
8603  20 87 86 JSR sub_8687            
8606  B1 BA    LDA ($BA),Y             
8608  29 F0    AND #$F0                
860A  4A       LSR A                   
860B  4A       LSR A                   
860C  4A       LSR A                   
860D  06 BE    ASL $BE                 
860F  18       CLC                     
8610  65 BE    ADC $BE                 
8612  84 BE    STY $BE                 
8614  A8       TAY                     
8615  B9 41 8A LDA $8A41,Y             
8618  18       CLC                     
8619  7D 80 07 ADC $0780,X             
861C  9D 38 07 STA $0738,X             
861F  B9 42 8A LDA $8A42,Y             
8622  69 00    ADC #$00                
8624  9D 40 07 STA $0740,X             
8627  A4 BE    LDY $BE                 
8629  E0 02    CPX #$02                
862B  F0 54    BEQ loc_8681            
862D  8A       TXA                     
862E  29 02    AND #$02                
8630  D0 4E    BNE loc_8680            
8632  B5 C0    LDA $C0,X               
8634  29 08    AND #$08                
8636  F0 68    BEQ loc_86A0            
8638  20 ED 87 JSR sub_87ED            

loc_863B:  ; 2 xrefs: 86CB 86F2
863B  20 4F 89 JSR sub_894F            
863E  1D D0 07 ORA $07D0,X             

loc_8641:  ; 1 xrefs: 8684
8641  9D 88 07 STA $0788,X             
8644  B5 C0    LDA $C0,X               
8646  29 04    AND #$04                
8648  F0 0F    BEQ loc_8659            
864A  20 34 87 JSR sub_8734            
864D  BD D2 07 LDA $07D2,X             
8650  9D 98 07 STA $0798,X             
8653  BD D5 07 LDA $07D5,X             
8656  4C 62 86 JMP loc_8662            

loc_8659:  ; 1 xrefs: 8648
8659  BD 38 07 LDA $0738,X             
865C  9D 98 07 STA $0798,X             
865F  BD 40 07 LDA $0740,X             

loc_8662:  ; 1 xrefs: 8656
8662  09 F8    ORA #$F8                
8664  9D A0 07 STA $07A0,X             
8667  BD F3 07 LDA $07F3,X             
866A  29 01    AND #$01                
866C  F0 03    BEQ loc_8671            
866E  20 70 88 JSR sub_8870            

loc_8671:  ; 4 xrefs: 8581 85A9 866C 8731
8671  C8       INY                     
8672  98       TYA                     
8673  18       CLC                     
8674  65 BA    ADC $BA                 
8676  9D 08 07 STA $0708,X             
8679  A9 00    LDA #$00                
867B  65 BB    ADC $BB                 
867D  9D 10 07 STA $0710,X             

loc_8680:  ; 1 xrefs: 8630
8680  60       RTS                     

loc_8681:  ; 1 xrefs: 862B
8681  BD 20 07 LDA $0720,X             
8684  4C 41 86 JMP loc_8641            

sub_8687:  ; 1 xrefs: 8603
8687  BD 50 07 LDA $0750,X             
868A  30 08    BMI loc_8694            
868C  29 0F    AND #$0F                
868E  18       CLC                     
868F  65 BE    ADC $BE                 
8691  85 BE    STA $BE                 
8693  60       RTS                     

loc_8694:  ; 1 xrefs: 868A
8694  29 0F    AND #$0F                
8696  49 FF    EOR #$FF                
8698  18       CLC                     
8699  65 BE    ADC $BE                 
869B  85 BE    STA $BE                 
869D  E6 BE    INC $BE                 
869F  60       RTS                     

loc_86A0:  ; 1 xrefs: 8636
86A0  B5 C0    LDA $C0,X               
86A2  29 CF    AND #$CF                
86A4  09 10    ORA #$10                
86A6  95 C0    STA $C0,X               
86A8  BD AA 07 LDA $07AA,X             
86AB  29 0F    AND #$0F                
86AD  9D C8 07 STA $07C8,X             
86B0  BD A8 07 LDA $07A8,X             
86B3  30 28    BMI loc_86DD            
86B5  0A       ASL A                   
86B6  0A       ASL A                   
86B7  0A       ASL A                   
86B8  0A       ASL A                   
86B9  18       CLC                     
86BA  7D A8 07 ADC $07A8,X             
86BD  90 02    BCC loc_86C1            
86BF  A9 F0    LDA #$F0                

loc_86C1:  ; 1 xrefs: 86BD
86C1  4A       LSR A                   
86C2  4A       LSR A                   
86C3  4A       LSR A                   
86C4  4A       LSR A                   
86C5  20 CE 86 JSR sub_86CE            
86C8  9D D0 07 STA $07D0,X             
86CB  4C 3B 86 JMP loc_863B            

sub_86CE:  ; 4 xrefs: 86C5 89C6 8A05 8A27
86CE  38       SEC                     
86CF  ED BF 07 SBC $07BF               
86D2  90 05    BCC loc_86D9            
86D4  DD D8 07 CMP $07D8,X             
86D7  B0 03    BCS loc_86DC            

loc_86D9:  ; 1 xrefs: 86D2
86D9  BD D8 07 LDA $07D8,X             

loc_86DC:  ; 1 xrefs: 86D7
86DC  60       RTS                     

loc_86DD:  ; 1 xrefs: 86B3
86DD  4A       LSR A                   
86DE  4A       LSR A                   
86DF  4A       LSR A                   
86E0  4A       LSR A                   
86E1  85 BE    STA $BE                 
86E3  BD A8 07 LDA $07A8,X             
86E6  29 0F    AND #$0F                
86E8  38       SEC                     
86E9  E5 BE    SBC $BE                 
86EB  B0 02    BCS loc_86EF            
86ED  A9 01    LDA #$01                

loc_86EF:  ; 1 xrefs: 86EB
86EF  9D D0 07 STA $07D0,X             
86F2  4C 3B 86 JMP loc_863B            

loc_86F5:  ; 2 xrefs: 83CE 852B
86F5  B1 BA    LDA ($BA),Y             
86F7  29 F0    AND #$F0                
86F9  D0 03    BNE loc_86FE            
86FB  4C BE 83 JMP loc_83BE            

loc_86FE:  ; 1 xrefs: 86F9
86FE  B1 BA    LDA ($BA),Y             
8700  C9 F8    CMP #$F8                
8702  90 03    BCC loc_8707            
8704  4C 8F 81 JMP loc_818F            

loc_8707:  ; 1 xrefs: 8702
8707  4A       LSR A                   
8708  4A       LSR A                   
8709  4A       LSR A                   
870A  4A       LSR A                   
870B  85 BE    STA $BE                 
870D  BD 20 07 LDA $0720,X             
8710  29 F0    AND #$F0                
8712  05 BE    ORA $BE                 
8714  9D 88 07 STA $0788,X             
8717  B1 BA    LDA ($BA),Y             
8719  29 07    AND #$07                
871B  09 F8    ORA #$F8                
871D  9D A0 07 STA $07A0,X             
8720  C8       INY                     
8721  B1 BA    LDA ($BA),Y             
8723  9D 98 07 STA $0798,X             
8726  BD 18 07 LDA $0718,X             
8729  9D 28 07 STA $0728,X             
872C  A9 00    LDA #$00                
872E  9D 30 07 STA $0730,X             
8731  4C 71 86 JMP loc_8671            

sub_8734:  ; 1 xrefs: 864A
8734  A9 FF    LDA #$FF                
8736  9D B0 07 STA $07B0,X             
8739  A9 00    LDA #$00                
873B  9D CC 07 STA $07CC,X             
873E  A9 01    LDA #$01                
8740  9D B3 07 STA $07B3,X             

sub_8743:  ; 1 xrefs: 8557
8743  DE B3 07 DEC $07B3,X             
8746  D0 32    BNE loc_877A            
8748  FE B0 07 INC $07B0,X             

loc_874B:  ; 2 xrefs: 87A0 87A9
874B  20 AC 87 JSR sub_87AC            
874E  85 BF    STA $BF                 
8750  C9 FB    CMP #$FB                
8752  F0 43    BEQ loc_8797            
8754  C9 FE    CMP #$FE                
8756  F0 4B    BEQ loc_87A3            
8758  C9 FF    CMP #$FF                
875A  F0 1F    BEQ loc_877B            
875C  29 0F    AND #$0F                
875E  9D B3 07 STA $07B3,X             
8761  A5 BF    LDA $BF                 
8763  4A       LSR A                   
8764  4A       LSR A                   
8765  4A       LSR A                   
8766  4A       LSR A                   
8767  C9 08    CMP #$08                
8769  B0 14    BCS loc_877F            
876B  18       CLC                     
876C  7D 38 07 ADC $0738,X             
876F  9D D2 07 STA $07D2,X             
8772  A9 00    LDA #$00                
8774  7D 40 07 ADC $0740,X             
8777  9D D5 07 STA $07D5,X             

loc_877A:  ; 1 xrefs: 8746
877A  60       RTS                     

loc_877B:  ; 1 xrefs: 875A
877B  9D B3 07 STA $07B3,X             
877E  60       RTS                     

loc_877F:  ; 1 xrefs: 8769
877F  49 0F    EOR #$0F                
8781  85 BF    STA $BF                 
8783  E6 BF    INC $BF                 
8785  BD 38 07 LDA $0738,X             
8788  38       SEC                     
8789  E5 BF    SBC $BF                 
878B  9D D2 07 STA $07D2,X             
878E  BD 40 07 LDA $0740,X             
8791  E9 00    SBC #$00                
8793  9D D5 07 STA $07D5,X             
8796  60       RTS                     

loc_8797:  ; 1 xrefs: 8752
8797  FE B0 07 INC $07B0,X             
879A  BD B0 07 LDA $07B0,X             
879D  9D CC 07 STA $07CC,X             
87A0  4C 4B 87 JMP loc_874B            

loc_87A3:  ; 1 xrefs: 8756
87A3  BD CC 07 LDA $07CC,X             

loc_87A6:  ; 0 xrefs: 
87A6  9D B0 07 STA $07B0,X             
87A9  4C 4B 87 JMP loc_874B            

sub_87AC:  ; 1 xrefs: 874B
87AC  84 BE    STY $BE                 
87AE  BC B0 07 LDY $07B0,X             
87B1  BD B8 07 LDA $07B8,X             
87B4  85 BC    STA $BC                 
87B6  BD BB 07 LDA $07BB,X             
87B9  85 BD    STA $BD                 
87BB  B1 BC    LDA ($BC),Y             
87BD  A4 BE    LDY $BE                 
87BF  60       RTS                     

loc_87C0:  ; 1 xrefs: 8824
87C0  C8       INY                     
87C1  B1 BC    LDA ($BC),Y             
87C3  30 03    BMI loc_87C8            
87C5  FE EE 07 INC $07EE,X             

loc_87C8:  ; 1 xrefs: 87C3
87C8  BD EE 07 LDA $07EE,X             
87CB  D1 BC    CMP ($BC),Y             
87CD  B0 0B    BCS loc_87DA            
87CF  BD F6 07 LDA $07F6,X             
87D2  9D C0 07 STA $07C0,X             
87D5  A4 BE    LDY $BE                 
87D7  4C 0D 88 JMP loc_880D            

loc_87DA:  ; 1 xrefs: 87CD
87DA  A9 00    LDA #$00                
87DC  9D EE 07 STA $07EE,X             
87DF  18       CLC                     
87E0  A9 02    LDA #$02                
87E2  7D C0 07 ADC $07C0,X             
87E5  9D C0 07 STA $07C0,X             
87E8  A4 BE    LDY $BE                 
87EA  4C 0D 88 JMP loc_880D            

sub_87ED:  ; 1 xrefs: 8638
87ED  B5 C0    LDA $C0,X               
87EF  29 08    AND #$08                
87F1  F0 62    BEQ loc_8855            
87F3  A9 FF    LDA #$FF                
87F5  9D C0 07 STA $07C0,X             
87F8  A9 01    LDA #$01                
87FA  9D C2 07 STA $07C2,X             
87FD  A9 00    LDA #$00                
87FF  9D F6 07 STA $07F6,X             
8802  9D EE 07 STA $07EE,X             

loc_8805:  ; 1 xrefs: 896C
8805  DE C2 07 DEC $07C2,X             
8808  D0 4B    BNE loc_8855            
880A  FE C0 07 INC $07C0,X             

loc_880D:  ; 3 xrefs: 87D7 87EA 8861
880D  84 BE    STY $BE                 
880F  BC C0 07 LDY $07C0,X             
8812  BD C4 07 LDA $07C4,X             
8815  85 BC    STA $BC                 
8817  BD C6 07 LDA $07C6,X             
881A  85 BD    STA $BD                 
881C  B1 BC    LDA ($BC),Y             
881E  C9 FB    CMP #$FB                
8820  F0 34    BEQ loc_8856            
8822  C9 FE    CMP #$FE                
8824  F0 9A    BEQ loc_87C0            
8826  C9 FF    CMP #$FF                
8828  F0 26    BEQ loc_8850            
882A  4A       LSR A                   
882B  4A       LSR A                   
882C  4A       LSR A                   
882D  4A       LSR A                   
882E  29 0F    AND #$0F                
8830  9D C2 07 STA $07C2,X             
8833  B1 BC    LDA ($BC),Y             
8835  29 0F    AND #$0F                
8837  9D D0 07 STA $07D0,X             
883A  BD FE 07 LDA $07FE,X             
883D  F0 0E    BEQ loc_884D            
883F  BD D0 07 LDA $07D0,X             
8842  38       SEC                     
8843  FD FE 07 SBC $07FE,X             
8846  B0 02    BCS loc_884A            
8848  A9 01    LDA #$01                

loc_884A:  ; 1 xrefs: 8846
884A  9D D0 07 STA $07D0,X             

loc_884D:  ; 1 xrefs: 883D
884D  A4 BE    LDY $BE                 
884F  60       RTS                     

loc_8850:  ; 1 xrefs: 8828
8850  A4 BE    LDY $BE                 
8852  9D C2 07 STA $07C2,X             

loc_8855:  ; 2 xrefs: 87F1 8808
8855  60       RTS                     

loc_8856:  ; 1 xrefs: 8820
8856  A4 BE    LDY $BE                 
8858  FE C0 07 INC $07C0,X             
885B  BD C0 07 LDA $07C0,X             
885E  9D F6 07 STA $07F6,X             
8861  4C 0D 88 JMP loc_880D            

sub_8864:  ; 1 xrefs: 8571
8864  84 BE    STY $BE                 
8866  BD F3 07 LDA $07F3,X             
8869  29 02    AND #$02                
886B  D0 40    BNE loc_88AD            
886D  4C FA 88 JMP loc_88FA            

sub_8870:  ; 1 xrefs: 866E
8870  84 BE    STY $BE                 
8872  18       CLC                     
8873  BD E0 07 LDA $07E0,X             
8876  9D E3 07 STA $07E3,X             
8879  FE E3 07 INC $07E3,X             
887C  BD F3 07 LDA $07F3,X             
887F  09 08    ORA #$08                
8881  9D F3 07 STA $07F3,X             
8884  29 02    AND #$02                
8886  F0 4D    BEQ loc_88D5            
8888  BD F3 07 LDA $07F3,X             
888B  29 04    AND #$04                
888D  D0 1E    BNE loc_88AD            
888F  38       SEC                     
8890  BD 38 07 LDA $0738,X             
8893  FD EB 07 SBC $07EB,X             
8896  9D F8 07 STA $07F8,X             
8899  BD 40 07 LDA $0740,X             
889C  FD F0 07 SBC $07F0,X             
889F  9D FB 07 STA $07FB,X             
88A2  A9 04    LDA #$04                
88A4  1D F3 07 ORA $07F3,X             
88A7  9D F3 07 STA $07F3,X             
88AA  4C BF 88 JMP loc_88BF            

loc_88AD:  ; 2 xrefs: 886B 888D
88AD  18       CLC                     
88AE  BD F8 07 LDA $07F8,X             
88B1  7D E8 07 ADC $07E8,X             
88B4  9D F8 07 STA $07F8,X             
88B7  A9 00    LDA #$00                
88B9  7D FB 07 ADC $07FB,X             
88BC  9D FB 07 STA $07FB,X             

loc_88BF:  ; 1 xrefs: 88AA
88BF  BD F8 07 LDA $07F8,X             
88C2  9D 98 07 STA $0798,X             
88C5  BD FB 07 LDA $07FB,X             
88C8  09 F8    ORA #$F8                
88CA  9D A0 07 STA $07A0,X             
88CD  DE E3 07 DEC $07E3,X             
88D0  F0 50    BEQ loc_8922            
88D2  A4 BE    LDY $BE                 
88D4  60       RTS                     

loc_88D5:  ; 1 xrefs: 8886
88D5  BD F3 07 LDA $07F3,X             
88D8  29 04    AND #$04                
88DA  D0 1E    BNE loc_88FA            
88DC  18       CLC                     
88DD  BD 38 07 LDA $0738,X             
88E0  7D EB 07 ADC $07EB,X             
88E3  9D F8 07 STA $07F8,X             
88E6  BD 40 07 LDA $0740,X             
88E9  7D F0 07 ADC $07F0,X             
88EC  9D FB 07 STA $07FB,X             
88EF  A9 04    LDA #$04                
88F1  1D F3 07 ORA $07F3,X             
88F4  9D F3 07 STA $07F3,X             
88F7  4C 0C 89 JMP loc_890C            

loc_88FA:  ; 2 xrefs: 886D 88DA
88FA  38       SEC                     
88FB  BD F8 07 LDA $07F8,X             
88FE  FD E8 07 SBC $07E8,X             
8901  9D F8 07 STA $07F8,X             
8904  BD FB 07 LDA $07FB,X             
8907  E9 00    SBC #$00                
8909  9D FB 07 STA $07FB,X             

loc_890C:  ; 1 xrefs: 88F7
890C  BD F8 07 LDA $07F8,X             
890F  9D 98 07 STA $0798,X             
8912  BD FB 07 LDA $07FB,X             
8915  09 F8    ORA #$F8                
8917  9D A0 07 STA $07A0,X             
891A  DE E3 07 DEC $07E3,X             
891D  F0 03    BEQ loc_8922            
891F  A4 BE    LDY $BE                 
8921  60       RTS                     

loc_8922:  ; 2 xrefs: 88D0 891D
8922  BD F3 07 LDA $07F3,X             
8925  29 F3    AND #$F3                
8927  9D F3 07 STA $07F3,X             
892A  A9 00    LDA #$00                
892C  9D E3 07 STA $07E3,X             
892F  9D F8 07 STA $07F8,X             
8932  9D FB 07 STA $07FB,X             
8935  A4 BE    LDY $BE                 
8937  60       RTS                     

sub_8938:  ; 1 xrefs: 89B3
8938  A9 00    LDA #$00                
893A  A2 08    LDX #$08                

loc_893C:  ; 1 xrefs: 8948
893C  06 BE    ASL $BE                 
893E  2A       ROL A                   
893F  C5 BF    CMP $BF                 
8941  90 04    BCC loc_8947            
8943  E5 BF    SBC $BF                 
8945  E6 BE    INC $BE                 

loc_8947:  ; 1 xrefs: 8941
8947  CA       DEX                     
8948  D0 F2    BNE loc_893C            
894A  85 D0    STA $D0                 
894C  A6 B9    LDX $B9                 
894E  60       RTS                     

sub_894F:  ; 2 xrefs: 8548 863B
894F  BD 30 07 LDA $0730,X             
8952  D0 06    BNE loc_895A            

loc_8954:  ; 1 xrefs: 895F
8954  BD 20 07 LDA $0720,X             
8957  29 F0    AND #$F0                
8959  60       RTS                     

loc_895A:  ; 1 xrefs: 8952
895A  BD 20 07 LDA $0720,X             
895D  29 0F    AND #$0F                
895F  F0 F3    BEQ loc_8954            
8961  0A       ASL A                   
8962  0A       ASL A                   
8963  0A       ASL A                   
8964  0A       ASL A                   
8965  60       RTS                     

sub_8966:  ; 1 xrefs: 8545
8966  B5 C0    LDA $C0,X               
8968  29 08    AND #$08                
896A  F0 03    BEQ loc_896F            
896C  4C 05 88 JMP loc_8805            

loc_896F:  ; 1 xrefs: 896A
896F  B5 C0    LDA $C0,X               
8971  29 30    AND #$30                
8973  C9 10    CMP #$10                
8975  F0 0C    BEQ loc_8983            
8977  C9 20    CMP #$20                
8979  F0 6D    BEQ loc_89E8            
897B  C9 30    CMP #$30                
897D  D0 03    BNE loc_8982            
897F  4C 0C 8A JMP loc_8A0C            

loc_8982:  ; 1 xrefs: 897D
8982  60       RTS                     

loc_8983:  ; 1 xrefs: 8975
8983  DE C8 07 DEC $07C8,X             
8986  F0 45    BEQ loc_89CD            
8988  BD A8 07 LDA $07A8,X             
898B  29 70    AND #$70                
898D  0A       ASL A                   
898E  85 BE    STA $BE                 
8990  BD C8 07 LDA $07C8,X             
8993  0A       ASL A                   
8994  0A       ASL A                   
8995  0A       ASL A                   
8996  85 BF    STA $BF                 
8998  18       CLC                     
8999  A9 00    LDA #$00                
899B  A2 03    LDX #$03                

loc_899D:  ; 1 xrefs: 89A7
899D  06 BE    ASL $BE                 
899F  90 03    BCC loc_89A4            
89A1  18       CLC                     
89A2  65 BF    ADC $BF                 

loc_89A4:  ; 1 xrefs: 899F
89A4  46 BF    LSR $BF                 
89A6  CA       DEX                     
89A7  D0 F4    BNE loc_899D            
89A9  A6 B9    LDX $B9                 
89AB  4A       LSR A                   
89AC  85 BE    STA $BE                 
89AE  BD AA 07 LDA $07AA,X             
89B1  85 BF    STA $BF                 
89B3  20 38 89 JSR sub_8938            
89B6  BD A8 07 LDA $07A8,X             
89B9  30 22    BMI loc_89DD            
89BB  29 0F    AND #$0F                
89BD  18       CLC                     
89BE  65 BE    ADC $BE                 
89C0  C9 10    CMP #$10                
89C2  90 02    BCC loc_89C6            
89C4  A9 0F    LDA #$0F                

loc_89C6:  ; 4 xrefs: 89C2 89DA 89E2 89E6
89C6  20 CE 86 JSR sub_86CE            
89C9  9D D0 07 STA $07D0,X             
89CC  60       RTS                     

loc_89CD:  ; 1 xrefs: 8986
89CD  B5 C0    LDA $C0,X               
89CF  29 CF    AND #$CF                
89D1  09 20    ORA #$20                
89D3  95 C0    STA $C0,X               
89D5  BD A8 07 LDA $07A8,X             
89D8  29 0F    AND #$0F                
89DA  4C C6 89 JMP loc_89C6            

loc_89DD:  ; 1 xrefs: 89B9
89DD  29 0F    AND #$0F                
89DF  38       SEC                     
89E0  E5 BE    SBC $BE                 
89E2  B0 E2    BCS loc_89C6            
89E4  A9 01    LDA #$01                
89E6  90 DE    BCC loc_89C6            

loc_89E8:  ; 1 xrefs: 8979
89E8  20 2E 8A JSR sub_8A2E            
89EB  90 13    BCC loc_8A00            
89ED  B5 C0    LDA $C0,X               
89EF  29 CF    AND #$CF                
89F1  09 30    ORA #$30                
89F3  95 C0    STA $C0,X               
89F5  A9 00    LDA #$00                
89F7  9D CA 07 STA $07CA,X             
89FA  BD AE 07 LDA $07AE,X             
89FD  9D C8 07 STA $07C8,X             

loc_8A00:  ; 1 xrefs: 89EB
8A00  BD A8 07 LDA $07A8,X             
8A03  29 0F    AND #$0F                
8A05  20 CE 86 JSR sub_86CE            
8A08  9D D0 07 STA $07D0,X             
8A0B  60       RTS                     

loc_8A0C:  ; 1 xrefs: 897F
8A0C  DE C8 07 DEC $07C8,X             
8A0F  D0 09    BNE loc_8A1A            
8A11  BD AE 07 LDA $07AE,X             
8A14  9D C8 07 STA $07C8,X             
8A17  FE CA 07 INC $07CA,X             

loc_8A1A:  ; 1 xrefs: 8A0F
8A1A  BD A8 07 LDA $07A8,X             
8A1D  29 0F    AND #$0F                
8A1F  38       SEC                     
8A20  FD CA 07 SBC $07CA,X             
8A23  B0 02    BCS loc_8A27            
8A25  A9 00    LDA #$00                

loc_8A27:  ; 1 xrefs: 8A23
8A27  20 CE 86 JSR sub_86CE            
8A2A  9D D0 07 STA $07D0,X             
8A2D  60       RTS                     

sub_8A2E:  ; 1 xrefs: 89E8
8A2E  BD AC 07 LDA $07AC,X             
8A31  30 04    BMI loc_8A37            
8A33  DD 28 07 CMP $0728,X             
8A36  60       RTS                     

loc_8A37:  ; 1 xrefs: 8A31
8A37  29 7F    AND #$7F                
8A39  85 BE    STA $BE                 
8A3B  BD 30 07 LDA $0730,X             
8A3E  C5 BE    CMP $BE                 
8A40  60       RTS                     

; ==== data $8A41..$8E0B  (971 bytes) ====
8A41  AE 06 4E 06 F4 05 9D 05 4D 05 01 05 B9 04 75 04  |..N.....M.....u.
8A51  35 04 F9 03 C0 03 8A 03 57 03 27 03 FA 02 CF 02  |5.......W.'.....
8A61  A7 02 81 02 5D 02 3B 02 1B 02 FC 01 E0 01 C5 01  |....].;.........
8A71  AC 01 94 01 7D 01 68 01 53 01 40 01 2E 01 1D 01  |....}.h.S.@.....
8A81  0D 01 FE 00 F0 00 E2 00 D6 00 CA 00 BE 00 B4 00  |................
8A91  AA 00 A0 00 97 00 8F 00 87 00 7F 00 78 00 71 00  |............x.q.
8AA1  6B 00 65 00 5F 00 5A 00 55 00 50 00 4B 00 47 00  |k.e._.Z.U.P.K.G.
8AB1  43 00 40 00 3C 00 38 00 35 00 32 00 2F 00 2D 00  |C.@.<.8.5.2./.-.
8AC1  2A 00 28 00 25 00 23 00 21 00 1F 00 1E 00 1C 00  |*.(.%.#.!.......
8AD1  1B 00 19 00 18 00 16 00 15 00 14 00 13 00 12 00  |................
8AE1  11 00 10 00 0F 00 0E 00 83 8B 87 8B 8B 8B 8F 8B  |................
8AF1  93 8B 9A 8B A1 8B A8 8B AF 8B B6 8B BD 8B C4 8B  |................
8B01  C8 8B CC 8B D0 8B D4 8B D8 8B DC 8B E0 8B E4 8B  |................
8B11  EB 8B EF 8B F6 8B FA 8B FE 8B 05 8C 0C 8C 10 8C  |................
8B21  14 8C 18 8C 1C 8C 23 8C 2A 8C 2E 8C 35 8C 3C 8C  |......#.*...5.<.
8B31  40 8C 47 8C 4B 8C 52 8C 56 8C 5A 8C 61 8C 65 8C  |@.G.K.R.V.Z.a.e.
8B41  72 8C 79 8C 83 8C 87 8C 8E 8C 92 8C 96 8C 9D 8C  |r.y.............
8B51  A4 8C A8 8C AC 8C B0 8C B7 8C BB 8C BF 8C C6 8C  |................
8B61  D3 8C E0 8C ED 8C FA 8C 07 8D 14 8D 21 8D 2E 8D  |............!...
8B71  3B 8D 48 8D 55 8D 62 8D 7C 8D 6F 8D 96 8D 89 8D  |;.H.U.b.|.o.....
8B81  A3 8D 01 00 B2 91 01 87 C1 90 01 87 CF 90 01 87  |................
8B91  F3 90 41 86 09 91 88 AD 90 41 86 1D 91 88 AD 90  |..A......A......
8BA1  41 86 31 91 88 AD 90 41 87 C1 90 88 AD 90 46 87  |A.1....A......F.
8BB1  DB 90 88 AD 90 41 87 C1 90 88 B1 90 41 87 CF 90  |.....A......A...
8BC1  88 B1 90 01 88 B1 90 01 88 B9 90 01 88 BD 90 06  |................
8BD1  87 DB 90 01 88 B5 90 1F 85 B3 91 02 85 C0 92 03  |................
8BE1  87 DA 92 42 00 A1 93 01 9F 93 02 85 AB 93 45 85  |...B..........E.
8BF1  D1 93 87 F2 93 03 87 0F 94 3F 85 20 97 4A 85 45  |.........?. .J.E
8C01  97 87 61 97 42 85 62 97 87 63 97 04 87 75 97 10  |..a.B.b..c...u..
8C11  85 A4 97 05 87 67 92 09 85 B7 97 42 85 87 92 87  |.....g.....B....
8C21  99 92 7F 85 30 99 87 5E 99 02 85 AB 92 46 85 09  |....0..^.....F..
8C31  97 87 1F 97 46 85 A3 94 87 BA 94 09 85 56 92 48  |....F........V.H
8C41  85 02 98 87 3C 98 02 87 59 98 44 85 6D 98 87 8A  |....<...Y.D.m...
8C51  98 05 87 9E 98 10 85 C2 98 70 85 DE 98 87 F5 98  |.........p......
8C61  02 85 D6 97 FF 00 87 96 01 AC 96 02 D7 96 03 F1  |................
8C71  96 70 84 97 95 85 C8 95 90 84 E5 95 85 22 96 87  |.p..........."..
8C81  5D 96 05 87 AD 99 45 85 9C 99 87 AD 99 08 84 87  |].....E.........
8C91  95 0F 85 6B 95 45 85 41 95 87 56 95 46 85 E5 91  |...k.E.A..V.F...
8CA1  87 0E 92 05 85 24 95 05 87 14 95 03 87 39 94 46  |.....$.......9.F
8CB1  85 F2 92 87 29 93 05 85 D6 91 08 85 87 95 42 85  |....).........B.
8CC1  5B 94 87 70 94 C3 00 D5 99 01 66 9A 02 09 9B 03  |[..p......f.....
8CD1  56 9B C2 00 07 A1 01 39 A2 02 A4 A3 03 C7 A3 C2  |V......9........
8CE1  00 52 A7 01 4B A8 02 5F A9 03 AC A9 C2 00 45 AA  |.R..K.._......E.
8CF1  01 F5 AA 02 D2 AB 03 6A AC C2 00 E7 A3 01 C3 A4  |.......j........
8D01  02 21 A6 03 DC A6 C2 00 E1 AC 01 B1 AD 02 8D AE  |.!..............
8D11  03 12 AF C2 00 89 AF 01 6B B0 02 5F B1 03 72 B1  |........k.._..r.
8D21  C2 00 DD B1 01 18 B2 02 3F B2 03 87 B2 C2 00 AF  |........?.......
8D31  B2 01 CC B2 02 FE B2 03 30 B3 C2 00 B9 9B 01 F5  |........0.......
8D41  9B 02 2F 9C 03 38 9C C2 00 88 B6 01 E8 B6 02 4C  |../..8.........L
8D51  B7 03 6A B7 C3 00 19 9D 01 4F 9C 02 C2 9D 03 72  |..j......O.....r
8D61  9E C2 00 C6 9E 01 28 9F 02 68 9F 03 8D 9F C5 00  |......(..h......
8D71  B3 9F 01 EA 9F 02 34 A0 03 56 A0 C6 00 75 A0 01  |......4..V...u..
8D81  9C A0 02 CE A0 03 F3 A0 C7 00 43 B3 01 62 B4 02  |..........C..b..
8D91  C6 B5 03 3B B6 C2 00 90 B7 01 7C B8 02 84 B9 03  |...;......|.....
8DA1  B0 B9 C3 00 B2 91 C5 8D C5 8D D5 8D FD 8D 16 8E  |................
8DB1  2B 8E 42 8E 4E 8E 65 8E 79 8E 7B 8E 90 8E 90 8E  |+.B.N.e.y.{.....
8DC1  9B 8E B4 8E 28 27 26 31 33 31 32 31 32 31 32 31  |....('&131212121
8DD1  32 31 32 31 17 28 37 26 35 44 32 FB 14 15 26 25  |2121.(7&5D2...&%
8DE1  24 23 12 FE 03 FB 21 22 13 24 13 22 21 FE 06 FB  |$#....!".$."!...
8DF1  15 16 17 18 17 16 25 24 13 12 FE FF 16 17 28 27  |......%$......('
8E01  26 25 14 13 12 11 25 24 23 22 21                 |&%....%$#"!

loc_8E0C:  ; 0 xrefs: 
8E0C  24 23    BIT $23                 

; ==== data $8E0E..$8E0E  (1 bytes) ====
8E0E  22                                               |"

loc_8E0F:  ; 0 xrefs: 
8E0F  21 FB    AND ($FB,X)             
8E11  23 32    RLA ($32,X)             
8E13  41 FE    EOR ($FE,X)             
8E15  FF 17 28 ISC $2817,X             
8E18  27 26    RLA $26                 
8E1A  25 24    AND $24                 
8E1C  23 12    RLA ($12,X)             
8E1E  21 23    AND ($23,X)             
8E20  24 33    BIT $33                 

; ==== data $8E22..$9762  (2369 bytes) ====
8E22  32 21 FB 12 33 32 51 FE FF 16 27 18 27 26 15 24  |2!..32Q...'.'&.$
8E32  23 12 31 12 13 44 23 22 21 FB 22 33 32 51 FE FF  |#.1..D#"!."32Q..
8E42  18 37 16 21 FB 12 14 23 22 31 FE FF 16 17 18 C7  |.7.!...#"1......
8E52  26 25 24 13 12 14 15 16 37 F8 A8 B8 17 16 15 24  |&%$.....7......$
8E62  23 22 F1 F1 F2 23 24 25 56 F7 F8 F8 F7 F6 F5 F4  |#"...#$%V.......
8E72  F3 F3 F2 F2 FB F1 FE 37 F1 17 38 37 26 15 14 13  |.......7..87&...
8E82  12 51 12 13 44 23 22 31 FB 22 53 32 51 FE 25 34  |.Q..D#"1."S2Q.%4
8E92  23 22 21 12 FB 33 32 61 FE 17 38 37 26 25 14 13  |#"!..32a..87&%..
8EA2  12 51 12 23 44 33 22 31 22 53 42 51 FB 11 82 71  |.Q.#D3"1"SBQ...q
8EB2  FE FF 17 57 36 25 14 13 12 51 12 23 44 33 22 31  |...W6%...Q.#D3"1
8EC2  22 53 42 51 FB 11 82 71 FE FF 0C 8F 0D 8F 14 8F  |"SBQ...q........
8ED2  23 8F 2F 8F 38 8F 49 8F 58 8F 64 8F 71 8F 7D 8F  |#./.8.I.X.d.q.}.
8EE2  8A 8F 97 8F A3 8F B1 8F BD 8F C9 8F D5 8F E1 8F  |................
8EF2  ED 8F F9 8F 01 90 10 90 1D 90 29 90 31 90 3F 90  |..........).1.?.
8F02  4C 90 58 90 64 90 6D 90 7D 90 FF 09 FB F2 02 12  |L.X.d.m.}.......
8F12  02 FE 08 FB 21 51 71 51 21 01 E1 A1 91 A1 E1 01  |....!QqQ!.......
8F22  FE 0F 05 FB F1 E2 F1 01 11 22 11 01 FE 0F 0D FB  |........."......
8F32  F2 02 12 02 FE FF 0F 0F FB F1 E1 D1 E1 F1 01 11  |................
8F42  21 31 21 01 11 FE FF 0F 0F FB 02 11 21 31 41 51  |!1!.........!1AQ
8F52  41 31 21 11 FE FF 0E FB F2 E1 F2 02 12 21 12 02  |A1!..........!..
8F62  FE FF 03 0F FB F2 E1 F2 02 12 21 12 02 FE FF 0C  |..........!.....
8F72  FB F1 E1 F1 01 11 21 11 01 FE FF 04 0F FB F1 E1  |......!.........
8F82  F1 02 11 21 11 02 FE FF 07 0F FB F1 E2 F1 02 11  |...!............
8F92  22 11 02 FE FF 0E FB 11 21 11 01 F1 E1 F1 01 FE  |".......!.......
8FA2  FF F1 E1 D1 E1 F1 02 11 21 31 21 11 02 FE FF 0E  |........!1!.....
8FB2  FB F1 C1 F1 01 11 41 11 01 FE FF 02 0F FB E1 C1  |......A.........
8FC2  E1 01 11 21 11 01 FE 0F FB F1 E2 F1 01 11 22 11  |...!..........".
8FD2  01 FE FF 0B FB 11 21 11 01 F1 E1 F1 01 FE FF 09  |......!.........
8FE2  FB 11 21 11 01 F1 E1 F1 01 FE FF 02 FB 11 21 11  |..!...........!.
8FF2  01 F1 E1 F1 01 FE FF 0B FB 12 01 F2 01 FE FF 0F  |................
9002  FB 11 21 31 21 11 01 F1 E1 D1 F1 01 FE FF 05 0F  |..!1!...........
9012  FB 11 21 11 01 F1 E1 F1 01 FE FF 0F FB F2 E1 F2  |..!.............
9022  12 03 12 03 12 03 FE 04 0F FB 02 D2 02 32 FE 0F  |.............2..
9032  0B 0F FB 11 21 11 01 F1 E1 F1 01 FE FF 06 0F FB  |....!...........
9042  11 21 11 01 F1 E1 F1 01 FE FF 0E FB F2 E1 F2 01  |.!..............
9052  12 21 12 01 FE FF 0A FB 11 21 11 01 F1 E1 F1 01  |.!.......!......
9062  FE FF 0F 04 FB 12 01 F2 01 FE FF 01 FB 12 22 31  |.............."1
9072  22 12 02 F2 E2 D1 E2 F2 02 FE FF 0E FB 11 21 31  |".............!1
9082  41 51 41 31 21 11 01 F1 E1 D1 C1 B1 C1 D1 E1 F1  |AQA1!...........
9092  01 FE FF 01 03 02 0A 07 04 05 06 0F 0C 0D 09 01  |................
90A2  01 01 08 08 01 01 01 01 01 01 0B 0F 4A 00 1F 0F  |............J...
90B2  41 08 0C 0F 40 0B 1C 0F 40 12 28 0E 40 12 28 01  |A...@...@.(.@.(.
90C2  30 7F 70 02 30 01 F8 02 20 01 10 00 FF 01 30 7F  |0.p.0... .....0.
90D2  20 02 50 03 70 04 20 01 FF 01 30 7F 40 05 F8 03  | .P.p. ...0.@...
90E2  50 04 F8 03 50 03 50 02 40 02 40 02 30 01 20 01  |P...P.P.@.@.0. .
90F2  FF 01 30 7F 40 01 60 05 F8 03 70 01 60 01 50 01  |..0.@.`...p.`.P.
9102  F8 04 40 01 30 01 FF 01 8F 7F 10 80 10 90 10 A0  |..@.0...........
9112  10 B0 10 C0 10 D0 10 E0 10 F0 FF 01 8F 7F 10 90  |................
9122  10 A0 10 B0 10 C0 10 D0 10 E0 10 F0 11 00 FF 01  |................
9132  7F 7F 10 A0 10 B0 10 C0 10 D0 10 E0 10 F0 11 10  |................
9142  11 30 FF 01 8F 7F 10 C0 10 D0 10 E0 10 F0 11 10  |.0..............
9152  11 30 11 50 11 70 FF 01 30 7F 60 0C 50 0A 50 07  |.0.P.p..0.`.P.P.
9162  50 04 40 04 30 03 30 02 30 02 20 02 20 02 20 01  |P.@.0.0.0. . . .
9172  20 01 10 01 10 01 10 01 FF 01 B0 8D FB 50 48 50  | ............PHP
9182  3C FE 05 50 48 40 3C 30 48 20 3C FB 10 48 10 3C  |<..PH@<0H <..H.<
9192  FE 03 FF 01 B0 8C FB 50 24 50 22 FE 05 50 24 40  |.......P$P"..P$@
91A2  22 30 24 20 22 01 B0 8D FB 10 24 10 22 FE 03 FF  |"0$ ".....$."...
91B2  FF 02 F0 9E 20 3C 04 F0 9E A0 30 90 20 80 30 70  |.... <....0. .0p
91C2  20 F8 05 60 30 50 20 40 30 30 20 20 30 10 20 10  | ..`0P @00  0. .
91D2  30 10 20 FF 08 B0 82 70 60 06 F0 8A B3 80 22 00  |0. ....p`.....".
91E2  13 80 FF 03 F0 81 E0 A0 0E F0 82 E0 15 04 30 81  |..............0.
91F2  C0 10 0C F0 82 A0 2D 04 30 81 B0 10 0C F0 82 60  |......-.0......`
9202  2D 04 30 81 30 10 0C F0 82 10 2D FF 03 F0 81 90  |-.0.0.....-.....
9212  0F F8 02 80 07 90 08 A0 09 B0 0A B0 0B B0 0C C0  |................
9222  0D F8 02 40 06 60 07 60 08 60 09 70 0A 80 0B 80  |...@.`.`.`.p....
9232  0C 80 0D 20 06 30 07 40 08 40 09 40 0A 40 0B 40  |... .0.@.@.@.@.@
9242  0C 40 0D 10 06 20 07 20 08 20 09 20 0A 10 0B 10  |.@... . . . ....
9252  0C 10 0D FF 08 F0 8C 91 80 71 00 09 B0 8B 51 00  |.........q....Q.
9262  20 D0 10 60 FF 02 30 7F F0 0D F0 0E C0 0D F8 03  | ..`..0.........
9272  D0 0F B0 0E D0 0D F8 04 B0 0D 80 0D F8 06 40 0D  |..............@.
9282  20 0D 10 0D FF 03 30 86 B0 18 F8 05 B0 31 A0 31  | .....0......1.1
9292  F8 09 20 31 10 31 FF 03 30 7F 10 09 F8 04 60 05  |.. 1.1..0.....`.
92A2  40 06 F8 09 10 07 10 08 FF 0B B0 89 A3 00 05 B0  |@...............
92B2  8A 31 50 09 B0 8A A2 D0 07 B0 8A 10 F0 FF 05 30  |.1P............0
92C2  82 50 F0 04 30 8B 92 F0 04 30 83 61 F0 82 F0 61  |.P..0....0.a...a
92D2  F0 42 F0 31 F0 22 F0 FF 01 30 7F E0 0C 70 06 F8  |.B.1."...0...p..
92E2  03 20 0C F8 02 C0 0C 60 0D F8 02 20 0C 10 0C FF  |. .....`... ....
92F2  08 F0 82 B1 80 C1 00 A2 00 92 00 62 00 F8 03 12  |...........b....
9302  00 06 F0 83 FB A2 80 A3 E0 A4 E0 A5 00 95 30 FE  |..............0.
9312  04 FB 52 80 53 E0 54 E0 55 00 35 30 FE 04 43 E0  |..R.S.T.U.50..C.
9322  34 E0 25 00 15 30 FF 03 B0 7F 70 0E B0 0D C0 0E  |4.%..0....p.....
9332  50 0D 70 0D D0 0E F8 07 E0 0F 90 0F D0 0F 03 30  |P.p............0
9342  7F 90 0E B0 0F F8 01 60 0C F8 01 D0 0D F8 06 E0  |.......`........
9352  0E B0 0F F8 05 30 0C F8 04 FB D0 0F E0 0E E0 0D  |.....0..........
9362  E0 0F E0 0E D0 0D B0 0F B0 0E FE 03 FB 80 0F 80  |................
9372  0E 80 0D 80 0F 80 0E 80 0D 50 0F 50 0E FE 02 FB  |.........P.P....
9382  40 0F 40 0E 40 0D 40 0F 40 0E 40 0D 20 0F 20 0E  |@.@.@.@.@.@. . .
9392  FE 02 30 0F 30 0E 20 0F 20 0E 10 0F FF EE 01 DF  |..0.0. . .......
93A2  B0 00 08 FA F6 E1 C2 90 FF 06 30 81 A1 60 09 F0  |..........0..`..
93B2  81 B0 41 06 F0 82 A1 50 02 B0 81 21 50 06 B0 82  |..A....P...!P...
93C2  81 50 02 B0 81 11 50 06 F0 82 51 50 11 50 FF FB  |.P....P...QP.P..
93D2  06 B0 8E 65 00 0A 30 8D 94 00 14 00 02 30 99 10  |...e..0......0..
93E2  40 FE 03 06 B0 8E 25 00 0A 30 8D 64 00 14 00 FF  |@.....%..0.d....
93F2  FB 06 B0 8E 50 0E F8 0A 80 0D 10 0D F8 02 10 0D  |....P...........
9402  FE 03 F8 06 30 0E F8 0A 60 0D 10 0D FF 01 30 7F  |....0...`.....0.
9412  A0 0F C0 0F F8 02 E0 0E F8 01 F0 0E F0 0E E0 0E  |................
9422  D0 0E C0 0D B0 0D A0 0D 90 0D F8 02 80 0D 60 0D  |..............`.
9432  F8 06 50 0D 20 0D FF 01 30 7F 80 00 A0 01 90 02  |..P. ...0.......
9442  60 03 60 05 70 07 50 08 40 0A 40 0C F8 05 E0 0E  |`.`.p.P.@.@.....
9452  B0 0F 50 0F 30 0F 20 0F FF 02 F0 7F 30 44 10 0F  |..P.0. .....0D..
9462  01 F0 7F 10 00 50 21 30 21 20 21 10 21 FF 01 30  |.....P!0! !.!..0
9472  7F A0 0C 80 0B 20 08 10 07 10 00 80 08 70 08 60  |..... .......p.`
9482  06 50 03 40 02 20 01 FF 04 F0 8B 40 70 03 B0 8B  |.P.@. .....@p...
9492  A0 80 A0 60 40 70 30 80 10 60 10 70 10 80 10 60  |...`@p0..`.p...`
94A2  FF 04 30 81 90 90 05 F0 89 A0 80 70 80 F9 30 40  |..0........p..0@
94B2  80 20 80 10 80 10 80 FF 01 30 7F A0 0D A0 0C A0  |. .......0......
94C2  0B A0 0A F8 02 A0 09 A0 08 F8 02 A0 07 F8 01 A0  |................
94D2  06 A0 05 A0 04 A0 03 20 0E 20 0D 20 0C 20 0B 20  |....... . . . . 
94E2  0A F8 03 20 09 20 08 F8 01 20 07 20 06 20 05 20  |... . ... . . . 
94F2  04 20 03 F8 01 10 0E 10 0D 10 0C 10 0B 10 0A F8  |. ..............
9502  03 10 09 10 08 F8 01 10 07 10 06 10 05 10 04 10  |................
9512  03 FF 01 30 7F 90 06 50 06 10 05 10 05 90 09 20  |...0...P....... 
9522  08 FF 01 B0 7F 10 4F 03 70 7F 90 4F F8 04 10 4F  |......O.p..O...O
9532  F8 05 C0 64 80 64 F8 0B 20 64 F8 05 10 64 FF 04  |...d.d.. d...d..
9542  30 99 A5 40 03 30 89 22 00 04 30 99 65 40 03 30  |0..@.0."..0.e@.0
9552  89 22 00 FF FB 01 30 7F 20 08 50 0A 50 0B 30 0C  |."....0. .P.P.0.
9562  20 0D 30 0D 30 0E FE 02 FF 04 F0 F6 C2 10 F8 05  | .0.0...........
9572  12 10 F8 03 D2 10 C2 10 A2 10 92 10 62 10 12 10  |............b...
9582  12 10 12 10 FF 05 F0 B9 B1 03 F8 04 31 03 71 03  |............1.q.
9592  31 04 11 03 FF 01 30 F5 FB 21 A7 FE 03 FB 71 A7  |1.....0..!....q.
95A2  FE 02 FB B1 A7 FE 06 FB 91 A7 FE 06 FB 71 A7 FE  |.............q..
95B2  05 FB 41 A7 FE 05 FB 31 A7 FE 05 FB 21 A7 FE 05  |..A....1....!...
95C2  FB 11 A7 FE 20 FF 01 30 F6 FB 21 F8 FE 03 FB 61  |.... ..0..!....a
95D2  F8 FE 02 FB A1 F8 FE 06 FB 31 F8 FE 0B FB 11 F8  |.........1......
95E2  FE 2D FF 07 F0 82 B0 F0 C1 00 03 B0 82 C2 00 02  |.-..............
95F2  30 84 32 F0 04 F0 82 D2 D0 F0 D0 D2 D0 C0 D0 B2  |0.2.............
9602  D0 90 D0 72 D0 50 D0 41 D0 30 D0 22 D0 20 D0 12  |...r.P.A.0.". ..
9612  D0 10 D0 12 D0 10 D0 12 D0 10 D0 12 D0 10 D0 FF  |................
9622  07 B0 82 50 F0 71 00 05 F0 82 61 00 02 F0 7F 20  |...P.q....a.... 
9632  02 04 F0 83 91 D0 80 D0 71 D0 60 D0 51 D0 40 D0  |........q.`.Q.@.
9642  31 D0 20 D0 21 D0 20 D0 11 D0 10 D0 11 D0 10 D0  |1. .!. .........
9652  11 D0 10 D0 11 D0 10 D0 11 D0 FF 03 B0 7F 70 0E  |..............p.
9662  A0 0D A0 0E 60 0D 20 0D A0 0E F8 07 C0 0F 90 0F  |....`. .........
9672  60 0F 50 0F 40 0E 20 0E 10 0E 10 0E F8 0F 10 00  |`.P.@. .........
9682  F8 0A 10 00 FF D7 3F 08 02 04 7F F2 04 04 E3 71  |......?........q
9692  31 E8 06 61 21 E8 04 51 11 E8 06 41 01 E8 08 31  |1..a!..Q...A...1
96A2  F2 04 0E D8 3F 00 05 E4 B5 FF D7 F3 07 02 04 7F  |....?...........
96B2  F2 04 04 E3 31 E4 B1 E8 05 E3 21 E4 A1 E8 04 E3  |....1.....!.....
96C2  11 E4 91 E8 05 E3 01 E4 81 E8 07 B1 F2 04 0E D8  |................
96D2  F3 00 05 75 FF D7 13 EB 02 01 F2 03 04 E3 71 31  |...u..........q1
96E2  61 21 51 11 41 01 31 F2 04 0E D8 90 E4 B5 FF D7  |a!Q.A.1.........
96F2  FB 81 FE 08 81 F8 04 81 01 01 F8 03 11 11 11 11  |................
9702  FB F8 02 11 FE 08 FF 02 B0 89 32 60 04 30 81 E0  |..........2`.0..
9712  40 50 40 30 40 20 40 20 40 10 40 10 40 FF 04 F0  |@P@0@ @ @.@.@...
9722  7F E0 46 F8 02 20 46 F8 04 D0 6A F8 02 20 6A F8  |..F.. F...j.. j.
9732  04 D0 54 F8 02 20 54 F8 04 D0 6A 06 F0 7F 30 6A  |..T.. T...j...0j
9742  10 6A FF 04 F0 93 F3 F0 03 F0 8B A3 F0 C2 10 B3  |.j..............
9752  F0 B2 10 63 F0 52 10 33 F0 32 10 13 F0 12 10 FF  |...c.R.3.2......
9762  FF                                               |.

loc_9763:  ; 1 xrefs: 97E1
9763  01 30    ORA ($30,X)             
9765  7F B0 0B RRA $0BB0,X             
9768  10 01    BPL loc_976B            
976A  10 03    BPL loc_976F            
976C  50 06    BVC loc_9774            
976E  10 03    BPL loc_9773            
9770  10 01    BPL loc_9773            
9772  10 00    BPL loc_9774            

loc_9774:  ; 2 xrefs: 976C 9772
9774  FF 01 30 ISC $3001,X             
9777  7F FB E0 RRA $E0FB,X             
977A  04 B0    NOP $B0                 
977C  07 60    SLO $60                 
977E  08       PHP                     
977F  20 05 10 JSR $1005               
9782  04 10    NOP $10                 
9784  03 10    SLO ($10,X)             

; ==== data $9786..$9791  (12 bytes) ====
9786  02 10 02 10 01 10 01 FE 01 60 04 50              |.........`.P

loc_9792:  ; 1 xrefs: 980D
9792  07 30    SLO $30                 
9794  08       PHP                     
9795  20 05 10 JSR $1005               
9798  04 10    NOP $10                 
979A  03 10    SLO ($10,X)             

; ==== data $979C..$97B6  (27 bytes) ====
979C  02 10 02 10 01 10 01 FF 08 F0 8C 90 70 70 44 09  |............ppD.
97AC  B0 8B 60 39 40 2E 20 25 10 20 FF                 |..`9@. %. .

loc_97B7:  ; 1 xrefs: 981C
97B7  03 B0    SLO ($B0,X)             

; ==== data $97B9..$97C0  (8 bytes) ====
97B9  8B B0 D0 10 F0 C0 A0 80                          |........

loc_97C1:  ; 1 xrefs: 9826
97C1  5A       NOP                     
97C2  60       RTS                     

; ==== data $97C3..$97CA  (8 bytes) ====
97C3  49 05 B0 8B 60 70 50 70                          |I...`pPp

loc_97CB:  ; 1 xrefs: 9830
97CB  40       RTI                     

; ==== data $97CC..$97D7  (12 bytes) ====
97CC  70 20 70 10 70 10 60 10 50 FF 01 30              |p p.p.`.P..0

loc_97D8:  ; 0 xrefs: 
97D8  81 FB    STA ($FB,X)             
97DA  B0 70    BCS loc_984C            
97DC  B0 64    BCS loc_9842            
97DE  FE 08 80 INC $8008,X             
97E1  70 80    BVS loc_9763            
97E3  64 70    NOP $70                 
97E5  70 70    BVS loc_9857            
97E7  64 60    NOP $60                 
97E9  70 50    BVS loc_983B            
97EB  64 FB    NOP $FB                 
97ED  30 70    BMI loc_985F            
97EF  30 64    BMI loc_9855            
97F1  FE 04 FB INC $FB04,X             
97F4  20 70 20 JSR $2070               
97F7  64 FE    NOP $FE                 
97F9  04 FB    NOP $FB                 
97FB  10 70    BPL loc_986D            
97FD  10 64    BPL loc_9863            
97FF  FE 06 FF INC $FF06,X             
9802  01 30    ORA ($30,X)             
9804  99 20 A0 STA $A020,Y             
9807  04 F0    NOP $F0                 
9809  82 A0    NOP #$A0                
980B  F0 01    BEQ loc_980E            
980D  F0 83    BEQ loc_9792            
980F  31 50    AND ($50),Y             
9811  03 70    SLO ($70,X)             
9813  82 C1    NOP #$C1                

loc_9815:  ; 1 xrefs: 9810
9815  50 04    BVC loc_981B            
9817  70 83    BVS loc_979C            
9819  A1 50    LDA ($50,X)             

; ==== data $981B..$981B  (1 bytes) ====
981B  02                                               |.
981C  30 99    BMI loc_97B7            

loc_981E:  ; 1 xrefs: 981A
981E  31 50    AND ($50),Y             
9820  04 70    NOP $70                 
9822  83 51    SAX ($51,X)             
9824  50 02    BVC loc_9828            
9826  30 99    BMI loc_97C1            

loc_9828:  ; 1 xrefs: 9824
9828  21 50    AND ($50,X)             
982A  04 70    NOP $70                 
982C  83 31    SAX ($31,X)             
982E  50 02    BVC loc_9832            
9830  30 99    BMI loc_97CB            

loc_9832:  ; 1 xrefs: 982E
9832  11 50    ORA ($50),Y             
9834  04 70    NOP $70                 
9836  83 21    SAX ($21,X)             
9838  50 11    BVC loc_984B            
983A  50 FF    BVC loc_983B            
983C  03 B0    SLO ($B0,X)             
983E  7F FB 80 RRA $80FB,X             
9841  0D 50 0C ORA $0C50               
9844  FE 02 70 INC $7002,X             
9847  0C 50 0B NOP $0B50               
984A  F8       SED                     

loc_984B:  ; 1 xrefs: 9838
984B  03 40    SLO ($40,X)             
984D  0A       ASL A                   
984E  40       RTI                     

; ==== data $984F..$984F  (1 bytes) ====
984F  09                                               |.

loc_9850:  ; 1 xrefs: 9842
9850  30 08    BMI loc_985A            
9852  30 08    BMI loc_985C            
9854  20 07 10 JSR $1007               

loc_9857:  ; 1 xrefs: 97E5
9857  05 FF    ORA $FF                 
9859  04 30    NOP $30                 
985B  7F 40 0E RRA $0E40,X             
985E  A0 0E    LDY #$0E                
9860  D0 0E    BNE loc_9870            
9862  E0 0E    CPX #$0E                
9864  E0 0E    CPX #$0E                
9866  E0 0E    CPX #$0E                
9868  B0 0E    BCS loc_9878            
986A  C0 0E    CPY #$0E                
986C  FF 01 F0 ISC $F001,X             

; ==== data $986F..$986F  (1 bytes) ====
986F  9E                                               |.

loc_9870:  ; 1 xrefs: 9860
9870  C0 40    CPY #$40                
9872  20 3D 01 JSR $013D               
9875  B0 9D    BCS loc_9814            
9877  B0 1F    BCS loc_9898            
9879  70 1F    BVS loc_989A            
987B  40       RTI                     

; ==== data $987C..$9899  (30 bytes) ====
987C  1F 04 B0 9E 20 1F 10 1F 01 F0 7F 10 1E FF 01 30  |.... ..........0
988C  7F 50 0A 10 01 30 03 10 03 10 03 10 02 10        |.P...0........

loc_989A:  ; 1 xrefs: 9879
989A  01 10    ORA ($10,X)             
989C  01 FF    ORA ($FF,X)             
989E  03 30    SLO ($30,X)             
98A0  7F E0 0E RRA $0EE0,X             
98A3  D0 0F    BNE loc_98B4            
98A5  F8       SED                     

; ==== data $98A6..$98B3  (14 bytes) ====
98A6  02 C0 0E F8 04 C0 0D B0 0D F8 05 C0 0D F8        |..............

loc_98B4:  ; 1 xrefs: 98A3
98B4  07 60    SLO $60                 
98B6  0D 70 0D ORA $0D70               
98B9  60       RTS                     

; ==== data $98BA..$98DA  (33 bytes) ====
98BA  0D 40 0D 30 0D 20 0D FF 04 B0 D8 60 4F A0 3F 90  |.@.0. .....`O.?.
98CA  35 50 4F 50 3F 50 35 20 4F 20 3F 20 35 10 4F 10  |5POP?P5 O ? 5.O.
98DA  3F                                               |?

loc_98DB:  ; 1 xrefs: 985A
98DB  10 35    BPL loc_9912            
98DD  FF FD 07 ISC $07FD,X             
98E0  99 60 2F STA $2F60,Y             
98E3  50 2F    BVC loc_9914            
98E5  40       RTI                     

; ==== data $98E6..$9911  (44 bytes) ====
98E6  2F 03 F0 7F 20 2F 10 2F 10 2F 10 2F 10 2F FF FD  |/... /././././..
98F6  22 99 F8 06 50 05 F8 08 30 04 20 03 10 02 10 01  |"...P...0. .....
9906  FF 03 B0 8B 80 90 90 40 20 20 02 F0              |.......@  ..

loc_9912:  ; 1 xrefs: 98DB
9912  7F D0 2F RRA $2FD0,X             
9915  C0 2F    CPY #$2F                
9917  B0 2F    BCS loc_9948            
9919  A0 2F    LDY #$2F                
991B  90 2F    BCC loc_994C            
991D  F8       SED                     
991E  04 80    NOP $80                 
9920  2F FC 02 RLA $02FC               
9923  30 7F    BMI loc_99A4            
9925  C0 0A    CPY #$0A                
9927  70 08    BVS loc_9931            
9929  30 04    BMI loc_992F            
992B  10 01    BPL loc_992E            
992D  10 05    BPL loc_9934            

loc_992F:  ; 1 xrefs: 9929
992F  FC FD 07 NOP $07FD,X             
9932  99 F8 03 STA $03F8,Y             
9935  60       RTS                     
9936  2F 03 B0 RLA $B003               

; ==== data $9939..$993A  (2 bytes) ====
9939  8B 20                                            |. 

loc_993B:  ; 1 xrefs: 99A4
993B  90 30    BCC loc_996D            
993D  40       RTI                     

; ==== data $993E..$9947  (10 bytes) ====
993E  20 20 04 F0 7F 60 2F 50 2F 40                    |  ...`/P/@

loc_9948:  ; 1 xrefs: 9917
9948  2F 03 B0 RLA $B003               

; ==== data $994B..$994B  (1 bytes) ====
994B  8B                                               |.

loc_994C:  ; 1 xrefs: 991B
994C  10 90    BPL loc_98DE            
994E  20 40 10 JSR $1040               
9951  10 03    BPL loc_9956            
9953  F0 7F    BEQ loc_99D4            
9955  20 2F 20 JSR $202F               
9958  2F 10 2F RLA $2F10               
995B  10 2F    BPL loc_998C            
995D  FF FD 22 ISC $22FD,X             
9960  99 F8 05 STA $05F8,Y             
9963  50 05    BVC loc_996A            
9965  30 04    BMI loc_996B            
9967  30 03    BMI loc_996C            
9969  F8       SED                     

loc_996A:  ; 1 xrefs: 9963
996A  01 20    ORA ($20,X)             

; ==== data $996C..$996C  (1 bytes) ====
996C  02                                               |.

loc_996D:  ; 1 xrefs: 993B
996D  F8       SED                     

; ==== data $996E..$9989  (28 bytes) ====
996E  02 40 0A 20 08 20 04 20 01 F8 01 20 05 F8 04 20  |.@. . . ... ... 
997E  05 20 04 20 03 F8 02 20 08 10 07 10              |. . ... ....

loc_998A:  ; 1 xrefs: 9959
998A  04 10    NOP $10                 

loc_998C:  ; 1 xrefs: 995B
998C  01 F8    ORA ($F8,X)             
998E  01 10    ORA ($10,X)             
9990  05 F8    ORA $F8                 
9992  03 10    SLO ($10,X)             
9994  05 10    ORA $10                 
9996  04 10    NOP $10                 
9998  03 10    SLO ($10,X)             

; ==== data $999A..$99A3  (10 bytes) ====
999A  02 FF 07 B0 84 A3 00 C4 00 05                    |..........

loc_99A4:  ; 1 xrefs: 9923
99A4  F0 95    BEQ loc_993B            
99A6  B6 B0    LDX $B0,Y               
99A8  26 B0    ROL $B0                 
99AA  16 B0    ASL $B0,X               
99AC  FF 01 30 ISC $3001,X             
99AF  7F D0 0E RRA $0ED0,X             
99B2  E0 0F    CPX #$0F                
99B4  F8       SED                     
99B5  04 F0    NOP $F0                 
99B7  0F F0 0E SLO $0EF0               
99BA  E0 0E    CPX #$0E                
99BC  D0 0E    BNE loc_99CC            
99BE  F8       SED                     
99BF  06 B0    ASL $B0                 
99C1  0E F8 03 ASL $03F8               
99C4  60       RTS                     

; ==== data $99C5..$99CB  (7 bytes) ====
99C5  0E F8 07 90 0E 80 0E                             |.......

loc_99CC:  ; 1 xrefs: 99BC
99CC  40       RTI                     

; ==== data $99CD..$99D3  (7 bytes) ====
99CD  0E 30 0E 20 0E 10 0E                             |.0. ...

loc_99D4:  ; 1 xrefs: 9953
99D4  FF EC 06 ISC $06EC,X             
99D7  D8       CLD                     
99D8  3F 00 03 RLA $0300,X             
99DB  FB E4 91 ISC $91E4,Y             
99DE  E3 02    ISC ($02,X)             
99E0  FE 04 F4 INC $F404,X             

; ==== data $99E3..$A00C  (1578 bytes) ====
99E3  02 02 12 FD 35 9A FD 35 9A D8 3F 00 03 E4 21 22  |....5..5..?...!"
99F3  51 52 91 92 E3 01 02 F4 0A 22 22 F4 03 E4 41 42  |QR.......""...AB
9A03  71 72 B1 B2 E3 41 42 F4 0A 72 72 F4 03 E4 51 52  |qr...AB..rr...QR
9A13  91 92 E3 01 02 51 52 F4 0A 92 92 F4 02 83 E4 85  |.....QR.........
9A23  D8 FB 00 02 E3 81 51 21 E4 B1 81 51 21 E5 B1 FD  |......Q!...Q!...
9A33  E6 99 D8 F3 00 02 FB E3 21 02 21 02 51 42 F5 03  |........!.!.QB..
9A43  51 42 51 41 51 41 F5 00 FE 02 91 82 71 62 51 42  |QBQAQA......qbQB
9A53  31 22 F4 04 F5 02 22 22 F5 03 22 22 F5 04 22 22  |1"....""..""..""
9A63  F5 00 FC EC 06 D8 3F 00 03 FB E4 41 72 FE 04 F4  |......?....Ar...
9A73  02 72 72 FD CC 9A FD CC 9A D8 3F 00 03 E5 91 92  |.rr.......?.....
9A83  E4 21 22 51 52 91 92 F4 0A 92 92 F4 03 E5 B1 B2  |.!"QR...........
9A93  E4 41 42 71 72 B1 B2 F4 0A E3 42 42 F4 03 E4 21  |.ABqr.....BB...!
9AA3  22 51 52 91 92 E3 01 02 F4 0A 52 52 F4 02 43 E4  |"QR.......RR..C.
9AB3  45 EE 01 F5 02 D8 FB 00 02 E3 82 51 21 E4 B1 81  |E..........Q!...
9AC3  51 21 EE 00 F5 00 FD 76 9A D8 F3 00 02 FB E4 91  |Q!.....v........
9AD3  72 91 72 E3 01 E4 B2 F5 03 E3 01 E4 B2 E3 01 E4  |r.r.............
9AE3  B1 E3 01 E4 B1 F5 00 FE 02 F9 BF E3 41 32 21 12  |............A2!.
9AF3  01 E4 B2 A1 92 F4 04 F5 02 92 92 F5 03 92 92 F5  |................
9B03  04 92 92 F5 00 FC EC 06 FB D8 17 E5 91 E4 91 E5  |................
9B13  91 FE 04 D8 30 E4 92 92 D8 1B FB E4 21 E3 21 FE  |....0.......!.!.
9B23  38 D8 1E FB E4 21 E3 21 FE 08 FB E4 41 E3 41 FE  |8....!.!....A.A.
9B33  08 FB E4 51 E3 51 FE 08 D8 90 EB 02 01 F2 0A 14  |...Q.Q..........
9B43  E3 88 F2 00 81 51 21 E4 B1 81 51 21 E5 B1 EB 00  |.....Q!...Q!....
9B53  FD 1B 9B D8 FB 41 42 FE 03 41 42 B1 41 41 41 FD  |.....AB..AB.AAA.
9B63  8F 9B FD 8F 9B D8 FB B1 01 41 B1 01 41 01 B1 41  |.........A..A..A
9B73  01 01 41 B1 41 B1 41 FE 03 B1 11 11 11 11 11 11  |..A.A.A.........
9B83  B1 B1 01 41 41 B1 41 41 41 FD 62 9B D8 FB B1 B1  |...AA.AAA.b.....
9B93  01 B1 41 01 01 B1 B1 41 01 B1 B1 41 41 B1 FE 02  |..A....A...AA...
9BA3  FB B1 01 41 B1 01 41 FE 02 B1 01 41 01 41 01 B1  |...A..A....A.A..
9BB3  41 41 41 41 41 FC EC 01 F8 09 EB 01 01 F2 03 02  |AAAAA...........
9BC3  C2 D9 BF 00 04 E3 93 93 63 75 F9 F3 41 41 71 92  |........cu..AAq.
9BD3  E2 02 E3 B4 A7 F9 BF 93 93 63 75 F9 F3 21 71 E2  |.........cu..!q.
9BE3  01 42 22 01 21 02 E3 B2 E2 01 E3 B1 F4 05 93 FD  |.B".!...........
9BF3  C4 9B EC 01 F8 09 EB 01 01 F2 03 02 C2 D9 BF 00  |................
9C03  04 E3 43 43 13 25 F9 F3 E4 B1 B1 E3 21 42 72 64  |..CC.%......!Brd
9C13  57 F9 BF 43 43 13 25 F9 F3 E4 91 E3 21 71 B2 92  |W..CC.%.....!q..
9C23  71 91 72 62 71 61 F4 05 43 FD 00 9C EC 01 D9 14  |q.rbqa..C.......
9C33  E4 91 FD 31 9C D9 FB B1 01 41 B1 B1 01 41 01 FE  |...1.....A...A..
9C43  07 B1 51 51 B1 61 61 41 71 FD 38 9C EC 02 D7 F3  |..QQ.aaAq.8.....
9C53  00 05 F5 01 EB 01 01 E4 C2 B3 E3 23 D7 F3 17 03  |...........#....
9C63  06 30 58 F5 00 EB 00 FD B1 9C FD B1 9C D7 3F 00  |.0X...........?.
9C73  04 F5 01 E4 42 41 43 52 51 53 72 71 73 92 91 D7  |....BACRQSrqs...
9C83  3F 17 02 0D 7F F2 01 0C 99 D3 F0 03 02 03 7F F2  |?...............
9C93  00 EE 02 E1 02 E2 B1 A1 91 81 71 EE 00 E8 14 E3  |..........q.....
9CA3  91 81 71 61 E8 02 51 41 31 F5 00 FD 6A 9C D7 3F  |..qa..QA1...j..?
9CB3  00 06 F5 03 FB E3 91 E2 41 E3 01 FE 06 E3 91 E3  |........A.......
9CC3  41 E3 01 E3 41 E4 91 41 E3 91 41 01 81 84 FB E3  |A...A..A..A.....
9CD3  91 E2 41 E3 01 FE 05 E3 91 E4 91 41 E3 91 41 E4  |..A........A..A.
9CE3  91 E3 41 E4 91 41 E3 91 01 91 41 91 E2 41 42 FB  |..A..A....A..AB.
9CF3  E3 01 71 01 FE 07 71 01 E2 01 71 01 E3 71 E2 01  |..q...q...q..q..
9D03  71 73 FB E3 01 71 01 FE 07 71 01 E2 01 71 01 E3  |qs...q...q...q..
9D13  71 E2 71 71 73 FC EC 02 D7 F3 00 05 EB 01 01 E3  |q.qqs...........
9D23  C2 23 53 D7 F3 17 03 06 30 B8 EB 00 D7 F3 00 04  |.#S.....0.......
9D33  FD 9C 9D 73 83 FD 9C 9D A3 B3 FD B3 9D E5 A3 B3  |...s............
9D43  FD B3 9D E5 B3 A3 FD 9C 9D 73 83 FD 9C 9D A3 B3  |.........s......
9D53  FD B3 9D E5 A3 B3 FD B3 9D E5 B3 A3 D7 3F 00 04  |.............?..
9D63  F5 00 E4 92 B1 E3 03 E4 B2 E3 01 23 02 21 43 22  |...........#.!C"
9D73  41 D7 3F 17 02 0D 7F F2 01 0C 59 D3 3F 15 02 03  |A.?.......Y.?...
9D83  7F F2 00 E1 01 E2 B1 A1 91 81 71 61 51 41 31 21  |..........qaQA1!
9D93  E8 03 11 01 E3 B1 FD 2F 9D E5 92 92 E4 01 E5 92  |......./........
9DA3  E4 22 E5 92 E4 32 E5 82 71 92 92 E4 01 E5 95 FC  |."...2..q.......
9DB3  E4 02 02 31 02 52 02 62 52 31 02 02 31 05 FC EC  |...1.R.bR1..1...
9DC3  02 D7 25 E4 C2 23 53 D7 90 B8 FD 3B 9E D7 50 73  |..%..#S....;..Ps
9DD3  83 FD 3B 9E D7 50 A3 B3 FD 5B 9E D7 50 E4 A3 B3  |..;..P...[..P...
9DE3  FD 5B 9E D7 50 E4 B3 A3 FD 3B 9E D7 50 73 83 FD  |.[..P....;..Ps..
9DF3  3B 9E D7 50 A3 B3 FD 5B 9E D7 50 E4 A3 B3 FD 5B  |;..P...[..P....[
9E03  9E D7 50 E4 B3 A3 D7 1A E4 92 B1 E3 01 E4 01 E3  |..P.............
9E13  01 E4 B2 E3 01 E3 21 E4 21 E3 21 02 21 41 E3 41  |......!.!.!.!A.A
9E23  E4 41 E3 22 41 D7 87 F2 0A 0C 5A F2 00 D7 10 E3  |.A."A.....Z.....
9E33  51 51 51 51 51 FD CD 9D D7 1C E4 92 92 E3 01 E4  |QQQQQ...........
9E43  92 D7 50 E3 22 E4 92 E3 32 E4 82 71 D7 1C E4 92  |..P."...2..q....
9E53  92 E3 01 D7 40 E4 95 FC D7 1C E3 02 02 31 02 D7  |....@........1..
9E63  50 52 02 62 52 31 D7 1C 02 02 31 D7 50 05 FC D7  |PR.bR1....1.P...
9E73  C2 B1 01 01 11 11 B1 B1 11 11 41 41 41 41 41 FD  |..........AAAAA.
9E83  A1 9E FD A1 9E D7 FB B1 01 01 B1 41 01 FE 04 B1  |...........A....
9E93  41 41 B1 01 B1 B1 01 41 41 41 41 FD 82 9E D7 FB  |AA.....AAAA.....
9EA3  B1 01 B1 01 41 B1 01 B1 B1 01 01 B1 41 B1 01 B1  |....A.......A...
9EB3  FE 07 B1 01 B1 01 41 B1 01 B1 B1 01 41 41 B1 41  |......A.....AA.A
9EC3  41 01 FC DA F3 00 05 F5 01 FB E3 32 01 E4 92 E3  |A..........2....
9ED3  31 01 E4 91 FE 06 F5 00 F8 0B E3 32 F8 01 0B F8  |1..........2....
9EE3  0A E4 92 F8 01 E3 39 08 E4 98 E3 3E 07 E4 97 E3  |......9....>....
9EF3  35 05 E4 95 E3 35 04 E4 94 FB E3 34 04 E4 94 FE  |5....5.....4....
9F03  04 E3 34 04 E4 93 FB E3 33 03 E4 93 FE 05 F5 01  |..4.....3.......
9F13  E3 33 F5 02 03 F5 03 E4 93 F5 04 E3 32 F5 05 02  |.3..........2...
9F23  F5 06 E4 92 FF DA F3 00 02 E5 98 68 98 68 94 64  |...........h.h.d
9F33  94 64 F8 0B 92 62 F8 09 92 F8 08 62 D7 F3 28 02  |.d...b.....b..(.
9F43  02 7F F0 02 92 62 F8 05 92 62 F8 04 FB 92 62 FE  |.....b...b....b.
9F53  04 D3 F3 00 02 FB 92 62 FE 04 F5 02 F8 01 94 64  |.......b.......d
9F63  F5 04 93 63 FF DA 90 E4 98 68 98 68 94 64 94 64  |...c.....h.h.d.d
9F73  F8 0B 92 62 F8 09 92 F8 08 62 F8 07 92 62 F8 05  |...b.....b...b..
9F83  92 62 F8 04 FB 92 62 FE 07 FF DA B8 B8 B8 B8 B4  |.b....b.........
9F93  B4 B4 B4 DB B2 B2 DB B2 D1 B0 9E 4E 9A 4A FB 98  |...........N.J..
9FA3  48 FE 04 96 46 96 46 95 45 94 44 93 02 01 01 FF  |H...F.F.E.D.....
9FB3  D5 3F 13 03 02 7F F0 01 EB 15 01 FD 61 A0 B4 F8  |.?..........a...
9FC3  05 EA 02 7F E2 14 E8 27 EA 08 7F 14 D1 F0 05 03  |.......'........
9FD3  03 7F 01 E3 B1 A1 E8 04 91 81 E8 03 71 61 51 E8  |............qaQ.
9FE3  02 41 31 21 11 01 FF EE 02 D5 F0 02 03 03 7F F0  |.A1!............
9FF3  01 EB 15 01 E4 82 B1 E3 11 E8 13 E4 B1 E8 14 E3  |................
A003  11 41 11 41 61 41 61 B3 D5 F0                    |.A.AaAa...

loc_A00D:  ; 0 xrefs: 
A00D  26 03    ROL $03                 

; ==== data $A00F..$A55F  (1361 bytes) ====
A00F  02 7F E3 84 E8 27 EA 08 7F 84 D1 F0 05 03 03 7F  |.....'..........
A01F  71 61 51 E8 04 41 31 E8 03 21 11 01 E8 02 E4 B1  |qaQ..A1..!......
A02F  A1 91 81 71 FF D5 13 EC 8C FD 61 A0 D5 B0 B4 D5  |...q......a.....
A03F  15 E2 14 D5 B0 14 D1 13 01 E3 B1 A1 91 81 71 61  |..............qa
A04F  51 41 31 21 11 01 FF D5 FB 01 FE 0C 41 41 01 44  |QA1!........AA.D
A05F  44 FF E4 81 B1 E3 11 E8 15 E4 B1 E3 11 41 E8 26  |D............A.&
A06F  11 41 61 41 61 FC EC 02 D7 3F 00 06 EB 01 01 E3  |.AaAa....?......
A07F  01 12 42 63 82 B1 82 B2 F2 05 03 F4 05 E2 17 D7  |..Bc............
A08F  30 27 01 01 7F F2 00 F0 01 E3 11 13 FF EC 02 D7  |0'..............
A09F  3F 00 06 EB 01 01 E4 71 82 B2 E3 11 E5 61 61 E3  |?......q.....aa.
A0AF  31 E4 31 E3 61 31 E4 31 E3 61 E5 61 F2 05 03 F4  |1.1.a1.1.a.a....
A0BF  05 E3 87 D7 30 27 01 01 7F F0 01 E4 81 83 FF EC  |....0'..........
A0CF  02 D7 30 E3 01 12 42 61 E4 62 D7 13 E3 81 81 B1  |..0...Ba.b......
A0DF  81 81 D7 30 B2 D7 90 F2 10 05 E3 17 F2 00 D7 10  |...0............
A0EF  E4 11 13 FF D7 B1 11 81 41 11 41 81 01 41 01 B1  |........A.A..A..
A0FF  81 B1 81 81 B7 41 43 FF EC 01 F5 02 D7 B0 00 03  |.....AC.........
A10F  FB E5 92 92 E4 41 03 73 63 52 E5 42 42 B1 83 E4  |.....A.scR.BB...
A11F  23 13 02 FE 02 D7 F0 00 02 EB 01 01 E2 C2 93 83  |#...............
A12F  F8 0E 7B D7 F0 26 02 03 7F F0 01 61 51 43 03 E8  |..{..&.....aQC..
A13F  13 03 E8 12 03 C6 F8 01 E8 26 12 2C F8 07 21 03  |.........&.,..!.
A14F  F9 B3 F4 03 E3 B3 E2 03 E3 B3 C1 D7 F0 00 02 E2  |................
A15F  93 83 F8 0E 7B D7 F0 26 02 03 7F 61 51 43 03 E8  |....{..&...aQC..
A16F  13 03 E8 12 03 C6 F8 01 E8 26 12 2C F8 07 21 11  |.........&.,..!.
A17F  02 F9 B3 F4 03 E3 B3 E2 03 72 D7 B0 00 03 EB 00  |.........r......
A18F  E2 C1 F8 03 81 96 F8 02 81 9D F8 07 93 E1 03 E2  |................
A19F  92 E1 22 02 E2 B1 E1 03 E2 B3 73 22 C2 F8 03 51  |..".......s"...Q
A1AF  61 7C 61 76 F8 07 73 72 72 51 42 33 C1 21 11 01  |a|av..srrQB3.!..
A1BF  E3 B1 A1 91 81 C2 F8 03 E2 01 11 25 F8 07 03 E3  |...........%....
A1CF  B3 93 B2 C2 F8 02 E2 31 46 F8 07 41 23 03 23 42  |.......1F..A#.#B
A1DF  C2 F8 03 51 61 7C 81 96 F8 07 B3 E1 02 F4 02 EB  |...Qa|..........
A1EF  01 01 20 D7 B3 00 01 F2 04 02 E3 C2 92 E2 01 E3  |.. .............
A1FF  93 FB E2 01 E3 92 FE 02 E2 01 E3 93 C8 F9 B0 F4  |................
A20F  03 73 84 F9 B3 F4 01 E3 C1 92 E2 01 E3 93 FB E2  |.s..............
A21F  01 E3 92 FE 02 E2 01 E3 93 C7 F2 00 F9 B0 E2 41  |...............A
A22F  31 21 11 01 E3 B1 A1 FD 24 A1 EC 01 EE 05 D7 B0  |1!......$.......
A23F  00 03 F5 04 C2 E5 92 92 E4 41 03 73 63 52 E5 42  |.........A.scR.B
A24F  42 B1 83 E4 23 13 02 E5 92 92 E4 41 03 73 63 52  |B...#......A.scR
A25F  E5 42 42 B1 83 E4 23 13 EE 00 D7 F0 00 02 EB 01  |.BB...#.........
A26F  01 F5 00 E2 C2 43 33 F8 0E 2B D7 F0 03 02 05 7F  |.....C3..+......
A27F  F0 01 EE 01 61 51 EE 00 D7 F0 26 02 03 7F E3 93  |....aQ....&.....
A28F  93 E8 13 93 E8 12 93 C6 EE 01 C2 F8 01 E8 04 E2  |................
A29F  12 2C F8 07 21 01 EE 00 F9 B3 F4 03 E3 43 43 43  |.,..!........CCC
A2AF  C1 D7 F0 00 02 E2 43 33 F8 0E 2B D7 F0 03 02 05  |......C3..+.....
A2BF  7F EE 01 61 51 EE 00 D7 F0 26 02 03 7F E3 93 93  |...aQ....&......
A2CF  E8 13 93 E8 12 93 C6 EE 01 C2 F8 01 E8 04 E2 12  |................
A2DF  2C F8 07 21 11 EE 00 F9 B3 F4 03 E3 43 73 E2 02  |,..!........Cs..
A2EF  EE 01 D7 B0 00 03 F5 04 EB 00 E2 C4 F8 03 81 96  |................
A2FF  F8 02 81 9D F8 07 93 E1 02 F5 01 E2 72 72 71 73  |............rrqs
A30F  73 23 E3 B2 C2 C3 F5 03 F8 03 E2 51 61 7C 61 76  |s#.........Qa|av
A31F  F8 07 73 72 72 51 42 31 F5 03 E3 91 81 71 61 51  |..srrQB1.....qaQ
A32F  41 31 F5 04 C5 F8 03 E2 01 11 25 F8 07 03 E3 B3  |A1........%.....
A33F  93 B2 C2 F8 02 E2 31 46 F8 07 41 23 03 23 42 C2  |......1F..A#.#B.
A34F  F8 03 51 61 7C 81 96 F8 07 B3 E1 02 F4 02 EB 01  |..Qa|...........
A35F  01 2D EE 00 F5 00 D7 B3 00 01 F2 04 02 E3 C2 42  |.-.............B
A36F  41 43 FB 41 42 FE 02 41 43 C8 F4 03 F9 B0 23 34  |AC.AB..AC.....#4
A37F  F9 B3 F4 01 C1 42 41 43 FB 41 42 FE 02 41 43 C7  |.....BAC.AB..AC.
A38F  F2 00 F9 B0 EE 01 F5 03 E2 43 31 21 11 01 F5 00  |.........C1!....
A39F  EE 00 FD 69 A2 EC 01 D7 14 E4 92 92 E3 41 D7 40  |...i.........A.@
A3AF  03 D7 38 73 63 52 D7 14 E4 42 42 B1 D7 40 83 D7  |..8scR...BB..@..
A3BF  38 E3 23 13 02 FD A4 A3 D7 B2 01 01 41 01 01 01  |8.#.........A...
A3CF  B1 B1 01 B1 42 01 01 B2 01 01 41 01 01 01 B1 41  |....B.....A....A
A3DF  B1 01 42 B1 41 FD C7 A3 EC 07 D7 3F 26 01 05 30  |..B.A......?&..0
A3EF  F0 01 EB 01 01 E3 56 EA 08 30 5A D4 F0 15 01 01  |......V..0Z.....
A3FF  7F F0 00 E1 51 41 31 21 FD B4 A4 01 E3 B1 A1 91  |....QA1!........
A40F  81 71 E8 03 61 51 41 31 21 FB D7 F0 26 02 06 28  |.q..aQA1!...&..(
A41F  F0 01 EB 01 01 E3 92 A4 E2 24 58 E3 A2 E2 02 E3  |.........$X.....
A42F  A2 92 A6 E2 32 54 24 06 E3 92 A2 92 54 26 E2 26  |....2T$.....T&.&
A43F  26 24 22 32 02 E3 94 E2 06 26 26 24 D7 BF 00 05  |&$"2.....&&$....
A44F  62 62 F5 04 62 F5 00 6A FE 02 D7 F0 26 02 05 22  |bb..b..j....&.."
A45F  F0 01 E2 22 E3 72 A2 E2 24 06 22 E3 62 92 E2 24  |...".r..$.".b..$
A46F  04 22 72 24 04 26 C2 32 52 32 22 14 32 D7 F0 26  |."r$.&.2R2".2..&
A47F  02 05 22 F0 01 E2 76 74 52 74 76 74 52 74 D7 F0  |.."...vtRtvtRt..
A48F  00 05 92 A2 72 F5 02 74 F5 00 92 A2 72 F5 02 72  |....r..t....r..r
A49F  F5 00 F0 01 D7 3F 26 01 05 30 E3 56 EA 08 7F 58  |.....?&..0.V...X
A4AF  F0 00 FD 18 A4 11 01 E2 B1 A1 91 81 71 61 51 41  |............qaQA
A4BF  31 21 11 FC EC 07 D7 3F 26 01 05 30 F0 01 EB 01  |1!.....?&..0....
A4CF  01 E3 06 EA 08 30 04 F4 03 E5 22 24 EE 01 D4 F0  |.....0...."$....
A4DF  03 03 04 7F F0 00 E1 91 81 71 61 51 41 31 21 E8  |.........qaQA1!.
A4EF  04 FD B4 A4 E8 03 01 E3 B1 A1 91 81 71 61 FB D7  |............qa..
A4FF  BF 00 02 F5 02 EE 01 EB 01 01 E3 96 A4 E2 22 F5  |..............".
A50F  01 E3 92 A2 E2 54 EE 00 D7 BF 16 02 06 28 F0 01  |.....T.......(..
A51F  E3 72 32 32 36 E3 92 94 94 96 52 72 52 24 E4 A2  |.r226.....RrR$..
A52F  D7 B0 00 02 F5 02 E2 92 72 D7 BF 16 02 06 28 E3  |........r.....(.
A53F  96 76 A4 92 E2 02 E3 92 34 96 66 66 64 D7 BF 00  |.v......4.ffd...
A54F  05 E2 02 02 F5 04 02 F5 00 0A FE 02 EE 01 FB D7  |................
A55F  3F                                               |?

loc_A560:  ; 0 xrefs: 
A560  00 05    BRK #$05                

; ==== data $A562..$A8A8  (839 bytes) ====
A562  E4 32 F5 01 F4 06 E3 72 E2 22 FE 02 E3 32 72 FB  |.2.....r."...2r.
A572  F4 05 F5 00 E4 22 F4 06 F5 01 E3 62 E2 02 FE 02  |.....".....b....
A582  E3 22 62 FB F5 00 F4 05 E4 72 F5 01 F4 06 E3 A2  |."b......r......
A592  E2 22 FE 02 E3 72 A2 FB F5 00 F4 05 E4 72 F5 01  |."...r.......r..
A5A2  F4 06 E3 B2 E2 32 FE 02 E3 72 B2 D7 3F 00 05 E4  |.....2...r..?...
A5B2  32 F5 01 F4 06 E3 72 E3 22 F5 00 F4 05 E4 32 F5  |2.....r.".....2.
A5C2  01 F4 06 E4 72 E3 22 F5 00 F4 05 E4 32 F5 01 F4  |....r.".....2...
A5D2  06 E4 72 F4 05 F5 00 E4 52 F4 06 F5 01 E2 02 E3  |..r.....R.......
A5E2  92 F5 00 F4 05 E4 52 F4 06 F5 01 E3 02 52 F5 00  |......R......R..
A5F2  F4 05 E4 52 02 F5 00 D7 F3 00 05 E3 22 22 22 F5  |...R........""".
A602  03 24 F5 00 22 22 22 F5 03 22 F5 00 F0 01 D7 3F  |.$.."""..".....?
A612  26 01 05 30 E3 06 EA 08 7F 08 F0 00 FD FD A4 EC  |&..0............
A622  07 D7 25 E4 62 C4 D7 90 6A C2 D7 15 FB EB 00 E4  |..%.b...j.......
A632  22 FE 06 F8 02 22 31 41 51 62 FB D7 15 E4 72 72  |"...."1AQb....rr
A642  E3 22 E4 71 72 72 71 52 72 02 02 02 01 02 02 01  |.".qrrqRr.......
A652  02 02 52 52 92 51 52 52 51 92 52 A2 A2 A2 A1 A2  |..RR.QRRQ.R.....
A662  A2 A1 A2 52 32 32 32 31 32 32 31 32 72 92 92 92  |...R22212212r...
A672  91 92 92 91 92 92 22 22 22 21 22 22 21 22 32 22  |......"""!""!"2"
A682  22 22 21 22 22 21 22 62 FE 02 D7 15 E4 32 32 32  |""!""!"b.....222
A692  31 32 32 31 32 32 22 22 22 21 22 22 21 22 22 72  |122122"""!""!""r
A6A2  72 72 71 72 72 71 72 72 72 72 72 71 72 72 71 72  |rrqrrqrrrrrqrrqr
A6B2  52 32 32 32 31 32 32 31 32 32 52 52 52 51 52 52  |R222122122RRRQRR
A6C2  51 52 52 72 72 72 71 72 72 71 72 72 C2 D7 25 62  |QRRrrrqrrqrr..%b
A6D2  C4 62 D7 14 22 22 22 FD 3C A6 D7 B6 B4 31 21 31  |.b..""".<....1!1
A6E2  21 C2 51 51 B1 B1 61 61 B1 B1 B1 71 71 71 42 41  |!.QQ..aa...qqqBA
A6F2  41 FD 2D A7 FD 2D A7 B1 01 B1 01 41 01 B1 B1 21  |A.-..-.....A...!
A702  31 31 21 41 01 B1 01 FE 06 41 B1 41 B1 41 01 B1  |11!A.....A.A.A..
A712  B1 21 31 41 21 41 01 41 B1 51 51 B1 B1 61 61 B1  |.!1A!A.A.QQ..aa.
A722  B1 B1 71 71 71 42 41 41 FD F3 A6 D7 FB B1 01 B1  |..qqqBAA........
A732  01 41 01 B1 B1 21 31 31 21 41 01 B1 01 FE 07 B1  |.A...!11!A......
A742  01 B1 01 41 01 B1 B1 21 31 41 21 B1 B1 41 41 FC  |...A...!1A!..AA.
A752  EC 05 D8 F3 00 03 F0 01 FB E3 C2 23 53 78 FE 04  |...........#Sx..
A762  FB D8 30 00 02 E2 C2 F8 04 01 11 24 F8 08 22 01  |..0........$..".
A772  E3 B2 E2 01 E3 B2 72 21 59 F8 04 51 61 72 F8 08  |......r!Y..Qar..
A782  51 41 22 01 29 92 B1 E2 01 E3 B1 91 71 98 D8 B0  |QA".).......q...
A792  16 01 03 7F E2 C1 22 E8 02 21 E8 16 22 E8 02 22  |......"..!..".."
A7A2  FE 02 D4 F0 00 02 E2 C4 51 61 74 F8 08 72 51 42  |........Qat..rQB
A7B2  51 42 22 01 52 42 21 03 22 22 41 54 F4 04 F9 B0  |QB".RB!.""AT....
A7C2  21 E3 92 E2 02 E3 71 B2 73 92 53 E2 21 E3 92 E2  |!.....q.s.S.!...
A7D2  02 E3 71 B2 B2 71 92 53 D4 F0 00 02 E2 C2 51 61  |..q..q.S......Qa
A7E2  74 F8 08 72 51 42 51 42 22 01 52 42 21 03 22 22  |t..rQBQB".RB!.""
A7F2  41 53 D8 3F 26 02 03 7F C1 93 94 93 93 92 E1 02  |AS.?&...........
A802  E2 92 91 72 EA 07 7F 99 D8 F0 00 01 E3 C2 21 02  |...r..........!.
A812  21 02 21 02 21 02 21 01 D8 F0 26 02 02 7F F0 01  |!.!.!.!...&.....
A822  52 42 21 02 F4 02 29 F4 01 C2 51 42 51 42 51 42  |RB!...)...QBQBQB
A832  51 42 51 41 D8 F0 26 02 02 7F C1 91 91 91 81 92  |QBQA..&.........
A842  E2 12 12 11 12 12 FD 52 A7 EC 05 FB D8 F3 00 03  |.......R........
A852  F0 01 F5 01 E4 C2 93 E3 23 25 F5 04 F9 F0 E5 91  |........#%......
A862  81 71 FE 04 EE 01 FB D8 30 00 02 F5 01 E3 C2 F8  |.q......0.......
A872  04 71 81 94 F8 08 92 91 72 F5 04 E2 02 E3 B2 72  |.q......r......r
A882  F5 01 29 F8 04 01 11 22 F8 08 21 E4 91 92 91 99  |..)...."..!.....
A892  E3 42 71 91 71 41 21 28 D8 B0 16 01 03 7F E3 C1  |.Bq.qA!(........
A8A2  92 E8 02 91 E8 16 92                             |.......

loc_A8A9:  ; 0 xrefs: 
A8A9  E8       INX                     

; ==== data $A8AA..$A95F  (182 bytes) ====
A8AA  02 92 FE 02 D8 B3 00 04 F5 01 C2 FB F2 23 03 E4  |.............#..
A8BA  A1 A1 F2 13 02 A4 E3 03 E4 A3 E3 04 FE 02 C1 F2  |................
A8CA  00 EE 02 D8 B0 00 03 F5 04 E2 21 E3 92 E2 02 E3  |..........!.....
A8DA  71 B2 73 92 53 E2 21 E3 92 E2 02 E3 71 B2 B2 71  |q.s.S.!.....q..q
A8EA  92 51 EE 00 D8 B3 00 04 F5 01 FB C1 F2 23 03 E4  |.Q...........#..
A8FA  A1 A1 F2 13 02 A4 E3 03 E4 A3 E3 03 FE 02 F2 00  |................
A90A  D8 3F 16 02 03 7F E2 43 44 43 43 42 42 42 41 42  |.?.....CDCCBBBAB
A91A  EA 07 7F 49 D8 F0 00 01 E4 C2 91 92 91 92 91 92  |...I............
A92A  91 92 91 91 D8 F0 26 02 02 7F F0 01 92 92 91 92  |......&.........
A93A  F4 02 99 F4 01 C2 E3 21 02 21 02 21 02 21 02 21  |.......!.!.!.!.!
A94A  01 D8 F0 26 02 02 7F C1 41 41 41 41 42 42 42 41  |...&....AAAABBBA
A95A  42 42 FD 4B A8 EC                                |BB.K..

loc_A960:  ; 0 xrefs: 
A960  05 FB    ORA $FB                 
A962  D8       CLD                     
A963  71 E4    ADC ($E4),Y             
A965  24 54    BIT $54                 
A967  D8       CLD                     
A968  81 75    STA ($75,X)             
A96A  D8       CLD                     
A96B  17 91    SLO $91,X               
A96D  81 71    STA ($71,X)             
A96F  FE 04 FB INC $FB04,X             
A972  D8       CLD                     
A973  71 E4    ADC ($E4),Y             
A975  24 54    BIT $54                 
A977  74 94    NOP $94,X               
A979  FE 08 D8 INC $D808,X             
A97C  71 FB    ADC ($FB),Y             
A97E  E4 74    CPX $74                 
A980  A4 E3    LDY $E3                 
A982  04 24    NOP $24                 
A984  FE 02 FB INC $FB02,X             
A987  E4 24    CPX $24                 
A989  54 74    NOP $74,X               
A98B  94 FE    STY $FE,X               

; ==== data $A98D..$A9A8  (28 bytes) ====
A98D  02 FB E4 74 A4 E3 04 24 FE 02 FB E3 14 44 74 94  |...t...$.....Dt.
A99D  FE 02 FB D8 71 E4 24 54 74 94 FE 04              |....q.$Tt...

loc_A9A9:  ; 0 xrefs: 
A9A9  FD 5F A9 SBC $A95F,X             
A9AC  D8       CLD                     
A9AD  FB B2 12 ISC $12B2,Y             
A9B0  FE 0D B2 INC $B20D,X             
A9B3  11 B1    ORA ($B1),Y             
A9B5  B1 51    LDA ($51),Y             

; ==== data $A9B7..$ADC7  (1041 bytes) ====
A9B7  52 61 62 71 D8 FB B2 01 01 42 01 B2 B1 B2 42 01  |Rabq.....B....B.
A9C7  B1 FE 08 D8 FB B2 01 01 42 01 B1 01 B1 B2 42 01  |........B.....B.
A9D7  B1 FE 07 B2 01 01 42 01 B1 01 51 51 01 61 62 71  |......B...QQ.abq
A9E7  D8 B1 01 71 01 B1 71 01 B1 71 01 B1 71 01 B1 41  |...q..q..q..q..A
A9F7  41 B1 01 01 01 41 01 01 B1 B1 01 01 01 41 41 B1  |A....A.......AA.
AA07  41 B1 01 71 01 B1 71 01 B1 71 01 B1 71 01 B1 41  |A..q..q..q..q..A
AA17  41 B1 B1 01 01 42 01 41 B1 41 B1 41 42 41 B1 D8  |A....B.A.A.ABA..
AA27  FB B2 01 01 42 01 B2 B1 B2 42 01 B1 FE 03 B2 01  |....B....B......
AA37  01 42 01 B1 01 51 52 61 61 71 71 FD BB A9 EC 03  |.B...QRaaqq.....
AA47  D7 F0 00 03 F5 02 FD B4 AA FE 04 F5 00 FD B4 AA  |................
AA57  FE 04 F5 03 72 F5 00 FD C1 AA F9 30 E3 71 61 E2  |....r......0.qa.
AA67  21 05 FD C1 AA F4 04 E3 61 71 91 B1 E2 01 21 D7  |!.......aq....!.
AA77  F0 00 04 FD E5 AA E3 91 71 91 E2 43 E2 91 71 91  |........q..C..q.
AA87  E1 42 21 01 E2 B1 71 21 E2 FD E5 AA F9 3F F4 01  |.B!...q!.....?..
AA97  21 02 21 02 21 02 F4 04 43 E2 94 C0 D7 F0 00 03  |!.!.!...C.......
AAA7  FD B4 AA FE 04 F5 03 72 F5 00 FD 5E AA FB E3 92  |.......r...^....
AAB7  E2 02 22 01 43 02 22 E3 72 FC D7 BF 00 04 E2 71  |..".C.".r......q
AAC7  72 72 71 96 D7 F0 00 05 21 01 22 02 21 42 E3 9B  |rrq.....!.".!B..
AAD7  E2 42 21 02 22 22 21 02 24 22 21 22 73 FC E2 42  |.B!.""!.$"!"s..B
AAE7  72 E1 02 E2 41 72 E1 02 E2 41 72 E1 02 FC EC 03  |r...Ar...Ar.....
AAF7  EE 01 D7 F0 00 03 F5 05 C2 FD B4 AA FE 04 F5 03  |................
AB07  FD B4 AA FE 03 FD C1 AB FD 78 AB F9 30 E3 21 21  |.........x..0.!!
AB17  71 75 FD 78 AB EE 01 C1 F4 04 F5 04 E3 61 71 91  |qu.x.........aq.
AB27  B1 E2 01 EE 01 D7 F0 00 04 F5 04 C2 FD B3 AB E1  |................
AB37  02 F5 03 C1 E3 91 71 91 E2 43 E2 91 71 F5 01 91  |......q..C..q...
AB47  71 41 21 E3 91 F5 04 C2 FD B3 AB F5 01 F9 F0 F4  |qA!.............
AB57  01 E2 41 42 41 42 41 42 F4 04 93 44 C0 EE 01 D7  |..ABABAB...D....
AB67  F0 00 03 C2 F5 03 FD B4 AA FE 03 FD C1 AB FD 0F  |................
AB77  AB D7 BF 00 04 F5 01 E2 21 22 22 21 46 D7 F0 00  |........!""!F...
AB87  05 E3 91 91 92 92 91 92 43 EE 01 D7 B0 00 01 E2  |........C.......
AB97  21 01 21 42 E3 93 EE 00 D7 F0 00 05 E2 02 E3 91  |!.!B............
ABA7  92 92 92 91 92 94 B2 B1 B2 E2 23 FC E2 42 72 E1  |..........#..Br.
ABB7  02 E2 41 72 E1 02 E2 41 72 FC E3 92 E2 02 22 01  |..Ar...Ar.....".
ABC7  43 02 22 F5 05 22 EE 00 F5 00 FC EC 03 D7 8F EB  |C.".."..........
ABD7  02 01 E4 9E 71 61 50 7E 42 9C FD 59 AC EB 00 D7  |....qaP~B..Y....
ABE7  16 FD 44 AC FD 4F AC 72 72 72 71 72 72 71 72 72  |..D..O.rrrqrrqrr
ABF7  FD 44 AC D7 16 FB FD 44 AC FD 4F AC 22 22 22 21  |.D.....D..O."""!
AC07  22 22 21 22 22 42 42 42 41 42 42 41 42 42 FE 02  |""!""BBBABBABB..
AC17  D7 15 FB 51 51 52 52 51 72 72 71 72 72 FD 44 AC  |...QQRRQrrqrr.D.
AC27  FE 02 CC FD 59 AC D7 16 FD 44 AC FD 4F AC 72 72  |....Y....D..O.rr
AC37  72 71 72 72 71 72 72 FD 44 AC FD FA AB E4 92 92  |rqrrqrr.D.......
AC47  92 91 92 92 91 92 92 FC 52 52 52 51 52 52 51 52  |........RRRQRRQR
AC57  52 FC D2 90 E4 92 82 71 61 51 41 31 21 11 01 E5  |R......qaQA1!...
AC67  B1 A1 FC D7 C0 C0 C0 C8 B1 41 42 41 42 41 FD BC  |.........ABABA..
AC77  AC B1 01 41 01 41 41 01 01 B1 41 41 01 41 41 01  |...A.AA...AA.AA.
AC87  41 FD BC AC FD D0 AC FD BC AC FD D0 AC FD BC AC  |A...............
AC97  FD D0 AC B1 B1 02 42 01 01 01 B1 01 B1 42 02 FD  |......B......B..
ACA7  BC AC B1 01 41 01 41 41 01 01 B1 41 41 01 41 41  |....A.AA...AA.AA
ACB7  01 41 FD 88 AC FB B1 B1 01 01 41 01 01 B1 01 B1  |.A........A.....
ACC7  B1 01 41 01 01 01 FE 03 FC B1 B1 01 01 41 01 01  |..A..........A..
ACD7  01 B1 41 41 01 41 41 01 41 FC FD 1D AD D8 B0 00  |..AA.AA.A.......
ACE7  09 FB E2 91 71 E1 21 01 F5 03 FE 02 FD 1D AD D8  |....q.!.........
ACF7  B3 00 03 E2 01 02 02 02 01 FD 59 AD FD 59 AD FD  |..........Y..Y..
AD07  93 AD 93 72 52 42 FD 93 AD D8 30 00 05 93 82 72  |...rRB....0....r
AD17  62 EB 00 FD E1 AC F5 00 EC 03 D8 F0 87 01 07 34  |b..............4
AD27  F0 01 E3 99 D8 F3 00 03 E2 93 94 D8 F0 87 01 07  |................
AD37  34 E2 09 D8 F3 00 03 E2 93 94 D8 F0 87 01 07 34  |4..............4
AD47  E3 B9 D8 F3 00 03 E2 93 94 D8 F0 87 01 07 34 E3  |..............4.
AD57  A8 FC D8 F3 00 05 EB 01 01 F2 03 03 FB E3 21 02  |..............!.
AD67  55 43 53 72 FE 02 F2 00 D8 3F 00 01 91 92 72 93  |UCSr.....?....r.
AD77  D8 F3 00 05 E2 03 E3 B3 A2 D8 3F 00 01 91 92 72  |..........?....r
AD87  92 91 D8 F3 00 05 E2 03 E3 B3 A2 FC D8 F0 00 06  |................
AD97  EB 00 FB E2 91 71 23 E3 91 71 21 FE 02 D8 F3 00  |.....q#..q!.....
ADA7  03 EB 01 01 E3 21 42 52 72 FC FD F8 AD EE 01 D8  |.....!BRr.......
ADB7  B0 00 06 C1 F5 04 E2 91 71 E1 21 01 E2 91 71 E1  |........q.!...q.
ADC7  21                                               |!

loc_ADC8:  ; 0 xrefs: 
ADC8  F5 00    SBC $00,X               
ADCA  EE 00 FD INC $FD00               
ADCD  F8       SED                     
ADCE  AD D8 B3 LDA $B3D8               
ADD1  00 03    BRK #$03                

; ==== data $ADD3..$B187  (949 bytes) ====
ADD3  E3 71 72 72 72 71 FD 32 AE FD 32 AE FD 67 AE 43  |.qrrrq.2..2..g.C
ADE3  22 02 E4 B2 FD 67 AE D8 3F 00 05 E3 43 32 22 12  |"....g..?...C2".
ADF3  EB 00 FD B1 AD EC 03 D8 F0 86 01 07 34 F0 01 E3  |............4...
AE03  49 D8 F3 00 03 E2 43 44 D8 F0 86 01 07 34 E3 79  |I.....CD.....4.y
AE13  D8 F3 00 03 E2 43 44 D8 F0 86 01 07 34 E3 69 D8  |.....CD.....4.i.
AE23  F3 00 03 E2 43 44 D8 F0 86 01 07 34 E3 58 FC D8  |....CD.....4.X..
AE33  F3 00 05 F5 01 F2 03 03 EB 01 01 FB E4 91 72 E3  |..............r.
AE43  05 E4 B3 E3 03 22 FE 02 F2 00 F4 01 41 42 22 43  |....."......AB"C
AE53  F4 05 E3 73 63 52 F4 01 41 42 22 42 41 F4 05 E3  |...scR..AB"BA...
AE63  73 63 52 FC EE 01 D8 B0 00 06 F5 02 EB 00 FB E2  |scR.............
AE73  93 71 22 E3 91 71 FE 02 EE 00 F5 00 D8 F3 00 03  |.q"..q..........
AE83  EB 01 01 E4 91 B2 E3 02 22 FC EC 03 D8 14 FD DF  |........".......
AE93  AE FE 08 EC 08 FD DF AE FE 02 EC 03 FD DF AE FE  |................
AEA3  02 EC 08 FD DF AE FE 02 EC 03 FD DF AE FE 02 FD  |................
AEB3  F9 AE FB 21 21 51 71 91 71 51 41 FE 02 FD F9 AE  |...!!Qq.qQA.....
AEC3  21 21 51 71 91 71 51 E3 A1 E4 A1 E3 A1 E3 91 E4  |!!Qq.qQ.........
AED3  91 E3 81 E4 81 E3 71 E4 71 FD 8D AE FB E4 91 91  |......q.q.......
AEE3  E3 01 21 E4 91 71 91 E3 01 E4 91 91 71 91 E3 01  |..!..q......q...
AEF3  E4 91 E3 21 01 FC E4 A1 A1 E3 51 21 E4 A1 E3 51  |...!......Q!...Q
AF03  E4 A1 E3 51 01 01 71 41 E4 A1 E3 71 01 71 FC D8  |...Q..qA...q.q..
AF13  FD 75 AF B1 01 41 01 B1 01 41 B1 01 B1 41 01 B1  |.u...A...A...A..
AF23  41 01 41 FD 75 AF B1 01 41 01 B1 01 41 B1 41 41  |A.A.u...A...A.AA
AF33  B1 41 B1 41 B1 41 FD 75 AF B1 01 41 01 B1 01 41  |.A.A.A.u...A...A
AF43  B1 41 B1 01 41 B1 01 41 B1 FD 75 AF B1 01 41 01  |.A..A..A..u...A.
AF53  B1 01 41 B1 B1 41 41 B1 41 41 41 41 FD 75 AF B1  |..A..AA.AAAA.u..
AF63  01 41 01 B1 01 41 B1 41 41 B1 41 B1 41 41 41 FD  |.A...A.AA.A.AAA.
AF73  12 AF FB B1 01 41 01 B1 01 41 01 B1 01 41 B1 01  |.....A...A...A..
AF83  B1 41 B1 FE 03 FC EC 01 F5 01 D8 03 00 03 FB FD  |.A..............
AF93  33 B0 FE 04 EB 01 01 FD 3E B0 7A 81 71 66 F2 00  |3.......>.z.qf..
AFA3  D8 30 00 06 61 65 FD 3E B0 9A A1 91 86 F2 00 D8  |.0..ae.>........
AFB3  30 00 06 E1 21 25 F2 00 D8 B3 00 03 F5 03 E3 92  |0...!%..........
AFC3  E2 02 22 E3 91 E2 02 23 F5 01 E3 92 E2 02 22 E3  |.."....#......".
AFD3  91 E2 02 23 F5 03 E3 92 E2 02 22 E3 91 E2 02 23  |...#......"....#
AFE3  F5 00 E3 92 E2 02 22 E3 91 E2 02 23 FD 50 B0 D8  |......"....#.P..
AFF3  B0 00 05 E2 01 E3 B1 A4 D8 30 00 06 E3 01 05 D8  |.........0......
B003  B0 00 05 F5 02 E3 01 E4 B1 E3 04 FD 50 B0 F4 01  |............P...
B013  F2 02 03 F9 30 01 E3 B1 A1 91 81 71 61 51 41 31  |....0......qaQA1
B023  21 11 F5 01 01 E4 B1 A1 F5 02 91 81 71 FD 97 AF  |!...........q...
B033  E4 92 E3 02 22 E4 91 E3 02 23 FC F5 00 D8 B0 00  |...."....#......
B043  02 F2 01 04 E2 46 36 26 04 E3 92 E2 FC D8 30 00  |.....F6&......0.
B053  06 E2 91 95 D8 B0 00 05 FB E2 41 31 E3 91 FE 06  |..........A1....
B063  D8 30 00 06 E2 01 05 FC EC 01 EE 01 D8 30 00 03  |.0...........0..
B073  F5 05 C2 FB FD 33 B0 FE 02 F5 04 FD 33 B0 F5 05  |.....3......3...
B083  E4 92 E3 02 22 E4 91 E3 02 21 EB 01 01 FD 22 B1  |...."....!....".
B093  7D F5 02 81 71 62 EE 00 F5 00 F2 00 D8 30 00 06  |}...qb.......0..
B0A3  01 05 FD 22 B1 9D F5 02 A1 91 82 EE 00 F5 00 F2  |..."............
B0B3  00 D8 30 00 06 E2 81 85 F2 00 D8 B3 00 03 F5 04  |..0.............
B0C3  E3 42 72 92 41 72 93 F5 02 42 72 92 41 72 93 F5  |.Br.Ar...Br.Ar..
B0D3  04 42 72 92 41 72 93 F5 01 42 72 92 41 72 93 FD  |.Br.Ar...Br.Ar..
B0E3  36 B1 D8 B0 00 05 E3 71 61 54 D8 30 00 06 E4 71  |6......qaT.0...q
B0F3  75 D8 B0 00 05 F5 02 E4 71 61 74 FD 36 B1 F4 01  |u.......qat.6...
B103  F2 02 03 F9 B0 71 61 51 41 31 21 11 01 E4 B1 A1  |.....qaQA1!.....
B113  91 81 F5 01 71 61 51 F5 02 41 31 21 FD 8D B0 EE  |....qaQ..A1!....
B123  02 D8 B0 00 02 F5 03 F2 01 04 E2 49 36 26 02 E3  |...........I6&..
B133  92 E2 FC F5 00 D8 30 00 06 E2 41 45 EE 02 D8 B0  |......0...AE....
B143  00 05 F5 03 C1 FB E2 41 31 E3 91 FE 05 E2 41 31  |.......A1.....A1
B153  EE 00 F5 00 D8 30 00 06 E3 71 75 FC EC 01 D8 18  |.....0...qu.....
B163  E4 92 E3 02 22 E4 91 E3 02 D8 2C 23 FD 61 B1 D8  |....".....,#.a..
B173  FB B1 01 01 01 B1 01 B1 41 01 01 41 B1 FE 03 B1  |........A..A....
B183  01 01 01 B1 01                                   |.....

loc_B188:  ; 0 xrefs: 
B188  B1 51    LDA ($51),Y             
B18A  01 61    ORA ($61,X)             
B18C  71 71    ADC ($71),Y             
B18E  D8       CLD                     
B18F  FB FD B6 ISC $B6FD,Y             
B192  B1 FE    LDA ($FE),Y             
B194  09 FD    ORA #$FD                
B196  C3 B1    DCP ($B1,X)             
B198  FD B6 B1 SBC $B1B6,X             
B19B  FD D0 B1 SBC $B1D0,X             
B19E  FD B6 B1 SBC $B1B6,X             
B1A1  FD C3 B1 SBC $B1C3,X             
B1A4  FB FD B6 ISC $B6FD,Y             
B1A7  B1 FE    LDA ($FE),Y             
B1A9  03 FD    SLO ($FD,X)             
B1AB  C3 B1    DCP ($B1,X)             
B1AD  FD B6 B1 SBC $B1B6,X             
B1B0  FD D0 B1 SBC $B1D0,X             
B1B3  FD 8E B1 SBC $B18E,X             
B1B6  B1 01    LDA ($01),Y             
B1B8  41 01    EOR ($01,X)             
B1BA  B1 01    LDA ($01),Y             
B1BC  B1 41    LDA ($41),Y             
B1BE  01 01    ORA ($01,X)             
B1C0  41 B1    EOR ($B1,X)             
B1C2  FC B1 01 NOP $01B1,X             
B1C5  41 01    EOR ($01,X)             
B1C7  B1 01    LDA ($01),Y             
B1C9  B1 41    LDA ($41),Y             
B1CB  01 B1    ORA ($B1,X)             
B1CD  41 41    EOR ($41,X)             
B1CF  FC B1 01 NOP $01B1,X             
B1D2  41 01    EOR ($01,X)             
B1D4  B1 41    LDA ($41),Y             
B1D6  B1 41    LDA ($41),Y             
B1D8  01 41    ORA ($41,X)             
B1DA  41 41    EOR ($41,X)             
B1DC  FC EE 01 NOP $01EE,X             
B1DF  DA       NOP                     
B1E0  3B 00 05 RLA $0500,Y             
B1E3  FD EA B1 SBC $B1EA,X             

; ==== data $B1E6..$B3D6  (497 bytes) ====
B1E6  22 FD E3 B1 E3 A2 E2 52 22 E3 72 A2 92 E2 52 22  |"......R".r...R"
B1F6  E3 A2 72 A2 E2 52 22 E3 A2 E2 02 22 02 E3 92 52  |..r..R"...."...R
B206  92 A2 E2 02 22 02 E3 A2 72 E2 22 E3 A2 E2 52 22  |...."...r."...R"
B216  A2 FC EE 02 D5 B0 00 03 F5 02 C3 F8 0A FD EA B1  |................
B226  22 FD EA B1 F8 05 21 DA B0 00 06 F5 02 FB E2 71  |".....!........q
B236  51 71 91 A1 91 71 51 FE FF DA 42 C0 C0 C0 C0 E3  |Qq...qQ...B.....
B246  72 7C 72 32 38 DA 7F 34 DA 42 32 52 5C 52 72 76  |r|r28..4.B2R\Rrv
B256  71 21 61 52 22 51 FB 72 76 71 21 A1 92 DA 9F 73  |q!aR"Q.rvq!....s
B266  DA 42 32 DA 9F 32 C5 DA 52 33 52 72 52 DA 9F 52  |.B2..2..R3RrR..R
B276  C5 52 C1 53 C1 DA 42 72 76 71 21 61 52 22 51 FE  |.R.S..Brvq!aR"Q.
B286  FF DA C0 C0 C0 CA F1 01 FB 31 FE 06 FB B2 B8 B1  |.........1......
B296  B1 33 B1 B2 B8 B1 B1 33 31 B2 B8 B1 B1 33 B1 B2  |.3.....31....3..
B2A6  B8 B1 B1 31 31 31 31 FE FF D8 B3 06 02 02 7F F0  |...1111.........
B2B6  02 FB E5 72 A2 E4 22 52 FE 04 FB E5 72 A2 E4 12  |...r.."R....r...
B2C6  42 FE 04 FD AF B2 EE 02 D8 30 02 03 04 7F C2 F0  |B........0......
B2D6  01 FB E5 72 A2 E4 22 52 FE 04 FB E5 72 A2 E4 12  |...r.."R....r...
B2E6  42 FE 04 FB E5 72 A2 E4 22 52 FE 04 FB E5 72 A2  |B....r.."R....r.
B2F6  E4 12 42 FE 04 FD D7 B2 DE 90 EB 03 01 FD 21 B3  |..B...........!.
B306  F8 0A F2 01 0A E0 10 F2 00 F8 08 02 E1 B2 FD 21  |...............!
B316  B3 F8 0C F2 03 0B E0 40 FD 03 B3 F8 0E F2 01 08  |.......@........
B326  E1 A0 F8 08 F2 00 92 82 78 FC D8 B2 B6 F1 01 38  |........x......8
B336  F1 00 C6 D1 05 05 06 D8 16 B2 FD 30 B3 EC 01 D1  |...........0....
B346  B0 07 01 05 23 F0 01 EB 04 01 E2 24 35 F8 09 E2  |....#......$5...
B356  45 E3 94 92 B2 E2 02 2A 22 42 76 F4 0D EB 00 E0  |E......*"Bv.....
B366  22 E1 B6 FD 30 B4 E2 44 F8 06 81 98 F8 09 76 52  |"...0..D......vR
B376  42 FB 44 E3 92 E2 04 02 22 02 FE 02 24 72 46 F4  |B.D....."...$rF.
B386  0D EB 00 E0 22 22 72 44 FD 30 B4 E1 04 E2 A2 92  |....""rD.0......
B396  72 96 E3 94 E2 94 42 98 93 B3 E1 02 24 E2 B2 74  |r.....B.....$..t
B3A6  46 A6 A2 A3 93 72 94 52 F8 0F E1 0A F8 01 CC F8  |F....r.R........
B3B6  09 53 43 02 F8 0D 0F F8 01 C3 F8 09 EB 00 F4 0D  |.SC.............
B3C6  E0 41 51 42 02 E1 72 56 FD 3A B4 56 E1 52 A2 92  |.AQB..rV.:.V.R..
B3D6  78                                               |x

loc_B3D7:  ; 0 xrefs: 
B3D7  74 A6    NOP $A6,X               

; ==== data $B3D9..$B44B  (115 bytes) ====
B3D9  92 74 56 72 54 26 E1 A2 E0 22 52 E1 78 74 A6 92  |.tVrT&..."R.xt..
B3E9  74 56 72 54 F8 0A 2C F8 01 F5 01 E1 03 F5 00 35  |tVrT..,........5
B3F9  56 96 F8 0A E0 08 F8 0B 04 36 02 E1 94 E1 AC E0  |V........6......
B409  2E C4 E1 A4 54 24 56 32 04 E2 AC CC E1 A4 54 24  |....T$V2......T$
B419  56 32 04 E2 A4 E1 24 54 D8 B0 00 0E F5 02 E2 A1  |V2....$T........
B429  E1 21 F5 00 51 A0 FF EB 04 01 D9 B0 07 01 05 23  |.!..Q..........#
B439  FC EC 03 DB B0 00 0D E1 56 72 54 26 E0 51 41 54  |........VrT&.QAT
B449  E1 56 72                                         |.Vr

loc_B44C:  ; 0 xrefs: 
B44C  54 24    NOP $24,X               
B44E  E0 22    CPX #$22                
B450  E1 A2    SBC ($A2,X)             

; ==== data $B452..$BA41  (1520 bytes) ====
B452  52 22 E0 08 04 E1 98 F8 0B A2 E0 02 E1 A8 A4 FC  |R"..............
B462  EC 01 EE 01 D9 B3 00 0E FB E4 52 92 E3 02 48 02  |..........R...H.
B472  FE 02 E4 42 72 E3 22 E4 B8 72 42 A2 E3 12 76 42  |...Br."..rB...vB
B482  E4 A2 FB E4 22 52 92 E3 04 42 E4 92 52 FE 02 E4  |...."R...B..R...
B492  02 42 72 B6 72 42 02 42 72 A4 E3 42 E4 A2 72 FB  |.Br.rB.Br..B..r.
B4A2  E4 52 92 E3 02 48 02 E4 52 92 E3 02 42 03 E4 93  |.R...H..R...B...
B4B2  52 E4 42 72 E3 22 E4 B8 72 E4 42 72 A2 E3 12 53  |R.Br."..r.Br...S
B4C2  43 22 FB E4 22 52 92 E3 02 52 02 E4 92 52 FE 02  |C".."R...R...R..
B4D2  FB E4 02 42 72 E3 06 E4 72 42 FE 02 F5 01 44 F8  |...Br...rB....D.
B4E2  01 C1 EE 00 FD 99 B5 E2 A2 E3 A2 E2 22 52 22 A2  |............"R".
B4F2  52 FD 7F B5 22 A2 E1 22 FD 7F B5 A2 E1 22 52 E3  |R...".."....."R.
B502  52 E2 02 32 02 92 02 E3 52 E2 02 32 02 52 02 E3  |R..2....R..2.R..
B512  72 A2 E2 22 E3 A2 E2 52 22 D1 B0 00 0E F5 03 E4  |r.."...R".......
B522  A9 E3 28 F5 00 58 A7 E2 27 57 A7 E1 27 56 F8 08  |..(..X..'W..'V..
B532  AB DB 7B 00 0E F5 01 C4 E3 52 A2 E2 24 E3 A4 E3  |..{......R..$...
B542  92 52 32 02 94 22 52 A2 52 E2 22 E3 A2 52 A2 E2  |.R2.."R.R."..R..
B552  22 E3 A2 E2 52 22 E3 52 A2 E2 24 E3 A4 92 E2 02  |"...R".R..$.....
B562  52 72 94 52 22 A2 52 E1 22 E2 A2 F8 01 C2 D8 B0  |Rr.R".R.".......
B572  00 0E F5 02 E2 51 A1 F5 00 E1 21 50 FF FB E2 32  |.....Q....!P...2
B582  72 A2 72 E1 32 E2 A2 FE 02 22 52 A2 52 E1 22 E2  |r.r.2...."R.R.".
B592  A2 E3 A2 E2 22 52 FC EC 03 F5 01 DB 7B 00 0E FB  |...."R......{...
B5A2  E3 A2 E2 22 52 22 A2 52 FE 04 E3 92 E2 02 32 02  |..."R".R......2.
B5B2  92 32 E2 52 E1 02 E2 52 02 32 E3 92 E2 22 52 A2  |.2.R...R.2..."R.
B5C2  52 E1 22 FC EC 01 D9 90 E3 EB 01 01 50 50 40 40  |R.".........PP@@
B5D2  20 20 00 00 EB 00 D9 27 E4 52 52 C2 D9 81 E3 44  |  .....'.RR....D
B5E2  24 42 E4 54 C4 D9 83 E3 43 23 02 D9 27 E4 42 42  |$B.T....C#..'.BB
B5F2  D9 81 C2 B4 74 E3 22 D9 27 E4 72 72 D9 83 A2 F2  |....t.".'.rr....
B602  07 09 E3 56 F3 05 05 44 F2 00 D9 30 52 52 E3 02  |...V...D...0RR..
B612  D9 90 5A D9 48 E4 54 E3 02 D9 90 58 C2 D9 90 E3  |..Z.H.T....X....
B622  05 C1 F2 08 08 54 F2 00 44 D9 30 02 D9 90 06 F2  |.....T..D.0.....
B632  08 08 E4 74 F2 00 54 76 FF D9 FB C0 FE 07 C6 F1  |...t..Tv........
B642  00 B4 51 51 61 61 71 71 B2 B4 F1 01 44 F1 00 B4  |..QQaaqq....D...
B652  B2 B2 B4 F1 01 42 F1 00 B3 B3 B2 B2 B4 F1 01 44  |.....B.........D
B662  F1 00 B4 B2 B2 B4 F1 01 42 F1 00 B2 F1 01 44 42  |........B.....DB
B672  F1 00 FB B2 02 02 F1 01 42 F1 00 B2 02 F1 01 42  |........B......B
B682  F1 00 B2 FE 04 FF EC 01 D9 F3 00 02 EB 01 01 F2  |................
B692  03 02 E3 C2 03 03 03 E4 A3 84 D1 30 87 02 02 7F  |...........0....
B6A2  F2 00 E5 36 86 E4 06 36 86 E3 06 36 E8 84 06 36  |...6...6...6...6
B6B2  F2 03 02 D9 F3 00 02 E4 A2 F2 00 D1 30 87 02 02  |............0...
B6C2  7F E5 56 A6 E4 26 56 A6 E3 26 56 A6 E8 84 56 A9  |..V..&V..&V...V.
B6D2  D9 3F 00 05 F2 02 01 E3 91 82 E2 02 E3 B1 E2 22  |.?............."
B6E2  D9 3F 00 07 39 FF EC 01 D9 F3 00 02 EB 01 01 F2  |.?..9...........
B6F2  03 02 F0 01 E4 C2 73 73 73 53 34 EE 01 F2 00 D6  |......sssS4.....
B702  30 85 02 04 7F E5 32 81 E4 01 31 81 E3 01 E8 83  |0.....2...1.....
B712  31 01 EE 00 F2 03 02 D9 F3 00 02 E4 52 F2 00 EE  |1...........R...
B722  01 D1 30 85 02 04 7F E5 5C A6 E4 26 56 A6 E3 26  |..0.....\..&V..&
B732  56 E8 83 A6 59 EE 00 D9 3F 00 05 F2 02 01 E3 41  |V...Y...?......A
B742  32 72 61 92 D9 3F 00 07 A9 FF EC 01 D9 13 FB E3  |2ra..?..........
B752  01 FE 20 D9 18 F2 08 04 E4 C1 91 82 D9 30 E3 02  |.. ..........0..
B762  E4 B1 E3 22 D9 90 39 FF D9 FB B1 01 41 01 FE 06  |..."..9.....A...
B772  B1 41 01 41 41 B1 41 41 B1 41 41 B1 41 41 01 41  |.A.AA.AA.AA.AA.A
B782  B1 41 41 B1 41 41 41 D1 44 45 D9 41 41 FF FD 3A  |.AA.AAA.DE.AA..:
B792  B4 EC 00 DA F3 00 02 EB 01 01 E3 71 62 61 52 51  |...........qbaRQ
B7A2  42 41 F0 01 DA F3 07 04 03 16 38 EB 00 EC 02 D7  |BA........8.....
B7B2  F3 00 02 FB E5 93 E4 43 32 23 03 E5 92 FE 04 EB  |.......C2#......
B7C2  01 01 FB D7 F0 00 02 F2 02 02 E3 C2 04 3C 04 32  |.............<.2
B7D2  03 33 02 33 4D D7 B0 00 05 E3 41 31 4E FE 02 F2  |.3.3M.....A1N...
B7E2  02 01 D7 F3 00 05 E3 03 63 E2 02 3A 32 32 32 33  |........c..:2223
B7F2  23 02 23 03 E3 92 E2 03 E3 93 72 93 73 82 93 73  |#.#.......r.s..s
B802  84 E2 32 32 32 33 23 02 63 53 32 63 63 62 F4 02  |..2223#.cS2ccb..
B812  7E 62 70 F2 00 FB D7 B0 00 05 EB 00 E3 91 E2 41  |~bp............A
B822  E3 91 E2 31 44 F5 03 F9 F0 E3 91 E2 41 E3 91 E2  |...1D.......A...
B832  31 44 F5 00 FE 04 F2 02 02 D7 3F 00 05 F5 03 C2  |1D........?.....
B842  E2 32 32 32 F5 02 32 32 32 32 F5 00 FB 32 FE 08  |.222..2222...2..
B852  FB 62 FE 08 FB E1 02 FE 06 F2 00 D2 F0 00 02 F5  |.b..............
B862  01 E2 B1 A1 91 81 71 61 51 F5 02 41 31 21 F5 03  |......qaQ..A1!..
B872  11 01 E3 B1 A1 F5 00 FD AF B7 F8 01 C1 FD 99 B5  |................
B882  F8 03 E2 A7 EC 00 EB 01 01 DA F3 00 02 F5 00 E3  |................
B892  21 12 11 02 01 E4 B2 B1 F0 01 DA F3 07 04 03 16  |!...............
B8A2  A8 EB 00 EC 02 EE 02 D7 F3 00 02 F5 03 C2 FB E5  |................
B8B2  93 E4 43 32 23 03 E5 92 FE 04 F5 00 EB 01 01 EE  |..C2#...........
B8C2  00 FB D7 F0 00 02 F2 02 02 E4 94 9C 94 92 93 93  |................
B8D2  92 93 9D EE 01 D7 B0 00 05 F5 02 E3 43 31 4E F5  |............C1N.
B8E2  00 FE 02 F2 02 01 D7 F3 00 05 E3 01 EE 00 03 62  |...............b
B8F2  E2 0A E3 92 92 92 93 93 92 93 93 E3 42 43 43 42  |............BCCB
B902  43 43 42 43 43 44 E3 92 92 92 93 93 92 E2 03 03  |CCBCCD..........
B912  02 03 03 02 F4 02 0E 02 00 F2 00 FB D7 B0 00 05  |................
B922  EE 01 F5 03 EB 00 E3 92 E2 41 E3 91 E2 31 43 F5  |.........A...1C.
B932  03 F9 F0 EE 00 E3 41 91 41 91 94 F5 00 FE 04 F2  |......A.A.......
B942  02 02 D7 3F 00 05 F5 03 C2 E3 92 92 92 F5 02 92  |...?............
B952  92 92 92 F5 00 FB 92 FE 08 FB E2 02 FE 08 FB 62  |...............b
B962  FE 06 F2 00 D2 F0 00 02 F5 01 31 21 11 01 E3 B1  |..........1!....
B972  A1 91 F5 02 81 71 61 F5 03 51 41 31 21 F5 00 FD  |.....qa..QA1!...
B982  A5 B8 DB 40 FB CC FE 07 DA 1E E3 81 72 71 62 61  |...@........rqba
B992  52 51 DA 90 48 EC 02 D7 12 E4 91 D7 40 92 E3 43  |RQ..H.......@..C
B9A2  D7 20 32 D7 40 23 03 D7 28 E4 92 FD 97 B9 DB FB  |. 2.@#..(.......
B9B2  CC FE 07 DA 41 41 B1 41 41 B1 41 41 B1 41 D5 FB  |....AA.AA.AA.A..
B9C2  41 FE 10 D7 FD 0D BA FD 21 BA FD 0D BA FD 21 BA  |A.......!.....!.
B9D2  FD 0D BA FD 21 BA FD 0D BA FD 31 BA FD 0D BA FD  |....!.....1.....
B9E2  31 BA FB B1 B1 01 01 41 01 B1 01 B1 41 41 01 91  |1......A....AA..
B9F2  91 01 91 FE 04 FD 0D BA B1 B1 01 01 41 01 B1 01  |............A...
BA02  41 41 B1 41 B1 41 41 41 FD C5 B9 FB B1 B1 01 01  |AA.A.AAA........
BA12  41 01 B1 01 B1 01 B1 41 01 01 41 B1 FE 03 FC B1  |A......A..A.....
BA22  B1 01 01 41 01 B1 01 B1 41 B1 41 91 A2 91 FC B1  |...A....A.A.....
BA32  B1 01 01 41 01 B1 01 B1 01 41 41 B1 41 41 41 FC  |...A.....AA.AAA.

loc_BA42:  ; 1 xrefs: 8006
BA42  A9 00    LDA #$00                
BA44  8D 7A 01 STA $017A               
BA47  A5 79    LDA $79                 
BA49  D0 28    BNE loc_BA73            
BA4B  A5 53    LDA $53                 
BA4D  C9 02    CMP #$02                
BA4F  F0 22    BEQ loc_BA73            
BA51  0A       ASL A                   
BA52  A8       TAY                     
BA53  B9 A8 BA LDA $BAA8,Y             
BA56  85 10    STA $10                 
BA58  B9 A9 BA LDA $BAA9,Y             
BA5B  85 11    STA $11                 
BA5D  A5 9C    LDA $9C                 
BA5F  0A       ASL A                   
BA60  A8       TAY                     
BA61  B1 10    LDA ($10),Y             
BA63  85 12    STA $12                 
BA65  C8       INY                     
BA66  B1 10    LDA ($10),Y             
BA68  85 13    STA $13                 
BA6A  A5 73    LDA $73                 
BA6C  29 1E    AND #$1E                
BA6E  85 17    STA $17                 
BA70  4C 74 BA JMP loc_BA74            

loc_BA73:  ; 2 xrefs: BA49 BA4F
BA73  60       RTS                     

loc_BA74:  ; 1 xrefs: BA70
BA74  A0 00    LDY #$00                

loc_BA76:  ; 1 xrefs: BA9D
BA76  B1 12    LDA ($12),Y             
BA78  C9 FF    CMP #$FF                
BA7A  F0 2B    BEQ loc_BAA7            
BA7C  CD 79 01 CMP $0179               
BA7F  D0 18    BNE loc_BA99            
BA81  C8       INY                     
BA82  B1 12    LDA ($12),Y             
BA84  C5 17    CMP $17                 
BA86  D0 12    BNE loc_BA9A            
BA88  C8       INY                     
BA89  B1 12    LDA ($12),Y             
BA8B  CD 77 01 CMP $0177               
BA8E  D0 0B    BNE loc_BA9B            
BA90  C8       INY                     
BA91  B1 12    LDA ($12),Y             
BA93  25 3B    AND $3B                 
BA95  D0 08    BNE loc_BA9F            
BA97  F0 03    BEQ loc_BA9C            

loc_BA99:  ; 1 xrefs: BA7F
BA99  C8       INY                     

loc_BA9A:  ; 1 xrefs: BA86
BA9A  C8       INY                     

loc_BA9B:  ; 1 xrefs: BA8E
BA9B  C8       INY                     

loc_BA9C:  ; 1 xrefs: BA97
BA9C  C8       INY                     
BA9D  D0 D7    BNE loc_BA76            

loc_BA9F:  ; 1 xrefs: BA95
BA9F  A9 00    LDA #$00                
BAA1  8D 77 01 STA $0177               
BAA4  EE 7A 01 INC $017A               

loc_BAA7:  ; 1 xrefs: BA7A
BAA7  60       RTS                     

; ==== data $BAA8..$BDFC  (853 bytes) ====
BAA8  B4 BA D4 BA B4 BA FB BA 2B BB 44 BB CA BA CA BA  |........+.D.....
BAB8  CA BA C2 BA CA BA CB BA CA BA 00 14 D5 01 01 08  |................
BAC8  D5 02 FF 00 14 D5 01 01 02 D5 02 FF E8 BA E8 BA  |................
BAD8  E8 BA E8 BA E4 BA E9 BA F2 BA E8 BA 00 06 D3 01  |................
BAE8  FF 02 0E D3 01 00 10 D3 02 FF 00 1C D3 00 01 0A  |................
BAF8  D3 02 FF 09 BB 19 BB 19 BB 19 BB 19 BB 19 BB 1A  |................
BB08  BB 00 1C F7 01 00 1E F7 02 01 1C F7 04 01 1E F7  |................
BB18  08 FF 02 0C F7 01 02 0E F7 02 02 10 F7 04 02 12  |................
BB28  F7 08 FF 43 BB 43 BB 43 BB 43 BB 43 BB 43 BB 43  |...C.C.C.C.C.C.C
BB38  BB 3F BB 43 BB 43 BB 00 08 F6 01 FF 75 BB 75 BB  |.?.C.C......u.u.
BB48  75 BB 75 BB 75 BB 60 BB 75 BB 75 BB 75 BB 75 BB  |u.u.u.`.u.u.u.u.
BB58  75 BB 75 BB 71 BB 75 BB 00 18 F4 01 00 1A F4 02  |u.u.q.u.........
BB68  00 1C F4 04 00 1E F4 08 FF 01 00 F4 01 FF 01 02  |................
BB78  0E F7 02 02 10 F7 04 02 12 F7 08 FF 9C BB 9C BB  |................
BB88  9C BB 9C BB 9C BB 9C BB 9C BB 98 BB 9C BB 9C BB  |................
BB98  00 08 F6 01 FF CE BB CE BB CE BB CE BB CE BB B9  |................
BBA8  BB CE BB CE BB CE BB CE BB CE BB CE BB CA BB CE  |................
BBB8  BB 00 18 F4 01 00 1A F4 02 00 1C F4 04 00 1E F4  |................
BBC8  08 FF 01 00 F4 01 FF 00 FF 30 08 A8 00 00 00 00  |.........0......
BBD8  FF 14 30 00 00 00 00 00 FF 28 56 AA 00 00 00 60  |..0......(V....`
BBE8  FF 10 18 A0 00 00 00 00 FF 0C AC 02 00 00 00 00  |................
BBF8  FF 08 0C 22 00 00 00 00 FF FF FF FF 92 DF FF 7F  |..."............
BC08  FF FF FF FF AF FF FF 77 FF FF FF FF DF FF FF 7F  |.......w........
BC18  FF FF FF FF AB FB D7 7F FF FF FF FF D0 EF FF FF  |................
BC28  FF FF FF FF EF FF EC 7F FF FF FF FF EB FB AF 7F  |................
BC38  FF FF FF FF FF B9 DF 7F FF FF FF FF 87 FF FD 7F  |................
BC48  FF FF FF FF FD F9 EC 7F FF FF FF FF FF FE 7F 7F  |................
BC58  FF FF FF FF BE DE F3 7F FF FF FF FF FF 6F FF 7F  |.............o..
BC68  FF FF FF FF FB EF 3D 7F FF FF FF FF EB FF BF 7F  |......=.........
BC78  FF FF FF FF 77 DE CB 7F FF FF FF FF FD EF FF 7F  |....w...........
BC88  FF FF FF FF 9B BF FB 7F FF FF FF FF BF F7 DF 7E  |...............~
BC98  FF FF FF FF F7 DF 97 7F FF FF FF FF DB F7 E7 7F  |................
BCA8  FF FF FF FF CD F5 ED 7F FF FF FF FF BF FE C2 7F  |................
BCB8  FF FF FF FF DF DD FE FF FF FF FF FF BF FF FF 7F  |................
BCC8  FF BF FF FF FD 4E FC FF FF FF FF FF D7 FF FF 7F  |.....N..........
BCD8  FF FF FF FF CF FF BF FF FF FF FF FF F7 FF F3 7F  |................
BCE8  FF FF FF FF EE 7F CF 7F FF FF FF FF FD FF FF FF  |................
BCF8  FF FF FF FF 7E BE B7 7F FF 18 30 40 00 00 00 AD  |....~.....0@....
BD08  FF 00 02 00 00 00 00 EB FF 20 02 08 00 00 00 0F  |......... ......
BD18  FF 00 80 08 00 00 00 45 FF 04 20 48 00 00 00 4F  |.......E.. H...O
BD28  FF 02 68 00 00 00 00 7E FF 02 00 00 00 00 00 5E  |..h....~.......^
BD38  FF 06 14 10 00 00 00 02 FF 49 01 40 00 00 00 7B  |.........I.@...{
BD48  DF 00 00 00 00 00 00 C7 FD 0C 00 01 00 00 00 5D  |...............]
BD58  FF 04 04 00 00 00 00 0C FF 04 20 12 00 00 00 57  |.......... ....W
BD68  FF 42 00 08 00 00 00 22 FF 00 00 10 00 00 00 43  |.B.....".......C
BD78  FF 08 60 00 00 00 00 81 FF 28 21 08 00 00 00 7B  |..`......(!....{
BD88  FF 04 40 00 00 00 00 B1 FF 10 08 08 00 00 00 5D  |..@............]
BD98  FF 00 00 00 00 00 00 29 FF 00 2A 24 00 00 00 FF  |.......)..*$....
BDA8  FF 04 10 40 00 00 00 00 FF 01 00 08 00 00 00 55  |...@...........U
BDB8  FF 12 18 12 00 00 00 40 FF 00 CA 50 00 00 00 D7  |.......@...P....
BDC8  FE 04 80 02 00 00 00 5F FF 42 10 04 00 00 00 3D  |......._.B.....=
BDD8  FF 00 00 00 00 00 00 84 FF 4B 50 02 00 00 00 4E  |.........KP....N
BDE8  FF 18 14 00 00 00 00 00 FF 4A 00 06 00 00 00 87  |.........J......
BDF8  FF 48 84 05 00                                   |.H...

loc_BDFD:  ; 0 xrefs: 
BDFD  00 00    BRK #$00                

; ==== data $BDFF..$BFFF  (513 bytes) ====
BDFF  08 FF FF FF FF B7 8F E9 7F FF FF FF FF FF DB D5  |................
BE0F  7F FF FF FF FF 3B 47 BC 7F FF FF FF FF 4D F7 A8  |.....;G......M..
BE1F  7F FF FF FF FF FF ED 73 7F FF FF FF FF F7 9F DE  |.......s........
BE2F  FF FF FF FF FF A9 15 F1 7F FF FF FF FF 82 EA FC  |................
BE3F  FF FF FF FF FF 6F D6 3B 7F FF FF FF FF CD B2 D5  |.....o.;........
BE4F  FF FF DF FF FF EA 25 D2 7F FF FF FF FF BA AF 43  |......%........C
BE5F  7F FF FF FF FF FD DC FF 7F FF FF FF FF 2F AA A3  |............./..
BE6F  FF FF FF FF FF EF 73 F7 FF FF FF FF FF C5 52 8E  |......s.......R.
BE7F  7F FF FF FF FF E7 9D F4 FF FF FF EF FF E5 93 DF  |................
BE8F  7D FF FF FF FF 79 CA 3E 7F FF FF FF FB 13 E3 85  |}....y.>........
BE9F  7F FF FF FF FF D9 FD AF 7F FF FF FF FF BF DF F7  |................
BEAF  FF FF FF FF FF 2D FF BE 7F FF FF FF FF 98 80 8C  |.....-..........
BEBF  7F FF FF FF FF EF AF BA 7F FF FF FF FF C3 9B CF  |................
BECF  7B FF FF FF FF 3D DE DD 7F FF FF FF FF BC ED B5  |{....=..........
BEDF  7F FF FF FF FF EB FB 93 7F FF FF FF FF BD FD EF  |................
BEEF  FF FF FF FF FF E9 1F CF 7F FF FF FF FF 54 F7 5B  |.............T.[
BEFF  FF FF A4 02 9F 00 00 00 C4 FF 62 32 20 00 00 00  |..........b2 ...
BF0F  80 FF 20 84 68 00 00 00 05 FF 08 04 08 00 00 00  |.. .h...........
BF1F  00 FF 24 14 09 00 00 00 00 FF 28 42 08 00 00 00  |..$.......(B....
BF2F  00 FF 44 88 00 00 00 00 00 FF 40 70 01 00 00 00  |..D.......@p....
BF3F  00 FF 16 60 00 00 04 00 84 FF 11 02 A0 00 00 00  |...`............
BF4F  02 FF 82 81 61 00 00 00 01 FF 13 13 36 00 00 00  |....a.......6...
BF5F  00 FF 20 4C C8 00 00 00 10 FF 0A 84 02 00 00 00  |.. L............
BF6F  00 FF 82 48 02 00 00 00 00 FF 41 50 02 00 00 00  |...H......AP....
BF7F  00 FF 86 4C 00 00 00 00 0D FF 09 3E 0A 00 00 00  |...L.......>....
BF8F  00 FF 04 00 63 00 00 00 00 FF 82 22 01 00 00 00  |....c......"....
BF9F  00 FF DC 10 20 00 00 00 00 FF 8A 01 C0 00 00 00  |.... ...........
BFAF  80 FF 2C 60 02 00 00 00 00 FF 58 00 78 00 00 00  |..,`......X.x...
BFBF  80 FF 18 58 05 00 00 00 43 FF 40 0C 50 00 00 00  |...X....C.@.P...
BFCF  00 FF 54 01 2E 00 00 00 00 FF 00 0A 07 00 00 00  |..T.............
BFDF  00 FF 26 09 10 00 00 00 4D FF 49 45 16 00 00 00  |..&.....M.IE....
BFEF  00 FF 60 54 00 00 00 08 00 FF 0A 2E 5C 00 00 00  |..`T........\...
BFFF  00                                               |.