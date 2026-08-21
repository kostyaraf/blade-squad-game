
loc_8000:  ; 0 xrefs: 
8000  4C 03 80 JMP loc_8003            

loc_8003:  ; 1 xrefs: 8000
8003  A5 27    LDA $27                 
8005  C9 05    CMP #$05                
8007  B0 39    BCS loc_8042            

loc_8009:  ; 0 xrefs: 
8009  20 18 BF JSR sub_BF18            

loc_800C:  ; 0 xrefs: 
800C  A9 00    LDA #$00                
800E  8D 1F 01 STA $011F               
8011  8D 66 01 STA $0166               
8014  8D 67 01 STA $0167               
8017  EE 19 01 INC $0119               
801A  A2 06    LDX #$06                

loc_801C:  ; 1 xrefs: 8040
801C  BD 00 04 LDA $0400,X             
801F  F0 1C    BEQ loc_803D            

loc_8021:  ; 0 xrefs: 
8021  20 34 81 JSR sub_8134            

loc_8024:  ; 0 xrefs: 
8024  B0 4F    BCS loc_8075            
8026  BD B8 05 LDA $05B8,X             
8029  D0 18    BNE loc_8043            

loc_802B:  ; 7 xrefs: 804B 804F 8055 8059 8061 8069 8070
802B  A5 2A    LDA $2A                 

loc_802D:  ; 0 xrefs: 
802D  F0 0B    BEQ loc_803A            

loc_802F:  ; 0 xrefs: 
802F  BD 00 04 LDA $0400,X             

loc_8032:  ; 0 xrefs: 
8032  C9 03    CMP #$03                
8034  F0 04    BEQ loc_803A            
8036  C9 04    CMP #$04                

loc_8038:  ; 0 xrefs: 
8038  D0 03    BNE loc_803D            

loc_803A:  ; 2 xrefs: 802D 8034
803A  20 7A 80 JSR sub_807A            

loc_803D:  ; 4 xrefs: 801F 8038 8072 8078
803D  E8       INX                     
803E  E0 16    CPX #$16                

loc_8040:  ; 0 xrefs: 
8040  D0 DA    BNE loc_801C            

loc_8042:  ; 1 xrefs: 8007
8042  60       RTS                     

loc_8043:  ; 1 xrefs: 8029
8043  DE B8 05 DEC $05B8,X             
8046  BD 00 04 LDA $0400,X             
8049  C9 4F    CMP #$4F                
804B  B0 DE    BCS loc_802B            
804D  C9 38    CMP #$38                
804F  F0 DA    BEQ loc_802B            
8051  B0 18    BCS loc_806B            
8053  C9 10    CMP #$10                
8055  F0 D4    BEQ loc_802B            
8057  C9 13    CMP #$13                
8059  F0 D0    BEQ loc_802B            
805B  C9 1D    CMP #$1D                
805D  90 0C    BCC loc_806B            
805F  C9 20    CMP #$20                
8061  90 C8    BCC loc_802B            
8063  C9 2C    CMP #$2C                
8065  90 04    BCC loc_806B            
8067  C9 2F    CMP #$2F                
8069  90 C0    BCC loc_802B            

loc_806B:  ; 3 xrefs: 8051 805D 8065
806B  BD 9A 04 LDA $049A,X             
806E  C9 20    CMP #$20                
8070  B0 B9    BCS loc_802B            
8072  4C 3D 80 JMP loc_803D            

loc_8075:  ; 1 xrefs: 8024
8075  20 10 C8 JSR $C810               
8078  F0 C3    BEQ loc_803D            

sub_807A:  ; 1 xrefs: 803A
807A  BD 00 04 LDA $0400,X             
807D  20 4F C8 JSR $C84F               

; ==== data $8080..$8133  (180 bytes) ====
8080  42 80 6C 82 EA 83 0A 84 42 85 28 87 B2 87 DE 9F  |B.l.....B.(.....
8090  B8 9F 61 A0 9D A0 0B A5 5D 8A 4F 8B 86 8B 09 A3  |..a.....].O.....
80A0  2F 9E ED 8B ED 8B AA 96 D8 8B F1 9E 68 9C A5 9D  |/...........h...
80B0  79 9D 1F 9D 7D 9C E4 8D 29 8E 9D 8E 50 A6 1F A7  |y...}...)...P...
80C0  96 8F 8E 90 0D 91 A2 91 E7 92 2E 93 83 93 80 97  |................
80D0  7D 97 AD A7 93 A8 B4 A8 5C A9 5C A9 5C A9 A8 93  |}.......\.\.\...
80E0  0D 94 73 94 24 95 FB 95 7A AD 64 AD 8D AE 0E B0  |..s.$...z.d.....
80F0  C0 B0 97 B6 EC B1 0D B4 00 B5 52 B6 CB BA 9F B4  |..........R.....
8100  AD B7 A4 B9 3A 8C 89 B9 89 BC 3A 8C 0D AC 12 A3  |....:.....:.....
8110  6F 9A 45 AB 45 AB 6A 9B 8D 9B 2D AC 42 80 B2 9A  |o.E.E.j...-.B...
8120  E9 BD E9 BD E9 BD E9 BD E9 BD E9 BD BD BD BD BD  |................
8130  BD BD BD BD                                      |....

sub_8134:  ; 1 xrefs: 8021
8134  BC 00 04 LDY $0400,X             
8137  B9 12 82 LDA $8212,Y             
813A  A8       TAY                     
813B  B9 4A 81 LDA $814A,Y             
813E  85 00    STA $00                 
8140  B9 52 81 LDA $8152,Y             
8143  85 01    STA $01                 
8145  6C 00 00 JMP ($0000)             

; ==== data $8148..$8195  (78 bytes) ====
8148  18 60 5A 62 6A 48 72 7E 86 8E 81 81 81 81 81 81  |.`ZbjHr~........
8158  81 81 20 A2 81 20 BD 81 18 60 20 9E 81 20 BD 81  |.. .. ...` .. ..
8168  18 60 20 A2 81 20 D4 81 18 60 BD F2 04 1D B0 04  |.` .. ...`......
8178  D0 02 18 60 38 60 20 A2 81 20 D0 81 18 60 20 9A  |...`8` .. ...` .
8188  81 20 EF 81 18 60 20 96 81 20 CC 81 18 60        |. ...` .. ...`

loc_8196:  ; 0 xrefs: 
8196  A0 06    LDY #$06                
8198  D0 0A    BNE loc_81A4            

loc_819A:  ; 0 xrefs: 
819A  A0 04    LDY #$04                
819C  D0 06    BNE loc_81A4            

loc_819E:  ; 0 xrefs: 
819E  A0 02    LDY #$02                
81A0  D0 02    BNE loc_81A4            

loc_81A2:  ; 0 xrefs: 
81A2  A0 00    LDY #$00                

loc_81A4:  ; 3 xrefs: 8198 819C 81A0
81A4  BD F2 04 LDA $04F2,X             
81A7  F0 13    BEQ loc_81BC            
81A9  10 09    BPL loc_81B4            
81AB  BD 08 05 LDA $0508,X             
81AE  D9 0A 82 CMP $820A,Y             
81B1  90 53    BCC loc_8206            
81B3  60       RTS                     

loc_81B4:  ; 1 xrefs: 81A9
81B4  BD 08 05 LDA $0508,X             
81B7  D9 0B 82 CMP $820B,Y             
81BA  B0 4A    BCS loc_8206            

loc_81BC:  ; 1 xrefs: 81A7
81BC  60       RTS                     

loc_81BD:  ; 0 xrefs: 
81BD  BD B0 04 LDA $04B0,X             
81C0  F0 09    BEQ loc_81CB            
81C2  10 42    BPL loc_8206            
81C4  BD C6 04 LDA $04C6,X             
81C7  C9 E0    CMP #$E0                
81C9  90 3B    BCC loc_8206            

loc_81CB:  ; 1 xrefs: 81C0
81CB  60       RTS                     

loc_81CC:  ; 0 xrefs: 
81CC  A0 06    LDY #$06                
81CE  D0 06    BNE loc_81D6            

loc_81D0:  ; 0 xrefs: 
81D0  A0 02    LDY #$02                
81D2  D0 02    BNE loc_81D6            

loc_81D4:  ; 0 xrefs: 
81D4  A0 00    LDY #$00                

loc_81D6:  ; 2 xrefs: 81CE 81D2
81D6  BD B0 04 LDA $04B0,X             
81D9  F0 13    BEQ loc_81EE            
81DB  10 09    BPL loc_81E6            
81DD  BD C6 04 LDA $04C6,X             
81E0  D9 0A 82 CMP $820A,Y             
81E3  90 21    BCC loc_8206            
81E5  60       RTS                     

loc_81E6:  ; 1 xrefs: 81DB
81E6  BD C6 04 LDA $04C6,X             
81E9  D9 0B 82 CMP $820B,Y             
81EC  B0 18    BCS loc_8206            

loc_81EE:  ; 1 xrefs: 81D9
81EE  60       RTS                     

loc_81EF:  ; 0 xrefs: 
81EF  BD B0 04 LDA $04B0,X             
81F2  F0 0A    BEQ loc_81FE            
81F4  10 10    BPL loc_8206            
81F6  BD C6 04 LDA $04C6,X             
81F9  C9 E0    CMP #$E0                
81FB  90 09    BCC loc_8206            
81FD  60       RTS                     

loc_81FE:  ; 1 xrefs: 81F2
81FE  BD C6 04 LDA $04C6,X             
8201  C9 D0    CMP #$D0                
8203  B0 01    BCS loc_8206            
8205  60       RTS                     

loc_8206:  ; 9 xrefs: 81B1 81BA 81C2 81C9 81E3 81EC 81F4 81FB 8203
8206  38       SEC                     
8207  68       PLA                     
8208  68       PLA                     
8209  60       RTS                     

; ==== data $820A..$826B  (98 bytes) ====
820A  C0 40 80 80 E0 20 F0 10 00 03 00 00 00 00 00 02  |.@... ..........
821A  01 00 03 00 00 00 00 03 02 00 00 00 04 00 04 01  |................
822A  04 07 00 00 04 00 00 06 00 04 00 05 00 00 00 05  |................
823A  05 07 04 03 00 00 00 00 06 06 06 06 03 03 03 02  |................
824A  00 00 00 06 00 00 00 04 00 03 03 03 00 03 03 03  |................
825A  04 03 03 04 04 03 00 03 03 03 03 03 03 03 03 03  |................
826A  03 03                                            |..

loc_826C:  ; 0 xrefs: 
826C  20 7E C9 JSR $C97E               
826F  79 82 A8 ADC $A882,Y             
8272  82 F3    NOP #$F3                
8274  82 95    NOP #$95                
8276  83 B3    SAX ($B3,X)             
8278  83 A9    SAX ($A9,X)             
827A  01 20    ORA ($20,X)             
827C  3A       NOP                     
827D  C8       INY                     
827E  A9 10    LDA #$10                
8280  9D E4 05 STA $05E4,X             
8283  A9 00    LDA #$00                
8285  9D CE 05 STA $05CE,X             
8288  A9 00    LDA #$00                
828A  A8       TAY                     
828B  20 06 C9 JSR $C906               
828E  A9 00    LDA #$00                
8290  A8       TAY                     
8291  20 09 C9 JSR $C909               
8294  BD 00 04 LDA $0400,X             
8297  C9 33    CMP #$33                
8299  F0 0A    BEQ loc_82A5            
829B  BD 10 06 LDA $0610,X             
829E  D0 05    BNE loc_82A5            
82A0  A9 24    LDA #$24                
82A2  20 1C C8 JSR $C81C               

loc_82A5:  ; 2 xrefs: 8299 829E
82A5  4C 66 C9 JMP $C966               

loc_82A8:  ; 0 xrefs: 
82A8  DE E4 05 DEC $05E4,X             
82AB  F0 03    BEQ loc_82B0            
82AD  4C 37 C8 JMP $C837               

loc_82B0:  ; 1 xrefs: 82AB
82B0  BD CE 05 LDA $05CE,X             
82B3  0A       ASL A                   
82B4  A8       TAY                     
82B5  B9 EB 82 LDA $82EB,Y             
82B8  85 00    STA $00                 
82BA  B9 EC 82 LDA $82EC,Y             
82BD  85 01    STA $01                 
82BF  20 28 8A JSR sub_8A28            
82C2  FE CE 05 INC $05CE,X             
82C5  BD CE 05 LDA $05CE,X             
82C8  C9 04    CMP #$04                
82CA  F0 1C    BEQ loc_82E8            
82CC  A9 10    LDA #$10                
82CE  9D E4 05 STA $05E4,X             
82D1  A9 01    LDA #$01                
82D3  20 3A C8 JSR $C83A               
82D6  BD 00 04 LDA $0400,X             
82D9  C9 33    CMP #$33                
82DB  F0 0A    BEQ loc_82E7            
82DD  BD 10 06 LDA $0610,X             
82E0  D0 05    BNE loc_82E7            
82E2  A9 24    LDA #$24                
82E4  20 1C C8 JSR $C81C               

loc_82E7:  ; 2 xrefs: 82DB 82E0
82E7  60       RTS                     

loc_82E8:  ; 1 xrefs: 82CA
82E8  4C 66 C9 JMP $C966               

; ==== data $82EB..$8339  (79 bytes) ====
82EB  00 FC FC 08 08 00 FC FC BD FA 05 D0 3F A5 98 4A  |............?..J
82FB  A8 E6 98 A5 98 29 3F 85 98 B9 69 83 F0 2E B0 04  |.....)?...i.....
830B  4A 4A 4A 4A 29 0F F0 24 A8 B9 89 83 85 10 B9 8F  |JJJJ)..$........
831B  83 85 11 20 3A 83 C9 00 F0 12 A5 10 9D 42 04 A5  |... :........B..
832B  11 9D 9A 04 A9 40 9D 16 04 4C 66 C9 4C 10 C8     |.....@...Lf.L..

loc_833A:  ; 0 xrefs: 
833A  A5 10    LDA $10                 
833C  C9 06    CMP #$06                
833E  F0 09    BEQ loc_8349            
8340  C9 0C    CMP #$0C                
8342  F0 0E    BEQ loc_8352            
8344  C9 05    CMP #$05                
8346  F0 13    BEQ loc_835B            
8348  60       RTS                     

loc_8349:  ; 1 xrefs: 833E
8349  A5 99    LDA $99                 
834B  C9 02    CMP #$02                
834D  F0 15    BEQ loc_8364            
834F  A5 10    LDA $10                 
8351  60       RTS                     

loc_8352:  ; 1 xrefs: 8342
8352  A5 A2    LDA $A2                 
8354  C9 01    CMP #$01                
8356  F0 0C    BEQ loc_8364            
8358  A5 10    LDA $10                 
835A  60       RTS                     

loc_835B:  ; 1 xrefs: 8346
835B  A5 55    LDA $55                 
835D  C9 03    CMP #$03                
835F  F0 03    BEQ loc_8364            
8361  A5 10    LDA $10                 
8363  60       RTS                     

loc_8364:  ; 3 xrefs: 834D 8356 835F
8364  A9 00    LDA #$00                
8366  85 10    STA $10                 
8368  60       RTS                     

; ==== data $8369..$83A4  (60 bytes) ====
8369  20 03 00 50 04 00 30 01 00 20 05 00 30 01 00 40  | ..P..0.. ..0..@
8379  03 00 20 05 00 10 03 00 20 04 00 30 05 00 10 00  |.. ..... ..0....
8389  00 03 02 05 0C 06 00 00 01 06 05 07 A9 E0 9D CE  |................
8399  05 A9 00 A8 20 09 C9 9D E4 05 9D 68              |.... ......h

loc_83A5:  ; 0 xrefs: 
83A5  06 A0    ASL $A0                 
83A7  F8       SED                     
83A8  20 88 C8 JSR $C888               
83AB  10 03    BPL loc_83B0            
83AD  FE E4 05 INC $05E4,X             

loc_83B0:  ; 1 xrefs: 83AB
83B0  4C 66 C9 JMP $C966               

; ==== data $83B3..$870D  (859 bytes) ====
83B3  DE CE 05 D0 03 4C 10 C8 BD E4 05 F0 0E A9 00 A0  |.....L..........
83C3  F8 20 48 C9 30 0D DE E4 05 F0 08 20 D0 9B BD 68  |. H.0...... ...h
83D3  06 D0 13 A9 40 20 0C C9 C9 03 D0 07 A9 03 A0 00  |....@ ..........
83E3  20 09 C9 20 F4 C8 60 BD 8C 05 D0 1A 20 A8 C9 BD  | .. ..`..... ...
83F3  9A 04 29 0F A8 B9 01 84 9D 42 04 4C 66 C9 03 02  |..)......B.Lf...
8403  04 01 BE 0C 05 06 60 20 7E C9 19 84 49 84 4A 84  |......` ~...I.J.
8413  77 84 D0 84 F1 84 A4 53 B9 36 BE 25 56 D0 18 A9  |w......S.6.%V...
8423  10 9D 16 04 A5 53 0A A8 B9 3D 84 9D FA 05 B9 3E  |.....S...=.....>
8433  84 9D 10 06 4C 66 C9 4C 10 C8 21 8E 21 8E 25 8E  |....Lf.L..!.!.%.
8443  24 CE 25 0E 20 8E 60 A9 04 85 27 AD 2C 04 29 7F  |$.%. .`...'.,.).
8453  8D 2C 04 A9 04 8D 42 04 BD 08 05 8D 08 05 A9 01  |.,....B.........
8463  85 4E 85 58 A9 00 9D E4 05 20 3D C8 A9 2C 20 1C  |.N.X..... =.., .
8473  C8 4C 66 C9 BD E4 05 0A A8 B9 0A 85 85 00 B9 0B  |.Lf.............
8483  85 85 01 BD FA 05 85 10 BD 10 06 85 11 86 25 A0  |..............%.
8493  00 20 40 C8 A5 11 20 49 C8 A5 10 20 49 C8 A9 03  |. @... I... I...
84A3  85 02 B1 00 20 49 C8 C8 C6 02 10 F6 20 46 C8 A5  |.... I...... F..
84B3  11 18 69 20 85 11 A5 10 69 00 85 10 C0 10 D0 D1  |..i ....i.......
84C3  A6 25 FE E4 05 A9 10 9D 26 06 4C 66 C9 BD E4 05  |.%......&.Lf....
84D3  C9 02 D0 05 A9 00 8D 42 04 BD E4 05 C9 04 F0 0B  |.......B........
84E3  DE 26 06 D0 05 A9 03 9D 8C 05 60 4C 66 C9 A5 CC  |.&........`Lf...
84F3  F0 01 60 A9 06 85 1A A9 00 A9 01 85 79 A5 53 18  |..`.........y.S.
8503  69 06 85 9C 4C 10 C8 22 85 32 85 22 85 12 85 08  |i...L..".2."....
8513  09 0A 0B 08 09 0A 0B 08 09 0A 0B 08 09 0A 0B 08  |................
8523  0C 0D 0B 08 0C 0D 0B 08 0C 0D 0B 08 0C 0D 0B 0E  |................
8533  00 00 0F 0E 00 00 0F 0E 00 00 0F 0E 00 00 0F 20  |............... 
8543  7E C9 51 85 49 84 FD 85 4A 86 D2 86 E7 86 BD 9A  |~.Q.I...J.......
8553  04 F0 09 A4 53 B9 36 BE 25 5B D0 25 A9 10 9D 16  |....S.6.%[.%....
8563  04 A5 53 0A A8 B9 87 85 85 00 B9 88 85 85 01 A5  |..S.............
8573  9C 0A A8 B1 00 9D FA 05 C8 B1 00 9D 10 06 4C 66  |..............Lf
8583  C9 4C 10 C8 93 85 A1 85 B1 85 BF 85 CD 85 E1 85  |.L..............
8593  25 E0 21 FE 25 FE 21 E0 25 E0 21 FE 25 FE 21 FE  |%.!.%.!.%.!.%.!.
85A3  23 20 21 E0 25 60 23 20 25 E0 23 3E 25 FE 20 FE  |# !.%`# %.#>%. .
85B3  21 FE 21 FE 21 E0 25 E0 21 FE 21 FE 24 FE 23 3E  |!.!.!.%.!.!.$.#>
85C3  25 FE 20 E0 24 E0 20 BE 25 FE 25 E0 21 E0 25 E0  |%. .$. .%.%.!.%.
85D3  25 E0 24 E0 22 3E 21 FE 20 FE 20 BE 21 FE 24 FE  |%.$.">!. . .!.$.
85E3  24 FE 20 BE 24 FE 20 A0 24 E0 25 E0 24 E0 25 E0  |$. .$. .$.%.$.%.
85F3  24 E0 25 E0 24 E0 20 BE 21 FE A9 04 85 27 AD 2C  |$.%.$. .!....'.,
8603  04 29 7F 8D 2C 04 A9 01 85 2A 85 4E 85 58 A5 53  |.)..,....*.N.X.S
8613  C9 05 D0 04 A5 9C F0 1F A5 87 C9 06 F0 1E C9 09  |................
8623  F0 1A C9 04 F0 16 A5 9C 85 17 E6 17 20 D0 C8 90  |............ ...
8633  03 20 3D C8 4C 66 C9 A9 00 8D 42 04 A9 20 9D 26  |. =.Lf....B.. .&
8643  06 A9 05 9D 8C 05 60 FE 26 06 BD 26 06 29 07 D0  |......`.&..&.)..
8653  05 A9 32 20 1C C8 BD 26 06 29 03 F0 01 60 BD FA  |..2 ...&.)...`..
8663  05 85 10 BD 10 06 85 11 A0 00 84 12 84 13 BD E4  |................
8673  05 29 01 D0 07 A0 14 84 12 C8 84 13 86 25 20 0E  |.)...........% .
8683  87 A6 25 BD E4 05 C9 07 F0 3D 29 01 F0 39 A0 12  |..%......=)..9..
8693  84 12 C8 84 13 BD 10 06 38 E9 20 9D 10 06 85 11  |........8. .....
86A3  BD FA 05 E9 00 9D FA 05 85 10 C9 1F D0 14 A5 11  |................
86B3  C9 E0 D0 0E A9 23 9D FA 05 85 10 A9 A0 9D 10 06  |.....#..........
86C3  85 11 86 25 20 0E 87 A6 25 FE E4 05 4C 66 C9 BD  |...% ...%...Lf..
86D3  E4 05 C9 08 F0 06 A9 03 9D 8C 05 60 A9 20 9D 26  |...........`. .&
86E3  06 4C 66 C9 DE 26 06 D0 21 A9 06 85 1A E6 9C 20  |.Lf..&..!...... 
86F3  94 C8 90 13 A9 01 85 79 A9 02 85 AD A0 00 A5 53  |.......y.......S
8703  C9 05 F0 01 A8 84 9C 4C 10 C8 60                 |.......L..`

loc_870E:  ; 0 xrefs: 
870E  20 40 C8 JSR $C840               
8711  A5 11    LDA $11                 
8713  20 49 C8 JSR $C849               
8716  A5 10    LDA $10                 
8718  20 49 C8 JSR $C849               
871B  A5 12    LDA $12                 
871D  20 49 C8 JSR $C849               
8720  A5 13    LDA $13                 
8722  20 49 C8 JSR $C849               
8725  4C 46 C8 JMP $C846               

