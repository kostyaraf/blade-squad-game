
; ==== data $E000..$E001  (2 bytes) ====
E000  A9 20                                            |. 

loc_E002:  ; 0 xrefs: 
E002  85 74    STA $74                 
E004  20 E1 E1 JSR sub_E1E1            
E007  20 C9 DF JSR $DFC9               
E00A  A9 06    LDA #$06                
E00C  A4 79    LDY $79                 
E00E  D0 02    BNE loc_E012            
E010  A5 53    LDA $53                 

loc_E012:  ; 1 xrefs: E00E
E012  0A       ASL A                   
E013  A8       TAY                     
E014  84 26    STY $26                 
E016  B9 3F DE LDA $DE3F,Y             
E019  85 10    STA $10                 
E01B  B9 40 DE LDA $DE40,Y             
E01E  85 11    STA $11                 
E020  A0 00    LDY #$00                
E022  B1 10    LDA ($10),Y             
E024  85 6C    STA $6C                 
E026  C8       INY                     
E027  B1 10    LDA ($10),Y             
E029  85 6D    STA $6D                 
E02B  A4 26    LDY $26                 
E02D  B9 31 DE LDA $DE31,Y             
E030  85 10    STA $10                 
E032  B9 32 DE LDA $DE32,Y             
E035  85 11    STA $11                 
E037  A0 00    LDY #$00                
E039  B1 10    LDA ($10),Y             
E03B  85 75    STA $75                 
E03D  C8       INY                     
E03E  B1 10    LDA ($10),Y             
E040  85 76    STA $76                 
E042  A5 79    LDA $79                 
E044  D0 03    BNE loc_E049            
E046  4C DF E0 JMP loc_E0DF            

loc_E049:  ; 1 xrefs: E044
E049  20 1C E1 JSR sub_E11C            
E04C  4C B7 E0 JMP loc_E0B7            

loc_E04F:  ; 0 xrefs: 
E04F  A9 00    LDA #$00                
E051  85 74    STA $74                 
E053  85 8B    STA $8B                 
E055  20 C9 DF JSR $DFC9               
E058  A9 06    LDA #$06                
E05A  A4 79    LDY $79                 
E05C  D0 02    BNE loc_E060            
E05E  A5 53    LDA $53                 

loc_E060:  ; 1 xrefs: E05C
E060  0A       ASL A                   
E061  A8       TAY                     
E062  84 26    STY $26                 
E064  B9 3F DE LDA $DE3F,Y             
E067  85 10    STA $10                 
E069  B9 40 DE LDA $DE40,Y             
E06C  85 11    STA $11                 
E06E  A0 00    LDY #$00                
E070  B1 10    LDA ($10),Y             
E072  85 6C    STA $6C                 
E074  C8       INY                     
E075  B1 10    LDA ($10),Y             
E077  85 6D    STA $6D                 
E079  A4 26    LDY $26                 
E07B  B9 31 DE LDA $DE31,Y             
E07E  85 10    STA $10                 
E080  B9 32 DE LDA $DE32,Y             
E083  85 11    STA $11                 
E085  A0 00    LDY #$00                
E087  B1 10    LDA ($10),Y             
E089  85 75    STA $75                 
E08B  C8       INY                     
E08C  B1 10    LDA ($10),Y             
E08E  85 76    STA $76                 
E090  20 1C E1 JSR sub_E11C            
E093  A5 73    LDA $73                 
E095  38       SEC                     
E096  E9 04    SBC #$04                
E098  90 03    BCC loc_E09D            
E09A  4C B7 E0 JMP loc_E0B7            

loc_E09D:  ; 1 xrefs: E098
E09D  A5 66    LDA $66                 
E09F  38       SEC                     
E0A0  E9 01    SBC #$01                
E0A2  4C B9 E0 JMP loc_E0B9            

sub_E0A5:  ; 1 xrefs: E19E
E0A5  20 1C E1 JSR sub_E11C            
E0A8  A5 67    LDA $67                 
E0AA  38       SEC                     
E0AB  E9 80    SBC #$80                
E0AD  90 08    BCC loc_E0B7            

loc_E0AF:  ; 1 xrefs: E116
E0AF  A5 66    LDA $66                 
E0B1  18       CLC                     
E0B2  69 01    ADC #$01                
E0B4  4C B9 E0 JMP loc_E0B9            

loc_E0B7:  ; 4 xrefs: E04C E09A E0AD E119
E0B7  A5 66    LDA $66                 

loc_E0B9:  ; 6 xrefs: E0A2 E0B4 E0DC E0EB E0FA E109
E0B9  30 13    BMI loc_E0CE            
E0BB  8D 79 01 STA $0179               
E0BE  A8       TAY                     
E0BF  B1 02    LDA ($02),Y             
E0C1  0A       ASL A                   
E0C2  A8       TAY                     
E0C3  B1 08    LDA ($08),Y             
E0C5  85 70    STA $70                 
E0C7  C8       INY                     
E0C8  B1 08    LDA ($08),Y             
E0CA  85 71    STA $71                 
E0CC  18       CLC                     
E0CD  60       RTS                     

loc_E0CE:  ; 1 xrefs: E0B9
E0CE  38       SEC                     
E0CF  60       RTS                     

sub_E0D0:  ; 1 xrefs: E198
E0D0  20 1C E1 JSR sub_E11C            
E0D3  A5 67    LDA $67                 
E0D5  18       CLC                     
E0D6  69 7F    ADC #$7F                
E0D8  A5 66    LDA $66                 
E0DA  69 01    ADC #$01                
E0DC  4C B9 E0 JMP loc_E0B9            

loc_E0DF:  ; 1 xrefs: E046
E0DF  20 1C E1 JSR sub_E11C            
E0E2  A5 67    LDA $67                 
E0E4  38       SEC                     
E0E5  E9 7F    SBC #$7F                
E0E7  A5 66    LDA $66                 
E0E9  E9 00    SBC #$00                
E0EB  4C B9 E0 JMP loc_E0B9            

loc_E0EE:  ; 0 xrefs: 
E0EE  20 1C E1 JSR sub_E11C            
E0F1  A5 67    LDA $67                 
E0F3  38       SEC                     
E0F4  E9 17    SBC #$17                
E0F6  A5 66    LDA $66                 
E0F8  E9 00    SBC #$00                
E0FA  4C B9 E0 JMP loc_E0B9            

loc_E0FD:  ; 0 xrefs: 
E0FD  20 1C E1 JSR sub_E11C            
E100  A5 67    LDA $67                 
E102  18       CLC                     
E103  69 DF    ADC #$DF                
E105  A5 66    LDA $66                 
E107  69 00    ADC #$00                
E109  4C B9 E0 JMP loc_E0B9            

sub_E10C:  ; 1 xrefs: E1CC
E10C  20 1C E1 JSR sub_E11C            
E10F  A5 67    LDA $67                 
E111  38       SEC                     
E112  E9 20    SBC #$20                
E114  90 03    BCC loc_E119            
E116  4C AF E0 JMP loc_E0AF            

loc_E119:  ; 1 xrefs: E114
E119  4C B7 E0 JMP loc_E0B7            

sub_E11C:  ; 9 xrefs: E049 E090 E0A5 E0D0 E0DF E0EE E0FD E10C EFA0
E11C  20 C9 DF JSR $DFC9               
E11F  A9 06    LDA #$06                
E121  A4 79    LDY $79                 
E123  D0 02    BNE loc_E127            
E125  A5 53    LDA $53                 

loc_E127:  ; 1 xrefs: E123
E127  0A       ASL A                   
E128  A8       TAY                     
E129  84 17    STY $17                 
E12B  B9 4D DE LDA $DE4D,Y             
E12E  85 02    STA $02                 
E130  B9 4E DE LDA $DE4E,Y             
E133  85 03    STA $03                 
E135  A0 00    LDY #$00                
E137  B1 02    LDA ($02),Y             
E139  85 00    STA $00                 
E13B  C8       INY                     
E13C  B1 02    LDA ($02),Y             
E13E  85 01    STA $01                 
E140  A4 17    LDY $17                 
E142  B9 5B DE LDA $DE5B,Y             
E145  85 0A    STA $0A                 
E147  B9 5C DE LDA $DE5C,Y             
E14A  85 0B    STA $0B                 
E14C  A0 00    LDY #$00                
E14E  B1 0A    LDA ($0A),Y             
E150  85 08    STA $08                 
E152  C8       INY                     
E153  B1 0A    LDA ($0A),Y             
E155  85 09    STA $09                 
E157  A5 9C    LDA $9C                 
E159  0A       ASL A                   
E15A  A8       TAY                     
E15B  B1 00    LDA ($00),Y             
E15D  85 02    STA $02                 
E15F  C8       INY                     
E160  B1 00    LDA ($00),Y             
E162  85 03    STA $03                 
E164  60       RTS                     

loc_E165:  ; 0 xrefs: 
E165  A9 02    LDA #$02                
E167  85 07    STA $07                 

loc_E169:  ; 1 xrefs: E1AB
E169  20 01 DB JSR $DB01               
E16C  A5 07    LDA $07                 
E16E  C9 02    CMP #$02                
E170  D0 03    BNE loc_E175            
E172  20 A3 DB JSR $DBA3               

loc_E175:  ; 1 xrefs: E170
E175  E6 6E    INC $6E                 
E177  A5 6E    LDA $6E                 
E179  C9 20    CMP #$20                
E17B  90 07    BCC loc_E184            
E17D  A9 00    LDA #$00                
E17F  85 6E    STA $6E                 
E181  20 69 DE JSR $DE69               

loc_E184:  ; 1 xrefs: E17B
E184  E6 73    INC $73                 
E186  A5 73    LDA $73                 
E188  C9 20    CMP #$20                
E18A  90 17    BCC loc_E1A3            
E18C  A5 79    LDA $79                 
E18E  D0 13    BNE loc_E1A3            
E190  A9 00    LDA #$00                
E192  85 73    STA $73                 
E194  A5 8B    LDA $8B                 
E196  F0 06    BEQ loc_E19E            
E198  20 D0 E0 JSR sub_E0D0            
E19B  4C A1 E1 JMP loc_E1A1            

loc_E19E:  ; 1 xrefs: E196
E19E  20 A5 E0 JSR sub_E0A5            

loc_E1A1:  ; 1 xrefs: E19B
E1A1  E6 8B    INC $8B                 

loc_E1A3:  ; 2 xrefs: E18A E18E
E1A3  C6 74    DEC $74                 
E1A5  F0 0A    BEQ loc_E1B1            
E1A7  C6 07    DEC $07                 
E1A9  F0 03    BEQ loc_E1AE            
E1AB  4C 69 E1 JMP loc_E169            

loc_E1AE:  ; 1 xrefs: E1A9
E1AE  A9 00    LDA #$00                
E1B0  60       RTS                     

loc_E1B1:  ; 1 xrefs: E1A5
E1B1  A9 00    LDA #$00                
E1B3  85 8B    STA $8B                 
E1B5  85 FD    STA $FD                 
E1B7  A9 01    LDA #$01                
E1B9  60       RTS                     

loc_E1BA:  ; 0 xrefs: 
E1BA  20 DE DB JSR $DBDE               
E1BD  20 73 DC JSR $DC73               
E1C0  E6 73    INC $73                 
E1C2  A5 73    LDA $73                 
E1C4  C9 1E    CMP #$1E                
E1C6  D0 07    BNE loc_E1CF            
E1C8  A9 00    LDA #$00                
E1CA  85 73    STA $73                 
E1CC  20 0C E1 JSR sub_E10C            

loc_E1CF:  ; 1 xrefs: E1C6
E1CF  E6 74    INC $74                 
E1D1  A5 74    LDA $74                 
E1D3  C9 1E    CMP #$1E                
E1D5  F0 03    BEQ loc_E1DA            
E1D7  A9 00    LDA #$00                
E1D9  60       RTS                     

loc_E1DA:  ; 1 xrefs: E1D5
E1DA  A9 00    LDA #$00                
E1DC  85 74    STA $74                 
E1DE  A9 01    LDA #$01                
E1E0  60       RTS                     

sub_E1E1:  ; 1 xrefs: E004
E1E1  A5 79    LDA $79                 
E1E3  D0 47    BNE loc_E22C            
E1E5  A5 67    LDA $67                 
E1E7  38       SEC                     
E1E8  E9 80    SBC #$80                
E1EA  29 F8    AND #$F8                
E1EC  20 07 CB JSR $CB07               
E1EF  85 73    STA $73                 
E1F1  20 08 CB JSR $CB08               
E1F4  85 08    STA $08                 
E1F6  A5 72    LDA $72                 
E1F8  29 40    AND #$40                
E1FA  F0 18    BEQ loc_E214            
E1FC  A5 73    LDA $73                 
E1FE  85 6E    STA $6E                 
E200  A9 24    LDA #$24                
E202  85 6F    STA $6F                 
E204  A9 40    LDA #$40                
E206  85 72    STA $72                 
E208  A5 08    LDA $08                 
E20A  18       CLC                     
E20B  69 C0    ADC #$C0                
E20D  85 6A    STA $6A                 
E20F  A9 27    LDA #$27                
E211  85 6B    STA $6B                 
E213  60       RTS                     

loc_E214:  ; 1 xrefs: E1FA
E214  A5 73    LDA $73                 
E216  85 6E    STA $6E                 
E218  A9 20    LDA #$20                
E21A  85 6F    STA $6F                 
E21C  A9 00    LDA #$00                
E21E  85 72    STA $72                 
E220  A5 08    LDA $08                 
E222  18       CLC                     
E223  69 C0    ADC #$C0                
E225  85 6A    STA $6A                 
E227  A9 23    LDA #$23                
E229  85 6B    STA $6B                 
E22B  60       RTS                     

loc_E22C:  ; 1 xrefs: E1E3
E22C  A9 00    LDA #$00                
E22E  85 6E    STA $6E                 
E230  85 73    STA $73                 
E232  A9 20    LDA #$20                
E234  85 6F    STA $6F                 
E236  A9 C0    LDA #$C0                
E238  85 6A    STA $6A                 
E23A  A9 23    LDA #$23                
E23C  85 6B    STA $6B                 
E23E  60       RTS                     

loc_E23F:  ; 0 xrefs: 
E23F  A0 36    LDY #$36                
E241  20 A7 EC JSR sub_ECA7            
E244  A9 06    LDA #$06                
E246  A4 79    LDY $79                 
E248  D0 02    BNE loc_E24C            
E24A  A5 53    LDA $53                 

loc_E24C:  ; 1 xrefs: E248
E24C  0A       ASL A                   
E24D  A8       TAY                     
E24E  B9 BC E2 LDA $E2BC,Y             
E251  85 00    STA $00                 
E253  B9 BD E2 LDA $E2BD,Y             
E256  85 01    STA $01                 
E258  A0 00    LDY #$00                
E25A  B1 00    LDA ($00),Y             
E25C  85 02    STA $02                 
E25E  C8       INY                     
E25F  B1 00    LDA ($00),Y             
E261  85 03    STA $03                 
E263  A5 9C    LDA $9C                 
E265  0A       ASL A                   
E266  A8       TAY                     
E267  B1 02    LDA ($02),Y             
E269  85 00    STA $00                 
E26B  C8       INY                     
E26C  B1 02    LDA ($02),Y             
E26E  85 01    STA $01                 
E270  A0 00    LDY #$00                
E272  B1 00    LDA ($00),Y             
E274  85 97    STA $97                 
E276  C8       INY                     
E277  B1 00    LDA ($00),Y             
E279  85 AE    STA $AE                 
E27B  C8       INY                     
E27C  B1 00    LDA ($00),Y             
E27E  85 73    STA $73                 
E280  C8       INY                     
E281  B1 00    LDA ($00),Y             
E283  85 66    STA $66                 
E285  C8       INY                     
E286  B1 00    LDA ($00),Y             
E288  85 67    STA $67                 
E28A  C8       INY                     
E28B  B1 00    LDA ($00),Y             
E28D  85 59    STA $59                 
E28F  C8       INY                     
E290  B1 00    LDA ($00),Y             
E292  85 5A    STA $5A                 
E294  C8       INY                     
E295  B1 00    LDA ($00),Y             
E297  85 42    STA $42                 
E299  C8       INY                     
E29A  B1 00    LDA ($00),Y             
E29C  85 43    STA $43                 
E29E  C8       INY                     
E29F  B1 00    LDA ($00),Y             
E2A1  85 46    STA $46                 
E2A3  C8       INY                     
E2A4  B1 00    LDA ($00),Y             
E2A6  85 47    STA $47                 
E2A8  C8       INY                     
E2A9  B1 00    LDA ($00),Y             
E2AB  85 FC    STA $FC                 
E2AD  C8       INY                     
E2AE  B1 00    LDA ($00),Y             
E2B0  8D 6D 01 STA $016D               
E2B3  C8       INY                     
E2B4  B1 00    LDA ($00),Y             
E2B6  8D 6E 01 STA $016E               
E2B9  4C C7 EC JMP sub_ECC7            

; ==== data $E2BC..$E2C9  (14 bytes) ====
E2BC  11 80 13 80 15 80 17 80 19 80 1B 80 1D 80        |..............

loc_E2CA:  ; 0 xrefs: 
E2CA  A9 00    LDA #$00                
E2CC  A2 80    LDX #$80                

loc_E2CE:  ; 1 xrefs: E2D2
E2CE  9D 00 06 STA $0600,X             
E2D1  E8       INX                     
E2D2  D0 FA    BNE loc_E2CE            
E2D4  60       RTS                     

loc_E2D5:  ; 0 xrefs: 
E2D5  9D 58 04 STA $0458,X             

loc_E2D8:  ; 0 xrefs: 
E2D8  48       PHA                     
E2D9  A0 36    LDY #$36                
E2DB  20 A7 EC JSR sub_ECA7            
E2DE  AD 2D 80 LDA $802D               
E2E1  85 12    STA $12                 
E2E3  AD 2E 80 LDA $802E               
E2E6  85 13    STA $13                 
E2E8  68       PLA                     
E2E9  0A       ASL A                   
E2EA  A8       TAY                     
E2EB  B1 12    LDA ($12),Y             
E2ED  85 10    STA $10                 
E2EF  C8       INY                     
E2F0  B1 12    LDA ($12),Y             
E2F2  85 11    STA $11                 
E2F4  A0 01    LDY #$01                
E2F6  B1 10    LDA ($10),Y             
E2F8  9D A2 05 STA $05A2,X             
E2FB  C8       INY                     
E2FC  B1 10    LDA ($10),Y             
E2FE  9D 42 04 STA $0442,X             
E301  A9 00    LDA #$00                
E303  9D 6E 04 STA $046E,X             
E306  4C C7 EC JMP sub_ECC7            

loc_E309:  ; 0 xrefs: 
E309  DE A2 05 DEC $05A2,X             
E30C  F0 0A    BEQ loc_E318            
E30E  60       RTS                     

sub_E30F:  ; 1 xrefs: FA05
E30F  DE A2 05 DEC $05A2,X             
E312  F0 01    BEQ loc_E315            
E314  60       RTS                     

loc_E315:  ; 1 xrefs: E312
E315  BD 58 04 LDA $0458,X             

loc_E318:  ; 1 xrefs: E30C
E318  48       PHA                     
E319  A0 36    LDY #$36                
E31B  20 A7 EC JSR sub_ECA7            
E31E  AD 2D 80 LDA $802D               
E321  85 12    STA $12                 
E323  AD 2E 80 LDA $802E               
E326  85 13    STA $13                 
E328  68       PLA                     
E329  0A       ASL A                   
E32A  A8       TAY                     
E32B  B1 12    LDA ($12),Y             
E32D  85 10    STA $10                 
E32F  C8       INY                     
E330  B1 12    LDA ($12),Y             
E332  85 11    STA $11                 
E334  A0 01    LDY #$01                
E336  B1 10    LDA ($10),Y             
E338  9D A2 05 STA $05A2,X             
E33B  A0 00    LDY #$00                
E33D  B1 10    LDA ($10),Y             
E33F  30 21    BMI loc_E362            
E341  DD 6E 04 CMP $046E,X             
E344  F0 06    BEQ loc_E34C            
E346  FE 6E 04 INC $046E,X             
E349  4C 51 E3 JMP loc_E351            

loc_E34C:  ; 1 xrefs: E344
E34C  A9 00    LDA #$00                
E34E  9D 6E 04 STA $046E,X             

loc_E351:  ; 1 xrefs: E349
E351  A0 02    LDY #$02                
E353  B1 10    LDA ($10),Y             
E355  18       CLC                     
E356  7D 6E 04 ADC $046E,X             
E359  9D 42 04 STA $0442,X             
E35C  48       PHA                     
E35D  20 C7 EC JSR sub_ECC7            
E360  68       PLA                     
E361  60       RTS                     

loc_E362:  ; 1 xrefs: E33F
E362  29 7F    AND #$7F                
E364  DD 6E 04 CMP $046E,X             
E367  F0 06    BEQ loc_E36F            
E369  FE 6E 04 INC $046E,X             
E36C  4C 74 E3 JMP loc_E374            

loc_E36F:  ; 1 xrefs: E367
E36F  A9 00    LDA #$00                
E371  9D 6E 04 STA $046E,X             

loc_E374:  ; 1 xrefs: E36C
E374  A0 03    LDY #$03                
E376  B1 10    LDA ($10),Y             
E378  0A       ASL A                   
E379  A8       TAY                     
E37A  B9 9C E3 LDA $E39C,Y             
E37D  85 12    STA $12                 
E37F  B9 9D E3 LDA $E39D,Y             
E382  85 13    STA $13                 
E384  BD 6E 04 LDA $046E,X             
E387  A8       TAY                     
E388  B1 12    LDA ($12),Y             
E38A  85 12    STA $12                 
E38C  A0 02    LDY #$02                
E38E  B1 10    LDA ($10),Y             
E390  18       CLC                     
E391  65 12    ADC $12                 
E393  9D 42 04 STA $0442,X             
E396  48       PHA                     
E397  20 C7 EC JSR sub_ECC7            
E39A  68       PLA                     
E39B  60       RTS                     