; ==== data $8728..$87A5  (126 bytes) ====
8728  20 7E C9 31 87 5D 87 6A 87 20 AB C9 A5 9C 18 69  | ~.1.].j. .....i
8738  50 8D 0F 04 A4 9C B9 9A 87 8D 17 05 B9 A0 87 8D  |P...............
8748  D5 04 B9 A6 87 8D 51 04 B9 AC 87 8D 6A 01 A9 01  |......Q.....j...
8758  85 4E 4C 66 C9 AD 42 04 D0 01 60 A9 04 85 27 4C  |.NLf..B...`...'L
8768  66 C9 A5 1C 29 03 D0 19 A9 23 20 1C C8 AD A9 04  |f...)....# .....
8778  18 69 04 8D A9 04 20 C4 C8 AD A9 04 CD 6A 01 F0  |.i.... ......j..
8788  01 60 A9 03 85 27 A9 00 85 4E 8D 6A 01 85 5F 4C  |.`...'...N.j.._L
8798  10 C8 D8 80 D8 D8 C0 C0 48 80 90 8D 80 60        |........H....`

loc_87A6:  ; 0 xrefs: 
87A6  BF A6 C9 LAX $C9A6,Y             
87A9  D9 E7 ED CMP $EDE7,Y             
87AC  30 30    BMI loc_87DE            
87AE  30 40    BMI loc_87F0            
87B0  40       RTI                     

; ==== data $87B1..$87DD  (45 bytes) ====
87B1  40 20 7E C9 BB 87 5D 87 6A 87 20 AB C9 A9 B7 8D  |@ ~...].j. .....
87C1  51 04 A5 53 A8 18 69 56 8D 0F 04 B9 E5 87 8D 17  |Q..S..iV........
87D1  05 B9 EB 87 8D D5 04 B9 F1 87 8D 6A 01           |...........j.

loc_87DE:  ; 1 xrefs: 87AC
87DE  A9 01    LDA #$01                
87E0  85 4E    STA $4E                 
87E2  4C 66 C9 JMP $C966               

; ==== data $87E5..$87EF  (11 bytes) ====
87E5  D0 D0 D0 D0 D0 D0 80 80 80 80 80                 |...........

loc_87F0:  ; 1 xrefs: 87AE
87F0  80 20    NOP #$20                
87F2  20 20 20 JSR $2020               
87F5  20 20 A9 JSR sub_A920            
87F8  01 85    ORA ($85,X)             
87FA  4E 86 25 LSR $2586               
87FD  20 D5 C9 JSR $C9D5               
8800  A6 25    LDX $25                 
8802  A9 01    LDA #$01                
8804  20 3A C8 JSR $C83A               
8807  A9 10    LDA #$10                
8809  9D E4 05 STA $05E4,X             
880C  A9 00    LDA #$00                
880E  9D FA 05 STA $05FA,X             
8811  BD 00 04 LDA $0400,X             
8814  C9 55    CMP #$55                
8816  F0 0A    BEQ loc_8822            
8818  C9 54    CMP #$54                
881A  F0 06    BEQ loc_8822            
881C  A5 53    LDA $53                 
881E  C9 05    CMP #$05                
8820  F0 03    BEQ loc_8825            

loc_8822:  ; 2 xrefs: 8816 881A
8822  20 3D C8 JSR $C83D               

loc_8825:  ; 1 xrefs: 8820
8825  A9 2D    LDA #$2D                
8827  20 1C C8 JSR $C81C               
882A  4C 66 C9 JMP $C966               

; ==== data $882D..$8A27  (507 bytes) ====
882D  DE E4 05 D0 2E A9 10 9D E4 05 A9 01 20 3A C8 BD  |............ :..
883D  FA 05 0A A8 B9 63 88 85 00 B9 64 88 85 01 20 28  |.....c....d... (
884D  8A FE FA 05 BD FA 05 C9 07 D0 08 A9 00 9D FA 05  |................
885D  4C 66 C9 4C 37 C8 00 00 F4 F4 0C 0C 08 F8 F8 08  |Lf.L7...........
886D  00 10 10 00 A5 CC D0 1D AD 2C 04 29 7F 8D 2C 04  |.........,.)..,.
887D  A9 10 85 2F A9 05 85 27 A9 00 9D 42 04 A9 34 9D  |.../...'...B..4.
888D  FA 05 4C 66 C9 4C 37 C8 A5 27 C9 05 D0 01 60 A9  |..Lf.L7..'....`.
889D  04 85 27 DE FA 05 D0 F6 BD 00 04 C9 55 D0 03 20  |..'.........U.. 
88AD  3D C8 A5 53 C9 05 F0 13 20 3D C8 A9 10 20 1C C8  |=..S.... =... ..
88BD  E6 9F 20 31 C8 20 66 C9 4C 66 C9 A9 04 85 30 A9  |.. 1. f.Lf....0.
88CD  06 85 27 A9 34 9D FA 05 4C 66 C9 A5 27 C9 06 D0  |..'.4...Lf..'...
88DD  01 60 A9 04 85 27 DE FA 05 D0 B3 4C 66 C9 A5 CD  |.`...'.....Lf...
88ED  F0 01 60 A5 53 C9 05 F0 27 A9 00 85 27 85 79 85  |..`.S...'...'.y.
88FD  AD 20 22 BE A5 53 C9 04 D0 0B A9 05 85 18 A9 17  |. "..S..........
890D  85 19 4C 13 C8 A9 05 85 18 A9 00 85 19 4C 13 C8  |..L..........L..
891D  E6 9C A5 9C C9 05 F0 0B C9 06 F0 E9 A9 06 85 1A  |................
892D  4C 13 C8 A9 06 85 18 A9 1F 85 19 4C 10 C8 A5 CC  |L..........L....
893D  D0 35 20 3D C8 A9 BE 9D 42 04 A9 04 9D 9A 04 A9  |.5 =....B.......
894D  40 9D 16 04 A9 80 9D 08 05 A9 40 9D C6 04 A9 02  |@.........@.....
895D  85 5F A9 01 A0 00 20 09 C9 A9 00 9D CE 05 9D F2  |._.... .........
896D  04 9D B0 04 4C 66 C9 4C 37 C8 20 3D 8B BD CE 05  |....Lf.L7. =....
897D  D0 14 A9 08 A0 02 20 4E C9 30 03 4C F4 C8 A9 01  |...... N.0.L....
898D  9D CE 05 4C 81 C9 60 A5 CD F0 01 60 A9 00 9D 42  |...L..`....`...B
899D  04 A9 01 85 58 AD 2C 04 29 7F 8D 2C 04 A9 10 85  |....X.,.)..,....
89AD  2F A9 05 85 27 A9 34 9D FA 05 4C 66 C9 A5 27 C9  |/...'.4...Lf..'.
89BD  05 D0 01 60 A9 04 85 27 DE FA 05 F0 01 60 20 3D  |...`...'.....` =
89CD  C8 4C 66 C9 A5 87 85 3E A9 0D 85 87 A5 53 18 69  |.Lf....>.....S.i
89DD  1B 20 BE C8 4C 66 C9 A5 90 F0 01 60 A9 80 9D CE  |. ..Lf.....`....
89ED  05 4C 66 C9 DE CE 05 F0 01 60 A9 01 85 AD A9 00  |.Lf......`......
89FD  85 79 A5 3E 85 87 A4 53 B9 36 BE 85 00 A5 56 25  |.y.>...S.6....V%
8A0D  00 25 5B D0 07 A9 07 85 1A 4C 10 C8 A9 00 85 AD  |.%[......L......
8A1D  A9 03 85 18 A9 17 85 19 4C 10 C8                 |........L..

sub_8A28:  ; 1 xrefs: 82BF
8A28  A9 00    LDA #$00                
8A2A  85 02    STA $02                 
8A2C  85 03    STA $03                 
8A2E  A5 00    LDA $00                 
8A30  10 02    BPL loc_8A34            
8A32  C6 02    DEC $02                 

loc_8A34:  ; 1 xrefs: 8A30
8A34  BD 08 05 LDA $0508,X             
8A37  18       CLC                     
8A38  65 00    ADC $00                 
8A3A  9D 08 05 STA $0508,X             
8A3D  BD F2 04 LDA $04F2,X             
8A40  65 02    ADC $02                 
8A42  9D F2 04 STA $04F2,X             
8A45  A5 01    LDA $01                 
8A47  10 02    BPL loc_8A4B            
8A49  C6 03    DEC $03                 

loc_8A4B:  ; 1 xrefs: 8A47
8A4B  BD C6 04 LDA $04C6,X             
8A4E  18       CLC                     
8A4F  65 01    ADC $01                 
8A51  9D C6 04 STA $04C6,X             
8A54  BD B0 04 LDA $04B0,X             
8A57  65 03    ADC $03                 
8A59  9D B0 04 STA $04B0,X             
8A5C  60       RTS                     

; ==== data $8A5D..$8AEF  (147 bytes) ====
8A5D  20 7E C9 6C 8A 96 8A 97 8A B7 8A CA 8A E2 8A 20  | ~.l........... 
8A6D  9F C9 BD 08 05 18 69 08 9D 08 05 BD F2 04 69 00  |......i.......i.
8A7D  9D F2 04 BD 9A 04 A8 B9 36 BE 25 3B D0 03 4C 66  |........6.%;..Lf
8A8D  C9 A9 04 9D 8C 05 4C AB C9 60 BD 9A 04 A8 B9 36  |......L..`.....6
8A9D  BE 45 3B 85 3B A9 01 20 3A C8 20 F0 8A A9 10 9D  |.E;.;.. :. .....
8AAD  CE 05 A9 24 20 1C C8 4C 66 C9 20 37 C8 DE CE 05  |...$ ..Lf. 7....
8ABD  D0 0A A9 05 9D 8C 05 A9 00 9D 42 04 60 A5 97 F0  |..........B.`...
8ACD  0E BD C6 04 C9 B8 90 01 60 20 F0 8A 4C 66 C9 20  |........` ..Lf. 
8ADD  F0 8A 4C 10 C8 BD C6 04 C9 B8 B0 01 60 A9 04 9D  |..L.........`...
8AED  8C 05 60                                         |..`

loc_8AF0:  ; 0 xrefs: 
8AF0  BC C6 04 LDY $04C6,X             
8AF3  BD 08 05 LDA $0508,X             
8AF6  38       SEC                     
8AF7  E9 08    SBC #$08                
8AF9  20 A9 C8 JSR $C8A9               
8AFC  BD C6 04 LDA $04C6,X             
8AFF  18       CLC                     
8B00  69 08    ADC #$08                
8B02  A8       TAY                     
8B03  BD 08 05 LDA $0508,X             
8B06  38       SEC                     
8B07  E9 08    SBC #$08                
8B09  20 A6 C8 JSR $C8A6               
8B0C  20 1E 8B JSR sub_8B1E            
8B0F  BC C6 04 LDY $04C6,X             
8B12  BD 08 05 LDA $0508,X             
8B15  38       SEC                     
8B16  E9 08    SBC #$08                
8B18  20 A6 C8 JSR $C8A6               
8B1B  4C 1E 8B JMP sub_8B1E            

sub_8B1E:  ; 2 xrefs: 8B0C 8B1B
8B1E  86 25    STX $25                 
8B20  20 40 C8 JSR $C840               
8B23  A5 08    LDA $08                 
8B25  20 49 C8 JSR $C849               
8B28  A5 09    LDA $09                 
8B2A  20 49 C8 JSR $C849               
8B2D  A9 00    LDA #$00                
8B2F  20 49 C8 JSR $C849               
8B32  A9 00    LDA #$00                
8B34  20 49 C8 JSR $C849               
8B37  20 46 C8 JSR $C846               
8B3A  A6 25    LDX $25                 
8B3C  60       RTS                     

loc_8B3D:  ; 0 xrefs: 
8B3D  A5 1C    LDA $1C                 
8B3F  29 03    AND #$03                
8B41  D0 0B    BNE loc_8B4E            
8B43  FE 2C 04 INC $042C,X             
8B46  BD 2C 04 LDA $042C,X             
8B49  29 03    AND #$03                
8B4B  9D 2C 04 STA $042C,X             

loc_8B4E:  ; 1 xrefs: 8B41
8B4E  60       RTS                     

; ==== data $8B4F..$8C38  (234 bytes) ====
8B4F  BD 8C 05 D0 19 20 AB C9 BD 9A 04 A8 B9 36 BE 25  |..... .......6.%
8B5F  3B D0 08 A9 40 9D CE 05 4C 66 C9 4C 10 C8 DE CE  |;...@...Lf.L....
8B6F  05 F0 01 60 A9 41 20 1C C8 BD 9A 04 A8 B9 36 BE  |...`.A .......6.
8B7F  45 3B 85 3B 4C 10 C8 BD 8C 05 D0 2C 20 AB C9 A5  |E;.;L......, ...
8B8F  AD D0 0C A9 10 85 46 A9 F8 9D 42 04 4C 66 C9 86  |......F...B.Lf..
8B9F  25 20 6A C8 A9 04 9D 00 04 A9 10 9D 08 05 A9 80  |% j.............
8BAF  9D C6 04 A6 25 4C 10 C8 AD 08 05 C9 90 90 0D A9  |....%L..........
8BBF  01 85 4E A9 02 85 4A A9 00 85 48 60 A9 01 85 AD  |..N...J...H`....
8BCF  A9 06 85 18 A9 00 85 19 60 BD 8C 05 D0 0A 20 A2  |........`..... .
8BDF  C9 20 6E BE 2A 4C 66 C9 20 D2 C9 4C EB C8 20 7E  |. n.*Lf. ..L.. ~
8BEF  C9 F4 8B 09 8C 20 B9 BE 00 00 20 BF BE 80 FE 20  |..... .... .... 
8BFF  AD BE 03 20 5A BE 01 4C 66 C9 20 EE C8 BD E4 05  |... Z..Lf. .....
8C0F  D0 13 A9 40 20 0C C9 BD 34 05 C9 04 D0 1C 20 7C  |...@ ...4..... |
8C1F  BE 01 4C 39 8C A9 40 20 0F C9 BD 34 05 C9 FC D0  |..L9..@ ...4....
8C2F  09 BD 4A 05 D0 04 20 7C BE 00                    |..J... |..

loc_8C39:  ; 0 xrefs: 
8C39  60       RTS                     

; ==== data $8C3A..$8D1F  (230 bytes) ====
8C3A  20 7E C9 49 8C 59 8C 5F 8C CB 8C 03 8D 72 8D 20  | ~.I.Y._.....r. 
8C4A  AE C9 20 39 C9 29 1F 69 3F 9D CE 05 4C 66 C9 DE  |.. 9.).i?...Lf..
8C5A  CE 05 F0 F8 60 20 3E BE D0 FA BD 00 04 C9 45 F0  |....` >.......E.
8C6A  1F 20 BA C9 BD F2 04 1D B0 04 D0 11 BD C6 04 C9  |. ..............
8C7A  B0 B0 09 C9 10 90 05 20 AE 8D 90 2A 60 4C 10 C8  |....... ...*`L..
8C8A  20 39 C9 29 3F 85 00 A9 98 E5 00 9D C6 04 A5 29  | 9.)?..........)
8C9A  18 69 0A DD C6 04 B0 E4 20 92 8D BD 08 05 C9 18  |.i...... .......
8CAA  90 DA C9 E8 B0 D6 20 AB C9 20 75 BE 40 20 AD BE  |...... .. u.@ ..
8CBA  05 20 39 C9 4A A9 80 90 02 A9 C0 9D 2C 04 4C 66  |. 9.J.......,.Lf
8CCA  C9 DE CE 05 F0 1F BD CE 05 29 03 D0 17 A0 00 BD  |.........)......
8CDA  CE 05 29 04 F0 02 A0 80 84 00 BD 2C 04 29 7F 05  |..)........,.)..
8CEA  00 9D 2C 04 60 BD 2C 04 29 7F 9D 2C 04 20 5A BE  |..,.`.,.)..,. Z.
8CFA  7F 20 C5 BE 80 FE 4C 66 C9 BD 9A 04 C9 7F D0 3B  |. ....Lf.......;
8D0A  BD B0 04 F0 03 4C 10 C8 8A 4D 19 01 29 03 D0 28  |.....L...M..)..(
8D1A  BD F2 04 F0 10 30                                |.....0

loc_8D20:  ; 0 xrefs: 
8D20  04 A9    NOP $A9                 
8D22  00 F0    BRK #$F0                

; ==== data $8D24..$8D91  (110 bytes) ====
8D24  02 A9 40 9D 2C 04 20 C5 BE 80 FE 20 90 C9 A9 F4  |..@.,. .... ....
8D34  90 02 A9 0B A0 00 20 45 C9 10 03 20 1B C9 4C EE  |...... E... ..L.
8D44  C8 BD 00 04 C9 45 F0 1A 86 25 20 6A C8 8A A6 25  |.....E...% j...%
8D54  B0 19 AA A4 25 20 63 C9 20 C0 C9 DE FA 05 A6 25  |....% c. ......%
8D64  D0 17 20 79 82 20 AB C9 4C 7B C9 4C C0 C9 20 A8  |.. y. ..L{.L.. .
8D74  82 BD 8C 05 C9 05 D0 01 60 20 AB C9 A9 00 9D 42  |........` .....B
8D84  04 20 39 C9 29 1F 69 3F 9D CE 05 4C 6F C9        |. 9.).i?...Lo.

sub_8D92:  ; 1 xrefs: 8DAE
8D92  20 39 C9 JSR $C939               
8D95  9D 08 05 STA $0508,X             
8D98  38       SEC                     
8D99  ED 08 05 SBC $0508               
8D9C  B0 03    BCS loc_8DA1            
8D9E  20 58 C8 JSR $C858               

loc_8DA1:  ; 1 xrefs: 8D9C
8DA1  C9 10    CMP #$10                
8DA3  B0 08    BCS loc_8DAD            
8DA5  BD 08 05 LDA $0508,X             
8DA8  49 80    EOR #$80                
8DAA  9D 08 05 STA $0508,X             

loc_8DAD:  ; 1 xrefs: 8DA3
8DAD  60       RTS                     

loc_8DAE:  ; 0 xrefs: 
8DAE  20 92 8D JSR sub_8D92            
8DB1  A5 87    LDA $87                 
8DB3  48       PHA                     
8DB4  A9 0F    LDA #$0F                
8DB6  85 87    STA $87                 
8DB8  A9 07    LDA #$07                
8DBA  85 08    STA $08                 

loc_8DBC:  ; 1 xrefs: 8DD2
8DBC  A4 08    LDY $08                 
8DBE  B9 DC 8D LDA $8DDC,Y             
8DC1  48       PHA                     
8DC2  B9 DB 8D LDA $8DDB,Y             
8DC5  A8       TAY                     
8DC6  68       PLA                     
8DC7  20 88 C8 JSR $C888               
8DCA  C9 04    CMP #$04                
8DCC  D0 09    BNE loc_8DD7            
8DCE  C6 08    DEC $08                 
8DD0  C6 08    DEC $08                 
8DD2  10 E8    BPL loc_8DBC            
8DD4  18       CLC                     
8DD5  90 01    BCC loc_8DD8            

loc_8DD7:  ; 1 xrefs: 8DCC
8DD7  38       SEC                     

loc_8DD8:  ; 1 xrefs: 8DD5
8DD8  68       PLA                     
8DD9  85 87    STA $87                 
8DDB  60       RTS                     

; ==== data $8DDC..$8E0B  (48 bytes) ====
8DDC  F8 F8 F8 07 07 F8 07 07 20 7E C9 ED 8D F3 8D 21  |........ ~.....!
8DEC  8E 20 AB C9 4C 66 C9 20 C3 C9 B0 28 20 6D C8 C9  |. ..Lf. ...( m..
8DFC  40 B0 21 C9 08 90 1D 86 25 20 24 C9 20 73 C8 B0  |@.!.....% $. s..

loc_8E0C:  ; 0 xrefs: 
8E0C  11 20    ORA ($20),Y             
8E0E  27 C9    RLA $C9                 
8E10  A9 1C    LDA #$1C                

loc_8E12:  ; 0 xrefs: 
8E12  9D 00 04 STA $0400,X             
8E15  A6 25    LDX $25                 
8E17  20 7C BE JSR sub_BE7C            
8E1A  80 4C    NOP #$4C                
8E1C  66 C9    ROR $C9                 
8E1E  A6 25    LDX $25                 
8E20  60       RTS                     

; ==== data $8E21..$8EDB  (187 bytes) ====
8E21  DE E4 05 D0 FA 4C 69 C9 20 7E C9 34 8E 49 8E 72  |.....Li. ~.4.I.r
8E31  8E 92 8E 20 AD BE 0D 20 B9 BE 00 01 20 BF BE 00  |... ... .... ...
8E41  FF 20 5A BE 01 4C 66 C9 20 37 C8 20 DD BE 08 04  |. Z..Lf. 7. ....
8E51  30 14 A9 40 20 0C C9 BD 34 05 C9 04 90 05 20 B9  |0..@ ...4..... .
8E61  BE 00 04 4C F4 C8 20 81 C9 20 B9 BE 00 00 4C 66  |...L.. .. ....Lf
8E71  C9 20 E3 BE 08 04 30 03 4C 69 C9 20 06 BF FE FF  |. ....0.Li. ....
8E81  FC 30 03 4C EE C8 20 AD BE 01 20 7C BE 10 4C 66  |.0.L.. ... |..Lf
8E91  C9 DE E4 05 D0 03 4C 10 C8 4C 37 C8 A9 F2 20 A5  |......L..L7... .
8EA1  9B 20 7E C9 B1 8E C3 8E 0E 8F 20 8F 36 8F 48 8F  |. ~....... .6.H.
8EB1  20 A5 C9 20 6E BE 31 20 63 BE 02 20 7C BE 30 4C  | .. n.1 c.. |.0L
8EC1  66 C9 20 70 C8 C9 10 B0 0D DE E4 05 F0 35 20 C5  |f. p.........5 .
8ED1  BE 00 FE 4C DC 8E 20 C5 BE 80 FF                 |...L.. ....

loc_8EDC:  ; 0 xrefs: 
8EDC  20 06 BF JSR sub_BF06            
8EDF  F6 F1    INC $F1,X               
8EE1  FF 30 19 ISC $1930,X             
8EE4  A0 F8    LDY #$F8                
8EE6  20 90 C9 JSR $C990               
8EE9  90 02    BCC loc_8EED            
8EEB  A0 08    LDY #$08                

loc_8EED:  ; 1 xrefs: 8EE9
8EED  98       TYA                     
8EEE  A0 04    LDY #$04                
8EF0  20 48 C9 JSR $C948               
8EF3  30 05    BMI loc_8EFA            
8EF5  20 44 9C JSR sub_9C44            
8EF8  90 03    BCC loc_8EFD            

loc_8EFA:  ; 1 xrefs: 8EF3
8EFA  4C F1 C8 JMP $C8F1               

loc_8EFD:  ; 1 xrefs: 8EF8
8EFD  20 83 BE JSR sub_BE83            
8F00  04 4C    NOP $4C                 
8F02  7B C9 20 RRA $20C9,Y             
8F05  FD C8 20 SBC $20C8,X             
8F08  AD BE 04 LDA $04BE               
8F0B  4C 66 C9 JMP $C966               

; ==== data $8F0E..$8F62  (85 bytes) ====
8F0E  20 37 C8 C9 33 F0 01 60 20 7C BE 18 20 9F C9 4C  | 7..3..` |.. ..L
8F1E  66 C9 DE E4 05 F0 01 60 A9 F8 85 17 85 16 A9 A0  |f......`........
8F2E  85 06 20 63 8F 4C 66 C9 20 37 C8 C9 31 F0 01 60  |.. c.Lf. 7..1..`
8F3E  20 A5 C9 20 7C BE 30 4C 6F C9 DE FA 05 D0 12 20  | .. |.0Lo...... 
8F4E  1B C9 20 00 BF F6 F1 FF 10 08 20 1B C9 20 83 BE  |.. ....... .. ..
8F5E  02 60 4C 6F C9                                   |.`Lo.

sub_8F63:  ; 1 xrefs: 9198
8F63  20 90 C9 JSR $C990               
8F66  90 06    BCC loc_8F6E            
8F68  A5 06    LDA $06                 
8F6A  49 40    EOR #$40                
8F6C  85 06    STA $06                 

loc_8F6E:  ; 1 xrefs: 8F66
8F6E  20 7C 8F JSR sub_8F7C            
8F71  A0 80    LDY #$80                
8F73  20 90 C9 JSR $C990               
8F76  90 02    BCC loc_8F7A            
8F78  A0 00    LDY #$00                

loc_8F7A:  ; 1 xrefs: 8F76
8F7A  84 06    STY $06                 

sub_8F7C:  ; 1 xrefs: 8F6E
8F7C  A9 14    LDA #$14                
8F7E  85 24    STA $24                 
8F80  A9 0C    LDA #$0C                
8F82  85 26    STA $26                 
8F84  20 90 C9 JSR $C990               
8F87  A5 16    LDA $16                 
8F89  90 06    BCC loc_8F91            
8F8B  20 58 C8 JSR $C858               
8F8E  18       CLC                     
8F8F  69 01    ADC #$01                

loc_8F91:  ; 1 xrefs: 8F89
8F91  A4 17    LDY $17                 
8F93  4C E5 C8 JMP $C8E5               

; ==== data $8F96..$9054  (191 bytes) ====
8F96  20 7E C9 A5 8F B9 8F F5 8F 1E 90 30 90 36 90 20  | ~.........0.6. 
8FA6  5A BE 7F 20 AD BE 10 20 BF BE 80 FF 20 75 BE 40  |Z.. ... .... u.@
8FB6  4C 66 C9 BD 9A 04 C9 7E 90 17 20 12 BF F6 EC FF  |Lf.....~.. .....
8FC6  20 E9 BE 04 F8 20 EE C8 BD CE 05 F0 0E DE CE 05  | .... ..........
8FD6  60 20 AB C9 20 AD BE 11 4C 75 C9 A0 D8 A9 00 20  |` .. ...Lu..... 
8FE6  55 90 B0 EC 20 AD BE 12 20 75 BE 16 4C 66 C9 BD  |U... ... u..Lf..
8FF6  9A 04 C9 7E 90 DB BD CE 05 F0 10 DE CE 05 F0 03  |...~............
9006  4C 37 C8 20 7C BE 40 20 AD BE 10 DE E4 05 F0 01  |L7. |.@ ........
9016  60 20 75 BE FF 4C 69 C9 20 37 C8 BD 42 04 C9 A3  |` u..Li. 7..B...
9026  F0 01 60 20 7C BE C0 4C 66 C9 DE E4 05 F0 F8 60  |..` |..Lf......`
9036  20 37 C8 BD 42 04 C9 A4 F0 01 60 20 AD BE 10 20  | 7..B.....` ... 
9046  5A BE 7F 20 75 BE 40 20 BF BE 80 FF 4C 6F C9     |Z.. u.@ ....Lo.

sub_9055:  ; 1 xrefs: ADEA
9055  85 00    STA $00                 
9057  84 01    STY $01                 
9059  20 C3 C9 JSR $C9C3               
905C  B0 2F    BCS loc_908D            
905E  20 8D C9 JSR $C98D               
9061  B0 2A    BCS loc_908D            
9063  C0 50    CPY #$50                
9065  B0 26    BCS loc_908D            
9067  C0 28    CPY #$28                
9069  90 21    BCC loc_908C            
906B  A9 21    LDA #$21                
906D  85 24    STA $24                 
906F  A5 00    LDA $00                 
9071  A4 01    LDY $01                 
9073  20 DF C8 JSR $C8DF               
9076  B0 15    BCS loc_908D            
9078  86 25    STX $25                 
907A  A6 12    LDX $12                 
907C  A9 40    LDA #$40                
907E  A0 FE    LDY #$FE                
9080  20 CF C9 JSR $C9CF               
9083  A6 25    LDX $25                 
9085  A9 38    LDA #$38                
9087  20 1C C8 JSR $C81C               
908A  18       CLC                     
908B  60       RTS                     

loc_908C:  ; 1 xrefs: 9069
908C  38       SEC                     

loc_908D:  ; 4 xrefs: 905C 9061 9065 9076
908D  60       RTS                     

; ==== data $908E..$90FB  (110 bytes) ====
908E  20 7E C9 97 90 A5 90 E2 90 20 5A BE FF 20 6E BE  | ~....... Z.. n.
909E  6E 20 93 C9 4C 66 C9 A9 10 20 0C C9 BD 34 05 30  |n ..Lf... ...4.0
90AE  12 C9 04 90 05 20 B9 BE 00 04 20 CB BE 04 00 30  |..... .... ....0
90BE  17 10 0C 20 CB BE FC 00 10 05 20 B9 BE 00 00 20  |... ...... .... 
90CE  FC 90 20 D2 C9 4C F4 C8 20 81 C9 20 AB C9 FE 42  |.. ..L.. .. ...B
90DE  04 4C 66 C9 DE CE 05 D0 03 4C 10 C8 A9 08 A0 F8  |.Lf......L......
90EE  20 20 BF AD 64 01 F0 05 A9 80 8D A2 05 60        |  ..d........`

loc_90FC:  ; 0 xrefs: 
90FC  20 06 BF JSR sub_BF06            
90FF  F8       SED                     
9100  FF 01 10 ISC $1001,X             
9103  06 A9    ASL $A9                 
9105  00 A8    BRK #$A8                

; ==== data $9107..$9129  (35 bytes) ====
9107  4C 06 C9 4C F7 C8 BD 8C 05 D0 44 BD 9A 04 20 BD  |L..L......D... .
9117  C9 BD 9A 04 29 01 9D CE 05 20 5A BE 01 20 AE C9  |....).... Z.. ..
9127  20 66 C9                                         | f.

loc_912A:  ; 1 xrefs: 919F
912A  20 FD C8 JSR $C8FD               
912D  20 39 C9 JSR $C939               
9130  29 3F    AND #$3F                
9132  69 40    ADC #$40                
9134  9D E4 05 STA $05E4,X             
9137  20 6E BE JSR sub_BE6E            
913A  3A       NOP                     
913B  BD CE 05 LDA $05CE,X             
913E  D0 04    BNE loc_9144            
9140  A9 FE    LDA #$FE                
9142  D0 05    BNE loc_9149            

loc_9144:  ; 1 xrefs: 913E
9144  FE 42 04 INC $0442,X             
9147  A9 02    LDA #$02                

loc_9149:  ; 1 xrefs: 9142
9149  9D 34 05 STA $0534,X             
914C  A9 00    LDA #$00                
914E  9D 4A 05 STA $054A,X             
9151  20 9F BE JSR sub_BE9F            
9154  2A       ROL A                   
9155  60       RTS                     

; ==== data $9156..$9171  (28 bytes) ====
9156  BD E4 05 F0 04 DE E4 05 60 20 FD C8 A9 18 BC CE  |........` ......
9166  05 D0 06 20 0C C9 4C 72 91 20 0F C9              |... ..Lr. ..

loc_9172:  ; 0 xrefs: 
9172  20 F4 C8 JSR $C8F4               
9175  DE 52 06 DEC $0652,X             
9178  F0 22    BEQ loc_919C            
917A  BD 52 06 LDA $0652,X             
917D  C9 15    CMP #$15                
917F  D0 1A    BNE loc_919B            
9181  BC CE 05 LDY $05CE,X             
9184  D0 06    BNE loc_918C            
9186  A9 A0    LDA #$A0                
9188  A0 F8    LDY #$F8                
918A  D0 04    BNE loc_9190            

loc_918C:  ; 1 xrefs: 9184
918C  A9 60    LDA #$60                
918E  A0 FA    LDY #$FA                

loc_9190:  ; 1 xrefs: 918A
9190  85 06    STA $06                 
9192  84 17    STY $17                 
9194  A9 FA    LDA #$FA                
9196  85 16    STA $16                 
9198  20 63 8F JSR sub_8F63            

loc_919B:  ; 1 xrefs: 917F
919B  60       RTS                     

loc_919C:  ; 1 xrefs: 9178
919C  20 BA C9 JSR $C9BA               
919F  4C 2A 91 JMP loc_912A            

; ==== data $91A2..$9255  (180 bytes) ====
91A2  20 7E C9 AF 91 C3 91 12 92 60 92 A7 92 BD 9A 04  | ~.......`......
91B2  9D CE 05 20 5A BE 01 20 7C BE 1E 20 D8 92 4C 66  |... Z.. |.. ..Lf
91C2  C9 DE E4 05 F0 1E BD E4 05 C9 20 D0 16 A9 14 85  |.......... .....
91D2  24 A9 0C 85 26 A0 F6 BD CE 05 10 02 A0 FE A9 00  |$...&...........
91E2  20 E2 C8 60 20 BD 92 20 BF BE 40 FF 20 39 C9 C9  | ..` .. ..@. 9..
91F2  C0 90 03 20 1B C9 A9 00 9D 4A 05 BD CE 05 30 08  |... .....J....0.
9202  A9 FC 9D 34 05 4C 66 C9 A9 04 9D 34 05 4C 75 C9  |...4.Lf....4.Lu.
9212  BD 42 04 C9 2D F0 03 4C 37 C8 20 CB 92 20 0C C9  |.B..-..L7. .. ..
9222  BD 34 05 30 12 C9 04 90 05 20 B9 BE 00 04 20 DD  |.4.0..... .... .
9232  BE 04 05 30 1A 10 0C 20 DD BE E2 05 10 05 20 B9  |...0... ...... .
9242  BE 00 00 20 F4 C8 20 12 BF F6 F1 FF 4C F7 C8 A9  |... .. .....L...
9252  00 20 87 C9                                      |. ..

loc_9256:  ; 0 xrefs: 
9256  20 BD 92 JSR sub_92BD            
9259  20 7C BE JSR sub_BE7C            
925C  10 4C    BPL loc_92AA            
925E  78       SEI                     
925F  C9 BD    CMP #$BD                

; ==== data $9261..$92A9  (73 bytes) ====
9261  42 04 C9 30 F0 03 4C 37 C8 20 CB 92 20 0F C9 BD  |B..0..L7. .. ...
9271  34 05 10 12 C9 FB B0 05 20 B9 BE 00 FB 20 DD BE  |4....... .... ..
9281  EC 05 30 1A 10 0C 20 DD BE 10 05 10 05 20 B9 BE  |..0... ...... ..
9291  00 00 20 F4 C8 20 12 BF F6 FF F1 4C F7 C8 A9 F0  |.. .. .....L....
92A1  20 8A C9 4C 56 92 DE E4 05                       | ..LV....

loc_92AA:  ; 1 xrefs: 925C
92AA  D0 10    BNE loc_92BC            
92AC  20 39 C9 JSR $C939               
92AF  29 3F    AND #$3F                
92B1  69 3F    ADC #$3F                
92B3  9D E4 05 STA $05E4,X             
92B6  20 D8 92 JSR sub_92D8            
92B9  4C 6F C9 JMP $C96F               

loc_92BC:  ; 1 xrefs: 92AA
92BC  60       RTS                     

sub_92BD:  ; 1 xrefs: 9256
92BD  BD CE 05 LDA $05CE,X             
92C0  30 04    BMI loc_92C6            
92C2  A9 13    LDA #$13                
92C4  D0 02    BNE loc_92C8            

loc_92C6:  ; 1 xrefs: 92C0
92C6  A9 14    LDA #$14                

loc_92C8:  ; 1 xrefs: 92C4
92C8  4C 3A C8 JMP $C83A               

loc_92CB:  ; 0 xrefs: 
92CB  BD CE 05 LDA $05CE,X             
92CE  29 7F    AND #$7F                
92D0  A8       TAY                     
92D1  B9 D5 92 LDA $92D5,Y             
92D4  60       RTS                     

; ==== data $92D5..$92D7  (3 bytes) ====
92D5  28 18 11                                         |(..

sub_92D8:  ; 1 xrefs: 92B6
92D8  BD CE 05 LDA $05CE,X             
92DB  30 04    BMI loc_92E1            
92DD  A9 2C    LDA #$2C                
92DF  D0 02    BNE loc_92E3            

loc_92E1:  ; 1 xrefs: 92DB
92E1  A9 2F    LDA #$2F                

loc_92E3:  ; 1 xrefs: 92DF
92E3  9D 42 04 STA $0442,X             
92E6  60       RTS                     

; ==== data $92E7..$9369  (131 bytes) ====
92E7  BD 8C 05 D0 13 20 5A BE 04 20 AD BE 15 20 BF BE  |..... Z.. ... ..
92F7  80 FE 20 18 C9 4C 66 C9 BD E4 05 D0 24 20 3C C9  |.. ..Lf.....$ <.
9307  70 22 C9 40 B0 1E A9 25 85 24 A9 08 BC 60 05 10  |p".@...%.$...`..
9317  02 A9 F8 A0 04 20 DF C8 B0 0A A9 1E 9D E4 05 D0  |..... ..........
9327  03 DE E4 05 4C EE C8 BD 8C 05 D0 0F 20 A2 C9 20  |....L....... .. 
9337  6E BE 4E 20 B9 BE 00 01 4C 66 C9 20 CB BE 04 00  |n.N ....Lf. ....
9347  30 17 A9 24 20 0C C9 BD 34 05 C9 04 D0 05 20 B9  |0..$ ...4..... .
9357  BE 00 04 20 D2 C9 4C F4 C8 A5 79 F0 03 4C D0 B4  |... ..L...y..L..
9367  20 81 C9                                         | ..