; ==== data $E39C..$E3B4  (25 bytes) ====
E39C  A4 E3 A8 E3 AC E3 B3 E3 00 01 00 02 00 01 02 01  |................
E3AC  00 01 02 03 03 02 01 00 02                       |.........

loc_E3B5:  ; 0 xrefs: 
E3B5  A0 36    LDY #$36                
E3B7  20 A7 EC JSR sub_ECA7            
E3BA  A9 06    LDA #$06                
E3BC  A4 79    LDY $79                 
E3BE  D0 02    BNE loc_E3C2            
E3C0  A5 53    LDA $53                 

loc_E3C2:  ; 1 xrefs: E3BE
E3C2  0A       ASL A                   
E3C3  A8       TAY                     
E3C4  B9 15 E5 LDA $E515,Y             
E3C7  85 0A    STA $0A                 
E3C9  B9 16 E5 LDA $E516,Y             
E3CC  85 0B    STA $0B                 
E3CE  A0 00    LDY #$00                
E3D0  B1 0A    LDA ($0A),Y             
E3D2  85 08    STA $08                 
E3D4  C8       INY                     
E3D5  B1 0A    LDA ($0A),Y             
E3D7  85 09    STA $09                 
E3D9  A5 9C    LDA $9C                 
E3DB  0A       ASL A                   
E3DC  A8       TAY                     
E3DD  B1 08    LDA ($08),Y             
E3DF  85 68    STA $68                 
E3E1  C8       INY                     
E3E2  B1 08    LDA ($08),Y             
E3E4  85 69    STA $69                 
E3E6  A9 00    LDA #$00                
E3E8  85 3B    STA $3B                 
E3EA  8D 71 01 STA $0171               
E3ED  20 B4 DF JSR $DFB4               
E3F0  4C C7 EC JMP sub_ECC7            

loc_E3F3:  ; 0 xrefs: 
E3F3  A5 97    LDA $97                 
E3F5  F0 2B    BEQ loc_E422            
E3F7  A5 A3    LDA $A3                 
E3F9  29 F0    AND #$F0                
E3FB  F0 25    BEQ loc_E422            
E3FD  4A       LSR A                   
E3FE  4A       LSR A                   
E3FF  4A       LSR A                   
E400  4A       LSR A                   
E401  85 00    STA $00                 
E403  A5 A3    LDA $A3                 
E405  38       SEC                     
E406  E5 00    SBC $00                 
E408  85 08    STA $08                 
E40A  A5 66    LDA $66                 
E40C  0A       ASL A                   
E40D  0A       ASL A                   
E40E  0A       ASL A                   
E40F  0A       ASL A                   
E410  85 00    STA $00                 
E412  A5 67    LDA $67                 
E414  38       SEC                     
E415  E5 00    SBC $00                 
E417  85 09    STA $09                 
E419  A5 66    LDA $66                 
E41B  E9 00    SBC #$00                
E41D  85 0A    STA $0A                 
E41F  4C 2E E4 JMP loc_E42E            

loc_E422:  ; 2 xrefs: E3F5 E3FB
E422  A5 66    LDA $66                 
E424  85 0A    STA $0A                 
E426  A5 67    LDA $67                 
E428  85 09    STA $09                 
E42A  A5 A3    LDA $A3                 
E42C  85 08    STA $08                 

loc_E42E:  ; 1 xrefs: E41F
E42E  A0 36    LDY #$36                
E430  20 A7 EC JSR sub_ECA7            
E433  A5 94    LDA $94                 
E435  D0 07    BNE loc_E43E            
E437  A5 8A    LDA $8A                 
E439  D0 03    BNE loc_E43E            
E43B  4C C7 EC JMP sub_ECC7            

loc_E43E:  ; 2 xrefs: E435 E439
E43E  A2 00    LDX #$00                
E440  A0 FC    LDY #$FC                

loc_E442:  ; 1 xrefs: E44F
E442  C8       INY                     
E443  C8       INY                     
E444  C8       INY                     
E445  C8       INY                     
E446  E8       INX                     

loc_E447:  ; 1 xrefs: E50A
E447  B1 68    LDA ($68),Y             
E449  C9 FF    CMP #$FF                
E44B  F0 2A    BEQ loc_E477            
E44D  C5 08    CMP $08                 
E44F  90 F1    BCC loc_E442            
E451  A9 00    LDA #$00                
E453  85 00    STA $00                 
E455  B1 68    LDA ($68),Y             
E457  C9 FF    CMP #$FF                
E459  F0 1C    BEQ loc_E477            
E45B  0A       ASL A                   
E45C  26 00    ROL $00                 
E45E  0A       ASL A                   
E45F  26 00    ROL $00                 
E461  0A       ASL A                   
E462  26 00    ROL $00                 
E464  0A       ASL A                   
E465  26 00    ROL $00                 
E467  38       SEC                     
E468  E5 09    SBC $09                 
E46A  85 01    STA $01                 
E46C  A5 00    LDA $00                 
E46E  E5 0A    SBC $0A                 
E470  F0 0C    BEQ loc_E47E            
E472  10 03    BPL loc_E477            
E474  4C 05 E5 JMP loc_E505            

loc_E477:  ; 3 xrefs: E44B E459 E472
E477  A9 00    LDA #$00                
E479  85 8A    STA $8A                 
E47B  4C C7 EC JMP sub_ECC7            

loc_E47E:  ; 1 xrefs: E470
E47E  A5 94    LDA $94                 
E480  30 08    BMI loc_E48A            
E482  A5 01    LDA $01                 
E484  C9 F8    CMP #$F8                
E486  B0 0F    BCS loc_E497            
E488  90 06    BCC loc_E490            

loc_E48A:  ; 1 xrefs: E480
E48A  A5 01    LDA $01                 
E48C  C9 08    CMP #$08                
E48E  90 07    BCC loc_E497            

loc_E490:  ; 1 xrefs: E488
E490  A5 8A    LDA $8A                 
E492  D0 03    BNE loc_E497            
E494  4C 05 E5 JMP loc_E505            

loc_E497:  ; 3 xrefs: E486 E48E E492
E497  86 02    STX $02                 
E499  A2 0E    LDX #$0E                
E49B  A9 80    LDA #$80                
E49D  85 00    STA $00                 

loc_E49F:  ; 1 xrefs: E4B4
E49F  BD 00 04 LDA $0400,X             
E4A2  D0 03    BNE loc_E4A7            
E4A4  4C 0D E5 JMP loc_E50D            

loc_E4A7:  ; 1 xrefs: E4A2
E4A7  BD 84 04 LDA $0484,X             
E4AA  C5 02    CMP $02                 
E4AC  D0 03    BNE loc_E4B1            
E4AE  4C 03 E5 JMP loc_E503            

loc_E4B1:  ; 2 xrefs: E4AC E50F
E4B1  E8       INX                     
E4B2  E0 16    CPX #$16                
E4B4  D0 E9    BNE loc_E49F            
E4B6  A6 00    LDX $00                 
E4B8  10 03    BPL loc_E4BD            
E4BA  4C 03 E5 JMP loc_E503            

loc_E4BD:  ; 1 xrefs: E4B8
E4BD  20 23 E5 JSR sub_E523            
E4C0  B0 41    BCS loc_E503            
E4C2  20 59 E5 JSR sub_E559            
E4C5  B0 3C    BCS loc_E503            
E4C7  20 D4 D6 JSR $D6D4               
E4CA  C8       INY                     
E4CB  B1 68    LDA ($68),Y             
E4CD  9D 00 04 STA $0400,X             
E4D0  C8       INY                     
E4D1  B1 68    LDA ($68),Y             
E4D3  85 03    STA $03                 
E4D5  C8       INY                     
E4D6  B1 68    LDA ($68),Y             
E4D8  9D 9A 04 STA $049A,X             
E4DB  A5 97    LDA $97                 
E4DD  D0 0C    BNE loc_E4EB            
E4DF  A5 03    LDA $03                 
E4E1  85 04    STA $04                 
E4E3  A5 01    LDA $01                 
E4E5  85 03    STA $03                 
E4E7  A5 04    LDA $04                 
E4E9  85 01    STA $01                 

loc_E4EB:  ; 1 xrefs: E4DD
E4EB  A5 03    LDA $03                 
E4ED  9D 08 05 STA $0508,X             
E4F0  A5 01    LDA $01                 
E4F2  9D C6 04 STA $04C6,X             
E4F5  A9 08    LDA #$08                
E4F7  9D 16 04 STA $0416,X             
E4FA  A5 02    LDA $02                 
E4FC  9D 84 04 STA $0484,X             
E4FF  AA       TAX                     
E500  4C 08 E5 JMP loc_E508            

loc_E503:  ; 4 xrefs: E4AE E4BA E4C0 E4C5
E503  A6 02    LDX $02                 

loc_E505:  ; 2 xrefs: E474 E494
E505  C8       INY                     
E506  C8       INY                     
E507  C8       INY                     

loc_E508:  ; 1 xrefs: E500
E508  C8       INY                     
E509  E8       INX                     
E50A  4C 47 E4 JMP loc_E447            

loc_E50D:  ; 1 xrefs: E4A4
E50D  86 00    STX $00                 
E50F  4C B1 E4 JMP loc_E4B1            

; ==== data $E512..$E522  (17 bytes) ====
E512  4C C7 EC 03 80 05 80 07 80 09 80 0B 80 0D 80 0F  |L...............
E522  80                                               |.

sub_E523:  ; 1 xrefs: E4BD
E523  84 26    STY $26                 
E525  C8       INY                     
E526  B1 68    LDA ($68),Y             
E528  C9 02    CMP #$02                
E52A  D0 29    BNE loc_E555            
E52C  C8       INY                     
E52D  C8       INY                     
E52E  B1 68    LDA ($68),Y             
E530  4A       LSR A                   
E531  4A       LSR A                   
E532  4A       LSR A                   
E533  4A       LSR A                   
E534  29 0F    AND #$0F                
E536  85 24    STA $24                 
E538  B1 68    LDA ($68),Y             
E53A  4A       LSR A                   
E53B  B0 0B    BCS loc_E548            
E53D  A4 24    LDY $24                 
E53F  B9 B1 E5 LDA $E5B1,Y             
E542  25 2B    AND $2B                 
E544  F0 0F    BEQ loc_E555            
E546  D0 09    BNE loc_E551            

loc_E548:  ; 1 xrefs: E53B
E548  A4 24    LDY $24                 
E54A  B9 B1 E5 LDA $E5B1,Y             
E54D  25 2C    AND $2C                 
E54F  F0 04    BEQ loc_E555            

loc_E551:  ; 2 xrefs: E546 E579
E551  A4 26    LDY $26                 
E553  38       SEC                     
E554  60       RTS                     

loc_E555:  ; 6 xrefs: E52A E544 E54F E56C E571 E57E
E555  A4 26    LDY $26                 
E557  18       CLC                     
E558  60       RTS                     

sub_E559:  ; 1 xrefs: E4C2
E559  84 26    STY $26                 
E55B  C8       INY                     
E55C  B1 68    LDA ($68),Y             
E55E  C9 24    CMP #$24                
E560  F0 0C    BEQ loc_E56E            
E562  C9 3E    CMP #$3E                
E564  F0 08    BEQ loc_E56E            
E566  C9 40    CMP #$40                
E568  F0 04    BEQ loc_E56E            
E56A  C9 3A    CMP #$3A                
E56C  D0 E7    BNE loc_E555            

loc_E56E:  ; 3 xrefs: E560 E564 E568
E56E  AC 71 01 LDY $0171               
E571  F0 E2    BEQ loc_E555            
E573  88       DEY                     

loc_E574:  ; 1 xrefs: E57C
E574  B9 72 01 LDA $0172,Y             
E577  C5 02    CMP $02                 
E579  F0 D6    BEQ loc_E551            
E57B  88       DEY                     
E57C  10 F6    BPL loc_E574            
E57E  30 D5    BMI loc_E555            

loc_E580:  ; 0 xrefs: 
E580  86 25    STX $25                 
E582  84 26    STY $26                 
E584  BD 9A 04 LDA $049A,X             
E587  4A       LSR A                   
E588  4A       LSR A                   
E589  4A       LSR A                   
E58A  4A       LSR A                   
E58B  29 0F    AND #$0F                
E58D  85 24    STA $24                 
E58F  BD 9A 04 LDA $049A,X             
E592  4A       LSR A                   
E593  B0 0E    BCS loc_E5A3            
E595  A4 24    LDY $24                 
E597  B9 B1 E5 LDA $E5B1,Y             
E59A  45 2B    EOR $2B                 
E59C  85 2B    STA $2B                 
E59E  A4 26    LDY $26                 
E5A0  A6 25    LDX $25                 
E5A2  60       RTS                     

loc_E5A3:  ; 1 xrefs: E593
E5A3  A4 24    LDY $24                 
E5A5  B9 B1 E5 LDA $E5B1,Y             
E5A8  45 2C    EOR $2C                 
E5AA  85 2C    STA $2C                 
E5AC  A4 26    LDY $26                 
E5AE  A6 25    LDX $25                 
E5B0  60       RTS                     

; ==== data $E5B1..$E5B8  (8 bytes) ====
E5B1  01 02 04 08 10 20 40 80                          |..... @.

loc_E5B9:  ; 0 xrefs: 
E5B9  78       SEI                     
E5BA  D8       CLD                     
E5BB  A9 00    LDA #$00                
E5BD  8D 00 E0 STA $E000               
E5C0  8D 00 C0 STA $C000               
E5C3  8D 01 20 STA $2001               
E5C6  8D 00 20 STA $2000               
E5C9  A2 02    LDX #$02                

loc_E5CB:  ; 2 xrefs: E5CE E5D6
E5CB  2C 02 20 BIT $2002               
E5CE  10 FB    BPL loc_E5CB            

loc_E5D0:  ; 1 xrefs: E5D3
E5D0  2C 02 20 BIT $2002               
E5D3  30 FB    BMI loc_E5D0            
E5D5  CA       DEX                     
E5D6  D0 F3    BNE loc_E5CB            
E5D8  CA       DEX                     
E5D9  9A       TXS                     
E5DA  A9 0F    LDA #$0F                
E5DC  8D 15 40 STA $4015               
E5DF  A0 00    LDY #$00                
E5E1  8C 10 40 STY $4010               
E5E4  A9 40    LDA #$40                
E5E6  8D 17 40 STA $4017               
E5E9  8C 00 80 STY $8000               
E5EC  8C 05 20 STY $2005               
E5EF  8C 05 20 STY $2005               
E5F2  8C 01 A0 STY $A001               
E5F5  8C 00 E0 STY $E000               
E5F8  AD 02 20 LDA $2002               
E5FB  A9 10    LDA #$10                
E5FD  AA       TAX                     

loc_E5FE:  ; 1 xrefs: E607
E5FE  8D 06 20 STA $2006               
E601  8D 06 20 STA $2006               
E604  49 10    EOR #$10                
E606  CA       DEX                     
E607  D0 F5    BNE loc_E5FE            
E609  A9 00    LDA #$00                
E60B  8D 00 A0 STA $A000               
E60E  8D 01 A0 STA $A001               
E611  A2 00    LDX #$00                

loc_E613:  ; 1 xrefs: E62B
E613  95 00    STA $00,X               
E615  9D 00 01 STA $0100,X             
E618  9D 00 02 STA $0200,X             
E61B  9D 00 03 STA $0300,X             
E61E  9D 00 04 STA $0400,X             
E621  9D 00 05 STA $0500,X             
E624  9D 00 06 STA $0600,X             
E627  9D 00 07 STA $0700,X             
E62A  E8       INX                     
E62B  D0 E6    BNE loc_E613            
E62D  20 86 EB JSR sub_EB86            
E630  20 0C EC JSR sub_EC0C            
E633  58       CLI                     

loc_E634:  ; 1 xrefs: E63D
E634  E6 23    INC $23                 
E636  A5 23    LDA $23                 
E638  18       CLC                     
E639  65 1C    ADC $1C                 
E63B  85 23    STA $23                 
E63D  4C 34 E6 JMP loc_E634            

loc_E640:  ; 0 xrefs: 
E640  48       PHA                     
E641  8A       TXA                     
E642  48       PHA                     
E643  98       TYA                     
E644  48       PHA                     
E645  8D 00 E0 STA $E000               
E648  8D 01 E0 STA $E001               
E64B  A5 2D    LDA $2D                 
E64D  0A       ASL A                   
E64E  A8       TAY                     
E64F  B1 31    LDA ($31),Y             
E651  85 33    STA $33                 
E653  C8       INY                     
E654  B1 31    LDA ($31),Y             
E656  85 34    STA $34                 
E658  6C 33 00 JMP ($0033)             

; ==== data $E65B..$E6A0  (70 bytes) ====
E65B  77 E6 77 E6 79 E6 7B E6 7D E6 83 E6 8B E6 93 E6  |w.w.y.{.}.......
E66B  83 E6 8B E6 97 E6 83 E6 9D E6 9F E6 0D E7 BC E6  |................
E67B  A1 E6 AC E7 DA E7 0D E7 C2 E8 01 E9 2F E9 0D E7  |............/...
E68B  16 E8 45 E8 72 E8 0D E7 99 E8 0D E7 75 E9 95 E9  |..E.r.......u...
E69B  0D E7 E3 E6 5F E7                                |...._.

loc_E6A1:  ; 0 xrefs: 
E6A1  8D 00 E0 STA $E000               
E6A4  A0 1E    LDY #$1E                

loc_E6A6:  ; 1 xrefs: E6A7
E6A6  88       DEY                     
E6A7  D0 FD    BNE loc_E6A6            
E6A9  AD 02 20 LDA $2002               
E6AC  A5 81    LDA $81                 
E6AE  8D 05 20 STA $2005               
E6B1  8C 05 20 STY $2005               
E6B4  A5 83    LDA $83                 
E6B6  8D 00 20 STA $2000               
E6B9  4C B4 E9 JMP loc_E9B4            

; ==== data $E6BC..$E6E2  (39 bytes) ====
E6BC  8D 00 E0 A0 00 AD 02 20 8C 05 20 8C 05 20 A9 A8  |....... .. .. ..
E6CC  8D 00 20 8C 00 80 A9 1C 8D 01 80 C8 8C 00 80 A9  |.. .............
E6DC  1E 8D 01 80 4C B4 E9                             |....L..

loc_E6E3:  ; 0 xrefs: 
E6E3  8D 00 E0 STA $E000               
E6E6  A0 1E    LDY #$1E                

loc_E6E8:  ; 1 xrefs: E6E9
E6E8  88       DEY                     
E6E9  D0 FD    BNE loc_E6E8            
E6EB  AD 02 20 LDA $2002               
E6EE  8C 05 20 STY $2005               
E6F1  8C 05 20 STY $2005               
E6F4  A9 A8    LDA #$A8                
E6F6  8D 00 20 STA $2000               
E6F9  8C 00 80 STY $8000               
E6FC  A9 34    LDA #$34                
E6FE  8D 01 80 STA $8001               
E701  C8       INY                     
E702  8C 00 80 STY $8000               
E705  A9 36    LDA #$36                
E707  8D 01 80 STA $8001               
E70A  4C B4 E9 JMP loc_E9B4            

; ==== data $E70D..$E9B3  (679 bytes) ====
E70D  8D 00 E0 A0 1E 88 D0 FD AD 02 20 A9 26 A2 80 8D  |.......... .&...
E71D  06 20 8E 06 20 8C 05 20 8C 05 20 A9 A9 8D 00 20  |. .. .. .. .... 
E72D  8C 00 80 A9 1C 8D 01 80 C8 8C 00 80 A9 1E 8D 01  |................
E73D  80 C8 8C 00 80 A9 64 8D 01 80 C8 8C 00 80 8D 01  |......d.........
E74D  80 C8 8C 00 80 8D 01 80 C8 8C 00 80 8D 01 80 4C  |...............L
E75D  B4 E9 8D 00 E0 A0 1E 88 D0 FD AD 02 20 A9 22 A2  |............ .".
E76D  80 8D 06 20 8E 06 20 8C 05 20 8C 05 20 8C 00 80  |... .. .. .. ...
E77D  A9 1C 8D 01 80 C8 8C 00 80 A9 1E 8D 01 80 C8 8C  |................
E78D  00 80 A9 64 8D 01 80 C8 8C 00 80 8D 01 80 C8 8C  |...d............
E79D  00 80 8D 01 80 C8 8C 00 80 8D 01 80 4C B4 E9 A5  |............L...
E7AD  A9 8D 00 C0 A0 0F 88 D0 FD AD 02 20 A5 81 8D 05  |........... ....
E7BD  20 8C 05 20 A5 83 8D 00 20 8C 00 80 A9 64 8D 01  | .. .... ....d..
E7CD  80 C8 8C 00 80 8D 01 80 E6 2D 4C B4 E9 A5 AA 8D  |.........-L.....
E7DD  00 C0 A0 0F 88 D0 FD AD 02 20 A9 25 A2 C0 8D 06  |......... .%....
E7ED  20 8E 06 20 A5 81 8D 05 20 8C 05 20 A5 83 8D 00  | .. .... .. ....
E7FD  20 8C 00 80 A5 42 0A 8D 01 80 C8 8C 00 80 A5 43  | ....B.........C
E80D  0A 8D 01 80 E6 2D 4C B4 E9 A5 A9 8D 00 C0 A0 1E  |.....-L.........
E81D  88 D0 FD AD 02 20 A9 26 8D 06 20 8C 06 20 A5 FD  |..... .&.. .. ..
E82D  8D 05 20 8C 05 20 A5 FF 8D 00 20 E6 2D A5 AA D0  |.. .. .... .-...
E83D  04 E6 2D E6 2D 4C B4 E9 A5 AA 8D 00 C0 A0 07 88  |..-.-L..........
E84D  D0 FD AD 02 20 A9 22 A2 80 8D 06 20 8E 06 20 8C  |.... .".... .. .
E85D  05 20 8C 05 20 A9 A8 8D 00 20 E6 2D A5 AB D0 02  |. .. .... .-....
E86D  E6 2D 4C B4 E9 A5 AB 8D 00 C0 A0 07 88 D0 FD AD  |.-L.............
E87D  02 20 A9 22 A2 80 8D 06 20 8E 06 20 8C 05 20 8C  |. .".... .. .. .
E88D  05 20 A9 A8 8D 00 20 E6 2D 4C B4 E9 A9 1F 8D 00  |. .... .-L......
E89D  C0 A0 02 8C 00 80 A9 64 8D 01 80 C8 8C 00 80 8D  |.......d........
E8AD  01 80 C8 8C 00 80 8D 01 80 C8 8C 00 80 8D 01 80  |................
E8BD  E6 2D 4C B4 E9 A4 A9 8C 00 C0 A0 1E 88 D0 FD AD  |.-L.............
E8CD  02 20 A9 24 8D 06 20 8C 06 20 8C 05 20 8C 05 20  |. .$.. .. .. .. 
E8DD  A0 02 8C 00 80 A9 64 8D 01 80 C8 8C 00 80 8D 01  |......d.........
E8ED  80 C8 8C 00 80 8D 01 80 C8 8C 00 80 8D 01 80 E6  |................
E8FD  2D 4C B4 E9 A4 AA C8 8C 00 C0 A0 00 8C 00 80 A9  |-L..............
E90D  64 8D 01 80 C8 8C 00 80 8D 01 80 A0 05 88 D0 FD  |d...............
E91D  AD 02 20 A5 65 A6 64 8D 06 20 8E 06 20 E6 2D 4C  |.. .e.d.. .. .-L
E92D  B4 E9 A4 AB 8C 00 C0 A0 0F 88 D0 FD 8C 00 80 A5  |................
E93D  42 0A 8D 01 80 C8 8C 00 80 A5 43 0A 8D 01 80 C8  |B.........C.....
E94D  8C 00 80 A5 44 8D 01 80 C8 8C 00 80 A5 45 8D 01  |....D........E..
E95D  80 C8 8C 00 80 A5 46 8D 01 80 C8 8C 00 80 A5 47  |......F........G
E96D  8D 01 80 E6 2D 4C B4 E9 A5 A9 8D 00 C0 A0 1E 88  |....-L..........
E97D  D0 FD AD 02 20 A9 24 8D 06 20 8C 06 20 8C 05 20  |.... .$.. .. .. 
E98D  8C 05 20 E6 2D 4C B4 E9 A5 AA 8D 00 C0 A0 1E 88  |.. .-L..........
E99D  D0 FD AD 02 20 A2 40 A9 22 8D 06 20 8E 06 20 8C  |.... .@.".. .. .
E9AD  05 20 8C 05 20 E6 2D                             |. .. .-

loc_E9B4:  ; 2 xrefs: E6B9 E70A
E9B4  A4 A4    LDY $A4                 
E9B6  A5 1D    LDA $1D                 
E9B8  29 02    AND #$02                
E9BA  F0 02    BEQ loc_E9BE            
E9BC  A4 A1    LDY $A1                 

loc_E9BE:  ; 1 xrefs: E9BA
E9BE  8C 00 80 STY $8000               
E9C1  68       PLA                     
E9C2  A8       TAY                     
E9C3  68       PLA                     
E9C4  AA       TAX                     
E9C5  68       PLA                     
E9C6  40       RTI                     

loc_E9C7:  ; 0 xrefs: 
E9C7  08       PHP                     
E9C8  48       PHA                     
E9C9  8A       TXA                     
E9CA  48       PHA                     
E9CB  98       TYA                     
E9CC  48       PHA                     
E9CD  AD 02 20 LDA $2002               
E9D0  58       CLI                     
E9D1  A4 1D    LDY $1D                 
E9D3  D0 74    BNE loc_EA49            
E9D5  A5 1D    LDA $1D                 
E9D7  09 01    ORA #$01                
E9D9  85 1D    STA $1D                 
E9DB  A5 FF    LDA $FF                 
E9DD  29 7F    AND #$7F                
E9DF  85 FF    STA $FF                 
E9E1  8D 00 20 STA $2000               
E9E4  8C 06 20 STY $2006               
E9E7  8C 06 20 STY $2006               
E9EA  A5 FE    LDA $FE                 
E9EC  29 E7    AND #$E7                
E9EE  8D 01 20 STA $2001               
E9F1  8C 03 20 STY $2003               
E9F4  A9 02    LDA #$02                
E9F6  8D 14 40 STA $4014               
E9F9  20 41 CC JSR $CC41               
E9FC  A5 FE    LDA $FE                 
E9FE  A6 1E    LDX $1E                 
EA00  F0 04    BEQ loc_EA06            
EA02  C6 1E    DEC $1E                 
EA04  29 E7    AND #$E7                

loc_EA06:  ; 1 xrefs: EA00
EA06  8D 01 20 STA $2001               
EA09  20 A5 EA JSR sub_EAA5            
EA0C  20 4E EB JSR sub_EB4E            
EA0F  A5 18    LDA $18                 
EA11  C9 04    CMP #$04                
EA13  F0 04    BEQ loc_EA19            
EA15  C9 06    CMP #$06                
EA17  D0 03    BNE loc_EA1C            

loc_EA19:  ; 1 xrefs: EA13
EA19  20 03 EF JSR sub_EF03            

loc_EA1C:  ; 1 xrefs: EA17
EA1C  20 11 EC JSR sub_EC11            
EA1F  20 B0 EB JSR sub_EBB0            
EA22  A0 3C    LDY #$3C                
EA24  20 A7 EC JSR sub_ECA7            
EA27  20 03 80 JSR $8003               
EA2A  A0 30    LDY #$30                
EA2C  20 A7 EC JSR sub_ECA7            
EA2F  20 15 80 JSR $8015               
EA32  20 62 ED JSR sub_ED62            
EA35  A0 36    LDY #$36                
EA37  20 A7 EC JSR sub_ECA7            
EA3A  20 00 80 JSR $8000               
EA3D  20 14 CD JSR $CD14               
EA40  85 1D    STA $1D                 

loc_EA42:  ; 1 xrefs: EAA2
EA42  68       PLA                     
EA43  A8       TAY                     
EA44  68       PLA                     
EA45  AA       TAX                     
EA46  68       PLA                     
EA47  28       PLP                     
EA48  40       RTI                     

loc_EA49:  ; 1 xrefs: E9D3
EA49  A5 1D    LDA $1D                 
EA4B  09 02    ORA #$02                
EA4D  85 1D    STA $1D                 
EA4F  A5 FE    LDA $FE                 
EA51  A6 1E    LDX $1E                 
EA53  F0 02    BEQ loc_EA57            
EA55  29 E7    AND #$E7                

loc_EA57:  ; 1 xrefs: EA53
EA57  8D 01 20 STA $2001               
EA5A  20 A5 EA JSR sub_EAA5            
EA5D  20 4E EB JSR sub_EB4E            
EA60  20 5C EC JSR sub_EC5C            
EA63  A5 1D    LDA $1D                 
EA65  30 36    BMI loc_EA9D            
EA67  A5 3F    LDA $3F                 
EA69  48       PHA                     
EA6A  A0 0C    LDY #$0C                
EA6C  A9 06    LDA #$06                
EA6E  85 A1    STA $A1                 
EA70  8D 00 80 STA $8000               
EA73  8C 01 80 STY $8001               
EA76  A9 07    LDA #$07                
EA78  85 A1    STA $A1                 
EA7A  8D 00 80 STA $8000               
EA7D  C8       INY                     
EA7E  8C 01 80 STY $8001               
EA81  20 03 80 JSR $8003               
EA84  68       PLA                     
EA85  29 0F    AND #$0F                
EA87  A8       TAY                     
EA88  A9 06    LDA #$06                
EA8A  85 A1    STA $A1                 
EA8C  8D 00 80 STA $8000               
EA8F  8C 01 80 STY $8001               
EA92  A9 07    LDA #$07                
EA94  85 A1    STA $A1                 
EA96  8D 00 80 STA $8000               
EA99  C8       INY                     
EA9A  8C 01 80 STY $8001               

loc_EA9D:  ; 1 xrefs: EA65
EA9D  A4 A4    LDY $A4                 
EA9F  8C 00 80 STY $8000               
EAA2  4C 42 EA JMP loc_EA42            

sub_EAA5:  ; 2 xrefs: EA09 EA5A
EAA5  AD 02 20 LDA $2002               
EAA8  A0 00    LDY #$00                
EAAA  8C 05 20 STY $2005               
EAAD  8C 05 20 STY $2005               
EAB0  AD 02 20 LDA $2002               
EAB3  A2 FF    LDX #$FF                
EAB5  8E 00 C0 STX $C000               
EAB8  8E 01 C0 STX $C001               
EABB  8C 06 20 STY $2006               
EABE  8C 06 20 STY $2006               
EAC1  8C 06 20 STY $2006               
EAC4  A6 87    LDX $87                 
EAC6  F0 52    BEQ loc_EB1A            
EAC8  CA       DEX                     
EAC9  F0 49    BEQ loc_EB14            
EACB  CA       DEX                     
EACC  F0 42    BEQ loc_EB10            
EACE  CA       DEX                     
EACF  F0 33    BEQ loc_EB04            
EAD1  CA       DEX                     
EAD2  F0 23    BEQ loc_EAF7            
EAD4  CA       DEX                     
EAD5  F0 28    BEQ loc_EAFF            
EAD7  CA       DEX                     
EAD8  F0 25    BEQ loc_EAFF            
EADA  CA       DEX                     
EADB  F0 15    BEQ loc_EAF2            
EADD  CA       DEX                     
EADE  F0 1F    BEQ loc_EAFF            
EAE0  CA       DEX                     
EAE1  F0 1C    BEQ loc_EAFF            
EAE3  CA       DEX                     
EAE4  F0 19    BEQ loc_EAFF            
EAE6  CA       DEX                     
EAE7  F0 16    BEQ loc_EAFF            
EAE9  CA       DEX                     
EAEA  F0 02    BEQ loc_EAEE            
EAEC  D0 26    BNE loc_EB14            

loc_EAEE:  ; 1 xrefs: EAEA
EAEE  A9 6C    LDA #$6C                
EAF0  D0 02    BNE loc_EAF4            

loc_EAF2:  ; 1 xrefs: EADB
EAF2  A9 8F    LDA #$8F                

loc_EAF4:  ; 1 xrefs: EAF0
EAF4  4C 18 EB JMP loc_EB18            

loc_EAF7:  ; 1 xrefs: EAD2
EAF7  A5 FF    LDA $FF                 
EAF9  85 83    STA $83                 
EAFB  A5 FD    LDA $FD                 
EAFD  85 81    STA $81                 

loc_EAFF:  ; 6 xrefs: EAD5 EAD8 EADE EAE1 EAE4 EAE7
EAFF  A5 29    LDA $29                 
EB01  4C 18 EB JMP loc_EB18            

loc_EB04:  ; 1 xrefs: EACF
EB04  A5 88    LDA $88                 
EB06  85 81    STA $81                 
EB08  A5 89    LDA $89                 
EB0A  85 83    STA $83                 
EB0C  A9 80    LDA #$80                
EB0E  D0 08    BNE loc_EB18            

loc_EB10:  ; 1 xrefs: EACC
EB10  A9 87    LDA #$87                
EB12  D0 04    BNE loc_EB18            

loc_EB14:  ; 2 xrefs: EAC9 EAEC
EB14  A9 AF    LDA #$AF                
EB16  D0 00    BNE loc_EB18            

loc_EB18:  ; 5 xrefs: EAF4 EB01 EB0E EB12 EB16
EB18  A2 01    LDX #$01                

loc_EB1A:  ; 1 xrefs: EAC6
EB1A  8D 00 C0 STA $C000               
EB1D  8D 01 C0 STA $C001               
EB20  9D 00 E0 STA $E000,X             
EB23  A9 00    LDA #$00                
EB25  85 2D    STA $2D                 
EB27  A5 87    LDA $87                 
EB29  0A       ASL A                   
EB2A  A8       TAY                     
EB2B  B9 5B E6 LDA $E65B,Y             
EB2E  85 31    STA $31                 
EB30  B9 5C E6 LDA $E65C,Y             
EB33  85 32    STA $32                 
EB35  A5 A5    LDA $A5                 
EB37  85 A9    STA $A9                 
EB39  A5 A6    LDA $A6                 
EB3B  85 AA    STA $AA                 
EB3D  A5 A7    LDA $A7                 
EB3F  85 AB    STA $AB                 
EB41  A5 A8    LDA $A8                 
EB43  85 AC    STA $AC                 
EB45  A5 62    LDA $62                 
EB47  85 64    STA $64                 
EB49  A5 63    LDA $63                 
EB4B  85 65    STA $65                 
EB4D  60       RTS                     

sub_EB4E:  ; 2 xrefs: EA0C EA5D
EB4E  AD 02 20 LDA $2002               
EB51  A9 20    LDA #$20                
EB53  8D 06 20 STA $2006               
EB56  A9 00    LDA #$00                
EB58  8D 06 20 STA $2006               
EB5B  AD 02 20 LDA $2002               
EB5E  A5 FD    LDA $FD                 
EB60  8D 05 20 STA $2005               
EB63  A5 FC    LDA $FC                 
EB65  8D 05 20 STA $2005               
EB68  A5 FF    LDA $FF                 
EB6A  09 80    ORA #$80                
EB6C  85 FF    STA $FF                 
EB6E  8D 00 20 STA $2000               
EB71  60       RTS                     

loc_EB72:  ; 0 xrefs: 
EB72  A5 FF    LDA $FF                 
EB74  09 80    ORA #$80                
EB76  85 FF    STA $FF                 
EB78  8D 00 20 STA $2000               
EB7B  60       RTS                     