loc_936A:  ; 0 xrefs: 
936A  A9 26    LDA #$26                
936C  9D 00 04 STA $0400,X             
936F  20 5A BE JSR sub_BE5A            
9372  FF 20 AD ISC $AD20,X             
9375  BE 16 20 LDX $2016,Y             
9378  75 BE    ADC $BE,X               
937A  80 A9    NOP #$A9                
937C  27 20    RLA $20                 
937E  1C C8 4C NOP $4CC8,X             
9381  6F C9 20 RRA $20C9               
9384  7E C9 6A ROR $6AC9,X             

; ==== data $9387..$9454  (206 bytes) ====
9387  93 8C 93 9D 93 BD 42 04 C9 51 D0 07 20 AD BE 17  |......B..Q.. ...
9397  4C 66 C9 4C 37 C8 DE CE 05 D0 03 4C 10 C8 4C 37  |Lf.L7......L..L7
93A7  C8 BD 8C 05 D0 15 BD 9A 04 9D E4 05 20 5A BE 05  |............ Z..
93B7  20 AD BE 1A 20 75 BE 28 4C 66 C9 BD CE 05 F0 14  | ... u.(Lf......
93C7  BD 42 04 C9 53 F0 03 4C 37 C8 AD 19 01 6A 90 03  |.B..S..L7....j..
93D7  DE CE 05 60 20 37 C8 C9 54 D0 2A 20 C3 C9 B0 21  |...` 7..T.* ...!
93E7  86 25 20 24 C9 20 73 C8 B0 15 20 27 C9 A9 33 9D  |.% $. s... '..3.
93F7  00 04 A9 03 9D 8C 05 A4 25 B9 E4 05 9D E4 05 A6  |........%.......
9407  25 20 75 BE FF 60 20 7E C9 16 94 1D 94 2B 94 20  |% u..` ~.....+. 
9417  AD BE 1B 4C 9D 95 20 AF 95 B0 03 4C 37 C8 FE FA  |...L.. ....L7...
9427  05 4C 66 C9 20 E8 95 20 C3 C9 90 15 DE FA 05 D0  |.Lf. .. ........
9437  0A 20 83 BE 20 20 CC C9 9D E4 05 20 C9 C9 4C 55  |. ..  ..... ..LU
9447  94 8A 29 07 A8 B9 6B 94 A8 A9 20 20 C6 C9        |..)...k...  ..

loc_9455:  ; 0 xrefs: 
9455  8A       TXA                     
9456  4D 19 01 EOR $0119               
9459  29 03    AND #$03                
945B  D0 0B    BNE loc_9468            
945D  BC CE 05 LDY $05CE,X             
9460  A9 05    LDA #$05                
9462  20 AF C8 JSR $C8AF               
9465  20 93 C9 JSR $C993               

loc_9468:  ; 1 xrefs: 945B
9468  4C EE C8 JMP $C8EE               

; ==== data $946B..$9499  (47 bytes) ====
946B  00 04 08 0C 00 FC F8 F4 20 7E C9 7C 94 83 94 9A  |........ ~.|....
947B  94 20 6E BE 59 4C 9D 95 20 AF 95 B0 03 4C 37 C8  |. n.YL.. ....L7.
948B  A9 00 9D CE 05 A8 20 09 C9 20 06 C9 4C 66 C9     |...... .. ..Lf.

loc_949A:  ; 0 xrefs: 
949A  20 E8 95 JSR sub_95E8            
949D  BD CE 05 LDA $05CE,X             
94A0  F0 2F    BEQ loc_94D1            
94A2  DE CE 05 DEC $05CE,X             
94A5  F0 01    BEQ loc_94A8            
94A7  60       RTS                     

loc_94A8:  ; 1 xrefs: 94A5
94A8  20 6E BE JSR sub_BE6E            
94AB  59 20 B9 EOR $B920,Y             
94AE  BE 00 FC LDX $FC00,Y             
94B1  20 FD C8 JSR $C8FD               
94B4  20 14 95 JSR sub_9514            
94B7  20 54 C9 JSR $C954               
94BA  30 0F    BMI loc_94CB            
94BC  20 39 C9 JSR $C939               
94BF  29 07    AND #$07                
94C1  A8       TAY                     
94C2  B9 1C 95 LDA $951C,Y             
94C5  A8       TAY                     
94C6  A9 FF    LDA #$FF                
94C8  4C 03 C9 JMP $C903               

loc_94CB:  ; 2 xrefs: 94BA 950F
94CB  A9 00    LDA #$00                
94CD  A8       TAY                     
94CE  4C 06 C9 JMP $C906               

loc_94D1:  ; 1 xrefs: 94A0
94D1  A9 28    LDA #$28                
94D3  20 0C C9 JSR $C90C               
94D6  BD 34 05 LDA $0534,X             
94D9  10 0F    BPL loc_94EA            
94DB  20 CB BE JSR sub_BECB            
94DE  F8       SED                     
94DF  00 10    BRK #$10                

; ==== data $94E1..$94E9  (9 bytes) ====
94E1  24 20 B9 BE 00 00 4C 06 95                       |$ ....L..

loc_94EA:  ; 1 xrefs: 94D9
94EA  C9 04    CMP #$04                
94EC  90 05    BCC loc_94F3            
94EE  20 B9 BE JSR sub_BEB9            
94F1  00 04    BRK #$04                

loc_94F3:  ; 1 xrefs: 94EC
94F3  20 CB BE JSR sub_BECB            
94F6  04 00    NOP $00                 
94F8  10 0C    BPL loc_9506            
94FA  20 81 C9 JSR $C981               
94FD  20 6E BE JSR sub_BE6E            
9500  5A       NOP                     
9501  20 75 BE JSR sub_BE75            
9504  20 60 20 JSR $2060               
9507  F4 C8    NOP $C8,X               
9509  20 14 95 JSR sub_9514            
950C  20 57 C9 JSR $C957               
950F  30 BA    BMI loc_94CB            
9511  4C F7 C8 JMP $C8F7               

sub_9514:  ; 2 xrefs: 94B4 9509
9514  A9 FC    LDA #$FC                
9516  85 00    STA $00                 
9518  A8       TAY                     
9519  A9 00    LDA #$00                
951B  60       RTS                     

; ==== data $951C..$959C  (129 bytes) ====
951C  00 20 40 60 80 90 A0 B0 20 7E C9 31 95 38 95 4F  |. @`.... ~.1.8.O
952C  95 6D 95 8A 95 20 AD BE 1C 4C 9D 95 20 AF 95 B0  |.m... ...L.. ...
953C  03 4C 37 C8 A9 00 9D CE 05 A8 20 09 C9 20 06 C9  |.L7....... .. ..
954C  4C 66 C9 20 9A 94 BD CE 05 D0 01 60 20 AD BE 1C  |Lf. .......` ...
955C  20 B9 BE 00 00 20 BF BE 80 FE 20 75 BE 80 4C 66  | .... .... u..Lf
956C  C9 20 E8 95 DE CE 05 D0 07 20 75 BE 28 4C 66 C9  |. ....... u.(Lf.
957C  20 12 BF F8 F9 FF 20 E9 BE 04 F8 4C EE C8 DE CE  | ..... ....L....
958C  05 D0 0D 20 39 C9 29 1F 69 1F 9D CE 05 4C 69 C9  |... 9.).i....Li.
959C  60                                               |`

loc_959D:  ; 0 xrefs: 
959D  BC CE 05 LDY $05CE,X             
95A0  A9 10    LDA #$10                
95A2  20 AF C8 JSR $C8AF               
95A5  20 93 C9 JSR $C993               
95A8  20 7C BE JSR sub_BE7C            
95AB  10 4C    BPL loc_95F9            
95AD  66 C9    ROR $C9                 

loc_95AF:  ; 0 xrefs: 
95AF  DE E4 05 DEC $05E4,X             
95B2  F0 32    BEQ loc_95E6            
95B4  A9 04    LDA #$04                
95B6  BC 60 05 LDY $0560,X             
95B9  10 02    BPL loc_95BD            
95BB  A9 FC    LDA #$FC                

loc_95BD:  ; 1 xrefs: 95B9
95BD  A0 00    LDY #$00                
95BF  20 45 C9 JSR $C945               
95C2  10 05    BPL loc_95C9            
95C4  20 B3 BE JSR sub_BEB3            
95C7  00 00    BRK #$00                

loc_95C9:  ; 1 xrefs: 95C2
95C9  20 F7 C8 JSR $C8F7               
95CC  A0 04    LDY #$04                
95CE  BD 34 05 LDA $0534,X             
95D1  10 02    BPL loc_95D5            
95D3  A0 FC    LDY #$FC                

loc_95D5:  ; 1 xrefs: 95D1
95D5  A9 00    LDA #$00                
95D7  20 45 C9 JSR $C945               
95DA  10 05    BPL loc_95E1            
95DC  20 B9 BE JSR sub_BEB9            
95DF  00 00    BRK #$00                

loc_95E1:  ; 1 xrefs: 95DA
95E1  20 F4 C8 JSR $C8F4               
95E4  18       CLC                     
95E5  60       RTS                     

loc_95E6:  ; 1 xrefs: 95B2
95E6  38       SEC                     
95E7  60       RTS                     

sub_95E8:  ; 1 xrefs: 949A
95E8  BD 68 06 LDA $0668,X             
95EB  F0 04    BEQ loc_95F1            
95ED  DE 68 06 DEC $0668,X             

loc_95F0:  ; 1 xrefs: 95F4
95F0  60       RTS                     

loc_95F1:  ; 1 xrefs: 95EB
95F1  20 C3 C9 JSR $C9C3               
95F4  90 FA    BCC loc_95F0            
95F6  68       PLA                     
95F7  68       PLA                     
95F8  4C 10 C8 JMP $C810               
95FB  20 7E C9 JSR $C97E               
95FE  4D 96 4D EOR $4D96               
9601  96 4D    STX $4D,Y               
9603  96 08    STX $08,Y               
9605  96 18    STX $18,Y               
9607  96 20    STX $20,Y               
9609  5A       NOP                     
960A  BE 01 20 LDX $2001,Y             
960D  6E BE 56 ROR $56BE               
9610  20 B9 BE JSR sub_BEB9            
9613  00 01    BRK #$01                

; ==== data $9615..$9772  (350 bytes) ====
9615  4C 66 C9 20 CB BE 14 00 30 17 A9 40 20 0C C9 BD  |Lf. ....0..@ ...
9625  34 05 C9 04 90 05 20 B9 BE 00 04 20 D2 C9 4C F4  |4..... .... ..L.
9635  C8 BD E4 05 A8 09 30 9D 52 06 20 A6 BE 03 20 8A  |......0.R. ... .
9645  BE 01 20 AB C9 4C 6C C9 20 6C 82 BD 8C 05 C9 01  |.. ..Ll. l......
9655  D0 0A BD CE 05 C9 02 D0 03 4C 10 C8 BD 68 06 30  |.........L...h.0
9665  3F 20 C3 C9 B0 3A 86 25 20 24 C9 20 73 C8 B0 2E  |? ...:.% $. s...
9675  20 27 C9 A4 25 B9 52 06 9D 00 04 B9 68 06 A8 B9  | '..%.R.....h...
9685  A6 96 9D CE 05 20 5A BE 01 20 A6 BE FF A6 25 BD  |..... Z.. ....%.
9695  68 06 DE 68 06 C9 02 D0 05 A9 14 20 1C C8 A6 25  |h..h....... ...%
96A5  60 95 B2 CE EB 20 7E C9 B5 96 D8 96 F1 96 17 97  |`.... ~.........
96B5  BD 9A 04 9D CE 05 85 00 0A A5 00 2A 29 03 A8 B9  |...........*)...
96C5  D4 96 9D 2C 04 20 63 BE 03 20 7C BE 10 D0 19 00  |...,. c.. |.....
96D5  40 40 00 20 73 97 DE E4 05 D0 10 A0 07 BD CE 05  |@@. s...........
96E5  4A 90 01 88 98 20 3A C8 4C 66 C9 60 20 73 97 20  |J.... :.Lf.` s. 
96F5  37 C8 BD 42 04 C9 37 F0 05 C9 16 F0 01 60 20 9F  |7..B..7......` .
9705  C9 20 39 C9 29 1F 69 20 9D E4 05 A9 03 9D FA 05  |. 9.).i ........
9715  D0 D6 20 73 97 DE E4 05 D0 4B 20 7C BE 30 A9 16  |.. s.....K |.0..
9725  85 24 A9 0C 85 26 A9 00 BD CE 05 4A 90 02 A0 04  |.$...&.....J....
9735  20 90 C9 B0 02 C8 C8 20 3C C9 B0 05 C8 A9 00 F0  | ...... <.......
9745  02 A9 80 85 06 98 4A A9 08 B0 02 A9 F8 48 B9 6B  |......J......H.k
9755  97 A8 68 20 E5 C8 B0 0D DE FA 05 D0 08 20 7C BE  |..h ......... |.
9765  90 20 83 BE 03 60 F4 E5 E5 F4 FD EC EC FD        |. ...`........

loc_9773:  ; 0 xrefs: 
9773  BD CE 05 LDA $05CE,X             
9776  4A       LSR A                   
9777  B0 03    BCS loc_977C            
9779  4C D0 9B JMP sub_9BD0            

loc_977C:  ; 1 xrefs: 9777
977C  60       RTS                     

; ==== data $977D..$97D7  (91 bytes) ====
977D  4C FB 97 BD 8C 05 D0 16 20 5A BE 7F 20 BF BE 80  |L....... Z.. ...
978D  FF 20 39 C9 29 0F 69 01 9D E4 05 4C 66 C9 BD 9A  |. 9.).i....Lf...
979D  04 C9 7F F0 59 FE 00 04 20 63 BE 01 A9 08 9D B8  |....Y... c......
97AD  05 BD CE 05 18 69 06 9D CE 05 A8 B9 0F 9A 48 BD  |.....i........H.
97BD  E4 05 F0 0B 20 7C BE 01 68 A8 B9 23 9A D0 05 68  |.... |..h..#...h
97CD  A8 B9 1B 9A 9D 42 04 BD 76 05 1D                 |.....B..v..

loc_97D8:  ; 0 xrefs: 
97D8  60       RTS                     

; ==== data $97D9..$97FA  (34 bytes) ====
97D9  05 F0 05 20 C5 BE 00 FF 86 25 20 6A C8 B0 0E A4  |... .....% j....
97E9  25 20 63 C9 BD E4 05 F0 04 20 7C BE 20 A6 25 20  |% c...... |. .% 
97F9  1B C9                                            |..

loc_97FB:  ; 0 xrefs: 
97FB  BD E4 05 LDA $05E4,X             
97FE  D0 03    BNE loc_9803            
9800  4C C4 98 JMP loc_98C4            

loc_9803:  ; 1 xrefs: 97FE
9803  DE E4 05 DEC $05E4,X             
9806  F0 01    BEQ loc_9809            
9808  60       RTS                     

loc_9809:  ; 1 xrefs: 9806
9809  A9 00    LDA #$00                
980B  85 08    STA $08                 
980D  A9 FB    LDA #$FB                
980F  BC 00 04 LDY $0400,X             
9812  C0 27    CPY #$27                
9814  F0 02    BEQ loc_9818            
9816  A9 FE    LDA #$FE                

loc_9818:  ; 1 xrefs: 9814
9818  85 00    STA $00                 
981A  BC CE 05 LDY $05CE,X             
981D  B9 63 9A LDA $9A63,Y             
9820  A8       TAY                     
9821  A5 00    LDA $00                 
9823  20 4B C9 JSR $C94B               
9826  10 13    BPL loc_983B            
9828  BC CE 05 LDY $05CE,X             
982B  B9 57 9A LDA $9A57,Y             
982E  9D CE 05 STA $05CE,X             
9831  BD FA 05 LDA $05FA,X             
9834  09 01    ORA #$01                
9836  9D FA 05 STA $05FA,X             
9839  E6 08    INC $08                 

loc_983B:  ; 1 xrefs: 9826
983B  BD CE 05 LDA $05CE,X             
983E  F0 0C    BEQ loc_984C            
9840  C9 03    CMP #$03                
9842  F0 08    BEQ loc_984C            
9844  C9 06    CMP #$06                
9846  F0 04    BEQ loc_984C            
9848  C9 09    CMP #$09                
984A  D0 30    BNE loc_987C            

loc_984C:  ; 3 xrefs: 983E 9842 9846
984C  BD FA 05 LDA $05FA,X             
984F  F0 06    BEQ loc_9857            
9851  DE FA 05 DEC $05FA,X             
9854  4C 6A 98 JMP loc_986A            

loc_9857:  ; 1 xrefs: 984F
9857  20 3C C9 JSR $C93C               
985A  70 0E    BVS loc_986A            
985C  20 83 BE JSR sub_BE83            
985F  03 20    SLO ($20,X)             
9861  BF BE 00 LAX $00BE,Y             
9864  FE FE CE INC $CEFE,X             
9867  05 D0    ORA $D0                 
9869  17 20    SLO $20,X               
986B  BF BE 40 LAX $40BE,Y             
986E  FF 20 39 ISC $3920,X             
9871  C9 C9    CMP #$C9                
9873  D0 90    BNE loc_9805            
9875  03 20    SLO ($20,X)             
9877  1B C9 4C SLO $4CC9,Y             
987A  81 98    STA ($98,X)             

loc_987C:  ; 1 xrefs: 984A
987C  20 BF BE JSR sub_BEBF            
987F  E0 FF    CPX #$FF                

loc_9881:  ; 0 xrefs: 
9881  A9 F8    LDA #$F8                
9883  BC 00 04 LDY $0400,X             
9886  C0 27    CPY #$27                
9888  F0 02    BEQ loc_988C            
988A  A9 FC    LDA #$FC                

loc_988C:  ; 1 xrefs: 9888
988C  85 00    STA $00                 
988E  BC CE 05 LDY $05CE,X             
9891  B9 0F 9A LDA $9A0F,Y             
9894  A8       TAY                     
9895  B9 3B 9A LDA $9A3B,Y             
9898  A8       TAY                     
9899  C9 80    CMP #$80                
989B  6A       ROR A                   
989C  20 54 C9 JSR $C954               
989F  10 05    BPL loc_98A6            
98A1  20 B3 BE JSR sub_BEB3            
98A4  00 00    BRK #$00                

loc_98A6:  ; 1 xrefs: 989F
98A6  BC CE 05 LDY $05CE,X             
98A9  B9 4B 9A LDA $9A4B,Y             
98AC  A0 00    LDY #$00                
98AE  20 09 C9 JSR $C909               
98B1  A5 08    LDA $08                 
98B3  F0 0E    BEQ loc_98C3            
98B5  A9 01    LDA #$01                
98B7  BC 34 05 LDY $0534,X             
98BA  10 02    BPL loc_98BE            
98BC  A9 FF    LDA #$FF                

loc_98BE:  ; 1 xrefs: 98BA
98BE  A0 00    LDY #$00                
98C0  20 09 C9 JSR $C909               

loc_98C3:  ; 1 xrefs: 98B3
98C3  60       RTS                     

loc_98C4:  ; 1 xrefs: 9800
98C4  BC CE 05 LDY $05CE,X             
98C7  B9 EB 99 LDA $99EB,Y             
98CA  30 06    BMI loc_98D2            
98CC  20 0C C9 JSR $C90C               
98CF  4C D8 98 JMP loc_98D8            

loc_98D2:  ; 1 xrefs: 98CA
98D2  20 58 C8 JSR $C858               
98D5  20 0F C9 JSR $C90F               

loc_98D8:  ; 1 xrefs: 98CF
98D8  BD 34 05 LDA $0534,X             
98DB  30 0C    BMI loc_98E9            
98DD  C9 04    CMP #$04                
98DF  90 11    BCC loc_98F2            
98E1  20 B9 BE JSR sub_BEB9            
98E4  00 04    BRK #$04                

; ==== data $98E6..$98E8  (3 bytes) ====
98E6  4C F2 98                                         |L..

loc_98E9:  ; 1 xrefs: 98DB
98E9  C9 FC    CMP #$FC                
98EB  B0 05    BCS loc_98F2            
98ED  20 B9 BE JSR sub_BEB9            
98F0  00 FC    BRK #$FC                

loc_98F2:  ; 2 xrefs: 98DF 98EB
98F2  BD 60 05 LDA $0560,X             
98F5  30 0C    BMI loc_9903            
98F7  C9 01    CMP #$01                
98F9  90 11    BCC loc_990C            
98FB  A9 10    LDA #$10                
98FD  20 15 C9 JSR $C915               
9900  4C 0C 99 JMP loc_990C            

loc_9903:  ; 1 xrefs: 98F5
9903  C9 FF    CMP #$FF                
9905  B0 05    BCS loc_990C            
9907  A9 10    LDA #$10                
9909  20 12 C9 JSR $C912               

loc_990C:  ; 3 xrefs: 98F9 9900 9905
990C  BC CE 05 LDY $05CE,X             
990F  B9 0F 9A LDA $9A0F,Y             
9912  85 08    STA $08                 
9914  A9 F8    LDA #$F8                
9916  BC 00 04 LDY $0400,X             
9919  C0 27    CPY #$27                
991B  F0 02    BEQ loc_991F            
991D  A9 FC    LDA #$FC                

loc_991F:  ; 1 xrefs: 991B
991F  85 00    STA $00                 
9921  A4 08    LDY $08                 
9923  B9 3B 9A LDA $9A3B,Y             
9926  48       PHA                     
9927  B9 43 9A LDA $9A43,Y             
992A  A8       TAY                     
992B  68       PLA                     
992C  20 57 C9 JSR $C957               
992F  10 11    BPL loc_9942            
9931  20 90 C9 JSR $C990               
9934  A0 02    LDY #$02                
9936  90 02    BCC loc_993A            
9938  A0 FE    LDY #$FE                

loc_993A:  ; 1 xrefs: 9936
993A  20 36 C9 JSR $C936               
993D  20 B3 BE JSR sub_BEB3            
9940  00 00    BRK #$00                

loc_9942:  ; 1 xrefs: 992F
9942  20 F7 C8 JSR $C8F7               
9945  A9 FB    LDA #$FB                
9947  BC 00 04 LDY $0400,X             
994A  C0 27    CPY #$27                
994C  F0 02    BEQ loc_9950            
994E  A9 FF    LDA #$FF                

loc_9950:  ; 1 xrefs: 994C
9950  85 00    STA $00                 
9952  A4 08    LDY $08                 
9954  BD 34 05 LDA $0534,X             
9957  30 0D    BMI loc_9966            
9959  B9 33 9A LDA $9A33,Y             
995C  A8       TAY                     
995D  A5 00    LDA $00                 
995F  20 4E C9 JSR $C94E               
9962  10 0D    BPL loc_9971            
9964  30 16    BMI loc_997C            

loc_9966:  ; 1 xrefs: 9957
9966  B9 2B 9A LDA $9A2B,Y             
9969  A8       TAY                     
996A  A5 00    LDA $00                 
996C  20 4E C9 JSR $C94E               
996F  30 2D    BMI loc_999E            

loc_9971:  ; 1 xrefs: 9962
9971  A4 08    LDY $08                 
9973  B9 1B 9A LDA $9A1B,Y             
9976  9D 42 04 STA $0442,X             
9979  4C F4 C8 JMP $C8F4               

loc_997C:  ; 1 xrefs: 9964
997C  20 D5 99 JSR sub_99D5            
997F  BC CE 05 LDY $05CE,X             
9982  B9 0F 9A LDA $9A0F,Y             
9985  A8       TAY                     
9986  B9 33 9A LDA $9A33,Y             
9989  A8       TAY                     
998A  20 30 C9 JSR $C930               
998D  A9 00    LDA #$00                
998F  20 87 C9 JSR $C987               
9992  BC CE 05 LDY $05CE,X             
9995  B9 03 9A LDA $9A03,Y             
9998  9D CE 05 STA $05CE,X             
999B  4C BD 99 JMP loc_99BD            

loc_999E:  ; 1 xrefs: 996F
999E  20 D5 99 JSR sub_99D5            
99A1  BC CE 05 LDY $05CE,X             
99A4  B9 0F 9A LDA $9A0F,Y             
99A7  A8       TAY                     
99A8  B9 2B 9A LDA $9A2B,Y             
99AB  A8       TAY                     
99AC  20 30 C9 JSR $C930               
99AF  A9 00    LDA #$00                
99B1  20 8A C9 JSR $C98A               
99B4  BC CE 05 LDY $05CE,X             
99B7  B9 F7 99 LDA $99F7,Y             
99BA  9D CE 05 STA $05CE,X             

loc_99BD:  ; 1 xrefs: 999B
99BD  20 39 C9 JSR $C939               
99C0  29 0F    AND #$0F                
99C2  69 0F    ADC #$0F                
99C4  9D E4 05 STA $05E4,X             
99C7  BC CE 05 LDY $05CE,X             
99CA  B9 0F 9A LDA $9A0F,Y             
99CD  A8       TAY                     
99CE  B9 23 9A LDA $9A23,Y             
99D1  9D 42 04 STA $0442,X             

loc_99D4:  ; 4 xrefs: 99D8 99DC 99E0 99E4
99D4  60       RTS                     

sub_99D5:  ; 2 xrefs: 997C 999E
99D5  BD CE 05 LDA $05CE,X             
99D8  F0 FA    BEQ loc_99D4            
99DA  C9 03    CMP #$03                
99DC  F0 F6    BEQ loc_99D4            
99DE  C9 06    CMP #$06                
99E0  F0 F2    BEQ loc_99D4            
99E2  C9 09    CMP #$09                
99E4  F0 EE    BEQ loc_99D4            
99E6  A9 20    LDA #$20                
99E8  4C 1C C8 JMP $C81C               

; ==== data $99EB..$9BA4  (442 bytes) ====
99EB  28 24 02 D8 DC FE 14 12 02 EC EE FE 03 05 03 03  |($..............
99FB  05 03 09 0B 09 09 0B 09 00 02 00 00 02 00 06 08  |................
9A0B  06 06 08 06 00 01 01 02 03 03 04 05 05 06 07 07  |................
9A1B  5E 5D 61 60 64 63 67 66 5F 5F 62 62 65 65 68 68  |^]a`dcgf__bbeehh
9A2B  F4 EC FC FC F8 F4 FC FC 04 04 0C 14 04 04 08 0C  |................
9A3B  F6 EE 0A 12 FA F6 06 0A FF FF 01 01 FF FF 01 01  |................
9A4B  FE FC FD 02 04 03 FF FE FD 01 02 03 00 00 00 03  |................
9A5B  03 03 06 06 06 09 09 09 EC EC EC 14 14 14 F4 F4  |................
9A6B  F4 0C 0C 0C BD 8C 05 D0 0A 20 A2 C9 20 6E BE 2A  |......... .. n.*
9A7B  4C 66 C9 A9 00 A8 20 45 C9 30 06 20 D2 C9 4C F1  |Lf.... E.0. ..L.
9A8B  C8 BD 34 05 30 1B A9 F0 BC 60 05 10 02 A9 10 A0  |..4.0....`......
9A9B  00 20 45 C9 10 0B 20 81 C9 20 6A 93 20 75 BE F0  |. E... .. j. u..
9AAB  60 4C 10 C8 4C C0 C9 BD 8C 05 D0 0B 20 5A BE 7F  |`L..L....... Z..
9ABB  20 AD BE 35 20 66 C9 AD 0F 04 C9 50 D0 E6 AD 9B  | ..5 f.....P....
9ACB  05 C9 03 B0 DF BD 9A 04 C9 6F 90 D8 BD B8 05 F0  |.........o......
9ADB  47 BD B0 04 1D F2 04 D0 3F 86 25 BD C6 04 85 00  |G.......?.%.....
9AEB  BD 08 05 85 01 A2 01 BD 00 04 F0 25 C9 04 B0 21  |...........%...!
9AFB  BD 08 05 38 E5 01 B0 03 20 58 C8 C9 15 B0 12 BD  |...8.... X......
9B0B  C6 04 38 E5 00 B0 03 20 58 C8 C9 15 B0 03 20 10  |..8.... X..... .
9B1B  C8 E8 E0 04 D0 D1 A6 25 A9 00 85 08 A9 EC 85 09  |.......%........
9B2B  BD E4 05 18 69 80 9D E4 05 BD CE 05 69 08 9D CE  |....i.......i...
9B3B  05 20 8B C8 A0 00 A5 0B 10 01 88 18 6D 17 05 9D  |. ..........m...
9B4B  08 05 98 6D 01 05 9D F2 04 A0 00 A5 0C 10 01 88  |...m............
9B5B  18 6D D5 04 9D C6 04 98 6D BF 04 9D B0 04 60 BD  |.m......m.....`.
9B6B  8C 05 D0 0B 20 5A BE FF 20 6E BE F2 4C 66 C9 20  |.... Z.. n..Lf. 
9B7B  F1 C8 BD C6 04 C9 96 B0 01 60 A9 02 8D 77 06 4C  |.........`...w.L
9B8B  10 C8 BD 8C 05 D0 0A 20 A2 C9 20 AD BE 3E 4C 66  |....... .. ..>Lf
9B9B  C9 20 37 C8 20 D2 C9 4C EB C8                    |. 7. ..L..