; ==== data $EB7C..$EB85  (10 bytes) ====
EB7C  A5 FF 29 7F 85 FF 8D 00 20 60                    |..)..... `

sub_EB86:  ; 1 xrefs: E62D
EB86  A9 A8    LDA #$A8                
EB88  8D 00 20 STA $2000               
EB8B  85 FF    STA $FF                 
EB8D  A9 1C    LDA #$1C                
EB8F  85 FE    STA $FE                 
EB91  A9 05    LDA #$05                
EB93  85 1E    STA $1E                 
EB95  60       RTS                     

loc_EB96:  ; 0 xrefs: 
EB96  A5 FF    LDA $FF                 
EB98  29 7F    AND #$7F                
EB9A  8D 00 20 STA $2000               
EB9D  AD 02 20 LDA $2002               
EBA0  A9 00    LDA #$00                
EBA2  8D 06 20 STA $2006               
EBA5  8D 06 20 STA $2006               
EBA8  A5 FE    LDA $FE                 
EBAA  29 E7    AND #$E7                
EBAC  8D 01 20 STA $2001               
EBAF  60       RTS                     

sub_EBB0:  ; 1 xrefs: EA1F
EBB0  A2 00    LDX #$00                
EBB2  20 E7 EB JSR sub_EBE7            
EBB5  A2 02    LDX #$02                
EBB7  20 E7 EB JSR sub_EBE7            
EBBA  A5 00    LDA $00                 
EBBC  C5 02    CMP $02                 
EBBE  D0 1C    BNE loc_EBDC            
EBC0  A5 01    LDA $01                 
EBC2  C5 03    CMP $03                 
EBC4  D0 16    BNE loc_EBDC            
EBC6  A2 00    LDX #$00                
EBC8  20 CC EB JSR sub_EBCC            
EBCB  E8       INX                     

sub_EBCC:  ; 1 xrefs: EBC8
EBCC  B5 00    LDA $00,X               
EBCE  A8       TAY                     
EBCF  55 F7    EOR $F7,X               
EBD1  35 00    AND $00,X               
EBD3  95 48    STA $48,X               
EBD5  95 F5    STA $F5,X               
EBD7  94 4A    STY $4A,X               
EBD9  94 F7    STY $F7,X               
EBDB  60       RTS                     

loc_EBDC:  ; 2 xrefs: EBBE EBC4
EBDC  A9 00    LDA #$00                
EBDE  85 48    STA $48                 
EBE0  85 F5    STA $F5                 
EBE2  85 49    STA $49                 
EBE4  85 F6    STA $F6                 
EBE6  60       RTS                     

sub_EBE7:  ; 2 xrefs: EBB2 EBB7
EBE7  A0 01    LDY #$01                
EBE9  8C 16 40 STY $4016               
EBEC  88       DEY                     
EBED  8C 16 40 STY $4016               
EBF0  A0 08    LDY #$08                

loc_EBF2:  ; 1 xrefs: EC09
EBF2  AD 16 40 LDA $4016               
EBF5  85 04    STA $04                 
EBF7  4A       LSR A                   
EBF8  05 04    ORA $04                 
EBFA  4A       LSR A                   
EBFB  36 00    ROL $00,X               
EBFD  AD 17 40 LDA $4017               
EC00  85 05    STA $05                 
EC02  4A       LSR A                   
EC03  05 05    ORA $05                 
EC05  4A       LSR A                   
EC06  36 01    ROL $01,X               
EC08  88       DEY                     
EC09  D0 E7    BNE loc_EBF2            
EC0B  60       RTS                     

sub_EC0C:  ; 4 xrefs: E630 EE01 EE09 EE49
EC0C  A9 00    LDA #$00                
EC0E  4C E8 EC JMP sub_ECE8            

sub_EC11:  ; 1 xrefs: EA1C
EC11  A0 00    LDY #$00                
EC13  84 A4    STY $A4                 
EC15  8C 00 80 STY $8000               
EC18  A5 42    LDA $42                 
EC1A  0A       ASL A                   
EC1B  8D 01 80 STA $8001               
EC1E  C8       INY                     
EC1F  84 A4    STY $A4                 
EC21  8C 00 80 STY $8000               
EC24  A5 43    LDA $43                 
EC26  0A       ASL A                   
EC27  8D 01 80 STA $8001               
EC2A  C8       INY                     
EC2B  84 A4    STY $A4                 
EC2D  8C 00 80 STY $8000               
EC30  A5 44    LDA $44                 
EC32  8D 01 80 STA $8001               
EC35  C8       INY                     
EC36  84 A4    STY $A4                 
EC38  8C 00 80 STY $8000               
EC3B  A5 45    LDA $45                 
EC3D  8D 01 80 STA $8001               
EC40  C8       INY                     
EC41  84 A4    STY $A4                 
EC43  8C 00 80 STY $8000               
EC46  A5 46    LDA $46                 
EC48  8D 01 80 STA $8001               
EC4B  C8       INY                     
EC4C  84 A4    STY $A4                 
EC4E  8C 00 80 STY $8000               
EC51  A5 47    LDA $47                 
EC53  8D 01 80 STA $8001               
EC56  A9 00    LDA #$00                
EC58  8D 00 A0 STA $A000               
EC5B  60       RTS                     

sub_EC5C:  ; 1 xrefs: EA60
EC5C  A0 00    LDY #$00                
EC5E  84 A1    STY $A1                 
EC60  8C 00 80 STY $8000               
EC63  A5 42    LDA $42                 
EC65  0A       ASL A                   
EC66  8D 01 80 STA $8001               
EC69  C8       INY                     
EC6A  84 A1    STY $A1                 
EC6C  8C 00 80 STY $8000               
EC6F  A5 43    LDA $43                 
EC71  0A       ASL A                   
EC72  8D 01 80 STA $8001               
EC75  C8       INY                     
EC76  84 A1    STY $A1                 
EC78  8C 00 80 STY $8000               
EC7B  A5 44    LDA $44                 
EC7D  8D 01 80 STA $8001               
EC80  C8       INY                     
EC81  84 A1    STY $A1                 
EC83  8C 00 80 STY $8000               
EC86  A5 45    LDA $45                 
EC88  8D 01 80 STA $8001               
EC8B  C8       INY                     
EC8C  84 A1    STY $A1                 
EC8E  8C 00 80 STY $8000               
EC91  A5 46    LDA $46                 
EC93  8D 01 80 STA $8001               
EC96  C8       INY                     
EC97  84 A1    STY $A1                 
EC99  8C 00 80 STY $8000               
EC9C  A5 47    LDA $47                 
EC9E  8D 01 80 STA $8001               
ECA1  A9 00    LDA #$00                
ECA3  8D 00 A0 STA $A000               
ECA6  60       RTS                     

sub_ECA7:  ; 22 xrefs: E241 E2DB E31B E3B7 E430 EA24 EA2C EA37 ED05 ED13 ...
ECA7  A5 3F    LDA $3F                 
ECA9  85 40    STA $40                 

sub_ECAB:  ; 3 xrefs: ECC9 ECD5 ECE1
ECAB  98       TYA                     
ECAC  29 0F    AND #$0F                
ECAE  A8       TAY                     
ECAF  84 3F    STY $3F                 
ECB1  A9 06    LDA #$06                
ECB3  85 A4    STA $A4                 
ECB5  8D 00 80 STA $8000               
ECB8  8C 01 80 STY $8001               
ECBB  A9 07    LDA #$07                
ECBD  85 A4    STA $A4                 
ECBF  8D 00 80 STA $8000               
ECC2  C8       INY                     
ECC3  8C 01 80 STY $8001               
ECC6  60       RTS                     

sub_ECC7:  ; 16 xrefs: E2B9 E306 E35D E397 E3F0 E43B E47B ED0E ED19 ED2A ...
ECC7  A4 40    LDY $40                 
ECC9  4C AB EC JMP sub_ECAB            

sub_ECCC:  ; 1 xrefs: ECF0
ECCC  48       PHA                     
ECCD  98       TYA                     
ECCE  48       PHA                     
ECCF  A5 3F    LDA $3F                 
ECD1  85 41    STA $41                 
ECD3  A0 3C    LDY #$3C                
ECD5  20 AB EC JSR sub_ECAB            
ECD8  68       PLA                     
ECD9  A8       TAY                     
ECDA  68       PLA                     
ECDB  60       RTS                     

sub_ECDC:  ; 1 xrefs: ECF6
ECDC  48       PHA                     
ECDD  98       TYA                     
ECDE  48       PHA                     
ECDF  A4 41    LDY $41                 
ECE1  20 AB EC JSR sub_ECAB            
ECE4  68       PLA                     
ECE5  A8       TAY                     
ECE6  68       PLA                     
ECE7  60       RTS                     

sub_ECE8:  ; 5 xrefs: EC0E EDE0 EE06 EFF0 F015
ECE8  48       PHA                     
ECE9  A5 1D    LDA $1D                 
ECEB  09 80    ORA #$80                
ECED  85 1D    STA $1D                 
ECEF  68       PLA                     
ECF0  20 CC EC JSR sub_ECCC            
ECF3  20 00 80 JSR $8000               
ECF6  20 DC EC JSR sub_ECDC            
ECF9  A5 1D    LDA $1D                 
ECFB  29 7F    AND #$7F                
ECFD  85 1D    STA $1D                 
ECFF  60       RTS                     

sub_ED00:  ; 1 xrefs: ED9D
ED00  48       PHA                     
ED01  98       TYA                     
ED02  48       PHA                     
ED03  A0 30    LDY #$30                
ED05  20 A7 EC JSR sub_ECA7            
ED08  68       PLA                     
ED09  A8       TAY                     
ED0A  68       PLA                     
ED0B  20 00 80 JSR $8000               
ED0E  4C C7 EC JMP sub_ECC7            

loc_ED11:  ; 0 xrefs: 
ED11  A0 30    LDY #$30                
ED13  20 A7 EC JSR sub_ECA7            
ED16  20 03 80 JSR $8003               
ED19  4C C7 EC JMP sub_ECC7            

loc_ED1C:  ; 0 xrefs: 
ED1C  85 24    STA $24                 
ED1E  98       TYA                     
ED1F  48       PHA                     
ED20  A0 30    LDY #$30                
ED22  20 A7 EC JSR sub_ECA7            
ED25  A5 24    LDA $24                 
ED27  20 1B 80 JSR $801B               
ED2A  20 C7 EC JSR sub_ECC7            
ED2D  68       PLA                     
ED2E  A8       TAY                     
ED2F  60       RTS                     

loc_ED30:  ; 0 xrefs: 
ED30  85 24    STA $24                 
ED32  86 25    STX $25                 
ED34  98       TYA                     
ED35  48       PHA                     
ED36  A0 30    LDY #$30                
ED38  20 A7 EC JSR sub_ECA7            
ED3B  A5 24    LDA $24                 
ED3D  A6 25    LDX $25                 
ED3F  20 1E 80 JSR $801E               
ED42  20 C7 EC JSR sub_ECC7            
ED45  68       PLA                     
ED46  A8       TAY                     
ED47  60       RTS                     

loc_ED48:  ; 0 xrefs: 
ED48  48       PHA                     
ED49  A0 30    LDY #$30                
ED4B  20 A7 EC JSR sub_ECA7            
ED4E  68       PLA                     
ED4F  20 21 80 JSR $8021               
ED52  4C C7 EC JMP sub_ECC7            

loc_ED55:  ; 0 xrefs: 
ED55  48       PHA                     
ED56  A0 30    LDY #$30                
ED58  20 A7 EC JSR sub_ECA7            
ED5B  68       PLA                     
ED5C  20 12 80 JSR $8012               
ED5F  4C C7 EC JMP sub_ECC7            

sub_ED62:  ; 1 xrefs: EA32
ED62  E6 1C    INC $1C                 
ED64  A5 18    LDA $18                 
ED66  20 0B CA JSR $CA0B               

; ==== JUMP TABLE $ED69 (9 entries) ====
;   [ 0] -> $ED7B
;   [ 1] -> $EE31
;   [ 2] -> $EE51
;   [ 3] -> $EE57
;   [ 4] -> $EE5D
;   [ 5] -> $EE98
;   [ 6] -> $EE9E
;   [ 7] -> $EEA4
;   [ 8] -> $EEAA
; ==== data $ED69..$ED7A  (18 bytes) ====
ED69  7B ED 31 EE 51 EE 57 EE 5D EE 98 EE 9E EE A4 EE  |{.1.Q.W.].......
ED79  AA EE                                            |..

loc_ED7B:  ; 1 xrefs: ED69
ED7B  A6 19    LDX $19                 
ED7D  D0 34    BNE loc_EDB3            
ED7F  20 E1 C9 JSR $C9E1               
ED82  20 E5 C9 JSR $C9E5               
ED85  A0 26    LDY #$26                
ED87  84 42    STY $42                 
ED89  C8       INY                     
ED8A  84 43    STY $43                 
ED8C  A0 00    LDY #$00                
ED8E  84 44    STY $44                 
ED90  C8       INY                     
ED91  84 45    STY $45                 
ED93  A0 10    LDY #$10                
ED95  84 46    STY $46                 
ED97  84 47    STY $47                 
ED99  A9 00    LDA #$00                
ED9B  85 22    STA $22                 
ED9D  20 00 ED JSR sub_ED00            
EDA0  20 2B CB JSR $CB2B               
EDA3  A9 80    LDA #$80                
EDA5  A0 00    LDY #$00                
EDA7  20 D4 EE JSR sub_EED4            
EDAA  20 D9 EE JSR sub_EED9            
EDAD  4C B7 EE JMP sub_EEB7            

loc_EDB0:  ; 1 xrefs: EDC8
EDB0  4C B0 EE JMP loc_EEB0            

loc_EDB3:  ; 1 xrefs: ED7D
EDB3  CA       DEX                     
EDB4  D0 0C    BNE loc_EDC2            
EDB6  20 BF EE JSR sub_EEBF            
EDB9  F0 01    BEQ loc_EDBC            
EDBB  60       RTS                     

loc_EDBC:  ; 1 xrefs: EDB9
EDBC  20 B7 EE JSR sub_EEB7            
EDBF  4C D0 EE JMP sub_EED0            

loc_EDC2:  ; 1 xrefs: EDB4
EDC2  CA       DEX                     
EDC3  D0 4D    BNE loc_EE12            
EDC5  20 BF EE JSR sub_EEBF            
EDC8  F0 E6    BEQ loc_EDB0            
EDCA  A5 48    LDA $48                 
EDCC  29 20    AND #$20                
EDCE  F0 13    BEQ loc_EDE3            
EDD0  E6 22    INC $22                 
EDD2  A5 22    LDA $22                 
EDD4  29 01    AND #$01                
EDD6  85 22    STA $22                 
EDD8  20 D9 EE JSR sub_EED9            
EDDB  20 D0 EE JSR sub_EED0            
EDDE  A9 39    LDA #$39                
EDE0  20 E8 EC JSR sub_ECE8            

loc_EDE3:  ; 1 xrefs: EDCE
EDE3  A5 48    LDA $48                 
EDE5  29 10    AND #$10                
EDE7  F0 28    BEQ loc_EE11            
EDE9  A5 4B    LDA $4B                 
EDEB  29 80    AND #$80                
EDED  F0 0C    BEQ loc_EDFB            
EDEF  A5 4B    LDA $4B                 
EDF1  29 40    AND #$40                
EDF3  F0 06    BEQ loc_EDFB            
EDF5  A5 4B    LDA $4B                 
EDF7  29 02    AND #$02                
EDF9  D0 0E    BNE loc_EE09            

loc_EDFB:  ; 2 xrefs: EDED EDF3
EDFB  A9 80    LDA #$80                
EDFD  85 52    STA $52                 
EDFF  E6 19    INC $19                 
EE01  20 0C EC JSR sub_EC0C            
EE04  A9 29    LDA #$29                
EE06  4C E8 EC JMP sub_ECE8            

loc_EE09:  ; 1 xrefs: EDF9
EE09  20 0C EC JSR sub_EC0C            
EE0C  A9 08    LDA #$08                
EE0E  20 BA EE JSR sub_EEBA            

loc_EE11:  ; 2 xrefs: EDE7 EE21
EE11  60       RTS                     

loc_EE12:  ; 1 xrefs: EDC3
EE12  A5 52    LDA $52                 
EE14  29 08    AND #$08                
EE16  0A       ASL A                   
EE17  0A       ASL A                   
EE18  0A       ASL A                   
EE19  0A       ASL A                   
EE1A  65 22    ADC $22                 
EE1C  20 BC CC JSR $CCBC               
EE1F  C6 52    DEC $52                 
EE21  D0 EE    BNE loc_EE11            
EE23  20 EF EE JSR sub_EEEF            
EE26  A9 03    LDA #$03                
EE28  A4 22    LDY $22                 
EE2A  F0 02    BEQ loc_EE2E            
EE2C  A9 02    LDA #$02                

loc_EE2E:  ; 1 xrefs: EE2A
EE2E  4C BA EE JMP sub_EEBA            

loc_EE31:  ; 1 xrefs: ED69
EE31  A5 48    LDA $48                 
EE33  29 30    AND #$30                
EE35  D0 08    BNE loc_EE3F            
EE37  A0 30    LDY #$30                
EE39  20 A7 EC JSR sub_ECA7            
EE3C  4C 2A 80 JMP $802A               

loc_EE3F:  ; 1 xrefs: EE35
EE3F  A9 00    LDA #$00                
EE41  85 90    STA $90                 
EE43  85 51    STA $51                 
EE45  85 4F    STA $4F                 
EE47  85 50    STA $50                 
EE49  20 0C EC JSR sub_EC0C            
EE4C  A9 00    LDA #$00                
EE4E  4C BA EE JMP sub_EEBA            

loc_EE51:  ; 1 xrefs: ED69
EE51  20 FB EE JSR sub_EEFB            
EE54  4C 18 80 JMP $8018               

loc_EE57:  ; 1 xrefs: ED69
EE57  20 FB EE JSR sub_EEFB            
EE5A  4C 09 80 JMP $8009               

loc_EE5D:  ; 1 xrefs: ED69
EE5D  A5 48    LDA $48                 
EE5F  29 20    AND #$20                
EE61  D0 03    BNE loc_EE66            

loc_EE63:  ; 5 xrefs: EE68 EE6E EE73 EE79 EE7D
EE63  4C B8 CD JMP $CDB8               

loc_EE66:  ; 1 xrefs: EE61
EE66  A5 4E    LDA $4E                 
EE68  D0 F9    BNE loc_EE63            
EE6A  A5 27    LDA $27                 
EE6C  C9 03    CMP #$03                
EE6E  D0 F3    BNE loc_EE63            
EE70  AD 9A 04 LDA $049A               
EE73  F0 EE    BEQ loc_EE63            
EE75  A5 96    LDA $96                 
EE77  05 95    ORA $95                 
EE79  F0 E8    BEQ loc_EE63            
EE7B  A5 4D    LDA $4D                 
EE7D  D0 E4    BNE loc_EE63            
EE7F  A5 9D    LDA $9D                 
EE81  F0 14    BEQ loc_EE97            
EE83  AD 9A 04 LDA $049A               
EE86  C9 10    CMP #$10                
EE88  F0 0D    BEQ loc_EE97            
EE8A  C6 9D    DEC $9D                 
EE8C  A9 10    LDA #$10                
EE8E  85 2F    STA $2F                 
EE90  A9 05    LDA #$05                
EE92  85 27    STA $27                 
EE94  20 A7 D4 JSR $D4A7               

loc_EE97:  ; 2 xrefs: EE81 EE88
EE97  60       RTS                     

loc_EE98:  ; 1 xrefs: ED69
EE98  20 FB EE JSR sub_EEFB            
EE9B  4C 24 80 JMP $8024               

loc_EE9E:  ; 1 xrefs: ED69
EE9E  20 FB EE JSR sub_EEFB            
EEA1  4C 2D 80 JMP $802D               

loc_EEA4:  ; 1 xrefs: ED69
EEA4  20 FB EE JSR sub_EEFB            
EEA7  4C 27 80 JMP $8027               

loc_EEAA:  ; 1 xrefs: ED69
EEAA  20 FB EE JSR sub_EEFB            
EEAD  4C 0C 80 JMP $800C               

loc_EEB0:  ; 1 xrefs: EDB0
EEB0  E6 18    INC $18                 

loc_EEB2:  ; 1 xrefs: EEBC
EEB2  A9 00    LDA #$00                
EEB4  85 19    STA $19                 
EEB6  60       RTS                     

sub_EEB7:  ; 2 xrefs: EDAD EDBC
EEB7  E6 19    INC $19                 
EEB9  60       RTS                     

sub_EEBA:  ; 3 xrefs: EE0E EE2E EE4E
EEBA  85 18    STA $18                 
EEBC  4C B2 EE JMP loc_EEB2            

sub_EEBF:  ; 2 xrefs: EDB6 EDC5
EEBF  A5 52    LDA $52                 
EEC1  05 53    ORA $53                 
EEC3  F0 0A    BEQ loc_EECF            
EEC5  A5 52    LDA $52                 
EEC7  D0 02    BNE loc_EECB            
EEC9  C6 53    DEC $53                 

loc_EECB:  ; 1 xrefs: EEC7
EECB  C6 52    DEC $52                 
EECD  A9 01    LDA #$01                

loc_EECF:  ; 1 xrefs: EEC3
EECF  60       RTS                     

sub_EED0:  ; 2 xrefs: EDBF EDDB
EED0  A9 00    LDA #$00                
EED2  A0 01    LDY #$01                

sub_EED4:  ; 1 xrefs: EDA7
EED4  85 52    STA $52                 
EED6  84 53    STY $53                 
EED8  60       RTS                     

sub_EED9:  ; 2 xrefs: EDAA EDD8
EED9  A5 22    LDA $22                 
EEDB  A8       TAY                     
EEDC  B9 ED EE LDA $EEED,Y             
EEDF  8D C6 04 STA $04C6               
EEE2  A9 80    LDA #$80                
EEE4  8D 08 05 STA $0508               
EEE7  A9 5A    LDA #$5A                
EEE9  8D 42 04 STA $0442               
EEEC  60       RTS                     

; ==== data $EEED..$EEEE  (2 bytes) ====
EEED  7A 82                                            |z.

sub_EEEF:  ; 1 xrefs: EE23
EEEF  A9 00    LDA #$00                
EEF1  8D C6 04 STA $04C6               
EEF4  8D 08 05 STA $0508               
EEF7  8D 42 04 STA $0442               
EEFA  60       RTS                     

sub_EEFB:  ; 6 xrefs: EE51 EE57 EE98 EE9E EEA4 EEAA
EEFB  A0 30    LDY #$30                
EEFD  4C A7 EC JMP sub_ECA7            

loc_EF00:  ; 0 xrefs: 
EF00  4C 7D EF JMP loc_EF7D            

sub_EF03:  ; 1 xrefs: EA19
EF03  AC 42 04 LDY $0442               
EF06  B9 3F EF LDA $EF3F,Y             
EF09  C0 1F    CPY #$1F                
EF0B  B0 07    BCS loc_EF14            
EF0D  A4 9A    LDY $9A                 
EF0F  F0 03    BEQ loc_EF14            
EF11  18       CLC                     
EF12  69 06    ADC #$06                

loc_EF14:  ; 2 xrefs: EF0B EF0F
EF14  85 44    STA $44                 
EF16  A0 01    LDY #$01                
EF18  A5 9A    LDA $9A                 
EF1A  F0 0E    BEQ loc_EF2A            
EF1C  AD 8C 05 LDA $058C               
EF1F  C9 0C    CMP #$0C                
EF21  D0 0F    BNE loc_EF32            
EF23  AD 16 04 LDA $0416               
EF26  30 0A    BMI loc_EF32            
EF28  F0 07    BEQ loc_EF31            

loc_EF2A:  ; 1 xrefs: EF1A
EF2A  AD 16 04 LDA $0416               
EF2D  29 60    AND #$60                
EF2F  D0 01    BNE loc_EF32            

loc_EF31:  ; 1 xrefs: EF28
EF31  88       DEY                     

loc_EF32:  ; 3 xrefs: EF21 EF26 EF2F
EF32  84 00    STY $00                 
EF34  AD 2C 04 LDA $042C               
EF37  29 FC    AND #$FC                
EF39  05 00    ORA $00                 
EF3B  8D 2C 04 STA $042C               
EF3E  60       RTS                     

; ==== data $EF3F..$EF7C  (62 bytes) ====
EF3F  00 00 00 00 05 01 01 01 01 02 02 02 02 02 03 03  |................
EF4F  03 03 03 04 04 04 04 04 05 05 05 05 05 05 05 06  |................
EF5F  06 06 06 07 07 0C 0C 0C 0D 0D 0D 0D 0E 0E 0E 0E  |................
EF6F  0E 0E 0D 0D 00 0C 0F 0F 0F 0F 0F 01 10 10        |..............

loc_EF7D:  ; 1 xrefs: EF00
EF7D  A5 27    LDA $27                 
EF7F  20 0B CA JSR $CA0B               

; ==== JUMP TABLE $EF82 (8 entries) ====
;   [ 0] -> $EF92
;   [ 1] -> $EF9A
;   [ 2] -> $EFA0
;   [ 3] -> $EFD7
;   [ 4] -> $EFE0
;   [ 5] -> $EFE1
;   [ 6] -> $F007
;   [ 7] -> $F02B
; ==== data $EF82..$EF91  (16 bytes) ====
EF82  92 EF 9A EF A0 EF D7 EF E0 EF E1 EF 07 F0 2B F0  |..............+.

loc_EF92:  ; 1 xrefs: EF82
EF92  20 4C F0 JSR sub_F04C            
EF95  E6 27    INC $27                 
EF97  E6 27    INC $27                 
EF99  60       RTS                     

loc_EF9A:  ; 1 xrefs: EF82
EF9A  20 F3 F0 JSR sub_F0F3            
EF9D  E6 27    INC $27                 
EF9F  60       RTS                     

loc_EFA0:  ; 1 xrefs: EF82
EFA0  20 1C E1 JSR sub_E11C            
EFA3  A5 02    LDA $02                 
EFA5  85 35    STA $35                 
EFA7  A5 03    LDA $03                 
EFA9  85 36    STA $36                 
EFAB  A5 08    LDA $08                 
EFAD  85 37    STA $37                 
EFAF  A5 09    LDA $09                 
EFB1  85 38    STA $38                 
EFB3  A9 06    LDA #$06                
EFB5  A4 79    LDY $79                 
EFB7  D0 02    BNE loc_EFBB            
EFB9  A5 53    LDA $53                 

loc_EFBB:  ; 1 xrefs: EFB7
EFBB  0A       ASL A                   
EFBC  A8       TAY                     
EFBD  B9 3F DE LDA $DE3F,Y             
EFC0  85 10    STA $10                 
EFC2  B9 40 DE LDA $DE40,Y             
EFC5  85 11    STA $11                 
EFC7  A0 00    LDY #$00                
EFC9  B1 10    LDA ($10),Y             
EFCB  85 39    STA $39                 
EFCD  C8       INY                     
EFCE  B1 10    LDA ($10),Y             
EFD0  85 3A    STA $3A                 
EFD2  E6 27    INC $27                 
EFD4  4C F1 D8 JMP $D8F1               

loc_EFD7:  ; 1 xrefs: EF82
EFD7  A0 38    LDY #$38                
EFD9  20 A7 EC JSR sub_ECA7            
EFDC  4C 00 80 JMP $8000               

; ==== data $EFDF..$EFDF  (1 bytes) ====
EFDF  60                                               |`

loc_EFE0:  ; 1 xrefs: EF82
EFE0  60       RTS                     

loc_EFE1:  ; 1 xrefs: EF82
EFE1  A5 1C    LDA $1C                 
EFE3  29 03    AND #$03                
EFE5  D0 16    BNE loc_EFFD            
EFE7  AD 9A 04 LDA $049A               
EFEA  C9 10    CMP #$10                
EFEC  F0 10    BEQ loc_EFFE            
EFEE  A9 1B    LDA #$1B                
EFF0  20 E8 EC JSR sub_ECE8            
EFF3  EE 9A 04 INC $049A               
EFF6  20 ED D4 JSR $D4ED               
EFF9  C6 2F    DEC $2F                 
EFFB  F0 01    BEQ loc_EFFE            

loc_EFFD:  ; 1 xrefs: EFE5
EFFD  60       RTS                     

loc_EFFE:  ; 2 xrefs: EFEC EFFB
EFFE  A9 03    LDA #$03                
F000  85 27    STA $27                 
F002  A9 00    LDA #$00                
F004  85 2F    STA $2F                 
F006  60       RTS                     

loc_F007:  ; 1 xrefs: EF82
F007  A5 1C    LDA $1C                 
F009  29 03    AND #$03                
F00B  D0 14    BNE loc_F021            
F00D  A5 A0    LDA $A0                 
F00F  C9 10    CMP #$10                
F011  F0 0F    BEQ loc_F022            
F013  A9 1B    LDA #$1B                
F015  20 E8 EC JSR sub_ECE8            
F018  E6 A0    INC $A0                 
F01A  20 D9 D4 JSR $D4D9               
F01D  C6 30    DEC $30                 
F01F  F0 01    BEQ loc_F022            

loc_F021:  ; 1 xrefs: F00B
F021  60       RTS                     

loc_F022:  ; 2 xrefs: F011 F01F
F022  A9 03    LDA #$03                
F024  85 27    STA $27                 
F026  A9 00    LDA #$00                
F028  85 30    STA $30                 
F02A  60       RTS                     