loc_9BA5:  ; 0 xrefs: 
9BA5  48       PHA                     
9BA6  20 D0 9B JSR sub_9BD0            
9BA9  68       PLA                     
9BAA  A8       TAY                     
9BAB  BD 68 06 LDA $0668,X             
9BAE  C9 82    CMP #$82                
9BB0  D0 14    BNE loc_9BC6            
9BB2  8A       TXA                     
9BB3  4D 19 01 EOR $0119               
9BB6  29 07    AND #$07                
9BB8  D0 0C    BNE loc_9BC6            
9BBA  A9 00    LDA #$00                
9BBC  20 88 C8 JSR $C888               
9BBF  10 05    BPL loc_9BC6            
9BC1  68       PLA                     
9BC2  68       PLA                     
9BC3  4C C0 C9 JMP $C9C0               

loc_9BC6:  ; 3 xrefs: 9BB0 9BB8 9BBF
9BC6  60       RTS                     

sub_9BC7:  ; 1 xrefs: A748
9BC7  20 44 9C JSR sub_9C44            
9BCA  90 03    BCC loc_9BCF            
9BCC  9D C6 04 STA $04C6,X             

loc_9BCF:  ; 1 xrefs: 9BCA
9BCF  60       RTS                     

sub_9BD0:  ; 2 xrefs: 9779 9BA6
9BD0  BD 68 06 LDA $0668,X             
9BD3  C9 81    CMP #$81                
9BD5  F0 17    BEQ loc_9BEE            
9BD7  B0 3A    BCS loc_9C13            
9BD9  20 44 9C JSR sub_9C44            
9BDC  B0 4D    BCS loc_9C2B            
9BDE  A9 00    LDA #$00                
9BE0  A0 01    LDY #$01                
9BE2  20 88 C8 JSR $C888               
9BE5  30 22    BMI loc_9C09            

loc_9BE7:  ; 1 xrefs: 9C42
9BE7  A9 00    LDA #$00                
9BE9  9D 68 06 STA $0668,X             
9BEC  18       CLC                     
9BED  60       RTS                     

loc_9BEE:  ; 1 xrefs: 9BD5
9BEE  20 44 9C JSR sub_9C44            
9BF1  90 19    BCC loc_9C0C            
9BF3  A4 87    LDY $87                 
9BF5  C0 09    CPY #$09                
9BF7  D0 32    BNE loc_9C2B            
9BF9  A4 20    LDY $20                 
9BFB  D0 2E    BNE loc_9C2B            
9BFD  48       PHA                     
9BFE  20 D1 BE JSR sub_BED1            
9C01  01 00    ORA ($00,X)             
9C03  10 25    BPL loc_9C2A            
9C05  68       PLA                     
9C06  4C 0C 9C JMP loc_9C0C            

loc_9C09:  ; 3 xrefs: 9BE5 9C36 9C40
9C09  20 81 C9 JSR $C981               

loc_9C0C:  ; 2 xrefs: 9BF1 9C06
9C0C  A9 81    LDA #$81                
9C0E  9D 68 06 STA $0668,X             
9C11  18       CLC                     
9C12  60       RTS                     

loc_9C13:  ; 1 xrefs: 9BD7
9C13  20 44 9C JSR sub_9C44            
9C16  90 21    BCC loc_9C39            
9C18  A4 87    LDY $87                 
9C1A  C0 09    CPY #$09                
9C1C  D0 0D    BNE loc_9C2B            
9C1E  A4 20    LDY $20                 
9C20  D0 09    BNE loc_9C2B            
9C22  48       PHA                     
9C23  20 CB BE JSR sub_BECB            
9C26  01 00    ORA ($00,X)             
9C28  30 0B    BMI loc_9C35            

loc_9C2A:  ; 1 xrefs: 9C03
9C2A  68       PLA                     

loc_9C2B:  ; 5 xrefs: 9BDC 9BF7 9BFB 9C1C 9C20
9C2B  9D C6 04 STA $04C6,X             
9C2E  A9 82    LDA #$82                
9C30  9D 68 06 STA $0668,X             
9C33  38       SEC                     
9C34  60       RTS                     

loc_9C35:  ; 1 xrefs: 9C28
9C35  68       PLA                     
9C36  4C 09 9C JMP loc_9C09            

loc_9C39:  ; 1 xrefs: 9C16
9C39  A9 00    LDA #$00                
9C3B  A0 01    LDY #$01                
9C3D  20 88 C8 JSR $C888               
9C40  30 C7    BMI loc_9C09            
9C42  10 A3    BPL loc_9BE7            

sub_9C44:  ; 6 xrefs: 8EF5 9BC7 9BD9 9BEE 9C13 AAF9
9C44  A5 87    LDA $87                 
9C46  C9 05    CMP #$05                
9C48  F0 04    BEQ loc_9C4E            
9C4A  C9 09    CMP #$09                
9C4C  D0 18    BNE loc_9C66            

loc_9C4E:  ; 1 xrefs: 9C48
9C4E  BD B0 04 LDA $04B0,X             
9C51  D0 13    BNE loc_9C66            
9C53  BD C6 04 LDA $04C6,X             
9C56  38       SEC                     
9C57  E5 29    SBC $29                 
9C59  B0 07    BCS loc_9C62            
9C5B  20 58 C8 JSR $C858               
9C5E  C9 02    CMP #$02                
9C60  B0 04    BCS loc_9C66            

loc_9C62:  ; 1 xrefs: 9C59
9C62  A5 29    LDA $29                 
9C64  38       SEC                     
9C65  60       RTS                     

loc_9C66:  ; 3 xrefs: 9C4C 9C51 9C60
9C66  18       CLC                     
9C67  60       RTS                     

; ==== data $9C68..$9D01  (154 bytes) ====
9C68  BD 8C 05 D0 0A 20 A2 C9 20 6E BE 3C 4C 66 C9 20  |..... .. n.<Lf. 
9C78  D2 C9 4C EB C8 20 7E C9 86 9C BA 9C CA 9C BD 9A  |..L.. ~.........
9C88  04 9D 52 06 20 6A BE BD 52 06 29 7F A8 B9 B2 9C  |..R. j..R.).....
9C98  85 24 B9 B6 9C A4 24 20 06 C9 20 39 C9 29 7F 09  |.$....$ .. 9.)..
9CA8  01 9D E4 05 20 AE C9 4C 66 C9 00 80 00 80 01 00  |.... ..Lf.......
9CB8  FF FF DE E4 05 F0 01 60 20 9F C9 20 AD BE 0C 4C  |.......` .. ...L
9CC8  66 C9 20 02 9D B0 30 20 37 C8 20 F7 C8 8A 4D 19  |f. ...0 7. ...M.
9CD8  01 29 07 D0 10 A9 08 BC 52 06 10 02 A9 F8 A0 00  |.)......R.......
9CE8  20 45 C9 30 01 60 20 BA C9 20 6E BE 00 20 AB C9  | E.0.` .. n.. ..
9CF8  20 7C BE 40 4C 69 C9 4C 10 C8                    | |.@Li.L..

loc_9D02:  ; 0 xrefs: 
9D02  A5 87    LDA $87                 
9D04  C9 05    CMP #$05                
9D06  D0 11    BNE loc_9D19            
9D08  BD B0 04 LDA $04B0,X             
9D0B  30 0C    BMI loc_9D19            
9D0D  D0 0E    BNE loc_9D1D            
9D0F  A5 29    LDA $29                 
9D11  38       SEC                     
9D12  FD C6 04 SBC $04C6,X             
9D15  90 06    BCC loc_9D1D            
9D17  18       CLC                     
9D18  60       RTS                     

loc_9D19:  ; 2 xrefs: 9D06 9D0B
9D19  A9 FF    LDA #$FF                
9D1B  18       CLC                     
9D1C  60       RTS                     

loc_9D1D:  ; 2 xrefs: 9D0D 9D15
9D1D  38       SEC                     
9D1E  60       RTS                     

; ==== data $9D1F..$9D64  (70 bytes) ====
9D1F  BD 8C 05 D0 2F BD 9A 04 9D 52 06 20 BD C9 20 A5  |..../....R. .. .
9D2F  C9 20 66 C9 20 6E BE 20 20 65 9D A0 00 BD 52 06  |. f. n.  e....R.
9D3F  29 04 F0 02 A0 80 BD 52 06 0A A9 FF 90 03 4C 06  |)......R......L.
9D4F  C9 4C 09 C9 20 F1 C8 DE CE 05 D0 09 20 65 9D 20  |.L.. ....... e. 
9D5F  1E C9 4C 21 C9 60                                |..L!.`

loc_9D65:  ; 0 xrefs: 
9D65  BD 52 06 LDA $0652,X             
9D68  29 0F    AND #$0F                
9D6A  A8       TAY                     
9D6B  B9 72 9D LDA $9D72,Y             
9D6E  9D CE 05 STA $05CE,X             
9D71  60       RTS                     

; ==== data $9D72..$9DDF  (110 bytes) ====
9D72  30 50 70 00 60 A0 E0 BD 8C 05 D0 0F 20 5A BE FF  |0Pp.`....... Z..
9D82  20 AD BE 0B 20 7C BE 38 4C 66 C9 DE E4 05 F0 10  | ... |.8Lf......
9D92  BC CE 05 B9 00 04 C9 17 D0 06 20 D2 C9 4C 37 C8  |.......... ..L7.
9DA2  4C 10 C8 20 7E C9 AE 9D E3 9D 17 9E BD 9A 04 9D  |L.. ~...........
9DB2  CE 05 20 5A BE 01 A0 1A BD CE 05 4A 90 02 A0 12  |.. Z.......J....
9DC2  98 9D 42 04 BD CE 05 30 0C 20 B3 BE 00 01 20 7C  |..B....0. .... |
9DD2  BE 18 4C E0 9D 20 B3 BE 80 00 20 7C BE 30        |..L.. .... |.0

loc_9DE0:  ; 0 xrefs: 
9DE0  4C 66 C9 JMP $C966               

; ==== data $9DE3..$9E8D  (171 bytes) ====
9DE3  DE E4 05 D0 2C 20 7C BE 40 A9 18 85 24 BD 60 05  |...., |.@...$.`.
9DF3  0A A9 10 B0 02 A9 F0 48 A0 FF BD CE 05 4A 90 02  |.......H.....J..
9E03  A0 04 68 20 DF C8 B0 06 A4 12 8A 99 CE 05 4C 66  |..h ..........Lf
9E13  C9 4C F7 C8 DE E4 05 D0 12 A9 30 BC CE 05 10 02  |.L........0.....
9E23  A9 60 9D E4 05 20 1E C9 4C 69 C9 60 BD 8C 05 D0  |.`... ..Li.`....
9E33  28 BD 08 05 9D CE 05 BD F2 04 9D E4 05 BD C6 04  |(...............
9E43  9D FA 05 BD B0 04 9D 10 06 BD 9A 04 9D 52 06 20  |.............R. 
9E53  A5 C9 20 6E BE 1D 4C 66 C9 A0 00 A5 94 10 01 88  |.. n..Lf........
9E63  84 00 A5 97 F0 14 BD FA 05 38 E5 94 9D FA 05 BD  |.........8......
9E73  10 06 E5 00 9D 10 06 4C 8E 9E BD CE 05 38 E5 94  |.......L.....8..
9E83  9D CE 05 BD E4 05 E5 00 9D E4 05                 |...........

loc_9E8E:  ; 0 xrefs: 
9E8E  A0 00    LDY #$00                
9E90  84 08    STY $08                 
9E92  A0 E0    LDY #$E0                
9E94  BD 52 06 LDA $0652,X             
9E97  10 02    BPL loc_9E9B            
9E99  A0 D0    LDY #$D0                

loc_9E9B:  ; 1 xrefs: 9E97
9E9B  84 09    STY $09                 
9E9D  29 07    AND #$07                
9E9F  A8       TAY                     
9EA0  BD 3C 06 LDA $063C,X             
9EA3  18       CLC                     
9EA4  79 E1 9E ADC $9EE1,Y             
9EA7  9D 3C 06 STA $063C,X             
9EAA  BD 26 06 LDA $0626,X             
9EAD  79 E9 9E ADC $9EE9,Y             
9EB0  9D 26 06 STA $0626,X             
9EB3  20 8B C8 JSR $C88B               
9EB6  A0 00    LDY #$00                
9EB8  A5 0B    LDA $0B                 
9EBA  10 01    BPL loc_9EBD            
9EBC  88       DEY                     

loc_9EBD:  ; 1 xrefs: 9EBA
9EBD  18       CLC                     
9EBE  7D CE 05 ADC $05CE,X             
9EC1  9D 08 05 STA $0508,X             
9EC4  98       TYA                     
9EC5  7D E4 05 ADC $05E4,X             
9EC8  9D F2 04 STA $04F2,X             
9ECB  A0 00    LDY #$00                
9ECD  A5 0C    LDA $0C                 
9ECF  10 01    BPL loc_9ED2            
9ED1  88       DEY                     

loc_9ED2:  ; 1 xrefs: 9ECF
9ED2  18       CLC                     
9ED3  7D FA 05 ADC $05FA,X             
9ED6  9D C6 04 STA $04C6,X             
9ED9  98       TYA                     
9EDA  7D 10 06 ADC $0610,X             
9EDD  9D B0 04 STA $04B0,X             
9EE0  60       RTS                     

; ==== data $9EE1..$9F14  (52 bytes) ====
9EE1  56 00 AB 00 AA 00 55 00 FF FF FE FE 00 01 01 02  |V.....U.........
9EF1  BD 8C 05 D0 14 20 AD BE 02 BD 9A 04 9D 52 06 20  |..... .......R. 
9F01  5A BE FF 20 15 9F 4C 66 C9 DE 26 06 D0 03 20 15  |Z.. ..Lf..&... .
9F11  9F 4C EE C8                                      |.L..

loc_9F15:  ; 0 xrefs: 
9F15  BC 52 06 LDY $0652,X             
9F18  B9 5C 9F LDA $9F5C,Y             
9F1B  85 00    STA $00                 
9F1D  B9 60 9F LDA $9F60,Y             
9F20  85 01    STA $01                 
9F22  BC 3C 06 LDY $063C,X             

loc_9F25:  ; 1 xrefs: 9F2A
9F25  B1 00    LDA ($00),Y             
9F27  D0 03    BNE loc_9F2C            
9F29  A8       TAY                     
9F2A  F0 F9    BEQ loc_9F25            

loc_9F2C:  ; 1 xrefs: 9F27
9F2C  9D 26 06 STA $0626,X             
9F2F  C8       INY                     
9F30  84 26    STY $26                 
9F32  B1 00    LDA ($00),Y             
9F34  A8       TAY                     
9F35  B9 A4 9F LDA $9FA4,Y             
9F38  9D 76 05 STA $0576,X             
9F3B  B9 A9 9F LDA $9FA9,Y             
9F3E  9D 60 05 STA $0560,X             
9F41  A4 26    LDY $26                 
9F43  C8       INY                     
9F44  B1 00    LDA ($00),Y             
9F46  C8       INY                     
9F47  84 26    STY $26                 
9F49  A8       TAY                     
9F4A  B9 AE 9F LDA $9FAE,Y             
9F4D  9D 4A 05 STA $054A,X             
9F50  B9 B3 9F LDA $9FB3,Y             
9F53  9D 34 05 STA $0534,X             
9F56  A5 26    LDA $26                 
9F58  9D 3C 06 STA $063C,X             
9F5B  60       RTS                     

; ==== data $9F5C..$A003  (168 bytes) ====
9F5C  64 74 84 94 9F 9F 9F 9F 18 03 00 20 00 03 30 01  |dt......... ..0.
9F6C  00 20 00 01 18 03 00 00 30 04 00 40 00 04 60 02  |. ......0..@..`.
9F7C  00 40 00 02 30 04 00 00 18 01 00 20 00 03 30 03  |.@..0...... ..0.
9F8C  00 20 00 01 18 01 00 00 30 02 00 40 00 04 60 04  |. ......0..@..`.
9F9C  00 40 00 02 30 02 00 00 00 00 80 00 80 00 01 00  |.@..0...........
9FAC  FF FF 00 00 80 00 80 00 FF FF 01 00 BD 8C 05 D0  |................
9FBC  0A 20 6E BE 0D 20 04 A0 4C 06 C9 20 53 A0 20 F7  |. n.. ..L.. S. .
9FCC  C8 DE E4 05 D0 09 BD FA 05 9D E4 05 20 1E C9 4C  |............ ..L
9FDC  5A A0 BD 8C 05 D0 0A 20 6E BE 0D 20 04 A0 4C 09  |Z...... n.. ..L.
9FEC  C9 20 53 A0 20 F4 C8 DE E4 05 D0 09 BD FA 05 9D  |. S. ...........
9FFC  E4 05 20 21 C9 4C 5A A0                          |.. !.LZ.

loc_A004:  ; 0 xrefs: 
A004  20 AB C9 JSR $C9AB               
A007  A4 97    LDY $97                 
A009  F0 05    BEQ loc_A010            
A00B  A0 FF    LDY #$FF                
A00D  20 30 C9 JSR $C930               

loc_A010:  ; 1 xrefs: A009
A010  BD 9A 04 LDA $049A,X             
A013  4A       LSR A                   
A014  4A       LSR A                   
A015  A8       TAY                     
A016  B9 35 A0 LDA $A035,Y             
A019  9D E4 05 STA $05E4,X             
A01C  B9 40 A0 LDA $A040,Y             
A01F  9D FA 05 STA $05FA,X             
A022  BD 9A 04 LDA $049A,X             
A025  29 03    AND #$03                
A027  A8       TAY                     
A028  B9 4B A0 LDA $A04B,Y             
A02B  85 24    STA $24                 
A02D  B9 4F A0 LDA $A04F,Y             
A030  A4 24    LDY $24                 
A032  4C 66 C9 JMP $C966               

; ==== data $A035..$A052  (30 bytes) ====
A035  70 62 40 E0 B0 60 50 C0 60 A4 80 70 62 40 E0 B0  |pb@..`P.`..pb@..
A045  60 50 C0 C0 A4 A0 00 00 80 80 01 FF 00 FF        |`P............

loc_A053:  ; 0 xrefs: 
A053  A9 0F    LDA #$0F                
A055  A0 F1    LDY #$F1                
A057  4C 20 BF JMP sub_BF20            

loc_A05A:  ; 0 xrefs: 
A05A  A9 0F    LDA #$0F                
A05C  A0 F1    LDY #$F1                
A05E  4C 26 BF JMP loc_BF26            