loc_F02B:  ; 1 xrefs: EF82
F02B  A5 CD    LDA $CD                 
F02D  F0 01    BEQ loc_F030            
F02F  60       RTS                     

loc_F030:  ; 1 xrefs: F02D
F030  AD E5 05 LDA $05E5               
F033  85 46    STA $46                 
F035  A9 00    LDA #$00                
F037  8D 43 04 STA $0443               
F03A  8D 09 05 STA $0509               
F03D  8D C7 04 STA $04C7               
F040  8D E5 05 STA $05E5               
F043  85 4D    STA $4D                 
F045  A9 03    LDA #$03                
F047  85 27    STA $27                 
F049  4C AC D6 JMP $D6AC               

sub_F04C:  ; 1 xrefs: EF92
F04C  A9 06    LDA #$06                
F04E  A4 79    LDY $79                 
F050  D0 02    BNE loc_F054            
F052  A5 53    LDA $53                 

loc_F054:  ; 1 xrefs: F050
F054  0A       ASL A                   
F055  A8       TAY                     
F056  B9 A4 F0 LDA $F0A4,Y             
F059  85 00    STA $00                 
F05B  B9 A5 F0 LDA $F0A5,Y             
F05E  85 01    STA $01                 
F060  A4 9C    LDY $9C                 
F062  B1 00    LDA ($00),Y             
F064  85 02    STA $02                 
F066  29 F0    AND #$F0                
F068  09 0F    ORA #$0F                
F06A  8D C6 04 STA $04C6               
F06D  A5 53    LDA $53                 
F06F  C9 04    CMP #$04                
F071  D0 0E    BNE loc_F081            
F073  A5 9C    LDA $9C                 
F075  C9 03    CMP #$03                
F077  D0 08    BNE loc_F081            
F079  A5 AD    LDA $AD                 
F07B  F0 04    BEQ loc_F081            
F07D  A9 09    LDA #$09                
F07F  D0 02    BNE loc_F083            

loc_F081:  ; 3 xrefs: F071 F077 F07B
F081  A5 02    LDA $02                 

loc_F083:  ; 1 xrefs: F07F
F083  0A       ASL A                   
F084  0A       ASL A                   
F085  0A       ASL A                   
F086  0A       ASL A                   
F087  29 F0    AND #$F0                
F089  8D 08 05 STA $0508               
F08C  C9 80    CMP #$80                
F08E  F0 0B    BEQ loc_F09B            
F090  90 09    BCC loc_F09B            
F092  AD 2C 04 LDA $042C               
F095  09 40    ORA #$40                
F097  8D 2C 04 STA $042C               
F09A  60       RTS                     

loc_F09B:  ; 2 xrefs: F08E F090
F09B  AD 2C 04 LDA $042C               
F09E  29 BF    AND #$BF                
F0A0  8D 2C 04 STA $042C               
F0A3  60       RTS                     

; ==== data $F0A4..$F0F2  (79 bytes) ====
F0A4  B2 F0 B9 F0 C1 F0 C8 F0 CF F0 D9 F0 E7 F0 8E 8E  |................
F0B4  82 82 8E 6D 82 82 72 8E 8E 5E 6E 7E 82 82 32 82  |...m..r..^n~..2.
F0C4  82 8E 8E 82 82 32 82 82 4E 3E 83 8E 8E 8E 8E 8E  |.....2..N>......
F0D4  3E 32 82 32 82 28 28 32 82 32 8E 4E 8E 4E 8E 4E  |>2.2.((2.2.N.N.N
F0E4  8E 3E 82 92 92 92 92 92 82 92 92 92 92 92 92     |.>.............

sub_F0F3:  ; 1 xrefs: EF9A
F0F3  A4 53    LDY $53                 
F0F5  B9 01 F1 LDA $F101,Y             
F0F8  8D C6 04 STA $04C6               
F0FB  A9 80    LDA #$80                
F0FD  8D 08 05 STA $0508               
F100  60       RTS                     

; ==== data $F101..$F106  (6 bytes) ====
F101  8F 8F 8F 5F 8F 00                                |..._..

loc_F107:  ; 0 xrefs: 
F107  20 0F F1 JSR sub_F10F            
F10A  A0 3A    LDY #$3A                
F10C  4C A7 EC JMP sub_ECA7            

sub_F10F:  ; 1 xrefs: F107
F10F  BC 00 04 LDY $0400,X             
F112  B9 CF F0 LDA $F0CF,Y             
F115  85 00    STA $00                 
F117  B9 D9 F0 LDA $F0D9,Y             
F11A  85 01    STA $01                 
F11C  6C 00 00 JMP ($0000)             

; ==== data $F11F..$F19F  (129 bytes) ====
F11F  3B 43 4B 53 5B 63 33 33 33 33 F1 F1 F1 F1 F1 F1  |;CKS[c3333......
F12F  F1 F1 F1 F1 A0 32 20 A7 EC 4C 18 80 A0 38 20 A7  |.....2 ..L...8 .
F13F  EC 4C 0C 8E A0 38 20 A7 EC 4C 0F 8E A0 36 20 A7  |.L...8 ..L...6 .
F14F  EC 4C 32 80 A0 36 20 A7 EC 4C 35 80 A0 30 20 A7  |.L2..6 ..L5..0 .
F15F  EC 4C 38 80 AD 77 06 F0 2E C9 01 F0 06 C9 02 F0  |.L8..w..........
F16F  0B D0 24 A9 00 8D 77 06 A9 48 D0 13 AD 19 01 29  |..$...w..H.....)
F17F  03 D0 14 A0 48 AD 19 01 29 04 D0 02 A0 83 98 A2  |....H...).......
F18F  01 20 30 ED 20 48 ED A2 0F A0 30 20 A7 EC 4C 3B  |. 0. H....0 ..L;
F19F  80                                               |.

loc_F1A0:  ; 0 xrefs: 
F1A0  85 24    STA $24                 
F1A2  84 26    STY $26                 
F1A4  A0 38    LDY #$38                
F1A6  20 A7 EC JSR sub_ECA7            
F1A9  A5 24    LDA $24                 
F1AB  A4 26    LDY $26                 
F1AD  20 B3 F1 JSR sub_F1B3            
F1B0  4C C7 EC JMP sub_ECC7            

sub_F1B3:  ; 1 xrefs: F1AD
F1B3  6C 00 00 JMP ($0000)             

loc_F1B6:  ; 0 xrefs: 
F1B6  A5 3F    LDA $3F                 
F1B8  8D 80 01 STA $0180               
F1BB  A0 38    LDY #$38                
F1BD  20 A7 EC JSR sub_ECA7            
F1C0  20 12 8E JSR $8E12               
F1C3  AC 80 01 LDY $0180               
F1C6  4C A7 EC JMP sub_ECA7            

loc_F1C9:  ; 0 xrefs: 
F1C9  86 15    STX $15                 
F1CB  BA       TSX                     
F1CC  BD 05 01 LDA $0105,X             
F1CF  85 16    STA $16                 
F1D1  BD 06 01 LDA $0106,X             
F1D4  85 17    STA $17                 
F1D6  98       TYA                     
F1D7  18       CLC                     
F1D8  65 16    ADC $16                 
F1DA  9D 05 01 STA $0105,X             
F1DD  A9 00    LDA #$00                
F1DF  65 17    ADC $17                 
F1E1  9D 06 01 STA $0106,X             

loc_F1E4:  ; 1 xrefs: F1EA
F1E4  B1 16    LDA ($16),Y             
F1E6  99 7F 01 STA $017F,Y             
F1E9  88       DEY                     
F1EA  D0 F8    BNE loc_F1E4            
F1EC  A6 15    LDX $15                 
F1EE  60       RTS                     

sub_F1EF:  ; 2 xrefs: FE79 FE99
F1EF  8A       TXA                     
F1F0  48       PHA                     
F1F1  98       TYA                     
F1F2  48       PHA                     
F1F3  A5 01    LDA $01                 
F1F5  08       PHP                     
F1F6  10 0D    BPL loc_F205            
F1F8  A9 00    LDA #$00                
F1FA  38       SEC                     
F1FB  E5 00    SBC $00                 
F1FD  85 00    STA $00                 
F1FF  A9 00    LDA #$00                
F201  E5 01    SBC $01                 
F203  85 01    STA $01                 

loc_F205:  ; 1 xrefs: F1F6
F205  A9 00    LDA #$00                
F207  85 04    STA $04                 
F209  85 05    STA $05                 
F20B  85 06    STA $06                 
F20D  85 07    STA $07                 
F20F  A0 10    LDY #$10                

loc_F211:  ; 1 xrefs: F22E
F211  06 00    ASL $00                 
F213  26 01    ROL $01                 
F215  26 06    ROL $06                 
F217  26 07    ROL $07                 
F219  38       SEC                     
F21A  A5 06    LDA $06                 
F21C  E5 02    SBC $02                 
F21E  AA       TAX                     
F21F  A5 07    LDA $07                 
F221  E5 03    SBC $03                 
F223  90 04    BCC loc_F229            
F225  85 07    STA $07                 
F227  86 06    STX $06                 

loc_F229:  ; 1 xrefs: F223
F229  26 04    ROL $04                 
F22B  26 05    ROL $05                 
F22D  88       DEY                     
F22E  D0 E1    BNE loc_F211            
F230  28       PLP                     
F231  10 0D    BPL loc_F240            
F233  A9 00    LDA #$00                
F235  38       SEC                     
F236  E5 04    SBC $04                 
F238  85 04    STA $04                 
F23A  A9 00    LDA #$00                
F23C  E5 05    SBC $05                 
F23E  85 05    STA $05                 

loc_F240:  ; 1 xrefs: F231
F240  68       PLA                     
F241  A8       TAY                     
F242  68       PLA                     
F243  AA       TAX                     
F244  60       RTS                     

loc_F245:  ; 0 xrefs: 
F245  85 0A    STA $0A                 
F247  A8       TAY                     
F248  A5 08    LDA $08                 
F24A  20 74 F2 JSR sub_F274            
F24D  A5 10    LDA $10                 
F24F  85 0B    STA $0B                 
F251  A5 11    LDA $11                 
F253  85 0C    STA $0C                 
F255  A5 0A    LDA $0A                 
F257  18       CLC                     
F258  69 40    ADC #$40                
F25A  A8       TAY                     
F25B  A5 09    LDA $09                 
F25D  20 74 F2 JSR sub_F274            
F260  A5 10    LDA $10                 
F262  18       CLC                     
F263  65 0B    ADC $0B                 
F265  85 0B    STA $0B                 
F267  A5 11    LDA $11                 
F269  18       CLC                     
F26A  65 0C    ADC $0C                 
F26C  85 0C    STA $0C                 
F26E  60       RTS                     

loc_F26F:  ; 1 xrefs: F276
F26F  85 10    STA $10                 
F271  85 11    STA $11                 
F273  60       RTS                     

sub_F274:  ; 2 xrefs: F24A F25D
F274  09 00    ORA #$00                
F276  F0 F7    BEQ loc_F26F            
F278  10 0D    BPL loc_F287            
F27A  49 FF    EOR #$FF                
F27C  18       CLC                     
F27D  69 01    ADC #$01                
F27F  85 0D    STA $0D                 
F281  98       TYA                     
F282  49 80    EOR #$80                
F284  A8       TAY                     
F285  A5 0D    LDA $0D                 

loc_F287:  ; 1 xrefs: F278
F287  85 0D    STA $0D                 
F289  84 0E    STY $0E                 
F28B  98       TYA                     
F28C  24 0E    BIT $0E                 
F28E  29 3F    AND #$3F                
F290  F0 1C    BEQ loc_F2AE            
F292  70 0D    BVS loc_F2A1            
F294  A8       TAY                     
F295  49 FF    EOR #$FF                
F297  18       CLC                     
F298  69 01    ADC #$01                
F29A  29 3F    AND #$3F                
F29C  85 0F    STA $0F                 
F29E  4C BC F2 JMP loc_F2BC            

loc_F2A1:  ; 1 xrefs: F292
F2A1  85 0F    STA $0F                 
F2A3  49 FF    EOR #$FF                
F2A5  18       CLC                     
F2A6  69 01    ADC #$01                
F2A8  29 3F    AND #$3F                
F2AA  A8       TAY                     
F2AB  4C BC F2 JMP loc_F2BC            

loc_F2AE:  ; 1 xrefs: F290
F2AE  50 07    BVC loc_F2B7            
F2B0  A0 40    LDY #$40                
F2B2  85 0F    STA $0F                 
F2B4  4C BC F2 JMP loc_F2BC            

loc_F2B7:  ; 1 xrefs: F2AE
F2B7  A8       TAY                     
F2B8  A9 40    LDA #$40                
F2BA  85 0F    STA $0F                 

loc_F2BC:  ; 3 xrefs: F29E F2AB F2B4
F2BC  20 E6 F2 JSR sub_F2E6            
F2BF  85 10    STA $10                 
F2C1  A4 0F    LDY $0F                 
F2C3  20 E6 F2 JSR sub_F2E6            
F2C6  85 11    STA $11                 
F2C8  A5 0E    LDA $0E                 
F2CA  10 0B    BPL loc_F2D7            
F2CC  A5 11    LDA $11                 
F2CE  49 FF    EOR #$FF                
F2D0  18       CLC                     
F2D1  69 01    ADC #$01                
F2D3  85 11    STA $11                 
F2D5  A5 0E    LDA $0E                 

loc_F2D7:  ; 1 xrefs: F2CA
F2D7  18       CLC                     
F2D8  69 40    ADC #$40                
F2DA  10 09    BPL loc_F2E5            
F2DC  A5 10    LDA $10                 
F2DE  49 FF    EOR #$FF                
F2E0  18       CLC                     
F2E1  69 01    ADC #$01                
F2E3  85 10    STA $10                 

loc_F2E5:  ; 1 xrefs: F2DA
F2E5  60       RTS                     

sub_F2E6:  ; 2 xrefs: F2BC F2C3
F2E6  C0 02    CPY #$02                
F2E8  90 14    BCC loc_F2FE            
F2EA  B9 01 F3 LDA $F301,Y             
F2ED  85 12    STA $12                 
F2EF  A9 00    LDA #$00                
F2F1  A0 08    LDY #$08                

loc_F2F3:  ; 1 xrefs: F2FB
F2F3  46 12    LSR $12                 
F2F5  90 02    BCC loc_F2F9            
F2F7  65 0D    ADC $0D                 

loc_F2F9:  ; 1 xrefs: F2F5
F2F9  6A       ROR A                   
F2FA  88       DEY                     
F2FB  D0 F6    BNE loc_F2F3            
F2FD  60       RTS                     

loc_F2FE:  ; 1 xrefs: F2E8
F2FE  A5 0D    LDA $0D                 
F300  60       RTS                     

; ==== data $F301..$F341  (65 bytes) ====
F301  00 00 FF FF FE FD FD FC FB F9 F8 F6 F4 F3 F1 EE  |................
F311  EC E9 E7 E4 E1 DE DB D8 D4 D1 CD C9 C5 C1 BD B9  |................
F321  B4 B0 AC A7 A2 9D 98 93 8E 88 83 7E 78 73 6D 67  |...........~xsmg
F331  62 5C 56 50 4A 44 3E 38 31 2B 25 1F 19 12 0C 06  |b\VPJD>81+%.....
F341  00                                               |.

sub_F342:  ; 5 xrefs: FB9E FBBE FBCC FC02 FC0B
F342  84 17    STY $17                 
F344  A0 00    LDY #$00                
F346  09 00    ORA #$00                
F348  10 01    BPL loc_F34B            
F34A  88       DEY                     

loc_F34B:  ; 1 xrefs: F348
F34B  18       CLC                     
F34C  7D 08 05 ADC $0508,X             
F34F  85 13    STA $13                 
F351  98       TYA                     
F352  7D F2 04 ADC $04F2,X             
F355  85 12    STA $12                 
F357  A0 00    LDY #$00                
F359  A5 17    LDA $17                 
F35B  10 01    BPL loc_F35E            
F35D  88       DEY                     

loc_F35E:  ; 1 xrefs: F35B
F35E  18       CLC                     
F35F  7D C6 04 ADC $04C6,X             
F362  85 11    STA $11                 
F364  98       TYA                     
F365  7D B0 04 ADC $04B0,X             
F368  85 10    STA $10                 
F36A  A4 97    LDY $97                 
F36C  D0 1D    BNE loc_F38B            
F36E  A8       TAY                     
F36F  F0 0E    BEQ loc_F37F            
F371  30 06    BMI loc_F379            

loc_F373:  ; 1 xrefs: F383
F373  A9 AF    LDA #$AF                
F375  85 11    STA $11                 
F377  D0 22    BNE loc_F39B            

loc_F379:  ; 2 xrefs: F371 F387
F379  A9 10    LDA #$10                
F37B  85 11    STA $11                 
F37D  D0 1C    BNE loc_F39B            

loc_F37F:  ; 1 xrefs: F36F
F37F  A5 11    LDA $11                 
F381  C9 B0    CMP #$B0                
F383  B0 EE    BCS loc_F373            
F385  C9 10    CMP #$10                
F387  90 F0    BCC loc_F379            
F389  B0 10    BCS loc_F39B            

loc_F38B:  ; 1 xrefs: F36C
F38B  A5 12    LDA $12                 
F38D  F0 0C    BEQ loc_F39B            
F38F  30 06    BMI loc_F397            
F391  A9 FF    LDA #$FF                
F393  85 13    STA $13                 
F395  D0 04    BNE loc_F39B            

loc_F397:  ; 1 xrefs: F38F
F397  A9 00    LDA #$00                
F399  85 13    STA $13                 

loc_F39B:  ; 5 xrefs: F377 F37D F389 F38D F395
F39B  A4 87    LDY $87                 
F39D  B9 AA F3 LDA $F3AA,Y             
F3A0  85 14    STA $14                 
F3A2  B9 BA F3 LDA $F3BA,Y             
F3A5  85 15    STA $15                 
F3A7  6C 14 00 JMP ($0014)             

; ==== data $F3AA..$F3FB  (82 bytes) ====
F3AA  FC FC FC FC 0D FC FC CA FC FC E3 FC FC FC FC 2C  |...............,
F3BA  F3 F3 F3 F3 F4 F3 F3 F3 F3 F3 F3 F3 F3 F3 F3 F4  |................
F3CA  A5 10 05 12 D0 09 A5 11 C9 90 90 2C A9 80 60 20  |...........,..` 
F3DA  2C F4 C9 03 F0 F6 09 00 60 A5 10 05 12 D0 43 A5  |,.......`.....C.
F3EA  11 C9 98 B0 13 C5 29 90 0F A0 9C 84 11 A5 13 4C  |......)........L
F3FA  2C F5                                            |,.

loc_F3FC:  ; 0 xrefs: 
F3FC  A5 10    LDA $10                 
F3FE  05 12    ORA $12                 
F400  D0 2A    BNE loc_F42C            
F402  A4 11    LDY $11                 
F404  C0 B0    CPY #$B0                
F406  B0 24    BCS loc_F42C            
F408  A5 13    LDA $13                 
F40A  4C 2C F5 JMP loc_F52C            