; ==== data $A061..$A0DF  (127 bytes) ====
A061  20 7E C9 6C A0 7C A0 8C A0 9A A0 20 6E BE 0D 20  | ~.l.|..... n.. 
A071  7C BE 28 20 B9 BE 00 04 4C 66 C9 20 53 A0 AD 64  ||.( ....Lf. S..d
A081  01 C9 01 D0 03 20 66 C9 4C 5A A0 20 53 A0 DE E4  |..... f.LZ. S...
A091  05 D0 03 20 66 C9 4C 5A A0 4C F4 C8 BD 8C 05 D0  |... f.LZ.L......
A0A1  1B 20 AB C9 20 AD BE 0A 20 5A A1 BC 9A 04 B9 B9  |. .. ... Z......
A0B1  A0 A8 20 30 C9 4C 66 C9 00 00 00 0A A9 10 A0 F6  |.. 0.Lf.........
A0C1  20 20 BF BD 3C 06 D0 40 AD 8C 05 C9 0C F0 7F C9  |  ..<..@........
A0D1  0E F0 7B AD 64 01 F0 76 C9 02 D0 06 A5 9A C9     |..{.d..v.......

loc_A0E0:  ; 0 xrefs: 
A0E0  01 D0    ORA ($D0,X)             
A0E2  6C BD 34 JMP ($34BD)             

; ==== data $A0E5..$A13F  (91 bytes) ====
A0E5  05 D0 0D BD 52 06 C9 14 B0 28 FE 52 06 4C 53 A1  |....R....(.R.LS.
A0F5  BD 52 06 C9 14 B0 06 FE 52 06 4C 53 A1 A9 10 9D  |.R......R.LS....
A105  3C 06 D0 0E DE 3C 06 D0 09 20 C4 A1 90 04 20 98  |<....<... .... .
A115  BE 0F 20 EE C8 FE 68 06 BD 68 06 C9 0D D0 09 20  |.. ...h..h..... 
A125  A6 BE 00 A9 12 20 1C C8 DE 26 06 D0 21 BD 10 06  |..... ...&..!...
A135  10 06 DE FA 05 4C 40 A1 FE FA 05                 |.....L@....

loc_A140:  ; 0 xrefs: 
A140  20 69 A1 JSR sub_A169            
A143  BD 60 05 LDA $0560,X             
A146  F0 0B    BEQ loc_A153            
A148  A9 00    LDA #$00                
A14A  9D 3C 06 STA $063C,X             
A14D  F0 04    BEQ loc_A153            
A14F  20 9F BE JSR sub_BE9F            
A152  00 A9    BRK #$A9                

; ==== data $A154..$A154  (1 bytes) ====
A154  10                                               |.
A155  A0 F6    LDY #$F6                
A157  4C 26 BF JMP loc_BF26            

loc_A15A:  ; 0 xrefs: 
A15A  BC 9A 04 LDY $049A,X             
A15D  B9 0C A2 LDA $A20C,Y             
A160  9D CE 05 STA $05CE,X             
A163  B9 1D A2 LDA $A21D,Y             
A166  9D E4 05 STA $05E4,X             

sub_A169:  ; 1 xrefs: A140
A169  BD CE 05 LDA $05CE,X             
A16C  85 00    STA $00                 
A16E  BD E4 05 LDA $05E4,X             
A171  85 01    STA $01                 
A173  BC FA 05 LDY $05FA,X             
A176  10 0E    BPL loc_A186            
A178  A0 00    LDY #$00                

loc_A17A:  ; 1 xrefs: A18B
A17A  98       TYA                     
A17B  9D FA 05 STA $05FA,X             
A17E  BD 10 06 LDA $0610,X             
A181  49 80    EOR #$80                
A183  9D 10 06 STA $0610,X             

loc_A186:  ; 1 xrefs: A176
A186  B1 00    LDA ($00),Y             
A188  D0 03    BNE loc_A18D            
A18A  88       DEY                     
A18B  D0 ED    BNE loc_A17A            

loc_A18D:  ; 1 xrefs: A188
A18D  29 FC    AND #$FC                
A18F  9D 26 06 STA $0626,X             
A192  BD 10 06 LDA $0610,X             
A195  0A       ASL A                   
A196  B1 00    LDA ($00),Y             
A198  29 03    AND #$03                
A19A  90 02    BCC loc_A19E            
A19C  49 01    EOR #$01                

loc_A19E:  ; 1 xrefs: A19A
A19E  A8       TAY                     
A19F  BD 00 04 LDA $0400,X             
A1A2  C9 0A    CMP #$0A                
A1A4  F0 05    BEQ loc_A1AB            
A1A6  98       TYA                     
A1A7  18       CLC                     
A1A8  69 04    ADC #$04                
A1AA  A8       TAY                     

loc_A1AB:  ; 1 xrefs: A1A4
A1AB  B9 EC A1 LDA $A1EC,Y             
A1AE  9D 76 05 STA $0576,X             
A1B1  B9 F4 A1 LDA $A1F4,Y             
A1B4  9D 60 05 STA $0560,X             
A1B7  B9 FC A1 LDA $A1FC,Y             
A1BA  9D 4A 05 STA $054A,X             
A1BD  B9 04 A2 LDA $A204,Y             
A1C0  9D 34 05 STA $0534,X             
A1C3  60       RTS                     

loc_A1C4:  ; 0 xrefs: 
A1C4  A9 EC    LDA #$EC                
A1C6  A0 08    LDY #$08                
A1C8  20 88 C8 JSR $C888               
A1CB  10 09    BPL loc_A1D6            
A1CD  A9 EC    LDA #$EC                
A1CF  A0 F8    LDY #$F8                
A1D1  20 88 C8 JSR $C888               
A1D4  10 14    BPL loc_A1EA            

loc_A1D6:  ; 1 xrefs: A1CB
A1D6  A9 14    LDA #$14                
A1D8  A0 08    LDY #$08                
A1DA  20 88 C8 JSR $C888               
A1DD  10 09    BPL loc_A1E8            
A1DF  A9 14    LDA #$14                
A1E1  A0 F8    LDY #$F8                

loc_A1E3:  ; 0 xrefs: 
A1E3  20 88 C8 JSR $C888               
A1E6  10 02    BPL loc_A1EA            

loc_A1E8:  ; 1 xrefs: A1DD
A1E8  18       CLC                     
A1E9  60       RTS                     

loc_A1EA:  ; 2 xrefs: A1D4 A1E6
A1EA  38       SEC                     
A1EB  60       RTS                     

; ==== data $A1EC..$A25F  (116 bytes) ====
A1EC  00 00 00 00 00 00 80 80 00 00 01 FF 00 00 00 FF  |................
A1FC  00 00 00 00 80 80 00 00 FF 01 00 00 FF 00 00 00  |................
A20C  2E 40 4D 59 5E 75 8D A2 B3 D2 F1 F5 FA FE 2E 01  |.@MY^u..........
A21C  05 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2 A2  |................
A22C  A3 A3 43 40 43 41 43 20 53 21 43 20 53 21 43 40  |..C@CAC S!C S!C@
A23C  43 41 53 00 1F 10 C7 83 83 83 83 83 83 C7 11 23  |CAS............#
A24C  00 52 60 53 60 52 60 53 60 52 60 53 00 E5 32 F1  |.R`S`R`S`R`S..2.
A25C  F1 00 E3 A3                                      |....

loc_A260:  ; 0 xrefs: 
A260  E1 E3    SBC ($E3,X)             
A262  E3 63    ISC ($63,X)             
A264  C0 83    CPY #$83                
A266  21 62    AND ($62,X)             
A268  21 23    AND ($23,X)             
A26A  21 22    AND ($22,X)             
A26C  41 E3    EOR ($E3,X)             
A26E  C0 83    CPY #$83                
A270  61 E3    ADC ($E3,X)             
A272  E3 A1    ISC ($A1,X)             
A274  00 62    BRK #$62                

; ==== data $A276..$A2E1  (108 bytes) ====
A276  A2 60 C3 21 22 41 E3 43 20 E3 A1 E3 E3 23 E0 43  |.`.!"A.C ....#.C
A286  61 63 60 E3 23 20 00 62 A2 61 C3 60 E3 43 21 E3  |ac`.# .b.a.`.C!.
A296  A0 E3 C3 E1 63 60 63 61 E3 23 21 00 E3 C3 E0 E3  |....c`ca.#!.....
A2A6  E3 23 E1 C3 E0 82 81 E3 E3 E3 23 81 00 E2 E2 22  |.#........#...."
A2B6  E0 22 A1 E2 42 A0 62 61 E2 60 83 81 E2 62 21 82  |."..B.ba.`...b!.
A2C6  21 82 21 82 40 83 20 E2 E2 42 81 00 A2 21 43 A1  |!.!.@. ..B...!C.
A2D6  E2 E2 82 41 C3 20 E2 A2 20 63 40 82              |...A. .. c@.

loc_A2E2:  ; 0 xrefs: 
A2E2  21 82    AND ($82,X)             
A2E4  21 82    AND ($82,X)             
A2E6  21 63    AND ($63,X)             
A2E8  21 E2    AND ($E2,X)             
A2EA  E2 E2    NOP #$E2                

; ==== data $A2EC..$A3CF  (228 bytes) ====
A2EC  42 60 A2 61 00 60 E3 A3 00 41 E3 E3 23 00 61 E3  |B`.a.`...A..#.a.
A2FC  E3 00 E3 E3 00 E2 E2 22 00 E3 E3 23 00 20 7E C9  |......."...#. ~.
A30C  19 A3 51 A3 8D A3 20 7E C9 51 A3 8D A3 A0 08 20  |..Q... ~.Q..... 
A31C  36 C9 A0 FF 20 30 C9 BC 9A 04 8A 29 07 18 79 33  |6... 0.....)..y3
A32C  A3 9D CE 05 4C 66 C9 70 04 70 05 70 06 73 07 10  |....Lf.p.p.p.s..
A33C  08 10 09 10 0A 10 0B 10 0C 10 0D 00 00 50 0F 40  |.............P.@
A34C  10 A0 0F A0 10 DE CE 05 F0 01 60 20 98 BE 20 BD  |..........` .. .
A35C  00 04 C9 47 F0 1F A9 47 85 24 A9 00 A8 20 DF C8  |...G...G.$... ..
A36C  B0 1C BC 9A 04 B9 34 A3 A4 12 9D 9A 04 99 9A 04  |......4.........
A37C  A9 61 99 CE 05 20 5A A1 20 D0 A3 4C 66 C9 4C 10  |.a... Z. ..Lf.L.
A38C  C8 BD 10 06 30 F8 AD 66 01 D0 12 EE 66 01 EE 65  |....0..f....f..e
A39C  01 AD 65 01 29 1F D0 05 A9 11 20 1C C8 20 F1 C8  |..e.)..... .. ..
A3AC  DE 26 06 D0 06 FE FA 05 20 69 A1 BD 00 04 C9 0F  |.&...... i......
A3BC  D0 0C A9 00 8D 64 01 A9 07 A0 F1 20 26 BF DE 3C  |.....d..... &..<
A3CC  06 F0 01 60                                      |...`

loc_A3D0:  ; 0 xrefs: 
A3D0  20 C1 A4 JSR sub_A4C1            
A3D3  20 CD A4 JSR sub_A4CD            
A3D6  20 D9 A4 JSR sub_A4D9            
A3D9  20 F8 A4 JSR sub_A4F8            
A3DC  B0 27    BCS loc_A405            
A3DE  AC 60 01 LDY $0160               
A3E1  BD 00 04 LDA $0400,X             
A3E4  C9 0F    CMP #$0F                
A3E6  F0 09    BEQ loc_A3F1            
A3E8  AD 61 01 LDA $0161               
A3EB  20 A9 C8 JSR $C8A9               
A3EE  4C F7 A3 JMP loc_A3F7            

loc_A3F1:  ; 1 xrefs: A3E6
A3F1  AD 61 01 LDA $0161               
A3F4  20 AC C8 JSR $C8AC               

loc_A3F7:  ; 1 xrefs: A3EE
A3F7  BD 00 04 LDA $0400,X             
A3FA  C9 0F    CMP #$0F                
A3FC  F0 07    BEQ loc_A405            
A3FE  A9 20    LDA #$20                
A400  9D 3C 06 STA $063C,X             
A403  D0 52    BNE loc_A457            

loc_A405:  ; 2 xrefs: A3DC A3FC
A405  20 98 BE JSR sub_BE98            
A408  20 BD 60 JSR $60BD               
A40B  05 1D    ORA $1D                 
A40D  76 05    ROR $05,X               
A40F  D0 23    BNE loc_A434            
A411  A9 00    LDA #$00                
A413  85 10    STA $10                 
A415  A9 10    LDA #$10                
A417  BC 34 05 LDY $0534,X             
A41A  10 04    BPL loc_A420            
A41C  A9 F0    LDA #$F0                
A41E  C6 10    DEC $10                 

loc_A420:  ; 1 xrefs: A41A
A420  18       CLC                     
A421  7D C6 04 ADC $04C6,X             
A424  8D 60 01 STA $0160               
A427  BD B0 04 LDA $04B0,X             
A42A  65 10    ADC $10                 
A42C  85 10    STA $10                 
A42E  20 CD A4 JSR sub_A4CD            
A431  4C 54 A4 JMP loc_A454            

loc_A434:  ; 1 xrefs: A40F
A434  A9 00    LDA #$00                
A436  85 11    STA $11                 
A438  A9 10    LDA #$10                
A43A  BC 60 05 LDY $0560,X             
A43D  10 04    BPL loc_A443            
A43F  C6 11    DEC $11                 
A441  A9 F0    LDA #$F0                

loc_A443:  ; 1 xrefs: A43D
A443  18       CLC                     
A444  7D 08 05 ADC $0508,X             
A447  8D 61 01 STA $0161               
A44A  BD F2 04 LDA $04F2,X             
A44D  65 11    ADC $11                 
A44F  85 11    STA $11                 
A451  20 C1 A4 JSR sub_A4C1            

loc_A454:  ; 1 xrefs: A431
A454  20 D9 A4 JSR sub_A4D9            

loc_A457:  ; 1 xrefs: A403
A457  A0 04    LDY #$04                
A459  BD 00 04 LDA $0400,X             
A45C  C9 0F    CMP #$0F                
A45E  D0 0A    BNE loc_A46A            
A460  A0 00    LDY #$00                
A462  A5 53    LDA $53                 
A464  C9 04    CMP #$04                
A466  F0 02    BEQ loc_A46A            
A468  A0 02    LDY #$02                

loc_A46A:  ; 2 xrefs: A45E A466
A46A  8C 62 01 STY $0162               
A46D  20 F8 A4 JSR sub_A4F8            
A470  B0 42    BCS loc_A4B4            
A472  AC 60 01 LDY $0160               
A475  AD 61 01 LDA $0161               
A478  20 A6 C8 JSR $C8A6               
A47B  20 8E A4 JSR sub_A48E            
A47E  EE 62 01 INC $0162               
A481  AD 60 01 LDA $0160               
A484  18       CLC                     
A485  69 08    ADC #$08                
A487  A8       TAY                     
A488  AD 61 01 LDA $0161               
A48B  20 A6 C8 JSR $C8A6               

sub_A48E:  ; 1 xrefs: A47B
A48E  86 25    STX $25                 
A490  20 40 C8 JSR $C840               
A493  A5 08    LDA $08                 
A495  20 49 C8 JSR $C849               
A498  A5 09    LDA $09                 
A49A  20 49 C8 JSR $C849               
A49D  AC 62 01 LDY $0162               
A4A0  B9 B5 A4 LDA $A4B5,Y             
A4A3  20 49 C8 JSR $C849               
A4A6  AC 62 01 LDY $0162               
A4A9  B9 BB A4 LDA $A4BB,Y             
A4AC  20 49 C8 JSR $C849               
A4AF  20 46 C8 JSR $C846               
A4B2  A6 25    LDX $25                 

loc_A4B4:  ; 1 xrefs: A470
A4B4  60       RTS                     

; ==== data $A4B5..$A4C0  (12 bytes) ====
A4B5  5E 60 65 67 00 00 5F 61 66 68 00 00              |^`eg.._afh..

sub_A4C1:  ; 2 xrefs: A3D0 A451
A4C1  BD C6 04 LDA $04C6,X             
A4C4  8D 60 01 STA $0160               
A4C7  BD B0 04 LDA $04B0,X             
A4CA  85 10    STA $10                 
A4CC  60       RTS                     

sub_A4CD:  ; 2 xrefs: A3D3 A42E
A4CD  BD 08 05 LDA $0508,X             
A4D0  8D 61 01 STA $0161               
A4D3  BD F2 04 LDA $04F2,X             
A4D6  85 11    STA $11                 
A4D8  60       RTS                     

sub_A4D9:  ; 2 xrefs: A3D6 A454
A4D9  AD 60 01 LDA $0160               
A4DC  38       SEC                     
A4DD  E9 0F    SBC #$0F                
A4DF  8D 60 01 STA $0160               
A4E2  A5 10    LDA $10                 
A4E4  E9 00    SBC #$00                
A4E6  85 10    STA $10                 
A4E8  AD 61 01 LDA $0161               
A4EB  38       SEC                     
A4EC  E9 08    SBC #$08                
A4EE  8D 61 01 STA $0161               
A4F1  A5 11    LDA $11                 
A4F3  E9 00    SBC #$00                
A4F5  85 11    STA $11                 
A4F7  60       RTS                     

sub_A4F8:  ; 2 xrefs: A3D9 A46D
A4F8  A5 10    LDA $10                 
A4FA  D0 0D    BNE loc_A509            
A4FC  AD 60 01 LDA $0160               
A4FF  C9 BF    CMP #$BF                
A501  B0 06    BCS loc_A509            
A503  A5 11    LDA $11                 
A505  D0 02    BNE loc_A509            
A507  18       CLC                     
A508  60       RTS                     

loc_A509:  ; 3 xrefs: A4FA A501 A505
A509  38       SEC                     
A50A  60       RTS                     

; ==== data $A50B..$A51F  (21 bytes) ====
A50B  20 7E C9 18 A5 2B A5 50 A5 39 A5 2C A6 20 15 A7  | ~...+.P.9.,. ..
A51B  A0 01 BD 9A 04                                   |.....

loc_A520:  ; 0 xrefs: 
A520  29 7F    AND #$7F                
A522  F0 02    BEQ loc_A526            
A524  A0 03    LDY #$03                

loc_A526:  ; 1 xrefs: A522
A526  98       TYA                     
A527  9D 8C 05 STA $058C,X             
A52A  60       RTS                     

; ==== data $A52B..$A55F  (53 bytes) ====
A52B  DE CE 05 30 09 AD 8C 05 C9 08 F0 02 D0 13 A5 5C  |...0...........\
A53B  30 0A 20 66 C9 A9 00 9D E4 05 F0 02 A9 40 9D CE  |0. f.........@..
A54B  05 60 4C 69 C9 A5 5C 30 F9 FE E4 05 AD 8C 05 C9  |.`Li..\0........
A55B  08 F0 18 A0 D0                                   |.....

loc_A560:  ; 0 xrefs: 
A560  20 FC A5 JSR sub_A5FC            
A563  F0 10    BEQ loc_A575            
A565  A9 00    LDA #$00                
A567  8D FA 05 STA $05FA               
A56A  8D 4A 05 STA $054A               
A56D  A9 FF    LDA #$FF                
A56F  8D 10 06 STA $0610               
A572  8D 34 05 STA $0534               

loc_A575:  ; 1 xrefs: A563
A575  60       RTS                     

; ==== data $A576..$A5FB  (134 bytes) ====
A576  AD 34 05 10 2A C9 FF F0 26 A0 80 20 FC A5 F0 1E  |.4..*...&.. ....
A586  A9 E4 AC 34 05 C0 FB B0 02 A9 EC 85 00 AD 4A 05  |...4..........J.
A596  18 65 00 8D 4A 05 AD 34 05 69 FF 8D 34 05 60 A5  |.e..J..4.i..4.`.
A5A6  1C 4A 29 0F A8 B9 EC A5 A8 20 FC A5 F0 F0 A9 FF  |.J)...... ......
A5B6  8D 34 05 A9 CE 8D 4A 05 AD 64 01 C9 01 D0 1C A5  |.4....J..d......
A5C6  0A 38 ED 1E 01 F0 07 C9 FE 90 10 20 1C BF A9 01  |.8......... ....
A5D6  8D 10 06 A9 00 8D FA 05 4C 0F A6 A9 00 8D FA 05  |........L.......
A5E6  A9 FE 8D 10 06 60 CC CB CA C9 C8 C7 C6 C5 C4 C5  |.....`..........
A5F6  C6 C7 C8 C9 CA CB                                |......

sub_A5FC:  ; 1 xrefs: A560
A5FC  BD 9A 04 LDA $049A,X             
A5FF  10 05    BPL loc_A606            
A601  98       TYA                     
A602  18       CLC                     
A603  69 E0    ADC #$E0                
A605  A8       TAY                     

loc_A606:  ; 1 xrefs: A5FF
A606  A9 22    LDA #$22                
A608  20 20 BF JSR sub_BF20            
A60B  AD 64 01 LDA $0164               
A60E  60       RTS                     

loc_A60F:  ; 0 xrefs: 
A60F  BD E4 05 LDA $05E4,X             
A612  C9 D0    CMP #$D0                
A614  B0 12    BCS loc_A628            
A616  A0 00    LDY #$00                
A618  8C 76 05 STY $0576               
A61B  8C 60 05 STY $0560               
A61E  A5 4A    LDA $4A                 
A620  4A       LSR A                   
A621  B0 02    BCS loc_A625            
A623  A0 80    LDY #$80                

loc_A625:  ; 1 xrefs: A621
A625  8C 1E 05 STY $051E               

loc_A628:  ; 1 xrefs: A614
A628  60       RTS                     

; ==== data $A629..$A660  (56 bytes) ====
A629  4C 69 C9 A5 5C 30 F9 A9 28 A0 B0 20 20 BF AD 64  |Li..\0..(..  ..d
A639  01 F0 0F BC 9A 04 B9 4B A6 8D CE 05 B9 4D A6 8D  |.......K.....M..
A649  E4 05 60 00 00 02 FE A9 07 A0 DE 20 20 BF 20 61  |..`........  . a
A659  A6 A9 07 A0 DE 4C 26 BF                          |.....L&.

loc_A661:  ; 0 xrefs: 
A661  20 7E C9 JSR $C97E               
A664  6C A6 8E JMP ($8EA6)             

; ==== data $A667..$A714  (174 bytes) ====
A667  A6 BA A6 FE A6 20 15 A7 20 39 C9 29 1F 69 1F 9D  |..... .. 9.).i..
A677  CE 05 BD 9A 04 9D E4 05 20 5A BE 10 8A 9D FA 05  |........ Z......
A687  20 AD BE 0E 4C 66 C9 BD CE 05 D0 1A BD E4 05 4A  | ...Lf.........J
A697  90 F2 BC FA 05 B9 00 04 C9 2C F0 16 C9 2D F0 12  |.........,...-..
A6A7  C9 2E F0 0E D0 DE 20 02 9D B0 07 C9 10 90 03 DE  |...... .........
A6B7  CE 05 60 20 37 C8 BD 42 04 C9 40 D0 F5 20 C3 C9  |..` 7..B..@.. ..
A6C7  B0 32 20 02 9D B0 2D C9 10 90 29 86 25 20 24 C9  |.2 ...-...).% $.
A6D7  20 6A C8 B0 1D 20 27 C9 A4 25 B9 E4 05 4A B0 04  | j... '..%...J..
A6E7  A9 1F D0 0B A9 06 9D 8C 05 8A 99 FA 05 A9 2C 9D  |..............,.
A6F7  00 04 A6 25 4C 66 C9 20 37 C8 C9 3D D0 0F A9 28  |...%Lf. 7..=...(
A707  BC E4 05 10 02 A9 78 9D CE 05 4C 6F C9 60        |......x...Lo.`

loc_A715:  ; 0 xrefs: 
A715  A4 97    LDY $97                 
A717  D0 05    BNE loc_A71E            
A719  A0 08    LDY #$08                
A71B  4C 36 C9 JMP $C936               

loc_A71E:  ; 1 xrefs: A717
A71E  60       RTS                     

; ==== data $A71F..$A743  (37 bytes) ====
A71F  20 7E C9 2A A7 48 A7 5F A7 A2 A7 20 5A BE 01 20  | ~.*.H._... Z.. 
A72F  AD BE 0F 20 93 C9 20 C5 BE 00 FF 20 00 BF F0 FF  |... .. .... ....
A73F  F1 10 03 20 1B                                   |... .

loc_A744:  ; 1 xrefs: A799
A744  C9 4C    CMP #$4C                
A746  66 C9    ROR $C9                 
A748  20 C7 9B JSR sub_9BC7            
A74B  B0 0F    BCS loc_A75C            
A74D  20 E3 BE JSR sub_BEE3            
A750  08       PHP                     
A751  06 30    ASL $30                 
A753  08       PHP                     
A754  20 B9 BE JSR sub_BEB9            
A757  00 00    BRK #$00                

; ==== data $A759..$A75B  (3 bytes) ====
A759  20 66 C9                                         | f.

loc_A75C:  ; 1 xrefs: A74B
A75C  4C 88 A7 JMP loc_A788            

; ==== data $A75F..$A787  (41 bytes) ====
A75F  20 C7 9B B0 0A 20 DD BE 08 06 10 09 20 81 C9 20  | .... ...... .. 
A76F  69 C9 4C 88 A7 A9 20 20 0C C9 BD 34 05 C9 04 D0  |i.L...  ...4....
A77F  05 20 B9 BE 00 04 20 F4 C8                       |. .... ..

loc_A788:  ; 1 xrefs: A75C
A788  20 37 C8 JSR $C837               
A78B  20 06 BF JSR sub_BF06            
A78E  F6 FF    INC $FF,X               
A790  F1 30    SBC ($30),Y             
A792  03 4C    SLO ($4C,X)             
A794  F7 C8    ISC $C8,X               
A796  20 7C BE JSR sub_BE7C            
A799  10 A9    BPL loc_A744            
A79B  01 20    ORA ($20,X)             
A79D  3A       NOP                     
A79E  C8       INY                     
A79F  4C 75 C9 JMP $C975               

; ==== data $A7A2..$A8A8  (263 bytes) ====
A7A2  DE E4 05 D0 03 4C 10 C8 4C 37 C8 BD 8C 05 D0 37  |.....L..L7.....7
A7B2  BD 9A 04 29 03 9D 26 06 BD 9A 04 20 BD C9 20 5A  |...)..&.... .. Z
A7C2  BE 01 BD 26 06 A8 18 69 25 9D 42 04 B9 E3 A7 9D  |...&...i%.B.....
A7D2  CE 05 B9 E6 A7 9D E4 05 FE FA 05 FE 10 06 4C 66  |..............Lf
A7E2  C9 40 80 00 C0 00 80 20 C3 C9 90 09 20 9F BE 00  |.@..... .... ...
A7F2  20 8A BE 10 60 A0 00 A9 10 20 C6 C9 BD 52 06 D0  | ...`.... ...R..
A802  27 DE 10 06 D0 EE BD CE 05 DD E4 05 F0 10 BD E4  |'...............
A812  05 38 FD CE 05 18 69 08 C9 11 90 02 B0 D2 20 98  |.8....i....... .
A822  BE 03 FE 52 06 FE 10 06 DE 10 06 D0 5A 20 8A BE  |...R........Z ..
A832  10 BD CE 05 BC 26 06 18 79 8A A8 C9 81 B0 3B 20  |.....&..y.....; 
A842  6D C8 C9 80 B0 34 20 70 C8 C9 80 B0 2D A9 2A 85  |m....4 p....-.*.
A852  24 BC 26 06 B9 90 A8 48 B9 8D A8 A8 68 20 DF C8  |$.&....H....h ..
A862  B0 25 A6 12 20 75 BE 05 A4 25 B9 CE 05 18 69 08  |.%.. u...%....i.
A872  29 F0 A8 A9 0C 20 AF C8 A6 25 DE 3C 06 D0 08 20  |).... ...%.<... 
A882  9F BE 00 20 8A BE 90 60 00 C0 40 04 00 00 00 FE  |... ...`..@.....
A892  02 BD CE 05 F0 0C DE CE 05 D0 0E 20 A2 C9 20 6E  |........... .. n
A8A2  BE 2A 20 CB BE 00 00                             |.* ....

loc_A8A9:  ; 0 xrefs: 
A8A9  30 06    BMI loc_A8B1            
A8AB  20 D2 C9 JSR $C9D2               
A8AE  4C F1 C8 JMP $C8F1               

loc_A8B1:  ; 1 xrefs: A8A9
A8B1  4C 10 C8 JMP $C810               

; ==== data $A8B4..$A91D  (106 bytes) ====
A8B4  20 7E C9 C5 A8 FD A8 21 A9 39 A9 3F A9 39 A9 51  | ~.....!.9.?.9.Q
A8C4  A9 BD E4 05 D0 0C 20 3C C9 70 2D C9 20 B0 29 FE  |...... <.p-. .).
A8D4  E4 05 86 25 20 6A C8 B0 10 A4 25 20 63 C9 20 1B  |...% j....% c. .
A8E4  C9 FE 8C 05 A6 25 4C 66 C9 A6 25 FE CE 05 BD CE  |.....%Lf..%.....
A8F4  05 C9 40 D0 03 4C 10 C8 60 A0 B0 20 90 C9 90 02  |..@..L..`.. ....
A904  A0 50 20 36 C9 20 5A BE FF 20 6E BE 70 20 B9 BE  |.P 6. Z.. n.p ..
A914  00 FF A9 30 9D CE 05 9D E4 05                    |...0......

loc_A91E:  ; 1 xrefs: A94F
A91E  4C 66 C9 JMP $C966               

; ==== data $A921..$A921  (1 bytes) ====
A921  DE                                               |.
A922  CE 05 F0 DEC $F005               
A925  03 4C    SLO ($4C,X)             
A927  F4 C8    NOP $C8,X               
A929  20 C5 BE JSR sub_BEC5            
A92C  80 01    NOP #$01                
A92E  20 83 BE JSR sub_BE83            
A931  35 20    AND $20,X               
A933  75 BE    ADC $BE,X               
A935  30 4C    BMI loc_A983            
A937  1E A9 DE ASL $DEA9,X             
A93A  CE 05 F0 DEC $F005               
A93D  E0 60    CPX #$60                
A93F  DE FA 05 DEC $05FA,X             
A942  F0 03    BEQ loc_A947            
A944  4C F7 C8 JMP $C8F7               

loc_A947:  ; 1 xrefs: A942
A947  20 21 C9 JSR $C921               
A94A  A9 30    LDA #$30                
A94C  9D CE 05 STA $05CE,X             
A94F  D0 CD    BNE loc_A91E            
A951  DE E4 05 DEC $05E4,X             
A954  D0 03    BNE loc_A959            
A956  4C 10 C8 JMP $C810               

loc_A959:  ; 1 xrefs: A954
A959  4C F4 C8 JMP $C8F4               

; ==== data $A95C..$A97C  (33 bytes) ====
A95C  A9 E8 20 A5 9B 20 7D A9 BD 42 04 C9 48 F0 0C C9  |.. .. }..B..H...
A96C  47 F0 04 A9 2C D0 06 A9 2E D0 02 A9 2D 9D 00 04  |G...,.......-...
A97C  60                                               |`

loc_A97D:  ; 0 xrefs: 
A97D  20 7E C9 JSR $C97E               
A980  9D A9 AB STA $ABA9,X             

loc_A983:  ; 1 xrefs: A935
A983  A9 D8    LDA #$D8                
A985  A9 28    LDA #$28                
A987  AA       TAX                     
A988  88       DEY                     
A989  AA       TAX                     
A98A  2B AA    ANC #$AA                
A98C  8E A9 20 STX $20A9               

; ==== data $A98F..$A9A8  (26 bytes) ====
A98F  9F C9 20 18 AA 20 75 BE 50 20 83 BE 40 60 20 9F  |.. .. u.P ..@` .
A99F  C9 20 AD BE 19 20 75 BE 80 4C                    |. ... u..L

loc_A9A9:  ; 0 xrefs: 
A9A9  66 C9    ROR $C9                 
A9AB  20 02 AB JSR sub_AB02            
A9AE  20 FD C8 JSR $C8FD               
A9B1  BD 42 04 LDA $0442,X             
A9B4  C9 47    CMP #$47                
A9B6  D0 0E    BNE loc_A9C6            
A9B8  A9 20    LDA #$20                
A9BA  A0 10    LDY #$10                
A9BC  20 CF AA JSR sub_AACF            

loc_A9BF:  ; 0 xrefs: 
A9BF  70 04    BVS loc_A9C5            
A9C1  B0 02    BCS loc_A9C5            
A9C3  90 04    BCC loc_A9C9            

loc_A9C5:  ; 2 xrefs: A9BF A9C1
A9C5  60       RTS                     

loc_A9C6:  ; 1 xrefs: A9B6
A9C6  4C 37 C8 JMP $C837               

loc_A9C9:  ; 1 xrefs: A9C3
A9C9  20 75 BE JSR sub_BE75            
A9CC  80 20    NOP #$20                
A9CE  7C BE 28 NOP $28BE,X             
A9D1  20 6E BE JSR sub_BE6E            
A9D4  45 4C    EOR $4C                 

; ==== data $A9D6..$AA17  (66 bytes) ====
A9D6  72 C9 20 02 AB BD CE 05 D0 25 A9 30 A0 20 20 CF  |r. ......%.0.  .
A9E6  AA 70 2E 90 0B 20 75 BE 40 20 AD BE 19 4C 69 C9  |.p... u.@ ...Li.
A9F6  8A 4D 19 01 29 01 D0 19 20 E0 AA B0 05 90 13 DE  |.M..)... .......
AA06  CE 05 DE E4 05 D0 0A 20 FD C8 20 B0 AA 20 7C BE  |....... .. .. |.
AA16  38 60                                            |8`

loc_AA18:  ; 0 xrefs: 
AA18  20 AD BE JSR sub_BEAD            
AA1B  18       CLC                     
AA1C  20 BF BE JSR sub_BEBF            
AA1F  C0 FE    CPY #$FE                
AA21  20 75 BE JSR sub_BE75            
AA24  FF 4C 75 ISC $754C,X             
AA27  C9 20    CMP #$20                

; ==== data $AA29..$AAAC  (132 bytes) ====
AA29  02 AB 20 E0 AA 90 0C BD FA 05 D0 04 20 75 BE 01  |.. ......... u..
AA39  20 1B C9 DE CE 05 F0 41 20 3C C9 70 24 C9 40 B0  | ......A <.p$.@.
AA49  20 20 8D C9 B0 1B A9 20 A0 10 20 CF AA 70 2A B0  |  ..... .. ..p*.
AA59  10 20 C5 BE 80 FD 20 6E BE 48 20 75 BE 18 4C 78  |. .... n.H u..Lx
AA69  C9 BD FA 05 D0 0D A9 30 A0 20 20 CF AA 70 0A B0  |.......0.  ..p..
AA79  08 90 03 DE FA 05 4C EE C8 20 FD C8 4C C9 A9 DE  |......L.. ..L...
AA89  CE 05 F0 05 20 E0 AA 90 0B 20 75 BE 20 20 6E BE  |.... .... u.  n.
AA99  47 4C 6F C9 A9 02 BC 60 05 30 06 20 15 C9 4C AD  |GLo....`.0. ..L.
AAA9  AA 20 12 C9                                      |. ..

loc_AAAD:  ; 0 xrefs: 
AAAD  4C F7 C8 JMP $C8F7               

loc_AAB0:  ; 0 xrefs: 
AAB0  A9 16    LDA #$16                
AAB2  85 24    STA $24                 
AAB4  A9 0C    LDA #$0C                
AAB6  85 26    STA $26                 
AAB8  20 90 C9 JSR $C990               
AABB  90 06    BCC loc_AAC3            
AABD  A0 00    LDY #$00                
AABF  A9 10    LDA #$10                
AAC1  D0 04    BNE loc_AAC7            

loc_AAC3:  ; 1 xrefs: AABB
AAC3  A0 80    LDY #$80                
AAC5  A9 F0    LDA #$F0                

loc_AAC7:  ; 1 xrefs: AAC1
AAC7  84 06    STY $06                 
AAC9  A0 E9    LDY #$E9                
AACB  4C E5 C8 JMP $C8E5               

; ==== data $AACE..$AACE  (1 bytes) ====
AACE  60                                               |`

sub_AACF:  ; 2 xrefs: A9BC AB1F
AACF  85 00    STA $00                 
AAD1  84 01    STY $01                 
AAD3  20 3F C9 JSR $C93F               
AAD6  70 07    BVS loc_AADF            
AAD8  90 03    BCC loc_AADD            
AADA  C5 00    CMP $00                 
AADC  60       RTS                     

loc_AADD:  ; 1 xrefs: AAD8
AADD  C5 01    CMP $01                 

loc_AADF:  ; 1 xrefs: AAD6
AADF  60       RTS                     

loc_AAE0:  ; 0 xrefs: 
AAE0  20 06 BF JSR sub_BF06            
AAE3  EC FF EC CPX $ECFF               
AAE6  30 18    BMI loc_AB00            
AAE8  A0 F6    LDY #$F6                
AAEA  20 90 C9 JSR $C990               
AAED  90 02    BCC loc_AAF1            
AAEF  A0 0A    LDY #$0A                

loc_AAF1:  ; 1 xrefs: AAED
AAF1  98       TYA                     
AAF2  A0 04    LDY #$04                
AAF4  20 48 C9 JSR $C948               
AAF7  30 05    BMI loc_AAFE            
AAF9  20 44 9C JSR sub_9C44            
AAFC  90 02    BCC loc_AB00            

loc_AAFE:  ; 1 xrefs: AAF7
AAFE  18       CLC                     
AAFF  60       RTS                     

loc_AB00:  ; 2 xrefs: AAE6 AAFC
AB00  38       SEC                     
AB01  60       RTS                     

sub_AB02:  ; 1 xrefs: A9AB
AB02  A5 9A    LDA $9A                 
AB04  F0 3E    BEQ loc_AB44            
AB06  AD 16 04 LDA $0416               
AB09  29 10    AND #$10                
AB0B  F0 37    BEQ loc_AB44            
AB0D  BD 2C 04 LDA $042C,X             
AB10  4D 2C 04 EOR $042C               
AB13  29 40    AND #$40                
AB15  D0 2D    BNE loc_AB44            
AB17  20 8D C9 JSR $C98D               
AB1A  B0 28    BCS loc_AB44            
AB1C  A9 04    LDA #$04                
AB1E  A8       TAY                     
AB1F  20 CF AA JSR sub_AACF            
AB22  70 20    BVS loc_AB44            
AB24  B0 1E    BCS loc_AB44            
AB26  20 3C C9 JSR $C93C               
AB29  70 19    BVS loc_AB44            
AB2B  C9 40    CMP #$40                
AB2D  B0 15    BCS loc_AB44            
AB2F  20 75 BE JSR sub_BE75            
AB32  35 20    AND $20,X               
AB34  AD BE 18 LDA $18BE               
AB37  20 BF BE JSR sub_BEBF            
AB3A  80 FE    NOP #$FE                
AB3C  20 1B C9 JSR $C91B               
AB3F  68       PLA                     
AB40  68       PLA                     
AB41  4C 7B C9 JMP $C97B               

loc_AB44:  ; 8 xrefs: AB04 AB0B AB15 AB1A AB22 AB24 AB29 AB2D
AB44  60       RTS                     

; ==== data $AB45..$ABFC  (184 bytes) ====
AB45  20 7E C9 52 AB 78 AB 97 AB B9 AB DE AB 20 5A BE  | ~.R.x....... Z.
AB55  FF 20 AD BE 0C BD CE 05 D0 0C A9 9A 9D C6 04 A9  |. ..............
AB65  EE 9D 08 05 D0 1E 20 08 AC 9D C6 04 A9 12 9D 08  |...... .........
AB75  05 D0 58 20 FD AB A9 EE DD 08 05 B0 14 9D 08 05  |..X ............
AB85  A5 00 D0 0D 20 B3 BE 00 00 20 B9 BE 00 FF 4C 72  |.... .... ....Lr
AB95  C9 60 20 FD AB 20 08 AC A5 01 DD C6 04 90 14 9D  |.` .. ..........
ABA5  C6 04 A5 00 D0 0D 20 B9 BE 00 00 20 B3 BE 00 FF  |...... .... ....
ABB5  4C 75 C9 60 20 FD AB 20 08 AC 9D C6 04 A9 12 DD  |Lu.` .. ........
ABC5  08 05 90 14 9D 08 05 A5 00 D0 0D 20 B9 BE 00 01  |........... ....
ABD5  20 B3 BE 00 00 4C 78 C9 60 20 FD AB A9 9A DD C6  | ....Lx.` ......
ABE5  04 B0 14 9D C6 04 A5 00 D0 0D 20 B9 BE 00 00 20  |.......... .... 
ABF5  B3 BE 00 01 4C 6F C9 60                          |....Lo.`

loc_ABFD:  ; 0 xrefs: 
ABFD  20 EE C8 JSR $C8EE               
AC00  AD 19 01 LDA $0119               
AC03  29 07    AND #$07                
AC05  85 00    STA $00                 
AC07  60       RTS                     

loc_AC08:  ; 0 xrefs: 
AC08  A9 24    LDA #$24                
AC0A  85 01    STA $01                 
AC0C  60       RTS                     

; ==== data $AC0D..$ACAE  (162 bytes) ====
AC0D  BD 8C 05 D0 0B 20 5A BE 8F 20 6E BE D8 4C 66 C9  |..... Z.. n..Lf.
AC1D  BD 9A 04 C9 8F D0 06 20 D2 C9 4C EB C8 4C C0 C9  |....... ..L..L..
AC2D  20 7E C9 36 AC 51 AC 8C AC 20 5A BE 08 A9 26 9D  | ~.6.Q... Z...&.
AC3D  C6 04 A9 55 BC CE 05 F0 02 A9 AD 9D 08 05 20 AF  |...U.......... .
AC4D  AC 4C 66 C9 DE E4 05 F0 2F 20 F7 C8 BD CE 05 D0  |.Lf...../ ......
AC5D  12 BD 08 05 BC 60 05 30 05 C9 78 B0 18 60 C9 18  |.....`.0..x..`..
AC6D  90 13 60 BD 08 05 BC 60 05 10 05 C9 88 90 06 60  |..`....`.......`
AC7D  C9 E8 B0 01 60 4C 1E C9 20 7C BE 30 4C 66 C9 DE  |....`L.. |.0Lf..
AC8D  E4 05 F0 1B BD E4 05 C9 14 D0 10 A9 21 85 24 A9  |............!.$.
AC9D  02 A0 06 20 DF C8 A9 38 20 1C C8 20 37 C8 60 20  |... ...8 .. 7.` 
ACAD  69 C9                                            |i.

loc_ACAF:  ; 0 xrefs: 
ACAF  20 AD BE JSR sub_BEAD            
ACB2  3D 20 39 AND $3920,X             
ACB5  C9 29    CMP #$29                
ACB7  07 69    SLO $69                 
ACB9  09 0A    ORA #$0A                
ACBB  0A       ASL A                   
ACBC  0A       ASL A                   
ACBD  0A       ASL A                   
ACBE  9D E4 05 STA $05E4,X             
ACC1  20 C5 BE JSR sub_BEC5            
ACC4  80 FF    NOP #$FF                
ACC6  20 39 C9 JSR $C939               
ACC9  4A       LSR A                   
ACCA  90 03    BCC loc_ACCF            
ACCC  4C 1E C9 JMP $C91E               

loc_ACCF:  ; 1 xrefs: ACCA
ACCF  60       RTS                     

sub_ACD0:  ; 5 xrefs: B28D B337 B5E1 B7FF BBB0
ACD0  20 B4 C9 JSR $C9B4               
ACD3  85 00    STA $00                 
ACD5  98       TYA                     
ACD6  85 01    STA $01                 
ACD8  BD FA 05 LDA $05FA,X             
ACDB  38       SEC                     
ACDC  E5 01    SBC $01                 
ACDE  85 01    STA $01                 
ACE0  BD 10 06 LDA $0610,X             
ACE3  E5 00    SBC $00                 
ACE5  85 00    STA $00                 
ACE7  A5 01    LDA $01                 
ACE9  A4 00    LDY $00                 
ACEB  30 0F    BMI loc_ACFC            
ACED  C0 01    CPY #$01                
ACEF  F0 04    BEQ loc_ACF5            
ACF1  C9 80    CMP #$80                
ACF3  90 17    BCC loc_AD0C            

loc_ACF5:  ; 1 xrefs: ACEF
ACF5  BD 60 05 LDA $0560,X             
ACF8  30 0F    BMI loc_AD09            
ACFA  10 10    BPL loc_AD0C            

loc_ACFC:  ; 1 xrefs: ACEB
ACFC  C0 FE    CPY #$FE                
ACFE  F0 04    BEQ loc_AD04            
AD00  C9 80    CMP #$80                
AD02  B0 08    BCS loc_AD0C            

loc_AD04:  ; 1 xrefs: ACFE
AD04  BD 60 05 LDA $0560,X             
AD07  30 03    BMI loc_AD0C            

loc_AD09:  ; 1 xrefs: ACF8
AD09  A9 80    LDA #$80                
AD0B  60       RTS                     

loc_AD0C:  ; 4 xrefs: ACF3 ACFA AD02 AD07
AD0C  A9 00    LDA #$00                
AD0E  60       RTS                     

loc_AD0F:  ; 0 xrefs: 
AD0F  20 C3 C9 JSR $C9C3               
AD12  B0 4C    BCS loc_AD60            
AD14  20 8D C9 JSR $C98D               
AD17  B0 47    BCS loc_AD60            
AD19  A0 01    LDY #$01                

loc_AD1B:  ; 1 xrefs: AD5E
AD1B  B9 60 05 LDA $0560,Y             
AD1E  19 76 05 ORA $0576,Y             
AD21  F0 38    BEQ loc_AD5B            
AD23  B9 34 05 LDA $0534,Y             
AD26  19 4A 05 ORA $054A,Y             
AD29  D0 30    BNE loc_AD5B            
AD2B  BD C6 04 LDA $04C6,X             
AD2E  38       SEC                     
AD2F  F9 C6 04 SBC $04C6,Y             
AD32  B0 03    BCS loc_AD37            
AD34  20 58 C8 JSR $C858               

loc_AD37:  ; 1 xrefs: AD32
AD37  C9 20    CMP #$20                
AD39  B0 20    BCS loc_AD5B            
AD3B  BD 08 05 LDA $0508,X             
AD3E  38       SEC                     
AD3F  F9 08 05 SBC $0508,Y             
AD42  08       PHP                     
AD43  B0 03    BCS loc_AD48            
AD45  20 58 C8 JSR $C858               

loc_AD48:  ; 1 xrefs: AD43
AD48  C9 60    CMP #$60                
AD4A  B0 0E    BCS loc_AD5A            
AD4C  28       PLP                     
AD4D  B9 60 05 LDA $0560,Y             
AD50  30 04    BMI loc_AD56            
AD52  B0 0E    BCS loc_AD62            
AD54  90 05    BCC loc_AD5B            

loc_AD56:  ; 1 xrefs: AD50
AD56  90 0A    BCC loc_AD62            
AD58  B0 01    BCS loc_AD5B            

loc_AD5A:  ; 1 xrefs: AD4A
AD5A  28       PLP                     

loc_AD5B:  ; 5 xrefs: AD21 AD29 AD39 AD54 AD58
AD5B  C8       INY                     
AD5C  C0 04    CPY #$04                
AD5E  D0 BB    BNE loc_AD1B            

loc_AD60:  ; 2 xrefs: AD12 AD17
AD60  38       SEC                     
AD61  60       RTS                     

loc_AD62:  ; 2 xrefs: AD52 AD56
AD62  18       CLC                     
AD63  60       RTS                     

; ==== data $AD64..$ADB3  (80 bytes) ====
AD64  20 7E C9 6D AD 74 AD 75 AE 20 6E BE 6D 4C 66 C9  | ~.m.t.u. n.mLf.
AD74  20 56 AE 4C 17 AE 20 7E C9 83 AD 93 AD 75 AE 20  | V.L.. ~.....u. 
AD84  6E BE 6C 20 63 BE 7F A9 90 9D A2 05 4C 66 C9 20  |n.l c.......Lf. 
AD94  C3 C9 B0 0A A9 11 A0 00 20 C6 C9 4C B4 AD DE FA  |........ ..L....
ADA4  05 D0 0A 20 83 BE 11 20 CC C9 9D E4 05 20 C9 C9  |... ... ..... ..

loc_ADB4:  ; 0 xrefs: 
ADB4  A0 00    LDY #$00                
ADB6  BD 68 06 LDA $0668,X             
ADB9  F0 02    BEQ loc_ADBD            
ADBB  A0 03    LDY #$03                

loc_ADBD:  ; 1 xrefs: ADB9
ADBD  BD E4 05 LDA $05E4,X             
ADC0  38       SEC                     
ADC1  F9 04 AE SBC $AE04,Y             
ADC4  C9 78    CMP #$78                
ADC6  90 0D    BCC loc_ADD5            

loc_ADC8:  ; 0 xrefs: 
ADC8  C8       INY                     
ADC9  20 FA C8 JSR $C8FA               
ADCC  B0 01    BCS loc_ADCF            
ADCE  C8       INY                     

loc_ADCF:  ; 1 xrefs: ADCC
ADCF  B9 04 AE LDA $AE04,Y             
ADD2  9D E4 05 STA $05E4,X             

loc_ADD5:  ; 1 xrefs: ADC6
ADD5  20 17 AE JSR sub_AE17            
ADD8  20 93 C9 JSR $C993               
ADDB  DE A2 05 DEC $05A2,X             
ADDE  F0 10    BEQ loc_ADF0            
ADE0  BD A2 05 LDA $05A2,X             
ADE3  C9 50    CMP #$50                
ADE5  D0 1C    BNE loc_AE03            
ADE7  20 0A AE JSR sub_AE0A            
ADEA  20 55 90 JSR sub_9055            
ADED  4C 03 AE JMP loc_AE03            

loc_ADF0:  ; 1 xrefs: ADDE
ADF0  A9 FF    LDA #$FF                
ADF2  9D A2 05 STA $05A2,X             
ADF5  A9 14    LDA #$14                
ADF7  85 24    STA $24                 
ADF9  A9 0C    LDA #$0C                
ADFB  85 26    STA $26                 
ADFD  20 0A AE JSR sub_AE0A            
AE00  20 E2 C8 JSR $C8E2               

loc_AE03:  ; 2 xrefs: ADE5 ADED
AE03  60       RTS                     

; ==== data $AE04..$AE09  (6 bytes) ====
AE04  84 84 FC 04 7C 04                                |....|.

sub_AE0A:  ; 2 xrefs: ADE7 ADFD
AE0A  A0 F6    LDY #$F6                
AE0C  20 90 C9 JSR $C990               
AE0F  90 02    BCC loc_AE13            
AE11  A0 0A    LDY #$0A                

loc_AE13:  ; 1 xrefs: AE0F
AE13  98       TYA                     
AE14  A0 00    LDY #$00                
AE16  60       RTS                     

sub_AE17:  ; 1 xrefs: ADD5
AE17  8A       TXA                     
AE18  4D 19 01 EOR $0119               
AE1B  29 03    AND #$03                
AE1D  D0 0C    BNE loc_AE2B            
AE1F  20 2C AE JSR sub_AE2C            
AE22  BC CE 05 LDY $05CE,X             
AE25  20 AF C8 JSR $C8AF               
AE28  4C F1 C8 JMP $C8F1               

loc_AE2B:  ; 1 xrefs: AE1D
AE2B  60       RTS                     

sub_AE2C:  ; 1 xrefs: AE1F
AE2C  BC 10 06 LDY $0610,X             
AE2F  B9 B0 04 LDA $04B0,Y             
AE32  9D B0 04 STA $04B0,X             
AE35  B9 C6 04 LDA $04C6,Y             
AE38  9D C6 04 STA $04C6,X             
AE3B  B9 F2 04 LDA $04F2,Y             
AE3E  9D F2 04 STA $04F2,X             
AE41  B9 08 05 LDA $0508,Y             
AE44  9D 08 05 STA $0508,X             
AE47  A9 00    LDA #$00                
AE49  9D 1E 05 STA $051E,X             
AE4C  9D DC 04 STA $04DC,X             
AE4F  B9 52 06 LDA $0652,Y             
AE52  9D 52 06 STA $0652,X             
AE55  60       RTS                     

loc_AE56:  ; 0 xrefs: 
AE56  DE FA 05 DEC $05FA,X             
AE59  D0 12    BNE loc_AE6D            
AE5B  BC 26 06 LDY $0626,X             
AE5E  B9 70 AE LDA $AE70,Y             
AE61  9D FA 05 STA $05FA,X             
AE64  BC 3C 06 LDY $063C,X             
AE67  B9 CE 05 LDA $05CE,Y             
AE6A  9D E4 05 STA $05E4,X             

loc_AE6D:  ; 1 xrefs: AE59
AE6D  4C C9 C9 JMP $C9C9               

; ==== data $AE70..$AF38  (201 bytes) ====
AE70  00 08 09 0A 0B DE 52 06 F0 01 60 BD 00 04 C9 34  |......R...`....4
AE80  D0 08 20 C0 C9 20 83 BE 00 60 4C C0 C9 20 7E C9  |.. .. ...`L.. ~.
AE90  9A AE 5C AF 75 AE 4C 10 C8 60 20 C3 C9 B0 F7 BD  |..\.u.L..` .....
AEA0  C6 04 C9 C0 B0 F3 BD 9A 04 C9 FF F0 03 9D 68 06  |..............h.
AEB0  20 5A BE FF 20 6E BE 6D 20 9F BE 00 86 25 86 00  | Z.. n.m ....%..
AEC0  A9 00 85 01 85 02 A9 C0 BC 68 06 F0 02 A9 40 85  |.........h....@.
AED0  03 A9 04 85 04 20 42 C9 B0 6C A5 03 9D CE 05 9D  |..... B..l......
AEE0  E4 05 FE FA 05 A5 00 9D 10 06 A8 8A 99 3C 06 86  |.............<..
AEF0  00 20 9F BE 00 A4 25 B9 68 06 9D 68 06 A5 04 9D  |. ....%.h..h....
AF00  26 06 A8 B9 4F AF 9D 00 04 20 5A BE FF 20 2C AE  |&...O.... Z.. ,.
AF10  8A 38 E9 06 29 07 A8 B9 54 AF A0 00 E0 0E 90 01  |.8..)...T.......
AF20  C8 19 01 00 99 01 00 C6 04 10 AA A4 25 8A A6 25  |............%..%
AF30  9D 10 06 20 39 AF 4C 66 C9                       |... 9.Lf.

loc_AF39:  ; 0 xrefs: 
AF39  A6 25    LDX $25                 
AF3B  A5 01    LDA $01                 
AF3D  9D 26 06 STA $0626,X             
AF40  A5 02    LDA $02                 
AF42  9D 3C 06 STA $063C,X             
AF45  60       RTS                     

; ==== data $AF46..$AFEE  (169 bytes) ====
AF46  20 39 AF 20 EF AF 4C 10 C8 34 35 35 35 35 01 02  | 9. ..L..45555..
AF56  04 08 10 20 40 80 BC 10 06 B9 9A 04 C9 76 90 53  |... @........v.S
AF66  20 C3 C9 B0 18 BD C6 04 C9 C0 90 2B B9 B0 04 19  | ..........+....
AF76  F2 04 D0 39 B9 C6 04 C9 C0 B0 32 90 0F B9 B0 04  |...9......2.....
AF86  19 F2 04 D0 22 B9 C6 04 C9 C0 B0 1B BD 52 06 C9  |...."........R..
AF96  01 90 03 DE 52 06 60 BD 52 06 18 69 02 C9 71 90  |....R.`.R..i..q.
AFA6  02 A9 70 9D 52 06 60 20 EF AF 4C 10 C8 20 EF AF  |..p.R.` ..L.. ..
AFB6  4C 69 C9 86 25 A9 06 85 00 A9 10 85 01 A6 25 5E  |Li..%.........%^
AFC6  3C 06 7E 26 06 90 0E A6 00 BC 26 06 B9 EA AF 9D  |<.~&......&.....
AFD6  52 06 20 72 C9 E6 00 C6 01 D0 E2 A6 25 20 9F BE  |R. r........% ..
AFE6  33 4C 72 C9 01 0B 15 1F 29                       |3Lr.....)

loc_AFEF:  ; 0 xrefs: 
AFEF  86 25    STX $25                 
AFF1  A9 06    LDA #$06                
AFF3  85 00    STA $00                 
AFF5  A0 10    LDY #$10                

loc_AFF7:  ; 1 xrefs: B009
AFF7  A6 25    LDX $25                 
AFF9  5E 3C 06 LSR $063C,X             
AFFC  7E 26 06 ROR $0626,X             
AFFF  90 05    BCC loc_B006            
B001  A6 00    LDX $00                 
B003  20 10 C8 JSR $C810               

loc_B006:  ; 1 xrefs: AFFF
B006  E6 00    INC $00                 
B008  88       DEY                     
B009  D0 EC    BNE loc_AFF7            
B00B  A6 25    LDX $25                 
B00D  60       RTS                     

; ==== data $B00E..$B053  (70 bytes) ====
B00E  BD 8C 05 F0 04 4C 54 B0 60 BD B0 04 D0 FA 20 3C  |.....LT.`..... <
B01E  C9 70 F5 C9 80 B0 F1 20 BF BE 80 00 20 1B C9 20  |.p..... .... .. 
B02E  B9 BE 80 00 BC C6 04 CC C6 04 90 03 20 21 C9 A9  |............ !..
B03E  1D BC 34 05 30 02 A9 1E 20 3A C8 20 5A BE 04 20  |..4.0... :. Z.. 
B04E  7C BE 04 4C 66 C9                                ||..Lf.

loc_B054:  ; 0 xrefs: 
B054  20 EE C8 JSR $C8EE               
B057  BD E4 05 LDA $05E4,X             
B05A  F0 5B    BEQ loc_B0B7            
B05C  BD CE 05 LDA $05CE,X             
B05F  D0 21    BNE loc_B082            
B061  BD 34 05 LDA $0534,X             
B064  10 0D    BPL loc_B073            
B066  20 3F C9 JSR $C93F               
B069  70 4C    BVS loc_B0B7            
B06B  B0 4A    BCS loc_B0B7            
B06D  C9 20    CMP #$20                
B06F  90 46    BCC loc_B0B7            
B071  B0 0B    BCS loc_B07E            

loc_B073:  ; 1 xrefs: B064
B073  20 3F C9 JSR $C93F               
B076  70 3F    BVS loc_B0B7            
B078  B0 04    BCS loc_B07E            
B07A  C9 20    CMP #$20                
B07C  B0 39    BCS loc_B0B7            

loc_B07E:  ; 2 xrefs: B071 B078
B07E  20 75 BE JSR sub_BE75            

; ==== data $B081..$B081  (1 bytes) ====
B081  02                                               |.

loc_B082:  ; 1 xrefs: B05F
B082  DE CE 05 DEC $05CE,X             
B085  BC CE 05 LDY $05CE,X             
B088  88       DEY                     
B089  D0 2C    BNE loc_B0B7            
B08B  20 75 BE JSR sub_BE75            
B08E  14 A9    NOP $A9,X               
B090  14 85    NOP $85,X               
B092  24 A9    BIT $A9                 
B094  06 85    ASL $85                 
B096  26 A0    ROL $A0                 
B098  00 BD    BRK #$BD                

; ==== data $B09A..$B0B6  (29 bytes) ====
B09A  34 05 30 02 A0 02 BD 60 05 30 01 C8 B9 B8 B0 48  |4.0....`.0.....H
B0AA  B9 BC B0 A8 68 20 E2 C8 B0 03 DE E4 05           |....h .......

loc_B0B7:  ; 7 xrefs: B05A B069 B06B B06F B076 B07C B089
B0B7  60       RTS                     

; ==== data $B0B8..$B187  (208 bytes) ====
B0B8  0C F4 0C F4 10 10 F0 F0 A9 0E A0 E4 20 20 BF A9  |............  ..
B0C8  E8 20 A5 9B 20 7E C9 D5 B0 EB B0 5A B1 20 5A BE  |. .. ~.....Z. Z.
B0D8  08 20 AD BE 1F 20 B1 C9 20 BF BE C0 01 20 1B C9  |. ... .. .... ..
B0E8  4C 66 C9 20 EE C8 20 98 B1 BD CE 05 F0 0C DE CE  |Lf. .. .........
B0F8  05 D0 07 20 75 BE 14 4C 66 C9 20 06 BF 24 FF EC  |... u..Lf. ..$..
B108  30 4A 20 3F C9 70 0F C9 10 B0 0B A0 22 20 90 C9  |0J ?.p......" ..
B118  90 0D A0 DE D0 09 A0 28 20 90 C9 90 02 A0 D8 98  |.......( .......
B128  A0 04 20 48 C9 30 09 C9 01 F0 05 20 44 9C 90 1C  |.. H.0..... D...
B138  BD CE 05 D0 1C 20 D0 AC 30 12 20 3C C9 70 12 C9  |..... ..0. <.p..
B148  18 90 0E 20 8D C9 B0 09 A9 20 D0 02 A9 01 9D CE  |... ..... ......
B158  05 60 20 F7 C8 20 98 B1 DE CE 05 F0 1B 20 37 C8  |.` .. ....... 7.
B168  BD CE 05 C9 0A B0 04 20 6E BE B6 A9 10 BC 60 05  |....... n.....`.
B178  10 03 4C 12 C9 4C 15 C9 20 D0 AC 10 04 20 75 BE  |..L..L.. .... u.

loc_B188:  ; 0 xrefs: 
B188  60       RTS                     

; ==== data $B189..$B197  (15 bytes) ====
B189  20 1B C9 20 C5 BE C0 01 20 AD BE 1F 4C 69 C9     | .. .... ...Li.

loc_B198:  ; 0 xrefs: 
B198  BD E4 05 LDA $05E4,X             
B19B  F0 0B    BEQ loc_B1A8            
B19D  DE E4 05 DEC $05E4,X             

loc_B1A0:  ; 3 xrefs: B1B2 B1B7 B1BE
B1A0  60       RTS                     

loc_B1A1:  ; 1 xrefs: B1AD
B1A1  A9 0E    LDA #$0E                
B1A3  A0 E4    LDY #$E4                
B1A5  4C 26 BF JMP loc_BF26            

loc_B1A8:  ; 1 xrefs: B19B
B1A8  AD 16 04 LDA $0416               
B1AB  29 60    AND #$60                
B1AD  D0 F2    BNE loc_B1A1            
B1AF  20 8D C9 JSR $C98D               
B1B2  90 EC    BCC loc_B1A0            
B1B4  AD B8 05 LDA $05B8               
B1B7  F0 E7    BEQ loc_B1A0            
B1B9  AD 64 01 LDA $0164               
B1BC  C9 03    CMP #$03                
B1BE  90 E0    BCC loc_B1A0            
B1C0  AD 16 04 LDA $0416               
B1C3  4A       LSR A                   
B1C4  90 07    BCC loc_B1CD            
B1C6  A9 20    LDA #$20                
B1C8  9D E4 05 STA $05E4,X             
B1CB  D0 05    BNE loc_B1D2            

loc_B1CD:  ; 1 xrefs: B1C4
B1CD  A9 F8    LDA #$F8                
B1CF  8D 10 06 STA $0610               

loc_B1D2:  ; 1 xrefs: B1CB
B1D2  A9 FC    LDA #$FC                
B1D4  8D 34 05 STA $0534               
B1D7  A9 08    LDA #$08                
B1D9  BC 60 05 LDY $0560,X             
B1DC  10 02    BPL loc_B1E0            
B1DE  A9 F8    LDA #$F8                

loc_B1E0:  ; 1 xrefs: B1DC
B1E0  8D 60 05 STA $0560               
B1E3  A9 00    LDA #$00                
B1E5  8D 76 05 STA $0576               
B1E8  8D 4A 05 STA $054A               
B1EB  60       RTS                     

; ==== data $B1EC..$B21E  (51 bytes) ====
B1EC  20 7E C9 FD B1 12 B2 2B B2 32 B2 12 B2 63 B2 F0  | ~.....+.2...c..
B1FC  B2 20 B1 C9 20 5A BE 08 20 AD BE 22 20 91 BE 20  |. .. Z.. .." .. 
B20C  20 6F C9 4C 1F B2 20 C3 C9 B0 05 DE 26 06 D0 03  | o.L.. .....&...
B21C  20 66 C9                                         | f.

loc_B21F:  ; 0 xrefs: 
B21F  20 37 C8 JSR $C837               

loc_B222:  ; 0 xrefs: 
B222  20 FD C8 JSR $C8FD               
B225  20 76 B3 JSR sub_B376            
B228  4C 71 B3 JMP sub_B371            

; ==== data $B22B..$B28C  (98 bytes) ====
B22B  A9 10 9D 26 06 D0 EA 20 22 B2 20 C3 C9 B0 1E DE  |...&... ". .....
B23B  26 06 F0 19 BD 26 06 C9 08 D0 03 20 C3 B3 A9 98  |&....&..... ....
B24B  BC 26 06 C0 08 B0 02 A9 99 9D 42 04 60 20 AD BE  |.&........B.` ..
B25B  22 20 91 BE 50 4C 66 C9 20 AD BE 23 20 91 BE 50  |" ..PLf. ..# ..P
B26B  20 3C C9 70 18 C9 30 B0 14 A9 00 BC 08 05 30 02  | <.p..0.......0.
B27B  A9 40 9D 2C 04 20 C5 BE 00 FE 4C 8D B2 20 BF BE  |.@.,. ....L.. ..
B28B  00 FE                                            |..