; ==== data $F40D..$F42B  (31 bytes) ====
F40D  A5 10 05 12 D0 19 A5 11 C9 80 B0 E9 C5 29 B0 0C  |.............)..
F41D  38 E5 29 18 69 80 A8 A5 13 4C 2C F5 A9 00 60     |8.).i....L,...`

loc_F42C:  ; 2 xrefs: F400 F406
F42C  86 25    STX $25                 
F42E  20 C9 DF JSR $DFC9               
F431  A5 97    LDA $97                 
F433  D0 16    BNE loc_F44B            
F435  A5 11    LDA $11                 
F437  38       SEC                     
F438  E9 10    SBC #$10                
F43A  85 11    STA $11                 
F43C  A5 67    LDA $67                 
F43E  18       CLC                     
F43F  65 13    ADC $13                 
F441  85 13    STA $13                 
F443  A5 66    LDA $66                 
F445  65 12    ADC $12                 
F447  A8       TAY                     
F448  4C 97 F4 JMP loc_F497            

loc_F44B:  ; 1 xrefs: F433
F44B  A5 67    LDA $67                 
F44D  18       CLC                     
F44E  65 11    ADC $11                 
F450  AA       TAX                     
F451  A5 66    LDA $66                 
F453  65 10    ADC $10                 
F455  24 10    BIT $10                 
F457  85 10    STA $10                 
F459  30 1E    BMI loc_F479            
F45B  38       SEC                     
F45C  E5 66    SBC $66                 
F45E  0A       ASL A                   
F45F  0A       ASL A                   
F460  0A       ASL A                   
F461  0A       ASL A                   
F462  85 14    STA $14                 
F464  8A       TXA                     
F465  18       CLC                     
F466  65 14    ADC $14                 
F468  AA       TAX                     
F469  A5 10    LDA $10                 
F46B  69 00    ADC #$00                
F46D  A8       TAY                     
F46E  8A       TXA                     
F46F  C9 F0    CMP #$F0                
F471  90 22    BCC loc_F495            
F473  29 0F    AND #$0F                
F475  C8       INY                     
F476  4C 95 F4 JMP loc_F495            

loc_F479:  ; 1 xrefs: F459
F479  A5 66    LDA $66                 
F47B  38       SEC                     
F47C  E5 10    SBC $10                 
F47E  0A       ASL A                   
F47F  0A       ASL A                   
F480  0A       ASL A                   
F481  0A       ASL A                   
F482  85 14    STA $14                 
F484  8A       TXA                     
F485  38       SEC                     
F486  E5 14    SBC $14                 
F488  AA       TAX                     
F489  A5 10    LDA $10                 
F48B  E9 00    SBC #$00                
F48D  A8       TAY                     
F48E  8A       TXA                     
F48F  C9 F0    CMP #$F0                
F491  90 02    BCC loc_F495            
F493  29 EF    AND #$EF                

loc_F495:  ; 3 xrefs: F471 F476 F491
F495  85 11    STA $11                 

loc_F497:  ; 1 xrefs: F448
F497  B1 35    LDA ($35),Y             
F499  0A       ASL A                   
F49A  A8       TAY                     
F49B  B1 37    LDA ($37),Y             
F49D  85 14    STA $14                 
F49F  C8       INY                     
F4A0  B1 37    LDA ($37),Y             
F4A2  85 15    STA $15                 
F4A4  A5 11    LDA $11                 
F4A6  4A       LSR A                   
F4A7  4A       LSR A                   
F4A8  29 38    AND #$38                
F4AA  85 16    STA $16                 
F4AC  A5 13    LDA $13                 
F4AE  4A       LSR A                   
F4AF  4A       LSR A                   
F4B0  4A       LSR A                   
F4B1  85 17    STA $17                 
F4B3  4A       LSR A                   
F4B4  4A       LSR A                   
F4B5  05 16    ORA $16                 
F4B7  A8       TAY                     
F4B8  B1 14    LDA ($14),Y             
F4BA  A8       TAY                     
F4BB  4A       LSR A                   
F4BC  4A       LSR A                   
F4BD  4A       LSR A                   
F4BE  4A       LSR A                   
F4BF  AA       TAX                     
F4C0  98       TYA                     
F4C1  29 0F    AND #$0F                
F4C3  A8       TAY                     
F4C4  B9 0C F5 LDA $F50C,Y             
F4C7  18       CLC                     
F4C8  65 39    ADC $39                 
F4CA  85 14    STA $14                 
F4CC  8A       TXA                     
F4CD  65 3A    ADC $3A                 
F4CF  85 15    STA $15                 
F4D1  A5 17    LDA $17                 
F4D3  29 03    AND #$03                
F4D5  85 16    STA $16                 
F4D7  A5 11    LDA $11                 
F4D9  4A       LSR A                   
F4DA  29 0C    AND #$0C                
F4DC  05 16    ORA $16                 
F4DE  A8       TAY                     
F4DF  B9 1C F5 LDA $F51C,Y             
F4E2  A8       TAY                     
F4E3  B1 14    LDA ($14),Y             
F4E5  85 17    STA $17                 
F4E7  20 C7 EC JSR sub_ECC7            
F4EA  A0 36    LDY #$36                
F4EC  20 A7 EC JSR sub_ECA7            
F4EF  A2 00    LDX #$00                
F4F1  A0 00    LDY #$00                
F4F3  A5 17    LDA $17                 

loc_F4F5:  ; 1 xrefs: F4FF
F4F5  D1 7B    CMP ($7B),Y             
F4F7  90 09    BCC loc_F502            
F4F9  B1 7D    LDA ($7D),Y             
F4FB  AA       TAX                     
F4FC  C8       INY                     
F4FD  A5 17    LDA $17                 
F4FF  4C F5 F4 JMP loc_F4F5            

loc_F502:  ; 1 xrefs: F4F7
F502  86 17    STX $17                 
F504  A6 25    LDX $25                 
F506  20 C7 EC JSR sub_ECC7            
F509  A5 17    LDA $17                 
F50B  60       RTS                     

; ==== data $F50C..$F52B  (32 bytes) ====
F50C  00 10 20 30 40 50 60 70 80 90 A0 B0 C0 D0 E0 F0  |.. 0@P`p........
F51C  00 00 02 02 00 00 02 02 08 08 0A 0A 08 08 0A 0A  |................

loc_F52C:  ; 1 xrefs: F40A
F52C  85 13    STA $13                 
F52E  A9 00    LDA #$00                
F530  85 10    STA $10                 
F532  98       TYA                     
F533  85 15    STA $15                 
F535  A5 97    LDA $97                 
F537  D0 04    BNE loc_F53D            
F539  A9 E0    LDA #$E0                
F53B  D0 02    BNE loc_F53F            

loc_F53D:  ; 1 xrefs: F537
F53D  A5 FC    LDA $FC                 

loc_F53F:  ; 1 xrefs: F53B
F53F  18       CLC                     
F540  65 15    ADC $15                 
F542  B0 04    BCS loc_F548            
F544  C9 F0    CMP #$F0                
F546  90 02    BCC loc_F54A            

loc_F548:  ; 1 xrefs: F542
F548  69 0F    ADC #$0F                

loc_F54A:  ; 1 xrefs: F546
F54A  85 16    STA $16                 
F54C  A5 13    LDA $13                 
F54E  18       CLC                     
F54F  65 FD    ADC $FD                 
F551  85 12    STA $12                 
F553  A5 FF    LDA $FF                 
F555  45 10    EOR $10                 
F557  29 01    AND #$01                
F559  90 02    BCC loc_F55D            
F55B  49 01    EOR #$01                

loc_F55D:  ; 1 xrefs: F559
F55D  A8       TAY                     
F55E  A5 16    LDA $16                 
F560  4A       LSR A                   
F561  4A       LSR A                   
F562  29 3C    AND #$3C                
F564  85 16    STA $16                 
F566  A5 12    LDA $12                 
F568  4A       LSR A                   
F569  4A       LSR A                   
F56A  4A       LSR A                   
F56B  4A       LSR A                   
F56C  85 12    STA $12                 
F56E  4A       LSR A                   
F56F  4A       LSR A                   
F570  05 16    ORA $16                 
F572  19 A7 F5 ORA $F5A7,Y             
F575  A8       TAY                     
F576  A5 12    LDA $12                 
F578  29 03    AND #$03                
F57A  85 12    STA $12                 
F57C  84 13    STY $13                 
F57E  A5 15    LDA $15                 
F580  C9 E0    CMP #$E0                
F582  A9 00    LDA #$00                
F584  B0 1B    BCS loc_F5A1            
F586  B9 80 06 LDA $0680,Y             
F589  A4 12    LDY $12                 
F58B  F0 08    BEQ loc_F595            
F58D  88       DEY                     
F58E  F0 07    BEQ loc_F597            
F590  88       DEY                     
F591  F0 06    BEQ loc_F599            
F593  D0 06    BNE loc_F59B            

loc_F595:  ; 1 xrefs: F58B
F595  4A       LSR A                   
F596  4A       LSR A                   

loc_F597:  ; 1 xrefs: F58E
F597  4A       LSR A                   
F598  4A       LSR A                   

loc_F599:  ; 1 xrefs: F591
F599  4A       LSR A                   
F59A  4A       LSR A                   

loc_F59B:  ; 1 xrefs: F593
F59B  29 03    AND #$03                
F59D  A8       TAY                     
F59E  B9 A9 F5 LDA $F5A9,Y             

loc_F5A1:  ; 1 xrefs: F584
F5A1  85 14    STA $14                 
F5A3  4A       LSR A                   
F5A4  A5 14    LDA $14                 
F5A6  60       RTS                     

; ==== data $F5A7..$F5AC  (6 bytes) ====
F5A7  00 40 00 01 80 02                                |.@....

loc_F5AD:  ; 1 xrefs: F5BC
F5AD  9D 76 05 STA $0576,X             
F5B0  9D 60 05 STA $0560,X             
F5B3  9D 4A 05 STA $054A,X             
F5B6  9D 34 05 STA $0534,X             
F5B9  60       RTS                     

sub_F5BA:  ; 1 xrefs: F906
F5BA  09 00    ORA #$00                
F5BC  F0 EF    BEQ loc_F5AD            
F5BE  84 01    STY $01                 
F5C0  85 00    STA $00                 
F5C2  C6 00    DEC $00                 
F5C4  98       TYA                     
F5C5  24 01    BIT $01                 
F5C7  29 3F    AND #$3F                
F5C9  F0 1B    BEQ loc_F5E6            
F5CB  18       CLC                     
F5CC  70 0C    BVS loc_F5DA            
F5CE  A8       TAY                     
F5CF  49 FF    EOR #$FF                
F5D1  69 01    ADC #$01                
F5D3  29 3F    AND #$3F                
F5D5  85 02    STA $02                 
F5D7  4C F1 F5 JMP loc_F5F1            

loc_F5DA:  ; 1 xrefs: F5CC
F5DA  85 02    STA $02                 
F5DC  49 FF    EOR #$FF                
F5DE  69 01    ADC #$01                
F5E0  29 3F    AND #$3F                
F5E2  A8       TAY                     
F5E3  4C F1 F5 JMP loc_F5F1            

loc_F5E6:  ; 1 xrefs: F5C9
F5E6  50 04    BVC loc_F5EC            
F5E8  A0 40    LDY #$40                
F5EA  70 03    BVS loc_F5EF            

loc_F5EC:  ; 1 xrefs: F5E6
F5EC  A8       TAY                     
F5ED  A9 40    LDA #$40                

loc_F5EF:  ; 1 xrefs: F5EA
F5EF  85 02    STA $02                 

loc_F5F1:  ; 2 xrefs: F5D7 F5E3
F5F1  20 37 F6 JSR sub_F637            
F5F4  9D 60 05 STA $0560,X             
F5F7  A5 04    LDA $04                 
F5F9  9D 76 05 STA $0576,X             
F5FC  A4 02    LDY $02                 
F5FE  20 37 F6 JSR sub_F637            
F601  9D 34 05 STA $0534,X             
F604  A5 04    LDA $04                 
F606  9D 4A 05 STA $054A,X             
F609  A5 01    LDA $01                 
F60B  10 13    BPL loc_F620            
F60D  A9 00    LDA #$00                
F60F  38       SEC                     
F610  FD 4A 05 SBC $054A,X             
F613  9D 4A 05 STA $054A,X             
F616  A9 00    LDA #$00                
F618  FD 34 05 SBC $0534,X             
F61B  9D 34 05 STA $0534,X             
F61E  A5 01    LDA $01                 

loc_F620:  ; 1 xrefs: F60B
F620  18       CLC                     
F621  69 40    ADC #$40                
F623  10 11    BPL loc_F636            
F625  A9 00    LDA #$00                
F627  38       SEC                     
F628  FD 76 05 SBC $0576,X             
F62B  9D 76 05 STA $0576,X             
F62E  A9 00    LDA #$00                
F630  FD 60 05 SBC $0560,X             
F633  9D 60 05 STA $0560,X             

loc_F636:  ; 1 xrefs: F623
F636  60       RTS                     

sub_F637:  ; 2 xrefs: F5F1 F5FE
F637  B9 4F F6 LDA $F64F,Y             
F63A  85 03    STA $03                 
F63C  A9 00    LDA #$00                
F63E  85 04    STA $04                 
F640  A0 08    LDY #$08                

loc_F642:  ; 1 xrefs: F64C
F642  46 03    LSR $03                 
F644  90 02    BCC loc_F648            
F646  65 00    ADC $00                 

loc_F648:  ; 1 xrefs: F644
F648  6A       ROR A                   
F649  66 04    ROR $04                 
F64B  88       DEY                     
F64C  D0 F4    BNE loc_F642            
F64E  60       RTS                     

; ==== data $F64F..$F68F  (65 bytes) ====
F64F  20 20 1F 1F 1F 1F 1F 1F 1F 1F 1F 1E 1E 1E 1E 1D  |  ..............
F65F  1D 1D 1C 1C 1C 1B 1B 1B 1A 1A 19 19 18 18 17 17  |................
F66F  16 16 15 14 14 13 13 12 11 11 10 0F 0F 0E 0D 0C  |................
F67F  0C 0B 0A 0A 09 08 07 07 06 05 04 03 03 02 01 00  |................
F68F  00                                               |.

loc_F690:  ; 1 xrefs: FF86
F690  A5 00    LDA $00                 
F692  38       SEC                     
F693  E5 02    SBC $02                 
F695  A8       TAY                     
F696  A5 04    LDA $04                 
F698  E5 06    SBC $06                 
F69A  10 14    BPL loc_F6B0            
F69C  A5 02    LDA $02                 
F69E  38       SEC                     
F69F  E5 00    SBC $00                 
F6A1  85 02    STA $02                 
F6A3  A5 06    LDA $06                 
F6A5  E5 04    SBC $04                 
F6A7  4A       LSR A                   
F6A8  66 02    ROR $02                 
F6AA  A9 00    LDA #$00                
F6AC  85 00    STA $00                 
F6AE  F0 09    BEQ loc_F6B9            

loc_F6B0:  ; 1 xrefs: F69A
F6B0  84 00    STY $00                 
F6B2  4A       LSR A                   
F6B3  66 00    ROR $00                 
F6B5  A9 00    LDA #$00                
F6B7  85 02    STA $02                 

loc_F6B9:  ; 1 xrefs: F6AE
F6B9  A5 01    LDA $01                 
F6BB  38       SEC                     
F6BC  E5 03    SBC $03                 
F6BE  A8       TAY                     
F6BF  A5 05    LDA $05                 
F6C1  E5 07    SBC $07                 
F6C3  10 14    BPL loc_F6D9            
F6C5  A5 03    LDA $03                 
F6C7  38       SEC                     
F6C8  E5 01    SBC $01                 
F6CA  85 03    STA $03                 
F6CC  A5 07    LDA $07                 
F6CE  E5 05    SBC $05                 
F6D0  4A       LSR A                   
F6D1  66 03    ROR $03                 
F6D3  A9 00    LDA #$00                
F6D5  85 01    STA $01                 
F6D7  F0 09    BEQ loc_F6E2            

loc_F6D9:  ; 1 xrefs: F6C3
F6D9  84 01    STY $01                 
F6DB  4A       LSR A                   
F6DC  66 01    ROR $01                 
F6DE  A9 00    LDA #$00                
F6E0  85 03    STA $03                 

sub_F6E2:  ; 3 xrefs: F6D7 F96F FF31
F6E2  A9 00    LDA #$00                
F6E4  85 04    STA $04                 
F6E6  A5 00    LDA $00                 
F6E8  38       SEC                     
F6E9  E5 02    SBC $02                 
F6EB  66 04    ROR $04                 
F6ED  30 04    BMI loc_F6F3            
F6EF  49 FF    EOR #$FF                
F6F1  69 01    ADC #$01                

loc_F6F3:  ; 1 xrefs: F6ED
F6F3  85 00    STA $00                 
F6F5  A5 01    LDA $01                 
F6F7  38       SEC                     
F6F8  E5 03    SBC $03                 
F6FA  66 04    ROR $04                 
F6FC  30 04    BMI loc_F702            
F6FE  49 FF    EOR #$FF                
F700  69 01    ADC #$01                

loc_F702:  ; 1 xrefs: F6FC
F702  85 01    STA $01                 
F704  A5 01    LDA $01                 
F706  C5 00    CMP $00                 
F708  66 04    ROR $04                 
F70A  A4 00    LDY $00                 
F70C  F0 4B    BEQ loc_F759            
F70E  09 00    ORA #$00                
F710  F0 4B    BEQ loc_F75D            
F712  C5 00    CMP $00                 
F714  F0 4C    BEQ loc_F762            
F716  24 04    BIT $04                 
F718  10 04    BPL loc_F71E            
F71A  84 02    STY $02                 
F71C  30 04    BMI loc_F722            

loc_F71E:  ; 1 xrefs: F718
F71E  85 02    STA $02                 
F720  84 01    STY $01                 

loc_F722:  ; 1 xrefs: F71C
F722  A9 00    LDA #$00                
F724  85 00    STA $00                 
F726  A0 08    LDY #$08                
F728  18       CLC                     

loc_F729:  ; 1 xrefs: F73B
F729  26 00    ROL $00                 
F72B  26 02    ROL $02                 
F72D  A5 02    LDA $02                 
F72F  B0 04    BCS loc_F735            
F731  C5 01    CMP $01                 
F733  90 05    BCC loc_F73A            

loc_F735:  ; 1 xrefs: F72F
F735  E5 01    SBC $01                 
F737  85 02    STA $02                 
F739  38       SEC                     

loc_F73A:  ; 1 xrefs: F733
F73A  88       DEY                     
F73B  D0 EC    BNE loc_F729            
F73D  26 00    ROL $00                 
F73F  A5 04    LDA $04                 
F741  4A       LSR A                   
F742  4A       LSR A                   
F743  4A       LSR A                   
F744  4A       LSR A                   
F745  A8       TAY                     
F746  B9 6F F7 LDA $F76F,Y             
F749  6A       ROR A                   
F74A  B9 70 F7 LDA $F770,Y             
F74D  A4 00    LDY $00                 
F74F  90 04    BCC loc_F755            
F751  79 83 F7 ADC $F783,Y             
F754  60       RTS                     

loc_F755:  ; 1 xrefs: F74F
F755  F9 83 F7 SBC $F783,Y             
F758  60       RTS                     

loc_F759:  ; 1 xrefs: F70C
F759  A5 04    LDA $04                 
F75B  0A       ASL A                   
F75C  60       RTS                     

loc_F75D:  ; 1 xrefs: F710
F75D  A5 04    LDA $04                 
F75F  0A       ASL A                   
F760  0A       ASL A                   
F761  60       RTS                     

loc_F762:  ; 1 xrefs: F714
F762  A5 04    LDA $04                 
F764  2A       ROL A                   
F765  2A       ROL A                   
F766  2A       ROL A                   
F767  2A       ROL A                   
F768  29 03    AND #$03                
F76A  A8       TAY                     
F76B  B9 7F F7 LDA $F77F,Y             
F76E  60       RTS                     

; ==== data $F76F..$F882  (276 bytes) ====
F76F  01 FF 00 81 00 01 01 7F 00 41 01 3F 01 BF 00 C1  |.........A.?....
F77F  20 60 E0 A0 00 00 00 00 01 01 01 01 01 01 02 02  | `..............
F78F  02 02 02 02 03 03 03 03 03 03 03 04 04 04 04 04  |................
F79F  04 05 05 05 05 05 05 06 06 06 06 06 06 06 07 07  |................
F7AF  07 07 07 07 08 08 08 08 08 08 08 09 09 09 09 09  |................
F7BF  09 0A 0A 0A 0A 0A 0A 0A 0B 0B 0B 0B 0B 0B 0B 0C  |................
F7CF  0C 0C 0C 0C 0C 0C 0D 0D 0D 0D 0D 0D 0D 0E 0E 0E  |................
F7DF  0E 0E 0E 0E 0F 0F 0F 0F 0F 0F 0F 10 10 10 10 10  |................
F7EF  10 10 11 11 11 11 11 11 11 11 12 12 12 12 12 12  |................
F7FF  12 13 13 13 13 13 13 13 13 14 14 14 14 14 14 14  |................
F80F  14 15 15 15 15 15 15 15 15 15 16 16 16 16 16 16  |................
F81F  16 16 17 17 17 17 17 17 17 17 17 18 18 18 18 18  |................
F82F  18 18 18 18 19 19 19 19 19 19 19 19 19 19 1A 1A  |................
F83F  1A 1A 1A 1A 1A 1A 1A 1B 1B 1B 1B 1B 1B 1B 1B 1B  |................
F84F  1B 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1D 1D 1D 1D  |................
F85F  1D 1D 1D 1D 1D 1D 1D 1E 1E 1E 1E 1E 1E 1E 1E 1E  |................
F86F  1E 1E 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 20 20  |..............  
F87F  20 20 20 20                                      |    

loc_F883:  ; 0 xrefs: 
F883  20 13 F9 JSR sub_F913            
F886  20 58 F9 JSR sub_F958            
F889  4C DD F8 JMP loc_F8DD            

loc_F88C:  ; 0 xrefs: 
F88C  20 13 F9 JSR sub_F913            

loc_F88F:  ; 1 xrefs: F8D0
F88F  20 51 F9 JSR sub_F951            
F892  4C E7 F8 JMP loc_F8E7            

loc_F895:  ; 0 xrefs: 
F895  20 13 F9 JSR sub_F913            
F898  4C DD F8 JMP loc_F8DD            

loc_F89B:  ; 0 xrefs: 
F89B  20 13 F9 JSR sub_F913            

loc_F89E:  ; 1 xrefs: F8DA
F89E  4C E7 F8 JMP loc_F8E7            

loc_F8A1:  ; 0 xrefs: 
F8A1  20 24 F9 JSR sub_F924            
F8A4  86 25    STX $25                 
F8A6  20 1B CB JSR $CB1B               
F8A9  B0 1A    BCS loc_F8C5            
F8AB  A5 24    LDA $24                 
F8AD  9D 00 04 STA $0400,X             
F8B0  A9 08    LDA #$08                
F8B2  9D 16 04 STA $0416,X             
F8B5  A5 10    LDA $10                 
F8B7  9D 08 05 STA $0508,X             
F8BA  A5 11    LDA $11                 
F8BC  9D C6 04 STA $04C6,X             
F8BF  86 12    STX $12                 
F8C1  18       CLC                     
F8C2  A6 25    LDX $25                 
F8C4  60       RTS                     

loc_F8C5:  ; 1 xrefs: F8A9
F8C5  38       SEC                     
F8C6  A6 25    LDX $25                 
F8C8  60       RTS                     

loc_F8C9:  ; 0 xrefs: 
F8C9  20 24 F9 JSR sub_F924            
F8CC  A4 26    LDY $26                 
F8CE  A5 24    LDA $24                 
F8D0  4C 8F F8 JMP loc_F88F            

loc_F8D3:  ; 0 xrefs: 
F8D3  20 24 F9 JSR sub_F924            
F8D6  A4 26    LDY $26                 
F8D8  A5 24    LDA $24                 
F8DA  4C 9E F8 JMP loc_F89E            

loc_F8DD:  ; 2 xrefs: F889 F898
F8DD  BD 08 05 LDA $0508,X             
F8E0  85 10    STA $10                 
F8E2  BD C6 04 LDA $04C6,X             
F8E5  85 11    STA $11                 

loc_F8E7:  ; 2 xrefs: F892 F89E
F8E7  86 25    STX $25                 
F8E9  20 1B CB JSR $CB1B               
F8EC  B0 21    BCS loc_F90F            
F8EE  A5 24    LDA $24                 
F8F0  9D 00 04 STA $0400,X             
F8F3  A5 10    LDA $10                 
F8F5  9D 08 05 STA $0508,X             
F8F8  A5 11    LDA $11                 
F8FA  9D C6 04 STA $04C6,X             
F8FD  A9 08    LDA #$08                
F8FF  9D 16 04 STA $0416,X             
F902  A5 26    LDA $26                 
F904  A4 06    LDY $06                 
F906  20 BA F5 JSR sub_F5BA            
F909  86 26    STX $26                 
F90B  A6 25    LDX $25                 
F90D  18       CLC                     
F90E  60       RTS                     

loc_F90F:  ; 1 xrefs: F8EC
F90F  A6 25    LDX $25                 
F911  38       SEC                     
F912  60       RTS                     

sub_F913:  ; 4 xrefs: F883 F88C F895 F89B
F913  85 24    STA $24                 
F915  84 26    STY $26                 
F917  BD F2 04 LDA $04F2,X             
F91A  1D B0 04 ORA $04B0,X             
F91D  D0 01    BNE loc_F920            
F91F  60       RTS                     

loc_F920:  ; 1 xrefs: F91D
F920  68       PLA                     
F921  68       PLA                     
F922  38       SEC                     
F923  60       RTS                     

sub_F924:  ; 3 xrefs: F8A1 F8C9 F8D3
F924  84 12    STY $12                 
F926  A0 00    LDY #$00                
F928  09 00    ORA #$00                
F92A  10 01    BPL loc_F92D            
F92C  88       DEY                     

loc_F92D:  ; 1 xrefs: F92A
F92D  18       CLC                     
F92E  7D 08 05 ADC $0508,X             
F931  85 10    STA $10                 
F933  98       TYA                     
F934  7D F2 04 ADC $04F2,X             
F937  D0 14    BNE loc_F94D            
F939  A0 00    LDY #$00                
F93B  A5 12    LDA $12                 
F93D  10 01    BPL loc_F940            
F93F  88       DEY                     

loc_F940:  ; 1 xrefs: F93D
F940  18       CLC                     
F941  7D C6 04 ADC $04C6,X             
F944  85 11    STA $11                 
F946  98       TYA                     
F947  7D B0 04 ADC $04B0,X             
F94A  D0 01    BNE loc_F94D            
F94C  60       RTS                     

loc_F94D:  ; 2 xrefs: F937 F94A
F94D  68       PLA                     
F94E  68       PLA                     
F94F  38       SEC                     
F950  60       RTS                     

sub_F951:  ; 1 xrefs: F88F
F951  A5 10    LDA $10                 
F953  A4 11    LDY $11                 
F955  4C 5E F9 JMP loc_F95E            

sub_F958:  ; 1 xrefs: F886
F958  BD 08 05 LDA $0508,X             
F95B  BC C6 04 LDY $04C6,X             

loc_F95E:  ; 1 xrefs: F955
F95E  85 00    STA $00                 
F960  84 01    STY $01                 
F962  AD 08 05 LDA $0508               
F965  85 02    STA $02                 
F967  AD C6 04 LDA $04C6               
F96A  18       CLC                     
F96B  69 F6    ADC #$F6                
F96D  85 03    STA $03                 
F96F  20 E2 F6 JSR sub_F6E2            
F972  85 06    STA $06                 
F974  60       RTS                     

loc_F975:  ; 1 xrefs: F97A
F975  EA       NOP                     
F976  EA       NOP                     
F977  EA       NOP                     
F978  EA       NOP                     
F979  EA       NOP                     
F97A  4C 75 F9 JMP loc_F975            

loc_F97D:  ; 2 xrefs: FC1B FC38
F97D  20 89 F9 JSR sub_F989            

loc_F980:  ; 0 xrefs: 
F980  BD 2C 04 LDA $042C,X             
F983  49 40    EOR #$40                
F985  9D 2C 04 STA $042C,X             
F988  60       RTS                     

sub_F989:  ; 2 xrefs: F97D FA01
F989  BD 76 05 LDA $0576,X             
F98C  49 FF    EOR #$FF                
F98E  18       CLC                     
F98F  69 01    ADC #$01                
F991  9D 76 05 STA $0576,X             
F994  BD 60 05 LDA $0560,X             
F997  49 FF    EOR #$FF                
F999  69 00    ADC #$00                
F99B  9D 60 05 STA $0560,X             
F99E  60       RTS                     

loc_F99F:  ; 0 xrefs: 
F99F  BD 4A 05 LDA $054A,X             
F9A2  49 FF    EOR #$FF                
F9A4  18       CLC                     
F9A5  69 01    ADC #$01                
F9A7  9D 4A 05 STA $054A,X             
F9AA  BD 34 05 LDA $0534,X             
F9AD  49 FF    EOR #$FF                
F9AF  69 00    ADC #$00                
F9B1  9D 34 05 STA $0534,X             
F9B4  60       RTS                     

sub_F9B5:  ; 2 xrefs: F9EE F9F7
F9B5  9D 60 05 STA $0560,X             
F9B8  98       TYA                     
F9B9  9D 76 05 STA $0576,X             
F9BC  60       RTS                     

loc_F9BD:  ; 0 xrefs: 
F9BD  9D 34 05 STA $0534,X             
F9C0  98       TYA                     
F9C1  9D 4A 05 STA $054A,X             
F9C4  60       RTS                     

sub_F9C5:  ; 1 xrefs: F9F1
F9C5  20 DC F9 JSR sub_F9DC            
F9C8  B0 09    BCS loc_F9D3            
F9CA  BD 2C 04 LDA $042C,X             
F9CD  09 40    ORA #$40                
F9CF  9D 2C 04 STA $042C,X             
F9D2  60       RTS                     

loc_F9D3:  ; 1 xrefs: F9C8
F9D3  BD 2C 04 LDA $042C,X             
F9D6  29 BF    AND #$BF                
F9D8  9D 2C 04 STA $042C,X             
F9DB  60       RTS                     

sub_F9DC:  ; 1 xrefs: F9C5
F9DC  BD F2 04 LDA $04F2,X             
F9DF  30 09    BMI loc_F9EA            
F9E1  D0 09    BNE loc_F9EC            
F9E3  BD 08 05 LDA $0508,X             
F9E6  CD 08 05 CMP $0508               
F9E9  60       RTS                     

loc_F9EA:  ; 1 xrefs: F9DF
F9EA  18       CLC                     
F9EB  60       RTS                     

loc_F9EC:  ; 1 xrefs: F9E1
F9EC  38       SEC                     
F9ED  60       RTS                     

loc_F9EE:  ; 0 xrefs: 
F9EE  20 B5 F9 JSR sub_F9B5            
F9F1  20 C5 F9 JSR sub_F9C5            
F9F4  4C FA F9 JMP loc_F9FA            

loc_F9F7:  ; 0 xrefs: 
F9F7  20 B5 F9 JSR sub_F9B5            

loc_F9FA:  ; 1 xrefs: F9F4
F9FA  BD 2C 04 LDA $042C,X             
F9FD  29 40    AND #$40                
F9FF  F0 03    BEQ loc_FA04            
FA01  20 89 F9 JSR sub_F989            

loc_FA04:  ; 1 xrefs: F9FF
FA04  60       RTS                     

loc_FA05:  ; 0 xrefs: 
FA05  20 0F E3 JSR sub_E30F            

loc_FA08:  ; 1 xrefs: FB7B
FA08  20 2F FA JSR sub_FA2F            

loc_FA0B:  ; 0 xrefs: 
FA0B  A9 00    LDA #$00                
FA0D  85 00    STA $00                 
FA0F  BD DC 04 LDA $04DC,X             
FA12  18       CLC                     
FA13  7D 4A 05 ADC $054A,X             
FA16  9D DC 04 STA $04DC,X             
FA19  BD 34 05 LDA $0534,X             
FA1C  10 02    BPL loc_FA20            
FA1E  C6 00    DEC $00                 

loc_FA20:  ; 1 xrefs: FA1C
FA20  7D C6 04 ADC $04C6,X             
FA23  9D C6 04 STA $04C6,X             
FA26  BD B0 04 LDA $04B0,X             
FA29  65 00    ADC $00                 
FA2B  9D B0 04 STA $04B0,X             
FA2E  60       RTS                     

sub_FA2F:  ; 1 xrefs: FA08
FA2F  A9 00    LDA #$00                
FA31  85 00    STA $00                 
FA33  BD 1E 05 LDA $051E,X             
FA36  18       CLC                     
FA37  7D 76 05 ADC $0576,X             
FA3A  9D 1E 05 STA $051E,X             
FA3D  BD 60 05 LDA $0560,X             
FA40  10 02    BPL loc_FA44            
FA42  C6 00    DEC $00                 

loc_FA44:  ; 1 xrefs: FA40
FA44  7D 08 05 ADC $0508,X             
FA47  9D 08 05 STA $0508,X             
FA4A  BD F2 04 LDA $04F2,X             
FA4D  65 00    ADC $00                 
FA4F  9D F2 04 STA $04F2,X             
FA52  60       RTS                     

loc_FA53:  ; 2 xrefs: FD2E FDA5
FA53  A9 00    LDA #$00                

loc_FA55:  ; 0 xrefs: 
FA55  84 00    STY $00                 
FA57  18       CLC                     
FA58  7D DC 04 ADC $04DC,X             
FA5B  9D DC 04 STA $04DC,X             
FA5E  A0 00    LDY #$00                
FA60  A5 00    LDA $00                 
FA62  10 01    BPL loc_FA65            
FA64  88       DEY                     

loc_FA65:  ; 1 xrefs: FA62
FA65  7D C6 04 ADC $04C6,X             
FA68  9D C6 04 STA $04C6,X             
FA6B  98       TYA                     
FA6C  7D B0 04 ADC $04B0,X             
FA6F  9D B0 04 STA $04B0,X             
FA72  60       RTS                     

loc_FA73:  ; 1 xrefs: FDA2
FA73  A9 00    LDA #$00                

loc_FA75:  ; 0 xrefs: 
FA75  84 00    STY $00                 
FA77  18       CLC                     
FA78  7D 1E 05 ADC $051E,X             
FA7B  9D 1E 05 STA $051E,X             
FA7E  A0 00    LDY #$00                
FA80  A5 00    LDA $00                 
FA82  10 01    BPL loc_FA85            
FA84  88       DEY                     

loc_FA85:  ; 1 xrefs: FA82
FA85  7D 08 05 ADC $0508,X             
FA88  9D 08 05 STA $0508,X             
FA8B  98       TYA                     
FA8C  7D F2 04 ADC $04F2,X             
FA8F  9D F2 04 STA $04F2,X             
FA92  60       RTS                     

loc_FA93:  ; 0 xrefs: 
FA93  18       CLC                     
FA94  7D 4A 05 ADC $054A,X             
FA97  9D 4A 05 STA $054A,X             
FA9A  BD 34 05 LDA $0534,X             
FA9D  69 00    ADC #$00                
FA9F  9D 34 05 STA $0534,X             
FAA2  60       RTS                     

loc_FAA3:  ; 0 xrefs: 
FAA3  18       CLC                     
FAA4  7D 76 05 ADC $0576,X             
FAA7  9D 76 05 STA $0576,X             
FAAA  BD 60 05 LDA $0560,X             
FAAD  69 00    ADC #$00                
FAAF  9D 60 05 STA $0560,X             
FAB2  60       RTS                     

loc_FAB3:  ; 0 xrefs: 
FAB3  85 24    STA $24                 
FAB5  BD 4A 05 LDA $054A,X             
FAB8  38       SEC                     
FAB9  E5 24    SBC $24                 
FABB  9D 4A 05 STA $054A,X             
FABE  BD 34 05 LDA $0534,X             
FAC1  E9 00    SBC #$00                
FAC3  9D 34 05 STA $0534,X             
FAC6  60       RTS                     

loc_FAC7:  ; 0 xrefs: 
FAC7  85 24    STA $24                 
FAC9  BD 76 05 LDA $0576,X             
FACC  38       SEC                     
FACD  E5 24    SBC $24                 
FACF  9D 76 05 STA $0576,X             
FAD2  BD 60 05 LDA $0560,X             
FAD5  E9 00    SBC #$00                
FAD7  9D 60 05 STA $0560,X             
FADA  60       RTS                     

loc_FADB:  ; 0 xrefs: 
FADB  BD 08 05 LDA $0508,X             
FADE  85 10    STA $10                 
FAE0  BD C6 04 LDA $04C6,X             
FAE3  85 11    STA $11                 
FAE5  BD 2C 04 LDA $042C,X             
FAE8  85 12    STA $12                 
FAEA  60       RTS                     

loc_FAEB:  ; 0 xrefs: 
FAEB  A5 12    LDA $12                 
FAED  9D 2C 04 STA $042C,X             

loc_FAF0:  ; 0 xrefs: 
FAF0  A5 10    LDA $10                 
FAF2  9D 08 05 STA $0508,X             
FAF5  A5 11    LDA $11                 
FAF7  9D C6 04 STA $04C6,X             
FAFA  60       RTS                     

loc_FAFB:  ; 0 xrefs: 
FAFB  AC 69 01 LDY $0169               
FAFE  AD 68 01 LDA $0168               
FB01  0A       ASL A                   
FB02  2E 69 01 ROL $0169               
FB05  0A       ASL A                   
FB06  2E 69 01 ROL $0169               
FB09  18       CLC                     
FB0A  6D 68 01 ADC $0168               
FB0D  8D 68 01 STA $0168               

loc_FB10:  ; 0 xrefs: 
FB10  98       TYA                     
FB11  6D 69 01 ADC $0169               
FB14  A8       TAY                     
FB15  AD 68 01 LDA $0168               
FB18  18       CLC                     
FB19  69 11    ADC #$11                
FB1B  8D 68 01 STA $0168               
FB1E  98       TYA                     
FB1F  69 37    ADC #$37                
FB21  8D 69 01 STA $0169               
FB24  60       RTS                     

loc_FB25:  ; 0 xrefs: 
FB25  BD F2 04 LDA $04F2,X             
FB28  D0 15    BNE loc_FB3F            
FB2A  BD 08 05 LDA $0508,X             
FB2D  38       SEC                     
FB2E  ED 08 05 SBC $0508               
FB31  B0 08    BCS loc_FB3B            
FB33  20 EB CA JSR $CAEB               
FB36  18       CLC                     
FB37  2C 71 FB BIT $FB71               
FB3A  60       RTS                     

loc_FB3B:  ; 1 xrefs: FB31
FB3B  2C 71 FB BIT $FB71               
FB3E  60       RTS                     

loc_FB3F:  ; 1 xrefs: FB28
FB3F  30 05    BMI loc_FB46            
FB41  38       SEC                     
FB42  2C 72 FB BIT $FB72               
FB45  60       RTS                     

loc_FB46:  ; 1 xrefs: FB3F
FB46  18       CLC                     
FB47  2C 72 FB BIT $FB72               
FB4A  60       RTS                     

loc_FB4B:  ; 0 xrefs: 
FB4B  BD B0 04 LDA $04B0,X             
FB4E  D0 15    BNE loc_FB65            
FB50  BD C6 04 LDA $04C6,X             
FB53  38       SEC                     
FB54  ED C6 04 SBC $04C6               
FB57  B0 08    BCS loc_FB61            
FB59  20 EB CA JSR $CAEB               
FB5C  18       CLC                     
FB5D  2C 71 FB BIT $FB71               
FB60  60       RTS                     

loc_FB61:  ; 1 xrefs: FB57
FB61  2C 71 FB BIT $FB71               
FB64  60       RTS                     

loc_FB65:  ; 1 xrefs: FB4E
FB65  30 05    BMI loc_FB6C            
FB67  38       SEC                     
FB68  2C 72 FB BIT $FB72               
FB6B  60       RTS                     

loc_FB6C:  ; 1 xrefs: FB65
FB6C  18       CLC                     
FB6D  2C 72 FB BIT $FB72               
FB70  60       RTS                     

; ==== data $FB71..$FB72  (2 bytes) ====
FB71  00 40                                            |.@

loc_FB73:  ; 0 xrefs: 
FB73  A9 00    LDA #$00                
FB75  A8       TAY                     
FB76  20 88 FB JSR sub_FB88            
FB79  30 03    BMI loc_FB7E            

loc_FB7B:  ; 0 xrefs: 
FB7B  4C 08 FA JMP loc_FA08            

loc_FB7E:  ; 1 xrefs: FB79
FB7E  4C D4 D6 JMP $D6D4               

sub_FB81:  ; 6 xrefs: FB8A FB94 FBA8 FBB2 FBDE FBE8
FB81  8A       TXA                     
FB82  4D 19 01 EOR $0119               
FB85  29 01    AND #$01                
FB87  60       RTS                     

sub_FB88:  ; 1 xrefs: FB76
FB88  85 10    STA $10                 
FB8A  20 81 FB JSR sub_FB81            
FB8D  F0 0D    BEQ loc_FB9C            
FB8F  A9 00    LDA #$00                
FB91  60       RTS                     

sub_FB92:  ; 1 xrefs: FC33
FB92  85 10    STA $10                 
FB94  20 81 FB JSR sub_FB81            
FB97  F0 03    BEQ loc_FB9C            
FB99  A9 80    LDA #$80                
FB9B  60       RTS                     

loc_FB9C:  ; 2 xrefs: FB8D FB97
FB9C  A5 10    LDA $10                 
FB9E  4C 42 F3 JMP sub_F342            

loc_FBA1:  ; 0 xrefs: 
FBA1  85 00    STA $00                 
FBA3  4C BA FB JMP loc_FBBA            

loc_FBA6:  ; 0 xrefs: 
FBA6  85 00    STA $00                 
FBA8  20 81 FB JSR sub_FB81            
FBAB  F0 0D    BEQ loc_FBBA            
FBAD  A9 00    LDA #$00                
FBAF  60       RTS                     

loc_FBB0:  ; 0 xrefs: 
FBB0  85 00    STA $00                 
FBB2  20 81 FB JSR sub_FB81            
FBB5  F0 03    BEQ loc_FBBA            
FBB7  A9 80    LDA #$80                
FBB9  60       RTS                     

loc_FBBA:  ; 3 xrefs: FBA3 FBAB FBB5
FBBA  84 01    STY $01                 
FBBC  A5 00    LDA $00                 
FBBE  20 42 F3 JSR sub_F342            
FBC1  30 11    BMI loc_FBD4            
FBC3  A5 00    LDA $00                 
FBC5  49 FF    EOR #$FF                
FBC7  18       CLC                     
FBC8  69 01    ADC #$01                
FBCA  A4 01    LDY $01                 
FBCC  20 42 F3 JSR sub_F342            
FBCF  30 03    BMI loc_FBD4            
FBD1  A9 00    LDA #$00                
FBD3  60       RTS                     

loc_FBD4:  ; 2 xrefs: FBC1 FBCF
FBD4  A9 80    LDA #$80                
FBD6  60       RTS                     

loc_FBD7:  ; 0 xrefs: 
FBD7  85 01    STA $01                 
FBD9  4C F0 FB JMP loc_FBF0            

sub_FBDC:  ; 1 xrefs: FC16
FBDC  85 01    STA $01                 
FBDE  20 81 FB JSR sub_FB81            
FBE1  F0 0D    BEQ loc_FBF0            
FBE3  A9 00    LDA #$00                
FBE5  60       RTS                     

loc_FBE6:  ; 0 xrefs: 
FBE6  85 01    STA $01                 
FBE8  20 81 FB JSR sub_FB81            
FBEB  F0 03    BEQ loc_FBF0            
FBED  A9 80    LDA #$80                
FBEF  60       RTS                     

loc_FBF0:  ; 3 xrefs: FBD9 FBE1 FBEB
FBF0  BD 2C 04 LDA $042C,X             
FBF3  29 40    AND #$40                
FBF5  F0 09    BEQ loc_FC00            
FBF7  A5 00    LDA $00                 
FBF9  49 FF    EOR #$FF                
FBFB  18       CLC                     
FBFC  69 01    ADC #$01                
FBFE  85 00    STA $00                 

loc_FC00:  ; 1 xrefs: FBF5
FC00  A5 00    LDA $00                 
FC02  20 42 F3 JSR sub_F342            
FC05  30 0C    BMI loc_FC13            
FC07  A5 00    LDA $00                 
FC09  A4 01    LDY $01                 
FC0B  20 42 F3 JSR sub_F342            
FC0E  30 03    BMI loc_FC13            
FC10  A9 00    LDA #$00                
FC12  60       RTS                     

loc_FC13:  ; 2 xrefs: FC05 FC0E
FC13  A9 80    LDA #$80                
FC15  60       RTS                     

loc_FC16:  ; 0 xrefs: 
FC16  20 DC FB JSR sub_FBDC            
FC19  10 03    BPL loc_FC1E            
FC1B  4C 7D F9 JMP loc_F97D            

loc_FC1E:  ; 1 xrefs: FC19
FC1E  60       RTS                     

loc_FC1F:  ; 0 xrefs: 
FC1F  85 00    STA $00                 
FC21  BD 2C 04 LDA $042C,X             
FC24  29 40    AND #$40                
FC26  F0 09    BEQ loc_FC31            
FC28  A5 00    LDA $00                 
FC2A  49 FF    EOR #$FF                
FC2C  18       CLC                     
FC2D  69 01    ADC #$01                
FC2F  85 00    STA $00                 

loc_FC31:  ; 1 xrefs: FC26
FC31  A5 00    LDA $00                 
FC33  20 92 FB JSR sub_FB92            
FC36  30 03    BMI loc_FC3B            
FC38  4C 7D F9 JMP loc_F97D            

loc_FC3B:  ; 1 xrefs: FC36
FC3B  60       RTS                     

loc_FC3C:  ; 0 xrefs: 
FC3C  20 0B CB JSR $CB0B               
FC3F  90 03    BCC loc_FC44            
FC41  4C 1B CB JMP $CB1B               

loc_FC44:  ; 1 xrefs: FC3F
FC44  60       RTS                     

loc_FC45:  ; 0 xrefs: 
FC45  B9 00 04 LDA $0400,Y             
FC48  9D 00 04 STA $0400,X             
FC4B  B9 16 04 LDA $0416,Y             
FC4E  9D 16 04 STA $0416,X             
FC51  B9 8C 05 LDA $058C,Y             
FC54  9D 8C 05 STA $058C,X             
FC57  B9 42 04 LDA $0442,Y             
FC5A  9D 42 04 STA $0442,X             
FC5D  B9 58 04 LDA $0458,Y             
FC60  9D 58 04 STA $0458,X             
FC63  B9 6E 04 LDA $046E,Y             
FC66  9D 6E 04 STA $046E,X             
FC69  B9 2C 04 LDA $042C,Y             
FC6C  9D 2C 04 STA $042C,X             
FC6F  B9 9A 04 LDA $049A,Y             
FC72  9D 9A 04 STA $049A,X             
FC75  B9 B0 04 LDA $04B0,Y             
FC78  9D B0 04 STA $04B0,X             
FC7B  B9 C6 04 LDA $04C6,Y             
FC7E  9D C6 04 STA $04C6,X             
FC81  B9 DC 04 LDA $04DC,Y             
FC84  9D DC 04 STA $04DC,X             
FC87  B9 F2 04 LDA $04F2,Y             
FC8A  9D F2 04 STA $04F2,X             
FC8D  B9 08 05 LDA $0508,Y             
FC90  9D 08 05 STA $0508,X             
FC93  B9 1E 05 LDA $051E,Y             
FC96  9D 1E 05 STA $051E,X             
FC99  B9 76 05 LDA $0576,Y             
FC9C  9D 76 05 STA $0576,X             
FC9F  B9 60 05 LDA $0560,Y             
FCA2  9D 60 05 STA $0560,X             

loc_FCA5:  ; 0 xrefs: 
FCA5  B9 4A 05 LDA $054A,Y             
FCA8  9D 4A 05 STA $054A,X             
FCAB  B9 34 05 LDA $0534,Y             
FCAE  9D 34 05 STA $0534,X             
FCB1  B9 A2 05 LDA $05A2,Y             
FCB4  9D A2 05 STA $05A2,X             
FCB7  B9 B8 05 LDA $05B8,Y             
FCBA  9D B8 05 STA $05B8,X             
FCBD  B9 CE 05 LDA $05CE,Y             
FCC0  9D CE 05 STA $05CE,X             
FCC3  B9 E4 05 LDA $05E4,Y             
FCC6  9D E4 05 STA $05E4,X             
FCC9  B9 FA 05 LDA $05FA,Y             
FCCC  9D FA 05 STA $05FA,X             
FCCF  B9 10 06 LDA $0610,Y             
FCD2  9D 10 06 STA $0610,X             
FCD5  B9 26 06 LDA $0626,Y             
FCD8  9D 26 06 STA $0626,X             
FCDB  B9 3C 06 LDA $063C,Y             
FCDE  9D 3C 06 STA $063C,X             
FCE1  B9 52 06 LDA $0652,Y             
FCE4  9D 52 06 STA $0652,X             
FCE7  B9 68 06 LDA $0668,Y             
FCEA  9D 68 06 STA $0668,X             
FCED  60       RTS                     

loc_FCEE:  ; 0 xrefs: 
FCEE  FE 8C 05 INC $058C,X             
FCF1  60       RTS                     

loc_FCF2:  ; 0 xrefs: 
FCF2  DE 8C 05 DEC $058C,X             
FCF5  60       RTS                     

sub_FCF6:  ; 1 xrefs: FEAA
FCF6  A9 00    LDA #$00                
FCF8  F0 12    BEQ loc_FD0C            

loc_FCFA:  ; 0 xrefs: 
FCFA  A9 01    LDA #$01                
FCFC  D0 0E    BNE loc_FD0C            

loc_FCFE:  ; 0 xrefs: 
FCFE  A9 02    LDA #$02                
FD00  D0 0A    BNE loc_FD0C            

loc_FD02:  ; 0 xrefs: 
FD02  A9 03    LDA #$03                
FD04  D0 06    BNE loc_FD0C            

loc_FD06:  ; 0 xrefs: 
FD06  A9 04    LDA #$04                
FD08  D0 02    BNE loc_FD0C            

loc_FD0A:  ; 0 xrefs: 
FD0A  A9 05    LDA #$05                

loc_FD0C:  ; 5 xrefs: FCF8 FCFC FD00 FD04 FD08
FD0C  9D 8C 05 STA $058C,X             
FD0F  60       RTS                     

loc_FD10:  ; 0 xrefs: 
FD10  BD 8C 05 LDA $058C,X             
FD13  4C 0B CA JMP $CA0B               

loc_FD16:  ; 0 xrefs: 
FD16  18       CLC                     
FD17  7D C6 04 ADC $04C6,X             
FD1A  4C 20 FD JMP loc_FD20            

loc_FD1D:  ; 0 xrefs: 
FD1D  BD C6 04 LDA $04C6,X             

loc_FD20:  ; 1 xrefs: FD1A
FD20  A4 97    LDY $97                 
FD22  F0 03    BEQ loc_FD27            
FD24  18       CLC                     
FD25  65 67    ADC $67                 

loc_FD27:  ; 1 xrefs: FD22
FD27  29 0F    AND #$0F                
FD29  A8       TAY                     
FD2A  B9 31 FD LDA $FD31,Y             
FD2D  A8       TAY                     
FD2E  4C 53 FA JMP loc_FA53            

; ==== data $FD31..$FD40  (16 bytes) ====
FD31  FF FE FD FC FB FA F9 F8 07 06 05 04 03 02 01 00  |................

loc_FD41:  ; 0 xrefs: 
FD41  20 DB CA JSR $CADB               
FD44  A8       TAY                     
FD45  BD 2C 04 LDA $042C,X             
FD48  29 40    AND #$40                
FD4A  90 04    BCC loc_FD50            
FD4C  D0 04    BNE loc_FD52            

loc_FD4E:  ; 1 xrefs: FD50
FD4E  38       SEC                     
FD4F  60       RTS                     

loc_FD50:  ; 1 xrefs: FD4A
FD50  D0 FC    BNE loc_FD4E            

loc_FD52:  ; 1 xrefs: FD4C
FD52  18       CLC                     
FD53  60       RTS                     

loc_FD54:  ; 0 xrefs: 
FD54  BD 2C 04 LDA $042C,X             
FD57  29 40    AND #$40                
FD59  D0 02    BNE loc_FD5D            
FD5B  18       CLC                     
FD5C  60       RTS                     

loc_FD5D:  ; 1 xrefs: FD59
FD5D  38       SEC                     
FD5E  60       RTS                     

loc_FD5F:  ; 0 xrefs: 
FD5F  BD 60 05 LDA $0560,X             
FD62  30 09    BMI loc_FD6D            
FD64  BD 2C 04 LDA $042C,X             
FD67  09 40    ORA #$40                
FD69  9D 2C 04 STA $042C,X             
FD6C  60       RTS                     

loc_FD6D:  ; 1 xrefs: FD62
FD6D  BD 2C 04 LDA $042C,X             
FD70  29 BF    AND #$BF                
FD72  9D 2C 04 STA $042C,X             
FD75  60       RTS                     

loc_FD76:  ; 0 xrefs: 
FD76  A9 01    LDA #$01                
FD78  D0 0E    BNE loc_FD88            

loc_FD7A:  ; 0 xrefs: 
FD7A  A9 02    LDA #$02                
FD7C  D0 0A    BNE loc_FD88            

loc_FD7E:  ; 0 xrefs: 
FD7E  A9 20    LDA #$20                
FD80  D0 06    BNE loc_FD88            

loc_FD82:  ; 0 xrefs: 
FD82  A9 40    LDA #$40                
FD84  D0 02    BNE loc_FD88            

loc_FD86:  ; 1 xrefs: FEBD
FD86  A9 80    LDA #$80                

loc_FD88:  ; 4 xrefs: FD78 FD7C FD80 FD84
FD88  9D 16 04 STA $0416,X             
FD8B  60       RTS                     

loc_FD8C:  ; 0 xrefs: 
FD8C  BD F2 04 LDA $04F2,X             
FD8F  1D B0 04 ORA $04B0,X             
FD92  D0 02    BNE loc_FD96            
FD94  18       CLC                     
FD95  60       RTS                     

loc_FD96:  ; 1 xrefs: FD92
FD96  38       SEC                     
FD97  60       RTS                     

loc_FD98:  ; 0 xrefs: 
FD98  29 40    AND #$40                
FD9A  F0 0C    BEQ loc_FDA8            
FD9C  A0 08    LDY #$08                
FD9E  A5 97    LDA $97                 
FDA0  D0 03    BNE loc_FDA5            
FDA2  4C 73 FA JMP loc_FA73            

loc_FDA5:  ; 1 xrefs: FDA0
FDA5  4C 53 FA JMP loc_FA53            

loc_FDA8:  ; 1 xrefs: FD9A
FDA8  60       RTS                     

loc_FDA9:  ; 0 xrefs: 
FDA9  20 E5 FD JSR sub_FDE5            

loc_FDAC:  ; 0 xrefs: 
FDAC  A5 97    LDA $97                 
FDAE  F0 28    BEQ loc_FDD8            
FDB0  A5 67    LDA $67                 
FDB2  18       CLC                     
FDB3  7D C6 04 ADC $04C6,X             
FDB6  A8       TAY                     
FDB7  08       PHP                     
FDB8  A5 66    LDA $66                 
FDBA  7D B0 04 ADC $04B0,X             
FDBD  9D 3C 06 STA $063C,X             
FDC0  28       PLP                     
FDC1  90 05    BCC loc_FDC8            
FDC3  98       TYA                     
FDC4  18       CLC                     
FDC5  69 10    ADC #$10                
FDC7  A8       TAY                     

loc_FDC8:  ; 1 xrefs: FDC1
FDC8  C0 F0    CPY #$F0                
FDCA  90 07    BCC loc_FDD3            
FDCC  98       TYA                     
FDCD  29 0F    AND #$0F                
FDCF  A8       TAY                     
FDD0  FE 3C 06 INC $063C,X             

loc_FDD3:  ; 1 xrefs: FDCA
FDD3  98       TYA                     
FDD4  9D 26 06 STA $0626,X             
FDD7  60       RTS                     

loc_FDD8:  ; 1 xrefs: FDAE
FDD8  BD C6 04 LDA $04C6,X             
FDDB  9D 26 06 STA $0626,X             
FDDE  BD B0 04 LDA $04B0,X             
FDE1  9D 3C 06 STA $063C,X             
FDE4  60       RTS                     

sub_FDE5:  ; 1 xrefs: FDA9
FDE5  20 F0 FD JSR sub_FDF0            
FDE8  9D 10 06 STA $0610,X             
FDEB  98       TYA                     
FDEC  9D FA 05 STA $05FA,X             
FDEF  60       RTS                     

sub_FDF0:  ; 1 xrefs: FDE5
FDF0  A5 97    LDA $97                 
FDF2  D0 0D    BNE loc_FE01            
FDF4  A5 67    LDA $67                 
FDF6  18       CLC                     
FDF7  7D 08 05 ADC $0508,X             
FDFA  A8       TAY                     
FDFB  A5 66    LDA $66                 
FDFD  7D F2 04 ADC $04F2,X             
FE00  60       RTS                     

loc_FE01:  ; 1 xrefs: FDF2
FE01  BC 08 05 LDY $0508,X             
FE04  BD F2 04 LDA $04F2,X             
FE07  60       RTS                     

loc_FE08:  ; 0 xrefs: 
FE08  A5 97    LDA $97                 
FE0A  D0 0F    BNE loc_FE1B            
FE0C  BD FA 05 LDA $05FA,X             
FE0F  38       SEC                     
FE10  E5 67    SBC $67                 
FE12  A8       TAY                     
FE13  BD 10 06 LDA $0610,X             
FE16  E5 66    SBC $66                 
FE18  4C 21 FE JMP loc_FE21            

loc_FE1B:  ; 1 xrefs: FE0A
FE1B  BD 10 06 LDA $0610,X             
FE1E  BC FA 05 LDY $05FA,X             

loc_FE21:  ; 1 xrefs: FE18
FE21  9D F2 04 STA $04F2,X             
FE24  98       TYA                     
FE25  9D 08 05 STA $0508,X             
FE28  A5 97    LDA $97                 
FE2A  F0 29    BEQ loc_FE55            
FE2C  BD 26 06 LDA $0626,X             
FE2F  38       SEC                     
FE30  E5 67    SBC $67                 
FE32  A8       TAY                     
FE33  BD 3C 06 LDA $063C,X             
FE36  E5 66    SBC $66                 
FE38  85 01    STA $01                 
FE3A  BD 3C 06 LDA $063C,X             
FE3D  38       SEC                     
FE3E  E5 66    SBC $66                 
FE40  0A       ASL A                   
FE41  0A       ASL A                   
FE42  0A       ASL A                   
FE43  0A       ASL A                   
FE44  85 00    STA $00                 
FE46  98       TYA                     
FE47  38       SEC                     
FE48  E5 00    SBC $00                 
FE4A  9D C6 04 STA $04C6,X             
FE4D  A5 01    LDA $01                 
FE4F  E9 00    SBC #$00                
FE51  9D B0 04 STA $04B0,X             
FE54  60       RTS                     

loc_FE55:  ; 1 xrefs: FE2A
FE55  BD 26 06 LDA $0626,X             
FE58  9D C6 04 STA $04C6,X             
FE5B  BD 3C 06 LDA $063C,X             
FE5E  9D B0 04 STA $04B0,X             
FE61  60       RTS                     

loc_FE62:  ; 0 xrefs: 
FE62  85 24    STA $24                 
FE64  84 26    STY $26                 
FE66  AD 08 05 LDA $0508               
FE69  38       SEC                     
FE6A  FD 08 05 SBC $0508,X             
FE6D  85 01    STA $01                 
FE6F  A9 00    LDA #$00                
FE71  85 00    STA $00                 
FE73  85 03    STA $03                 
FE75  A5 24    LDA $24                 
FE77  85 02    STA $02                 
FE79  20 EF F1 JSR sub_F1EF            
FE7C  A5 04    LDA $04                 
FE7E  9D 76 05 STA $0576,X             
FE81  A5 05    LDA $05                 
FE83  9D 60 05 STA $0560,X             
FE86  AD C6 04 LDA $04C6               
FE89  38       SEC                     
FE8A  FD C6 04 SBC $04C6,X             
FE8D  85 01    STA $01                 
FE8F  A9 00    LDA #$00                
FE91  85 00    STA $00                 
FE93  85 03    STA $03                 
FE95  A5 24    LDA $24                 
FE97  85 02    STA $02                 
FE99  20 EF F1 JSR sub_F1EF            
FE9C  A5 04    LDA $04                 
FE9E  9D 4A 05 STA $054A,X             
FEA1  A5 05    LDA $05                 
FEA3  18       CLC                     
FEA4  65 26    ADC $26                 
FEA6  9D 34 05 STA $0534,X             
FEA9  60       RTS                     

loc_FEAA:  ; 0 xrefs: 
FEAA  20 F6 FC JSR sub_FCF6            
FEAD  A9 01    LDA #$01                
FEAF  9D 00 04 STA $0400,X             
FEB2  9D FA 05 STA $05FA,X             
FEB5  A9 00    LDA #$00                
FEB7  9D 10 06 STA $0610,X             
FEBA  9D 9A 04 STA $049A,X             
FEBD  4C 86 FD JMP loc_FD86            

loc_FEC0:  ; 0 xrefs: 
FEC0  8A       TXA                     
FEC1  38       SEC                     
FEC2  E9 06    SBC #$06                
FEC4  29 07    AND #$07                
FEC6  A8       TAY                     
FEC7  B9 D8 FE LDA $FED8,Y             
FECA  A0 00    LDY #$00                
FECC  E0 0E    CPX #$0E                
FECE  90 01    BCC loc_FED1            
FED0  C8       INY                     

loc_FED1:  ; 1 xrefs: FECE
FED1  19 17 01 ORA $0117,Y             
FED4  99 17 01 STA $0117,Y             
FED7  60       RTS                     

; ==== data $FED8..$FEDF  (8 bytes) ====
FED8  01 02 04 08 10 20 40 80                          |..... @.

loc_FEE0:  ; 0 xrefs: 
FEE0  8A       TXA                     
FEE1  38       SEC                     
FEE2  E9 06    SBC #$06                
FEE4  29 07    AND #$07                
FEE6  A8       TAY                     
FEE7  B9 F8 FE LDA $FEF8,Y             
FEEA  A0 00    LDY #$00                
FEEC  E0 0E    CPX #$0E                
FEEE  90 01    BCC loc_FEF1            
FEF0  C8       INY                     

loc_FEF1:  ; 1 xrefs: FEEE
FEF1  39 17 01 AND $0117,Y             
FEF4  99 17 01 STA $0117,Y             
FEF7  60       RTS                     

; ==== data $FEF8..$FEFF  (8 bytes) ====
FEF8  FE FD FB F7 EF DF BF 7F                          |........

loc_FF00:  ; 0 xrefs: 
FF00  DE FA 05 DEC $05FA,X             
FF03  D0 32    BNE loc_FF37            
FF05  9D FA 05 STA $05FA,X             
FF08  A9 00    LDA #$00                
FF0A  85 00    STA $00                 
FF0C  98       TYA                     
FF0D  10 02    BPL loc_FF11            
FF0F  C6 00    DEC $00                 

loc_FF11:  ; 1 xrefs: FF0D
FF11  18       CLC                     
FF12  6D 08 05 ADC $0508               
FF15  85 02    STA $02                 
FF17  A9 00    LDA #$00                
FF19  65 00    ADC $00                 
FF1B  F0 05    BEQ loc_FF22            
FF1D  AD 08 05 LDA $0508               
FF20  85 02    STA $02                 

loc_FF22:  ; 1 xrefs: FF1B
FF22  AD C6 04 LDA $04C6               
FF25  85 03    STA $03                 
FF27  BD 08 05 LDA $0508,X             
FF2A  85 00    STA $00                 
FF2C  BD C6 04 LDA $04C6,X             
FF2F  85 01    STA $01                 
FF31  20 E2 F6 JSR sub_F6E2            
FF34  9D E4 05 STA $05E4,X             

loc_FF37:  ; 1 xrefs: FF03
FF37  BD E4 05 LDA $05E4,X             
FF3A  38       SEC                     
FF3B  FD CE 05 SBC $05CE,X             
FF3E  F0 21    BEQ loc_FF61            
FF40  A8       TAY                     
FF41  18       CLC                     
FF42  69 04    ADC #$04                
FF44  C9 09    CMP #$09                
FF46  90 13    BCC loc_FF5B            
FF48  98       TYA                     
FF49  C9 80    CMP #$80                
FF4B  90 07    BCC loc_FF54            
FF4D  DE CE 05 DEC $05CE,X             
FF50  DE CE 05 DEC $05CE,X             
FF53  60       RTS                     

loc_FF54:  ; 1 xrefs: FF4B
FF54  FE CE 05 INC $05CE,X             
FF57  FE CE 05 INC $05CE,X             
FF5A  60       RTS                     

loc_FF5B:  ; 1 xrefs: FF46
FF5B  BD E4 05 LDA $05E4,X             
FF5E  9D CE 05 STA $05CE,X             

loc_FF61:  ; 1 xrefs: FF3E
FF61  60       RTS                     

loc_FF62:  ; 0 xrefs: 
FF62  BD 08 05 LDA $0508,X             
FF65  85 00    STA $00                 
FF67  BD C6 04 LDA $04C6,X             
FF6A  85 01    STA $01                 
FF6C  AD 08 05 LDA $0508               
FF6F  85 02    STA $02                 
FF71  AD C6 04 LDA $04C6               
FF74  85 03    STA $03                 
FF76  BD F2 04 LDA $04F2,X             
FF79  85 04    STA $04                 
FF7B  BD B0 04 LDA $04B0,X             
FF7E  85 05    STA $05                 
FF80  A9 00    LDA #$00                
FF82  85 06    STA $06                 
FF84  85 07    STA $07                 
FF86  4C 90 F6 JMP loc_F690            

; ==== data $FF89..$FFA1  (25 bytes) ====
FF89  92 F6 0A 00 00 00 00 FF 6A 14 00 00 80 00 00 FF  |........j.......
FF99  02 28 0C 00 00 00 00 FD 30                       |.(......0

loc_FFA2:  ; 0 xrefs: 
FFA2  4C 50 00 JMP $0050               

loc_FFA5:  ; 0 xrefs: 
FFA5  00 00    BRK #$00                

; ==== data $FFA7..$FFF1  (75 bytes) ====
FFA7  07 FF 44 C0 00 00 00 00 00 FF 68 80 6C 00 00 00  |..D.......h.l...
FFB7  20 FF 00 3A 33 00 00 00 00 FF 07 04 41 00 00 00  | ..:3.......A...
FFC7  F2 FF 40 14 24 00 00 00 00 FF 09 54 24 00 00 00  |..@.$......T$...
FFD7  00 FF 44 00 04 00 00 00 00 00 00 00 00 00 00 00  |..D.............
FFE7  00 00 00 00 00 00 00 00 00 00 00                 |...........

loc_FFF2:  ; 0 xrefs: 
FFF2  00 00    BRK #$00                

; ==== data $FFF4..$FFFF  (12 bytes) ====
FFF4  38 02 01 06 00 BF C7 E9 B9 E5 40 E6              |8.........@.