loc_B28D:  ; 0 xrefs: 
B28D  20 D0 AC JSR sub_ACD0            
B290  10 08    BPL loc_B29A            
B292  20 C5 BE JSR sub_BEC5            
B295  80 FF    NOP #$FF                
B297  20 1E C9 JSR $C91E               

loc_B29A:  ; 1 xrefs: B290
B29A  BD 68 06 LDA $0668,X             
B29D  29 02    AND #$02                
B29F  F0 04    BEQ loc_B2A5            
B2A1  A0 08    LDY #$08                
B2A3  D0 18    BNE loc_B2BD            

loc_B2A5:  ; 1 xrefs: B29F
B2A5  BD C6 04 LDA $04C6,X             
B2A8  BC B0 04 LDY $04B0,X             
B2AB  F0 08    BEQ loc_B2B5            
B2AD  30 04    BMI loc_B2B3            
B2AF  A9 FF    LDA #$FF                
B2B1  D0 02    BNE loc_B2B5            

loc_B2B3:  ; 1 xrefs: B2AD
B2B3  A9 00    LDA #$00                

loc_B2B5:  ; 2 xrefs: B2AB B2B1
B2B5  29 E0    AND #$E0                
B2B7  4A       LSR A                   
B2B8  4A       LSR A                   
B2B9  4A       LSR A                   
B2BA  4A       LSR A                   
B2BB  4A       LSR A                   
B2BC  A8       TAY                     

loc_B2BD:  ; 1 xrefs: B2A3
B2BD  B9 E7 B2 LDA $B2E7,Y             
B2C0  9D 3C 06 STA $063C,X             
B2C3  B9 DE B2 LDA $B2DE,Y             
B2C6  48       PHA                     
B2C7  B9 D5 B2 LDA $B2D5,Y             
B2CA  A8       TAY                     
B2CB  68       PLA                     
B2CC  20 09 C9 JSR $C909               
B2CF  20 71 B3 JSR sub_B371            
B2D2  4C 66 C9 JMP $C966               

; ==== data $B2D5..$B32F  (91 bytes) ====
B2D5  00 80 40 C0 80 00 00 80 00 03 02 02 01 01 01 00  |..@.............
B2E5  FF 00 0E 0F 10 14 18 1C 22 24 01 DE 26 06 F0 60  |........"$..&..`
B2F5  BD 3C 06 20 0F C9 BD 34 05 10 09 C9 FE B0 05 20  |.<. ...4....... 
B305  B9 BE 00 FE BD B0 04 10 05 BD 34 05 30 42 BD 26  |..........4.0B.&
B315  06 C9 28 B0 16 98 30 0A F0 11 A9 04 20 15 C9 4C  |..(...0..... ..L
B325  30 B3 C9 FF F0 05 A9 04 20 12 C9                 |0....... ..

loc_B330:  ; 0 xrefs: 
B330  BD 68 06 LDA $0668,X             
B333  29 C0    AND #$C0                
B335  D0 10    BNE loc_B347            
B337  20 D0 AC JSR sub_ACD0            
B33A  10 13    BPL loc_B34F            
B33C  BD 26 06 LDA $0626,X             
B33F  C9 20    CMP #$20                
B341  90 04    BCC loc_B347            
B343  20 91 BE JSR sub_BE91            
B346  20 20 C5 JSR $C520               
B349  BE E0 FF LDX $FFE0,Y             
B34C  20 1E C9 JSR $C91E               

loc_B34F:  ; 1 xrefs: B33A
B34F  20 37 C8 JSR $C837               
B352  4C 71 B3 JMP sub_B371            

; ==== data $B355..$B370  (28 bytes) ====
B355  20 AD BE 22 20 91 BE 18 20 6F C9 BD 60 05 30 06  | .." ... o..`.0.
B365  20 B3 BE 40 00 60 20 B3 BE C0 FF 60              | ..@.` ....`

sub_B371:  ; 3 xrefs: B228 B2CF B352
B371  A0 00    LDY #$00                
B373  4C BB BC JMP sub_BCBB            

sub_B376:  ; 1 xrefs: B225
B376  FE E4 05 INC $05E4,X             
B379  BD E4 05 LDA $05E4,X             
B37C  48       PHA                     
B37D  48       PHA                     
B37E  29 1F    AND #$1F                
B380  A8       TAY                     
B381  68       PLA                     
B382  29 20    AND #$20                
B384  F0 06    BEQ loc_B38C            
B386  98       TYA                     
B387  49 FF    EOR #$FF                
B389  29 1F    AND #$1F                
B38B  A8       TAY                     

loc_B38C:  ; 1 xrefs: B384
B38C  B9 A3 B3 LDA $B3A3,Y             
B38F  A8       TAY                     
B390  68       PLA                     
B391  18       CLC                     
B392  69 20    ADC #$20                
B394  29 40    AND #$40                
B396  F0 05    BEQ loc_B39D            
B398  98       TYA                     
B399  20 58 C8 JSR $C858               
B39C  A8       TAY                     

loc_B39D:  ; 1 xrefs: B396
B39D  98       TYA                     
B39E  A0 00    LDY #$00                
B3A0  4C 09 C9 JMP $C909               

; ==== data $B3A3..$B3C2  (32 bytes) ====
B3A3  00 01 00 00 01 00 00 01 00 00 00 01 00 00 00 01  |................
B3B3  00 00 00 00 01 00 00 00 00 01 00 00 00 00 00 01  |................

loc_B3C3:  ; 0 xrefs: 
B3C3  A0 00    LDY #$00                
B3C5  84 00    STY $00                 
B3C7  20 90 C9 JSR $C990               
B3CA  90 02    BCC loc_B3CE            
B3CC  A0 02    LDY #$02                

loc_B3CE:  ; 1 xrefs: B3CA
B3CE  84 01    STY $01                 
B3D0  20 D7 B3 JSR sub_B3D7            
B3D3  C6 00    DEC $00                 
B3D5  E6 01    INC $01                 

sub_B3D7:  ; 1 xrefs: B3D0
B3D7  A9 3B    LDA #$3B                
B3D9  85 24    STA $24                 
B3DB  A0 00    LDY #$00                
B3DD  A9 00    LDA #$00                
B3DF  20 DF C8 JSR $C8DF               
B3E2  B0 24    BCS loc_B408            
B3E4  A6 12    LDX $12                 
B3E6  A9 0A    LDA #$0A                
B3E8  24 00    BIT $00                 
B3EA  10 02    BPL loc_B3EE            
B3EC  A9 F6    LDA #$F6                

loc_B3EE:  ; 1 xrefs: B3EA
B3EE  9D 10 06 STA $0610,X             
B3F1  A5 00    LDA $00                 
B3F3  4A       LSR A                   
B3F4  A9 00    LDA #$00                
B3F6  69 14    ADC #$14                
B3F8  9D FA 05 STA $05FA,X             
B3FB  A4 01    LDY $01                 
B3FD  B9 09 B4 LDA $B409,Y             
B400  9D E4 05 STA $05E4,X             
B403  9D CE 05 STA $05CE,X             
B406  A6 25    LDX $25                 

loc_B408:  ; 1 xrefs: B3E2
B408  60       RTS                     

; ==== data $B409..$B44B  (67 bytes) ====
B409  90 70 F0 10 20 7E C9 16 B4 24 B4 4A B4 20 5A BE  |.p.. ~...$.J. Z.
B419  02 20 91 BE FF 20 55 B4 4C 66 C9 BD 26 06 F0 18  |. ... U.Lf..&...
B429  DE 26 06 BD CE 05 48 A9 06 BC 10 06 20 C6 C9 68  |.&....H..... ..h
B439  DD CE 05 F0 03 20 55 B4 20 87 B4 20 D2 C9 4C F1  |..... U. .. ..L.
B449  C8 DE CE                                         |...

loc_B44C:  ; 0 xrefs: 
B44C  05 F0    ORA $F0                 
B44E  03 4C    SLO ($4C,X)             
B450  37 C8    RLA $C8,X               
B452  4C 10 C8 JMP $C810               

loc_B455:  ; 0 xrefs: 
B455  BC CE 05 LDY $05CE,X             
B458  A9 0C    LDA #$0C                
B45A  20 AF C8 JSR $C8AF               
B45D  BD CE 05 LDA $05CE,X             
B460  18       CLC                     
B461  69 10    ADC #$10                
B463  2A       ROL A                   
B464  2A       ROL A                   
B465  2A       ROL A                   
B466  2A       ROL A                   
B467  29 07    AND #$07                
B469  A8       TAY                     
B46A  B9 77 B4 LDA $B477,Y             
B46D  9D 42 04 STA $0442,X             
B470  B9 7F B4 LDA $B47F,Y             
B473  9D 2C 04 STA $042C,X             
B476  60       RTS                     

; ==== data $B477..$B486  (16 bytes) ====
B477  9C 9D 9E 9D 9C 9B 9A 9B 40 40 00 00 00 00 00 40  |........@@.....@

loc_B487:  ; 1 xrefs: B691
B487  20 CB BE JSR sub_BECB            
B48A  00 00    BRK #$00                

; ==== data $B48C..$B4CF  (68 bytes) ====
B48C  30 01 60 20 AD BE 01 20 75 BE 10 A9 3B 9D 00 04  |0.` ... u...;...
B49C  4C 72 C9 20 7E C9 A8 B4 B2 B4 E8 B4 20 A2 C9 20  |Lr. ~....... .. 
B4AC  AD BE 25 4C 66 C9 A9 40 20 0C C9 BD 34 05 C9 04  |..%Lf..@ ...4...
B4BC  90 05 20 B9 BE 00 04 20 CB BE 00 00 30 06 20 D2  |.. .... ....0. .
B4CC  C9 4C EE C8                                      |.L..

loc_B4D0:  ; 0 xrefs: 
B4D0  A9 33    LDA #$33                
B4D2  9D 00 04 STA $0400,X             
B4D5  20 79 82 JSR sub_8279            
B4D8  A9 3F    LDA #$3F                
B4DA  9D 00 04 STA $0400,X             
B4DD  20 AB C9 JSR $C9AB               
B4E0  A9 1C    LDA #$1C                
B4E2  20 1C C8 JSR $C81C               
B4E5  4C 72 C9 JMP $C972               

; ==== data $B4E8..$B562  (123 bytes) ====
B4E8  A9 33 9D 00 04 20 A8 82 A9 3F 9D 00 04 BD 8C 05  |.3... ...?......
B4F8  C9 02 F0 03 4C 10 C8 60 20 7E C9 0B B5 23 B5 AA  |....L..` ~...#..
B508  B5 05 B6 BD 9A 04 9D 52 06 20 5A BE 08 20 AD BE  |.......R. Z.. ..
B518  26 20 B1 C9 20 75 BE 28 4C 66 C9 20 0F AD 90 2A  |& .. u.(Lf. ...*
B528  DE CE 05 F0 03 4C FD C8 BD 52 06 D0 0E 20 39 C9  |.....L...R... 9.
B538  C9 A0 90 0E BD 68 06 29 C0 D0 07 20 AD BE 26 4C  |.....h.)... ..&L
B548  75 C9 20 BF BE 80 FE 4C 63 B5 FE E4 05 BD E4 05  |u. ....Lc.......
B558  4A 90 EF 20 BF BE 40 FF 20 1E C9                 |J.. ..@. ..

loc_B563:  ; 0 xrefs: 
B563  BD C6 04 LDA $04C6,X             
B566  C9 50    CMP #$50                
B568  B0 08    BCS loc_B572            
B56A  20 B9 BE JSR sub_BEB9            
B56D  00 FC    BRK #$FC                

; ==== data $B56F..$B571  (3 bytes) ====
B56F  4C 86 B5                                         |L..

loc_B572:  ; 1 xrefs: B568
B572  AD C6 04 LDA $04C6               
B575  C9 50    CMP #$50                
B577  B0 08    BCS loc_B581            
B579  20 B9 BE JSR sub_BEB9            
B57C  00 F9    BRK #$F9                

; ==== data $B57E..$B580  (3 bytes) ====
B57E  4C 86 B5                                         |L..

loc_B581:  ; 1 xrefs: B577
B581  20 B9 BE JSR sub_BEB9            
B584  00 FA    BRK #$FA                

loc_B586:  ; 0 xrefs: 
B586  20 72 C9 JSR $C972               
B589  BD 52 06 LDA $0652,X             
B58C  F0 05    BEQ loc_B593            
B58E  20 B3 BE JSR sub_BEB3            
B591  00 00    BRK #$00                

loc_B593:  ; 1 xrefs: B58C
B593  BD 60 05 LDA $0560,X             
B596  30 09    BMI loc_B5A1            
B598  20 91 BE JSR sub_BE91            
B59B  FF 20 98 ISC $9820,X             
B59E  BE 80 60 LDX $6080,Y             

loc_B5A1:  ; 1 xrefs: B596
B5A1  20 91 BE JSR sub_BE91            
B5A4  00 20    BRK #$20                

; ==== data $B5A6..$B5D6  (49 bytes) ====
B5A6  98 BE 80 60 A0 03 20 BB BC BD 68 06 29 02 D0 41  |...`.. ...h.)..A
B5B6  A9 4B 20 0C C9 BD 34 05 30 13 20 6E BE 91 BD 34  |.K ...4.0. n...4
B5C6  05 C9 04 90 0C 20 B9 BE 00 04 4C D7 B5 20 6E BE  |..... ....L.. n.
B5D6  90                                               |.

loc_B5D7:  ; 0 xrefs: 
B5D7  20 FD C8 JSR $C8FD               
B5DA  BD 68 06 LDA $0668,X             
B5DD  29 C0    AND #$C0                
B5DF  D0 09    BNE loc_B5EA            
B5E1  20 D0 AC JSR sub_ACD0            
B5E4  30 01    BMI loc_B5E7            
B5E6  60       RTS                     

loc_B5E7:  ; 1 xrefs: B5E4
B5E7  4C 1E C9 JMP $C91E               

loc_B5EA:  ; 1 xrefs: B5DF
B5EA  BD 26 06 LDA $0626,X             
B5ED  9D 60 05 STA $0560,X             
B5F0  BD 3C 06 LDA $063C,X             
B5F3  9D 76 05 STA $0576,X             
B5F6  60       RTS                     

; ==== data $B5F7..$B68A  (148 bytes) ====
B5F7  20 81 C9 20 AD BE 26 20 75 BE 20 4C 6F C9 20 FD  | .. ..& u. Lo. .
B607  C8 20 37 C8 BD 42 04 C9 90 F0 2B C9 8F D0 26 BD  |. 7..B....+...&.
B617  A2 05 C9 07 D0 1F A9 3D 85 24 A9 14 85 26 20 90  |.......=.$...& .
B627  C9 B0 06 A9 80 A0 F0 D0 04 A9 00 A0 10 85 06 98  |................
B637  A0 E2 20 E5 C8 60 20 6F C9 DE 42 04 BD 52 06 D0  |.. ..` o..B..R..
B647  05 20 75 BE 10 60 20 75 BE 38 60 BD 8C 05 D0 0D  |. u..` u.8`.....
B657  20 A2 C9 20 AD BE 27 20 93 C9 4C 66 C9 20 90 C9  | .. ..' ..Lf. ..
B667  BD F2 04 B0 11 F0 07 10 24 20 B3 BE 80 00 A9 0C  |........$ ......
B677  20 12 C9 4C 8B B6 F0 07 30 13 20 B3 BE 80 FF A9  | ..L....0. .....
B687  0C 20 15 C9                                      |. ..

loc_B68B:  ; 0 xrefs: 
B68B  20 EE C8 JSR $C8EE               
B68E  20 D2 C9 JSR $C9D2               
B691  4C 87 B4 JMP loc_B487            

; ==== data $B694..$B6B1  (30 bytes) ====
B694  4C 10 C8 20 7E C9 A2 B6 C9 B6 31 B7 79 B7 BD 9A  |L.. ~.....1.y...
B6A4  04 9D 52 06 20 63 BE 08 20 B1 C9 4C B2 B6        |..R. c.. ..L..

loc_B6B2:  ; 0 xrefs: 
B6B2  20 6E BE JSR sub_BE6E            
B6B5  AC 20 A5 LDY $A520               
B6B8  C9 20    CMP #$20                
B6BA  B9 BE 00 LDA $00BE,Y             
B6BD  FD 20 75 SBC $7520,X             
B6C0  BE B4 20 LDX $20B4,Y             
B6C3  7C BE 00 NOP $00BE,X             
B6C6  4C 6F C9 JMP $C96F               

; ==== data $B6C9..$B72D  (101 bytes) ====
B6C9  BD CE 05 F0 03 DE CE 05 A9 1C 20 0C C9 BD 34 05  |.......... ...4.
B6D9  10 0F 20 DD BE E8 04 10 4C 20 B9 BE 00 00 4C 2E  |.. .....L ....L.
B6E9  B7 C9 04 90 05 20 B9 BE 00 04 20 DD BE 04 04 10  |..... .... .....
B6F9  34 BD CE 05 F0 0A FE E4 05 BD E4 05 C9 04 90 20  |4.............. 
B709  A9 00 20 87 C9 20 AD BE 20 20 BF BE 80 FF 20 66  |.. .. ..  .... f
B719  C9 BD 52 06 D0 05 20 75 BE 40 60 20 75 BE 01 60  |..R... u.@` u..`
B729  20 B9 BE 00 FD                                   | ....

loc_B72E:  ; 0 xrefs: 
B72E  4C F4 C8 JMP $C8F4               

; ==== data $B731..$B7F9  (201 bytes) ====
B731  20 E3 BE 04 08 30 0C 20 75 BE 00 20 B9 BE 80 00  | ....0. u.. ....
B741  4C 69 C9 DE CE 05 F0 1F 20 37 C8 20 D0 AC 30 08  |Li...... 7. ..0.
B751  20 06 BF F6 FF E8 10 0C BD CE 05 18 69 14 9D CE  | ...........i...
B761  05 20 1B C9 4C F7 C8 20 AD BE 21 20 9F C9 20 FD  |. ..L.. ..! .. .
B771  C8 20 75 BE 46 4C 66 C9 20 FD C8 BD 42 04 C9 B1  |. u.FLf. ...B...
B781  F0 03 4C 37 C8 DE CE 05 F0 1F BD CE 05 C9 10 F0  |..L7............
B791  01 60 A9 14 85 24 A9 0C 85 26 A0 F6 20 90 C9 90  |.`...$...&.. ...
B7A1  02 A0 0A 98 A0 EA 4C E2 C8 4C B2 B6 BD 8C 05 D0  |......L..L......
B7B1  15 20 B1 C9 20 5A BE 08 20 AD BE 2A 20 9F BE 40  |. .. Z.. ..* ..@
B7C1  20 FA B7 4C 66 C9 20 FD C8 20 FA B7 20 A7 B8 A0  | ..Lf. .. .. ...
B7D1  02 20 BB BC BD 3C 06 F0 07 DE 3C 06 D0 05 A9 00  |. ...<....<.....
B7E1  9D 26 06 BD 3C 06 D0 08 DE 52 06 D0 03 20 1D B9  |.&..<....R... ..
B7F1  20 E1 B8 9D 58 04 4C 37 C8                       | ...X.L7.

loc_B7FA:  ; 0 xrefs: 
B7FA  BD E4 05 LDA $05E4,X             
B7FD  D0 66    BNE loc_B865            
B7FF  20 D0 AC JSR sub_ACD0            
B802  30 0B    BMI loc_B80F            
B804  BD 68 06 LDA $0668,X             
B807  29 C0    AND #$C0                
B809  F0 35    BEQ loc_B840            
B80B  30 17    BMI loc_B824            
B80D  10 11    BPL loc_B820            

loc_B80F:  ; 1 xrefs: B802
B80F  BD 60 05 LDA $0560,X             
B812  30 04    BMI loc_B818            
B814  A9 80    LDA #$80                
B816  D0 02    BNE loc_B81A            

loc_B818:  ; 1 xrefs: B812
B818  A9 00    LDA #$00                

loc_B81A:  ; 1 xrefs: B816
B81A  9D CE 05 STA $05CE,X             
B81D  4C 34 B8 JMP loc_B834            

loc_B820:  ; 1 xrefs: B80D
B820  A9 80    LDA #$80                
B822  D0 02    BNE loc_B826            

loc_B824:  ; 1 xrefs: B80B
B824  A9 00    LDA #$00                

loc_B826:  ; 1 xrefs: B822
B826  9D CE 05 STA $05CE,X             
B829  20 3C C9 JSR $C93C               
B82C  70 06    BVS loc_B834            
B82E  08       PHP                     
B82F  C9 30    CMP #$30                
B831  B0 17    BCS loc_B84A            
B833  28       PLP                     

loc_B834:  ; 2 xrefs: B81D B82C
B834  20 B3 BE JSR sub_BEB3            
B837  00 00    BRK #$00                

; ==== data $B839..$B83F  (7 bytes) ====
B839  20 7C BE 3C 4C 68 B8                             | |.<Lh.

loc_B840:  ; 1 xrefs: B809
B840  20 3C C9 JSR $C93C               
B843  70 1C    BVS loc_B861            
B845  08       PHP                     
B846  C9 50    CMP #$50                
B848  90 12    BCC loc_B85C            

loc_B84A:  ; 1 xrefs: B831
B84A  C9 60    CMP #$60                
B84C  B0 12    BCS loc_B860            
B84E  20 3F C9 JSR $C93F               
B851  90 07    BCC loc_B85A            
B853  20 7C BE JSR sub_BE7C            
B856  28       PLP                     
B857  4C 60 B8 JMP loc_B860            

loc_B85A:  ; 1 xrefs: B851
B85A  28       PLP                     
B85B  60       RTS                     

loc_B85C:  ; 1 xrefs: B848
B85C  68       PLA                     
B85D  49 01    EOR #$01                
B85F  48       PHA                     

loc_B860:  ; 2 xrefs: B84C B857
B860  28       PLP                     

loc_B861:  ; 1 xrefs: B843
B861  B0 27    BCS loc_B88A            
B863  90 08    BCC loc_B86D            

loc_B865:  ; 1 xrefs: B7FD
B865  DE E4 05 DEC $05E4,X             

loc_B868:  ; 0 xrefs: 
B868  BD CE 05 LDA $05CE,X             
B86B  30 1D    BMI loc_B88A            

loc_B86D:  ; 1 xrefs: B863
B86D  A9 00    LDA #$00                
B86F  9D CE 05 STA $05CE,X             
B872  A9 08    LDA #$08                
B874  BC 60 05 LDY $0560,X             
B877  10 02    BPL loc_B87B            
B879  A9 10    LDA #$10                

loc_B87B:  ; 1 xrefs: B877
B87B  20 12 C9 JSR $C912               
B87E  30 09    BMI loc_B889            
B880  C9 02    CMP #$02                
B882  90 05    BCC loc_B889            
B884  20 B3 BE JSR sub_BEB3            
B887  00 02    BRK #$02                

loc_B889:  ; 2 xrefs: B87E B882
B889  60       RTS                     

loc_B88A:  ; 2 xrefs: B861 B86B
B88A  A9 80    LDA #$80                
B88C  9D CE 05 STA $05CE,X             
B88F  A9 08    LDA #$08                
B891  BC 60 05 LDY $0560,X             
B894  30 02    BMI loc_B898            
B896  A9 10    LDA #$10                

loc_B898:  ; 1 xrefs: B894
B898  20 15 C9 JSR $C915               
B89B  10 09    BPL loc_B8A6            
B89D  C9 FE    CMP #$FE                
B89F  B0 05    BCS loc_B8A6            
B8A1  20 B3 BE JSR sub_BEB3            
B8A4  00 FE    BRK #$FE                

loc_B8A6:  ; 2 xrefs: B89B B89F
B8A6  60       RTS                     

loc_B8A7:  ; 0 xrefs: 
B8A7  20 3F C9 JSR $C93F               
B8AA  08       PHP                     
B8AB  70 04    BVS loc_B8B1            
B8AD  C9 40    CMP #$40                
B8AF  90 04    BCC loc_B8B5            

loc_B8B1:  ; 1 xrefs: B8AB
B8B1  28       PLP                     
B8B2  4C BB B8 JMP loc_B8BB            

loc_B8B5:  ; 1 xrefs: B8AF
B8B5  28       PLP                     
B8B6  AD C6 04 LDA $04C6               
B8B9  C9 68    CMP #$68                

loc_B8BB:  ; 1 xrefs: B8B2
B8BB  A9 10    LDA #$10                
B8BD  B0 06    BCS loc_B8C5            
B8BF  20 0C C9 JSR $C90C               
B8C2  4C C8 B8 JMP loc_B8C8            

loc_B8C5:  ; 1 xrefs: B8BD
B8C5  20 0F C9 JSR $C90F               

loc_B8C8:  ; 1 xrefs: B8C2
B8C8  BD 34 05 LDA $0534,X             
B8CB  30 0A    BMI loc_B8D7            
B8CD  C9 02    CMP #$02                
B8CF  90 05    BCC loc_B8D6            
B8D1  20 B9 BE JSR sub_BEB9            
B8D4  00 02    BRK #$02                

loc_B8D6:  ; 1 xrefs: B8CF
B8D6  60       RTS                     

loc_B8D7:  ; 1 xrefs: B8CB
B8D7  C9 FE    CMP #$FE                
B8D9  B0 05    BCS loc_B8E0            
B8DB  20 B9 BE JSR sub_BEB9            
B8DE  00 FE    BRK #$FE                

loc_B8E0:  ; 1 xrefs: B8D9
B8E0  60       RTS                     

sub_B8E1:  ; 1 xrefs: B957
B8E1  BD 26 06 LDA $0626,X             
B8E4  0A       ASL A                   
B8E5  7D 26 06 ADC $0626,X             
B8E8  A8       TAY                     
B8E9  BD 60 05 LDA $0560,X             
B8EC  1D 76 05 ORA $0576,X             
B8EF  F0 1D    BEQ loc_B90E            
B8F1  BD 68 06 LDA $0668,X             
B8F4  29 C0    AND #$C0                
B8F6  D0 16    BNE loc_B90E            
B8F8  20 90 C9 JSR $C990               
B8FB  BD 60 05 LDA $0560,X             
B8FE  B0 08    BCS loc_B908            
B900  10 0D    BPL loc_B90F            
B902  C9 FE    CMP #$FE                
B904  F0 0A    BEQ loc_B910            
B906  D0 06    BNE loc_B90E            

loc_B908:  ; 1 xrefs: B8FE
B908  30 05    BMI loc_B90F            
B90A  C9 02    CMP #$02                
B90C  F0 02    BEQ loc_B910            

loc_B90E:  ; 3 xrefs: B8EF B8F6 B906
B90E  C8       INY                     

loc_B90F:  ; 2 xrefs: B900 B908
B90F  C8       INY                     

loc_B910:  ; 2 xrefs: B904 B90C
B910  B9 14 B9 LDA $B914,Y             
B913  60       RTS                     

; ==== data $B914..$B91C  (9 bytes) ====
B914  28 29 2A 2B 2C 2D 2E 2F 30                       |()*+,-./0

loc_B91D:  ; 0 xrefs: 
B91D  A9 41    LDA #$41                
B91F  85 24    STA $24                 
B921  A9 10    LDA #$10                
B923  85 26    STA $26                 
B925  A0 00    LDY #$00                
B927  20 90 C9 JSR $C990               
B92A  90 02    BCC loc_B92E            
B92C  A0 08    LDY #$08                

loc_B92E:  ; 1 xrefs: B92A
B92E  20 3F C9 JSR $C93F               
B931  90 04    BCC loc_B937            
B933  98       TYA                     
B934  69 03    ADC #$03                
B936  A8       TAY                     

loc_B937:  ; 1 xrefs: B931
B937  B9 79 B9 LDA $B979,Y             
B93A  9D 26 06 STA $0626,X             
B93D  B9 7A B9 LDA $B97A,Y             
B940  85 06    STA $06                 
B942  B9 7B B9 LDA $B97B,Y             
B945  48       PHA                     
B946  B9 7C B9 LDA $B97C,Y             
B949  A8       TAY                     
B94A  68       PLA                     
B94B  20 E5 C8 JSR $C8E5               
B94E  B0 20    BCS loc_B970            
B950  A4 26    LDY $26                 
B952  A5 06    LDA $06                 
B954  99 CE 05 STA $05CE,Y             
B957  20 E1 B8 JSR sub_B8E1            
B95A  20 3A C8 JSR $C83A               
B95D  20 98 BE JSR sub_BE98            
B960  30 20    BMI loc_B982            

; ==== data $B962..$B968  (7 bytes) ====
B962  9F BE 80 20 B3 BE 00                             |... ...

loc_B969:  ; 1 xrefs: B99F
B969  00 20    BRK #$20                

; ==== data $B96B..$B96F  (5 bytes) ====
B96B  B9 BE 00 00 60                                   |....`

loc_B970:  ; 1 xrefs: B94E
B970  20 91 BE JSR sub_BE91            
B973  00 20    BRK #$20                

; ==== data $B975..$B981  (13 bytes) ====
B975  9F BE 11 60 02 60 F6 EA 01 A0 F6 CC 02           |...`.`.......

loc_B982:  ; 1 xrefs: B960
B982  20 0A EA JSR $EA0A               
B985  01 E0    ORA ($E0,X)             
B987  0A       ASL A                   
B988  CC BD 8C CPY $8CBD               
B98B  05 D0    ORA $D0                 
B98D  0B 20    ANC #$20                
B98F  AD BE 31 LDA $31BE               
B992  20 75 BE JSR sub_BE75            
B995  0E 20 66 ASL $6620               
B998  C9 DE    CMP #$DE                
B99A  CE 05 D0 DEC $D005               
B99D  03 4C    SLO ($4C,X)             
B99F  10 C8    BPL loc_B969            
B9A1  4C 37 C8 JMP $C837               

; ==== data $B9A4..$B9AF  (12 bytes) ====
B9A4  20 D2 C9 20 7E C9 B2 B9 D6 B9 0F BA              | .. ~.......

loc_B9B0:  ; 0 xrefs: 
B9B0  2D BA 20 AND $20BA               
B9B3  3E BE D0 ROL $D0BE,X             
B9B6  1E 20 A2 ASL $A220,X             
B9B9  BA       TSX                     
B9BA  30 16    BMI loc_B9D2            
B9BC  20 5A BE JSR sub_BE5A            
B9BF  FF 20 83 ISC $8320,X             
B9C2  BE C8 20 LDX $20C8,Y             
B9C5  94 BA    STY $BA,X               
B9C7  20 B9 BA JSR sub_BAB9            
B9CA  A9 2A    LDA #$2A                
B9CC  20 1C C8 JSR $C81C               
B9CF  4C 66 C9 JMP $C966               

loc_B9D2:  ; 1 xrefs: B9BA
B9D2  4C 10 C8 JMP $C810               

; ==== data $B9D5..$BA4E  (122 bytes) ====
B9D5  60 20 B9 BA 20 F1 C8 20 A2 BA 30 09 BD FA 05 F0  |` .. .. ..0.....
B9E5  03 DE FA 05 60 A9 43 85 24 20 8A BA B9 0B BA 48  |....`.C.$ .....H
B9F5  B9 07 BA A8 68 20 DF C8 B0 D3 A9 1E 20 1C C8 4C  |....h ...... ..L
BA05  66 C9 10 10 FE FE 08 F7 F7 08 20 F1 C8 20 CB BE  |f......... .. ..
BA15  00 00 30 01 60 BD FA 05 F0 B3 20 7C BE 00 20 8A  |..0.`..... |.. .
BA25  BE 03 20 B9 BA 4C 66 C9 20 3E BE D0 37 20 8A BA  |.. ..Lf. >..7 ..
BA35  18 7D E4 05 85 00 A8 B9 7A BA 48 B9 72 BA A8 68  |.}......z.H.r..h
BA45  20 45 C9 30 14 A4 00 B9 82 BA                    | E.0......

loc_BA4F:  ; 0 xrefs: 
BA4F  9D CE 05 STA $05CE,X             
BA52  A8       TAY                     
BA53  A9 10    LDA #$10                
BA55  20 AF C8 JSR $C8AF               
BA58  20 94 BA JSR sub_BA94            
BA5B  4C 6F C9 JMP $C96F               

; ==== data $BA5E..$BA89  (44 bytes) ====
BA5E  BD E4 05 C9 04 F0 05 20 7C BE 04 60 BD CE 05 49  |....... |..`...I
BA6E  80 4C 4F BA F7 F7 08 08 08 08 F7 F7 08 F7 F7 08  |.LO.............
BA7E  F7 08 08 F7 E0 A0 60 20 60 20 E0 A0              |......` ` ..

sub_BA8A:  ; 2 xrefs: BA94 BAA2
BA8A  BD CE 05 LDA $05CE,X             
BA8D  2A       ROL A                   
BA8E  2A       ROL A                   
BA8F  2A       ROL A                   
BA90  29 03    AND #$03                
BA92  A8       TAY                     
BA93  60       RTS                     

sub_BA94:  ; 1 xrefs: BA58
BA94  20 8A BA JSR sub_BA8A            
BA97  B9 9E BA LDA $BA9E,Y             
BA9A  9D 2C 04 STA $042C,X             
BA9D  60       RTS                     

; ==== data $BA9E..$BAA1  (4 bytes) ====
BA9E  00 40 00 40                                      |.@.@

loc_BAA2:  ; 0 xrefs: 
BAA2  20 8A BA JSR sub_BA8A            
BAA5  B9 B5 BA LDA $BAB5,Y             
BAA8  48       PHA                     
BAA9  B9 B1 BA LDA $BAB1,Y             
BAAC  A8       TAY                     
BAAD  68       PLA                     
BAAE  4C 45 C9 JMP $C945               

; ==== data $BAB1..$BAB8  (8 bytes) ====
BAB1  08 08 F7 F7 08 F7 F7 08                          |........

sub_BAB9:  ; 1 xrefs: B9C7
BAB9  BD 10 06 LDA $0610,X             
BABC  F0 08    BEQ loc_BAC6            
BABE  DE 10 06 DEC $0610,X             
BAC1  20 6E BE JSR sub_BE6E            
BAC4  00 60    BRK #$60                

loc_BAC6:  ; 1 xrefs: BABC
BAC6  20 6E BE JSR sub_BE6E            
BAC9  83 60    SAX ($60,X)             
BACB  20 7E C9 JSR $C97E               
BACE  D6 BA    DEC $BA,X               
BAD0  EA       NOP                     
BAD1  BA       TSX                     
BAD2  1F BB 8C SLO $8CBB,X             

; ==== data $BAD5..$BBAA  (214 bytes) ====
BAD5  BB 20 5A BE 04 20 AD BE 24 FE CE 05 FE E4 05 20  |. Z.. ..$...... 
BAE5  B1 C9 4C 66 C9 20 37 C8 20 31 BC 20 AB BB 20 FD  |..Lf. 7. 1. .. .
BAF5  C8 20 D6 BB 20 0F AD 90 01 60 BD 68 06 29 C0 D0  |. .. ....`.h.)..
BB05  F8 A0 00 20 05 BC 20 B9 BE 00 F8 20 6E BE 89 20  |... .. .... n.. 
BB15  91 BE 80 20 98 BE 00 4C 66 C9 BD 34 05 10 08 A9  |... ...Lf..4....
BB25  64 20 0C C9 4C AB BB DE 26 06 F0 4A BD 68 06 29  |d ..L...&..J.h.)
BB35  C0 D0 43 20 6E BE 8A 20 B9 BE 00 00 20 AB BB 20  |..C n.. .... .. 
BB45  FD C8 20 D6 BB BD 3C 06 F0 05 DE 3C 06 D0 26 20  |.. ...<....<..& 
BB55  3C C9 70 22 C9 80 B0 1E C9 30 B0 19 A9 40 85 06  |<.p".....0...@..
BB65  A9 04 85 26 A9 3F 85 24 A9 00 A0 F0 20 E5 C8 B0  |...&.?.$.... ...
BB75  04 20 98 BE 20 60 20 6E BE 89 20 B9 BE 80 01 20  |. .. ` n.. .... 
BB85  B3 BE 00 00 4C 66 C9 A0 01 20 BB BC BD 68 06 29  |....Lf... ...h.)
BB95  02 D0 0C 20 3F C9 70 06 B0 05 C9 08 90 01 60 20  |... ?.p.......` 
BBA5  75 BE 08 4C 6F C9                                |u..Lo.

loc_BBAB:  ; 0 xrefs: 
BBAB  A0 01    LDY #$01                
BBAD  20 BB BC JSR sub_BCBB            
BBB0  20 D0 AC JSR sub_ACD0            
BBB3  10 15    BPL loc_BBCA            
BBB5  20 75 BE JSR sub_BE75            
BBB8  80 BD    NOP #$BD                
BBBA  60       RTS                     

; ==== data $BBBB..$BBC9  (15 bytes) ====
BBBB  05 30 06 20 B3 BE 00 FF 60 20 B3 BE 00 01 60     |.0. ....` ....`

loc_BBCA:  ; 1 xrefs: BBB3
BBCA  BD 68 06 LDA $0668,X             
BBCD  29 C0    AND #$C0                
BBCF  F0 04    BEQ loc_BBD5            
BBD1  20 75 BE JSR sub_BE75            
BBD4  01 60    ORA ($60,X)             

loc_BBD6:  ; 0 xrefs: 
BBD6  DE CE 05 DEC $05CE,X             
BBD9  F0 01    BEQ loc_BBDC            
BBDB  60       RTS                     

loc_BBDC:  ; 1 xrefs: BBD9
BBDC  20 3C C9 JSR $C93C               
BBDF  70 1A    BVS loc_BBFB            
BBE1  48       PHA                     
BBE2  BD 68 06 LDA $0668,X             
BBE5  29 C0    AND #$C0                
BBE7  F0 05    BEQ loc_BBEE            
BBE9  68       PLA                     
BBEA  A0 0A    LDY #$0A                
BBEC  D0 17    BNE loc_BC05            

loc_BBEE:  ; 1 xrefs: BBE7
BBEE  68       PLA                     
BBEF  C9 60    CMP #$60                
BBF1  B0 0C    BCS loc_BBFF            
BBF3  C9 30    CMP #$30                
BBF5  B0 0C    BCS loc_BC03            
BBF7  A0 08    LDY #$08                
BBF9  D0 0A    BNE loc_BC05            

loc_BBFB:  ; 1 xrefs: BBDF
BBFB  A0 02    LDY #$02                
BBFD  D0 06    BNE loc_BC05            

loc_BBFF:  ; 1 xrefs: BBF1
BBFF  A0 04    LDY #$04                
BC01  D0 02    BNE loc_BC05            

loc_BC03:  ; 1 xrefs: BBF5
BC03  A0 06    LDY #$06                

loc_BC05:  ; 4 xrefs: BBEC BBF9 BBFD BC01
BC05  B9 1B BC LDA $BC1B,Y             
BC08  9D CE 05 STA $05CE,X             
BC0B  B9 1C BC LDA $BC1C,Y             
BC0E  A8       TAY                     
BC0F  B9 28 BC LDA $BC28,Y             
BC12  48       PHA                     
BC13  B9 27 BC LDA $BC27,Y             
BC16  A8       TAY                     
BC17  68       PLA                     
BC18  4C 00 C9 JMP $C900               

; ==== data $BC1B..$BC30  (22 bytes) ====
BC1B  40 04 10 00 20 02 30 04 60 06 20 08 00 FE 40 FE  |@... .0.`. ...@.
BC2B  80 FE C0 FE E0 FF                                |......

loc_BC31:  ; 0 xrefs: 
BC31  DE E4 05 DEC $05E4,X             
BC34  F0 01    BEQ loc_BC37            
BC36  60       RTS                     

loc_BC37:  ; 1 xrefs: BC34
BC37  20 7C BE JSR sub_BE7C            

; ==== data $BC3A..$BC61  (40 bytes) ====
BC3A  22 20 3F C9 08 70 29 48 BD 68 06 29 C0 F0 04 68  |" ?..p)H.h.)...h
BC4A  4C 62 BC 68 C9 60 B0 14 C9 30 B0 0C C9 10 B0 04  |Lb.h.`...0......
BC5A  A0 08 D0 0E A0 06 D0 0A                          |........

loc_BC62:  ; 0 xrefs: 
BC62  A0 04    LDY #$04                
BC64  D0 06    BNE loc_BC6C            
BC66  A0 02    LDY #$02                
BC68  D0 02    BNE loc_BC6C            
BC6A  A0 00    LDY #$00                

loc_BC6C:  ; 2 xrefs: BC64 BC68
BC6C  B9 80 BC LDA $BC80,Y             
BC6F  48       PHA                     
BC70  B9 7F BC LDA $BC7F,Y             
BC73  A8       TAY                     
BC74  68       PLA                     
BC75  20 09 C9 JSR $C909               
BC78  28       PLP                     
BC79  90 03    BCC loc_BC7E            
BC7B  4C 21 C9 JMP $C921               

loc_BC7E:  ; 1 xrefs: BC79
BC7E  60       RTS                     

; ==== data $BC7F..$BCBA  (60 bytes) ====
BC7F  80 01 00 01 80 00 40 00 20 00 BD 8C 05 D0 0D 20  |......@. ...... 
BC8F  A2 C9 20 AD BE 33 20 93 C9 4C 66 C9 20 37 C8 20  |.. ..3 ..Lf. 7. 
BC9F  D2 C9 BD 34 05 1D 4A 05 D0 0F BD CE 05 C9 06 B0  |...4..J.........
BCAF  08 FE CE 05 A0 01 20 30 C9 4C EB C8              |...... 0.L..

sub_BCBB:  ; 2 xrefs: B373 BBAD
BCBB  B9 A3 BD LDA $BDA3,Y             
BCBE  85 08    STA $08                 
BCC0  B9 A7 BD LDA $BDA7,Y             
BCC3  85 09    STA $09                 
BCC5  BD 34 05 LDA $0534,X             
BCC8  1D 4A 05 ORA $054A,X             
BCCB  F0 56    BEQ loc_BD23            
BCCD  BD 68 06 LDA $0668,X             
BCD0  4A       LSR A                   
BCD1  B0 0A    BCS loc_BCDD            
BCD3  4A       LSR A                   
BCD4  90 16    BCC loc_BCEC            
BCD6  BD 34 05 LDA $0534,X             
BCD9  30 0E    BMI loc_BCE9            
BCDB  10 05    BPL loc_BCE2            

loc_BCDD:  ; 1 xrefs: BCD1
BCDD  BD 34 05 LDA $0534,X             
BCE0  10 07    BPL loc_BCE9            

loc_BCE2:  ; 1 xrefs: BCDB
BCE2  20 3E BE JSR sub_BE3E            
BCE5  F0 05    BEQ loc_BCEC            
BCE7  D0 3A    BNE loc_BD23            

loc_BCE9:  ; 2 xrefs: BCD9 BCE0
BCE9  20 91 BD JSR sub_BD91            

loc_BCEC:  ; 2 xrefs: BCD4 BCE5
BCEC  A0 00    LDY #$00                
BCEE  BD 34 05 LDA $0534,X             
BCF1  10 01    BPL loc_BCF4            
BCF3  C8       INY                     

loc_BCF4:  ; 1 xrefs: BCF1
BCF4  B1 08    LDA ($08),Y             
BCF6  A8       TAY                     
BCF7  A9 07    LDA #$07                
BCF9  20 4E C9 JSR $C94E               
BCFC  30 09    BMI loc_BD07            
BCFE  20 F4 C8 JSR $C8F4               
BD01  20 91 BD JSR sub_BD91            
BD04  4C 23 BD JMP loc_BD23            

loc_BD07:  ; 1 xrefs: BCFC
BD07  20 91 BD JSR sub_BD91            
BD0A  BD 34 05 LDA $0534,X             
BD0D  30 04    BMI loc_BD13            
BD0F  A9 02    LDA #$02                
BD11  D0 02    BNE loc_BD15            

loc_BD13:  ; 1 xrefs: BD0D
BD13  A9 01    LDA #$01                

loc_BD15:  ; 1 xrefs: BD11
BD15  1D 68 06 ORA $0668,X             
BD18  9D 68 06 STA $0668,X             
BD1B  A9 00    LDA #$00                
BD1D  9D 34 05 STA $0534,X             
BD20  9D 4A 05 STA $054A,X             

loc_BD23:  ; 3 xrefs: BCCB BCE7 BD04
BD23  BD 60 05 LDA $0560,X             
BD26  1D 76 05 ORA $0576,X             
BD29  F0 65    BEQ loc_BD90            
BD2B  BD 68 06 LDA $0668,X             
BD2E  0A       ASL A                   
BD2F  B0 0A    BCS loc_BD3B            
BD31  0A       ASL A                   
BD32  90 16    BCC loc_BD4A            
BD34  BD 60 05 LDA $0560,X             
BD37  30 0E    BMI loc_BD47            
BD39  10 05    BPL loc_BD40            

loc_BD3B:  ; 1 xrefs: BD2F
BD3B  BD 60 05 LDA $0560,X             
BD3E  10 07    BPL loc_BD47            

loc_BD40:  ; 1 xrefs: BD39
BD40  20 3E BE JSR sub_BE3E            
BD43  F0 05    BEQ loc_BD4A            
BD45  D0 49    BNE loc_BD90            

loc_BD47:  ; 2 xrefs: BD37 BD3E
BD47  20 9A BD JSR sub_BD9A            

loc_BD4A:  ; 2 xrefs: BD32 BD43
BD4A  A0 04    LDY #$04                
BD4C  BD 60 05 LDA $0560,X             
BD4F  10 01    BPL loc_BD52            
BD51  C8       INY                     

loc_BD52:  ; 1 xrefs: BD4F
BD52  B1 08    LDA ($08),Y             
BD54  85 0A    STA $0A                 
BD56  A0 02    LDY #$02                
BD58  B1 08    LDA ($08),Y             
BD5A  A8       TAY                     
BD5B  A5 0A    LDA $0A                 
BD5D  20 45 C9 JSR $C945               
BD60  30 12    BMI loc_BD74            
BD62  A0 03    LDY #$03                
BD64  B1 08    LDA ($08),Y             
BD66  A8       TAY                     
BD67  A5 0A    LDA $0A                 
BD69  20 45 C9 JSR $C945               
BD6C  30 06    BMI loc_BD74            
BD6E  20 F7 C8 JSR $C8F7               
BD71  4C 9A BD JMP sub_BD9A            

loc_BD74:  ; 2 xrefs: BD60 BD6C
BD74  20 9A BD JSR sub_BD9A            
BD77  BD 60 05 LDA $0560,X             
BD7A  30 04    BMI loc_BD80            
BD7C  A9 40    LDA #$40                
BD7E  D0 02    BNE loc_BD82            

loc_BD80:  ; 1 xrefs: BD7A
BD80  A9 80    LDA #$80                

loc_BD82:  ; 1 xrefs: BD7E
BD82  1D 68 06 ORA $0668,X             
BD85  9D 68 06 STA $0668,X             
BD88  A9 00    LDA #$00                
BD8A  9D 60 05 STA $0560,X             
BD8D  9D 76 05 STA $0576,X             

loc_BD90:  ; 2 xrefs: BD29 BD45
BD90  60       RTS                     

sub_BD91:  ; 3 xrefs: BCE9 BD01 BD07
BD91  BD 68 06 LDA $0668,X             
BD94  29 FC    AND #$FC                
BD96  9D 68 06 STA $0668,X             
BD99  60       RTS                     

sub_BD9A:  ; 3 xrefs: BD47 BD71 BD74
BD9A  BD 68 06 LDA $0668,X             
BD9D  29 3F    AND #$3F                
BD9F  9D 68 06 STA $0668,X             
BDA2  60       RTS                     

; ==== data $BDA3..$BDBE  (28 bytes) ====
BDA3  AB B1 B7 B7 BD BD BD BD 10 F0 08 F8 0C F4 04 E0  |................
BDB3  FC EC 0C F4 04 E0 F8 E8 0C F4 BD 8C              |............

loc_BDBF:  ; 0 xrefs: 
BDBF  05 C9    ORA $C9                 
BDC1  06 B0    ASL $B0                 
BDC3  04 A9    NOP $A9                 
BDC5  00 85    BRK #$85                

; ==== data $BDC7..$BDFC  (54 bytes) ====
BDC7  5F 20 7E C9 99 C9 99 C9 99 C9 99 C9 99 C9 99 C9  |_ ~.............
BDD7  F7 87 2D 88 3B 89 77 89 94 89 BA 89 D1 89 E4 89  |..-.;.w.........
BDE7  F1 89 20 7E C9 FE BD 0F BE 1B BE F7 87 2D 88 71  |.. ~.........-.q
BDF7  88 95 88 D8 88 EB                                |......

loc_BDFD:  ; 0 xrefs: 
BDFD  88       DEY                     
BDFE  A5 27    LDA $27                 
BE00  C9 03    CMP #$03                
BE02  F0 01    BEQ loc_BE05            
BE04  60       RTS                     

loc_BE05:  ; 1 xrefs: BE02
BE05  20 9F C9 JSR $C99F               
BE08  20 7C BE JSR sub_BE7C            
BE0B  20 4C 66 JSR $664C               
BE0E  C9 A5    CMP #$A5                
BE10  27 C9    RLA $C9                 
BE12  03 D0    SLO ($D0,X)             
BE14  EF DE E4 ISC $E4DE               
BE17  05 F0    ORA $F0                 

; ==== data $BE19..$BE21  (9 bytes) ====
BE19  F2 60 A9 00 85 5F 4C 99 C9                       |.`..._L..

loc_BE22:  ; 0 xrefs: 
BE22  A4 53    LDY $53                 
BE24  B9 36 BE LDA $BE36,Y             
BE27  05 5B    ORA $5B                 
BE29  85 5B    STA $5B                 
BE2B  60       RTS                     

; ==== data $BE2C..$BE3D  (18 bytes) ====
BE2C  A4 53 B9 36 BE 05 56 85 56 60 01 02 04 08 10 20  |.S.6..V.V`..... 
BE3C  40 80                                            |@.

sub_BE3E:  ; 2 xrefs: BCE2 BD40
BE3E  8A       TXA                     
BE3F  4D 19 01 EOR $0119               
BE42  29 01    AND #$01                
BE44  60       RTS                     

sub_BE45:  ; 12 xrefs: BE5A BE63 BE6E BE75 BE7C BE83 BE8A BE91 BE98 BE9F ...
BE45  A0 01    LDY #$01                
BE47  20 C7 C8 JSR $C8C7               
BE4A  AD 80 01 LDA $0180               
BE4D  60       RTS                     

sub_BE4E:  ; 9 xrefs: BEB3 BEB9 BEBF BEC5 BECB BED1 BEDD BEE3 BEE9
BE4E  A0 02    LDY #$02                
BE50  20 C7 C8 JSR $C8C7               
BE53  AD 81 01 LDA $0181               
BE56  AC 80 01 LDY $0180               
BE59  60       RTS                     

sub_BE5A:  ; 2 xrefs: 936F B9BC
BE5A  20 45 BE JSR sub_BE45            
BE5D  9D 9A 04 STA $049A,X             
BE60  4C 9F C9 JMP $C99F               

loc_BE63:  ; 0 xrefs: 
BE63  20 45 BE JSR sub_BE45            

loc_BE66:  ; 1 xrefs: BE6C
BE66  9D 9A 04 STA $049A,X             
BE69  60       RTS                     

loc_BE6A:  ; 0 xrefs: 
BE6A  A9 FF    LDA #$FF                
BE6C  D0 F8    BNE loc_BE66            

sub_BE6E:  ; 7 xrefs: 9137 94A8 94FD A9D1 B6B2 BAC1 BAC6
BE6E  20 45 BE JSR sub_BE45            
BE71  9D 42 04 STA $0442,X             
BE74  60       RTS                     

sub_BE75:  ; 9 xrefs: 9501 A9C9 AA21 AB2F B07E B08B B992 BBB5 BBD1
BE75  20 45 BE JSR sub_BE45            
BE78  9D CE 05 STA $05CE,X             
BE7B  60       RTS                     

sub_BE7C:  ; 7 xrefs: 8E17 9259 95A8 A796 B853 BC37 BE08
BE7C  20 45 BE JSR sub_BE45            
BE7F  9D E4 05 STA $05E4,X             
BE82  60       RTS                     

sub_BE83:  ; 3 xrefs: 8EFD 985C A92E
BE83  20 45 BE JSR sub_BE45            
BE86  9D FA 05 STA $05FA,X             
BE89  60       RTS                     

loc_BE8A:  ; 0 xrefs: 
BE8A  20 45 BE JSR sub_BE45            
BE8D  9D 10 06 STA $0610,X             
BE90  60       RTS                     

sub_BE91:  ; 4 xrefs: B343 B598 B5A1 B970
BE91  20 45 BE JSR sub_BE45            
BE94  9D 26 06 STA $0626,X             
BE97  60       RTS                     

sub_BE98:  ; 2 xrefs: A405 B95D
BE98  20 45 BE JSR sub_BE45            
BE9B  9D 3C 06 STA $063C,X             
BE9E  60       RTS                     

sub_BE9F:  ; 2 xrefs: 9151 A14F
BE9F  20 45 BE JSR sub_BE45            
BEA2  9D 52 06 STA $0652,X             
BEA5  60       RTS                     

loc_BEA6:  ; 0 xrefs: 
BEA6  20 45 BE JSR sub_BE45            
BEA9  9D 68 06 STA $0668,X             
BEAC  60       RTS                     

sub_BEAD:  ; 2 xrefs: AA18 ACAF
BEAD  20 45 BE JSR sub_BE45            
BEB0  4C 3A C8 JMP $C83A               

sub_BEB3:  ; 7 xrefs: 95C4 98A1 993D B58E B834 B884 B8A1
BEB3  20 4E BE JSR sub_BE4E            
BEB6  4C 06 C9 JMP $C906               

sub_BEB9:  ; 11 xrefs: 94EE 95DC 9610 98E1 98ED A754 B56A B579 B581 B8D1 ...
BEB9  20 4E BE JSR sub_BE4E            
BEBC  4C 09 C9 JMP $C909               

sub_BEBF:  ; 4 xrefs: 986A 987C AA1C AB37
BEBF  20 4E BE JSR sub_BE4E            
BEC2  4C 00 C9 JMP $C900               

sub_BEC5:  ; 4 xrefs: A929 ACC1 B292 B347
BEC5  20 4E BE JSR sub_BE4E            
BEC8  4C 03 C9 JMP $C903               

sub_BECB:  ; 4 xrefs: 94DB 94F3 9C23 B487
BECB  20 4E BE JSR sub_BE4E            
BECE  4C 45 C9 JMP $C945               

sub_BED1:  ; 1 xrefs: 9BFE
BED1  20 4E BE JSR sub_BE4E            
BED4  4C 48 C9 JMP $C948               

; ==== data $BED7..$BEDC  (6 bytes) ====
BED7  20 4E BE 4C 4B C9                                | N.LK.

loc_BEDD:  ; 0 xrefs: 
BEDD  20 4E BE JSR sub_BE4E            
BEE0  4C 4E C9 JMP $C94E               

sub_BEE3:  ; 1 xrefs: A74D
BEE3  20 4E BE JSR sub_BE4E            
BEE6  4C 51 C9 JMP $C951               

loc_BEE9:  ; 0 xrefs: 
BEE9  20 4E BE JSR sub_BE4E            
BEEC  4C 60 C9 JMP $C960               

sub_BEEF:  ; 3 xrefs: BF00 BF06 BF12
BEEF  A0 03    LDY #$03                
BEF1  20 C7 C8 JSR $C8C7               
BEF4  AD 80 01 LDA $0180               
BEF7  85 00    STA $00                 
BEF9  AD 81 01 LDA $0181               
BEFC  AC 82 01 LDY $0182               
BEFF  60       RTS                     

loc_BF00:  ; 0 xrefs: 
BF00  20 EF BE JSR sub_BEEF            
BF03  4C 54 C9 JMP $C954               

sub_BF06:  ; 4 xrefs: 8EDC 90FC A78B AAE0
BF06  20 EF BE JSR sub_BEEF            
BF09  4C 57 C9 JMP $C957               

; ==== data $BF0C..$BF11  (6 bytes) ====
BF0C  20 EF BE 4C 5A C9                                | ..LZ.

loc_BF12:  ; 0 xrefs: 
BF12  20 EF BE JSR sub_BEEF            
BF15  4C 5D C9 JMP $C95D               

sub_BF18:  ; 1 xrefs: 8009
BF18  A9 00    LDA #$00                
BF1A  F0 0E    BEQ loc_BF2A            

loc_BF1C:  ; 0 xrefs: 
BF1C  A9 03    LDA #$03                
BF1E  D0 0A    BNE loc_BF2A            

sub_BF20:  ; 2 xrefs: A057 A608
BF20  85 24    STA $24                 
BF22  A9 06    LDA #$06                
BF24  D0 04    BNE loc_BF2A            

loc_BF26:  ; 3 xrefs: A05E A157 B1A5
BF26  85 24    STA $24                 
BF28  A9 09    LDA #$09                

loc_BF2A:  ; 3 xrefs: BF1A BF1E BF24
BF2A  85 00    STA $00                 
BF2C  A9 8E    LDA #$8E                
BF2E  85 01    STA $01                 
BF30  A5 24    LDA $24                 
BF32  4C CD C8 JMP $C8CD               

; ==== data $BF35..$BFFF  (203 bytes) ====
BF35  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF45  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF55  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF65  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF75  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF85  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF95  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFA5  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFB5  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFC5  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFD5  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFE5  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFF5  FF FF FF FF FF FF FF FF FF FF FF                 |...........