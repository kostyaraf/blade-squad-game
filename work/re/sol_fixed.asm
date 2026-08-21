
; ---- data $C000-$C080 (129 bytes) ----
C000  4C F2 C2 4C DC F3 4C E5 F3 4C F0 F3 4C 32 D0 4C  |L..L..L..L..L2.L
C010  10 D0 4C 8C E5 4C 7C EC 4C E7 EC 4C 54 E5 4C 92  |..L..L|.L..LT.L.
C020  F7 4C CE EA 4C D3 F7 4C 15 EB 4C 96 CF 4C BA CF  |.L..L..L..L..L..
C030  4C 0E EA 4C 05 D0 4C AC C2 4C 01 C3 4C AB C3 4C  |L..L..L..L..L..L
C040  41 C2 4C 8B C2 4C A9 E9 4C AD E9 4C A5 E9 4C 35  |A.L..L..L..L..L5
C050  F8 4C 2E C1 4C 2A C2 4C 00 C2 4C 1E F8 4C 26 E6  |.L..L*.L..L..L&.
C060  4C B6 E9 4C BC E9 4C C0 E9 4C C4 E9 4C C8 E9 4C  |L..L..L..L..L..L
C070  CC E9 4C FA C0 4C DA C1 4C B9 C0 4C ED C0 4C AC  |..L..L..L..L..L.
C080  C0                                               |.

sub_C081:  ; xrefs(1): $E48E
C081  4C 9E C0 JMP $C09E                 

; ---- data $C084-$C09D (26 bytes) ----
C084  4C 85 C1 4C 90 C0 4C 4F C1 4C 40 C1 A9 04 20 2C  |L..L..LO.L@... ,
C094  C9 20 9B C0 4C 98 C9 6C 9E 00                    |. ..L..l..

loc_C09E:  ; xrefs(1): $C081
C09E  A9 06    LDA #$06                  
C0A0  20 2C C9 JSR $C92C                 
C0A3  20 A9 C0 JSR $C0A9                 
C0A6  4C 98 C9 JMP $C998                 

sub_C0A9:  ; xrefs(1): $C0A3
C0A9  6C 90 00 JMP ($0090)               

; ---- data $C0AC-$C2DF (564 bytes) ----
C0AC  A9 06 20 2C C9 20 04 80 A9 02 4C 2C C9 E6 47 A0  |.. ,. ....L,..G.
C0BC  06 8C 00 80 A0 0C 8C 01 80 A0 07 8C 00 80 A0 0D  |................
C0CC  8C 01 80 C6 47 20 10 80 E6 47 A9 06 8D 00 80 A9  |....G ...G......
C0DC  02 8D 01 80 A9 07 8D 00 80 A9 03 8D 01 80 C6 47  |...............G
C0EC  60 48 A9 0C 20 2C C9 68 20 10 80 4C 98 C9 E6 47  |`H.. ,.h ..L...G
C0FC  A9 06 8D 00 80 A9 0C 8D 01 80 A9 07 8D 00 80 A9  |................
C10C  0D 8D 01 80 C6 47 20 13 80 E6 47 A9 06 8D 00 80  |.....G ...G.....
C11C  A9 02 8D 01 80 A9 07 8D 00 80 A9 03 8D 01 80 C6  |................
C12C  47 60 84 90 A9 0C 20 2C C9 A4 90 20 04 80 48 20  |G`.... ,... ..H 
C13C  98 C9 68 60 A2 0E CA D0 FD A5 47 D0 03 20 57 C3  |..h`......G.. W.
C14C  4C F2 C2 A2 03 CA D0 FD 8E 00 80 8E 01 80 A5 02  |L...............
C15C  C9 03 90 06 A5 4C 29 04 F0 0F A5 7B F0 0E A2 05  |.....L)....{....
C16C  CA D0 FD 8E 00 80 8E 01 80 4C F2 C2 A9 08 8D 00  |.........L......
C17C  C0 20 57 C3 E6 7B 4C F9 C2 A2 07 CA D0 FD EA A5  |. W..{L.........
C18C  73 49 18 85 73 38 E9 01 8D 00 C0 A6 7B BD 80 07  |sI..s8......{...
C19C  8D 05 20 A5 7E 8D 05 20 A5 74 49 08 85 74 29 08  |.. .~.. .tI..t).
C1AC  F0 14 A9 00 8D 00 80 8D 01 80 A9 01 8D 00 80 A9  |................
C1BC  02 8D 01 80 D0 07 A5 47 D0 03 20 57 C3 E6 7B A5  |.......G.. W..{.
C1CC  7B C9 0C D0 06 20 08 E5 8D 00 E0 4C F9 C2 A5 79  |{.... .....L...y
C1DC  09 02 8D 00 20 A5 76 8D 06 20 A5 77 8D 06 20 A5  |.... .v.. .w.. .
C1EC  78 8D 05 20 A5 7E 8D 05 20 A5 73 85 77 A5 74 85  |x.. .~.. .s.w.t.
C1FC  76 4C F2 C2 A5 7B D0 14 A9 30 8D 00 C0 A5 48 8D  |vL...{...0....H.
C20C  05 20 A5 7E 8D 05 20 E6 7B 4C F9 C2 A5 79 8D 00  |. .~.. .{L...y..
C21C  20 A5 78 8D 05 20 A5 7E 8D 05 20 4C F2 C2 A5 7B  | .x.. .~.. L...{
C22C  F0 36 C9 02 90 32 F0 30 C9 04 90 2C F0 2A C9 06  |.6...2.0...,.*..
C23C  90 26 4C 51 C2 A5 7B F0 1F C9 02 90 1B F0 19 C9  |.&LQ..{.........
C24C  04 90 15 F0 13 8D 00 E0 A5 08 8D 00 20 A9 00 8D  |............ ...
C25C  05 20 8D 05 20 4C F9 C2 AA BD 40 07 8D 00 C0 A5  |. .. L....@.....
C26C  08 29 FE 85 48 BD 50 07 29 01 05 48 8D 00 20 BD  |.)..H.P.)..H.. .
C27C  60 07 8D 05 20 A9 00 8D 05 20 E6 7B 4C F9 C2 A5  |`... .... .{L...
C28C  08 29 FE 85 48 AD 50 07 29 01 05 48 8D 00 20 AD  |.)..H.P.)..H.. .
C29C  60 07 8D 05 20 A9 00 8D 05 20 8D 00 E0 4C F9 C2  |`... .... ...L..
C2AC  A5 7B D0 16 A9 01 8D 00 C0 A2 0A CA D0 FD A5 09  |.{..............
C2BC  29 EF 8D 01 20 E6 7B 4C F9 C2 A5 72 8D 00 C0 2C  |)... .{L...r...,
C2CC  02 20 50 0D A2 0E CA D0 FD A5 09 8D 01 20 8D 00  |. P.......... ..
C2DC  E0 4C F9 C2                                      |.L..

loc_C2E0:  ; xrefs(0): 
C2E0  E6 7A    INC $7A                   
C2E2  48       PHA                       
C2E3  8A       TXA                       
C2E4  48       PHA                       
C2E5  A5 7A    LDA $7A                   
C2E7  F0 10    BEQ $C2F9                 
C2E9  8D 00 E0 STA $E000                 
C2EC  8D 01 E0 STA $E001                 
C2EF  6C 70 00 JMP ($0070)               

; ---- data $C2F2-$C2F8 (7 bytes) ----
C2F2  A9 00 85 7B 8D 00 E0                             |...{...

loc_C2F9:  ; xrefs(1): $C2E7
C2F9  A9 00    LDA #$00                  
C2FB  85 7A    STA $7A                   
C2FD  68       PLA                       
C2FE  AA       TAX                       
C2FF  68       PLA                       
C300  40       RTI                       

; ---- data $C301-$C356 (86 bytes) ----
C301  A9 02 8D 00 C0 A5 74 18 AA 29 20 D0 14 8A 29 1F  |......t..) ...).
C311  65 72 AA 18 BD 71 C4 65 78 AA A5 79 B0 16 4C 37  |er...q.ex..y..L7
C321  C3 8A 29 1F 65 72 AA 38 A5 78 FD 71 C4 AA A5 79  |..).er.8.x.q...y
C331  B0 EC 90 00 49 01 8D 00 20 8E 05 20 A5 7E 8D 05  |....I... .. .~..
C341  20 18 A5 74 65 73 85 74 2C 02 20 50 AB 8D 00 E0  | ..tes.t,. P....
C351  20 5E C4 4C F9 C2                                | ^.L..

sub_C357:  ; xrefs(1): $D20F
C357  A9 00    LDA #$00                  
C359  8D 00 80 STA $8000                 
C35C  A9 62    LDA #$62                  
C35E  8D 01 80 STA $8001                 
C361  A9 01    LDA #$01                  
C363  8D 00 80 STA $8000                 
C366  A9 62    LDA #$62                  
C368  8D 01 80 STA $8001                 
C36B  60       RTS                       

; ---- data $C36C-$C534 (457 bytes) ----
C36C  A5 75 29 07 85 48 D0 06 EA EA EA EA F0 06 49 07  |.u)..H........I.
C37C  85 48 E6 48 A5 7E 29 07 49 07 38 65 48 8D 00 C0  |.H.H.~).I.8eH...
C38C  A5 47 D0 03 20 57 C3 E6 7B 4C F9 C2 18 A5 75 65  |.G.. W..{L....ue
C39C  74 85 75 A9 00 85 7B 85 74 8D 00 E0 4C F9 C2 A5  |t.u...{.t...L...
C3AC  7B F0 3D C9 02 90 B9 F0 7F A2 02 CA D0 FD A5 47  |{.=............G
C3BC  F0 08 A9 01 8D 00 C0 4C F9 C2 A5 79 09 80 8D 00  |.......L...y....
C3CC  20 8E 00 80 A9 28 8D 01 80 A9 01 8D 00 80 A5 41  | ....(.........A
C3DC  8D 01 80 18 A5 75 65 74 85 75 20 A1 C4 4C 9F C3  |.....uet.u ..L..
C3EC  A9 1D 8D 00 C0 A2 05 CA D0 FD EA EA AD 02 20 A9  |.............. .
C3FC  06 8D 06 20 A9 40 8D 06 20 A9 00 8D 05 20 8D 05  |... .@.. .... ..
C40C  20 A5 79 49 81 8D 00 20 E6 7B A5 75 C9 C0 90 11  | .yI... .{.u....
C41C  A5 09 8D 01 20 A5 79 49 01 09 80 8D 00 20 4C 98  |.... .yI..... L.
C42C  C3 29 07 85 73 4C F9 C2 A5 7E 29 07 18 69 01 8D  |.)..sL...~)..i..
C43C  00 C0 A5 76 8D 06 20 A5 77 8D 06 20 A5 78 8D 05  |...v.. .w.. .x..
C44C  20 A5 7E 8D 05 20 A5 47 D0 03 20 57 C3 E6 7B 4C  | .~.. .G.. W..{L
C45C  A8 C3 A5 79 8D 00 20 AD 02 20 A5 78 8D 05 20 85  |...y.. .. .x.. .
C46C  7E 8D 05 20 60 00 01 01 01 02 02 03 03 03 03 04  |~.. `...........
C47C  04 04 04 04 04 04 04 04 04 04 04 04 03 03 03 03  |................
C48C  02 02 01 01 01 00 01 01 01 02 02 03 03 03 03 04  |................
C49C  04 04 04 04 04 A5 34 D0 0D 18 A5 75 29 07 85 48  |......4....u)..H
C4AC  D0 0D A9 0A D0 18 18 A5 75 29 07 85 48 F0 0F 49  |........u)..H..I
C4BC  07 85 48 E6 48 A5 7E 29 07 49 07 38 65 48 65 75  |..H.H.~).I.8eHeu
C4CC  85 48 A9 00 46 48 6A 46 48 6A 46 48 6A 46 48 6A  |.H..FHjFHjFHjFHj
C4DC  65 32 85 4A A5 33 65 48 69 02 85 4B A5 4B 85 76  |e2.J.3eHi..K.K.v
C4EC  A5 4A 0A 26 76 0A 26 76 0A 26 76 0A 26 76 A5 4B  |.J.&v.&v.&v.&v.K
C4FC  29 F0 18 65 76 B0 08 AA 69 10 B0 05 8A 90 02 69  |)..ev...i......i
C50C  0F 29 F8 AA 85 77 A9 00 06 77 2A 06 77 2A 85 76  |.)...w...w*.w*.v
C51C  18 A9 00 65 77 85 77 A9 20 65 76 85 76 60 A9 A8  |...ew.w. ev.v`..
C52C  85 79 85 08 A9 1E 85 09 60                       |.y......`

sub_C535:  ; xrefs(24): $D1BA $D28E $D2F8 $D522 $D6CD $D7BF $D7D3 $D87D $D8B9 $D8E1
C535  AD 02 20 LDA $2002                 
C538  A5 09    LDA $09                   
C53A  29 E3    AND #$E3                  
C53C  09 1C    ORA #$1C                  
C53E  48       PHA                       
C53F  A5 08    LDA $08                   
C541  09 A8    ORA #$A8                  
C543  48       PHA                       
C544  A5 0A    LDA $0A                   
C546  85 78    STA $78                   
C548  A8       TAY                       
C549  18       CLC                       
C54A  A5 0B    LDA $0B                   
C54C  6D F8 05 ADC $05F8                 
C54F  C9 F0    CMP #$F0                  
C551  90 02    BCC $C555                 
C553  E9 F0    SBC #$F0                  

loc_C555:  ; xrefs(1): $C551
C555  AA       TAX                       
C556  AD 02 20 LDA $2002                 
C559  A9 00    LDA #$00                  
C55B  8D 06 20 STA $2006                 
C55E  8D 06 20 STA $2006                 
C561  8C 05 20 STY $2005                 
C564  8E 05 20 STX $2005                 
C567  86 7E    STX $7E                   
C569  68       PLA                       
C56A  8D 00 20 STA $2000                 
C56D  85 79    STA $79                   
C56F  85 08    STA $08                   
C571  68       PLA                       
C572  8D 01 20 STA $2001                 
C575  85 09    STA $09                   
C577  60       RTS                       

sub_C578:  ; xrefs(8): $C5C9 $D96A $DA3D $DA8F $DB70 $E203 $E33A $E520
C578  A9 00    LDA #$00                  
C57A  85 0A    STA $0A                   
C57C  85 0B    STA $0B                   
C57E  85 78    STA $78                   
C580  85 7E    STA $7E                   
C582  A5 09    LDA $09                   
C584  09 02    ORA #$02                  
C586  29 EF    AND #$EF                  
C588  85 09    STA $09                   
C58A  8D 01 20 STA $2001                 
C58D  20 BC FA JSR $FABC                 
C590  A5 09    LDA $09                   
C592  29 E7    AND #$E7                  
C594  85 09    STA $09                   
C596  8D 01 20 STA $2001                 
C599  20 BC FA JSR $FABC                 

sub_C59C:  ; xrefs(1): $D63F
C59C  20 B5 C6 JSR $C6B5                 

sub_C59F:  ; xrefs(1): $FAD7
C59F  A9 06    LDA #$06                  
C5A1  8D 01 20 STA $2001                 
C5A4  A5 08    LDA $08                   
C5A6  29 2B    AND #$2B                  
C5A8  8D 00 20 STA $2000                 
C5AB  85 79    STA $79                   
C5AD  85 08    STA $08                   
C5AF  60       RTS                       

sub_C5B0:  ; xrefs(3): $C5CC $D47D $E33D
C5B0  A9 0F    LDA #$0F                  
C5B2  A0 1F    LDY #$1F                  

loc_C5B4:  ; xrefs(1): $C5B8
C5B4  99 00 01 STA $0100,Y               
C5B7  88       DEY                       
C5B8  10 FA    BPL $C5B4                 
C5BA  60       RTS                       

sub_C5BB:  ; xrefs(1): $C5DD
C5BB  A5 08    LDA $08                   
C5BD  29 FB    AND #$FB                  
C5BF  8D 00 20 STA $2000                 
C5C2  60       RTS                       

; ---- data $C5C3-$C5C8 (6 bytes) ----
C5C3  A5 08 09 04 D0 F6                                |......

sub_C5C9:  ; xrefs(15): $D1BD $D262 $D2AC $D6D0 $D79F $D7D0 $D863 $D8A7 $D8C7 $D90B
C5C9  20 78 C5 JSR $C578                 

sub_C5CC:  ; xrefs(1): $F89C
C5CC  20 B0 C5 JSR $C5B0                 
C5CF  A9 0C    LDA #$0C                  
C5D1  20 18 C6 JSR $C618                 
C5D4  A5 08    LDA $08                   
C5D6  29 FC    AND #$FC                  
C5D8  85 08    STA $08                   

sub_C5DA:  ; xrefs(6): $D96D $DA44 $DA92 $DB73 $E209 $E523
C5DA  A9 00    LDA #$00                  

sub_C5DC:  ; xrefs(1): $E350
C5DC  48       PHA                       
C5DD  20 BB C5 JSR $C5BB                 
C5E0  68       PLA                       
C5E1  48       PHA                       
C5E2  A0 20    LDY #$20                  
C5E4  A2 00    LDX #$00                  
C5E6  20 FE C5 JSR $C5FE                 
C5E9  68       PLA                       
C5EA  A0 24    LDY #$24                  
C5EC  A2 00    LDX #$00                  
C5EE  4C FE C5 JMP $C5FE                 

; ---- data $C5F1-$C5F8 (8 bytes) ----
C5F1  A9 00 A0 20 AA 20 FE C5                          |... . ..

sub_C5F9:  ; xrefs(1): $E353
C5F9  A9 00    LDA #$00                  
C5FB  A0 24    LDY #$24                  
C5FD  AA       TAX                       

sub_C5FE:  ; xrefs(2): $C5E6 $C5EE
C5FE  8C 06 20 STY $2006                 
C601  8E 06 20 STX $2006                 
C604  A0 20    LDY #$20                  

loc_C606:  ; xrefs(1): $C615
C606  C0 03    CPY #$03                  
C608  B0 02    BCS $C60C                 
C60A  A9 00    LDA #$00                  

loc_C60C:  ; xrefs(1): $C608
C60C  A2 20    LDX #$20                  

loc_C60E:  ; xrefs(1): $C612
C60E  8D 07 20 STA $2007                 
C611  CA       DEX                       
C612  D0 FA    BNE $C60E                 
C614  88       DEY                       
C615  D0 EF    BNE $C606                 
C617  60       RTS                       

sub_C618:  ; xrefs(7): $C5D1 $D68B $E114 $E345 $E500 $E69D $F881
C618  A2 00    LDX #$00                  
C61A  4A       LSR A                     
C61B  90 0E    BCC $C62B                 
C61D  48       PHA                       
C61E  8A       TXA                       
C61F  A8       TAY                       

loc_C620:  ; xrefs(1): $C628
C620  C0 E0    CPY #$E0                  
C622  B0 03    BCS $C627                 
C624  99 00 00 STA $0000,Y               

loc_C627:  ; xrefs(1): $C622
C627  88       DEY                       
C628  D0 F6    BNE $C620                 
C62A  68       PLA                       

loc_C62B:  ; xrefs(1): $C61B
C62B  4A       LSR A                     
C62C  4A       LSR A                     
C62D  90 0C    BCC $C63B                 
C62F  48       PHA                       
C630  A0 00    LDY #$00                  
C632  A9 F7    LDA #$F7                  

loc_C634:  ; xrefs(1): $C638
C634  99 00 02 STA $0200,Y               
C637  88       DEY                       
C638  D0 FA    BNE $C634                 
C63A  68       PLA                       

loc_C63B:  ; xrefs(1): $C62D
C63B  4A       LSR A                     
C63C  90 0E    BCC $C64C                 
C63E  48       PHA                       
C63F  8A       TXA                       
C640  A8       TAY                       

loc_C641:  ; xrefs(1): $C649
C641  C0 C0    CPY #$C0                  
C643  B0 03    BCS $C648                 
C645  99 00 03 STA $0300,Y               

loc_C648:  ; xrefs(1): $C643
C648  88       DEY                       
C649  D0 F6    BNE $C641                 
C64B  68       PLA                       

loc_C64C:  ; xrefs(1): $C63C
C64C  4A       LSR A                     
C64D  4A       LSR A                     
C64E  90 12    BCC $C662                 
C650  48       PHA                       
C651  8A       TXA                       
C652  A8       TAY                       

loc_C653:  ; xrefs(1): $C65F
C653  C0 40    CPY #$40                  
C655  90 07    BCC $C65E                 
C657  C0 BA    CPY #$BA                  
C659  B0 03    BCS $C65E                 
C65B  99 00 05 STA $0500,Y               

loc_C65E:  ; xrefs(2): $C655 $C659
C65E  88       DEY                       
C65F  D0 F2    BNE $C653                 
C661  68       PLA                       

loc_C662:  ; xrefs(1): $C64E
C662  4A       LSR A                     
C663  90 13    BCC $C678                 
C665  48       PHA                       
C666  8A       TXA                       
C667  A8       TAY                       

loc_C668:  ; xrefs(1): $C675
C668  8A       TXA                       
C669  98       TYA                       
C66A  29 0F    AND #$0F                  
C66C  C9 0C    CMP #$0C                  
C66E  B0 04    BCS $C674                 
C670  8A       TXA                       
C671  99 00 06 STA $0600,Y               

loc_C674:  ; xrefs(1): $C66E
C674  88       DEY                       
C675  D0 F1    BNE $C668                 
C677  68       PLA                       

loc_C678:  ; xrefs(1): $C663
C678  4A       LSR A                     
C679  90 15    BCC $C690                 
C67B  8A       TXA                       
C67C  A8       TAY                       

loc_C67D:  ; xrefs(1): $C68E
C67D  8A       TXA                       
C67E  C0 80    CPY #$80                  
C680  B0 08    BCS $C68A                 
C682  98       TYA                       
C683  29 0F    AND #$0F                  
C685  C9 0B    CMP #$0B                  
C687  B0 04    BCS $C68D                 
C689  8A       TXA                       

loc_C68A:  ; xrefs(1): $C680
C68A  99 00 07 STA $0700,Y               

loc_C68D:  ; xrefs(1): $C687
C68D  88       DEY                       
C68E  D0 ED    BNE $C67D                 

loc_C690:  ; xrefs(1): $C679
C690  60       RTS                       

sub_C691:  ; xrefs(1): $F872
C691  A0 1F    LDY #$1F                  
C693  A9 0F    LDA #$0F                  

loc_C695:  ; xrefs(1): $C699
C695  99 00 01 STA $0100,Y               
C698  88       DEY                       
C699  10 FA    BPL $C695                 

sub_C69B:  ; xrefs(1): $FB1C
C69B  20 AA C6 JSR $C6AA                 

loc_C69E:  ; xrefs(1): $C6A7
C69E  B9 00 01 LDA $0100,Y               
C6A1  8D 07 20 STA $2007                 
C6A4  C8       INY                       
C6A5  C0 20    CPY #$20                  
C6A7  D0 F5    BNE $C69E                 
C6A9  60       RTS                       

sub_C6AA:  ; xrefs(2): $C69B $C6B5
C6AA  A2 3F    LDX #$3F                  
C6AC  A0 00    LDY #$00                  
C6AE  8E 06 20 STX $2006                 
C6B1  8C 06 20 STY $2006                 
C6B4  60       RTS                       

sub_C6B5:  ; xrefs(1): $C59C
C6B5  20 AA C6 JSR $C6AA                 
C6B8  A9 0F    LDA #$0F                  

loc_C6BA:  ; xrefs(1): $C6C0
C6BA  8D 07 20 STA $2007                 
C6BD  C8       INY                       
C6BE  C0 20    CPY #$20                  
C6C0  D0 F8    BNE $C6BA                 
C6C2  60       RTS                       

; ---- data $C6C3-$C6E8 (38 bytes) ----
C6C3  20 2A C9 20 B0 C5 68 85 29 68 85 2A A0 01 B1 29  | *. ..h.)h.*...)
C6D3  85 90 C8 B1 29 85 91 8A A8 B1 90 99 00 01 99 10  |....)...........
C6E3  01 88 10 F5 30 28                                |....0(

sub_C6E9:  ; xrefs(10): $D1CE $D6E2 $D7B7 $D878 $D8B4 $D8DC $D918 $D9BF $E36B $E4F1
C6E9  20 2A C9 JSR $C92A                 
C6EC  8A       TXA                       
C6ED  48       PHA                       
C6EE  20 61 F8 JSR $F861                 
C6F1  20 3D F8 JSR $F83D                 
C6F4  68       PLA                       
C6F5  AA       TAX                       
C6F6  68       PLA                       
C6F7  85 29    STA $29                   
C6F9  68       PLA                       
C6FA  85 2A    STA $2A                   
C6FC  A0 01    LDY #$01                  
C6FE  B1 29    LDA ($29),Y               
C700  85 20    STA $20                   
C702  C8       INY                       
C703  B1 29    LDA ($29),Y               
C705  85 21    STA $21                   
C707  8A       TXA                       
C708  A8       TAY                       

loc_C709:  ; xrefs(1): $C70F
C709  B1 20    LDA ($20),Y               
C70B  99 00 01 STA $0100,Y               
C70E  88       DEY                       
C70F  10 F8    BPL $C709                 
C711  C8       INY                       
C712  B1 20    LDA ($20),Y               
C714  A6 1C    LDX $1C                   

loc_C716:  ; xrefs(1): $C71D
C716  9D 00 01 STA $0100,X               
C719  CA       DEX                       
C71A  CA       DEX                       
C71B  CA       DEX                       
C71C  CA       DEX                       
C71D  10 F7    BPL $C716                 
C71F  18       CLC                       
C720  A5 29    LDA $29                   
C722  69 02    ADC #$02                  
C724  A8       TAY                       
C725  A5 2A    LDA $2A                   
C727  69 00    ADC #$00                  
C729  48       PHA                       
C72A  98       TYA                       
C72B  48       PHA                       
C72C  60       RTS                       

sub_C72D:  ; xrefs(7): $CA9A $CD93 $D525 $E4AF $F9EA $F9F3 $FA69
C72D  A5 00    LDA $00                   
C72F  85 6B    STA $6B                   
C731  A9 00    LDA #$00                  
C733  85 6A    STA $6A                   
C735  18       CLC                       
C736  A5 69    LDA $69                   
C738  69 50    ADC #$50                  
C73A  C9 20    CMP #$20                  
C73C  B0 02    BCS $C740                 
C73E  69 E0    ADC #$E0                  

loc_C740:  ; xrefs(1): $C73C
C740  85 69    STA $69                   
C742  85 6C    STA $6C                   
C744  AA       TAX                       
C745  CA       DEX                       
C746  E0 20    CPX #$20                  
C748  B0 02    BCS $C74C                 
C74A  A2 FF    LDX #$FF                  

loc_C74C:  ; xrefs(1): $C748
C74C  86 6D    STX $6D                   
C74E  A9 F7    LDA #$F7                  
C750  8D 20 02 STA $0220                 
C753  8D 30 02 STA $0230                 
C756  8D 40 02 STA $0240                 
C759  8D 50 02 STA $0250                 
C75C  8D 60 02 STA $0260                 
C75F  8D 70 02 STA $0270                 
C762  8D 80 02 STA $0280                 
C765  8D 90 02 STA $0290                 
C768  8D A0 02 STA $02A0                 
C76B  8D B0 02 STA $02B0                 
C76E  8D C0 02 STA $02C0                 
C771  8D D0 02 STA $02D0                 
C774  8D E0 02 STA $02E0                 
C777  8D F0 02 STA $02F0                 
C77A  8D 24 02 STA $0224                 
C77D  8D 34 02 STA $0234                 
C780  8D 44 02 STA $0244                 
C783  8D 54 02 STA $0254                 
C786  8D 64 02 STA $0264                 
C789  8D 74 02 STA $0274                 
C78C  8D 84 02 STA $0284                 
C78F  8D 94 02 STA $0294                 
C792  8D A4 02 STA $02A4                 
C795  8D B4 02 STA $02B4                 
C798  8D C4 02 STA $02C4                 
C79B  8D D4 02 STA $02D4                 
C79E  8D E4 02 STA $02E4                 
C7A1  8D F4 02 STA $02F4                 
C7A4  8D 28 02 STA $0228                 
C7A7  8D 38 02 STA $0238                 
C7AA  8D 48 02 STA $0248                 
C7AD  8D 58 02 STA $0258                 
C7B0  8D 68 02 STA $0268                 
C7B3  8D 78 02 STA $0278                 
C7B6  8D 88 02 STA $0288                 
C7B9  8D 98 02 STA $0298                 
C7BC  8D A8 02 STA $02A8                 
C7BF  8D B8 02 STA $02B8                 
C7C2  8D C8 02 STA $02C8                 
C7C5  8D D8 02 STA $02D8                 
C7C8  8D E8 02 STA $02E8                 
C7CB  8D F8 02 STA $02F8                 
C7CE  8D 2C 02 STA $022C                 
C7D1  8D 3C 02 STA $023C                 
C7D4  8D 4C 02 STA $024C                 
C7D7  8D 5C 02 STA $025C                 
C7DA  8D 6C 02 STA $026C                 
C7DD  8D 7C 02 STA $027C                 
C7E0  8D 8C 02 STA $028C                 
C7E3  8D 9C 02 STA $029C                 
C7E6  8D AC 02 STA $02AC                 
C7E9  8D BC 02 STA $02BC                 
C7EC  8D CC 02 STA $02CC                 
C7EF  8D DC 02 STA $02DC                 
C7F2  8D EC 02 STA $02EC                 
C7F5  8D FC 02 STA $02FC                 
C7F8  60       RTS                       

sub_C7F9:  ; xrefs(1): $C9BE
C7F9  84 2B    STY $2B                   
C7FB  86 2C    STX $2C                   
C7FD  0A       ASL A                     
C7FE  A8       TAY                       
C7FF  68       PLA                       
C800  85 29    STA $29                   
C802  68       PLA                       
C803  85 2A    STA $2A                   
C805  C8       INY                       
C806  90 02    BCC $C80A                 
C808  E6 2A    INC $2A                   

loc_C80A:  ; xrefs(1): $C806
C80A  B1 29    LDA ($29),Y               
C80C  AA       TAX                       
C80D  C8       INY                       
C80E  D0 02    BNE $C812                 
C810  E6 2A    INC $2A                   

loc_C812:  ; xrefs(1): $C80E
C812  B1 29    LDA ($29),Y               
C814  85 2A    STA $2A                   
C816  86 29    STX $29                   
C818  A4 2B    LDY $2B                   
C81A  A6 2C    LDX $2C                   
C81C  6C 29 00 JMP ($0029)               

sub_C81F:  ; xrefs(3): $DDCD $E119 $E214
C81F  84 2C    STY $2C                   
C821  0A       ASL A                     
C822  A8       TAY                       
C823  68       PLA                       
C824  85 29    STA $29                   
C826  68       PLA                       
C827  85 2A    STA $2A                   
C829  C8       INY                       
C82A  B1 29    LDA ($29),Y               
C82C  48       PHA                       
C82D  C8       INY                       
C82E  B1 29    LDA ($29),Y               
C830  A4 2C    LDY $2C                   
C832  85 2C    STA $2C                   
C834  68       PLA                       
C835  85 2B    STA $2B                   
C837  6C 2B 00 JMP ($002B)               

sub_C83A:  ; xrefs(1): $D859
C83A  A5 90    LDA $90                   
C83C  20 4D C8 JSR $C84D                 
C83F  86 9F    STX $9F                   
C841  85 9E    STA $9E                   
C843  A5 91    LDA $91                   
C845  20 4D C8 JSR $C84D                 
C848  86 9D    STX $9D                   
C84A  85 9C    STA $9C                   
C84C  60       RTS                       

sub_C84D:  ; xrefs(2): $C83C $C845
C84D  48       PHA                       
C84E  20 57 C8 JSR $C857                 
C851  AA       TAX                       
C852  68       PLA                       
C853  4A       LSR A                     
C854  4A       LSR A                     
C855  4A       LSR A                     
C856  4A       LSR A                     

sub_C857:  ; xrefs(1): $C84E
C857  29 0F    AND #$0F                  
C859  A8       TAY                       
C85A  B9 5E C8 LDA $C85E,Y               
C85D  60       RTS                       

; ---- data $C85E-$C881 (36 bytes) ----
C85E  30 31 32 33 34 35 36 37 38 39 41 42 43 44 45 46  |0123456789ABCDEF
C86E  48 A9 07 D0 03 48 A9 06 E6 47 8D 00 80 68 8D 01  |H....H...G...h..
C87E  80 C6 47 60                                      |..G`

sub_C882:  ; xrefs(11): $CD90 $D1E3 $D291 $D52E $D781 $D7C7 $D880 $D8E4 $DA55 $DBB1
C882  20 A2 C8 JSR $C8A2                 
C885  A5 92    LDA $92                   
C887  05 90    ORA $90                   
C889  85 92    STA $92                   
C88B  45 06    EOR $06                   
C88D  25 92    AND $92                   
C88F  85 04    STA $04                   
C891  A5 92    LDA $92                   
C893  85 06    STA $06                   
C895  A5 91    LDA $91                   
C897  45 07    EOR $07                   
C899  25 91    AND $91                   
C89B  85 05    STA $05                   
C89D  A5 91    LDA $91                   
C89F  85 07    STA $07                   
C8A1  60       RTS                       

sub_C8A2:  ; xrefs(1): $C882
C8A2  A9 01    LDA #$01                  
C8A4  8D 16 40 STA $4016                 
C8A7  A9 00    LDA #$00                  
C8A9  8D 16 40 STA $4016                 
C8AC  AD 16 40 LDA $4016                 
C8AF  4A       LSR A                     
C8B0  26 90    ROL $90                   
C8B2  4A       LSR A                     
C8B3  26 92    ROL $92                   
C8B5  AD 16 40 LDA $4016                 
C8B8  4A       LSR A                     
C8B9  26 90    ROL $90                   
C8BB  4A       LSR A                     
C8BC  26 92    ROL $92                   
C8BE  AD 16 40 LDA $4016                 
C8C1  4A       LSR A                     
C8C2  26 90    ROL $90                   
C8C4  4A       LSR A                     
C8C5  26 92    ROL $92                   
C8C7  AD 16 40 LDA $4016                 
C8CA  4A       LSR A                     
C8CB  26 90    ROL $90                   
C8CD  4A       LSR A                     
C8CE  26 92    ROL $92                   
C8D0  AD 16 40 LDA $4016                 
C8D3  4A       LSR A                     
C8D4  26 90    ROL $90                   
C8D6  4A       LSR A                     
C8D7  26 92    ROL $92                   
C8D9  AD 16 40 LDA $4016                 
C8DC  4A       LSR A                     
C8DD  26 90    ROL $90                   
C8DF  4A       LSR A                     
C8E0  26 92    ROL $92                   
C8E2  AD 16 40 LDA $4016                 
C8E5  4A       LSR A                     
C8E6  26 90    ROL $90                   
C8E8  4A       LSR A                     
C8E9  26 92    ROL $92                   
C8EB  AD 16 40 LDA $4016                 
C8EE  4A       LSR A                     
C8EF  26 90    ROL $90                   
C8F1  4A       LSR A                     
C8F2  26 92    ROL $92                   
C8F4  AD 17 40 LDA $4017                 
C8F7  4A       LSR A                     
C8F8  26 91    ROL $91                   
C8FA  AD 17 40 LDA $4017                 
C8FD  4A       LSR A                     
C8FE  26 91    ROL $91                   
C900  AD 17 40 LDA $4017                 
C903  4A       LSR A                     
C904  26 91    ROL $91                   
C906  AD 17 40 LDA $4017                 
C909  4A       LSR A                     
C90A  26 91    ROL $91                   
C90C  AD 17 40 LDA $4017                 
C90F  4A       LSR A                     
C910  26 91    ROL $91                   
C912  AD 17 40 LDA $4017                 
C915  4A       LSR A                     
C916  26 91    ROL $91                   
C918  AD 17 40 LDA $4017                 
C91B  4A       LSR A                     
C91C  26 91    ROL $91                   
C91E  AD 17 40 LDA $4017                 
C921  4A       LSR A                     
C922  26 91    ROL $91                   
C924  60       RTS                       

sub_C925:  ; xrefs(9): $D1C4 $D26E $D2CC $D346 $D396 $D3DE $DAE7 $E35A $E3EE
C925  85 40    STA $40                   
C927  84 41    STY $41                   
C929  60       RTS                       

sub_C92A:  ; xrefs(7): $C6E9 $CB40 $CC43 $CD3A $CF2E $F812 $F9F9
C92A  A9 0A    LDA #$0A                  

sub_C92C:  ; xrefs(15): $C0A0 $CAB7 $CC63 $CDB0 $CDB8 $CDD7 $CE3D $D299 $D960 $E426
C92C  A8       TAY                       
C92D  20 92 C9 JSR $C992                 
C930  E6 47    INC $47                   
C932  A9 06    LDA #$06                  
C934  8D 00 80 STA $8000                 
C937  8C 01 80 STY $8001                 
C93A  C8       INY                       
C93B  A9 07    LDA #$07                  
C93D  8D 00 80 STA $8000                 
C940  8C 01 80 STY $8001                 
C943  C6 47    DEC $47                   
C945  60       RTS                       

sub_C946:  ; xrefs(3): $CCB5 $CD99 $E9E3
C946  20 92 C9 JSR $C992                 
C949  E6 47    INC $47                   
C94B  A9 06    LDA #$06                  
C94D  8D 00 80 STA $8000                 
C950  A4 55    LDY $55                   
C952  B9 65 C9 LDA $C965,Y               
C955  8D 01 80 STA $8001                 
C958  AA       TAX                       
C959  A9 07    LDA #$07                  
C95B  8D 00 80 STA $8000                 
C95E  E8       INX                       
C95F  8E 01 80 STX $8001                 
C962  C6 47    DEC $47                   
C964  60       RTS                       

; ---- data $C965-$C978 (20 bytes) ----
C965  04 06 06 06 06 06 06 06 04 06 04 04 06 06 04 04  |................
C975  04 06 06 04                                      |....

sub_C979:  ; xrefs(1): $CDCF
C979  E6 47    INC $47                   
C97B  A9 06    LDA #$06                  
C97D  8D 00 80 STA $8000                 
C980  A9 0C    LDA #$0C                  
C982  8D 01 80 STA $8001                 
C985  A9 07    LDA #$07                  
C987  8D 00 80 STA $8000                 
C98A  A9 0D    LDA #$0D                  
C98C  8D 01 80 STA $8001                 
C98F  C6 47    DEC $47                   
C991  60       RTS                       

sub_C992:  ; xrefs(3): $C92D $C946 $F422
C992  AD 00 80 LDA $8000                 
C995  85 46    STA $46                   
C997  60       RTS                       

loc_C998:  ; xrefs(4): $C0A6 $F3EB $F403 $F818
C998  E6 47    INC $47                   
C99A  A9 06    LDA #$06                  
C99C  8D 00 80 STA $8000                 
C99F  A5 46    LDA $46                   
C9A1  8D 01 80 STA $8001                 
C9A4  A9 07    LDA #$07                  
C9A6  8D 00 80 STA $8000                 
C9A9  18       CLC                       
C9AA  A5 46    LDA $46                   
C9AC  69 01    ADC #$01                  
C9AE  8D 01 80 STA $8001                 
C9B1  C6 47    DEC $47                   
C9B3  60       RTS                       

sub_C9B4:  ; xrefs(1): $F9CC
C9B4  A9 00    LDA #$00                  
C9B6  8D 00 03 STA $0300                 
C9B9  8D 01 03 STA $0301                 
C9BC  A5 02    LDA $02                   
C9BE  20 F9 C7 JSR $C7F9                 

; ---- jump table $C9C1 (94 entries) ----
C9C1  .word $CD57   ; [00] 
C9C3  .word $D157   ; [01] 
C9C5  .word $D167   ; [02] 
C9C7  .word $D176   ; [03] 
C9C9  .word $D19D   ; [04] 
C9CB  .word $D1E3   ; [05] 
C9CD  .word $D2AC   ; [06] 
C9CF  .word $D2FB   ; [07] 
C9D1  .word $D481   ; [08] 
C9D3  .word $D4AD   ; [09] 
C9D5  .word $D4AD   ; [0A] 
C9D7  .word $D4AD   ; [0B] 
C9D9  .word $D4AD   ; [0C] 
C9DB  .word $D4AD   ; [0D] 
C9DD  .word $D6CA   ; [0E] 
C9DF  .word $D77E   ; [0F] 
C9E1  .word $D79F   ; [10] 
C9E3  .word $D79F   ; [11] 
C9E5  .word $D95A   ; [12] 
C9E7  .word $D95A   ; [13] 
C9E9  .word $D974   ; [14] 
C9EB  .word $DA52   ; [15] 
C9ED  .word $DAE3   ; [16] 
C9EF  .word $DAE3   ; [17] 
C9F1  .word $DAE3   ; [18] 
C9F3  .word $DAE3   ; [19] 
C9F5  .word $DBAE   ; [1A] 
C9F7  .word $E09C   ; [1B] 
C9F9  .word $E117   ; [1C] 
C9FB  .word $E520   ; [1D] 
C9FD  .word $E097   ; [1E] 
C9FF  .word $E097   ; [1F] 
CA01  .word $E33A   ; [20] 
CA03  .word $E4DD   ; [21] 
CA05  .word $E4E9   ; [22] 
CA07  .word $E515   ; [23] 
CA09  .word $D79F   ; [24] 
CA0B  .word $D7C2   ; [25] 
CA0D  .word $D842   ; [26] 
CA0F  .word $D847   ; [27] 
CA11  .word $D939   ; [28] 
CA13  .word $D93E   ; [29] 
CA15  .word $D863   ; [2A] 
CA17  .word $D880   ; [2B] 
CA19  .word $E9D2   ; [2C] 
CA1B  .word $E9E3   ; [2D] 
CA1D  .word $D92B   ; [2E] 
CA1F  .word $D92F   ; [2F] 
CA21  .word $D930   ; [30] 
CA23  .word $D939   ; [31] 
CA25  .word $DB4A   ; [32] 
CA27  .word $D8C7   ; [33] 
CA29  .word $D8E4   ; [34] 
CA2B  .word $CAA0   ; [35] 
CA2D  .word $E9D2   ; [36] 
CA2F  .word $CAC6   ; [37] 
CA31  .word $CB78   ; [38] 
CA33  .word $CB85   ; [39] 
CA35  .word $D358   ; [3A] 
CA37  .word $D3A9   ; [3B] 
CA39  .word $D3C1   ; [3C] 
CA3B  .word $D3F4   ; [3D] 
CA3D  .word $CB96   ; [3E] 
CA3F  .word $CC77   ; [3F] 
CA41  .word $CB8F   ; [40] 
CA43  .word $CA7D   ; [41] 
CA45  .word $CA81   ; [42] 
CA47  .word $D4AD   ; [43] 
CA49  .word $D6A5   ; [44] 
CA4B  .word $D525   ; [45] 
CA4D  .word $D648   ; [46] 
CA4F  .word $DA02   ; [47] 
CA51  .word $CA85   ; [48] 
CA53  .word $CA91   ; [49] 
CA55  .word $CA89   ; [4A] 
CA57  .word $CA8D   ; [4B] 
CA59  .word $E33A   ; [4C] 
CA5B  .word $E421   ; [4D] 
CA5D  .word $E3E7   ; [4E] 
CA5F  .word $E42F   ; [4F] 
CA61  .word $E456   ; [50] 
CA63  .word $E463   ; [51] 
CA65  .word $E474   ; [52] 
CA67  .word $E486   ; [53] 
CA69  .word $E494   ; [54] 
CA6B  .word $D4AD   ; [55] 
CA6D  .word $D6A5   ; [56] 
CA6F  .word $D525   ; [57] 
CA71  .word $D648   ; [58] 
CA73  .word $D631   ; [59] 
CA75  .word $D63B   ; [5A] 
CA77  .word $D45C   ; [5B] 
CA79  .word $D262   ; [5C] 
CA7B  .word $D291   ; [5D] 

sub_CA7D:  ; xrefs(1): $C9C1
CA7D  A9 0D    LDA #$0D                  
CA7F  D0 12    BNE $CA93                 

sub_CA81:  ; xrefs(1): $C9C1
CA81  A9 0E    LDA #$0E                  
CA83  D0 0E    BNE $CA93                 

sub_CA85:  ; xrefs(1): $C9C1
CA85  A9 08    LDA #$08                  
CA87  D0 0A    BNE $CA93                 

sub_CA89:  ; xrefs(1): $C9C1
CA89  A9 12    LDA #$12                  
CA8B  D0 06    BNE $CA93                 

sub_CA8D:  ; xrefs(1): $C9C1
CA8D  A9 11    LDA #$11                  
CA8F  D0 02    BNE $CA93                 

sub_CA91:  ; xrefs(1): $C9C1
CA91  A9 13    LDA #$13                  

loc_CA93:  ; xrefs(5): $CA7F $CA83 $CA87 $CA8B $CA8F
CA93  85 55    STA $55                   
CA95  A9 1D    LDA #$1D                  
CA97  85 02    STA $02                   
CA99  60       RTS                       

sub_CA9A:  ; xrefs(13): $CAA0 $CADF $CC77 $D294 $D2FB $D358 $D3A9 $D3C1 $D3F4 $D45C
CA9A  20 2D C7 JSR $C72D                 
CA9D  4C 06 F8 JMP $F806                 

sub_CAA0:  ; xrefs(1): $C9C1
CAA0  20 9A CA JSR $CA9A                 
CAA3  A5 26    LDA $26                   
CAA5  D0 1E    BNE $CAC5                 
CAA7  20 9B E6 JSR $E69B                 
CAAA  E6 02    INC $02                   
CAAC  A5 81    LDA $81                   
CAAE  8D 20 07 STA $0720                 
CAB1  29 F0    AND #$F0                  
CAB3  85 81    STA $81                   
CAB5  A9 0C    LDA #$0C                  
CAB7  20 2C C9 JSR $C92C                 
CABA  20 19 80 JSR $8019                 
CABD  A9 01    LDA #$01                  
CABF  8D 40 07 STA $0740                 
CAC2  8D 30 07 STA $0730                 

loc_CAC5:  ; xrefs(1): $CAA5
CAC5  60       RTS                       

sub_CAC6:  ; xrefs(1): $C9C1
CAC6  20 DF CA JSR $CADF                 
CAC9  20 E3 E9 JSR $E9E3                 
CACC  A5 02    LDA $02                   
CACE  D0 0E    BNE $CADE                 
CAD0  A9 05    LDA #$05                  
CAD2  A0 FF    LDY #$FF                  
CAD4  20 6D F8 JSR $F86D                 
CAD7  20 61 F8 JSR $F861                 
CADA  A9 38    LDA #$38                  
CADC  85 02    STA $02                   

loc_CADE:  ; xrefs(1): $CACE
CADE  60       RTS                       

sub_CADF:  ; xrefs(2): $CAC6 $CB78
CADF  20 9A CA JSR $CA9A                 
CAE2  AD C8 05 LDA $05C8                 
CAE5  F0 0C    BEQ $CAF3                 
CAE7  A5 0C    LDA $0C                   
CAE9  4A       LSR A                     
CAEA  29 03    AND #$03                  
CAEC  A8       TAY                       
CAED  B9 74 CB LDA $CB74,Y               
CAF0  8D 12 01 STA $0112                 

loc_CAF3:  ; xrefs(1): $CAE5
CAF3  A5 81    LDA $81                   
CAF5  CD 20 07 CMP $0720                 
CAF8  D0 0D    BNE $CB07                 
CAFA  AD C2 05 LDA $05C2                 
CAFD  F0 04    BEQ $CB03                 
CAFF  A9 DA    LDA #$DA                  
CB01  D0 3C    BNE $CB3F                 

loc_CB03:  ; xrefs(1): $CAFD
CB03  A9 64    LDA #$64                  
CB05  D0 38    BNE $CB3F                 

loc_CB07:  ; xrefs(1): $CAF8
CB07  18       CLC                       
CB08  A5 80    LDA $80                   
CB0A  69 18    ADC #$18                  
CB0C  85 80    STA $80                   
CB0E  90 02    BCC $CB12                 
CB10  E6 81    INC $81                   

loc_CB12:  ; xrefs(1): $CB0E
CB12  CE 40 07 DEC $0740                 
CB15  D0 18    BNE $CB2F                 
CB17  18       CLC                       
CB18  AD 30 07 LDA $0730                 
CB1B  69 01    ADC #$01                  
CB1D  29 07    AND #$07                  
CB1F  C9 06    CMP #$06                  
CB21  D0 02    BNE $CB25                 
CB23  A9 00    LDA #$00                  

loc_CB25:  ; xrefs(1): $CB21
CB25  8D 30 07 STA $0730                 
CB28  A8       TAY                       
CB29  B9 62 CB LDA $CB62,Y               
CB2C  8D 40 07 STA $0740                 

loc_CB2F:  ; xrefs(1): $CB15
CB2F  AC 30 07 LDY $0730                 
CB32  AD C2 05 LDA $05C2                 
CB35  F0 05    BEQ $CB3C                 
CB37  B9 6E CB LDA $CB6E,Y               
CB3A  D0 03    BNE $CB3F                 

loc_CB3C:  ; xrefs(1): $CB35
CB3C  B9 68 CB LDA $CB68,Y               

loc_CB3F:  ; xrefs(3): $CB01 $CB05 $CB3A
CB3F  48       PHA                       
CB40  20 2A C9 JSR $C92A                 
CB43  A9 00    LDA #$00                  
CB45  85 9E    STA $9E                   
CB47  A5 80    LDA $80                   
CB49  85 90    STA $90                   
CB4B  A5 81    LDA $81                   
CB4D  29 0F    AND #$0F                  
CB4F  85 91    STA $91                   
CB51  A5 82    LDA $82                   
CB53  85 92    STA $92                   
CB55  A5 83    LDA $83                   
CB57  29 0F    AND #$0F                  
CB59  85 93    STA $93                   
CB5B  68       PLA                       
CB5C  A0 00    LDY #$00                  
CB5E  20 3F F4 JSR $F43F                 
CB61  60       RTS                       

; ---- data $CB62-$CB77 (22 bytes) ----
CB62  06 05 08 06 05 08 A0 A2 A4 A8 AA A6 DE E0 E2 E6  |................
CB72  E8 E4 15 24 05 24                                |...$.$

sub_CB78:  ; xrefs(1): $C9C1
CB78  20 DF CA JSR $CADF                 
CB7B  A5 26    LDA $26                   
CB7D  D0 05    BNE $CB84                 
CB7F  20 65 F8 JSR $F865                 
CB82  E6 02    INC $02                   

loc_CB84:  ; xrefs(1): $CB7D
CB84  60       RTS                       

sub_CB85:  ; xrefs(1): $C9C1
CB85  20 06 F8 JSR $F806                 
CB88  A5 26    LDA $26                   
CB8A  D0 02    BNE $CB8E                 
CB8C  85 02    STA $02                   

loc_CB8E:  ; xrefs(1): $CB8A
CB8E  60       RTS                       

sub_CB8F:  ; xrefs(1): $C9C1
CB8F  A9 3E    LDA #$3E                  
CB91  85 02    STA $02                   
CB93  4C 9B E6 JMP $E69B                 

sub_CB96:  ; xrefs(1): $C9C1
CB96  AD C2 05 LDA $05C2                 
CB99  F0 05    BEQ $CBA0                 
CB9B  09 07    ORA #$07                  
CB9D  8D C2 05 STA $05C2                 

loc_CBA0:  ; xrefs(1): $CB99
CBA0  A5 44    LDA $44                   
CBA2  8D F0 07 STA $07F0                 
CBA5  A5 45    LDA $45                   
CBA7  8D E0 07 STA $07E0                 
CBAA  A9 0E    LDA #$0E                  
CBAC  85 45    STA $45                   
CBAE  20 61 CC JSR $CC61                 
CBB1  A0 B4    LDY #$B4                  
CBB3  20 0D 80 JSR $800D                 
CBB6  A9 12    LDA #$12                  
CBB8  8D A2 05 STA $05A2                 
CBBB  8D AF 05 STA $05AF                 
CBBE  20 43 CC JSR $CC43                 
CBC1  A0 0F    LDY #$0F                  

loc_CBC3:  ; xrefs(1): $CBD2
CBC3  A9 0F    LDA #$0F                  
CBC5  99 00 01 STA $0100,Y               
CBC8  B9 33 CC LDA $CC33,Y               
CBCB  99 10 01 STA $0110,Y               
CBCE  99 A0 07 STA $07A0,Y               
CBD1  88       DEY                       
CBD2  10 EF    BPL $CBC3                 
CBD4  A2 03    LDX #$03                  

loc_CBD6:  ; xrefs(1): $CBE1
CBD6  A9 F8    LDA #$F8                  
CBD8  9D BA 05 STA $05BA,X               
CBDB  A9 00    LDA #$00                  
CBDD  9D BE 05 STA $05BE,X               
CBE0  CA       DEX                       
CBE1  10 F3    BPL $CBD6                 
CBE3  E8       INX                       
CBE4  86 57    STX $57                   
CBE6  20 0D CC JSR $CC0D                 
CBE9  20 0D CC JSR $CC0D                 
CBEC  20 0D CC JSR $CC0D                 
CBEF  20 0D CC JSR $CC0D                 
CBF2  A9 06    LDA #$06                  
CBF4  85 F1    STA $F1                   
CBF6  A5 30    LDA $30                   
CBF8  8D 17 07 STA $0717                 
CBFB  A5 31    LDA $31                   
CBFD  8D 27 07 STA $0727                 
CC00  A5 32    LDA $32                   
CC02  8D 37 07 STA $0737                 
CC05  A5 33    LDA $33                   
CC07  8D 47 07 STA $0747                 
CC0A  4C D2 E9 JMP $E9D2                 

sub_CC0D:  ; xrefs(4): $CBE6 $CBE9 $CBEC $CBEF
CC0D  A5 80    LDA $80                   
CC0F  9D 20 07 STA $0720,X               
CC12  18       CLC                       
CC13  A5 81    LDA $81                   
CC15  7D 2B CC ADC $CC2B,X               
CC18  9D 30 07 STA $0730,X               
CC1B  A5 82    LDA $82                   
CC1D  9D 40 07 STA $0740,X               
CC20  18       CLC                       
CC21  A5 83    LDA $83                   
CC23  7D 2F CC ADC $CC2F,X               
CC26  9D 50 07 STA $0750,X               
CC29  E8       INX                       
CC2A  60       RTS                       

; ---- data $CC2B-$CC42 (24 bytes) ----
CC2B  EE 12 EE 12 EE EE 12 12 0F 01 28 30 0F 0F 21 30  |..........(0..!0
CC3B  0F 06 27 38 0F 06 27 29                          |..'8..')

sub_CC43:  ; xrefs(2): $CBBE $E40F
CC43  20 2A C9 JSR $C92A                 
CC46  A5 20    LDA $20                   
CC48  8D 57 07 STA $0757                 
CC4B  A5 21    LDA $21                   
CC4D  8D 67 07 STA $0767                 
CC50  A0 1F    LDY #$1F                  

loc_CC52:  ; xrefs(1): $CC58
CC52  B1 20    LDA ($20),Y               
CC54  99 90 07 STA $0790,Y               
CC57  88       DEY                       
CC58  10 F8    BPL $CC52                 
CC5A  A9 90    LDA #$90                  
CC5C  A0 07    LDY #$07                  
CC5E  4C B1 E9 JMP $E9B1                 

sub_CC61:  ; xrefs(2): $CBAE $CC91
CC61  A9 02    LDA #$02                  
CC63  20 2C C9 JSR $C92C                 
CC66  A5 80    LDA $80                   
CC68  85 90    STA $90                   
CC6A  A5 81    LDA $81                   
CC6C  85 91    STA $91                   
CC6E  A5 82    LDA $82                   
CC70  85 92    STA $92                   
CC72  A5 83    LDA $83                   
CC74  85 93    STA $93                   
CC76  60       RTS                       

sub_CC77:  ; xrefs(1): $C9C1
CC77  20 9A CA JSR $CA9A                 
CC7A  38       SEC                       
CC7B  AD 20 07 LDA $0720                 
CC7E  E5 80    SBC $80                   
CC80  85 90    STA $90                   
CC82  AD 30 07 LDA $0730                 
CC85  E5 81    SBC $81                   
CC87  05 90    ORA $90                   
CC89  D0 23    BNE $CCAE                 
CC8B  A5 2E    LDA $2E                   
CC8D  F0 02    BEQ $CC91                 
CC8F  85 F0    STA $F0                   

loc_CC91:  ; xrefs(1): $CC8D
CC91  20 61 CC JSR $CC61                 
CC94  A0 3F    LDY #$3F                  
CC96  20 0D 80 JSR $800D                 
CC99  A9 00    LDA #$00                  
CC9B  85 04    STA $04                   
CC9D  85 05    STA $05                   
CC9F  85 02    STA $02                   
CCA1  A2 03    LDX #$03                  

loc_CCA3:  ; xrefs(1): $CCAB
CCA3  8A       TXA                       
CCA4  48       PHA                       
CCA5  20 10 CD JSR $CD10                 
CCA8  68       PLA                       
CCA9  AA       TAX                       
CCAA  CA       DEX                       
CCAB  10 F6    BPL $CCA3                 
CCAD  60       RTS                       

loc_CCAE:  ; xrefs(1): $CC89
CCAE  20 DD CC JSR $CCDD                 
CCB1  A5 57    LDA $57                   
CCB3  D0 27    BNE $CCDC                 
CCB5  20 46 C9 JSR $C946                 
CCB8  20 9C EA JSR $EA9C                 
CCBB  20 44 EC JSR $EC44                 
CCBE  20 2B EC JSR $EC2B                 
CCC1  C6 03    DEC $03                   
CCC3  D0 0A    BNE $CCCF                 
CCC5  A9 06    LDA #$06                  
CCC7  A0 0F    LDY #$0F                  
CCC9  20 6D F8 JSR $F86D                 
CCCC  C6 57    DEC $57                   
CCCE  60       RTS                       

loc_CCCF:  ; xrefs(1): $CCC3
CCCF  38       SEC                       
CCD0  A5 30    LDA $30                   
CCD2  E9 80    SBC #$80                  
CCD4  85 30    STA $30                   
CCD6  A5 31    LDA $31                   
CCD8  E9 00    SBC #$00                  
CCDA  85 31    STA $31                   

loc_CCDC:  ; xrefs(1): $CCB3
CCDC  60       RTS                       

sub_CCDD:  ; xrefs(1): $CCAE
CCDD  A2 03    LDX #$03                  

loc_CCDF:  ; xrefs(1): $CCE7
CCDF  8A       TXA                       
CCE0  48       PHA                       
CCE1  20 EA CC JSR $CCEA                 
CCE4  68       PLA                       
CCE5  AA       TAX                       
CCE6  CA       DEX                       
CCE7  10 F6    BPL $CCDF                 
CCE9  60       RTS                       

sub_CCEA:  ; xrefs(1): $CCE1
CCEA  18       CLC                       
CCEB  BD 20 07 LDA $0720,X               
CCEE  7D 43 CD ADC $CD43,X               
CCF1  9D 20 07 STA $0720,X               
CCF4  BD 30 07 LDA $0730,X               
CCF7  7D 47 CD ADC $CD47,X               
CCFA  9D 30 07 STA $0730,X               
CCFD  18       CLC                       
CCFE  BD 40 07 LDA $0740,X               
CD01  7D 4B CD ADC $CD4B,X               
CD04  9D 40 07 STA $0740,X               
CD07  BD 50 07 LDA $0750,X               
CD0A  7D 4F CD ADC $CD4F,X               
CD0D  9D 50 07 STA $0750,X               

sub_CD10:  ; xrefs(1): $CCA5
CD10  BD 53 CD LDA $CD53,X               
CD13  48       PHA                       
CD14  A9 00    LDA #$00                  
CD16  85 9E    STA $9E                   
CD18  38       SEC                       
CD19  BD 20 07 LDA $0720,X               
CD1C  ED 17 07 SBC $0717                 
CD1F  85 90    STA $90                   
CD21  BD 30 07 LDA $0730,X               
CD24  ED 27 07 SBC $0727                 
CD27  85 91    STA $91                   
CD29  38       SEC                       
CD2A  BD 40 07 LDA $0740,X               
CD2D  ED 37 07 SBC $0737                 
CD30  85 92    STA $92                   
CD32  BD 50 07 LDA $0750,X               
CD35  ED 47 07 SBC $0747                 
CD38  85 93    STA $93                   
CD3A  20 2A C9 JSR $C92A                 
CD3D  68       PLA                       
CD3E  A0 02    LDY #$02                  
CD40  4C 3F F4 JMP $F43F                 

; ---- data $CD43-$CD56 (20 bytes) ----
CD43  40 C0 40 C0 00 FF 00 FF 40 40 C0 C0 00 00 FF FF  |@.@.....@@......
CD53  2E 2F 30 31                                      |./01

sub_CD57:  ; xrefs(1): $C9C1
CD57  A5 0E    LDA $0E                   
CD59  AA       TAX                       
CD5A  6A       ROR A                     
CD5B  6A       ROR A                     
CD5C  6A       ROR A                     
CD5D  6A       ROR A                     
CD5E  4D D5 03 EOR $03D5                 
CD61  45 80    EOR $80                   
CD63  6A       ROR A                     
CD64  45 6C    EOR $6C                   
CD66  45 00    EOR $00                   
CD68  5D 00 07 EOR $0700,X               
CD6B  AA       TAX                       
CD6C  5D 00 06 EOR $0600,X               
CD6F  4D DA 03 EOR $03DA                 
CD72  85 0E    STA $0E                   
CD74  A9 00    LDA #$00                  
CD76  8D F0 05 STA $05F0                 
CD79  AD CB 05 LDA $05CB                 
CD7C  29 80    AND #$80                  
CD7E  8D CB 05 STA $05CB                 
CD81  AD F7 05 LDA $05F7                 
CD84  F0 07    BEQ $CD8D                 
CD86  A8       TAY                       
CD87  B9 15 CE LDA $CE15,Y               
CD8A  CE F7 05 DEC $05F7                 

loc_CD8D:  ; xrefs(1): $CD84
CD8D  8D F8 05 STA $05F8                 
CD90  20 82 C8 JSR $C882                 
CD93  20 2D C7 JSR $C72D                 
CD96  EE F9 05 INC $05F9                 
CD99  20 46 C9 JSR $C946                 
CD9C  20 EA F1 JSR $F1EA                 
CD9F  20 4B F2 JSR $F24B                 
CDA2  20 44 EC JSR $EC44                 
CDA5  20 2B EC JSR $EC2B                 
CDA8  CE F9 05 DEC $05F9                 
CDAB  20 9C EA JSR $EA9C                 
CDAE  A9 08    LDA #$08                  
CDB0  20 2C C9 JSR $C92C                 
CDB3  20 16 80 JSR $8016                 
CDB6  A9 08    LDA #$08                  
CDB8  20 2C C9 JSR $C92C                 
CDBB  20 19 80 JSR $8019                 
CDBE  20 10 80 JSR $8010                 
CDC1  A5 54    LDA $54                   
CDC3  F0 0A    BEQ $CDCF                 
CDC5  AD A3 05 LDA $05A3                 
CDC8  C9 70    CMP #$70                  
CDCA  90 03    BCC $CDCF                 
CDCC  20 1F 80 JSR $801F                 

loc_CDCF:  ; xrefs(2): $CDC3 $CDCA
CDCF  20 79 C9 JSR $C979                 
CDD2  20 07 80 JSR $8007                 
CDD5  A9 02    LDA #$02                  
CDD7  20 2C C9 JSR $C92C                 
CDDA  20 0A 80 JSR $800A                 
CDDD  20 1D CE JSR $CE1D                 
CDE0  20 06 F8 JSR $F806                 
CDE3  A5 56    LDA $56                   
CDE5  F0 10    BEQ $CDF7                 
CDE7  C6 56    DEC $56                   
CDE9  38       SEC                       
CDEA  AD C6 05 LDA $05C6                 
CDED  E9 01    SBC #$01                  
CDEF  8D C6 05 STA $05C6                 
CDF2  B0 03    BCS $CDF7                 
CDF4  CE C7 05 DEC $05C7                 

loc_CDF7:  ; xrefs(2): $CDE5 $CDF2
CDF7  AD C5 05 LDA $05C5                 
CDFA  D0 18    BNE $CE14                 
CDFC  AD A3 05 LDA $05A3                 
CDFF  C9 40    CMP #$40                  
CE01  B0 11    BCS $CE14                 
CE03  A5 0F    LDA $0F                   
CE05  C9 80    CMP #$80                  
CE07  F0 0B    BEQ $CE14                 
CE09  A5 00    LDA $00                   
CE0B  85 90    STA $90                   

loc_CE0D:  ; xrefs(1): $CE12
CE0D  A5 90    LDA $90                   
CE0F  45 00    EOR $00                   
CE11  6A       ROR A                     
CE12  90 F9    BCC $CE0D                 

loc_CE14:  ; xrefs(3): $CDFA $CE01 $CE07
CE14  60       RTS                       

; ---- data $CE15-$CE1C (8 bytes) ----
CE15  00 00 FF FE FD FC FB FA                          |........

sub_CE1D:  ; xrefs(1): $CDDD
CE1D  A2 0B    LDX #$0B                  

loc_CE1F:  ; xrefs(1): $CE23
CE1F  20 26 CE JSR $CE26                 
CE22  CA       DEX                       
CE23  10 FA    BPL $CE1F                 
CE25  60       RTS                       

sub_CE26:  ; xrefs(1): $CE1F
CE26  BD 00 06 LDA $0600,X               
CE29  F0 18    BEQ $CE43                 
CE2B  20 44 CE JSR $CE44                 
CE2E  30 13    BMI $CE43                 
CE30  FE E0 06 INC $06E0,X               
CE33  D0 03    BNE $CE38                 
CE35  DE E0 06 DEC $06E0,X               

loc_CE38:  ; xrefs(1): $CE33
CE38  20 26 CF JSR $CF26                 
CE3B  A9 02    LDA #$02                  
CE3D  20 2C C9 JSR $C92C                 
CE40  4C 04 80 JMP $8004                 

loc_CE43:  ; xrefs(2): $CE29 $CE2E
CE43  60       RTS                       

sub_CE44:  ; xrefs(1): $CE2B
CE44  BD 00 06 LDA $0600,X               
CE47  29 40    AND #$40                  
CE49  F0 29    BEQ $CE74                 
CE4B  A5 30    LDA $30                   
CE4D  29 F0    AND #$F0                  
CE4F  85 90    STA $90                   
CE51  38       SEC                       
CE52  B5 A0    LDA $A0,X                 
CE54  E5 90    SBC $90                   
CE56  85 5C    STA $5C                   
CE58  B5 B0    LDA $B0,X                 
CE5A  E5 31    SBC $31                   
CE5C  85 5D    STA $5D                   
CE5E  A5 32    LDA $32                   
CE60  29 F0    AND #$F0                  
CE62  85 90    STA $90                   
CE64  38       SEC                       
CE65  B5 C0    LDA $C0,X                 
CE67  E5 90    SBC $90                   
CE69  85 5E    STA $5E                   
CE6B  B5 D0    LDA $D0,X                 
CE6D  E5 33    SBC $33                   
CE6F  85 5F    STA $5F                   
CE71  A9 00    LDA #$00                  
CE73  60       RTS                       

loc_CE74:  ; xrefs(1): $CE49
CE74  A5 30    LDA $30                   
CE76  29 F0    AND #$F0                  
CE78  85 90    STA $90                   
CE7A  38       SEC                       
CE7B  B5 A0    LDA $A0,X                 
CE7D  E5 90    SBC $90                   
CE7F  85 5C    STA $5C                   
CE81  B5 B0    LDA $B0,X                 
CE83  E5 31    SBC $31                   
CE85  85 5D    STA $5D                   
CE87  18       CLC                       
CE88  69 10    ADC #$10                  
CE8A  C9 30    CMP #$30                  
CE8C  B0 37    BCS $CEC5                 
CE8E  4A       LSR A                     
CE8F  4A       LSR A                     
CE90  A8       TAY                       
CE91  A5 32    LDA $32                   
CE93  29 F0    AND #$F0                  
CE95  85 90    STA $90                   
CE97  38       SEC                       
CE98  B5 C0    LDA $C0,X                 
CE9A  E5 90    SBC $90                   
CE9C  85 5E    STA $5E                   
CE9E  B5 D0    LDA $D0,X                 
CEA0  E5 33    SBC $33                   
CEA2  85 5F    STA $5F                   
CEA4  18       CLC                       
CEA5  69 10    ADC #$10                  
CEA7  C9 30    CMP #$30                  
CEA9  B0 1A    BCS $CEC5                 
CEAB  29 FC    AND #$FC                  
CEAD  85 94    STA $94                   
CEAF  0A       ASL A                     
CEB0  65 94    ADC $94                   
CEB2  85 94    STA $94                   
CEB4  98       TYA                       
CEB5  65 94    ADC $94                   
CEB7  C9 24    CMP #$24                  
CEB9  90 0A    BCC $CEC5                 
CEBB  C9 6C    CMP #$6C                  
CEBD  B0 06    BCS $CEC5                 
CEBF  A8       TAY                       
CEC0  B9 BA CE LDA $CEBA,Y               
CEC3  10 15    BPL $CEDA                 

loc_CEC5:  ; xrefs(4): $CE8C $CEA9 $CEB9 $CEBD
CEC5  BD 00 06 LDA $0600,X               
CEC8  29 3F    AND #$3F                  
CECA  A8       TAY                       
CECB  B9 60 05 LDA $0560,Y               
CECE  29 7F    AND #$7F                  
CED0  99 60 05 STA $0560,Y               
CED3  A9 00    LDA #$00                  
CED5  9D 00 06 STA $0600,X               
CED8  A9 FF    LDA #$FF                  

loc_CEDA:  ; xrefs(1): $CEC3
CEDA  60       RTS                       

; ---- data $CEDB-$CF25 (75 bytes) ----
CEDB  A9 00 60 FF FE FE 01 03 03 03 03 02 FE FE FF FF  |..`.............
CEEB  FE FE 01 00 00 00 00 02 FE FE FF FF FE FE 01 00  |................
CEFB  7F 7F 00 02 FE FE FF FF FE FE 01 00 7F 7F 00 02  |................
CF0B  FE FE FF FF FE FE 01 00 00 00 00 02 FE FE FF FF  |................
CF1B  FE FE 01 04 04 04 04 02 FE FE FF                 |...........

sub_CF26:  ; xrefs(1): $CE38
CF26  BD 60 06 LDA $0660,X               
CF29  1D 70 06 ORA $0670,X               
CF2C  F0 4A    BEQ $CF78                 
CF2E  20 2A C9 JSR $C92A                 
CF31  A9 00    LDA #$00                  
CF33  85 9E    STA $9E                   
CF35  BD E0 06 LDA $06E0,X               
CF38  C9 10    CMP #$10                  
CF3A  F0 3C    BEQ $CF78                 
CF3C  BD 50 06 LDA $0650,X               
CF3F  30 11    BMI $CF52                 
CF41  B0 0F    BCS $CF52                 
CF43  A5 9E    LDA $9E                   
CF45  29 FC    AND #$FC                  
CF47  85 9E    STA $9E                   
CF49  BD E0 06 LDA $06E0,X               
CF4C  29 03    AND #$03                  
CF4E  05 9E    ORA $9E                   
CF50  85 9E    STA $9E                   

loc_CF52:  ; xrefs(2): $CF3F $CF41
CF52  8A       TXA                       
CF53  48       PHA                       
CF54  A5 5C    LDA $5C                   
CF56  85 90    STA $90                   
CF58  A5 5D    LDA $5D                   
CF5A  85 91    STA $91                   
CF5C  A5 5E    LDA $5E                   
CF5E  85 92    STA $92                   
CF60  A5 5F    LDA $5F                   
CF62  85 93    STA $93                   
CF64  BD 80 06 LDA $0680,X               
CF67  0A       ASL A                     
CF68  BD 60 06 LDA $0660,X               
CF6B  69 00    ADC #$00                  
CF6D  BC 70 06 LDY $0670,X               
CF70  90 01    BCC $CF73                 
CF72  C8       INY                       

loc_CF73:  ; xrefs(1): $CF70
CF73  20 3F F4 JSR $F43F                 
CF76  68       PLA                       
CF77  AA       TAX                       

loc_CF78:  ; xrefs(2): $CF2C $CF3A
CF78  60       RTS                       

; ---- data $CF79-$D13D (453 bytes) ----
CF79  8A 48 A5 5D 85 91 A5 5F 85 93 A5 5C 85 90 A5 5E  |.H.]..._...\...^
CF89  85 92 BD 10 06 A0 00 20 3F F4 68 AA 60 A9 08 20  |....... ?.h.`.. 
CF99  2C C9 BD 80 06 0A BD 60 06 69 00 BC 70 06 90 01  |,......`.i..p...
CFA9  C8 20 07 80 F0 05 20 0A 80 A9 FF 48 20 98 C9 68  |. .... ....H ..h
CFB9  60 A9 08 20 2C C9 A5 60 F0 2B A5 54 F0 19 30 0F  |`.. ,..`.+.T..0.
CFC9  BD 50 06 A8 B9 F1 CF F0 06 8A 45 0C 6A B0 08 AD  |.P........E.j...
CFD9  C5 05 F0 03 20 13 80 A5 60 30 07 29 3F F0 03 20  |.... ...`0.)?.. 
CFE9  04 80 20 0D 80 4C 98 C9 00 00 00 01 01 01 01 01  |.. ..L..........
CFF9  01 01 01 01 01 01 00 01 01 00 01 00 A9 08 20 2C  |.............. ,
D009  C9 20 22 80 4C 98 C9 A5 70 C9 3C F0 1B A5 90 6D  |. ".L...p.<....m
D019  B6 05 85 90 85 9D A5 91 6D B7 05 85 91 20 46 C9  |........m.... F.
D029  20 9C D0 48 20 98 C9 68 60 20 46 C9 A5 70 C9 3C  | ..H ..h` F..p.<
D039  D0 54 A5 75 85 9E A9 00 06 9E 2A 06 9E 2A 06 9E  |.T.u......*..*..
D049  2A 06 9E 2A 48 A5 9E 65 32 85 9E 68 65 33 85 9F  |*..*H..e2..he3..
D059  A5 92 C5 9E A5 93 E5 9F 90 2C D0 2A A5 92 E5 9E  |.........,.*....
D069  85 9D 38 AD B8 05 E5 9D 8D B8 05 B0 03 CE B9 05  |..8.............
D079  18 AD B8 05 65 72 8D B8 05 90 03 EE B9 05 A9 00  |....er..........
D089  85 9D A9 80 D0 07 A5 92 85 9D 20 9C D0 48 20 98  |.......... ..H .
D099  C9 68 60 A5 91 4A 4A 4A 4A 85 9F 18 A5 93 29 F0  |.h`..JJJJ.....).
D0A9  65 9F A8 B1 1E 85 95 A9 00 85 96 46 95 6A 46 95  |e..........F.jF.
D0B9  6A 65 14 85 94 A5 95 65 15 85 95 A5 91 6A 29 07  |je.....e.....j).
D0C9  85 9E A5 93 29 0E 0A 0A 65 9E A8 B1 94 A4 13 0A  |....)...e.......
D0D9  90 02 C8 C8 0A 90 02 C8 18 65 12 85 97 90 01 C8  |.........e......
D0E9  84 98 A0 00 A5 93 6A 90 01 C8 A5 91 6A 90 02 C8  |......j.....j...
D0F9  C8 B1 97 A8 84 2A B1 16 0A 0A 0A 85 29 90 11 98  |.....*......)...
D109  20 24 D1 F0 11 A4 2A B1 18 A8 B1 16 0A 0A 0A 60  | $....*........`
D119  98 20 24 D1 F0 04 A4 2A A5 29 60 48 4A 4A 4A AA  |. $....*.)`HJJJ.
D129  BD 40 05 AA 68 29 07 A8 8A 39 36 D1 60 80 40 20  |.@..h)...96.`.@ 
D139  10 08 04 02 01                                   |.....

sub_D13E:  ; xrefs(1): $F995
D13E  A9 11    LDA #$11                  
D140  8D 01 01 STA $0101                 
D143  A9 21    LDA #$21                  
D145  8D 02 01 STA $0102                 
D148  A9 31    LDA #$31                  
D14A  8D 03 01 STA $0103                 
D14D  A9 04    LDA #$04                  
D14F  85 40    STA $40                   
D151  A9 01    LDA #$01                  
D153  85 02    STA $02                   
D155  D0 0B    BNE $D162                 

sub_D157:  ; xrefs(1): $C9C1
D157  4C 6E D1 JMP $D16E                 

; ---- data $D15A-$D161 (8 bytes) ----
D15A  20 BD D1 20 35 C5 E6 02                          | .. 5...

loc_D162:  ; xrefs(1): $D155
D162  A9 00    LDA #$00                  
D164  85 4C    STA $4C                   
D166  60       RTS                       

sub_D167:  ; xrefs(1): $C9C1
D167  E6 4C    INC $4C                   
D169  D0 0A    BNE $D175                 
D16B  EE A0 05 INC $05A0                 

loc_D16E:  ; xrefs(1): $D157
D16E  20 05 E1 JSR $E105                 
D171  A9 03    LDA #$03                  
D173  85 02    STA $02                   

loc_D175:  ; xrefs(1): $D169
D175  60       RTS                       

sub_D176:  ; xrefs(1): $C9C1
D176  AD A0 05 LDA $05A0                 
D179  29 03    AND #$03                  
D17B  C9 01    CMP #$01                  
D17D  D0 04    BNE $D183                 
D17F  A9 0E    LDA #$0E                  
D181  D0 17    BNE $D19A                 

loc_D183:  ; xrefs(1): $D17D
D183  C9 03    CMP #$03                  
D185  D0 11    BNE $D198                 
D187  AD A0 05 LDA $05A0                 
D18A  4A       LSR A                     
D18B  4A       LSR A                     
D18C  29 03    AND #$03                  
D18E  AA       TAX                       
D18F  BD 94 D1 LDA $D194,X               
D192  D0 06    BNE $D19A                 
D194  0E 0E 0E ASL $0E0E                 
D197  0E A9 04 ASL $04A9                 

loc_D19A:  ; xrefs(2): $D181 $D192
D19A  85 02    STA $02                   
D19C  60       RTS                       

sub_D19D:  ; xrefs(1): $C9C1
D19D  20 BD D1 JSR $D1BD                 
D1A0  A9 3B    LDA #$3B                  
D1A2  20 8C EF JSR $EF8C                 
D1A5  E6 02    INC $02                   
D1A7  20 D8 DA JSR $DAD8                 
D1AA  85 58    STA $58                   
D1AC  85 59    STA $59                   
D1AE  85 0D    STA $0D                   
D1B0  85 2D    STA $2D                   
D1B2  85 55    STA $55                   
D1B4  8D 0C 06 STA $060C                 
D1B7  20 B9 F8 JSR $F8B9                 
D1BA  4C 35 C5 JMP $C535                 

sub_D1BD:  ; xrefs(1): $D19D
D1BD  20 C9 C5 JSR $C5C9                 
D1C0  A9 04    LDA #$04                  
D1C2  A0 06    LDY #$06                  
D1C4  20 25 C9 JSR $C925                 
D1C7  A9 0A    LDA #$0A                  
D1C9  20 8C EF JSR $EF8C                 
D1CC  A2 13    LDX #$13                  
D1CE  20 E9 C6 JSR $C6E9                 
D1D1  99 D4 A9 STA $A9D4,Y               
D1D4  8A       TXA                       
D1D5  85 7D    STA $7D                   
D1D7  A9 97    LDA #$97                  
D1D9  85 75    STA $75                   
D1DB  60       RTS                       

; ---- data $D1DC-$D1E2 (7 bytes) ----
D1DC  A5 08 09 01 85 08 60                             |......`

sub_D1E3:  ; xrefs(1): $C9C1
D1E3  20 82 C8 JSR $C882                 
D1E6  20 26 D2 JSR $D226                 
D1E9  A5 0C    LDA $0C                   
D1EB  29 03    AND #$03                  
D1ED  D0 02    BNE $D1F1                 
D1EF  C6 4C    DEC $4C                   

loc_D1F1:  ; xrefs(1): $D1ED
D1F1  A5 04    LDA $04                   
D1F3  29 10    AND #$10                  
D1F5  D0 1F    BNE $D216                 
D1F7  A5 06    LDA $06                   
D1F9  F0 04    BEQ $D1FF                 
D1FB  A9 00    LDA #$00                  
D1FD  85 4D    STA $4D                   

loc_D1FF:  ; xrefs(1): $D1F9
D1FF  A5 0C    LDA $0C                   
D201  29 03    AND #$03                  
D203  D0 20    BNE $D225                 
D205  C6 4D    DEC $4D                   
D207  D0 1C    BNE $D225                 
D209  EE A0 05 INC $05A0                 
D20C  20 05 E1 JSR $E105                 
D20F  20 57 C3 JSR $C357                 
D212  A9 03    LDA #$03                  
D214  D0 0D    BNE $D223                 

loc_D216:  ; xrefs(1): $D1F5
D216  A9 80    LDA #$80                  
D218  85 4C    STA $4C                   
D21A  A9 03    LDA #$03                  
D21C  85 F1    STA $F1                   
D21E  A9 12    LDA #$12                  
D220  8D A0 05 STA $05A0                 

loc_D223:  ; xrefs(1): $D214
D223  85 02    STA $02                   

loc_D225:  ; xrefs(2): $D203 $D207
D225  60       RTS                       

sub_D226:  ; xrefs(1): $D1E6
D226  A5 04    LDA $04                   
D228  F0 27    BEQ $D251                 
D22A  A5 06    LDA $06                   
D22C  F0 23    BEQ $D251                 
D22E  A6 58    LDX $58                   
D230  BD 52 D2 LDA $D252,X               
D233  C5 06    CMP $06                   
D235  D0 16    BNE $D24D                 
D237  E6 58    INC $58                   
D239  A5 58    LDA $58                   
D23B  C9 10    CMP #$10                  
D23D  D0 12    BNE $D251                 
D23F  A9 11    LDA #$11                  
D241  85 F1    STA $F1                   
D243  A9 24    LDA #$24                  
D245  85 02    STA $02                   
D247  8D A0 05 STA $05A0                 
D24A  20 05 E1 JSR $E105                 

loc_D24D:  ; xrefs(1): $D235
D24D  A9 00    LDA #$00                  
D24F  85 58    STA $58                   

loc_D251:  ; xrefs(3): $D228 $D22C $D23D
D251  60       RTS                       

; ---- data $D252-$D261 (16 bytes) ----
D252  80 80 80 80 40 40 40 40 80 40 80 40 80 40 80 40  |....@@@@.@.@.@.@

sub_D262:  ; xrefs(1): $C9C1
D262  20 C9 C5 JSR $C5C9                 
D265  A9 33    LDA #$33                  
D267  20 8C EF JSR $EF8C                 
D26A  A9 16    LDA #$16                  
D26C  A0 0A    LDY #$0A                  
D26E  20 25 C9 JSR $C925                 
D271  E6 02    INC $02                   
D273  A9 00    LDA #$00                  
D275  A0 85    LDY #$85                  
D277  20 B1 E9 JSR $E9B1                 
D27A  A9 05    LDA #$05                  
D27C  A0 FF    LDY #$FF                  
D27E  20 6D F8 JSR $F86D                 
D281  20 05 E1 JSR $E105                 
D284  A9 00    LDA #$00                  
D286  85 0A    STA $0A                   
D288  85 0B    STA $0B                   
D28A  A9 0C    LDA #$0C                  
D28C  85 F0    STA $F0                   
D28E  4C 35 C5 JMP $C535                 

sub_D291:  ; xrefs(1): $C9C1
D291  20 82 C8 JSR $C882                 
D294  20 9A CA JSR $CA9A                 
D297  A9 04    LDA #$04                  
D299  20 2C C9 JSR $C92C                 
D29C  20 37 80 JSR $8037                 
D29F  A5 57    LDA $57                   
D2A1  F0 08    BEQ $D2AB                 
D2A3  A9 10    LDA #$10                  
D2A5  85 F0    STA $F0                   
D2A7  A9 06    LDA #$06                  
D2A9  85 02    STA $02                   

loc_D2AB:  ; xrefs(1): $D2A1
D2AB  60       RTS                       

sub_D2AC:  ; xrefs(1): $C9C1
D2AC  20 C9 C5 JSR $C5C9                 
D2AF  A9 01    LDA #$01                  
D2B1  8D 00 A0 STA $A000                 
D2B4  A9 30    LDA #$30                  
D2B6  20 8C EF JSR $EF8C                 
D2B9  A9 31    LDA #$31                  
D2BB  20 8C EF JSR $EF8C                 
D2BE  A9 0A    LDA #$0A                  
D2C0  85 F0    STA $F0                   
D2C2  A5 08    LDA $08                   
D2C4  29 FC    AND #$FC                  
D2C6  85 08    STA $08                   
D2C8  A9 10    LDA #$10                  
D2CA  A0 12    LDY #$12                  
D2CC  20 25 C9 JSR $C925                 
D2CF  E6 02    INC $02                   
D2D1  A9 80    LDA #$80                  
D2D3  A0 82    LDY #$82                  
D2D5  20 B1 E9 JSR $E9B1                 
D2D8  20 4F F8 JSR $F84F                 
D2DB  A9 02    LDA #$02                  
D2DD  85 28    STA $28                   
D2DF  A9 20    LDA #$20                  
D2E1  85 4C    STA $4C                   
D2E3  0A       ASL A                     
D2E4  85 4D    STA $4D                   
D2E6  A9 05    LDA #$05                  
D2E8  A0 FF    LDY #$FF                  
D2EA  20 6D F8 JSR $F86D                 
D2ED  20 05 E1 JSR $E105                 
D2F0  A9 00    LDA #$00                  
D2F2  85 0A    STA $0A                   
D2F4  A9 00    LDA #$00                  
D2F6  85 0B    STA $0B                   
D2F8  4C 35 C5 JMP $C535                 

sub_D2FB:  ; xrefs(1): $C9C1
D2FB  20 9A CA JSR $CA9A                 
D2FE  38       SEC                       
D2FF  A5 0A    LDA $0A                   
D301  E9 02    SBC #$02                  
D303  85 0A    STA $0A                   
D305  C6 4C    DEC $4C                   
D307  D0 4E    BNE $D357                 
D309  18       CLC                       
D30A  A5 0A    LDA $0A                   
D30C  69 02    ADC #$02                  
D30E  85 0A    STA $0A                   
D310  E6 4C    INC $4C                   
D312  A9 30    LDA #$30                  
D314  8D 0F 01 STA $010F                 
D317  A5 09    LDA $09                   
D319  29 FE    AND #$FE                  
D31B  85 09    STA $09                   
D31D  A5 4D    LDA $4D                   
D31F  C9 30    CMP #$30                  
D321  B0 04    BCS $D327                 
D323  29 02    AND #$02                  
D325  F0 00    BEQ $D327                 

loc_D327:  ; xrefs(2): $D321 $D325
D327  C6 4D    DEC $4D                   
D329  D0 2C    BNE $D357                 
D32B  A5 09    LDA $09                   
D32D  29 FE    AND #$FE                  
D32F  85 09    STA $09                   
D331  A9 A0    LDA #$A0                  
D333  A0 82    LDY #$82                  
D335  20 B1 E9 JSR $E9B1                 
D338  20 4F F8 JSR $F84F                 
D33B  A9 05    LDA #$05                  
D33D  A0 FF    LDY #$FF                  
D33F  20 6D F8 JSR $F86D                 
D342  A9 14    LDA #$14                  
D344  A0 16    LDY #$16                  
D346  20 25 C9 JSR $C925                 
D349  A9 3A    LDA #$3A                  
D34B  85 02    STA $02                   
D34D  A9 00    LDA #$00                  
D34F  85 4C    STA $4C                   
D351  85 0A    STA $0A                   
D353  A9 EF    LDA #$EF                  
D355  85 0B    STA $0B                   

loc_D357:  ; xrefs(2): $D307 $D329
D357  60       RTS                       

sub_D358:  ; xrefs(1): $C9C1
D358  20 9A CA JSR $CA9A                 
D35B  E6 4C    INC $4C                   
D35D  A0 1F    LDY #$1F                  
D35F  A5 0C    LDA $0C                   
D361  6A       ROR A                     
D362  90 02    BCC $D366                 
D364  A0 31    LDY #$31                  

loc_D366:  ; xrefs(1): $D362
D366  A5 4C    LDA $4C                   
D368  C9 20    CMP #$20                  
D36A  90 03    BCC $D36F                 
D36C  8C 02 01 STY $0102                 

loc_D36F:  ; xrefs(1): $D36A
D36F  C9 30    CMP #$30                  
D371  90 03    BCC $D376                 
D373  8C 06 01 STY $0106                 

loc_D376:  ; xrefs(1): $D371
D376  C9 40    CMP #$40                  
D378  90 03    BCC $D37D                 
D37A  8C 0A 01 STY $010A                 

loc_D37D:  ; xrefs(1): $D378
D37D  C9 80    CMP #$80                  
D37F  D0 27    BNE $D3A8                 
D381  A9 80    LDA #$80                  
D383  A0 82    LDY #$82                  
D385  20 B1 E9 JSR $E9B1                 
D388  20 4F F8 JSR $F84F                 
D38B  A9 05    LDA #$05                  
D38D  A0 FF    LDY #$FF                  
D38F  20 6D F8 JSR $F86D                 
D392  A9 10    LDA #$10                  
D394  A0 12    LDY #$12                  
D396  20 25 C9 JSR $C925                 
D399  A9 20    LDA #$20                  
D39B  85 4C    STA $4C                   
D39D  E6 02    INC $02                   
D39F  A9 C0    LDA #$C0                  
D3A1  85 0A    STA $0A                   
D3A3  A9 00    LDA #$00                  
D3A5  85 0B    STA $0B                   
D3A7  60       RTS                       

loc_D3A8:  ; xrefs(1): $D37F
D3A8  60       RTS                       

sub_D3A9:  ; xrefs(1): $C9C1
D3A9  20 9A CA JSR $CA9A                 
D3AC  C6 4C    DEC $4C                   
D3AE  D0 10    BNE $D3C0                 
D3B0  A9 02    LDA #$02                  
D3B2  A0 FF    LDY #$FF                  
D3B4  20 6D F8 JSR $F86D                 
D3B7  E6 02    INC $02                   
D3B9  20 65 F8 JSR $F865                 
D3BC  A9 10    LDA #$10                  
D3BE  85 4C    STA $4C                   

loc_D3C0:  ; xrefs(1): $D3AE
D3C0  60       RTS                       

sub_D3C1:  ; xrefs(1): $C9C1
D3C1  20 9A CA JSR $CA9A                 
D3C4  A5 26    LDA $26                   
D3C6  D0 2B    BNE $D3F3                 
D3C8  C6 4C    DEC $4C                   
D3CA  D0 27    BNE $D3F3                 
D3CC  A9 05    LDA #$05                  
D3CE  A0 FF    LDY #$FF                  
D3D0  20 6D F8 JSR $F86D                 
D3D3  A9 C0    LDA #$C0                  
D3D5  A0 82    LDY #$82                  
D3D7  20 B1 E9 JSR $E9B1                 
D3DA  A9 10    LDA #$10                  
D3DC  A0 12    LDY #$12                  
D3DE  20 25 C9 JSR $C925                 
D3E1  A9 70    LDA #$70                  
D3E3  85 4C    STA $4C                   
D3E5  A9 00    LDA #$00                  
D3E7  85 4D    STA $4D                   
D3E9  A9 01    LDA #$01                  
D3EB  85 4E    STA $4E                   
D3ED  A9 50    LDA #$50                  
D3EF  85 0A    STA $0A                   
D3F1  E6 02    INC $02                   

loc_D3F3:  ; xrefs(2): $D3C6 $D3CA
D3F3  60       RTS                       

sub_D3F4:  ; xrefs(1): $C9C1
D3F4  20 9A CA JSR $CA9A                 
D3F7  A5 0C    LDA $0C                   
D3F9  29 07    AND #$07                  
D3FB  D0 16    BNE $D413                 
D3FD  C6 0A    DEC $0A                   
D3FF  E6 4C    INC $4C                   
D401  A5 0A    LDA $0A                   
D403  C9 30    CMP #$30                  
D405  D0 0C    BNE $D413                 
D407  A9 01    LDA #$01                  
D409  A0 FF    LDY #$FF                  
D40B  20 6D F8 JSR $F86D                 
D40E  A9 5B    LDA #$5B                  
D410  85 02    STA $02                   
D412  60       RTS                       

loc_D413:  ; xrefs(2): $D3FB $D405
D413  A5 4E    LDA $4E                   
D415  10 06    BPL $D41D                 
D417  A5 0C    LDA $0C                   
D419  6A       ROR A                     
D41A  90 17    BCC $D433                 
D41C  60       RTS                       

loc_D41D:  ; xrefs(1): $D415
D41D  C6 4E    DEC $4E                   
D41F  D0 12    BNE $D433                 
D421  A4 4D    LDY $4D                   
D423  B9 4B D4 LDA $D44B,Y               
D426  85 4E    STA $4E                   
D428  30 20    BMI $D44A                 
D42A  B9 4C D4 LDA $D44C,Y               
D42D  85 4F    STA $4F                   
D42F  E6 4D    INC $4D                   
D431  E6 4D    INC $4D                   

loc_D433:  ; xrefs(2): $D41A $D41F
D433  A5 4C    LDA $4C                   
D435  85 90    STA $90                   
D437  A9 60    LDA #$60                  
D439  85 92    STA $92                   
D43B  A9 00    LDA #$00                  
D43D  85 91    STA $91                   
D43F  85 93    STA $93                   
D441  85 9E    STA $9E                   
D443  A5 4F    LDA $4F                   
D445  A0 02    LDY #$02                  
D447  4C F9 F3 JMP $F3F9                 

loc_D44A:  ; xrefs(1): $D428
D44A  60       RTS                       

; ---- data $D44B-$D45B (17 bytes) ----
D44B  40 00 06 08 08 0A 06 0C 02 00 04 0E 04 00 04 10  |@...............
D45B  FF                                               |.

sub_D45C:  ; xrefs(1): $C9C1
D45C  20 9A CA JSR $CA9A                 
D45F  A5 26    LDA $26                   
D461  D0 1D    BNE $D480                 
D463  A9 10    LDA #$10                  
D465  8D 01 20 STA $2001                 
D468  85 09    STA $09                   
D46A  A9 10    LDA #$10                  
D46C  85 F0    STA $F0                   
D46E  A9 19    LDA #$19                  
D470  85 02    STA $02                   
D472  A9 00    LDA #$00                  
D474  8D 00 A0 STA $A000                 
D477  85 7D    STA $7D                   
D479  A9 04    LDA #$04                  
D47B  85 28    STA $28                   
D47D  4C B0 C5 JMP $C5B0                 

loc_D480:  ; xrefs(1): $D461
D480  60       RTS                       

sub_D481:  ; xrefs(1): $C9C1
D481  0F 21 10 SLO $1021                 
D484  30 0F    BMI $D495                 
D486  13 22    SLO ($22),Y               
D488  30 0F    BMI $D499                 
D48A  11 21    ORA ($21),Y               
D48C  31 0F    AND ($0F),Y               

; ---- data $D48E-$D494 (7 bytes) ----
D48E  12 22 32 0F 13 23 33                             |."2..#3

loc_D495:  ; xrefs(1): $D484
D495  0F 14 24 SLO $2414                 
D498  34 0F    NOP $0F,X                 
D49A  21 11    AND ($11,X)               
D49C  30 0F    BMI $D4AD                 
D49E  30 38    BMI $D4D8                 
D4A0  11 0F    ORA ($0F),Y               
D4A2  30 38    BMI $D4DC                 
D4A4  28       PLP                       
D4A5  0F 16 16 SLO $1616                 
D4A8  16 0F    ASL $0F,X                 
D4AA  14 24    NOP $24,X                 
D4AC  34 38    NOP $38,X                 
D4AE  AD 5B 07 LDA $075B                 
D4B1  ED FF 05 SBC $05FF                 
D4B4  85 90    STA $90                   
D4B6  AD 6B 07 LDA $076B                 
D4B9  ED FE 05 SBC $05FE                 
D4BC  85 91    STA $91                   
D4BE  AD 7B 07 LDA $077B                 
D4C1  ED FD 05 SBC $05FD                 
D4C4  85 92    STA $92                   
D4C6  90 1A    BCC $D4E2                 
D4C8  D0 06    BNE $D4D0                 
D4CA  A5 90    LDA $90                   
D4CC  05 91    ORA $91                   
D4CE  F0 12    BEQ $D4E2                 

loc_D4D0:  ; xrefs(1): $D4C8
D4D0  A5 02    LDA $02                   
D4D2  C9 55    CMP #$55                  
D4D4  D0 04    BNE $D4DA                 
D4D6  A9 59    LDA #$59                  

loc_D4D8:  ; xrefs(1): $D49E
D4D8  D0 05    BNE $D4DF                 

loc_D4DA:  ; xrefs(1): $D4D4
D4DA  20 B9 F8 JSR $F8B9                 
D4DD  A9 03    LDA #$03                  

loc_D4DF:  ; xrefs(1): $D4D8
D4DF  85 02    STA $02                   
D4E1  60       RTS                       

loc_D4E2:  ; xrefs(2): $D4C6 $D4CE
D4E2  AD FF 05 LDA $05FF                 
D4E5  8D 5B 07 STA $075B                 
D4E8  AD FE 05 LDA $05FE                 
D4EB  8D 6B 07 STA $076B                 
D4EE  AD FD 05 LDA $05FD                 
D4F1  8D 7B 07 STA $077B                 
D4F4  A9 00    LDA #$00                  
D4F6  8D 4B 07 STA $074B                 
D4F9  8D 3B 07 STA $073B                 
D4FC  8D 2B 07 STA $072B                 
D4FF  20 D0 D6 JSR $D6D0                 
D502  20 81 D6 JSR $D681                 
D505  A0 04    LDY #$04                  

loc_D507:  ; xrefs(1): $D50D
D507  B9 4B 07 LDA $074B,Y               
D50A  F0 03    BEQ $D50F                 
D50C  88       DEY                       
D50D  10 F8    BPL $D507                 

loc_D50F:  ; xrefs(1): $D50A
D50F  84 4D    STY $4D                   
D511  85 4C    STA $4C                   
D513  85 4E    STA $4E                   
D515  85 4F    STA $4F                   
D517  18       CLC                       
D518  98       TYA                       
D519  69 34    ADC #$34                  
D51B  20 8C EF JSR $EF8C                 
D51E  A9 0D    LDA #$0D                  
D520  85 F0    STA $F0                   
D522  4C 35 C5 JMP $C535                 

sub_D525:  ; xrefs(1): $C9C1
D525  20 2D C7 JSR $C72D                 
D528  20 72 D6 JSR $D672                 
D52B  20 D6 D5 JSR $D5D6                 
D52E  20 82 C8 JSR $C882                 
D531  A5 04    LDA $04                   
D533  29 08    AND #$08                  
D535  F0 02    BEQ $D539                 
D537  C6 4F    DEC $4F                   

loc_D539:  ; xrefs(1): $D535
D539  A5 04    LDA $04                   
D53B  29 04    AND #$04                  
D53D  F0 02    BEQ $D541                 
D53F  E6 4F    INC $4F                   

loc_D541:  ; xrefs(1): $D53D
D541  A5 4C    LDA $4C                   
D543  F0 19    BEQ $D55E                 
D545  24 04    BIT $04                   
D547  50 15    BVC $D55E                 
D549  C6 4C    DEC $4C                   
D54B  20 01 D6 JSR $D601                 
D54E  B9 2B 07 LDA $072B,Y               
D551  C9 7F    CMP #$7F                  
D553  D0 04    BNE $D559                 
D555  A9 1E    LDA #$1E                  
D557  D0 03    BNE $D55C                 

loc_D559:  ; xrefs(1): $D553
D559  38       SEC                       
D55A  E9 41    SBC #$41                  

loc_D55C:  ; xrefs(1): $D557
D55C  85 4F    STA $4F                   

loc_D55E:  ; xrefs(2): $D543 $D547
D55E  A5 04    LDA $04                   
D560  10 17    BPL $D579                 
D562  E6 4C    INC $4C                   
D564  A9 0D    LDA #$0D                  
D566  85 F1    STA $F1                   
D568  A5 4C    LDA $4C                   
D56A  C9 03    CMP #$03                  
D56C  D0 0B    BNE $D579                 
D56E  A9 0E    LDA #$0E                  
D570  85 F1    STA $F1                   
D572  A9 00    LDA #$00                  
D574  85 4C    STA $4C                   
D576  E6 02    INC $02                   
D578  60       RTS                       

loc_D579:  ; xrefs(2): $D560 $D56C
D579  A5 4F    LDA $4F                   
D57B  30 08    BMI $D585                 
D57D  C9 1F    CMP #$1F                  
D57F  90 06    BCC $D587                 
D581  A9 00    LDA #$00                  
D583  F0 02    BEQ $D587                 

loc_D585:  ; xrefs(1): $D57B
D585  A9 1E    LDA #$1E                  

loc_D587:  ; xrefs(2): $D57F $D583
D587  85 4F    STA $4F                   
D589  C9 1E    CMP #$1E                  
D58B  D0 02    BNE $D58F                 
D58D  A9 3E    LDA #$3E                  

loc_D58F:  ; xrefs(1): $D58B
D58F  18       CLC                       
D590  69 41    ADC #$41                  
D592  85 90    STA $90                   
D594  A5 0C    LDA $0C                   
D596  6A       ROR A                     
D597  90 2C    BCC $D5C5                 
D599  AC 00 03 LDY $0300                 
D59C  A5 90    LDA $90                   
D59E  99 04 03 STA $0304,Y               
D5A1  A9 81    LDA #$81                  
D5A3  99 01 03 STA $0301,Y               
D5A6  A6 4D    LDX $4D                   
D5A8  18       CLC                       
D5A9  BD 10 D6 LDA $D610,X               
D5AC  65 4C    ADC $4C                   
D5AE  99 03 03 STA $0303,Y               
D5B1  BD 79 D7 LDA $D779,X               
D5B4  69 00    ADC #$00                  
D5B6  99 02 03 STA $0302,Y               
D5B9  A9 00    LDA #$00                  
D5BB  99 05 03 STA $0305,Y               
D5BE  18       CLC                       
D5BF  98       TYA                       
D5C0  69 04    ADC #$04                  
D5C2  20 31 E3 JSR $E331                 

loc_D5C5:  ; xrefs(1): $D597
D5C5  20 01 D6 JSR $D601                 
D5C8  18       CLC                       
D5C9  A5 4F    LDA $4F                   
D5CB  69 41    ADC #$41                  
D5CD  C9 5F    CMP #$5F                  
D5CF  D0 02    BNE $D5D3                 
D5D1  A9 7F    LDA #$7F                  

loc_D5D3:  ; xrefs(1): $D5CF
D5D3  99 2B 07 STA $072B,Y               

sub_D5D6:  ; xrefs(1): $D52B
D5D6  20 15 D6 JSR $D615                 
D5D9  A9 F8    LDA #$F8                  
D5DB  8D 04 02 STA $0204                 
D5DE  A5 0C    LDA $0C                   
D5E0  29 10    AND #$10                  
D5E2  D0 1C    BNE $D600                 
D5E4  A4 4D    LDY $4D                   
D5E6  B9 0B D6 LDA $D60B,Y               
D5E9  8D 04 02 STA $0204                 
D5EC  A5 4C    LDA $4C                   
D5EE  0A       ASL A                     
D5EF  0A       ASL A                     
D5F0  0A       ASL A                     
D5F1  69 A8    ADC #$A8                  
D5F3  8D 07 02 STA $0207                 
D5F6  A9 1F    LDA #$1F                  
D5F8  8D 05 02 STA $0205                 
D5FB  A9 00    LDA #$00                  
D5FD  8D 06 02 STA $0206                 

loc_D600:  ; xrefs(1): $D5E2
D600  60       RTS                       

sub_D601:  ; xrefs(2): $D54B $D5C5
D601  A5 4C    LDA $4C                   
D603  0A       ASL A                     
D604  0A       ASL A                     
D605  0A       ASL A                     
D606  0A       ASL A                     
D607  65 4D    ADC $4D                   
D609  A8       TAY                       
D60A  60       RTS                       

; ---- data $D60B-$D614 (10 bytes) ----
D60B  97 87 77 67 57 75 35 F5 B5 75                    |..wgWu5..u

sub_D615:  ; xrefs(2): $D5D6 $D6A5
D615  A5 0C    LDA $0C                   
D617  4A       LSR A                     
D618  4A       LSR A                     

sub_D619:  ; xrefs(1): $D64D
D619  29 03    AND #$03                  
D61B  A8       TAY                       
D61C  B9 29 D6 LDA $D629,Y               
D61F  8D 0A 01 STA $010A                 
D622  B9 2D D6 LDA $D62D,Y               
D625  8D 0B 01 STA $010B                 
D628  60       RTS                       

; ---- data $D629-$D630 (8 bytes) ----
D629  05 17 26 35 26 27 38 30                          |..&5&'80

sub_D631:  ; xrefs(1): $C9C1
D631  A9 01    LDA #$01                  
D633  A0 FF    LDY #$FF                  
D635  20 6D F8 JSR $F86D                 
D638  E6 02    INC $02                   
D63A  60       RTS                       

sub_D63B:  ; xrefs(1): $C9C1
D63B  A5 26    LDA $26                   
D63D  D0 06    BNE $D645                 
D63F  20 9C C5 JSR $C59C                 
D642  4C 7F F9 JMP $F97F                 

loc_D645:  ; xrefs(1): $D63D
D645  4C 06 F8 JMP $F806                 

sub_D648:  ; xrefs(1): $C9C1
D648  20 72 D6 JSR $D672                 
D64B  A5 0C    LDA $0C                   
D64D  20 19 D6 JSR $D619                 
D650  A9 F8    LDA #$F8                  
D652  8D 04 02 STA $0204                 
D655  C6 4C    DEC $4C                   
D657  D0 18    BNE $D671                 
D659  20 05 E1 JSR $E105                 
D65C  A5 02    LDA $02                   
D65E  C9 58    CMP #$58                  
D660  D0 04    BNE $D666                 
D662  A9 59    LDA #$59                  
D664  D0 05    BNE $D66B                 

loc_D666:  ; xrefs(1): $D660
D666  20 B9 F8 JSR $F8B9                 
D669  A9 03    LDA #$03                  

loc_D66B:  ; xrefs(1): $D664
D66B  85 02    STA $02                   
D66D  A9 10    LDA #$10                  
D66F  85 F0    STA $F0                   

loc_D671:  ; xrefs(1): $D657
D671  60       RTS                       

sub_D672:  ; xrefs(3): $D528 $D648 $D6C7
D672  A5 0C    LDA $0C                   
D674  29 03    AND #$03                  
D676  D0 08    BNE $D680                 
D678  EE 65 07 INC $0765                 
D67B  D0 03    BNE $D680                 
D67D  EE 55 07 INC $0755                 

loc_D680:  ; xrefs(2): $D676 $D67B
D680  60       RTS                       

sub_D681:  ; xrefs(1): $D502
D681  A9 4F    LDA #$4F                  
D683  85 75    STA $75                   
D685  A9 54    LDA #$54                  
D687  85 7D    STA $7D                   
D689  A9 80    LDA #$80                  
D68B  20 18 C6 JSR $C618                 
D68E  A2 07    LDX #$07                  

loc_D690:  ; xrefs(1): $D69C
D690  BD 9F D6 LDA $D69F,X               
D693  9D 40 07 STA $0740,X               
D696  A9 FF    LDA #$FF                  
D698  9D 50 07 STA $0750,X               
D69B  CA       DEX                       
D69C  10 F2    BPL $D690                 
D69E  60       RTS                       

; ---- data $D69F-$D6A4 (6 bytes) ----
D69F  10 10 10 10 0F 1B                                |......

sub_D6A5:  ; xrefs(1): $C9C1
D6A5  20 15 D6 JSR $D615                 
D6A8  A6 4E    LDX $4E                   
D6AA  BD 50 07 LDA $0750,X               
D6AD  6A       ROR A                     
D6AE  90 17    BCC $D6C7                 
D6B0  BD 60 07 LDA $0760,X               
D6B3  69 0F    ADC #$0F                  
D6B5  9D 60 07 STA $0760,X               
D6B8  90 0D    BCC $D6C7                 
D6BA  FE 50 07 INC $0750,X               
D6BD  E6 4E    INC $4E                   
D6BF  A5 4E    LDA $4E                   
D6C1  C9 05    CMP #$05                  
D6C3  D0 02    BNE $D6C7                 
D6C5  E6 02    INC $02                   

loc_D6C7:  ; xrefs(3): $D6AE $D6B8 $D6C3
D6C7  4C 72 D6 JMP $D672                 

sub_D6CA:  ; xrefs(1): $C9C1
D6CA  20 D0 D6 JSR $D6D0                 
D6CD  4C 35 C5 JMP $C535                 

sub_D6D0:  ; xrefs(2): $D4FF $D6CA
D6D0  20 C9 C5 JSR $C5C9                 
D6D3  20 1F D8 JSR $D81F                 
D6D6  A9 12    LDA #$12                  
D6D8  20 8C EF JSR $EF8C                 
D6DB  20 37 E2 JSR $E237                 
D6DE  E6 02    INC $02                   
D6E0  A2 1F    LDX #$1F                  
D6E2  20 E9 C6 JSR $C6E9                 
D6E5  C0 83    CPY #$83                  
D6E7  20 02 ED JSR $ED02                 
D6EA  A0 04    LDY #$04                  

loc_D6EC:  ; xrefs(1): $D724
D6EC  98       TYA                       
D6ED  48       PHA                       
D6EE  B9 5B 07 LDA $075B,Y               
D6F1  85 90    STA $90                   
D6F3  B9 6B 07 LDA $076B,Y               
D6F6  85 91    STA $91                   
D6F8  B9 7B 07 LDA $077B,Y               
D6FB  85 92    STA $92                   
D6FD  20 7C EC JSR $EC7C                 
D700  20 F5 EC JSR $ECF5                 
D703  20 72 EC JSR $EC72                 
D706  A9 46    LDA #$46                  
D708  85 95    STA $95                   
D70A  B9 79 D7 LDA $D779,Y               
D70D  85 96    STA $96                   
D70F  B9 74 D7 LDA $D774,Y               
D712  85 97    STA $97                   
D714  A9 00    LDA #$00                  
D716  85 9E    STA $9E                   
D718  85 91    STA $91                   
D71A  A9 95    LDA #$95                  
D71C  85 90    STA $90                   
D71E  20 84 EF JSR $EF84                 
D721  68       PLA                       
D722  A8       TAY                       
D723  88       DEY                       
D724  10 C6    BPL $D6EC                 
D726  A0 04    LDY #$04                  

loc_D728:  ; xrefs(1): $D75E
D728  98       TYA                       
D729  48       PHA                       
D72A  A9 43    LDA #$43                  
D72C  85 95    STA $95                   
D72E  18       CLC                       
D72F  B9 74 D7 LDA $D774,Y               
D732  69 09    ADC #$09                  
D734  85 97    STA $97                   
D736  B9 79 D7 LDA $D779,Y               
D739  69 00    ADC #$00                  
D73B  85 96    STA $96                   
D73D  A9 00    LDA #$00                  
D73F  85 9B    STA $9B                   
D741  B9 2B 07 LDA $072B,Y               
D744  85 98    STA $98                   
D746  B9 3B 07 LDA $073B,Y               
D749  85 99    STA $99                   
D74B  B9 4B 07 LDA $074B,Y               
D74E  85 9A    STA $9A                   
D750  A9 95    LDA #$95                  
D752  85 90    STA $90                   
D754  A9 00    LDA #$00                  
D756  85 91    STA $91                   
D758  20 84 EF JSR $EF84                 
D75B  68       PLA                       
D75C  A8       TAY                       
D75D  88       DEY                       
D75E  10 C8    BPL $D728                 
D760  20 0A E1 JSR $E10A                 
D763  A2 07    LDX #$07                  

loc_D765:  ; xrefs(1): $D76C
D765  BD 6F D7 LDA $D76F,X               
D768  9D 40 07 STA $0740,X               
D76B  CA       DEX                       
D76C  10 F7    BPL $D765                 
D76E  60       RTS                       

; ---- data $D76F-$D77D (15 bytes) ----
D76F  24 1C 10 13 1B 6C 2C EC AC 6C 22 22 21 21 21     |$....l,..l""!!!

sub_D77E:  ; xrefs(1): $C9C1
D77E  20 55 E2 JSR $E255                 
D781  20 82 C8 JSR $C882                 
D784  A5 04    LDA $04                   
D786  29 F0    AND #$F0                  
D788  D0 0A    BNE $D794                 
D78A  A5 00    LDA $00                   
D78C  29 03    AND #$03                  
D78E  D0 0E    BNE $D79E                 
D790  C6 4C    DEC $4C                   
D792  D0 0A    BNE $D79E                 

loc_D794:  ; xrefs(1): $D788
D794  EE A0 05 INC $05A0                 
D797  20 05 E1 JSR $E105                 
D79A  A9 03    LDA #$03                  
D79C  85 02    STA $02                   

loc_D79E:  ; xrefs(2): $D78E $D792
D79E  60       RTS                       

sub_D79F:  ; xrefs(1): $C9C1
D79F  20 C9 C5 JSR $C5C9                 
D7A2  20 1F D8 JSR $D81F                 
D7A5  A9 19    LDA #$19                  
D7A7  85 0D    STA $0D                   
D7A9  20 8C EF JSR $EF8C                 
D7AC  20 D8 DA JSR $DAD8                 
D7AF  85 2E    STA $2E                   
D7B1  E6 02    INC $02                   
D7B3  E6 59    INC $59                   
D7B5  A2 13    LDX #$13                  
D7B7  20 E9 C6 JSR $C6E9                 
D7BA  85 D4    STA $D4                   
D7BC  20 05 E1 JSR $E105                 
D7BF  4C 35 C5 JMP $C535                 

sub_D7C2:  ; xrefs(1): $C9C1
D7C2  A9 F7    LDA #$F7                  
D7C4  8D 00 02 STA $0200                 
D7C7  20 82 C8 JSR $C882                 
D7CA  A5 04    LDA $04                   
D7CC  29 10    AND #$10                  
D7CE  F0 0F    BEQ $D7DF                 
D7D0  20 C9 C5 JSR $C5C9                 
D7D3  20 35 C5 JSR $C535                 
D7D6  A6 4C    LDX $4C                   
D7D8  BD 16 D8 LDA $D816,X               
D7DB  85 02    STA $02                   
D7DD  D0 16    BNE $D7F5                 

loc_D7DF:  ; xrefs(1): $D7CE
D7DF  A5 04    LDA $04                   
D7E1  29 20    AND #$20                  
D7E3  F0 10    BEQ $D7F5                 
D7E5  A9 02    LDA #$02                  
D7E7  85 F1    STA $F1                   
D7E9  E6 4C    INC $4C                   
D7EB  A5 4C    LDA $4C                   
D7ED  C9 09    CMP #$09                  
D7EF  90 04    BCC $D7F5                 
D7F1  A9 00    LDA #$00                  
D7F3  85 4C    STA $4C                   

loc_D7F5:  ; xrefs(3): $D7DD $D7E3 $D7EF
D7F5  A6 4C    LDX $4C                   
D7F7  BD 0D D8 LDA $D80D,X               
D7FA  8D 00 02 STA $0200                 
D7FD  A9 58    LDA #$58                  
D7FF  8D 03 02 STA $0203                 
D802  A9 1B    LDA #$1B                  
D804  8D 01 02 STA $0201                 
D807  A9 00    LDA #$00                  
D809  8D 02 02 STA $0202                 
D80C  60       RTS                       

; ---- data $D80D-$D81E (18 bytes) ----
D80D  57 67 77 87 97 A7 B7 C7 D7 2A 33 48 30 41 42 4A  |Wgw......*3H0ABJ
D81D  4B 04                                            |K.

sub_D81F:  ; xrefs(7): $D6D3 $D7A2 $D866 $D8CA $D977 $E09C $E4EC
D81F  A9 00    LDA #$00                  
D821  8D 00 80 STA $8000                 
D824  85 40    STA $40                   
D826  8D 01 80 STA $8001                 
D829  A9 01    LDA #$01                  
D82B  8D 00 80 STA $8000                 
D82E  A9 02    LDA #$02                  
D830  85 41    STA $41                   
D832  8D 01 80 STA $8001                 

sub_D835:  ; xrefs(1): $F9F6
D835  A9 02    LDA #$02                  
D837  8D 00 80 STA $8000                 
D83A  A9 5C    LDA #$5C                  
D83C  85 42    STA $42                   
D83E  8D 01 80 STA $8001                 
D841  60       RTS                       

sub_D842:  ; xrefs(1): $C9C1
D842  A9 24    LDA #$24                  
D844  85 02    STA $02                   
D846  60       RTS                       

sub_D847:  ; xrefs(5): $C9C1 $D871 $D8AF $D8D5 $D913
D847  A5 4C    LDA $4C                   
D849  29 7F    AND #$7F                  
D84B  85 41    STA $41                   
D84D  85 91    STA $91                   
D84F  A9 21    LDA #$21                  
D851  8D 06 20 STA $2006                 
D854  A9 6F    LDA #$6F                  

sub_D856:  ; xrefs(2): $D949 $D957
D856  8D 06 20 STA $2006                 
D859  20 3A C8 JSR $C83A                 
D85C  8D 07 20 STA $2007                 
D85F  8E 07 20 STX $2007                 
D862  60       RTS                       

sub_D863:  ; xrefs(1): $C9C1
D863  20 C9 C5 JSR $C5C9                 
D866  20 1F D8 JSR $D81F                 
D869  A9 1B    LDA #$1B                  
D86B  20 8C EF JSR $EF8C                 
D86E  20 D8 DA JSR $DAD8                 
D871  20 47 D8 JSR $D847                 
D874  E6 02    INC $02                   
D876  A2 0F    LDX #$0F                  
D878  20 E9 C6 JSR $C6E9                 
D87B  85 D4    STA $D4                   
D87D  4C 35 C5 JMP $C535                 

sub_D880:  ; xrefs(1): $C9C1
D880  20 82 C8 JSR $C882                 
D883  A5 04    LDA $04                   
D885  29 10    AND #$10                  
D887  F0 05    BEQ $D88E                 
D889  A9 24    LDA #$24                  
D88B  85 02    STA $02                   
D88D  60       RTS                       

loc_D88E:  ; xrefs(1): $D887
D88E  A5 04    LDA $04                   
D890  29 C0    AND #$C0                  
D892  F0 28    BEQ $D8BC                 
D894  10 05    BPL $D89B                 
D896  E6 4C    INC $4C                   
D898  4C 9D D8 JMP $D89D                 

loc_D89B:  ; xrefs(1): $D894
D89B  C6 4C    DEC $4C                   

loc_D89D:  ; xrefs(1): $D898
D89D  A5 4C    LDA $4C                   
D89F  C9 11    CMP #$11                  
D8A1  90 04    BCC $D8A7                 
D8A3  A9 00    LDA #$00                  
D8A5  85 4C    STA $4C                   

loc_D8A7:  ; xrefs(1): $D8A1
D8A7  20 C9 C5 JSR $C5C9                 
D8AA  A9 1B    LDA #$1B                  
D8AC  20 8C EF JSR $EF8C                 
D8AF  20 47 D8 JSR $D847                 
D8B2  A2 0F    LDX #$0F                  
D8B4  20 E9 C6 JSR $C6E9                 
D8B7  85 D4    STA $D4                   
D8B9  20 35 C5 JSR $C535                 

loc_D8BC:  ; xrefs(1): $D892
D8BC  A5 04    LDA $04                   
D8BE  29 20    AND #$20                  
D8C0  F0 04    BEQ $D8C6                 
D8C2  A5 4C    LDA $4C                   
D8C4  85 F0    STA $F0                   

loc_D8C6:  ; xrefs(1): $D8C0
D8C6  60       RTS                       

sub_D8C7:  ; xrefs(1): $C9C1
D8C7  20 C9 C5 JSR $C5C9                 
D8CA  20 1F D8 JSR $D81F                 
D8CD  A9 2F    LDA #$2F                  
D8CF  20 8C EF JSR $EF8C                 
D8D2  20 D8 DA JSR $DAD8                 
D8D5  20 47 D8 JSR $D847                 
D8D8  E6 02    INC $02                   
D8DA  A2 0F    LDX #$0F                  
D8DC  20 E9 C6 JSR $C6E9                 
D8DF  85 D4    STA $D4                   
D8E1  4C 35 C5 JMP $C535                 

sub_D8E4:  ; xrefs(1): $C9C1
D8E4  20 82 C8 JSR $C882                 
D8E7  A5 04    LDA $04                   
D8E9  29 10    AND #$10                  
D8EB  F0 05    BEQ $D8F2                 
D8ED  A9 24    LDA #$24                  
D8EF  85 02    STA $02                   
D8F1  60       RTS                       

loc_D8F2:  ; xrefs(1): $D8EB
D8F2  A5 04    LDA $04                   
D8F4  29 C0    AND #$C0                  
D8F6  F0 28    BEQ $D920                 
D8F8  10 05    BPL $D8FF                 
D8FA  E6 4C    INC $4C                   
D8FC  4C 01 D9 JMP $D901                 

loc_D8FF:  ; xrefs(1): $D8F8
D8FF  C6 4C    DEC $4C                   

loc_D901:  ; xrefs(1): $D8FC
D901  A5 4C    LDA $4C                   
D903  C9 41    CMP #$41                  
D905  90 04    BCC $D90B                 
D907  A9 00    LDA #$00                  
D909  85 4C    STA $4C                   

loc_D90B:  ; xrefs(1): $D905
D90B  20 C9 C5 JSR $C5C9                 
D90E  A9 2F    LDA #$2F                  
D910  20 8C EF JSR $EF8C                 
D913  20 47 D8 JSR $D847                 
D916  A2 0F    LDX #$0F                  
D918  20 E9 C6 JSR $C6E9                 
D91B  85 D4    STA $D4                   
D91D  20 35 C5 JSR $C535                 

loc_D920:  ; xrefs(1): $D8F6
D920  A5 04    LDA $04                   
D922  29 20    AND #$20                  
D924  F0 04    BEQ $D92A                 
D926  A5 4C    LDA $4C                   
D928  85 F1    STA $F1                   

loc_D92A:  ; xrefs(1): $D924
D92A  60       RTS                       

sub_D92B:  ; xrefs(1): $C9C1
D92B  A9 08    LDA #$08                  
D92D  D0 03    BNE $D932                 

sub_D92F:  ; xrefs(1): $C9C1
D92F  60       RTS                       

sub_D930:  ; xrefs(1): $C9C1
D930  A9 0C    LDA #$0C                  

loc_D932:  ; xrefs(1): $D92D
D932  85 55    STA $55                   
D934  A9 1D    LDA #$1D                  
D936  85 02    STA $02                   
D938  60       RTS                       

sub_D939:  ; xrefs(1): $C9C1
D939  A9 24    LDA #$24                  
D93B  85 02    STA $02                   
D93D  60       RTS                       

sub_D93E:  ; xrefs(1): $C9C1
D93E  A5 4D    LDA $4D                   
D940  85 91    STA $91                   
D942  A9 21    LDA #$21                  
D944  8D 06 20 STA $2006                 
D947  A9 6E    LDA #$6E                  
D949  20 56 D8 JSR $D856                 
D94C  A5 4C    LDA $4C                   
D94E  85 91    STA $91                   
D950  A9 21    LDA #$21                  
D952  8D 06 20 STA $2006                 
D955  A9 70    LDA #$70                  
D957  4C 56 D8 JMP $D856                 

sub_D95A:  ; xrefs(1): $C9C1
D95A  C6 4C    DEC $4C                   
D95C  D0 15    BNE $D973                 
D95E  A9 04    LDA #$04                  
D960  20 2C C9 JSR $C92C                 
D963  20 3A 80 JSR $803A                 
D966  A9 5C    LDA #$5C                  
D968  85 02    STA $02                   
D96A  20 78 C5 JSR $C578                 
D96D  20 DA C5 JSR $C5DA                 
D970  4C 35 C5 JMP $C535                 

loc_D973:  ; xrefs(1): $D95C
D973  60       RTS                       

sub_D974:  ; xrefs(1): $C9C1
D974  20 C9 C5 JSR $C5C9                 
D977  20 1F D8 JSR $D81F                 
D97A  A9 00    LDA #$00                  
D97C  85 2E    STA $2E                   
D97E  E6 59    INC $59                   
D980  D0 02    BNE $D984                 
D982  C6 59    DEC $59                   

loc_D984:  ; xrefs(1): $D980
D984  A9 09    LDA #$09                  
D986  85 F0    STA $F0                   
D988  A9 14    LDA #$14                  
D98A  20 8C EF JSR $EF8C                 
D98D  AD 5F 07 LDA $075F                 
D990  85 90    STA $90                   
D992  AD 6F 07 LDA $076F                 
D995  85 91    STA $91                   
D997  AD 7F 07 LDA $077F                 
D99A  85 92    STA $92                   
D99C  20 6C EC JSR $EC6C                 
D99F  A9 21    LDA #$21                  
D9A1  85 96    STA $96                   
D9A3  A9 73    LDA #$73                  
D9A5  85 97    STA $97                   
D9A7  20 F1 D9 JSR $D9F1                 
D9AA  20 5D EC JSR $EC5D                 
D9AD  A9 21    LDA #$21                  
D9AF  85 96    STA $96                   
D9B1  A9 B3    LDA #$B3                  
D9B3  85 97    STA $97                   
D9B5  20 F1 D9 JSR $D9F1                 
D9B8  20 37 E2 JSR $E237                 
D9BB  E6 02    INC $02                   
D9BD  A2 1F    LDX #$1F                  
D9BF  20 E9 C6 JSR $C6E9                 
D9C2  80 83    NOP #$83                  
D9C4  20 D8 DA JSR $DAD8                 
D9C7  20 0A E1 JSR $E10A                 
D9CA  A2 07    LDX #$07                  

loc_D9CC:  ; xrefs(1): $D9D3
D9CC  BD EC D9 LDA $D9EC,X               
D9CF  9D 40 07 STA $0740,X               
D9D2  CA       DEX                       
D9D3  10 F7    BPL $D9CC                 
D9D5  A9 2A    LDA #$2A                  
D9D7  85 75    STA $75                   
D9D9  A9 01    LDA #$01                  
D9DB  8D 52 07 STA $0752                 
D9DE  8D 53 07 STA $0753                 
D9E1  A9 02    LDA #$02                  
D9E3  8D 1C 07 STA $071C                 
D9E6  20 C1 F8 JSR $F8C1                 
D9E9  4C 35 C5 JMP $C535                 

; ---- data $D9EC-$D9F0 (5 bytes) ----
D9EC  18 36 10 17 1B                                   |.6...

sub_D9F1:  ; xrefs(2): $D9A7 $D9B5
D9F1  A9 46    LDA #$46                  
D9F3  85 95    STA $95                   
D9F5  A9 00    LDA #$00                  
D9F7  85 9E    STA $9E                   
D9F9  85 91    STA $91                   
D9FB  A9 95    LDA #$95                  
D9FD  85 90    STA $90                   
D9FF  4C 84 EF JMP $EF84                 

sub_DA02:  ; xrefs(1): $C9C1
DA02  20 55 E2 JSR $E255                 
DA05  C6 4D    DEC $4D                   
DA07  A5 4D    LDA $4D                   
DA09  D0 3F    BNE $DA4A                 
DA0B  20 B9 F8 JSR $F8B9                 
DA0E  A5 55    LDA $55                   
DA10  C9 08    CMP #$08                  
DA12  D0 04    BNE $DA18                 
DA14  A9 00    LDA #$00                  
DA16  F0 18    BEQ $DA30                 

loc_DA18:  ; xrefs(1): $DA12
DA18  A5 2D    LDA $2D                   
DA1A  29 1F    AND #$1F                  
DA1C  C9 1F    CMP #$1F                  
DA1E  D0 16    BNE $DA36                 
DA20  A5 55    LDA $55                   
DA22  C9 10    CMP #$10                  
DA24  F0 0C    BEQ $DA32                 
DA26  C9 13    CMP #$13                  
DA28  D0 04    BNE $DA2E                 
DA2A  A9 10    LDA #$10                  
DA2C  D0 02    BNE $DA30                 

loc_DA2E:  ; xrefs(1): $DA28
DA2E  A9 0F    LDA #$0F                  

loc_DA30:  ; xrefs(2): $DA16 $DA2C
DA30  85 55    STA $55                   

loc_DA32:  ; xrefs(1): $DA24
DA32  A9 1D    LDA #$1D                  
DA34  D0 02    BNE $DA38                 

loc_DA36:  ; xrefs(1): $DA1E
DA36  A9 19    LDA #$19                  

loc_DA38:  ; xrefs(1): $DA34
DA38  85 02    STA $02                   
DA3A  20 05 E1 JSR $E105                 
DA3D  20 78 C5 JSR $C578                 
DA40  A9 10    LDA #$10                  
DA42  85 F0    STA $F0                   
DA44  20 DA C5 JSR $C5DA                 
DA47  4C 35 C5 JMP $C535                 

loc_DA4A:  ; xrefs(1): $DA09
DA4A  29 07    AND #$07                  
DA4C  D0 03    BNE $DA51                 
DA4E  EE 52 07 INC $0752                 

loc_DA51:  ; xrefs(1): $DA4C
DA51  60       RTS                       

sub_DA52:  ; xrefs(1): $C9C1
DA52  20 55 E2 JSR $E255                 
DA55  20 82 C8 JSR $C882                 
DA58  AD 53 07 LDA $0753                 
DA5B  F0 0B    BEQ $DA68                 
DA5D  A5 FD    LDA $FD                   
DA5F  D0 12    BNE $DA73                 
DA61  A5 04    LDA $04                   
DA63  29 10    AND #$10                  
DA65  D0 0C    BNE $DA73                 
DA67  60       RTS                       

loc_DA68:  ; xrefs(1): $DA5B
DA68  A5 04    LDA $04                   
DA6A  29 10    AND #$10                  
DA6C  F0 42    BEQ $DAB0                 
DA6E  AD 52 07 LDA $0752                 
DA71  F0 09    BEQ $DA7C                 

loc_DA73:  ; xrefs(2): $DA5F $DA65
DA73  A9 00    LDA #$00                  
DA75  8D 52 07 STA $0752                 
DA78  8D 53 07 STA $0753                 
DA7B  60       RTS                       

loc_DA7C:  ; xrefs(1): $DA71
DA7C  A5 4D    LDA $4D                   
DA7E  6A       ROR A                     
DA7F  A9 47    LDA #$47                  
DA81  90 1E    BCC $DAA1                 
DA83  A9 00    LDA #$00                  
DA85  85 2D    STA $2D                   
DA87  8D A0 05 STA $05A0                 
DA8A  85 55    STA $55                   
DA8C  20 05 E1 JSR $E105                 
DA8F  20 78 C5 JSR $C578                 
DA92  20 DA C5 JSR $C5DA                 
DA95  A9 10    LDA #$10                  
DA97  85 F0    STA $F0                   
DA99  20 35 C5 JSR $C535                 
DA9C  A9 43    LDA #$43                  
DA9E  85 02    STA $02                   
DAA0  60       RTS                       

loc_DAA1:  ; xrefs(1): $DA81
DAA1  85 02    STA $02                   
DAA3  A9 0F    LDA #$0F                  
DAA5  85 F0    STA $F0                   
DAA7  A9 03    LDA #$03                  
DAA9  85 F1    STA $F1                   
DAAB  A9 80    LDA #$80                  
DAAD  85 4D    STA $4D                   
DAAF  60       RTS                       

loc_DAB0:  ; xrefs(1): $DA6C
DAB0  A5 04    LDA $04                   
DAB2  29 20    AND #$20                  
DAB4  F0 06    BEQ $DABC                 
DAB6  A9 02    LDA #$02                  
DAB8  85 F1    STA $F1                   
DABA  E6 4D    INC $4D                   

loc_DABC:  ; xrefs(1): $DAB4
DABC  A5 4D    LDA $4D                   
DABE  6A       ROR A                     
DABF  A9 80    LDA #$80                  
DAC1  90 02    BCC $DAC5                 
DAC3  A9 90    LDA #$90                  

loc_DAC5:  ; xrefs(1): $DAC1
DAC5  8D 04 02 STA $0204                 
DAC8  A9 60    LDA #$60                  
DACA  8D 07 02 STA $0207                 
DACD  A9 1B    LDA #$1B                  
DACF  8D 05 02 STA $0205                 
DAD2  A9 00    LDA #$00                  
DAD4  8D 06 02 STA $0206                 
DAD7  60       RTS                       

sub_DAD8:  ; xrefs(11): $D1A7 $D7AC $D86E $D8D2 $D9C4 $DB05 $E0D4 $E362 $E3F6 $E4F6
DAD8  A9 00    LDA #$00                  
DADA  85 4C    STA $4C                   
DADC  85 4D    STA $4D                   
DADE  85 4E    STA $4E                   
DAE0  85 4F    STA $4F                   
DAE2  60       RTS                       

sub_DAE3:  ; xrefs(1): $C9C1
DAE3  A9 08    LDA #$08                  
DAE5  A0 5E    LDY #$5E                  
DAE7  20 25 C9 JSR $C925                 
DAEA  A9 5C    LDA #$5C                  
DAEC  85 42    STA $42                   
DAEE  A9 70    LDA #$70                  
DAF0  85 44    STA $44                   
DAF2  A5 55    LDA $55                   
DAF4  D0 05    BNE $DAFB                 
DAF6  A9 1D    LDA #$1D                  
DAF8  85 02    STA $02                   
DAFA  60       RTS                       

loc_DAFB:  ; xrefs(1): $DAF4
DAFB  20 C9 C5 JSR $C5C9                 
DAFE  A9 13    LDA #$13                  
DB00  20 8C EF JSR $EF8C                 
DB03  E6 02    INC $02                   
DB05  20 D8 DA JSR $DAD8                 
DB08  A9 60    LDA #$60                  
DB0A  A0 83    LDY #$83                  
DB0C  20 B1 E9 JSR $E9B1                 
DB0F  A9 F8    LDA #$F8                  
DB11  A2 07    LDX #$07                  

loc_DB13:  ; xrefs(1): $DB17
DB13  9D BA 05 STA $05BA,X               
DB16  CA       DEX                       
DB17  10 FA    BPL $DB13                 
DB19  20 61 F8 JSR $F861                 
DB1C  A9 08    LDA #$08                  
DB1E  8D BA 05 STA $05BA                 
DB21  8D BB 05 STA $05BB                 
DB24  8D BC 05 STA $05BC                 
DB27  A9 FE    LDA #$FE                  
DB29  8D AB 05 STA $05AB                 
DB2C  20 49 F8 JSR $F849                 
DB2F  A9 01    LDA #$01                  
DB31  8D 00 A0 STA $A000                 
DB34  20 7D DD JSR $DD7D                 
DB37  D0 06    BNE $DB3F                 
DB39  A9 16    LDA #$16                  
DB3B  85 F1    STA $F1                   
DB3D  D0 04    BNE $DB43                 

loc_DB3F:  ; xrefs(1): $DB37
DB3F  A9 0C    LDA #$0C                  
DB41  85 F0    STA $F0                   

loc_DB43:  ; xrefs(1): $DB3D
DB43  A9 EF    LDA #$EF                  
DB45  85 0B    STA $0B                   
DB47  4C 35 C5 JMP $C535                 

sub_DB4A:  ; xrefs(1): $C9C1
DB4A  20 9A CA JSR $CA9A                 
DB4D  E6 4C    INC $4C                   
DB4F  A5 4C    LDA $4C                   
DB51  C9 08    CMP #$08                  
DB53  90 32    BCC $DB87                 
DB55  C9 10    CMP #$10                  
DB57  90 32    BCC $DB8B                 
DB59  C9 18    CMP #$18                  
DB5B  90 37    BCC $DB94                 
DB5D  C9 20    CMP #$20                  
DB5F  90 38    BCC $DB99                 
DB61  D0 09    BNE $DB6C                 
DB63  A9 01    LDA #$01                  
DB65  A0 FF    LDY #$FF                  
DB67  20 6D F8 JSR $F86D                 
DB6A  D0 2D    BNE $DB99                 

loc_DB6C:  ; xrefs(1): $DB61
DB6C  A5 26    LDA $26                   
DB6E  D0 29    BNE $DB99                 
DB70  20 78 C5 JSR $C578                 
DB73  20 DA C5 JSR $C5DA                 
DB76  20 35 C5 JSR $C535                 
DB79  A9 00    LDA #$00                  
DB7B  8D 00 A0 STA $A000                 
DB7E  A9 10    LDA #$10                  
DB80  85 F0    STA $F0                   
DB82  A9 1D    LDA #$1D                  
DB84  85 02    STA $02                   
DB86  60       RTS                       

loc_DB87:  ; xrefs(1): $DB53
DB87  A9 10    LDA #$10                  
DB89  D0 10    BNE $DB9B                 

loc_DB8B:  ; xrefs(1): $DB57
DB8B  A9 11    LDA #$11                  
DB8D  20 9B DB JSR $DB9B                 
DB90  A9 13    LDA #$13                  
DB92  D0 07    BNE $DB9B                 

loc_DB94:  ; xrefs(1): $DB5B
DB94  A9 12    LDA #$12                  
DB96  20 9B DB JSR $DB9B                 

loc_DB99:  ; xrefs(3): $DB5F $DB6A $DB6E
DB99  A9 13    LDA #$13                  

sub_DB9B:  ; xrefs(4): $DB89 $DB8D $DB92 $DB96
DB9B  A0 80    LDY #$80                  
DB9D  84 90    STY $90                   
DB9F  A0 B0    LDY #$B0                  
DBA1  84 92    STY $92                   
DBA3  A0 00    LDY #$00                  
DBA5  84 91    STY $91                   
DBA7  84 93    STY $93                   
DBA9  84 9E    STY $9E                   
DBAB  4C E5 F3 JMP $F3E5                 

sub_DBAE:  ; xrefs(1): $C9C1
DBAE  20 9A CA JSR $CA9A                 
DBB1  20 82 C8 JSR $C882                 
DBB4  20 65 DD JSR $DD65                 
DBB7  18       CLC                       
DBB8  A5 0B    LDA $0B                   
DBBA  4A       LSR A                     
DBBB  4A       LSR A                     
DBBC  4A       LSR A                     
DBBD  85 94    STA $94                   
DBBF  18       CLC                       
DBC0  A9 B0    LDA #$B0                  
DBC2  65 94    ADC $94                   
DBC4  85 92    STA $92                   
DBC6  A9 80    LDA #$80                  
DBC8  85 90    STA $90                   
DBCA  A9 00    LDA #$00                  
DBCC  85 91    STA $91                   
DBCE  85 93    STA $93                   
DBD0  85 9E    STA $9E                   
DBD2  A5 0C    LDA $0C                   
DBD4  4A       LSR A                     
DBD5  4A       LSR A                     
DBD6  A9 0E    LDA #$0E                  
DBD8  69 00    ADC #$00                  
DBDA  A0 00    LDY #$00                  
DBDC  20 E5 F3 JSR $F3E5                 
DBDF  A5 4F    LDA $4F                   
DBE1  D0 45    BNE $DC28                 
DBE3  20 7D DD JSR $DD7D                 
DBE6  D0 11    BNE $DBF9                 
DBE8  A5 0C    LDA $0C                   
DBEA  6A       ROR A                     
DBEB  B0 2B    BCS $DC18                 
DBED  CE AB 05 DEC $05AB                 
DBF0  D0 26    BNE $DC18                 
DBF2  EE AB 05 INC $05AB                 
DBF5  A5 0B    LDA $0B                   
DBF7  F0 2F    BEQ $DC28                 

loc_DBF9:  ; xrefs(1): $DBE6
DBF9  A5 04    LDA $04                   
DBFB  29 10    AND #$10                  
DBFD  F0 19    BEQ $DC18                 
DBFF  A5 0B    LDA $0B                   
DC01  F0 18    BEQ $DC1B                 
DC03  C9 20    CMP #$20                  
DC05  90 0E    BCC $DC15                 
DC07  20 7D DD JSR $DD7D                 
DC0A  F0 09    BEQ $DC15                 
DC0C  A9 E0    LDA #$E0                  
DC0E  20 E5 DC JSR $DCE5                 
DC11  A9 20    LDA #$20                  
DC13  85 0B    STA $0B                   

loc_DC15:  ; xrefs(2): $DC05 $DC0A
DC15  4C BB DC JMP $DCBB                 

loc_DC18:  ; xrefs(3): $DBEB $DBF0 $DBFD
DC18  4C 80 DC JMP $DC80                 

loc_DC1B:  ; xrefs(1): $DC01
DC1B  A5 2D    LDA $2D                   
DC1D  A6 4C    LDX $4C                   

loc_DC1F:  ; xrefs(1): $DC21
DC1F  6A       ROR A                     
DC20  CA       DEX                       
DC21  10 FC    BPL $DC1F                 
DC23  90 03    BCC $DC28                 
DC25  4C BB DC JMP $DCBB                 

loc_DC28:  ; xrefs(3): $DBE1 $DBF7 $DC23
DC28  20 7D DD JSR $DD7D                 
DC2B  D0 1A    BNE $DC47                 
DC2D  A5 0C    LDA $0C                   
DC2F  29 3F    AND #$3F                  
DC31  D0 13    BNE $DC46                 
DC33  A4 4C    LDY $4C                   
DC35  C8       INY                       
DC36  E6 4F    INC $4F                   
DC38  A5 4F    LDA $4F                   
DC3A  C9 06    CMP #$06                  
DC3C  90 1F    BCC $DC5D                 
DC3E  C9 0A    CMP #$0A                  
DC40  F0 2B    BEQ $DC6D                 
DC42  C9 0E    CMP #$0E                  
DC44  B0 31    BCS $DC77                 

loc_DC46:  ; xrefs(1): $DC31
DC46  60       RTS                       

loc_DC47:  ; xrefs(1): $DC2B
DC47  A4 4C    LDY $4C                   
DC49  C8       INY                       
DC4A  E6 4F    INC $4F                   
DC4C  A5 4F    LDA $4F                   
DC4E  C9 06    CMP #$06                  
DC50  90 0B    BCC $DC5D                 
DC52  F0 0E    BEQ $DC62                 
DC54  C9 20    CMP #$20                  
DC56  F0 15    BEQ $DC6D                 
DC58  C9 C0    CMP #$C0                  
DC5A  B0 1B    BCS $DC77                 
DC5C  60       RTS                       

loc_DC5D:  ; xrefs(2): $DC3C $DC50
DC5D  84 4D    STY $4D                   
DC5F  4C 84 DD JMP $DD84                 

loc_DC62:  ; xrefs(1): $DC52
DC62  A9 03    LDA #$03                  
DC64  85 F1    STA $F1                   
DC66  A9 0F    LDA #$0F                  
DC68  85 F0    STA $F0                   
DC6A  4C 1B DD JMP $DD1B                 

loc_DC6D:  ; xrefs(2): $DC40 $DC56
DC6D  20 61 F8 JSR $F861                 
DC70  A9 03    LDA #$03                  
DC72  A0 08    LDY #$08                  
DC74  4C 6D F8 JMP $F86D                 

loc_DC77:  ; xrefs(2): $DC44 $DC5A
DC77  A9 3D    LDA #$3D                  
DC79  85 F1    STA $F1                   
DC7B  A9 32    LDA #$32                  
DC7D  85 02    STA $02                   
DC7F  60       RTS                       

loc_DC80:  ; xrefs(1): $DC18
DC80  A5 0B    LDA $0B                   
DC82  D0 37    BNE $DCBB                 
DC84  20 7D DD JSR $DD7D                 
DC87  D0 06    BNE $DC8F                 
DC89  A9 06    LDA #$06                  
DC8B  85 4E    STA $4E                   
DC8D  D0 2C    BNE $DCBB                 

loc_DC8F:  ; xrefs(1): $DC87
DC8F  A0 01    LDY #$01                  
DC91  A5 04    LDA $04                   
DC93  29 20    AND #$20                  
DC95  D0 16    BNE $DCAD                 
DC97  A5 04    LDA $04                   
DC99  A0 01    LDY #$01                  
DC9B  6A       ROR A                     
DC9C  B0 0F    BCS $DCAD                 
DC9E  A0 FF    LDY #$FF                  
DCA0  6A       ROR A                     
DCA1  B0 0A    BCS $DCAD                 
DCA3  A0 03    LDY #$03                  
DCA5  6A       ROR A                     
DCA6  B0 05    BCS $DCAD                 
DCA8  A0 FD    LDY #$FD                  
DCAA  6A       ROR A                     
DCAB  90 0E    BCC $DCBB                 

loc_DCAD:  ; xrefs(4): $DC95 $DC9C $DCA1 $DCA6
DCAD  A9 23    LDA #$23                  
DCAF  85 F1    STA $F1                   
DCB1  18       CLC                       
DCB2  98       TYA                       
DCB3  65 4E    ADC $4E                   
DCB5  C9 06    CMP #$06                  
DCB7  B0 02    BCS $DCBB                 
DCB9  85 4E    STA $4E                   

loc_DCBB:  ; xrefs(6): $DC15 $DC25 $DC82 $DC8D $DCAB $DCB7
DCBB  A6 4E    LDX $4E                   
DCBD  BC 5E DD LDY $DD5E,X               
DCC0  84 4C    STY $4C                   
DCC2  B9 58 DD LDA $DD58,Y               
DCC5  85 55    STA $55                   
DCC7  A9 00    LDA #$00                  
DCC9  85 2E    STA $2E                   
DCCB  A5 0B    LDA $0B                   
DCCD  F0 1F    BEQ $DCEE                 
DCCF  C6 0B    DEC $0B                   
DCD1  C9 EF    CMP #$EF                  
DCD3  D0 04    BNE $DCD9                 
DCD5  A9 E0    LDA #$E0                  
DCD7  D0 0C    BNE $DCE5                 

loc_DCD9:  ; xrefs(1): $DCD3
DCD9  C9 20    CMP #$20                  
DCDB  D0 07    BNE $DCE4                 
DCDD  20 65 F8 JSR $F865                 
DCE0  A9 0F    LDA #$0F                  
DCE2  D0 01    BNE $DCE5                 

loc_DCE4:  ; xrefs(1): $DCDB
DCE4  60       RTS                       

sub_DCE5:  ; xrefs(3): $DC0E $DCD7 $DCE2
DCE5  05 27    ORA $27                   
DCE7  85 27    STA $27                   
DCE9  A9 06    LDA #$06                  
DCEB  85 26    STA $26                   
DCED  60       RTS                       

loc_DCEE:  ; xrefs(1): $DCCD
DCEE  A5 4D    LDA $4D                   
DCF0  C9 05    CMP #$05                  
DCF2  F0 39    BEQ $DD2D                 
DCF4  A5 26    LDA $26                   
DCF6  D0 34    BNE $DD2C                 
DCF8  A9 01    LDA #$01                  
DCFA  C5 28    CMP $28                   
DCFC  F0 0F    BEQ $DD0D                 
DCFE  85 28    STA $28                   
DD00  85 25    STA $25                   
DD02  A9 07    LDA #$07                  
DD04  05 27    ORA $27                   
DD06  85 27    STA $27                   
DD08  A9 03    LDA #$03                  
DD0A  85 26    STA $26                   
DD0C  60       RTS                       

loc_DD0D:  ; xrefs(1): $DCFC
DD0D  E6 4D    INC $4D                   
DD0F  A4 4D    LDY $4D                   
DD11  98       TYA                       
DD12  20 84 DD JSR $DD84                 
DD15  A5 4D    LDA $4D                   
DD17  C9 05    CMP #$05                  
DD19  D0 11    BNE $DD2C                 

loc_DD1B:  ; xrefs(1): $DC6A
DD1B  A9 40    LDA #$40                  
DD1D  A0 83    LDY #$83                  
DD1F  20 B1 E9 JSR $E9B1                 
DD22  A9 17    LDA #$17                  
DD24  05 27    ORA $27                   
DD26  85 27    STA $27                   
DD28  A9 06    LDA #$06                  
DD2A  85 26    STA $26                   

loc_DD2C:  ; xrefs(2): $DCF6 $DD19
DD2C  60       RTS                       

loc_DD2D:  ; xrefs(1): $DCF2
DD2D  20 7D DD JSR $DD7D                 
DD30  F0 19    BEQ $DD4B                 
DD32  A5 0C    LDA $0C                   
DD34  29 02    AND #$02                  
DD36  D0 13    BNE $DD4B                 
DD38  BD 4C DD LDA $DD4C,X               
DD3B  85 92    STA $92                   
DD3D  BD 52 DD LDA $DD52,X               
DD40  85 90    STA $90                   
DD42  A9 0B    LDA #$0B                  
DD44  A0 00    LDY #$00                  
DD46  84 9E    STY $9E                   
DD48  20 E2 F6 JSR $F6E2                 

loc_DD4B:  ; xrefs(2): $DD30 $DD36
DD4B  60       RTS                       

; ---- data $DD4C-$DD64 (25 bytes) ----
DD4C  1F 4F 1F 7F 4F 7F 08 58 A8 08 58 A8 0A 03 04 06  |.O..O..X..X.....
DD5C  01 0F 00 04 01 02 04 03 05                       |.........

sub_DD65:  ; xrefs(1): $DBB4
DD65  20 7D DD JSR $DD7D                 
DD68  D0 12    BNE $DD7C                 
DD6A  A5 0C    LDA $0C                   
DD6C  0A       ASL A                     
DD6D  0A       ASL A                     
DD6E  29 E0    AND #$E0                  
DD70  85 90    STA $90                   
DD72  A5 09    LDA $09                   
DD74  29 1F    AND #$1F                  
DD76  09 20    ORA #$20                  
DD78  05 90    ORA $90                   
DD7A  85 09    STA $09                   

loc_DD7C:  ; xrefs(1): $DD68
DD7C  60       RTS                       

sub_DD7D:  ; xrefs(7): $DB34 $DBE3 $DC07 $DC28 $DC84 $DD2D $DD65
DD7D  A5 2D    LDA $2D                   
DD7F  29 1F    AND #$1F                  
DD81  C9 1F    CMP #$1F                  
DD83  60       RTS                       

sub_DD84:  ; xrefs(2): $DC5F $DD12
DD84  48       PHA                       
DD85  AA       TAX                       
DD86  98       TYA                       
DD87  48       PHA                       
DD88  20 DE DD JSR $DDDE                 
DD8B  B9 35 DE LDA $DE35,Y               
DD8E  A8       TAY                       
DD8F  8A       TXA                       
DD90  0A       ASL A                     
DD91  0A       ASL A                     
DD92  0A       ASL A                     
DD93  AA       TAX                       
DD94  BD EF DD LDA $DDEF,X               
DD97  85 9A    STA $9A                   
DD99  BD F0 DD LDA $DDF0,X               
DD9C  85 9B    STA $9B                   
DD9E  BD F1 DD LDA $DDF1,X               
DDA1  85 9C    STA $9C                   
DDA3  BD F2 DD LDA $DDF2,X               
DDA6  85 9D    STA $9D                   
DDA8  BD F3 DD LDA $DDF3,X               
DDAB  85 9E    STA $9E                   
DDAD  BD F4 DD LDA $DDF4,X               
DDB0  85 9F    STA $9F                   
DDB2  BD F5 DD LDA $DDF5,X               
DDB5  85 91    STA $91                   
DDB7  20 B3 DE JSR $DEB3                 
DDBA  68       PLA                       
DDBB  A8       TAY                       
DDBC  68       PLA                       
DDBD  0A       ASL A                     
DDBE  AA       TAX                       
DDBF  BD 27 DE LDA $DE27,X               
DDC2  85 9E    STA $9E                   
DDC4  BD 28 DE LDA $DE28,X               
DDC7  85 9F    STA $9F                   
DDC9  20 DE DD JSR $DDDE                 
DDCC  98       TYA                       
DDCD  20 1F C8 JSR $C81F                 

; ---- jump table $DDD0 (7 entries) ----
DDD0  .word $DE42   ; [00] 
DDD2  .word $DE48   ; [01] 
DDD4  .word $DE4E   ; [02] 
DDD6  .word $DE54   ; [03] 
DDD8  .word $DE5A   ; [04] 
DDDA  .word $DE60   ; [05] 
DDDC  .word $DE3C   ; [06] 

sub_DDDE:  ; xrefs(2): $DD88 $DDC9
DDDE  8A       TXA                       
DDDF  48       PHA                       
DDE0  A5 2D    LDA $2D                   
DDE2  A6 4D    LDX $4D                   

loc_DDE4:  ; xrefs(1): $DDE6
DDE4  6A       ROR A                     
DDE5  CA       DEX                       
DDE6  D0 FC    BNE $DDE4                 
DDE8  90 02    BCC $DDEC                 
DDEA  A0 00    LDY #$00                  

loc_DDEC:  ; xrefs(1): $DDE8
DDEC  68       PLA                       
DDED  AA       TAX                       
DDEE  60       RTS                       

; ---- data $DDEF-$DE3B (77 bytes) ----
DDEF  83 23 C8 83 23 D0 00 00 83 23 C8 83 23 D0 00 00  |.#..#....#..#...
DDFF  83 23 CD 83 23 D5 00 00 83 23 E0 83 23 E8 00 00  |.#..#....#..#...
DE0F  83 23 E5 83 23 ED 00 00 82 23 D3 82 23 DB 80 00  |.#..#....#..#...
DE1F  82 23 D3 82 23 DB 80 00 82 20 82 20 96 20 02 22  |.#..#.... . . ."
DE2F  16 22 4C 21 4C 21 12 00 0C 06 0C 00 0C           |."L!L!.......

sub_DE3C:  ; xrefs(1): $DDD0
DE3C  A0 67    LDY #$67                  
DE3E  A9 E0    LDA #$E0                  
DE40  D0 22    BNE $DE64                 

sub_DE42:  ; xrefs(1): $DDD0
DE42  A0 37    LDY #$37                  
DE44  A9 E0    LDA #$E0                  
DE46  D0 1C    BNE $DE64                 

sub_DE48:  ; xrefs(1): $DDD0
DE48  A0 47    LDY #$47                  
DE4A  A9 DF    LDA #$DF                  
DE4C  D0 16    BNE $DE64                 

sub_DE4E:  ; xrefs(1): $DDD0
DE4E  A0 77    LDY #$77                  
DE50  A9 DF    LDA #$DF                  
DE52  D0 10    BNE $DE64                 

sub_DE54:  ; xrefs(1): $DDD0
DE54  A0 A7    LDY #$A7                  
DE56  A9 DF    LDA #$DF                  
DE58  D0 0A    BNE $DE64                 

sub_DE5A:  ; xrefs(1): $DDD0
DE5A  A0 D7    LDY #$D7                  
DE5C  A9 DF    LDA #$DF                  
DE5E  D0 04    BNE $DE64                 

sub_DE60:  ; xrefs(1): $DDD0
DE60  A0 07    LDY #$07                  
DE62  A9 E0    LDA #$E0                  

loc_DE64:  ; xrefs(6): $DE40 $DE46 $DE4C $DE52 $DE58 $DE5E
DE64  84 90    STY $90                   
DE66  85 91    STA $91                   
DE68  A0 00    LDY #$00                  
DE6A  AE 00 03 LDX $0300                 
DE6D  E8       INX                       
DE6E  20 86 DE JSR $DE86                 
DE71  20 86 DE JSR $DE86                 
DE74  20 86 DE JSR $DE86                 
DE77  A9 00    LDA #$00                  
DE79  9D 00 03 STA $0300,X               
DE7C  CA       DEX                       
DE7D  8E 00 03 STX $0300                 
DE80  A9 FF    LDA #$FF                  
DE82  8D F0 05 STA $05F0                 
DE85  60       RTS                       

sub_DE86:  ; xrefs(3): $DE6E $DE71 $DE74
DE86  20 89 DE JSR $DE89                 

sub_DE89:  ; xrefs(1): $DE86
DE89  A9 88    LDA #$88                  
DE8B  9D 00 03 STA $0300,X               
DE8E  E8       INX                       
DE8F  A5 9F    LDA $9F                   
DE91  9D 00 03 STA $0300,X               
DE94  E8       INX                       
DE95  A5 9E    LDA $9E                   
DE97  9D 00 03 STA $0300,X               
DE9A  E8       INX                       

loc_DE9B:  ; xrefs(1): $DEA5
DE9B  B1 90    LDA ($90),Y               
DE9D  9D 00 03 STA $0300,X               
DEA0  E8       INX                       
DEA1  C8       INY                       
DEA2  98       TYA                       
DEA3  29 07    AND #$07                  
DEA5  D0 F4    BNE $DE9B                 
DEA7  18       CLC                       
DEA8  A5 9E    LDA $9E                   
DEAA  69 20    ADC #$20                  
DEAC  85 9E    STA $9E                   
DEAE  90 02    BCC $DEB2                 
DEB0  E6 9F    INC $9F                   

loc_DEB2:  ; xrefs(1): $DEAE
DEB2  60       RTS                       

sub_DEB3:  ; xrefs(1): $DDB7
DEB3  AE 00 03 LDX $0300                 
DEB6  E8       INX                       
DEB7  A5 9A    LDA $9A                   
DEB9  9D 00 03 STA $0300,X               
DEBC  E8       INX                       
DEBD  A5 9B    LDA $9B                   
DEBF  9D 00 03 STA $0300,X               
DEC2  E8       INX                       
DEC3  A5 9C    LDA $9C                   
DEC5  9D 00 03 STA $0300,X               
DEC8  E8       INX                       
DEC9  20 F0 DE JSR $DEF0                 
DECC  A5 9D    LDA $9D                   
DECE  9D 00 03 STA $0300,X               
DED1  E8       INX                       
DED2  A5 9E    LDA $9E                   
DED4  9D 00 03 STA $0300,X               
DED7  E8       INX                       
DED8  A5 9F    LDA $9F                   
DEDA  9D 00 03 STA $0300,X               
DEDD  E8       INX                       
DEDE  20 F0 DE JSR $DEF0                 
DEE1  A9 00    LDA #$00                  
DEE3  9D 00 03 STA $0300,X               
DEE6  CA       DEX                       
DEE7  8E 00 03 STX $0300                 
DEEA  A9 FF    LDA #$FF                  
DEEC  8D F0 05 STA $05F0                 
DEEF  60       RTS                       

sub_DEF0:  ; xrefs(2): $DEC9 $DEDE
DEF0  A9 03    LDA #$03                  
DEF2  85 90    STA $90                   
DEF4  A5 91    LDA $91                   
DEF6  10 05    BPL $DEFD                 
DEF8  C6 90    DEC $90                   
DEFA  4C 0A DF JMP $DF0A                 

loc_DEFD:  ; xrefs(2): $DEF6 $DF07
DEFD  B9 17 DF LDA $DF17,Y               
DF00  9D 00 03 STA $0300,X               
DF03  E8       INX                       
DF04  C8       INY                       
DF05  C6 90    DEC $90                   
DF07  D0 F4    BNE $DEFD                 
DF09  60       RTS                       

loc_DF0A:  ; xrefs(2): $DEFA $DF14
DF0A  B9 2F DF LDA $DF2F,Y               
DF0D  9D 00 03 STA $0300,X               
DF10  E8       INX                       
DF11  C8       INY                       
DF12  C6 90    DEC $90                   
DF14  D0 F4    BNE $DF0A                 
DF16  60       RTS                       

; ---- data $DF17-$E096 (384 bytes) ----
DF17  33 00 CC F3 F0 FC 77 55 DD F7 F5 FD BB AA EE FB  |3.....wU........
DF27  FA FE FF FF FF FF FF FF 0F 0F 00 00 00 00 5F 5F  |..............__
DF37  55 55 00 00 AF AF AA AA 00 00 FF FF FF FF 00 00  |UU..............
DF47  30 72 72 72 72 72 72 63 72 72 72 01 02 03 03 03  |0rrrrrrcrrr.....
DF57  72 72 01 11 72 72 72 72 12 01 11 11 12 13 22 23  |rr..rrrr......"#
DF67  20 11 21 21 22 23 32 33 00 31 31 31 32 33 00 00  | .!!"#23.11123..
DF77  88 89 8A 8B 8C 8D 8E 8F 98 99 9A 9B 9C 9D 9E 9F  |................
DF87  A8 A9 AA AB AC AD AE AF B8 B9 BA BB BC BD BE BF  |................
DF97  C8 C9 CA CB CC CD CE CF D8 D9 DA DB DC DD DE DF  |................
DFA7  29 08 08 1A 1B 08 08 09 08 1A 1B 2A 2B 18 19 19  |)..........*+...
DFB7  08 2A 2B 19 28 28 00 28 18 19 28 28 28 38 28 38  |.*+.((.(..(((8(8
DFC7  28 28 38 38 00 00 0A 0B 00 38 00 0A 0B 0B 0B 00  |((88.....8......
DFD7  44 55 46 47 00 47 00 00 64 65 54 55 46 47 00 57  |DUFG.G..deTUFG.W
DFE7  74 45 64 65 56 00 57 45 74 45 74 00 00 00 67 45  |tEdeV.WEtEt...gE
DFF7  74 45 74 00 66 77 67 45 74 75 75 76 76 75 67 67  |tEt.fwgEtuuvvugg
E007  62 43 53 43 52 52 52 63 53 53 43 43 40 40 40 40  |bCSCRRRcSSCC@@@@
E017  00 53 43 53 41 42 41 42 00 00 53 53 00 00 00 00  |.SCSABAB..SS....
E027  60 60 61 00 00 73 50 73 70 70 71 51 50 51 73 73  |``a..sPsppqQPQss
E037  6E 6F 00 00 00 00 00 6B 7E 00 00 00 00 00 00 00  |no.....k~.......
E047  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 6C  |...............l
E057  00 00 00 00 00 00 00 6D 00 00 00 00 7B 7C 7C 7D  |.......m....{||}
E067  80 81 82 83 84 85 86 87 90 91 92 93 94 95 96 97  |................
E077  A0 A1 A2 A3 A4 A5 A6 A7 B0 B1 B2 B3 B4 B5 B6 B7  |................
E087  C0 C1 C2 C3 C4 C5 C6 C7 D0 D1 D2 D3 D4 D5 D6 D7  |................

sub_E097:  ; xrefs(1): $C9C1
E097  A9 19    LDA #$19                  
E099  85 02    STA $02                   
E09B  60       RTS                       

sub_E09C:  ; xrefs(1): $C9C1
E09C  20 1F D8 JSR $D81F                 
E09F  20 C9 C5 JSR $C5C9                 
E0A2  A9 15    LDA #$15                  
E0A4  20 8C EF JSR $EF8C                 
E0A7  20 5D EC JSR $EC5D                 
E0AA  A9 46    LDA #$46                  
E0AC  85 95    STA $95                   
E0AE  A9 21    LDA #$21                  
E0B0  85 96    STA $96                   
E0B2  A9 D0    LDA #$D0                  
E0B4  85 97    STA $97                   
E0B6  A9 00    LDA #$00                  
E0B8  85 9E    STA $9E                   
E0BA  85 91    STA $91                   
E0BC  A9 95    LDA #$95                  
E0BE  85 90    STA $90                   
E0C0  20 84 EF JSR $EF84                 
E0C3  20 37 E2 JSR $E237                 
E0C6  A6 55    LDX $55                   
E0C8  BD 23 E2 LDA $E223,X               
E0CB  AA       TAX                       
E0CC  BD 4E E2 LDA $E24E,X               
E0CF  20 8C EF JSR $EF8C                 
E0D2  E6 02    INC $02                   
E0D4  20 D8 DA JSR $DAD8                 
E0D7  A9 20    LDA #$20                  
E0D9  A0 83    LDY #$83                  
E0DB  20 B1 E9 JSR $E9B1                 
E0DE  20 3D F8 JSR $F83D                 
E0E1  20 0A E1 JSR $E10A                 
E0E4  A2 07    LDX #$07                  

loc_E0E6:  ; xrefs(1): $E0F7
E0E6  BD 00 E1 LDA $E100,X               
E0E9  9D 40 07 STA $0740,X               
E0EC  A9 01    LDA #$01                  
E0EE  9D 50 07 STA $0750,X               
E0F1  A9 00    LDA #$00                  
E0F3  9D 60 07 STA $0760,X               
E0F6  CA       DEX                       
E0F7  10 ED    BPL $E0E6                 
E0F9  A9 08    LDA #$08                  
E0FB  85 F0    STA $F0                   
E0FD  4C 35 C5 JMP $C535                 

; ---- data $E100-$E104 (5 bytes) ----
E100  24 1C 10 13 1B                                   |$....

sub_E105:  ; xrefs(11): $D16E $D20C $D24A $D281 $D2ED $D659 $D797 $D7BC $DA3A $DA8C
E105  A9 00    LDA #$00                  
E107  85 7D    STA $7D                   
E109  60       RTS                       

sub_E10A:  ; xrefs(3): $D760 $D9C7 $E0E1
E10A  A9 3F    LDA #$3F                  
E10C  85 7D    STA $7D                   
E10E  A9 3C    LDA #$3C                  
E110  85 75    STA $75                   
E112  A9 80    LDA #$80                  
E114  4C 18 C6 JMP $C618                 

sub_E117:  ; xrefs(1): $C9C1
E117  A5 4D    LDA $4D                   
E119  20 1F C8 JSR $C81F                 

; ---- jump table $E11C (9 entries) ----
E11C  .word $E12E   ; [00] 
E11E  .word $E17C   ; [01] 
E120  .word $E185   ; [02] 
E122  .word $E173   ; [03] 
E124  .word $E1C3   ; [04] 
E126  .word $E173   ; [05] 
E128  .word $E12E   ; [06] 
E12A  .word $E1E8   ; [07] 
E12C  .word $E1F4   ; [08] 

sub_E12E:  ; xrefs(1): $E11C
E12E  20 8C E2 JSR $E28C                 
E131  20 55 E2 JSR $E255                 
E134  A2 07    LDX #$07                  

loc_E136:  ; xrefs(1): $E15B
E136  E0 04    CPX #$04                  
E138  F0 20    BEQ $E15A                 
E13A  8A       TXA                       
E13B  6A       ROR A                     
E13C  B0 0F    BCS $E14D                 
E13E  A9 08    LDA #$08                  
E140  7D 60 07 ADC $0760,X               
E143  9D 60 07 STA $0760,X               
E146  90 12    BCC $E15A                 
E148  FE 50 07 INC $0750,X               
E14B  B0 0D    BCS $E15A                 

loc_E14D:  ; xrefs(1): $E13C
E14D  BD 60 07 LDA $0760,X               
E150  E9 08    SBC #$08                  
E152  9D 60 07 STA $0760,X               
E155  B0 03    BCS $E15A                 
E157  DE 50 07 DEC $0750,X               

loc_E15A:  ; xrefs(4): $E138 $E146 $E14B $E155
E15A  CA       DEX                       
E15B  10 D9    BPL $E136                 
E15D  18       CLC                       
E15E  A5 4C    LDA $4C                   
E160  69 08    ADC #$08                  
E162  85 4C    STA $4C                   
E164  90 06    BCC $E16C                 
E166  A9 80    LDA #$80                  
E168  85 4C    STA $4C                   
E16A  E6 4D    INC $4D                   

loc_E16C:  ; xrefs(1): $E164
E16C  60       RTS                       

loc_E16D:  ; xrefs(6): $E179 $E182 $E193 $E1C0 $E1CE $E1E5
E16D  20 8C E2 JSR $E28C                 
E170  4C 55 E2 JMP $E255                 

sub_E173:  ; xrefs(1): $E11C
E173  C6 4C    DEC $4C                   
E175  D0 02    BNE $E179                 
E177  E6 4D    INC $4D                   

loc_E179:  ; xrefs(1): $E175
E179  4C 6D E1 JMP $E16D                 

sub_E17C:  ; xrefs(1): $E11C
E17C  A5 FD    LDA $FD                   
E17E  F0 02    BEQ $E182                 
E180  E6 4D    INC $4D                   

loc_E182:  ; xrefs(1): $E17E
E182  4C 6D E1 JMP $E16D                 

sub_E185:  ; xrefs(1): $E11C
E185  AD C6 05 LDA $05C6                 
E188  0D C7 05 ORA $05C7                 
E18B  D0 09    BNE $E196                 
E18D  A9 80    LDA #$80                  
E18F  85 4C    STA $4C                   
E191  E6 4D    INC $4D                   
E193  4C 6D E1 JMP $E16D                 

loc_E196:  ; xrefs(1): $E18B
E196  A9 01    LDA #$01                  
E198  AC C7 05 LDY $05C7                 
E19B  F0 02    BEQ $E19F                 
E19D  A9 0A    LDA #$0A                  

loc_E19F:  ; xrefs(1): $E19B
E19F  85 90    STA $90                   
E1A1  38       SEC                       
E1A2  AD C6 05 LDA $05C6                 
E1A5  E5 90    SBC $90                   
E1A7  8D C6 05 STA $05C6                 
E1AA  B0 03    BCS $E1AF                 
E1AC  CE C7 05 DEC $05C7                 

loc_E1AF:  ; xrefs(1): $E1AA
E1AF  A5 90    LDA $90                   
E1B1  A0 00    LDY #$00                  
E1B3  20 D3 E3 JSR $E3D3                 
E1B6  A5 0C    LDA $0C                   
E1B8  29 07    AND #$07                  
E1BA  D0 04    BNE $E1C0                 
E1BC  A9 04    LDA #$04                  
E1BE  85 F1    STA $F1                   

loc_E1C0:  ; xrefs(1): $E1BA
E1C0  4C 6D E1 JMP $E16D                 

sub_E1C3:  ; xrefs(1): $E11C
E1C3  AD C5 05 LDA $05C5                 
E1C6  D0 09    BNE $E1D1                 
E1C8  A9 80    LDA #$80                  
E1CA  85 4C    STA $4C                   
E1CC  E6 4D    INC $4D                   
E1CE  4C 6D E1 JMP $E16D                 

loc_E1D1:  ; xrefs(1): $E1C6
E1D1  A5 00    LDA $00                   
E1D3  29 0F    AND #$0F                  
E1D5  D0 0E    BNE $E1E5                 
E1D7  A9 04    LDA #$04                  
E1D9  85 F1    STA $F1                   
E1DB  CE C5 05 DEC $05C5                 
E1DE  A9 2C    LDA #$2C                  
E1E0  A0 01    LDY #$01                  
E1E2  20 D3 E3 JSR $E3D3                 

loc_E1E5:  ; xrefs(1): $E1D5
E1E5  4C 6D E1 JMP $E16D                 

sub_E1E8:  ; xrefs(1): $E11C
E1E8  A9 01    LDA #$01                  
E1EA  A0 FF    LDY #$FF                  
E1EC  20 6D F8 JSR $F86D                 
E1EF  E6 4D    INC $4D                   
E1F1  4C 8C E2 JMP $E28C                 

sub_E1F4:  ; xrefs(1): $E11C
E1F4  20 06 F8 JSR $F806                 
E1F7  A5 26    LDA $26                   
E1F9  F0 08    BEQ $E203                 
E1FB  A9 00    LDA #$00                  
E1FD  8D F0 05 STA $05F0                 
E200  4C 55 E2 JMP $E255                 

loc_E203:  ; xrefs(1): $E1F9
E203  20 78 C5 JSR $C578                 
E206  20 05 E1 JSR $E105                 
E209  20 DA C5 JSR $C5DA                 
E20C  20 35 C5 JSR $C535                 
E20F  A6 55    LDX $55                   
E211  BD 23 E2 LDA $E223,X               
E214  20 1F C8 JSR $C81F                 

; ---- jump table $E217 (6 entries) ----
E217  .word $E264   ; [00] 
E219  .word $E26D   ; [01] 
E21B  .word $E271   ; [02] 
E21D  .word $E275   ; [03] 
E21F  .word $E279   ; [04] 
E221  .word $E27D   ; [05] 

; ---- data $E223-$E236 (20 bytes) ----
E223  00 05 05 02 03 03 04 04 00 02 01 01 04 05 01 05  |................
E233  05 03 02 05                                      |....

sub_E237:  ; xrefs(3): $D6DB $D9B8 $E0C3
E237  A9 20    LDA #$20                  
E239  20 8C EF JSR $EF8C                 
E23C  A6 55    LDX $55                   
E23E  BD 23 E2 LDA $E223,X               
E241  AA       TAX                       
E242  BD 48 E2 LDA $E248,X               
E245  4C 8C EF JMP $EF8C                 

; ---- data $E248-$E254 (13 bytes) ----
E248  21 25 27 23 24 22 28 29 2A 2B 2C 2D 2E           |!%'#$"()*+,-.

sub_E255:  ; xrefs(6): $D77E $DA02 $DA52 $E131 $E170 $E200
E255  A5 0C    LDA $0C                   
E257  29 03    AND #$03                  
E259  D0 08    BNE $E263                 
E25B  EE 64 07 INC $0764                 
E25E  D0 03    BNE $E263                 
E260  EE 54 07 INC $0754                 

loc_E263:  ; xrefs(2): $E259 $E25E
E263  60       RTS                       

sub_E264:  ; xrefs(1): $E217
E264  A9 01    LDA #$01                  
E266  85 55    STA $55                   
E268  A9 19    LDA #$19                  
E26A  85 02    STA $02                   
E26C  60       RTS                       

sub_E26D:  ; xrefs(1): $E217
E26D  A9 01    LDA #$01                  
E26F  D0 0E    BNE $E27F                 

sub_E271:  ; xrefs(1): $E217
E271  A9 02    LDA #$02                  
E273  D0 0A    BNE $E27F                 

sub_E275:  ; xrefs(1): $E217
E275  A9 04    LDA #$04                  
E277  D0 06    BNE $E27F                 

sub_E279:  ; xrefs(1): $E217
E279  A9 08    LDA #$08                  
E27B  D0 02    BNE $E27F                 

sub_E27D:  ; xrefs(1): $E217
E27D  A9 10    LDA #$10                  

loc_E27F:  ; xrefs(4): $E26F $E273 $E277 $E27B
E27F  05 2D    ORA $2D                   
E281  85 2D    STA $2D                   
E283  A9 19    LDA #$19                  
E285  85 02    STA $02                   
E287  60       RTS                       

; ---- data $E288-$E28B (4 bytes) ----
E288  A9 20 D0 F9                                      |. ..

sub_E28C:  ; xrefs(3): $E12E $E16D $E1F1
E28C  20 5D EC JSR $EC5D                 
E28F  AC 00 03 LDY $0300                 
E292  A9 21    LDA #$21                  
E294  99 02 03 STA $0302,Y               
E297  A9 D0    LDA #$D0                  
E299  99 03 03 STA $0303,Y               
E29C  A9 30    LDA #$30                  
E29E  85 9E    STA $9E                   
E2A0  A9 00    LDA #$00                  
E2A2  85 9F    STA $9F                   
E2A4  20 F8 E2 JSR $E2F8                 
E2A7  A9 00    LDA #$00                  
E2A9  A2 08    LDX #$08                  

loc_E2AB:  ; xrefs(1): $E2BC
E2AB  AC C5 05 LDY $05C5                 
E2AE  F0 09    BEQ $E2B9                 
E2B0  EC C5 05 CPX $05C5                 
E2B3  F0 02    BEQ $E2B7                 
E2B5  B0 02    BCS $E2B9                 

loc_E2B7:  ; xrefs(1): $E2B3
E2B7  A9 7B    LDA #$7B                  

loc_E2B9:  ; xrefs(2): $E2AE $E2B5
E2B9  95 97    STA $97,X                 
E2BB  CA       DEX                       
E2BC  10 ED    BPL $E2AB                 
E2BE  AC 00 03 LDY $0300                 
E2C1  A9 22    LDA #$22                  
E2C3  99 02 03 STA $0302,Y               
E2C6  A9 50    LDA #$50                  
E2C8  99 03 03 STA $0303,Y               
E2CB  20 F8 E2 JSR $E2F8                 
E2CE  AD C6 05 LDA $05C6                 
E2D1  85 90    STA $90                   
E2D3  AD C7 05 LDA $05C7                 
E2D6  85 91    STA $91                   
E2D8  A9 00    LDA #$00                  
E2DA  85 92    STA $92                   
E2DC  20 6C EC JSR $EC6C                 
E2DF  AC 00 03 LDY $0300                 
E2E2  A9 22    LDA #$22                  
E2E4  99 02 03 STA $0302,Y               
E2E7  A9 0F    LDA #$0F                  
E2E9  99 03 03 STA $0303,Y               
E2EC  A9 30    LDA #$30                  
E2EE  85 9E    STA $9E                   

loc_E2F0:  ; xrefs(1): $E36E
E2F0  A9 00    LDA #$00                  
E2F2  85 9F    STA $9F                   
E2F4  A9 EF    LDA #$EF                  
E2F6  85 98    STA $98                   

sub_E2F8:  ; xrefs(2): $E2A4 $E2CB
E2F8  AC 00 03 LDY $0300                 
E2FB  A9 88    LDA #$88                  
E2FD  99 01 03 STA $0301,Y               
E300  A5 98    LDA $98                   
E302  99 04 03 STA $0304,Y               
E305  A5 99    LDA $99                   
E307  99 05 03 STA $0305,Y               
E30A  A5 9A    LDA $9A                   
E30C  99 06 03 STA $0306,Y               
E30F  A5 9B    LDA $9B                   
E311  99 07 03 STA $0307,Y               
E314  A5 9C    LDA $9C                   
E316  99 08 03 STA $0308,Y               
E319  A5 9D    LDA $9D                   
E31B  99 09 03 STA $0309,Y               
E31E  A5 9E    LDA $9E                   
E320  99 0A 03 STA $030A,Y               
E323  A5 9F    LDA $9F                   
E325  99 0B 03 STA $030B,Y               
E328  A9 00    LDA #$00                  
E32A  99 0C 03 STA $030C,Y               
E32D  18       CLC                       
E32E  98       TYA                       
E32F  69 0B    ADC #$0B                  

sub_E331:  ; xrefs(1): $D5C2
E331  8D 00 03 STA $0300                 
E334  A9 FF    LDA #$FF                  
E336  8D F0 05 STA $05F0                 
E339  60       RTS                       

sub_E33A:  ; xrefs(1): $C9C1
E33A  20 78 C5 JSR $C578                 
E33D  20 B0 C5 JSR $C5B0                 
E340  20 9D E3 JSR $E39D                 
E343  A9 0C    LDA #$0C                  
E345  20 18 C6 JSR $C618                 
E348  A5 08    LDA $08                   
E34A  29 FC    AND #$FC                  
E34C  85 08    STA $08                   
E34E  A9 0F    LDA #$0F                  
E350  20 DC C5 JSR $C5DC                 
E353  20 F9 C5 JSR $C5F9                 
E356  A9 18    LDA #$18                  
E358  A0 1A    LDY #$1A                  
E35A  20 25 C9 JSR $C925                 
E35D  A9 39    LDA #$39                  
E35F  20 8C EF JSR $EF8C                 
E362  20 D8 DA JSR $DAD8                 
E365  A9 04    LDA #$04                  
E367  85 4D    STA $4D                   
E369  A2 1F    LDX #$1F                  
E36B  20 E9 C6 JSR $C6E9                 
E36E  10 80    BPL $E2F0                 
E370  A9 00    LDA #$00                  
E372  8D BC 05 STA $05BC                 
E375  8D BD 05 STA $05BD                 
E378  8D F8 05 STA $05F8                 
E37B  85 77    STA $77                   
E37D  A9 03    LDA #$03                  
E37F  85 76    STA $76                   
E381  A9 A8    LDA #$A8                  
E383  85 75    STA $75                   
E385  A9 48    LDA #$48                  
E387  85 72    STA $72                   
E389  A9 01    LDA #$01                  
E38B  8D 00 A0 STA $A000                 
E38E  A9 0F    LDA #$0F                  
E390  A2 07    LDX #$07                  

loc_E392:  ; xrefs(1): $E396
E392  9D 08 01 STA $0108,X               
E395  CA       DEX                       
E396  10 FA    BPL $E392                 
E398  E6 02    INC $02                   
E39A  4C 35 C5 JMP $C535                 

sub_E39D:  ; xrefs(1): $E340
E39D  AE 1C 07 LDX $071C                 
E3A0  F0 06    BEQ $E3A8                 

loc_E3A2:  ; xrefs(1): $E3A6
E3A2  20 CF E3 JSR $E3CF                 
E3A5  CA       DEX                       
E3A6  D0 FA    BNE $E3A2                 

loc_E3A8:  ; xrefs(1): $E3A0
E3A8  AD 0C 06 LDA $060C                 
E3AB  F0 15    BEQ $E3C2                 
E3AD  18       CLC                       
E3AE  69 06    ADC #$06                  
E3B0  29 07    AND #$07                  
E3B2  AA       TAX                       
E3B3  F0 06    BEQ $E3BB                 

loc_E3B5:  ; xrefs(1): $E3B9
E3B5  20 CF E3 JSR $E3CF                 
E3B8  CA       DEX                       
E3B9  D0 FA    BNE $E3B5                 

loc_E3BB:  ; xrefs(1): $E3B3
E3BB  A9 10    LDA #$10                  
E3BD  A0 27    LDY #$27                  
E3BF  20 D3 E3 JSR $E3D3                 

loc_E3C2:  ; xrefs(1): $E3AB
E3C2  A5 59    LDA $59                   
E3C4  D0 08    BNE $E3CE                 
E3C6  A2 64    LDX #$64                  

loc_E3C8:  ; xrefs(1): $E3CC
E3C8  20 CF E3 JSR $E3CF                 
E3CB  CA       DEX                       
E3CC  D0 FA    BNE $E3C8                 

loc_E3CE:  ; xrefs(1): $E3C4
E3CE  60       RTS                       

sub_E3CF:  ; xrefs(3): $E3A2 $E3B5 $E3C8
E3CF  A0 03    LDY #$03                  
E3D1  A9 E8    LDA #$E8                  

sub_E3D3:  ; xrefs(3): $E1B3 $E1E2 $E3BF
E3D3  18       CLC                       
E3D4  6D FF 05 ADC $05FF                 
E3D7  8D FF 05 STA $05FF                 
E3DA  98       TYA                       
E3DB  6D FE 05 ADC $05FE                 
E3DE  8D FE 05 STA $05FE                 
E3E1  90 03    BCC $E3E6                 
E3E3  EE FD 05 INC $05FD                 

loc_E3E6:  ; xrefs(1): $E3E1
E3E6  60       RTS                       

sub_E3E7:  ; xrefs(1): $C9C1
E3E7  20 C9 C5 JSR $C5C9                 
E3EA  A9 18    LDA #$18                  
E3EC  A0 1A    LDY #$1A                  
E3EE  20 25 C9 JSR $C925                 
E3F1  A9 3A    LDA #$3A                  
E3F3  20 8C EF JSR $EF8C                 
E3F6  20 D8 DA JSR $DAD8                 
E3F9  85 7D    STA $7D                   
E3FB  8D 00 A0 STA $A000                 
E3FE  A9 20    LDA #$20                  
E400  85 4C    STA $4C                   
E402  A9 10    LDA #$10                  
E404  A5 28    LDA $28                   
E406  85 25    STA $25                   
E408  A9 20    LDA #$20                  
E40A  A0 80    LDY #$80                  
E40C  20 B1 E9 JSR $E9B1                 
E40F  20 43 CC JSR $CC43                 
E412  20 4F F8 JSR $F84F                 
E415  A9 06    LDA #$06                  
E417  A0 0F    LDY #$0F                  
E419  20 6D F8 JSR $F86D                 
E41C  E6 02    INC $02                   
E41E  4C 35 C5 JMP $C535                 

sub_E421:  ; xrefs(1): $C9C1
E421  20 06 F8 JSR $F806                 
E424  A9 0C    LDA #$0C                  
E426  20 2C C9 JSR $C92C                 
E429  20 0D 80 JSR $800D                 
E42C  4C DD E4 JMP $E4DD                 

sub_E42F:  ; xrefs(1): $C9C1
E42F  A9 30    LDA #$30                  
E431  85 4F    STA $4F                   
E433  A5 0C    LDA $0C                   
E435  6A       ROR A                     
E436  A5 4C    LDA $4C                   
E438  69 00    ADC #$00                  
E43A  C9 40    CMP #$40                  
E43C  D0 09    BNE $E447                 
E43E  48       PHA                       
E43F  A9 06    LDA #$06                  
E441  A0 FF    LDY #$FF                  
E443  20 6D F8 JSR $F86D                 
E446  68       PLA                       

loc_E447:  ; xrefs(1): $E43C
E447  C9 B8    CMP #$B8                  
E449  90 06    BCC $E451                 
E44B  A0 C0    LDY #$C0                  
E44D  84 4D    STY $4D                   
E44F  E6 02    INC $02                   

loc_E451:  ; xrefs(1): $E449
E451  85 4C    STA $4C                   
E453  4C A9 E4 JMP $E4A9                 

sub_E456:  ; xrefs(1): $C9C1
E456  C6 4D    DEC $4D                   
E458  D0 06    BNE $E460                 
E45A  A9 60    LDA #$60                  
E45C  85 4D    STA $4D                   
E45E  E6 02    INC $02                   

loc_E460:  ; xrefs(1): $E458
E460  4C A9 E4 JMP $E4A9                 

sub_E463:  ; xrefs(1): $C9C1
E463  A9 2E    LDA #$2E                  
E465  85 4F    STA $4F                   
E467  C6 4D    DEC $4D                   
E469  D0 06    BNE $E471                 
E46B  A9 00    LDA #$00                  
E46D  85 4D    STA $4D                   
E46F  E6 02    INC $02                   

loc_E471:  ; xrefs(1): $E469
E471  4C A9 E4 JMP $E4A9                 

sub_E474:  ; xrefs(1): $C9C1
E474  C6 4D    DEC $4D                   
E476  D0 0B    BNE $E483                 
E478  A9 00    LDA #$00                  
E47A  85 4E    STA $4E                   
E47C  A9 E0    LDA #$E0                  
E47E  8D AB 05 STA $05AB                 
E481  E6 02    INC $02                   

loc_E483:  ; xrefs(1): $E476
E483  4C A5 E4 JMP $E4A5                 

sub_E486:  ; xrefs(1): $C9C1
E486  A9 8B    LDA #$8B                  
E488  85 90    STA $90                   
E48A  A9 80    LDA #$80                  
E48C  85 91    STA $91                   
E48E  20 81 C0 JSR $C081                 
E491  4C 9F E4 JMP $E49F                 

sub_E494:  ; xrefs(1): $C9C1
E494  20 06 F8 JSR $F806                 
E497  A5 26    LDA $26                   
E499  D0 04    BNE $E49F                 
E49B  A9 22    LDA #$22                  
E49D  85 02    STA $02                   

loc_E49F:  ; xrefs(2): $E491 $E499
E49F  A9 2C    LDA #$2C                  
E4A1  85 4F    STA $4F                   
E4A3  D0 0A    BNE $E4AF                 

loc_E4A5:  ; xrefs(1): $E483
E4A5  A9 2C    LDA #$2C                  
E4A7  85 4F    STA $4F                   

loc_E4A9:  ; xrefs(3): $E453 $E460 $E471
E4A9  20 06 F8 JSR $F806                 
E4AC  20 DD E4 JSR $E4DD                 

loc_E4AF:  ; xrefs(1): $E4A3
E4AF  20 2D C7 JSR $C72D                 
E4B2  A2 1F    LDX #$1F                  

loc_E4B4:  ; xrefs(1): $E4B8
E4B4  8D 00 02 STA $0200                 
E4B7  CA       DEX                       
E4B8  10 FA    BPL $E4B4                 
E4BA  A9 00    LDA #$00                  
E4BC  85 6C    STA $6C                   
E4BE  A9 1C    LDA #$1C                  
E4C0  85 42    STA $42                   
E4C2  A9 1D    LDA #$1D                  
E4C4  85 43    STA $43                   
E4C6  A5 4C    LDA $4C                   
E4C8  85 90    STA $90                   
E4CA  A9 80    LDA #$80                  
E4CC  85 92    STA $92                   
E4CE  A9 00    LDA #$00                  
E4D0  85 91    STA $91                   
E4D2  85 93    STA $93                   
E4D4  85 9E    STA $9E                   
E4D6  A5 4F    LDA $4F                   
E4D8  A0 03    LDY #$03                  
E4DA  4C F9 F3 JMP $F3F9                 

sub_E4DD:  ; xrefs(3): $C9C1 $E42C $E4AC
E4DD  18       CLC                       
E4DE  A5 0C    LDA $0C                   
E4E0  6A       ROR A                     
E4E1  29 08    AND #$08                  
E4E3  4A       LSR A                     
E4E4  69 1A    ADC #$1A                  
E4E6  85 41    STA $41                   
E4E8  60       RTS                       

sub_E4E9:  ; xrefs(1): $C9C1
E4E9  20 C9 C5 JSR $C5C9                 
E4EC  20 1F D8 JSR $D81F                 
E4EF  A2 13    LDX #$13                  
E4F1  20 E9 C6 JSR $C6E9                 
E4F4  81 D4    STA ($D4,X)               
E4F6  20 D8 DA JSR $DAD8                 
E4F9  85 7D    STA $7D                   
E4FB  20 08 E5 JSR $E508                 
E4FE  A9 80    LDA #$80                  
E500  20 18 C6 JSR $C618                 
E503  E6 02    INC $02                   
E505  4C 35 C5 JMP $C535                 

sub_E508:  ; xrefs(1): $E4FB
E508  A9 4E    LDA #$4E                  
E50A  85 75    STA $75                   
E50C  A9 08    LDA #$08                  
E50E  85 73    STA $73                   
E510  A9 F7    LDA #$F7                  
E512  85 74    STA $74                   
E514  60       RTS                       

sub_E515:  ; xrefs(1): $C9C1
E515  20 9A CA JSR $CA9A                 
E518  A9 0C    LDA #$0C                  
E51A  20 2C C9 JSR $C92C                 
E51D  4C 16 80 JMP $8016                 

sub_E520:  ; xrefs(1): $C9C1
E520  20 78 C5 JSR $C578                 
E523  20 DA C5 JSR $C5DA                 
E526  20 72 F8 JSR $F872                 
E529  20 88 E6 JSR $E688                 
E52C  20 CB F8 JSR $F8CB                 
E52F  A9 3E    LDA #$3E                  
E531  85 02    STA $02                   
E533  4C 35 C5 JMP $C535                 

; ---- data $E536-$E641 (268 bytes) ----
E536  49 4D 4D 54 49 57 41 49 4E 53 41 54 5A 49 4B 88  |IMMTIWAINSATZIK.
E546  40 10 98 20 13 1F 27 3A 4E 00 00 00 00 00 48 38  |@.. ..':N.....H8
E556  A5 90 E9 80 85 90 B0 02 C6 91 38 A5 92 E9 80 85  |..........8.....
E566  92 B0 02 C6 93 A5 90 46 91 6A 46 91 6A 46 91 6A  |.......F.jF.jF.j
E576  46 91 6A 85 90 A5 92 46 93 6A 46 93 6A 46 93 6A  |F.j....F.jF.jF.j
E586  46 93 6A 85 92 68 48 A5 91 D0 49 A5 93 D0 45 E6  |F.j..hH...I...E.
E596  6B A5 6B 6A 90 40 A6 6C A5 90 9D 03 02 A5 92 9D  |k.kj.@.l........
E5A6  00 02 A5 9E 9D 01 02 68 9D 02 02 E8 E8 E8 E8 D0  |.......h........
E5B6  02 A2 30 18 A5 90 69 08 9D 03 02 A5 92 9D 00 02  |..0...i.........
E5C6  A5 9F 9D 01 02 98 9D 02 02 E8 E8 E8 E8 D0 02 A2  |................
E5D6  30 86 6C 60 68 60 A5 6A C9 3A B0 42 A6 6D A5 90  |0.l`h`.j.:.B.m..
E5E6  9D 00 02 A5 92 9D FD 01 A5 9E 9D FE 01 68 9D FF  |.............h..
E5F6  01 CA CA CA CA E0 20 B0 02 A2 FF 18 A5 90 69 08  |...... .......i.
E606  9D 00 02 A5 92 9D FD 01 A5 9F 9D FE 01 98 9D FF  |................
E616  01 CA CA CA CA E0 20 B0 02 A2 FF 86 6D 60 68 60  |...... .....m`h`
E626  A6 55 BD 65 C9 20 2C C9 A5 55 0A A8 B9 E0 E6 85  |.U.e. ,..U......
E636  90 B9 E1 E6 85 91 20 42 E6 4C 98 C9              |...... B.L..

sub_E642:  ; xrefs(1): $E708
E642  A0 00    LDY #$00                  
E644  B1 90    LDA ($90),Y               
E646  AA       TAX                       
E647  BD 0D 80 LDA $800D,X               
E64A  85 10    STA $10                   
E64C  BD 0E 80 LDA $800E,X               
E64F  85 11    STA $11                   
E651  BD 0F 80 LDA $800F,X               
E654  85 12    STA $12                   
E656  BD 10 80 LDA $8010,X               
E659  85 13    STA $13                   
E65B  BD 11 80 LDA $8011,X               
E65E  85 14    STA $14                   
E660  BD 12 80 LDA $8012,X               
E663  85 15    STA $15                   
E665  BD 13 80 LDA $8013,X               
E668  85 1E    STA $1E                   
E66A  BD 14 80 LDA $8014,X               
E66D  85 1F    STA $1F                   
E66F  BD 15 80 LDA $8015,X               
E672  85 16    STA $16                   
E674  BD 16 80 LDA $8016,X               
E677  85 17    STA $17                   
E679  BD 17 80 LDA $8017,X               
E67C  85 18    STA $18                   
E67E  BD 18 80 LDA $8018,X               
E681  85 19    STA $19                   
E683  A5 55    LDA $55                   
E685  85 7C    STA $7C                   
E687  60       RTS                       

sub_E688:  ; xrefs(1): $E529
E688  20 9B E6 JSR $E69B                 
E68B  A5 2E    LDA $2E                   
E68D  D0 04    BNE $E693                 
E68F  A9 F8    LDA #$F8                  
E691  D0 02    BNE $E695                 

loc_E693:  ; xrefs(1): $E68D
E693  A9 00    LDA #$00                  

loc_E695:  ; xrefs(1): $E691
E695  20 3F F8 JSR $F83F                 
E698  4C 06 F8 JMP $F806                 

sub_E69B:  ; xrefs(3): $CAA7 $CB93 $E688
E69B  A9 E4    LDA #$E4                  
E69D  20 18 C6 JSR $C618                 
E6A0  A9 B8    LDA #$B8                  
E6A2  8D E8 05 STA $05E8                 
E6A5  A9 06    LDA #$06                  
E6A7  85 5B    STA $5B                   
E6A9  A9 04    LDA #$04                  
E6AB  8D E9 05 STA $05E9                 
E6AE  A9 06    LDA #$06                  
E6B0  8D EA 05 STA $05EA                 
E6B3  A9 07    LDA #$07                  
E6B5  8D E4 05 STA $05E4                 
E6B8  A9 01    LDA #$01                  
E6BA  8D E5 05 STA $05E5                 
E6BD  A9 01    LDA #$01                  
E6BF  8D E6 05 STA $05E6                 
E6C2  A9 0E    LDA #$0E                  
E6C4  8D E7 05 STA $05E7                 
E6C7  A6 55    LDX $55                   
E6C9  BD 65 C9 LDA $C965,X               
E6CC  20 2C C9 JSR $C92C                 
E6CF  A5 55    LDA $55                   
E6D1  0A       ASL A                     
E6D2  A8       TAY                       
E6D3  B9 E0 E6 LDA $E6E0,Y               
E6D6  85 90    STA $90                   
E6D8  B9 E1 E6 LDA $E6E1,Y               
E6DB  85 91    STA $91                   
E6DD  4C 08 E7 JMP $E708                 

; ---- data $E6E0-$E707 (40 bytes) ----
E6E0  D9 E7 51 E8 65 E8 DD E8 29 E8 3D E8 8D E8 A1 E8  |..Q.e...).=.....
E6F0  C9 E8 F1 E8 19 E9 2D E9 B5 E8 79 E8 41 E9 55 E9  |......-...y.A.U.
E700  69 E9 91 E9 05 E9 7D E9                          |i.....}.

loc_E708:  ; xrefs(1): $E6DD
E708  20 42 E6 JSR $E642                 
E70B  C8       INY                       
E70C  B1 90    LDA ($90),Y               
E70E  85 80    STA $80                   
E710  C8       INY                       
E711  B1 90    LDA ($90),Y               
E713  85 81    STA $81                   
E715  29 F0    AND #$F0                  
E717  85 31    STA $31                   
E719  8D E1 05 STA $05E1                 
E71C  C8       INY                       
E71D  B1 90    LDA ($90),Y               
E71F  85 82    STA $82                   
E721  C8       INY                       
E722  B1 90    LDA ($90),Y               
E724  85 83    STA $83                   
E726  29 F0    AND #$F0                  
E728  85 33    STA $33                   
E72A  8D E3 05 STA $05E3                 
E72D  C8       INY                       
E72E  B1 90    LDA ($90),Y               
E730  85 39    STA $39                   
E732  C8       INY                       
E733  B1 90    LDA ($90),Y               
E735  85 3B    STA $3B                   
E737  C8       INY                       
E738  B1 90    LDA ($90),Y               
E73A  85 3D    STA $3D                   
E73C  C8       INY                       
E73D  B1 90    LDA ($90),Y               
E73F  85 3F    STA $3F                   
E741  C8       INY                       
E742  B1 90    LDA ($90),Y               
E744  85 20    STA $20                   
E746  C8       INY                       
E747  B1 90    LDA ($90),Y               
E749  85 21    STA $21                   
E74B  C8       INY                       
E74C  B1 90    LDA ($90),Y               
E74E  85 40    STA $40                   
E750  C8       INY                       
E751  B1 90    LDA ($90),Y               
E753  85 41    STA $41                   
E755  C8       INY                       
E756  B1 90    LDA ($90),Y               
E758  85 42    STA $42                   
E75A  C8       INY                       
E75B  B1 90    LDA ($90),Y               
E75D  85 43    STA $43                   
E75F  C8       INY                       
E760  B1 90    LDA ($90),Y               
E762  85 44    STA $44                   
E764  C8       INY                       
E765  B1 90    LDA ($90),Y               
E767  85 45    STA $45                   
E769  C8       INY                       
E76A  B1 90    LDA ($90),Y               
E76C  85 92    STA $92                   
E76E  C8       INY                       
E76F  B1 90    LDA ($90),Y               
E771  85 93    STA $93                   
E773  C8       INY                       
E774  B1 90    LDA ($90),Y               
E776  C5 2E    CMP $2E                   
E778  D0 02    BNE $E77C                 
E77A  A9 00    LDA #$00                  

loc_E77C:  ; xrefs(1): $E778
E77C  85 2E    STA $2E                   
E77E  A9 FF    LDA #$FF                  
E780  A2 1F    LDX #$1F                  

loc_E782:  ; xrefs(1): $E786
E782  9D 40 05 STA $0540,X               
E785  CA       DEX                       
E786  10 FA    BPL $E782                 
E788  A2 3F    LDX #$3F                  

loc_E78A:  ; xrefs(1): $E790
E78A  A9 01    LDA #$01                  
E78C  9D 60 05 STA $0560,X               
E78F  CA       DEX                       
E790  10 F8    BPL $E78A                 
E792  A9 00    LDA #$00                  
E794  A2 07    LDX #$07                  

loc_E796:  ; xrefs(1): $E79A
E796  9D C9 05 STA $05C9,X               
E799  CA       DEX                       
E79A  10 FA    BPL $E796                 
E79C  A9 80    LDA #$80                  
E79E  85 69    STA $69                   
E7A0  A5 00    LDA $00                   
E7A2  85 9D    STA $9D                   
E7A4  A5 09    LDA $09                   
E7A6  09 02    ORA #$02                  
E7A8  29 1F    AND #$1F                  
E7AA  85 09    STA $09                   
E7AC  A9 FF    LDA #$FF                  
E7AE  8D A3 05 STA $05A3                 
E7B1  A9 00    LDA #$00                  
E7B3  85 30    STA $30                   
E7B5  85 32    STA $32                   
E7B7  8D A5 01 STA $01A5                 
E7BA  85 38    STA $38                   
E7BC  85 3A    STA $3A                   
E7BE  85 3C    STA $3C                   
E7C0  85 3E    STA $3E                   
E7C2  8D E0 05 STA $05E0                 
E7C5  8D E2 05 STA $05E2                 
E7C8  85 35    STA $35                   
E7CA  8D A2 05 STA $05A2                 
E7CD  85 7F    STA $7F                   
E7CF  85 57    STA $57                   
E7D1  85 58    STA $58                   
E7D3  85 34    STA $34                   
E7D5  8D FA 05 STA $05FA                 
E7D8  60       RTS                       

; ---- data $E7D9-$E9B0 (472 bytes) ----
E7D9  00 00 15 00 16 10 60 10 20 40 80 20 22 40 56 70  |......`. @. "@Vp
E7E9  00 D2 E9 01 00 00 14 00 E4 10 20 30 F1 40 80 20  |.......... 0.@. 
E7F9  22 40 56 70 00 D2 E9 01 0C 00 14 00 14 10 E0 11  |"@Vp............
E809  21 80 80 30 32 40 56 70 00 D2 E9 01 18 00 54 00  |!..02@Vp......T.
E819  54 10 E0 11 E1 A0 80 30 32 40 56 70 00 D2 E9 01  |T......02@Vp....
E829  00 00 14 00 24 10 70 21 31 C0 80 2C 22 40 56 77  |....$.p!1..,"@Vw
E839  72 D2 E9 02 0C 00 18 00 69 10 90 60 80 E0 80 2C  |r.......i..`...,
E849  22 40 56 74 00 D2 E9 02 18 00 45 00 17 40 80 10  |"@Vt......E..@..
E859  20 00 81 28 22 40 56 77 7B D2 E9 05 24 00 17 00  | ..("@Vw{...$...
E869  E9 10 40 D1 E1 00 81 28 22 40 56 70 7E D2 E9 05  |..@....("@Vp~...
E879  60 00 52 00 E4 50 60 10 F0 20 81 28 22 40 56 70  |`.R..P`.. .("@Vp
E889  00 D2 E9 07 30 00 15 00 16 10 D0 10 20 40 81 34  |....0....... @.4
E899  22 40 56 74 7F D2 E9 06 3C 00 28 00 6B 20 30 41  |"@Vt....<.(.k 0A
E8A9  71 60 81 34 22 40 56 77 7A D2 E9 06 3C 00 B2 00  |q`.4"@Vwz...<...
E8B9  67 B0 C0 60 70 C0 81 34 22 40 56 6B 60 D2 E9 07  |g..`p..4"@Vk`...
E8C9  00 00 D2 00 17 D0 E0 10 20 60 80 20 22 40 56 75  |........ `. "@Vu
E8D9  60 D2 E9 07 48 00 14 00 18 10 80 10 20 E0 81 30  |`...H....... ..0
E8E9  32 40 56 77 71 D2 E9 05 54 00 17 00 47 10 90 40  |2@Vwq...T...G..@
E8F9  50 00 82 30 32 40 56 70 7C D2 E9 05 54 00 92 00  |P..02@Vp|...T...
E909  45 90 A0 40 50 40 84 30 32 40 56 70 00 D2 E9 07  |E..@P@.02@Vp....
E919  0C 00 15 00 16 10 90 10 20 20 82 24 32 40 56 77  |........  .$2@Vw
E929  73 D2 E9 03 18 00 17 00 37 10 20 30 70 40 82 24  |s.......7. 0p@.$
E939  32 40 56 70 72 D2 E9 03 18 00 42 00 35 40 50 30  |2@Vpr.....B.5@P0
E949  40 60 82 24 32 40 56 75 63 D2 E9 07 30 00 14 00  |@`.$2@Vuc...0...
E959  58 10 70 50 60 E0 83 38 32 40 56 77 73 D2 E9 04  |X.pP`..82@Vws...
E969  3C 00 B8 00 6B B0 D0 60 70 20 84 3C 32 40 56 70  |<...k..`p .<2@Vp
E979  7A D2 E9 04 30 00 25 00 28 20 40 20 30 E0 84 38  |z...0.%.( @ 0..8
E989  32 40 56 70 60 D2 E9 07 0C 00 C4 00 64 C0 D0 60  |2@Vp`.......d..`
E999  70 60 84 2C 22 40 56 74 00 D2 E9 07 A9 60 D0 06  |p`.,"@Vt.....`..
E9A9  A9 80 D0 02 A9 A0 A0 81                          |........

sub_E9B1:  ; xrefs(10): $CC5E $D277 $D2D5 $D335 $D385 $D3D7 $DB0C $DD1F $E0DB $E40C
E9B1  85 20    STA $20                   
E9B3  84 21    STY $21                   
E9B5  60       RTS                       

; ---- data $E9B6-$E9D1 (28 bytes) ----
E9B6  A9 00 A0 84 D0 F5 A9 20 D0 F8 A9 80 D0 F4 A9 A0  |....... ........
E9C6  D0 F0 A9 C0 D0 EC A9 E0 A0 83 D0 DF              |............

sub_E9D2:  ; xrefs(2): $C9C1 $CC0A
E9D2  18       CLC                       
E9D3  A5 31    LDA $31                   
E9D5  69 20    ADC #$20                  
E9D7  85 31    STA $31                   
E9D9  8D E1 05 STA $05E1                 
E9DC  A9 41    LDA #$41                  
E9DE  85 03    STA $03                   
E9E0  E6 02    INC $02                   
E9E2  60       RTS                       

sub_E9E3:  ; xrefs(2): $C9C1 $CAC9
E9E3  20 46 C9 JSR $C946                 
E9E6  20 9C EA JSR $EA9C                 
E9E9  20 44 EC JSR $EC44                 
E9EC  20 2B EC JSR $EC2B                 
E9EF  C6 03    DEC $03                   
E9F1  D0 0F    BNE $EA02                 
E9F3  A5 2E    LDA $2E                   
E9F5  F0 02    BEQ $E9F9                 
E9F7  85 F0    STA $F0                   

loc_E9F9:  ; xrefs(1): $E9F5
E9F9  A9 00    LDA #$00                  
E9FB  85 04    STA $04                   
E9FD  85 05    STA $05                   
E9FF  85 02    STA $02                   
EA01  60       RTS                       

loc_EA02:  ; xrefs(1): $E9F1
EA02  38       SEC                       
EA03  A5 30    LDA $30                   
EA05  E9 80    SBC #$80                  
EA07  85 30    STA $30                   
EA09  B0 02    BCS $EA0D                 
EA0B  C6 31    DEC $31                   

loc_EA0D:  ; xrefs(1): $EA09
EA0D  60       RTS                       

; ---- data $EA0E-$EA9B (142 bytes) ----
EA0E  48 38 A5 90 E9 40 85 90 B0 03 C6 91 38 A5 92 E9  |H8...@......8...
EA1E  40 85 92 B0 02 C6 93 A5 90 46 91 6A 46 91 6A 46  |@........F.jF.jF
EA2E  91 6A 46 91 6A 85 90 A5 92 46 93 6A 46 93 6A 46  |.jF.j....F.jF.jF
EA3E  93 6A 46 93 6A 85 92 A5 91 D0 51 A5 93 D0 4D E6  |.jF.j.....Q...M.
EA4E  6B A5 6B 6A 90 1F A6 6C A5 90 9D 03 02 A5 92 9D  |k.kj...l........
EA5E  00 02 98 9D 01 02 68 9D 02 02 E8 E8 E8 E8 D0 02  |......h.........
EA6E  A2 30 86 6C 60 A5 6A C9 3A B0 21 A6 6D A5 90 9D  |.0.l`.j.:.!.m...
EA7E  00 02 A5 92 9D FD 01 98 9D FE 01 68 9D FF 01 CA  |...........h....
EA8E  CA CA CA E0 30 B0 02 A2 FF 86 6D 60 68 60        |....0.....m`h`

sub_EA9C:  ; xrefs(3): $CCB8 $CDAB $E9E6
EA9C  A5 31    LDA $31                   
EA9E  85 91    STA $91                   
EAA0  A5 30    LDA $30                   
EAA2  46 91    LSR $91                   
EAA4  6A       ROR A                     
EAA5  46 91    LSR $91                   
EAA7  6A       ROR A                     
EAA8  46 91    LSR $91                   
EAAA  6A       ROR A                     
EAAB  46 91    LSR $91                   
EAAD  6A       ROR A                     
EAAE  85 90    STA $90                   
EAB0  85 0A    STA $0A                   
EAB2  A5 91    LDA $91                   
EAB4  29 01    AND #$01                  
EAB6  85 91    STA $91                   
EAB8  A5 08    LDA $08                   
EABA  29 FE    AND #$FE                  
EABC  05 91    ORA $91                   
EABE  85 08    STA $08                   
EAC0  A5 33    LDA $33                   
EAC2  85 93    STA $93                   
EAC4  A5 32    LDA $32                   
EAC6  85 92    STA $92                   
EAC8  20 06 EC JSR $EC06                 
EACB  85 0B    STA $0B                   
EACD  60       RTS                       

; ---- data $EACE-$EB46 (121 bytes) ----
EACE  A5 91 4A 4A 29 04 18 69 20 85 9F A5 90 2A A5 91  |..JJ)..i ....*..
EADE  2A 29 1F 85 9E 20 06 EC 29 F8 AA 85 9C A9 00 06  |*)... ..).......
EAEE  9C 2A 06 9C 2A 85 9D 18 A5 9E 65 9C 85 9E A5 9F  |.*..*.....e.....
EAFE  65 9D 85 9F 8A 4A 4A 4A 8D A5 01 A5 92 2A A5 93  |e....JJJ.....*..
EB0E  2A 29 1F 8D A4 01 60 A5 91 48 29 0F 4A 85 9F 68  |*)....`..H).J..h
EB1E  29 10 0A 0A 65 9F 85 9F 20 06 EC 48 29 E0 4A 4A  |)...e... ..H).JJ
EB2E  65 9F 85 9F 68 0A 0A 0A 0A 26 9E A5 91 6A 26 9E  |e...h....&...j&.
EB3E  A5 9E 49 FF 29 03 85 9E 60                       |..I.)...`

sub_EB47:  ; xrefs(1): $EDC5
EB47  A5 91    LDA $91                   
EB49  4A       LSR A                     
EB4A  4A       LSR A                     
EB4B  29 04    AND #$04                  
EB4D  18       CLC                       
EB4E  69 20    ADC #$20                  
EB50  85 9F    STA $9F                   
EB52  8D A3 01 STA $01A3                 
EB55  A5 90    LDA $90                   
EB57  2A       ROL A                     
EB58  A5 91    LDA $91                   
EB5A  2A       ROL A                     
EB5B  29 1F    AND #$1F                  
EB5D  85 9E    STA $9E                   
EB5F  8D A2 01 STA $01A2                 
EB62  20 FC EB JSR $EBFC                 
EB65  29 F8    AND #$F8                  
EB67  AA       TAX                       
EB68  85 9C    STA $9C                   
EB6A  A9 00    LDA #$00                  
EB6C  06 9C    ASL $9C                   
EB6E  2A       ROL A                     
EB6F  06 9C    ASL $9C                   
EB71  2A       ROL A                     
EB72  85 9D    STA $9D                   
EB74  18       CLC                       
EB75  A5 9E    LDA $9E                   
EB77  65 9C    ADC $9C                   
EB79  8D A0 01 STA $01A0                 
EB7C  A5 9F    LDA $9F                   
EB7E  65 9D    ADC $9D                   
EB80  8D A1 01 STA $01A1                 
EB83  8A       TXA                       
EB84  4A       LSR A                     
EB85  4A       LSR A                     
EB86  4A       LSR A                     
EB87  8D A5 01 STA $01A5                 
EB8A  A5 92    LDA $92                   
EB8C  2A       ROL A                     
EB8D  A5 93    LDA $93                   
EB8F  2A       ROL A                     
EB90  29 1F    AND #$1F                  
EB92  8D A4 01 STA $01A4                 
EB95  60       RTS                       

sub_EB96:  ; xrefs(1): $EE2A
EB96  A5 91    LDA $91                   
EB98  4A       LSR A                     
EB99  4A       LSR A                     
EB9A  29 04    AND #$04                  
EB9C  49 04    EOR #$04                  
EB9E  18       CLC                       
EB9F  69 20    ADC #$20                  
EBA1  85 9F    STA $9F                   
EBA3  20 FC EB JSR $EBFC                 
EBA6  85 99    STA $99                   
EBA8  29 F8    AND #$F8                  
EBAA  85 9E    STA $9E                   
EBAC  A9 00    LDA #$00                  
EBAE  06 9E    ASL $9E                   
EBB0  2A       ROL A                     
EBB1  06 9E    ASL $9E                   
EBB3  2A       ROL A                     
EBB4  85 9D    STA $9D                   
EBB6  A5 99    LDA $99                   
EBB8  29 E0    AND #$E0                  
EBBA  4A       LSR A                     
EBBB  4A       LSR A                     
EBBC  85 9A    STA $9A                   
EBBE  8D D0 05 STA $05D0                 
EBC1  A5 9E    LDA $9E                   
EBC3  8D A8 01 STA $01A8                 
EBC6  A5 9F    LDA $9F                   
EBC8  65 9D    ADC $9D                   
EBCA  85 9F    STA $9F                   
EBCC  8D A9 01 STA $01A9                 
EBCF  A5 90    LDA $90                   
EBD1  2A       ROL A                     
EBD2  A5 91    LDA $91                   
EBD4  2A       ROL A                     
EBD5  29 1F    AND #$1F                  
EBD7  85 9C    STA $9C                   
EBD9  18       CLC                       
EBDA  A5 9E    LDA $9E                   
EBDC  65 9C    ADC $9C                   
EBDE  8D A6 01 STA $01A6                 
EBE1  A5 9F    LDA $9F                   
EBE3  69 00    ADC #$00                  
EBE5  49 04    EOR #$04                  
EBE7  8D A7 01 STA $01A7                 
EBEA  A5 90    LDA $90                   
EBEC  2A       ROL A                     
EBED  A5 91    LDA $91                   
EBEF  2A       ROL A                     
EBF0  29 1F    AND #$1F                  
EBF2  8D AD 01 STA $01AD                 
EBF5  18       CLC                       
EBF6  69 40    ADC #$40                  
EBF8  8D AC 01 STA $01AC                 
EBFB  60       RTS                       

sub_EBFC:  ; xrefs(2): $EB62 $EBA3
EBFC  A5 55    LDA $55                   
EBFE  D0 06    BNE $EC06                 
EC00  A5 92    LDA $92                   
EC02  29 80    AND #$80                  
EC04  85 92    STA $92                   

sub_EC06:  ; xrefs(2): $EAC8 $EBFE
EC06  A5 93    LDA $93                   
EC08  85 9D    STA $9D                   
EC0A  A5 92    LDA $92                   
EC0C  0A       ASL A                     
EC0D  26 9D    ROL $9D                   
EC0F  0A       ASL A                     
EC10  26 9D    ROL $9D                   
EC12  0A       ASL A                     
EC13  26 9D    ROL $9D                   
EC15  0A       ASL A                     
EC16  26 9D    ROL $9D                   
EC18  A5 93    LDA $93                   
EC1A  29 F0    AND #$F0                  
EC1C  18       CLC                       
EC1D  65 9D    ADC $9D                   
EC1F  B0 07    BCS $EC28                 
EC21  AA       TAX                       
EC22  69 10    ADC #$10                  
EC24  B0 04    BCS $EC2A                 
EC26  8A       TXA                       
EC27  60       RTS                       

loc_EC28:  ; xrefs(1): $EC1F
EC28  69 0F    ADC #$0F                  

loc_EC2A:  ; xrefs(1): $EC24
EC2A  60       RTS                       

sub_EC2B:  ; xrefs(3): $CCBE $CDA5 $E9EC
EC2B  A5 32    LDA $32                   
EC2D  4D E2 05 EOR $05E2                 
EC30  10 11    BPL $EC43                 
EC32  20 F1 ED JSR $EDF1                 
EC35  A5 32    LDA $32                   
EC37  8D E2 05 STA $05E2                 
EC3A  A5 33    LDA $33                   
EC3C  8D E3 05 STA $05E3                 
EC3F  A9 FF    LDA #$FF                  
EC41  85 36    STA $36                   

loc_EC43:  ; xrefs(1): $EC30
EC43  60       RTS                       

sub_EC44:  ; xrefs(3): $CCBB $CDA2 $E9E9
EC44  A5 30    LDA $30                   
EC46  4D E0 05 EOR $05E0                 
EC49  10 11    BPL $EC5C                 
EC4B  20 9A ED JSR $ED9A                 
EC4E  A5 30    LDA $30                   
EC50  8D E0 05 STA $05E0                 
EC53  A5 31    LDA $31                   
EC55  8D E1 05 STA $05E1                 
EC58  A9 FF    LDA #$FF                  
EC5A  85 37    STA $37                   

loc_EC5C:  ; xrefs(1): $EC49
EC5C  60       RTS                       

sub_EC5D:  ; xrefs(3): $D9AA $E0A7 $E28C
EC5D  AD FF 05 LDA $05FF                 
EC60  85 90    STA $90                   
EC62  AD FE 05 LDA $05FE                 
EC65  85 91    STA $91                   
EC67  AD FD 05 LDA $05FD                 
EC6A  85 92    STA $92                   

sub_EC6C:  ; xrefs(2): $D99C $E2DC
EC6C  20 7C EC JSR $EC7C                 
EC6F  20 F5 EC JSR $ECF5                 

sub_EC72:  ; xrefs(1): $D703
EC72  A2 05    LDX #$05                  

loc_EC74:  ; xrefs(1): $EC79
EC74  B5 93    LDA $93,X                 
EC76  95 98    STA $98,X                 
EC78  CA       DEX                       
EC79  10 F9    BPL $EC74                 
EC7B  60       RTS                       

sub_EC7C:  ; xrefs(3): $D6FD $EC6C $FA35
EC7C  A2 00    LDX #$00                  

loc_EC7E:  ; xrefs(1): $ECB1
EC7E  A9 00    LDA #$00                  
EC80  95 93    STA $93,X                 

loc_EC82:  ; xrefs(1): $ECAB
EC82  A5 90    LDA $90                   
EC84  DD C8 EC CMP $ECC8,X               
EC87  A5 91    LDA $91                   
EC89  FD CE EC SBC $ECCE,X               
EC8C  A5 92    LDA $92                   
EC8E  FD D4 EC SBC $ECD4,X               
EC91  90 1B    BCC $ECAE                 
EC93  F6 93    INC $93,X                 
EC95  38       SEC                       
EC96  A5 90    LDA $90                   
EC98  FD C8 EC SBC $ECC8,X               
EC9B  85 90    STA $90                   
EC9D  A5 91    LDA $91                   
EC9F  FD CE EC SBC $ECCE,X               
ECA2  85 91    STA $91                   
ECA4  A5 92    LDA $92                   
ECA6  FD D4 EC SBC $ECD4,X               
ECA9  85 92    STA $92                   
ECAB  4C 82 EC JMP $EC82                 

loc_ECAE:  ; xrefs(1): $EC91
ECAE  E8       INX                       
ECAF  E0 06    CPX #$06                  
ECB1  D0 CB    BNE $EC7E                 
ECB3  A5 93    LDA $93                   
ECB5  C9 0A    CMP #$0A                  
ECB7  90 0E    BCC $ECC7                 
ECB9  A9 09    LDA #$09                  
ECBB  85 98    STA $98                   
ECBD  85 97    STA $97                   
ECBF  85 96    STA $96                   
ECC1  85 95    STA $95                   
ECC3  85 94    STA $94                   
ECC5  85 93    STA $93                   

loc_ECC7:  ; xrefs(1): $ECB7
ECC7  60       RTS                       

; ---- data $ECC8-$ECD9 (18 bytes) ----
ECC8  A0 10 E8 64 0A 01 86 27 03 00 00 00 01 00 00 00  |...d...'........
ECD8  00 00                                            |..

sub_ECDA:  ; xrefs(1): $FA38
ECDA  A2 05    LDX #$05                  

loc_ECDC:  ; xrefs(1): $ECE4
ECDC  B5 93    LDA $93,X                 
ECDE  0A       ASL A                     
ECDF  95 93    STA $93,X                 
ECE1  F6 93    INC $93,X                 
ECE3  CA       DEX                       
ECE4  10 F6    BPL $ECDC                 
ECE6  60       RTS                       

; ---- data $ECE7-$ECF4 (14 bytes) ----
ECE7  A2 05 B5 93 0A 18 69 81 95 93 CA 10 F5 60        |......i......`

sub_ECF5:  ; xrefs(2): $D700 $EC6F
ECF5  A2 05    LDX #$05                  

loc_ECF7:  ; xrefs(1): $ECFF
ECF7  18       CLC                       
ECF8  B5 93    LDA $93,X                 
ECFA  69 30    ADC #$30                  
ECFC  95 93    STA $93,X                 
ECFE  CA       DEX                       
ECFF  10 F6    BPL $ECF7                 
ED01  60       RTS                       

sub_ED02:  ; xrefs(1): $D6E7
ED02  A2 04    LDX #$04                  

loc_ED04:  ; xrefs(1): $ED78
ED04  8A       TXA                       
ED05  A8       TAY                       

loc_ED06:  ; xrefs(1): $ED75
ED06  86 90    STX $90                   
ED08  C4 90    CPY $90                   
ED0A  F0 68    BEQ $ED74                 
ED0C  B9 5B 07 LDA $075B,Y               
ED0F  DD 5B 07 CMP $075B,X               
ED12  B9 6B 07 LDA $076B,Y               
ED15  FD 6B 07 SBC $076B,X               
ED18  B9 7B 07 LDA $077B,Y               
ED1B  FD 7B 07 SBC $077B,X               
ED1E  90 54    BCC $ED74                 
ED20  B9 5B 07 LDA $075B,Y               
ED23  48       PHA                       
ED24  BD 5B 07 LDA $075B,X               
ED27  99 5B 07 STA $075B,Y               
ED2A  68       PLA                       
ED2B  9D 5B 07 STA $075B,X               
ED2E  B9 6B 07 LDA $076B,Y               
ED31  48       PHA                       
ED32  BD 6B 07 LDA $076B,X               
ED35  99 6B 07 STA $076B,Y               
ED38  68       PLA                       
ED39  9D 6B 07 STA $076B,X               
ED3C  B9 7B 07 LDA $077B,Y               
ED3F  48       PHA                       
ED40  BD 7B 07 LDA $077B,X               
ED43  99 7B 07 STA $077B,Y               
ED46  68       PLA                       
ED47  9D 7B 07 STA $077B,X               
ED4A  B9 4B 07 LDA $074B,Y               
ED4D  48       PHA                       
ED4E  BD 4B 07 LDA $074B,X               
ED51  99 4B 07 STA $074B,Y               
ED54  68       PLA                       
ED55  9D 4B 07 STA $074B,X               
ED58  B9 3B 07 LDA $073B,Y               
ED5B  48       PHA                       
ED5C  BD 3B 07 LDA $073B,X               
ED5F  99 3B 07 STA $073B,Y               
ED62  68       PLA                       
ED63  9D 3B 07 STA $073B,X               
ED66  B9 2B 07 LDA $072B,Y               
ED69  48       PHA                       
ED6A  BD 2B 07 LDA $072B,X               
ED6D  99 2B 07 STA $072B,Y               
ED70  68       PLA                       
ED71  9D 2B 07 STA $072B,X               

loc_ED74:  ; xrefs(2): $ED0A $ED1E
ED74  88       DEY                       
ED75  10 8F    BPL $ED06                 
ED77  CA       DEX                       
ED78  10 8A    BPL $ED04                 
ED7A  60       RTS                       

; ---- data $ED7B-$ED99 (31 bytes) ----
ED7B  A5 29 85 90 A5 2A 85 91 A5 2B 85 92 A5 2C 85 93  |.)...*...+...,..
ED8B  20 C5 ED 18 A5 29 69 80 85 29 90 02 E6 2A 60     | ....)i..)...*`

sub_ED9A:  ; xrefs(1): $EC4B
ED9A  38       SEC                       
ED9B  A5 30    LDA $30                   
ED9D  ED E0 05 SBC $05E0                 
EDA0  A5 31    LDA $31                   
EDA2  ED E1 05 SBC $05E1                 
EDA5  90 0E    BCC $EDB5                 
EDA7  A5 30    LDA $30                   
EDA9  85 90    STA $90                   
EDAB  18       CLC                       
EDAC  A5 31    LDA $31                   
EDAE  69 10    ADC #$10                  
EDB0  85 91    STA $91                   
EDB2  4C BD ED JMP $EDBD                 

loc_EDB5:  ; xrefs(1): $EDA5
EDB5  A5 30    LDA $30                   
EDB7  85 90    STA $90                   
EDB9  A5 31    LDA $31                   
EDBB  85 91    STA $91                   

loc_EDBD:  ; xrefs(1): $EDB2
EDBD  A5 32    LDA $32                   
EDBF  85 92    STA $92                   
EDC1  A5 33    LDA $33                   
EDC3  85 93    STA $93                   
EDC5  20 47 EB JSR $EB47                 
EDC8  A9 00    LDA #$00                  
EDCA  85 92    STA $92                   
EDCC  A5 33    LDA $33                   
EDCE  29 F0    AND #$F0                  
EDD0  85 93    STA $93                   
EDD2  A5 33    LDA $33                   
EDD4  29 0F    AND #$0F                  
EDD6  F0 10    BEQ $EDE8                 
EDD8  A9 00    LDA #$00                  
EDDA  85 6F    STA $6F                   
EDDC  20 C7 EF JSR $EFC7                 
EDDF  18       CLC                       
EDE0  A5 93    LDA $93                   
EDE2  69 10    ADC #$10                  
EDE4  85 93    STA $93                   
EDE6  A9 20    LDA #$20                  

loc_EDE8:  ; xrefs(1): $EDD6
EDE8  85 6F    STA $6F                   
EDEA  20 C7 EF JSR $EFC7                 
EDED  20 4F EE JSR $EE4F                 
EDF0  60       RTS                       

sub_EDF1:  ; xrefs(1): $EC32
EDF1  38       SEC                       
EDF2  A5 32    LDA $32                   
EDF4  ED E2 05 SBC $05E2                 
EDF7  A5 33    LDA $33                   
EDF9  ED E3 05 SBC $05E3                 
EDFC  90 1A    BCC $EE18                 
EDFE  A5 30    LDA $30                   
EE00  85 90    STA $90                   
EE02  A5 31    LDA $31                   
EE04  85 91    STA $91                   
EE06  18       CLC                       
EE07  A5 32    LDA $32                   
EE09  69 80    ADC #$80                  
EE0B  29 80    AND #$80                  
EE0D  85 92    STA $92                   
EE0F  A5 33    LDA $33                   
EE11  69 0E    ADC #$0E                  
EE13  85 93    STA $93                   
EE15  4C 2A EE JMP $EE2A                 

loc_EE18:  ; xrefs(1): $EDFC
EE18  A5 30    LDA $30                   
EE1A  85 90    STA $90                   
EE1C  A5 31    LDA $31                   
EE1E  85 91    STA $91                   
EE20  A5 32    LDA $32                   
EE22  29 80    AND #$80                  
EE24  85 92    STA $92                   
EE26  A5 33    LDA $33                   
EE28  85 93    STA $93                   

loc_EE2A:  ; xrefs(1): $EE15
EE2A  20 96 EB JSR $EB96                 
EE2D  A9 00    LDA #$00                  
EE2F  85 90    STA $90                   
EE31  A5 91    LDA $91                   
EE33  29 F0    AND #$F0                  
EE35  85 91    STA $91                   
EE37  A9 40    LDA #$40                  
EE39  85 6F    STA $6F                   
EE3B  20 F1 F0 JSR $F0F1                 
EE3E  A5 91    LDA $91                   
EE40  69 10    ADC #$10                  
EE42  85 91    STA $91                   
EE44  A9 60    LDA #$60                  
EE46  85 6F    STA $6F                   
EE48  20 F1 F0 JSR $F0F1                 
EE4B  20 0D EF JSR $EF0D                 
EE4E  60       RTS                       

sub_EE4F:  ; xrefs(1): $EDED
EE4F  A0 00    LDY #$00                  
EE51  AD A4 01 LDA $01A4                 
EE54  4A       LSR A                     
EE55  8D D6 05 STA $05D6                 
EE58  AD A5 01 LDA $01A5                 
EE5B  4A       LSR A                     
EE5C  8D D7 05 STA $05D7                 
EE5F  85 9D    STA $9D                   
EE61  F0 1A    BEQ $EE7D                 
EE63  18       CLC                       
EE64  AD A4 01 LDA $01A4                 
EE67  69 1E    ADC #$1E                  
EE69  38       SEC                       
EE6A  ED A5 01 SBC $01A5                 
EE6D  29 FE    AND #$FE                  
EE6F  AA       TAX                       

loc_EE70:  ; xrefs(1): $EE7B
EE70  BD 90 03 LDA $0390,X               
EE73  99 80 03 STA $0380,Y               
EE76  C8       INY                       
EE77  E8       INX                       
EE78  E8       INX                       
EE79  C6 9D    DEC $9D                   
EE7B  D0 F3    BNE $EE70                 

loc_EE7D:  ; xrefs(1): $EE61
EE7D  AD A4 01 LDA $01A4                 
EE80  29 FE    AND #$FE                  
EE82  AA       TAX                       
EE83  38       SEC                       
EE84  A9 0F    LDA #$0F                  
EE86  ED D7 05 SBC $05D7                 
EE89  85 9D    STA $9D                   

loc_EE8B:  ; xrefs(1): $EE96
EE8B  BD 90 03 LDA $0390,X               
EE8E  99 80 03 STA $0380,Y               
EE91  C8       INY                       
EE92  E8       INX                       
EE93  E8       INX                       
EE94  C6 9D    DEC $9D                   
EE96  D0 F3    BNE $EE8B                 
EE98  A0 23    LDY #$23                  
EE9A  A5 91    LDA $91                   
EE9C  29 10    AND #$10                  
EE9E  F0 04    BEQ $EEA4                 
EEA0  0A       ASL A                     
EEA1  0A       ASL A                     
EEA2  A0 27    LDY #$27                  

loc_EEA4:  ; xrefs(1): $EE9E
EEA4  85 9F    STA $9F                   
EEA6  A5 91    LDA $91                   
EEA8  29 0E    AND #$0E                  
EEAA  4A       LSR A                     
EEAB  48       PHA                       
EEAC  65 9F    ADC $9F                   
EEAE  AA       TAX                       
EEAF  8D D5 05 STA $05D5                 
EEB2  68       PLA                       
EEB3  18       CLC                       
EEB4  69 C0    ADC #$C0                  
EEB6  8D D2 05 STA $05D2                 
EEB9  8C D3 05 STY $05D3                 
EEBC  A5 91    LDA $91                   
EEBE  6A       ROR A                     
EEBF  A9 33    LDA #$33                  
EEC1  B0 02    BCS $EEC5                 
EEC3  A9 CC    LDA #$CC                  

loc_EEC5:  ; xrefs(1): $EEC1
EEC5  85 9E    STA $9E                   
EEC7  A0 00    LDY #$00                  
EEC9  20 DE EE JSR $EEDE                 
EECC  20 DE EE JSR $EEDE                 
EECF  20 DE EE JSR $EEDE                 
EED2  20 DE EE JSR $EEDE                 
EED5  20 DE EE JSR $EEDE                 
EED8  20 DE EE JSR $EEDE                 
EEDB  20 DE EE JSR $EEDE                 

sub_EEDE:  ; xrefs(7): $EEC9 $EECC $EECF $EED2 $EED5 $EED8 $EEDB
EEDE  B9 80 03 LDA $0380,Y               
EEE1  29 C0    AND #$C0                  
EEE3  C8       INY                       
EEE4  4A       LSR A                     
EEE5  4A       LSR A                     
EEE6  4A       LSR A                     
EEE7  4A       LSR A                     
EEE8  85 9F    STA $9F                   
EEEA  B9 80 03 LDA $0380,Y               
EEED  29 C0    AND #$C0                  
EEEF  05 9F    ORA $9F                   
EEF1  85 9F    STA $9F                   
EEF3  C8       INY                       
EEF4  A5 91    LDA $91                   
EEF6  6A       ROR A                     
EEF7  B0 04    BCS $EEFD                 
EEF9  46 9F    LSR $9F                   
EEFB  46 9F    LSR $9F                   

loc_EEFD:  ; xrefs(1): $EEF7
EEFD  BD 20 01 LDA $0120,X               
EF00  25 9E    AND $9E                   
EF02  05 9F    ORA $9F                   
EF04  9D 20 01 STA $0120,X               
EF07  18       CLC                       
EF08  8A       TXA                       
EF09  69 08    ADC #$08                  
EF0B  AA       TAX                       
EF0C  60       RTS                       

sub_EF0D:  ; xrefs(1): $EE4B
EF0D  18       CLC                       
EF0E  A0 23    LDY #$23                  
EF10  A5 91    LDA $91                   
EF12  29 10    AND #$10                  
EF14  49 10    EOR #$10                  
EF16  F0 04    BEQ $EF1C                 
EF18  0A       ASL A                     
EF19  0A       ASL A                     
EF1A  A0 27    LDY #$27                  

loc_EF1C:  ; xrefs(1): $EF16
EF1C  65 9A    ADC $9A                   
EF1E  85 9A    STA $9A                   
EF20  AA       TAX                       
EF21  8D D4 05 STA $05D4                 
EF24  18       CLC                       
EF25  AD D0 05 LDA $05D0                 
EF28  69 C0    ADC #$C0                  
EF2A  8D D0 05 STA $05D0                 
EF2D  8C D1 05 STY $05D1                 
EF30  A5 99    LDA $99                   
EF32  0A       ASL A                     
EF33  0A       ASL A                     
EF34  0A       ASL A                     
EF35  0A       ASL A                     
EF36  A9 0F    LDA #$0F                  
EF38  B0 02    BCS $EF3C                 
EF3A  A9 F0    LDA #$F0                  

loc_EF3C:  ; xrefs(1): $EF38
EF3C  85 9E    STA $9E                   
EF3E  A0 00    LDY #$00                  
EF40  20 48 EF JSR $EF48                 
EF43  A5 9A    LDA $9A                   
EF45  49 40    EOR #$40                  
EF47  AA       TAX                       

sub_EF48:  ; xrefs(1): $EF40
EF48  20 4B EF JSR $EF4B                 

sub_EF4B:  ; xrefs(1): $EF48
EF4B  20 54 EF JSR $EF54                 
EF4E  20 54 EF JSR $EF54                 
EF51  20 54 EF JSR $EF54                 

sub_EF54:  ; xrefs(3): $EF4B $EF4E $EF51
EF54  B9 91 03 LDA $0391,Y               
EF57  29 C0    AND #$C0                  
EF59  C8       INY                       
EF5A  C8       INY                       
EF5B  4A       LSR A                     
EF5C  4A       LSR A                     
EF5D  85 9F    STA $9F                   
EF5F  B9 91 03 LDA $0391,Y               
EF62  29 C0    AND #$C0                  
EF64  05 9F    ORA $9F                   
EF66  85 9F    STA $9F                   
EF68  C8       INY                       
EF69  C8       INY                       
EF6A  A5 99    LDA $99                   
EF6C  29 10    AND #$10                  
EF6E  D0 08    BNE $EF78                 
EF70  A5 9F    LDA $9F                   
EF72  4A       LSR A                     
EF73  4A       LSR A                     
EF74  4A       LSR A                     
EF75  4A       LSR A                     
EF76  85 9F    STA $9F                   

loc_EF78:  ; xrefs(1): $EF6E
EF78  BD 20 01 LDA $0120,X               
EF7B  25 9E    AND $9E                   
EF7D  05 9F    ORA $9F                   
EF7F  9D 20 01 STA $0120,X               
EF82  E8       INX                       
EF83  60       RTS                       

sub_EF84:  ; xrefs(4): $D71E $D758 $D9FF $E0C0
EF84  A9 04    LDA #$04                  
EF86  20 2C C9 JSR $C92C                 
EF89  4C 04 80 JMP $8004                 

sub_EF8C:  ; xrefs(20): $D1A2 $D1C9 $D267 $D2B6 $D2BB $D51B $D6D8 $D7A9 $D86B $D8AC
EF8C  48       PHA                       
EF8D  A9 04    LDA #$04                  
EF8F  20 2C C9 JSR $C92C                 
EF92  68       PLA                       
EF93  4C 07 80 JMP $8007                 

; ---- data $EF96-$EF9F (10 bytes) ----
EF96  48 A9 04 20 2C C9 68 4C 0A 80                    |H.. ,.hL..

sub_EFA0:  ; xrefs(2): $EFC7 $F0F1
EFA0  A5 91    LDA $91                   
EFA2  4A       LSR A                     
EFA3  4A       LSR A                     
EFA4  4A       LSR A                     
EFA5  4A       LSR A                     
EFA6  85 9F    STA $9F                   
EFA8  18       CLC                       
EFA9  A5 93    LDA $93                   
EFAB  29 F0    AND #$F0                  
EFAD  65 9F    ADC $9F                   
EFAF  A8       TAY                       
EFB0  B1 1E    LDA ($1E),Y               
EFB2  85 95    STA $95                   
EFB4  A9 00    LDA #$00                  
EFB6  46 95    LSR $95                   
EFB8  6A       ROR A                     
EFB9  46 95    LSR $95                   
EFBB  6A       ROR A                     
EFBC  65 14    ADC $14                   
EFBE  85 94    STA $94                   
EFC0  A5 95    LDA $95                   
EFC2  65 15    ADC $15                   
EFC4  85 95    STA $95                   
EFC6  60       RTS                       

sub_EFC7:  ; xrefs(2): $EDDC $EDEA
EFC7  20 A0 EF JSR $EFA0                 
EFCA  A5 10    LDA $10                   
EFCC  85 29    STA $29                   
EFCE  A5 91    LDA $91                   
EFD0  29 0F    AND #$0F                  
EFD2  4A       LSR A                     
EFD3  A8       TAY                       
EFD4  84 9D    STY $9D                   
EFD6  B1 94    LDA ($94),Y               
EFD8  20 31 F0 JSR $F031                 
EFDB  18       CLC                       
EFDC  A5 9D    LDA $9D                   
EFDE  69 08    ADC #$08                  
EFE0  A8       TAY                       
EFE1  84 9D    STY $9D                   
EFE3  B1 94    LDA ($94),Y               
EFE5  20 31 F0 JSR $F031                 
EFE8  18       CLC                       
EFE9  A5 9D    LDA $9D                   
EFEB  69 08    ADC #$08                  
EFED  A8       TAY                       
EFEE  84 9D    STY $9D                   
EFF0  B1 94    LDA ($94),Y               
EFF2  20 31 F0 JSR $F031                 
EFF5  18       CLC                       
EFF6  A5 9D    LDA $9D                   
EFF8  69 08    ADC #$08                  
EFFA  A8       TAY                       
EFFB  84 9D    STY $9D                   
EFFD  B1 94    LDA ($94),Y               
EFFF  20 31 F0 JSR $F031                 
F002  18       CLC                       
F003  A5 9D    LDA $9D                   
F005  69 08    ADC #$08                  
F007  A8       TAY                       
F008  84 9D    STY $9D                   
F00A  B1 94    LDA ($94),Y               
F00C  20 31 F0 JSR $F031                 
F00F  18       CLC                       
F010  A5 9D    LDA $9D                   
F012  69 08    ADC #$08                  
F014  A8       TAY                       
F015  84 9D    STY $9D                   
F017  B1 94    LDA ($94),Y               
F019  20 31 F0 JSR $F031                 
F01C  18       CLC                       
F01D  A5 9D    LDA $9D                   
F01F  69 08    ADC #$08                  
F021  A8       TAY                       
F022  84 9D    STY $9D                   
F024  B1 94    LDA ($94),Y               
F026  20 31 F0 JSR $F031                 
F029  18       CLC                       
F02A  A5 9D    LDA $9D                   
F02C  69 08    ADC #$08                  
F02E  A8       TAY                       
F02F  B1 94    LDA ($94),Y               

sub_F031:  ; xrefs(7): $EFD8 $EFE5 $EFF2 $EFFF $F00C $F019 $F026
F031  A4 13    LDY $13                   
F033  0A       ASL A                     
F034  90 02    BCC $F038                 
F036  C8       INY                       
F037  C8       INY                       

loc_F038:  ; xrefs(1): $F034
F038  0A       ASL A                     
F039  90 02    BCC $F03D                 
F03B  C8       INY                       
F03C  18       CLC                       

loc_F03D:  ; xrefs(1): $F039
F03D  65 12    ADC $12                   
F03F  85 97    STA $97                   
F041  90 01    BCC $F044                 
F043  C8       INY                       

loc_F044:  ; xrefs(1): $F041
F044  84 98    STY $98                   
F046  A5 91    LDA $91                   
F048  0A       ASL A                     
F049  29 02    AND #$02                  
F04B  A8       TAY                       
F04C  A5 11    LDA $11                   
F04E  85 2A    STA $2A                   
F050  48       PHA                       
F051  84 9F    STY $9F                   
F053  B1 97    LDA ($97),Y               
F055  A8       TAY                       
F056  B1 16    LDA ($16),Y               
F058  AA       TAX                       
F059  29 20    AND #$20                  
F05B  F0 0D    BEQ $F06A                 
F05D  20 D8 F0 JSR $F0D8                 
F060  F0 08    BEQ $F06A                 
F062  B1 18    LDA ($18),Y               
F064  A8       TAY                       
F065  B1 16    LDA ($16),Y               
F067  4C 6B F0 JMP $F06B                 

loc_F06A:  ; xrefs(2): $F05B $F060
F06A  8A       TXA                       

loc_F06B:  ; xrefs(1): $F067
F06B  A6 6F    LDX $6F                   
F06D  9D 90 03 STA $0390,X               
F070  98       TYA                       
F071  0A       ASL A                     
F072  90 04    BCC $F078                 
F074  E6 2A    INC $2A                   
F076  E6 2A    INC $2A                   

loc_F078:  ; xrefs(1): $F072
F078  0A       ASL A                     
F079  90 02    BCC $F07D                 
F07B  E6 2A    INC $2A                   

loc_F07D:  ; xrefs(1): $F079
F07D  A8       TAY                       
F07E  A5 90    LDA $90                   
F080  10 02    BPL $F084                 
F082  C8       INY                       
F083  C8       INY                       

loc_F084:  ; xrefs(1): $F080
F084  B1 29    LDA ($29),Y               
F086  9D 00 03 STA $0300,X               
F089  C8       INY                       
F08A  E8       INX                       
F08B  B1 29    LDA ($29),Y               
F08D  9D 00 03 STA $0300,X               
F090  E8       INX                       
F091  68       PLA                       
F092  85 2A    STA $2A                   
F094  E6 9F    INC $9F                   
F096  A4 9F    LDY $9F                   
F098  B1 97    LDA ($97),Y               
F09A  A8       TAY                       
F09B  B1 16    LDA ($16),Y               
F09D  48       PHA                       
F09E  29 20    AND #$20                  
F0A0  F0 0E    BEQ $F0B0                 
F0A2  20 D8 F0 JSR $F0D8                 
F0A5  F0 09    BEQ $F0B0                 
F0A7  68       PLA                       
F0A8  B1 18    LDA ($18),Y               
F0AA  A8       TAY                       
F0AB  B1 16    LDA ($16),Y               
F0AD  4C B1 F0 JMP $F0B1                 

loc_F0B0:  ; xrefs(2): $F0A0 $F0A5
F0B0  68       PLA                       

loc_F0B1:  ; xrefs(1): $F0AD
F0B1  9D 90 03 STA $0390,X               
F0B4  98       TYA                       
F0B5  0A       ASL A                     
F0B6  90 04    BCC $F0BC                 
F0B8  E6 2A    INC $2A                   
F0BA  E6 2A    INC $2A                   

loc_F0BC:  ; xrefs(1): $F0B6
F0BC  0A       ASL A                     
F0BD  90 02    BCC $F0C1                 
F0BF  E6 2A    INC $2A                   

loc_F0C1:  ; xrefs(1): $F0BD
F0C1  A8       TAY                       
F0C2  A5 90    LDA $90                   
F0C4  10 02    BPL $F0C8                 
F0C6  C8       INY                       
F0C7  C8       INY                       

loc_F0C8:  ; xrefs(1): $F0C4
F0C8  B1 29    LDA ($29),Y               
F0CA  9D 00 03 STA $0300,X               
F0CD  C8       INY                       
F0CE  E8       INX                       
F0CF  B1 29    LDA ($29),Y               
F0D1  9D 00 03 STA $0300,X               
F0D4  E8       INX                       
F0D5  86 6F    STX $6F                   
F0D7  60       RTS                       

sub_F0D8:  ; xrefs(4): $F05D $F0A2 $F16D $F1B4
F0D8  98       TYA                       
F0D9  86 2B    STX $2B                   
F0DB  48       PHA                       
F0DC  4A       LSR A                     
F0DD  4A       LSR A                     
F0DE  4A       LSR A                     
F0DF  AA       TAX                       
F0E0  BD 40 05 LDA $0540,X               
F0E3  85 2C    STA $2C                   
F0E5  68       PLA                       
F0E6  29 07    AND #$07                  
F0E8  AA       TAX                       
F0E9  BD 36 D1 LDA $D136,X               
F0EC  A6 2B    LDX $2B                   
F0EE  25 2C    AND $2C                   
F0F0  60       RTS                       

sub_F0F1:  ; xrefs(2): $EE3B $EE48
F0F1  20 A0 EF JSR $EFA0                 
F0F4  A5 10    LDA $10                   
F0F6  85 29    STA $29                   
F0F8  A5 93    LDA $93                   
F0FA  29 0E    AND #$0E                  
F0FC  0A       ASL A                     
F0FD  0A       ASL A                     
F0FE  85 9D    STA $9D                   
F100  A8       TAY                       
F101  B1 94    LDA ($94),Y               
F103  20 42 F1 JSR $F142                 
F106  E6 9D    INC $9D                   
F108  A4 9D    LDY $9D                   
F10A  B1 94    LDA ($94),Y               
F10C  20 42 F1 JSR $F142                 
F10F  E6 9D    INC $9D                   
F111  A4 9D    LDY $9D                   
F113  B1 94    LDA ($94),Y               
F115  20 42 F1 JSR $F142                 
F118  E6 9D    INC $9D                   
F11A  A4 9D    LDY $9D                   
F11C  B1 94    LDA ($94),Y               
F11E  20 42 F1 JSR $F142                 
F121  E6 9D    INC $9D                   
F123  A4 9D    LDY $9D                   
F125  B1 94    LDA ($94),Y               
F127  20 42 F1 JSR $F142                 
F12A  E6 9D    INC $9D                   
F12C  A4 9D    LDY $9D                   
F12E  B1 94    LDA ($94),Y               
F130  20 42 F1 JSR $F142                 
F133  E6 9D    INC $9D                   
F135  A4 9D    LDY $9D                   
F137  B1 94    LDA ($94),Y               
F139  20 42 F1 JSR $F142                 
F13C  E6 9D    INC $9D                   
F13E  A4 9D    LDY $9D                   
F140  B1 94    LDA ($94),Y               

sub_F142:  ; xrefs(7): $F103 $F10C $F115 $F11E $F127 $F130 $F139
F142  A4 13    LDY $13                   
F144  0A       ASL A                     
F145  90 02    BCC $F149                 
F147  C8       INY                       
F148  C8       INY                       

loc_F149:  ; xrefs(1): $F145
F149  0A       ASL A                     
F14A  90 02    BCC $F14E                 
F14C  C8       INY                       
F14D  18       CLC                       

loc_F14E:  ; xrefs(1): $F14A
F14E  65 12    ADC $12                   
F150  85 97    STA $97                   
F152  90 01    BCC $F155                 
F154  C8       INY                       

loc_F155:  ; xrefs(1): $F152
F155  84 98    STY $98                   
F157  A5 93    LDA $93                   
F159  29 01    AND #$01                  
F15B  A8       TAY                       
F15C  A5 11    LDA $11                   
F15E  85 2A    STA $2A                   
F160  48       PHA                       
F161  84 9F    STY $9F                   
F163  B1 97    LDA ($97),Y               
F165  A8       TAY                       
F166  B1 16    LDA ($16),Y               
F168  AA       TAX                       
F169  29 20    AND #$20                  
F16B  F0 0D    BEQ $F17A                 
F16D  20 D8 F0 JSR $F0D8                 
F170  F0 08    BEQ $F17A                 
F172  B1 18    LDA ($18),Y               
F174  A8       TAY                       
F175  B1 16    LDA ($16),Y               
F177  4C 7B F1 JMP $F17B                 

loc_F17A:  ; xrefs(2): $F16B $F170
F17A  8A       TXA                       

loc_F17B:  ; xrefs(1): $F177
F17B  A6 6F    LDX $6F                   
F17D  9D 51 03 STA $0351,X               
F180  98       TYA                       
F181  0A       ASL A                     
F182  90 04    BCC $F188                 
F184  E6 2A    INC $2A                   
F186  E6 2A    INC $2A                   

loc_F188:  ; xrefs(1): $F182
F188  0A       ASL A                     
F189  90 02    BCC $F18D                 
F18B  E6 2A    INC $2A                   

loc_F18D:  ; xrefs(1): $F189
F18D  A8       TAY                       
F18E  A5 92    LDA $92                   
F190  10 01    BPL $F193                 
F192  C8       INY                       

loc_F193:  ; xrefs(1): $F190
F193  B1 29    LDA ($29),Y               
F195  9D 00 03 STA $0300,X               
F198  C8       INY                       
F199  C8       INY                       
F19A  E8       INX                       
F19B  B1 29    LDA ($29),Y               
F19D  9D 00 03 STA $0300,X               
F1A0  E8       INX                       
F1A1  68       PLA                       
F1A2  85 2A    STA $2A                   
F1A4  E6 9F    INC $9F                   
F1A6  E6 9F    INC $9F                   
F1A8  A4 9F    LDY $9F                   
F1AA  B1 97    LDA ($97),Y               
F1AC  A8       TAY                       
F1AD  B1 16    LDA ($16),Y               
F1AF  48       PHA                       
F1B0  29 20    AND #$20                  
F1B2  F0 0E    BEQ $F1C2                 
F1B4  20 D8 F0 JSR $F0D8                 
F1B7  F0 09    BEQ $F1C2                 
F1B9  68       PLA                       
F1BA  B1 18    LDA ($18),Y               
F1BC  A8       TAY                       
F1BD  B1 16    LDA ($16),Y               
F1BF  4C C3 F1 JMP $F1C3                 

loc_F1C2:  ; xrefs(2): $F1B2 $F1B7
F1C2  68       PLA                       

loc_F1C3:  ; xrefs(1): $F1BF
F1C3  9D 51 03 STA $0351,X               
F1C6  98       TYA                       
F1C7  0A       ASL A                     
F1C8  90 04    BCC $F1CE                 
F1CA  E6 2A    INC $2A                   
F1CC  E6 2A    INC $2A                   

loc_F1CE:  ; xrefs(1): $F1C8
F1CE  0A       ASL A                     
F1CF  90 02    BCC $F1D3                 
F1D1  E6 2A    INC $2A                   

loc_F1D3:  ; xrefs(1): $F1CF
F1D3  A8       TAY                       
F1D4  A5 92    LDA $92                   
F1D6  10 01    BPL $F1D9                 
F1D8  C8       INY                       

loc_F1D9:  ; xrefs(1): $F1D6
F1D9  B1 29    LDA ($29),Y               
F1DB  9D 00 03 STA $0300,X               
F1DE  C8       INY                       
F1DF  C8       INY                       
F1E0  E8       INX                       
F1E1  B1 29    LDA ($29),Y               
F1E3  9D 00 03 STA $0300,X               
F1E6  E8       INX                       
F1E7  86 6F    STX $6F                   
F1E9  60       RTS                       

sub_F1EA:  ; xrefs(1): $CD9C
F1EA  20 C8 F2 JSR $F2C8                 
F1ED  AD D8 05 LDA $05D8                 
F1F0  F0 58    BEQ $F24A                 
F1F2  30 27    BMI $F21B                 
F1F4  4D B7 05 EOR $05B7                 
F1F7  30 21    BMI $F21A                 
F1F9  18       CLC                       
F1FA  A5 30    LDA $30                   
F1FC  6D B6 05 ADC $05B6                 
F1FF  85 30    STA $30                   
F201  A5 31    LDA $31                   
F203  6D B7 05 ADC $05B7                 
F206  85 31    STA $31                   
F208  A5 30    LDA $30                   
F20A  C5 38    CMP $38                   
F20C  A5 31    LDA $31                   
F20E  E5 39    SBC $39                   
F210  B0 08    BCS $F21A                 
F212  A5 38    LDA $38                   
F214  85 30    STA $30                   
F216  A5 39    LDA $39                   
F218  85 31    STA $31                   

loc_F21A:  ; xrefs(3): $F1F7 $F210 $F21E
F21A  60       RTS                       

loc_F21B:  ; xrefs(1): $F1F2
F21B  4D B7 05 EOR $05B7                 
F21E  30 FA    BMI $F21A                 
F220  18       CLC                       
F221  A5 30    LDA $30                   
F223  6D B6 05 ADC $05B6                 
F226  85 30    STA $30                   
F228  A5 31    LDA $31                   
F22A  6D B7 05 ADC $05B7                 
F22D  85 31    STA $31                   
F22F  A5 30    LDA $30                   
F231  C5 3A    CMP $3A                   
F233  A5 31    LDA $31                   
F235  E5 3B    SBC $3B                   
F237  90 11    BCC $F24A                 
F239  E9 10    SBC #$10                  
F23B  F0 02    BEQ $F23F                 
F23D  B0 0B    BCS $F24A                 

loc_F23F:  ; xrefs(1): $F23B
F23F  38       SEC                       
F240  A5 3A    LDA $3A                   
F242  85 30    STA $30                   
F244  A5 3B    LDA $3B                   
F246  E9 10    SBC #$10                  
F248  85 31    STA $31                   

loc_F24A:  ; xrefs(3): $F1F0 $F237 $F23D
F24A  60       RTS                       

sub_F24B:  ; xrefs(1): $CD9F
F24B  A5 70    LDA $70                   
F24D  C9 3C    CMP #$3C                  
F24F  D0 16    BNE $F267                 
F251  AD C3 05 LDA $05C3                 
F254  F0 04    BEQ $F25A                 
F256  C9 30    CMP #$30                  
F258  90 52    BCC $F2AC                 

loc_F25A:  ; xrefs(1): $F254
F25A  38       SEC                       
F25B  A5 32    LDA $32                   
F25D  E5 34    SBC $34                   
F25F  85 32    STA $32                   
F261  B0 49    BCS $F2AC                 
F263  C6 33    DEC $33                   
F265  90 45    BCC $F2AC                 

loc_F267:  ; xrefs(1): $F24F
F267  20 52 F3 JSR $F352                 
F26A  AD D8 05 LDA $05D8                 
F26D  F0 58    BEQ $F2C7                 
F26F  30 27    BMI $F298                 
F271  4D B9 05 EOR $05B9                 
F274  30 21    BMI $F297                 
F276  18       CLC                       
F277  A5 32    LDA $32                   
F279  6D B8 05 ADC $05B8                 
F27C  85 32    STA $32                   
F27E  A5 33    LDA $33                   
F280  6D B9 05 ADC $05B9                 
F283  85 33    STA $33                   

loc_F285:  ; xrefs(2): $F2B4 $F2BA
F285  A5 32    LDA $32                   
F287  C5 3C    CMP $3C                   
F289  A5 33    LDA $33                   
F28B  E5 3D    SBC $3D                   
F28D  B0 08    BCS $F297                 
F28F  A5 3C    LDA $3C                   
F291  85 32    STA $32                   
F293  A5 3D    LDA $3D                   
F295  85 33    STA $33                   

loc_F297:  ; xrefs(3): $F274 $F28D $F29B
F297  60       RTS                       

loc_F298:  ; xrefs(1): $F26F
F298  4D B9 05 EOR $05B9                 
F29B  30 FA    BMI $F297                 
F29D  18       CLC                       
F29E  A5 32    LDA $32                   
F2A0  6D B8 05 ADC $05B8                 
F2A3  85 32    STA $32                   
F2A5  A5 33    LDA $33                   
F2A7  6D B9 05 ADC $05B9                 
F2AA  85 33    STA $33                   

loc_F2AC:  ; xrefs(3): $F258 $F261 $F265
F2AC  A5 32    LDA $32                   
F2AE  C5 3E    CMP $3E                   
F2B0  A5 33    LDA $33                   
F2B2  E5 3F    SBC $3F                   
F2B4  90 CF    BCC $F285                 
F2B6  E9 10    SBC #$10                  
F2B8  F0 02    BEQ $F2BC                 
F2BA  B0 C9    BCS $F285                 

loc_F2BC:  ; xrefs(1): $F2B8
F2BC  38       SEC                       
F2BD  A5 3E    LDA $3E                   
F2BF  85 32    STA $32                   
F2C1  A5 3F    LDA $3F                   
F2C3  E9 10    SBC #$10                  
F2C5  85 33    STA $33                   

loc_F2C7:  ; xrefs(1): $F26D
F2C7  60       RTS                       

sub_F2C8:  ; xrefs(1): $F1EA
F2C8  A9 00    LDA #$00                  
F2CA  8D D8 05 STA $05D8                 
F2CD  AD E4 05 LDA $05E4                 
F2D0  85 92    STA $92                   
F2D2  18       CLC                       
F2D3  6D E5 05 ADC $05E5                 
F2D6  85 93    STA $93                   
F2D8  4C DC F2 JMP $F2DC                 

loc_F2DB:  ; xrefs(1): $F2E9
F2DB  60       RTS                       

loc_F2DC:  ; xrefs(1): $F2D8
F2DC  38       SEC                       
F2DD  A5 3A    LDA $3A                   
F2DF  E5 38    SBC $38                   
F2E1  85 94    STA $94                   
F2E3  A5 3B    LDA $3B                   
F2E5  E5 39    SBC $39                   
F2E7  C9 11    CMP #$11                  
F2E9  90 F0    BCC $F2DB                 
F2EB  A5 39    LDA $39                   
F2ED  85 95    STA $95                   
F2EF  C6 95    DEC $95                   
F2F1  A5 30    LDA $30                   
F2F3  C5 38    CMP $38                   
F2F5  A5 31    LDA $31                   
F2F7  E5 95    SBC $95                   
F2F9  F0 02    BEQ $F2FD                 
F2FB  B0 04    BCS $F301                 

loc_F2FD:  ; xrefs(1): $F2F9
F2FD  A9 00    LDA #$00                  
F2FF  85 92    STA $92                   

loc_F301:  ; xrefs(1): $F2FB
F301  38       SEC                       
F302  A5 3A    LDA $3A                   
F304  85 94    STA $94                   
F306  A5 3B    LDA $3B                   
F308  E9 10    SBC #$10                  
F30A  85 95    STA $95                   
F30C  A5 94    LDA $94                   
F30E  C5 30    CMP $30                   
F310  A5 95    LDA $95                   
F312  E5 31    SBC $31                   
F314  B0 04    BCS $F31A                 
F316  A9 10    LDA #$10                  
F318  85 93    STA $93                   

loc_F31A:  ; xrefs(1): $F314
F31A  18       CLC                       
F31B  A5 30    LDA $30                   
F31D  85 90    STA $90                   
F31F  A5 31    LDA $31                   
F321  65 92    ADC $92                   
F323  85 91    STA $91                   
F325  38       SEC                       
F326  A5 90    LDA $90                   
F328  E5 80    SBC $80                   
F32A  85 96    STA $96                   
F32C  A5 91    LDA $91                   
F32E  E5 81    SBC $81                   
F330  85 97    STA $97                   
F332  B0 1A    BCS $F34E                 
F334  18       CLC                       
F335  A5 31    LDA $31                   
F337  65 93    ADC $93                   
F339  85 91    STA $91                   
F33B  38       SEC                       
F33C  A5 80    LDA $80                   
F33E  E5 90    SBC $90                   
F340  85 96    STA $96                   
F342  A5 81    LDA $81                   
F344  E5 91    SBC $91                   
F346  85 97    STA $97                   
F348  90 07    BCC $F351                 
F34A  EE D8 05 INC $05D8                 
F34D  60       RTS                       

loc_F34E:  ; xrefs(1): $F332
F34E  CE D8 05 DEC $05D8                 

loc_F351:  ; xrefs(1): $F348
F351  60       RTS                       

sub_F352:  ; xrefs(1): $F267
F352  A9 06    LDA #$06                  
F354  85 92    STA $92                   
F356  18       CLC                       
F357  69 02    ADC #$02                  
F359  85 93    STA $93                   
F35B  4C 67 F3 JMP $F367                 

; ---- data $F35E-$F366 (9 bytes) ----
F35E  A9 09 85 92 18 69 01 85 93                       |.....i...

loc_F367:  ; xrefs(1): $F35B
F367  A9 00    LDA #$00                  
F369  8D D8 05 STA $05D8                 
F36C  4C 70 F3 JMP $F370                 

loc_F36F:  ; xrefs(1): $F37D
F36F  60       RTS                       

loc_F370:  ; xrefs(1): $F36C
F370  38       SEC                       
F371  A5 3E    LDA $3E                   
F373  E5 3C    SBC $3C                   
F375  85 94    STA $94                   
F377  A5 3F    LDA $3F                   
F379  E5 3D    SBC $3D                   
F37B  C9 14    CMP #$14                  
F37D  90 F0    BCC $F36F                 
F37F  A5 3D    LDA $3D                   
F381  85 95    STA $95                   
F383  C6 95    DEC $95                   
F385  A5 32    LDA $32                   
F387  C5 3C    CMP $3C                   
F389  A5 33    LDA $33                   
F38B  E5 95    SBC $95                   
F38D  F0 02    BEQ $F391                 
F38F  B0 04    BCS $F395                 

loc_F391:  ; xrefs(1): $F38D
F391  A9 00    LDA #$00                  
F393  85 92    STA $92                   

loc_F395:  ; xrefs(1): $F38F
F395  38       SEC                       
F396  A5 3E    LDA $3E                   
F398  85 94    STA $94                   
F39A  A5 3F    LDA $3F                   
F39C  E9 10    SBC #$10                  
F39E  85 95    STA $95                   
F3A0  A5 94    LDA $94                   
F3A2  C5 32    CMP $32                   
F3A4  A5 95    LDA $95                   
F3A6  E5 33    SBC $33                   
F3A8  B0 04    BCS $F3AE                 
F3AA  A9 0F    LDA #$0F                  
F3AC  85 93    STA $93                   

loc_F3AE:  ; xrefs(1): $F3A8
F3AE  18       CLC                       
F3AF  A5 32    LDA $32                   
F3B1  85 90    STA $90                   
F3B3  A5 33    LDA $33                   
F3B5  65 92    ADC $92                   
F3B7  85 91    STA $91                   
F3B9  A5 90    LDA $90                   
F3BB  C5 82    CMP $82                   
F3BD  A5 91    LDA $91                   
F3BF  E5 83    SBC $83                   
F3C1  B0 15    BCS $F3D8                 
F3C3  18       CLC                       
F3C4  A5 33    LDA $33                   
F3C6  65 93    ADC $93                   
F3C8  85 91    STA $91                   
F3CA  A5 90    LDA $90                   
F3CC  E5 82    SBC $82                   
F3CE  A5 91    LDA $91                   
F3D0  E5 83    SBC $83                   
F3D2  B0 07    BCS $F3DB                 
F3D4  EE D8 05 INC $05D8                 
F3D7  60       RTS                       

loc_F3D8:  ; xrefs(1): $F3C1
F3D8  CE D8 05 DEC $05D8                 

loc_F3DB:  ; xrefs(1): $F3D2
F3DB  60       RTS                       

; ---- data $F3DC-$F3E4 (9 bytes) ----
F3DC  20 21 F4 20 3F F4 4C 98 C9                       | !. ?.L..

sub_F3E5:  ; xrefs(2): $DBAB $DBDC
F3E5  20 21 F4 JSR $F421                 
F3E8  20 61 F4 JSR $F461                 
F3EB  4C 98 C9 JMP $C998                 

; ---- data $F3EE-$F3F8 (11 bytes) ----
F3EE  A0 02 20 21 F4 20 E2 F6 4C 98 C9                 |.. !. ..L..

loc_F3F9:  ; xrefs(2): $D447 $E4DA
F3F9  20 21 F4 JSR $F421                 
F3FC  A2 00    LDX #$00                  
F3FE  86 9F    STX $9F                   
F400  20 E6 F6 JSR $F6E6                 
F403  4C 98 C9 JMP $C998                 

; ---- data $F406-$F420 (27 bytes) ----
F406  48 E6 47 A9 06 8D 00 80 A9 0C 8D 01 80 A9 07 8D  |H.G.............
F416  00 80 A9 0D 8D 01 80 C6 47 68 60                 |........Gh`

sub_F421:  ; xrefs(2): $F3E5 $F3F9
F421  48       PHA                       
F422  20 92 C9 JSR $C992                 
F425  E6 47    INC $47                   
F427  A9 06    LDA #$06                  
F429  8D 00 80 STA $8000                 
F42C  A9 0A    LDA #$0A                  
F42E  8D 01 80 STA $8001                 
F431  A9 07    LDA #$07                  
F433  8D 00 80 STA $8000                 
F436  A9 0B    LDA #$0B                  
F438  8D 01 80 STA $8001                 
F43B  C6 47    DEC $47                   
F43D  68       PLA                       
F43E  60       RTS                       

sub_F43F:  ; xrefs(3): $CB5E $CD40 $CF73
F43F  48       PHA                       
F440  A5 90    LDA $90                   
F442  46 91    LSR $91                   
F444  6A       ROR A                     
F445  46 91    LSR $91                   
F447  6A       ROR A                     
F448  46 91    LSR $91                   
F44A  6A       ROR A                     
F44B  46 91    LSR $91                   
F44D  6A       ROR A                     
F44E  85 90    STA $90                   
F450  A5 92    LDA $92                   
F452  46 93    LSR $93                   
F454  6A       ROR A                     
F455  46 93    LSR $93                   
F457  6A       ROR A                     
F458  46 93    LSR $93                   
F45A  6A       ROR A                     
F45B  46 93    LSR $93                   
F45D  6A       ROR A                     
F45E  85 92    STA $92                   
F460  68       PLA                       

sub_F461:  ; xrefs(2): $F3E8 $FA0E
F461  84 9B    STY $9B                   
F463  0A       ASL A                     
F464  26 9B    ROL $9B                   
F466  0A       ASL A                     
F467  26 9B    ROL $9B                   
F469  18       CLC                       
F46A  6D 04 80 ADC $8004                 
F46D  85 9A    STA $9A                   
F46F  AD 05 80 LDA $8005                 
F472  65 9B    ADC $9B                   
F474  85 9B    STA $9B                   
F476  A0 01    LDY #$01                  
F478  B1 9A    LDA ($9A),Y               
F47A  45 9E    EOR $9E                   
F47C  85 9E    STA $9E                   
F47E  6A       ROR A                     
F47F  6A       ROR A                     
F480  29 03    AND #$03                  
F482  AA       TAX                       
F483  88       DEY                       
F484  B1 9A    LDA ($9A),Y               
F486  F0 04    BEQ $F48C                 
F488  30 57    BMI $F4E1                 
F48A  95 42    STA $42,X                 

loc_F48C:  ; xrefs(1): $F486
F48C  A5 9E    LDA $9E                   
F48E  29 40    AND #$40                  
F490  85 94    STA $94                   
F492  A5 9E    LDA $9E                   
F494  29 80    AND #$80                  
F496  85 95    STA $95                   
F498  C8       INY                       
F499  C8       INY                       
F49A  B1 9A    LDA ($9A),Y               
F49C  85 96    STA $96                   
F49E  C8       INY                       
F49F  B1 9A    LDA ($9A),Y               
F4A1  85 97    STA $97                   
F4A3  A0 00    LDY #$00                  
F4A5  B1 96    LDA ($96),Y               
F4A7  85 9A    STA $9A                   
F4A9  C8       INY                       
F4AA  B1 96    LDA ($96),Y               
F4AC  85 9B    STA $9B                   
F4AE  88       DEY                       
F4AF  B1 9A    LDA ($9A),Y               
F4B1  85 9C    STA $9C                   
F4B3  AA       TAX                       
F4B4  38       SEC                       
F4B5  A5 9A    LDA $9A                   
F4B7  E9 01    SBC #$01                  
F4B9  85 9A    STA $9A                   
F4BB  B0 02    BCS $F4BF                 
F4BD  C6 9B    DEC $9B                   

loc_F4BF:  ; xrefs(1): $F4BB
F4BF  A0 02    LDY #$02                  
F4C1  E6 6B    INC $6B                   
F4C3  A5 6B    LDA $6B                   
F4C5  6A       ROR A                     
F4C6  90 08    BCC $F4D0                 
F4C8  A6 6C    LDX $6C                   
F4CA  20 E2 F4 JSR $F4E2                 
F4CD  86 6C    STX $6C                   
F4CF  60       RTS                       

loc_F4D0:  ; xrefs(1): $F4C6
F4D0  A5 6A    LDA $6A                   
F4D2  C9 3A    CMP #$3A                  
F4D4  B0 0B    BCS $F4E1                 
F4D6  8A       TXA                       
F4D7  0A       ASL A                     
F4D8  A8       TAY                       
F4D9  C8       INY                       
F4DA  A6 6D    LDX $6D                   
F4DC  20 E1 F5 JSR $F5E1                 
F4DF  86 6D    STX $6D                   

loc_F4E1:  ; xrefs(2): $F488 $F4D4
F4E1  60       RTS                       

sub_F4E2:  ; xrefs(4): $F4CA $F548 $F5B5 $F5DD
F4E2  A5 93    LDA $93                   
F4E4  F0 21    BEQ $F507                 
F4E6  C9 0F    CMP #$0F                  
F4E8  F0 3F    BEQ $F529                 
F4EA  A5 92    LDA $92                   
F4EC  30 56    BMI $F544                 
F4EE  A5 95    LDA $95                   
F4F0  F0 0A    BEQ $F4FC                 
F4F2  B1 9A    LDA ($9A),Y               
F4F4  49 FF    EOR #$FF                  
F4F6  38       SEC                       
F4F7  E9 0F    SBC #$0F                  
F4F9  4C FE F4 JMP $F4FE                 

loc_F4FC:  ; xrefs(1): $F4F0
F4FC  B1 9A    LDA ($9A),Y               

loc_F4FE:  ; xrefs(1): $F4F9
F4FE  10 44    BPL $F544                 
F500  18       CLC                       
F501  65 92    ADC $92                   
F503  30 46    BMI $F54B                 
F505  10 3D    BPL $F544                 

loc_F507:  ; xrefs(1): $F4E4
F507  A5 95    LDA $95                   
F509  F0 0A    BEQ $F515                 
F50B  B1 9A    LDA ($9A),Y               
F50D  49 FF    EOR #$FF                  
F50F  38       SEC                       
F510  E9 0F    SBC #$0F                  
F512  4C 17 F5 JMP $F517                 

loc_F515:  ; xrefs(1): $F509
F515  B1 9A    LDA ($9A),Y               

loc_F517:  ; xrefs(1): $F512
F517  30 07    BMI $F520                 
F519  18       CLC                       
F51A  65 92    ADC $92                   
F51C  90 2D    BCC $F54B                 
F51E  B0 24    BCS $F544                 

loc_F520:  ; xrefs(1): $F517
F520  18       CLC                       
F521  65 92    ADC $92                   
F523  C5 92    CMP $92                   
F525  90 24    BCC $F54B                 
F527  B0 1B    BCS $F544                 

loc_F529:  ; xrefs(1): $F4E8
F529  A5 92    LDA $92                   
F52B  10 17    BPL $F544                 
F52D  A5 95    LDA $95                   
F52F  F0 0A    BEQ $F53B                 
F531  B1 9A    LDA ($9A),Y               
F533  49 FF    EOR #$FF                  
F535  38       SEC                       
F536  E9 0F    SBC #$0F                  
F538  4C 3D F5 JMP $F53D                 

loc_F53B:  ; xrefs(1): $F52F
F53B  B1 9A    LDA ($9A),Y               

loc_F53D:  ; xrefs(1): $F538
F53D  30 05    BMI $F544                 
F53F  18       CLC                       
F540  65 92    ADC $92                   
F542  B0 07    BCS $F54B                 

loc_F544:  ; xrefs(7): $F4EC $F4FE $F505 $F51E $F527 $F52B $F53D
F544  C8       INY                       
F545  C8       INY                       
F546  C6 9C    DEC $9C                   
F548  D0 98    BNE $F4E2                 
F54A  60       RTS                       

loc_F54B:  ; xrefs(4): $F503 $F51C $F525 $F542
F54B  85 9F    STA $9F                   
F54D  C8       INY                       
F54E  A5 91    LDA $91                   
F550  F0 21    BEQ $F573                 
F552  C9 0F    CMP #$0F                  
F554  F0 3F    BEQ $F595                 
F556  A5 90    LDA $90                   
F558  30 56    BMI $F5B0                 
F55A  A5 94    LDA $94                   
F55C  F0 0A    BEQ $F568                 
F55E  B1 9A    LDA ($9A),Y               
F560  49 FF    EOR #$FF                  
F562  38       SEC                       
F563  E9 07    SBC #$07                  
F565  4C 6A F5 JMP $F56A                 

loc_F568:  ; xrefs(1): $F55C
F568  B1 9A    LDA ($9A),Y               

loc_F56A:  ; xrefs(1): $F565
F56A  10 44    BPL $F5B0                 
F56C  18       CLC                       
F56D  65 90    ADC $90                   
F56F  30 47    BMI $F5B8                 
F571  10 3D    BPL $F5B0                 

loc_F573:  ; xrefs(1): $F550
F573  A5 94    LDA $94                   
F575  F0 0A    BEQ $F581                 
F577  B1 9A    LDA ($9A),Y               
F579  49 FF    EOR #$FF                  
F57B  38       SEC                       
F57C  E9 07    SBC #$07                  
F57E  4C 83 F5 JMP $F583                 

loc_F581:  ; xrefs(1): $F575
F581  B1 9A    LDA ($9A),Y               

loc_F583:  ; xrefs(1): $F57E
F583  30 07    BMI $F58C                 
F585  18       CLC                       
F586  65 90    ADC $90                   
F588  90 2E    BCC $F5B8                 
F58A  B0 24    BCS $F5B0                 

loc_F58C:  ; xrefs(1): $F583
F58C  18       CLC                       
F58D  65 90    ADC $90                   
F58F  C5 90    CMP $90                   
F591  90 25    BCC $F5B8                 
F593  B0 1B    BCS $F5B0                 

loc_F595:  ; xrefs(1): $F554
F595  A5 90    LDA $90                   
F597  10 17    BPL $F5B0                 
F599  A5 94    LDA $94                   
F59B  F0 0A    BEQ $F5A7                 
F59D  B1 9A    LDA ($9A),Y               
F59F  49 FF    EOR #$FF                  
F5A1  38       SEC                       
F5A2  E9 07    SBC #$07                  
F5A4  4C A9 F5 JMP $F5A9                 

loc_F5A7:  ; xrefs(1): $F59B
F5A7  B1 9A    LDA ($9A),Y               

loc_F5A9:  ; xrefs(1): $F5A4
F5A9  30 05    BMI $F5B0                 
F5AB  18       CLC                       
F5AC  65 90    ADC $90                   
F5AE  B0 08    BCS $F5B8                 

loc_F5B0:  ; xrefs(7): $F558 $F56A $F571 $F58A $F593 $F597 $F5A9
F5B0  C8       INY                       
F5B1  C6 9C    DEC $9C                   
F5B3  F0 2B    BEQ $F5E0                 
F5B5  4C E2 F4 JMP $F4E2                 

loc_F5B8:  ; xrefs(4): $F56F $F588 $F591 $F5AE
F5B8  9D 03 02 STA $0203,X               
F5BB  A5 9F    LDA $9F                   
F5BD  9D 00 02 STA $0200,X               
F5C0  88       DEY                       
F5C1  B1 96    LDA ($96),Y               
F5C3  9D 01 02 STA $0201,X               
F5C6  C8       INY                       
F5C7  B1 96    LDA ($96),Y               
F5C9  45 9E    EOR $9E                   
F5CB  9D 02 02 STA $0202,X               
F5CE  E6 6A    INC $6A                   
F5D0  C8       INY                       
F5D1  E8       INX                       
F5D2  E8       INX                       
F5D3  E8       INX                       
F5D4  E8       INX                       
F5D5  D0 02    BNE $F5D9                 
F5D7  A2 30    LDX #$30                  

loc_F5D9:  ; xrefs(1): $F5D5
F5D9  C6 9C    DEC $9C                   
F5DB  F0 03    BEQ $F5E0                 
F5DD  4C E2 F4 JMP $F4E2                 

loc_F5E0:  ; xrefs(2): $F5B3 $F5DB
F5E0  60       RTS                       

sub_F5E1:  ; xrefs(4): $F4DC $F647 $F6B4 $F6DE
F5E1  A5 91    LDA $91                   
F5E3  F0 21    BEQ $F606                 
F5E5  C9 0F    CMP #$0F                  
F5E7  F0 3F    BEQ $F628                 
F5E9  A5 90    LDA $90                   
F5EB  30 56    BMI $F643                 
F5ED  A5 94    LDA $94                   
F5EF  F0 0A    BEQ $F5FB                 
F5F1  B1 9A    LDA ($9A),Y               
F5F3  49 FF    EOR #$FF                  
F5F5  38       SEC                       
F5F6  E9 07    SBC #$07                  
F5F8  4C FD F5 JMP $F5FD                 

loc_F5FB:  ; xrefs(1): $F5EF
F5FB  B1 9A    LDA ($9A),Y               

loc_F5FD:  ; xrefs(1): $F5F8
F5FD  10 44    BPL $F643                 
F5FF  18       CLC                       
F600  65 90    ADC $90                   
F602  30 46    BMI $F64A                 
F604  10 3D    BPL $F643                 

loc_F606:  ; xrefs(1): $F5E3
F606  A5 94    LDA $94                   
F608  F0 0A    BEQ $F614                 
F60A  B1 9A    LDA ($9A),Y               
F60C  49 FF    EOR #$FF                  
F60E  38       SEC                       
F60F  E9 07    SBC #$07                  
F611  4C 16 F6 JMP $F616                 

loc_F614:  ; xrefs(1): $F608
F614  B1 9A    LDA ($9A),Y               

loc_F616:  ; xrefs(1): $F611
F616  30 07    BMI $F61F                 
F618  18       CLC                       
F619  65 90    ADC $90                   
F61B  90 2D    BCC $F64A                 
F61D  B0 24    BCS $F643                 

loc_F61F:  ; xrefs(1): $F616
F61F  18       CLC                       
F620  65 90    ADC $90                   
F622  C5 90    CMP $90                   
F624  90 24    BCC $F64A                 
F626  B0 1B    BCS $F643                 

loc_F628:  ; xrefs(1): $F5E7
F628  A5 90    LDA $90                   
F62A  10 17    BPL $F643                 
F62C  A5 94    LDA $94                   
F62E  F0 0A    BEQ $F63A                 
F630  B1 9A    LDA ($9A),Y               
F632  49 FF    EOR #$FF                  
F634  38       SEC                       
F635  E9 07    SBC #$07                  
F637  4C 3C F6 JMP $F63C                 

loc_F63A:  ; xrefs(1): $F62E
F63A  B1 9A    LDA ($9A),Y               

loc_F63C:  ; xrefs(1): $F637
F63C  30 05    BMI $F643                 
F63E  18       CLC                       
F63F  65 90    ADC $90                   
F641  B0 07    BCS $F64A                 

loc_F643:  ; xrefs(7): $F5EB $F5FD $F604 $F61D $F626 $F62A $F63C
F643  88       DEY                       
F644  88       DEY                       
F645  C6 9C    DEC $9C                   
F647  D0 98    BNE $F5E1                 
F649  60       RTS                       

loc_F64A:  ; xrefs(4): $F602 $F61B $F624 $F641
F64A  85 9F    STA $9F                   
F64C  88       DEY                       
F64D  A5 93    LDA $93                   
F64F  F0 21    BEQ $F672                 
F651  C9 0F    CMP #$0F                  
F653  F0 3F    BEQ $F694                 
F655  A5 92    LDA $92                   
F657  30 56    BMI $F6AF                 
F659  A5 95    LDA $95                   
F65B  F0 0A    BEQ $F667                 
F65D  B1 9A    LDA ($9A),Y               
F65F  49 FF    EOR #$FF                  
F661  38       SEC                       
F662  E9 0F    SBC #$0F                  
F664  4C 69 F6 JMP $F669                 

loc_F667:  ; xrefs(1): $F65B
F667  B1 9A    LDA ($9A),Y               

loc_F669:  ; xrefs(1): $F664
F669  10 44    BPL $F6AF                 
F66B  18       CLC                       
F66C  65 92    ADC $92                   
F66E  30 47    BMI $F6B7                 
F670  10 3D    BPL $F6AF                 

loc_F672:  ; xrefs(1): $F64F
F672  A5 95    LDA $95                   
F674  F0 0A    BEQ $F680                 
F676  B1 9A    LDA ($9A),Y               
F678  49 FF    EOR #$FF                  
F67A  38       SEC                       
F67B  E9 0F    SBC #$0F                  
F67D  4C 82 F6 JMP $F682                 

loc_F680:  ; xrefs(1): $F674
F680  B1 9A    LDA ($9A),Y               

loc_F682:  ; xrefs(1): $F67D
F682  30 07    BMI $F68B                 
F684  18       CLC                       
F685  65 92    ADC $92                   
F687  90 2E    BCC $F6B7                 
F689  B0 24    BCS $F6AF                 

loc_F68B:  ; xrefs(1): $F682
F68B  18       CLC                       
F68C  65 92    ADC $92                   
F68E  C5 92    CMP $92                   
F690  90 25    BCC $F6B7                 
F692  B0 1B    BCS $F6AF                 

loc_F694:  ; xrefs(1): $F653
F694  A5 92    LDA $92                   
F696  10 17    BPL $F6AF                 
F698  A5 95    LDA $95                   
F69A  F0 0A    BEQ $F6A6                 
F69C  B1 9A    LDA ($9A),Y               
F69E  49 FF    EOR #$FF                  
F6A0  38       SEC                       
F6A1  E9 0F    SBC #$0F                  
F6A3  4C A8 F6 JMP $F6A8                 

loc_F6A6:  ; xrefs(1): $F69A
F6A6  B1 9A    LDA ($9A),Y               

loc_F6A8:  ; xrefs(1): $F6A3
F6A8  30 05    BMI $F6AF                 
F6AA  18       CLC                       
F6AB  65 92    ADC $92                   
F6AD  B0 08    BCS $F6B7                 

loc_F6AF:  ; xrefs(7): $F657 $F669 $F670 $F689 $F692 $F696 $F6A8
F6AF  88       DEY                       
F6B0  C6 9C    DEC $9C                   
F6B2  F0 2D    BEQ $F6E1                 
F6B4  4C E1 F5 JMP $F5E1                 

loc_F6B7:  ; xrefs(4): $F66E $F687 $F690 $F6AD
F6B7  9D FD 01 STA $01FD,X               
F6BA  A5 9F    LDA $9F                   
F6BC  9D 00 02 STA $0200,X               
F6BF  C8       INY                       
F6C0  B1 96    LDA ($96),Y               
F6C2  45 9E    EOR $9E                   
F6C4  9D FF 01 STA $01FF,X               
F6C7  88       DEY                       
F6C8  B1 96    LDA ($96),Y               
F6CA  9D FE 01 STA $01FE,X               
F6CD  E6 6A    INC $6A                   
F6CF  88       DEY                       
F6D0  CA       DEX                       
F6D1  CA       DEX                       
F6D2  CA       DEX                       
F6D3  CA       DEX                       
F6D4  E0 20    CPX #$20                  
F6D6  B0 02    BCS $F6DA                 
F6D8  A2 FF    LDX #$FF                  

loc_F6DA:  ; xrefs(1): $F6D6
F6DA  C6 9C    DEC $9C                   
F6DC  F0 03    BEQ $F6E1                 
F6DE  4C E1 F5 JMP $F5E1                 

loc_F6E1:  ; xrefs(2): $F6B2 $F6DC
F6E1  60       RTS                       

sub_F6E2:  ; xrefs(1): $DD48
F6E2  A2 30    LDX #$30                  
F6E4  86 9F    STX $9F                   

sub_F6E6:  ; xrefs(1): $F400
F6E6  E6 47    INC $47                   
F6E8  A2 06    LDX #$06                  
F6EA  8E 00 80 STX $8000                 
F6ED  A2 0A    LDX #$0A                  
F6EF  8E 01 80 STX $8001                 
F6F2  A2 07    LDX #$07                  
F6F4  8E 00 80 STX $8000                 
F6F7  A2 0B    LDX #$0B                  
F6F9  8E 01 80 STX $8001                 
F6FC  C6 47    DEC $47                   
F6FE  84 9B    STY $9B                   
F700  0A       ASL A                     
F701  26 9B    ROL $9B                   
F703  0A       ASL A                     
F704  26 9B    ROL $9B                   
F706  18       CLC                       
F707  6D 04 80 ADC $8004                 
F70A  85 9A    STA $9A                   
F70C  AD 05 80 LDA $8005                 
F70F  65 9B    ADC $9B                   
F711  85 9B    STA $9B                   
F713  A0 01    LDY #$01                  
F715  B1 9A    LDA ($9A),Y               
F717  45 9E    EOR $9E                   
F719  85 9E    STA $9E                   
F71B  6A       ROR A                     
F71C  6A       ROR A                     
F71D  29 03    AND #$03                  
F71F  AA       TAX                       
F720  88       DEY                       
F721  B1 9A    LDA ($9A),Y               
F723  F0 05    BEQ $F72A                 
F725  10 01    BPL $F728                 
F727  60       RTS                       

loc_F728:  ; xrefs(1): $F725
F728  95 42    STA $42,X                 

loc_F72A:  ; xrefs(1): $F723
F72A  A5 9E    LDA $9E                   
F72C  29 40    AND #$40                  
F72E  85 94    STA $94                   
F730  A5 9E    LDA $9E                   
F732  29 80    AND #$80                  
F734  85 95    STA $95                   
F736  C8       INY                       
F737  C8       INY                       
F738  B1 9A    LDA ($9A),Y               
F73A  85 96    STA $96                   
F73C  C8       INY                       
F73D  B1 9A    LDA ($9A),Y               
F73F  85 97    STA $97                   
F741  A0 00    LDY #$00                  
F743  B1 96    LDA ($96),Y               
F745  85 9A    STA $9A                   
F747  C8       INY                       
F748  B1 96    LDA ($96),Y               
F74A  85 9B    STA $9B                   
F74C  88       DEY                       
F74D  B1 9A    LDA ($9A),Y               
F74F  85 9C    STA $9C                   
F751  AA       TAX                       
F752  38       SEC                       
F753  A5 9A    LDA $9A                   
F755  E9 01    SBC #$01                  
F757  85 9A    STA $9A                   
F759  B0 02    BCS $F75D                 
F75B  C6 9B    DEC $9B                   

loc_F75D:  ; xrefs(1): $F759
F75D  A0 02    LDY #$02                  
F75F  A6 6C    LDX $6C                   

loc_F761:  ; xrefs(1): $F78D
F761  18       CLC                       
F762  B1 9A    LDA ($9A),Y               
F764  65 92    ADC $92                   
F766  9D 00 02 STA $0200,X               
F769  C8       INY                       
F76A  18       CLC                       
F76B  B1 9A    LDA ($9A),Y               
F76D  65 90    ADC $90                   
F76F  9D 03 02 STA $0203,X               
F772  88       DEY                       
F773  B1 96    LDA ($96),Y               
F775  9D 01 02 STA $0201,X               
F778  C8       INY                       
F779  B1 96    LDA ($96),Y               
F77B  45 9E    EOR $9E                   
F77D  9D 02 02 STA $0202,X               
F780  E6 6A    INC $6A                   
F782  C8       INY                       
F783  E8       INX                       
F784  E8       INX                       
F785  E8       INX                       
F786  E8       INX                       
F787  D0 02    BNE $F78B                 
F789  A6 9F    LDX $9F                   

loc_F78B:  ; xrefs(1): $F787
F78B  C6 9C    DEC $9C                   
F78D  D0 D2    BNE $F761                 
F78F  86 6C    STX $6C                   
F791  60       RTS                       

; ---- data $F792-$F805 (116 bytes) ----
F792  20 46 C9 20 A0 EF A5 93 29 0E 0A 0A 85 9D A5 91  | F. ....).......
F7A2  29 0E 4A 65 9D A8 B1 94 A4 13 0A 90 02 C8 C8 0A  |).Je............
F7B2  90 02 C8 18 65 12 85 97 90 01 C8 84 98 A5 93 6A  |....e..........j
F7C2  A5 91 2A 29 03 A8 B1 97 A8 B1 16 48 20 98 C9 68  |..*).......H ..h
F7D2  60 98 48 20 46 C9 68 A8 A5 10 85 29 A5 11 85 2A  |`.H F.h....)...*
F7E2  98 0A 90 04 E6 2A E6 2A 0A 90 02 E6 2A A8 B1 29  |.....*.*....*..)
F7F2  85 94 C8 B1 29 85 95 C8 B1 29 85 96 C8 B1 29 85  |....)....)....).
F802  97 4C 98 C9                                      |.L..

sub_F806:  ; xrefs(9): $CA9D $CB85 $CDE0 $D645 $E1F4 $E421 $E494 $E4A9 $E698
F806  A5 26    LDA $26                   
F808  F0 11    BEQ $F81B                 
F80A  C6 25    DEC $25                   
F80C  D0 0F    BNE $F81D                 
F80E  A5 28    LDA $28                   
F810  85 25    STA $25                   

loc_F812:  ; xrefs(2): $F84C $F85E
F812  20 2A C9 JSR $C92A                 
F815  20 06 80 JSR $8006                 
F818  4C 98 C9 JMP $C998                 

loc_F81B:  ; xrefs(1): $F808
F81B  85 27    STA $27                   

loc_F81D:  ; xrefs(1): $F80C
F81D  60       RTS                       

; ---- data $F81E-$F83C (31 bytes) ----
F81E  20 2A C9 A0 1F B1 20 99 90 03 88 10 F8 A9 90 A0  | *.... .........
F82E  03 20 B1 E9 4C 98 C9 20 3D F8 A9 0C 4C 2C C9     |. ..L.. =...L,.

sub_F83D:  ; xrefs(2): $C6F1 $E0DE
F83D  A9 00    LDA #$00                  

sub_F83F:  ; xrefs(1): $E695
F83F  A2 07    LDX #$07                  

loc_F841:  ; xrefs(1): $F845
F841  9D BA 05 STA $05BA,X               
F844  CA       DEX                       
F845  10 FA    BPL $F841                 
F847  A9 FF    LDA #$FF                  

sub_F849:  ; xrefs(1): $DB2C
F849  20 6C F8 JSR $F86C                 
F84C  4C 12 F8 JMP $F812                 

sub_F84F:  ; xrefs(4): $D2D8 $D338 $D388 $E412
F84F  A9 F8    LDA #$F8                  
F851  A2 07    LDX #$07                  

loc_F853:  ; xrefs(1): $F857
F853  9D BA 05 STA $05BA,X               
F856  CA       DEX                       
F857  10 FA    BPL $F853                 
F859  A9 FF    LDA #$FF                  
F85B  20 6C F8 JSR $F86C                 
F85E  4C 12 F8 JMP $F812                 

sub_F861:  ; xrefs(4): $C6EE $CAD7 $DB19 $DC6D
F861  A9 08    LDA #$08                  
F863  D0 02    BNE $F867                 

sub_F865:  ; xrefs(3): $CB7F $D3B9 $DCDD
F865  A9 04    LDA #$04                  

loc_F867:  ; xrefs(1): $F863
F867  85 28    STA $28                   
F869  85 25    STA $25                   
F86B  60       RTS                       

sub_F86C:  ; xrefs(2): $F849 $F85B
F86C  A8       TAY                       

sub_F86D:  ; xrefs(15): $CAD4 $CCC9 $D27E $D2EA $D33F $D38F $D3B4 $D3D0 $D40B $D635
F86D  85 26    STA $26                   
F86F  84 27    STY $27                   
F871  60       RTS                       

sub_F872:  ; xrefs(2): $E526 $F98C
F872  20 91 C6 JSR $C691                 
F875  20 D8 DA JSR $DAD8                 
F878  8D 00 A0 STA $A000                 
F87B  85 58    STA $58                   
F87D  85 57    STA $57                   
F87F  A9 FE    LDA #$FE                  
F881  20 18 C6 JSR $C618                 
F884  A9 08    LDA #$08                  
F886  85 75    STA $75                   
F888  A9 02    LDA #$02                  
F88A  85 72    STA $72                   
F88C  85 73    STA $73                   
F88E  85 74    STA $74                   
F890  A2 9F    LDX #$9F                  
F892  A9 00    LDA #$00                  

loc_F894:  ; xrefs(1): $F89A
F894  9D 00 01 STA $0100,X               
F897  CA       DEX                       
F898  E0 FF    CPX #$FF                  
F89A  D0 F8    BNE $F894                 
F89C  20 CC C5 JSR $C5CC                 
F89F  A9 00    LDA #$00                  
F8A1  85 69    STA $69                   
F8A3  85 7B    STA $7B                   
F8A5  85 7D    STA $7D                   
F8A7  85 7A    STA $7A                   
F8A9  A9 C0    LDA #$C0                  
F8AB  85 71    STA $71                   
F8AD  A9 06    LDA #$06                  
F8AF  85 28    STA $28                   
F8B1  85 25    STA $25                   
F8B3  A9 02    LDA #$02                  
F8B5  8D A0 05 STA $05A0                 
F8B8  60       RTS                       

sub_F8B9:  ; xrefs(5): $D1B7 $D4DA $D666 $DA0B $F98F
F8B9  A9 02    LDA #$02                  
F8BB  8D 1C 07 STA $071C                 
F8BE  20 EC F8 JSR $F8EC                 

sub_F8C1:  ; xrefs(1): $D9E6
F8C1  A9 00    LDA #$00                  
F8C3  A2 0C    LDX #$0C                  

loc_F8C5:  ; xrefs(1): $F8C9
F8C5  9D C2 05 STA $05C2,X               
F8C8  CA       DEX                       
F8C9  10 FA    BPL $F8C5                 

sub_F8CB:  ; xrefs(1): $E52C
F8CB  A9 08    LDA #$08                  
F8CD  8D C5 05 STA $05C5                 
F8D0  60       RTS                       

sub_F8D1:  ; xrefs(1): $F992
F8D1  A2 0F    LDX #$0F                  
F8D3  A9 00    LDA #$00                  

loc_F8D5:  ; xrefs(1): $F8D9
F8D5  9D 00 40 STA $4000,X               
F8D8  CA       DEX                       
F8D9  10 FA    BPL $F8D5                 
F8DB  A9 30    LDA #$30                  
F8DD  8D 0C 40 STA $400C                 
F8E0  8D 00 40 STA $4000                 
F8E3  8D 04 40 STA $4004                 
F8E6  A9 0F    LDA #$0F                  
F8E8  8D 15 40 STA $4015                 
F8EB  60       RTS                       

sub_F8EC:  ; xrefs(1): $F8BE
F8EC  A9 00    LDA #$00                  
F8EE  8D FD 05 STA $05FD                 
F8F1  8D FE 05 STA $05FE                 
F8F4  8D FF 05 STA $05FF                 
F8F7  60       RTS                       

loc_F8F8:  ; xrefs(0): 
F8F8  78       SEI                       
F8F9  D8       CLD                       
F8FA  A2 FF    LDX #$FF                  
F8FC  9A       TXS                       
F8FD  A9 06    LDA #$06                  
F8FF  8D 01 20 STA $2001                 
F902  A9 2E    LDA #$2E                  
F904  8D 00 20 STA $2000                 

loc_F907:  ; xrefs(1): $F90A
F907  AD 02 20 LDA $2002                 
F90A  10 FB    BPL $F907                 

loc_F90C:  ; xrefs(1): $F90F
F90C  AD 02 20 LDA $2002                 
F90F  10 FB    BPL $F90C                 
F911  A9 0F    LDA #$0F                  
F913  8D 15 40 STA $4015                 
F916  A9 00    LDA #$00                  
F918  8D 10 40 STA $4010                 
F91B  A9 40    LDA #$40                  
F91D  8D 17 40 STA $4017                 
F920  8D 00 E0 STA $E000                 
F923  AD 02 20 LDA $2002                 
F926  A9 10    LDA #$10                  
F928  AA       TAX                       

loc_F929:  ; xrefs(1): $F932
F929  8D 06 20 STA $2006                 
F92C  8D 06 20 STA $2006                 
F92F  49 10    EOR #$10                  
F931  CA       DEX                       
F932  D0 F5    BNE $F929                 
F934  A9 00    LDA #$00                  
F936  8D 00 80 STA $8000                 
F939  A2 00    LDX #$00                  

loc_F93B:  ; xrefs(1): $F950
F93B  95 00    STA $00,X                 
F93D  9D 00 02 STA $0200,X               
F940  9D 00 03 STA $0300,X               
F943  9D 00 04 STA $0400,X               
F946  9D 00 05 STA $0500,X               
F949  9D 00 06 STA $0600,X               
F94C  9D 00 07 STA $0700,X               
F94F  CA       DEX                       
F950  D0 E9    BNE $F93B                 
F952  A2 04    LDX #$04                  

loc_F954:  ; xrefs(1): $F97D
F954  A9 00    LDA #$00                  
F956  9D 1C 07 STA $071C,X               
F959  BD 36 E5 LDA $E536,X               
F95C  9D 2B 07 STA $072B,X               
F95F  BD 3B E5 LDA $E53B,X               
F962  9D 3B 07 STA $073B,X               
F965  BD 40 E5 LDA $E540,X               
F968  9D 4B 07 STA $074B,X               
F96B  BD 45 E5 LDA $E545,X               
F96E  9D 5B 07 STA $075B,X               
F971  BD 4A E5 LDA $E54A,X               
F974  9D 6B 07 STA $076B,X               
F977  A9 00    LDA #$00                  
F979  9D 7B 07 STA $077B,X               
F97C  CA       DEX                       
F97D  10 D5    BPL $F954                 

loc_F97F:  ; xrefs(1): $D642
F97F  A9 00    LDA #$00                  
F981  85 55    STA $55                   
F983  85 2D    STA $2D                   
F985  85 0A    STA $0A                   
F987  85 0B    STA $0B                   
F989  8D 0C 06 STA $060C                 
F98C  20 72 F8 JSR $F872                 
F98F  20 B9 F8 JSR $F8B9                 
F992  20 D1 F8 JSR $F8D1                 
F995  20 3E D1 JSR $D13E                 
F998  A9 1E    LDA #$1E                  
F99A  8D 01 20 STA $2001                 
F99D  85 09    STA $09                   
F99F  A9 A8    LDA #$A8                  
F9A1  8D 00 20 STA $2000                 
F9A4  85 79    STA $79                   
F9A6  85 08    STA $08                   
F9A8  20 B8 FA JSR $FAB8                 
F9AB  58       CLI                       
F9AC  A5 75    LDA $75                   
F9AE  8D 00 C0 STA $C000                 
F9B1  8D 01 C0 STA $C001                 
F9B4  8D 01 E0 STA $E001                 

loc_F9B7:  ; xrefs(3): $F9D1 $F9D7 $FA7E
F9B7  A5 0F    LDA $0F                   
F9B9  C9 80    CMP #$80                  
F9BB  D0 03    BNE $F9C0                 
F9BD  20 C7 FA JSR $FAC7                 

loc_F9C0:  ; xrefs(1): $F9BB
F9C0  20 B8 FA JSR $FAB8                 
F9C3  E6 0C    INC $0C                   
F9C5  A9 01    LDA #$01                  
F9C7  85 01    STA $01                   
F9C9  20 C7 FA JSR $FAC7                 
F9CC  20 B4 C9 JSR $C9B4                 
F9CF  A5 02    LDA $02                   
F9D1  D0 E4    BNE $F9B7                 
F9D3  A5 04    LDA $04                   
F9D5  29 10    AND #$10                  
F9D7  F0 DE    BEQ $F9B7                 
F9D9  85 F6    STA $F6                   
F9DB  A2 0F    LDX #$0F                  

loc_F9DD:  ; xrefs(1): $F9E8
F9DD  BD 10 01 LDA $0110,X               
F9E0  48       PHA                       
F9E1  BD 8C FA LDA $FA8C,X               
F9E4  9D 10 01 STA $0110,X               
F9E7  CA       DEX                       
F9E8  10 F3    BPL $F9DD                 
F9EA  20 2D C7 JSR $C72D                 
F9ED  20 81 FA JSR $FA81                 

loc_F9F0:  ; xrefs(1): $FA63
F9F0  20 B8 FA JSR $FAB8                 
F9F3  20 2D C7 JSR $C72D                 
F9F6  20 35 D8 JSR $D835                 
F9F9  20 2A C9 JSR $C92A                 
F9FC  A9 48    LDA #$48                  
F9FE  85 90    STA $90                   
FA00  A9 40    LDA #$40                  
FA02  85 92    STA $92                   
FA04  A9 01    LDA #$01                  
FA06  A0 00    LDY #$00                  
FA08  84 9E    STY $9E                   
FA0A  84 91    STY $91                   
FA0C  84 93    STY $93                   
FA0E  20 61 F4 JSR $F461                 
FA11  A2 1B    LDX #$1B                  

loc_FA13:  ; xrefs(1): $FA1A
FA13  BD 9C FA LDA $FA9C,X               
FA16  9D 04 02 STA $0204,X               
FA19  CA       DEX                       
FA1A  10 F7    BPL $FA13                 
FA1C  AD 1C 07 LDA $071C                 
FA1F  0A       ASL A                     
FA20  8D 05 02 STA $0205                 
FA23  EE 05 02 INC $0205                 
FA26  AD FF 05 LDA $05FF                 
FA29  85 90    STA $90                   
FA2B  AD FE 05 LDA $05FE                 
FA2E  85 91    STA $91                   
FA30  AD FD 05 LDA $05FD                 
FA33  85 92    STA $92                   
FA35  20 7C EC JSR $EC7C                 
FA38  20 DA EC JSR $ECDA                 
FA3B  A5 98    LDA $98                   
FA3D  8D 1D 02 STA $021D                 
FA40  A5 97    LDA $97                   
FA42  8D 19 02 STA $0219                 
FA45  A5 96    LDA $96                   
FA47  8D 15 02 STA $0215                 
FA4A  A5 95    LDA $95                   
FA4C  8D 11 02 STA $0211                 
FA4F  A5 94    LDA $94                   
FA51  8D 0D 02 STA $020D                 
FA54  A5 93    LDA $93                   
FA56  8D 09 02 STA $0209                 
FA59  20 C7 FA JSR $FAC7                 
FA5C  20 82 C8 JSR $C882                 
FA5F  A5 04    LDA $04                   
FA61  29 10    AND #$10                  
FA63  F0 8B    BEQ $F9F0                 
FA65  A9 00    LDA #$00                  
FA67  85 F6    STA $F6                   
FA69  20 2D C7 JSR $C72D                 
FA6C  A2 00    LDX #$00                  

loc_FA6E:  ; xrefs(1): $FA75
FA6E  68       PLA                       
FA6F  9D 10 01 STA $0110,X               
FA72  E8       INX                       
FA73  E0 10    CPX #$10                  
FA75  D0 F7    BNE $FA6E                 
FA77  20 81 FA JSR $FA81                 
FA7A  A9 40    LDA #$40                  
FA7C  85 42    STA $42                   
FA7E  4C B7 F9 JMP $F9B7                 

sub_FA81:  ; xrefs(2): $F9ED $FA77
FA81  A9 F7    LDA #$F7                  
FA83  A2 1B    LDX #$1B                  

loc_FA85:  ; xrefs(1): $FA89
FA85  9D 04 02 STA $0204,X               
FA88  CA       DEX                       
FA89  10 FA    BPL $FA85                 
FA8B  60       RTS                       

; ---- data $FA8C-$FAB7 (44 bytes) ----
FA8C  0F 01 28 30 0F 0F 21 30 0F 06 27 38 0F 00 10 20  |..(0..!0..'8... 
FA9C  80 01 01 88 68 01 01 68 68 01 01 70 68 01 01 78  |....h..hh..ph..x
FAAC  68 01 01 80 68 01 01 88 68 01 01 90              |h...h...h...

sub_FAB8:  ; xrefs(3): $F9A8 $F9C0 $F9F0
FAB8  A9 00    LDA #$00                  
FABA  85 01    STA $01                   

sub_FABC:  ; xrefs(2): $C58D $C599
FABC  A9 FF    LDA #$FF                  
FABE  85 0F    STA $0F                   

loc_FAC0:  ; xrefs(1): $FAC4
FAC0  A5 0F    LDA $0F                   
FAC2  C9 FF    CMP #$FF                  
FAC4  F0 FA    BEQ $FAC0                 
FAC6  60       RTS                       

sub_FAC7:  ; xrefs(3): $F9BD $F9C9 $FA59
FAC7  A9 00    LDA #$00                  
FAC9  20 2C C9 JSR $C92C                 
FACC  4C 00 80 JMP $8000                 

loc_FACF:  ; xrefs(0): 
FACF  48       PHA                       
FAD0  8A       TXA                       
FAD1  48       PHA                       
FAD2  98       TYA                       
FAD3  48       PHA                       
FAD4  AD 02 20 LDA $2002                 
FAD7  20 9F C5 JSR $C59F                 
FADA  A5 6E    LDA $6E                   
FADC  D0 02    BNE $FAE0                 
FADE  E6 00    INC $00                   

loc_FAE0:  ; xrefs(1): $FADC
FAE0  A5 01    LDA $01                   
FAE2  F0 03    BEQ $FAE7                 
FAE4  4C E5 FB JMP $FBE5                 

loc_FAE7:  ; xrefs(1): $FAE2
FAE7  A9 00    LDA #$00                  
FAE9  A2 02    LDX #$02                  
FAEB  8D 03 20 STA $2003                 
FAEE  8E 14 40 STX $4014                 
FAF1  A5 6E    LDA $6E                   
FAF3  F0 03    BEQ $FAF8                 
FAF5  4C 22 FB JMP $FB22                 

loc_FAF8:  ; xrefs(1): $FAF3
FAF8  AD F9 05 LDA $05F9                 
FAFB  D0 18    BNE $FB15                 
FAFD  AD F0 05 LDA $05F0                 
FB00  F0 0D    BEQ $FB0F                 
FB02  C9 FF    CMP #$FF                  
FB04  D0 06    BNE $FB0C                 
FB06  20 07 FF JSR $FF07                 
FB09  4C 9F FB JMP $FB9F                 

loc_FB0C:  ; xrefs(1): $FB04
FB0C  20 07 FF JSR $FF07                 

loc_FB0F:  ; xrefs(1): $FB00
FB0F  A5 37    LDA $37                   
FB11  05 36    ORA $36                   
FB13  D0 0D    BNE $FB22                 

loc_FB15:  ; xrefs(1): $FAFB
FB15  A5 08    LDA $08                   
FB17  29 7B    AND #$7B                  
FB19  8D 00 20 STA $2000                 
FB1C  20 9B C6 JSR $C69B                 
FB1F  4C 9F FB JMP $FB9F                 

loc_FB22:  ; xrefs(2): $FAF5 $FB13
FB22  A5 37    LDA $37                   
FB24  F0 39    BEQ $FB5F                 
FB26  8D EC 05 STA $05EC                 
FB29  A9 00    LDA #$00                  
FB2B  85 37    STA $37                   
FB2D  A9 2C    LDA #$2C                  
FB2F  8D 00 20 STA $2000                 
FB32  AD A1 01 LDA $01A1                 
FB35  8D 06 20 STA $2006                 
FB38  AD A0 01 LDA $01A0                 
FB3B  8D 06 20 STA $2006                 
FB3E  AC A4 01 LDY $01A4                 
FB41  A9 1E    LDA #$1E                  
FB43  38       SEC                       
FB44  ED A5 01 SBC $01A5                 
FB47  20 12 FD JSR $FD12                 
FB4A  AD A3 01 LDA $01A3                 
FB4D  8D 06 20 STA $2006                 
FB50  AD A2 01 LDA $01A2                 
FB53  8D 06 20 STA $2006                 
FB56  AD A5 01 LDA $01A5                 
FB59  20 12 FD JSR $FD12                 
FB5C  20 97 FE JSR $FE97                 

loc_FB5F:  ; xrefs(1): $FB24
FB5F  A5 36    LDA $36                   
FB61  F0 3C    BEQ $FB9F                 
FB63  8D EC 05 STA $05EC                 
FB66  A9 00    LDA #$00                  
FB68  85 36    STA $36                   
FB6A  A9 28    LDA #$28                  
FB6C  8D 00 20 STA $2000                 
FB6F  AD A7 01 LDA $01A7                 
FB72  8D 06 20 STA $2006                 
FB75  AD A6 01 LDA $01A6                 
FB78  8D 06 20 STA $2006                 
FB7B  AC AC 01 LDY $01AC                 
FB7E  A9 20    LDA #$20                  
FB80  38       SEC                       
FB81  ED AD 01 SBC $01AD                 
FB84  20 12 FD JSR $FD12                 
FB87  AD A9 01 LDA $01A9                 
FB8A  8D 06 20 STA $2006                 
FB8D  AD A8 01 LDA $01A8                 
FB90  8D 06 20 STA $2006                 
FB93  AD AD 01 LDA $01AD                 
FB96  18       CLC                       
FB97  69 01    ADC #$01                  
FB99  20 12 FD JSR $FD12                 
FB9C  20 44 FE JSR $FE44                 

loc_FB9F:  ; xrefs(3): $FB09 $FB1F $FB61
FB9F  A9 00    LDA #$00                  
FBA1  8D 00 80 STA $8000                 
FBA4  A5 40    LDA $40                   
FBA6  8D 01 80 STA $8001                 
FBA9  A9 01    LDA #$01                  
FBAB  8D 00 80 STA $8000                 
FBAE  A5 41    LDA $41                   
FBB0  8D 01 80 STA $8001                 
FBB3  A9 02    LDA #$02                  
FBB5  8D 00 80 STA $8000                 
FBB8  A5 42    LDA $42                   
FBBA  8D 01 80 STA $8001                 
FBBD  A9 03    LDA #$03                  
FBBF  8D 00 80 STA $8000                 
FBC2  A5 43    LDA $43                   
FBC4  8D 01 80 STA $8001                 
FBC7  A9 04    LDA #$04                  
FBC9  8D 00 80 STA $8000                 
FBCC  A5 44    LDA $44                   
FBCE  8D 01 80 STA $8001                 
FBD1  A9 05    LDA #$05                  
FBD3  8D 00 80 STA $8000                 
FBD6  A5 45    LDA $45                   
FBD8  8D 01 80 STA $8001                 
FBDB  A5 7D    LDA $7D                   
FBDD  85 70    STA $70                   
FBDF  A9 00    LDA #$00                  
FBE1  85 47    STA $47                   
FBE3  F0 02    BEQ $FBE7                 

loc_FBE5:  ; xrefs(1): $FAE4
FBE5  A9 80    LDA #$80                  

loc_FBE7:  ; xrefs(1): $FBE3
FBE7  85 0F    STA $0F                   
FBE9  A9 00    LDA #$00                  
FBEB  85 7B    STA $7B                   
FBED  20 35 C5 JSR $C535                 
FBF0  A5 75    LDA $75                   
FBF2  8D 00 C0 STA $C000                 
FBF5  8D 01 C0 STA $C001                 
FBF8  8D 01 E0 STA $E001                 
FBFB  A5 70    LDA $70                   
FBFD  C9 39    CMP #$39                  
FBFF  F0 0A    BEQ $FC0B                 
FC01  C9 57    CMP #$57                  
FC03  D0 0E    BNE $FC13                 
FC05  20 30 FC JSR $FC30                 
FC08  4C 13 FC JMP $FC13                 

loc_FC0B:  ; xrefs(1): $FBFF
FC0B  A5 00    LDA $00                   
FC0D  85 74    STA $74                   
FC0F  A9 00    LDA #$00                  
FC11  85 77    STA $77                   

loc_FC13:  ; xrefs(2): $FC03 $FC08
FC13  A5 7A    LDA $7A                   
FC15  F0 13    BEQ $FC2A                 
FC17  C9 01    CMP #$01                  
FC19  D0 06    BNE $FC21                 
FC1B  A9 00    LDA #$00                  
FC1D  85 7A    STA $7A                   
FC1F  F0 09    BEQ $FC2A                 

loc_FC21:  ; xrefs(1): $FC19
FC21  A9 00    LDA #$00                  
FC23  85 7A    STA $7A                   
FC25  68       PLA                       
FC26  68       PLA                       
FC27  68       PLA                       
FC28  68       PLA                       
FC29  68       PLA                       

loc_FC2A:  ; xrefs(2): $FC15 $FC1F
FC2A  68       PLA                       
FC2B  A8       TAY                       
FC2C  68       PLA                       
FC2D  AA       TAX                       
FC2E  68       PLA                       
FC2F  40       RTI                       

sub_FC30:  ; xrefs(1): $FC05
FC30  A5 31    LDA $31                   
FC32  85 49    STA $49                   
FC34  A5 30    LDA $30                   
FC36  46 49    LSR $49                   
FC38  6A       ROR A                     
FC39  46 49    LSR $49                   
FC3B  6A       ROR A                     
FC3C  46 49    LSR $49                   
FC3E  6A       ROR A                     
FC3F  46 49    LSR $49                   
FC41  6A       ROR A                     
FC42  46 49    LSR $49                   
FC44  6A       ROR A                     
FC45  85 48    STA $48                   
FC47  46 49    LSR $49                   
FC49  A5 08    LDA $08                   
FC4B  29 FE    AND #$FE                  
FC4D  69 00    ADC #$00                  
FC4F  85 4A    STA $4A                   
FC51  6A       ROR A                     
FC52  A5 48    LDA $48                   
FC54  6A       ROR A                     
FC55  8D 05 20 STA $2005                 
FC58  A5 7E    LDA $7E                   
FC5A  8D 05 20 STA $2005                 
FC5D  46 49    LSR $49                   
FC5F  A5 08    LDA $08                   
FC61  29 FE    AND #$FE                  
FC63  69 00    ADC #$00                  
FC65  8D 00 20 STA $2000                 
FC68  60       RTS                       

; ---- data $FC69-$FD11 (169 bytes) ----
FC69  31 39 39 31 20 4E 41 47 4F 59 41 20 4E 41 54 53  |1991 NAGOYA NATS
FC79  55 4D 45 20 49 4E 43 0D 4D 45 54 41 4C 20 43 4F  |UME INC.METAL CO
FC89  4D 4D 41 4E 44 4F 20 47 31 0D 50 52 4F 47 52 41  |MMANDO G1.PROGRA
FC99  4D 20 20 4B 2E 49 53 48 49 48 41 52 41 0D 44 45  |M  K.ISHIHARA.DE
FCA9  53 49 47 4E 20 20 53 2E 54 41 4E 49 47 55 43 48  |SIGN  S.TANIGUCH
FCB9  49 0D 44 45 53 49 47 4E 20 20 4E 2E 4D 49 5A 4F  |I.DESIGN  N.MIZO
FCC9  47 55 43 48 49 0D 44 45 53 49 47 4E 20 20 53 2E  |GUCHI.DESIGN  S.
FCD9  4D 41 54 53 55 55 52 41 0D 44 45 53 49 47 4E 20  |MATSUURA.DESIGN 
FCE9  20 42 49 54 0D 53 4F 55 4E 44 20 20 48 2E 49 57  | BIT.SOUND  H.IW
FCF9  41 54 53 55 4B 49 0D 4D 55 53 49 43 20 20 49 2E  |ATSUKI.MUSIC  I.
FD09  4D 49 5A 55 54 41 4E 49 0D                       |MIZUTANI.

sub_FD12:  ; xrefs(4): $FB47 $FB59 $FB84 $FB99
FD12  0A       ASL A                     
FD13  AA       TAX                       
FD14  BD 21 FD LDA $FD21,X               
FD17  85 48    STA $48                   
FD19  BD 22 FD LDA $FD22,X               
FD1C  85 49    STA $49                   
FD1E  6C 48 00 JMP ($0048)               

; ---- data $FD21-$FE43 (291 bytes) ----
FD21  43 FE 3C FE 35 FE 2E FE 27 FE 20 FE 19 FE 12 FE  |C.<.5...'. .....
FD31  0B FE 04 FE FD FD F6 FD EF FD E8 FD E1 FD DA FD  |................
FD41  D3 FD CC FD C5 FD BE FD B7 FD B0 FD A9 FD A2 FD  |................
FD51  9B FD 94 FD 8D FD 86 FD 7F FD 78 FD 71 FD 6A FD  |..........x.q.j.
FD61  63 FD B9 00 03 8D 07 20 C8 B9 00 03 8D 07 20 C8  |c...... ...... .
FD71  B9 00 03 8D 07 20 C8 B9 00 03 8D 07 20 C8 B9 00  |..... ...... ...
FD81  03 8D 07 20 C8 B9 00 03 8D 07 20 C8 B9 00 03 8D  |... ...... .....
FD91  07 20 C8 B9 00 03 8D 07 20 C8 B9 00 03 8D 07 20  |. ...... ...... 
FDA1  C8 B9 00 03 8D 07 20 C8 B9 00 03 8D 07 20 C8 B9  |...... ...... ..
FDB1  00 03 8D 07 20 C8 B9 00 03 8D 07 20 C8 B9 00 03  |.... ...... ....
FDC1  8D 07 20 C8 B9 00 03 8D 07 20 C8 B9 00 03 8D 07  |.. ...... ......
FDD1  20 C8 B9 00 03 8D 07 20 C8 B9 00 03 8D 07 20 C8  | ...... ...... .
FDE1  B9 00 03 8D 07 20 C8 B9 00 03 8D 07 20 C8 B9 00  |..... ...... ...
FDF1  03 8D 07 20 C8 B9 00 03 8D 07 20 C8 B9 00 03 8D  |... ...... .....
FE01  07 20 C8 B9 00 03 8D 07 20 C8 B9 00 03 8D 07 20  |. ...... ...... 
FE11  C8 B9 00 03 8D 07 20 C8 B9 00 03 8D 07 20 C8 B9  |...... ...... ..
FE21  00 03 8D 07 20 C8 B9 00 03 8D 07 20 C8 B9 00 03  |.... ...... ....
FE31  8D 07 20 C8 B9 00 03 8D 07 20 C8 B9 00 03 8D 07  |.. ...... ......
FE41  20 C8 60                                         | .`

sub_FE44:  ; xrefs(1): $FB9C
FE44  AE D4 05 LDX $05D4                 
FE47  AD D1 05 LDA $05D1                 
FE4A  8D 06 20 STA $2006                 
FE4D  20 60 FE JSR $FE60                 
FE50  A5 34    LDA $34                   
FE52  D0 42    BNE $FE96                 
FE54  8A       TXA                       
FE55  49 40    EOR #$40                  
FE57  AA       TAX                       
FE58  AD D1 05 LDA $05D1                 
FE5B  49 04    EOR #$04                  
FE5D  8D 06 20 STA $2006                 

sub_FE60:  ; xrefs(1): $FE4D
FE60  AD D0 05 LDA $05D0                 
FE63  8D 06 20 STA $2006                 
FE66  BD 20 01 LDA $0120,X               
FE69  8D 07 20 STA $2007                 
FE6C  BD 21 01 LDA $0121,X               
FE6F  8D 07 20 STA $2007                 
FE72  BD 22 01 LDA $0122,X               
FE75  8D 07 20 STA $2007                 
FE78  BD 23 01 LDA $0123,X               
FE7B  8D 07 20 STA $2007                 
FE7E  BD 24 01 LDA $0124,X               
FE81  8D 07 20 STA $2007                 
FE84  BD 25 01 LDA $0125,X               
FE87  8D 07 20 STA $2007                 
FE8A  BD 26 01 LDA $0126,X               
FE8D  8D 07 20 STA $2007                 
FE90  BD 27 01 LDA $0127,X               
FE93  8D 07 20 STA $2007                 

loc_FE96:  ; xrefs(1): $FE52
FE96  60       RTS                       

sub_FE97:  ; xrefs(1): $FB5C
FE97  AE D5 05 LDX $05D5                 
FE9A  AD D3 05 LDA $05D3                 
FE9D  8D 06 20 STA $2006                 
FEA0  AD D2 05 LDA $05D2                 
FEA3  8D 06 20 STA $2006                 
FEA6  18       CLC                       
FEA7  69 08    ADC #$08                  
FEA9  85 9F    STA $9F                   
FEAB  BD 20 01 LDA $0120,X               
FEAE  8D 07 20 STA $2007                 
FEB1  BD 40 01 LDA $0140,X               
FEB4  8D 07 20 STA $2007                 
FEB7  AD D3 05 LDA $05D3                 
FEBA  8D 06 20 STA $2006                 
FEBD  A5 9F    LDA $9F                   
FEBF  8D 06 20 STA $2006                 
FEC2  18       CLC                       
FEC3  69 08    ADC #$08                  
FEC5  85 9F    STA $9F                   
FEC7  BD 28 01 LDA $0128,X               
FECA  8D 07 20 STA $2007                 
FECD  BD 48 01 LDA $0148,X               
FED0  8D 07 20 STA $2007                 
FED3  AD D3 05 LDA $05D3                 
FED6  8D 06 20 STA $2006                 
FED9  A5 9F    LDA $9F                   
FEDB  8D 06 20 STA $2006                 
FEDE  18       CLC                       
FEDF  69 08    ADC #$08                  
FEE1  85 9F    STA $9F                   
FEE3  BD 30 01 LDA $0130,X               
FEE6  8D 07 20 STA $2007                 
FEE9  BD 50 01 LDA $0150,X               
FEEC  8D 07 20 STA $2007                 
FEEF  AD D3 05 LDA $05D3                 
FEF2  8D 06 20 STA $2006                 
FEF5  A5 9F    LDA $9F                   
FEF7  8D 06 20 STA $2006                 
FEFA  BD 38 01 LDA $0138,X               
FEFD  8D 07 20 STA $2007                 
FF00  BD 58 01 LDA $0158,X               
FF03  8D 07 20 STA $2007                 
FF06  60       RTS                       

sub_FF07:  ; xrefs(2): $FB06 $FB0C
FF07  A0 00    LDY #$00                  
FF09  AD 00 03 LDA $0300                 
FF0C  F0 3B    BEQ $FF49                 

loc_FF0E:  ; xrefs(1): $FF46
FF0E  B9 01 03 LDA $0301,Y               
FF11  29 3F    AND #$3F                  
FF13  F0 34    BEQ $FF49                 
FF15  AA       TAX                       
FF16  A9 28    LDA #$28                  
FF18  8D 00 20 STA $2000                 
FF1B  B9 01 03 LDA $0301,Y               
FF1E  29 40    AND #$40                  
FF20  F0 05    BEQ $FF27                 
FF22  A9 2C    LDA #$2C                  
FF24  8D 00 20 STA $2000                 

loc_FF27:  ; xrefs(1): $FF20
FF27  B9 01 03 LDA $0301,Y               
FF2A  0A       ASL A                     
FF2B  C8       INY                       
FF2C  90 0E    BCC $FF3C                 
FF2E  B9 01 03 LDA $0301,Y               
FF31  8D 06 20 STA $2006                 
FF34  C8       INY                       
FF35  B9 01 03 LDA $0301,Y               
FF38  8D 06 20 STA $2006                 
FF3B  C8       INY                       

loc_FF3C:  ; xrefs(2): $FF2C $FF44
FF3C  B9 01 03 LDA $0301,Y               
FF3F  8D 07 20 STA $2007                 
FF42  C8       INY                       
FF43  CA       DEX                       
FF44  D0 F6    BNE $FF3C                 
FF46  4C 0E FF JMP $FF0E                 

loc_FF49:  ; xrefs(2): $FF0C $FF13
FF49  8D F0 05 STA $05F0                 
FF4C  8D 00 03 STA $0300                 
FF4F  60       RTS                       

; ---- data $FF50-$FFFF (176 bytes) ----
FF50  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
FF60  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
FF70  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
FF80  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
FF90  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
FFA0  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
FFB0  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
FFC0  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
FFD0  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
FFE0  20 20 20 20 20 46 43 20 53 4F 4C 42 52 41 49 4E  |     FC SOLBRAIN
FFF0  B7 56 17 59 33 04 01 0A CF 7F CF FA F8 F8 E0 C2  |.V.Y3...........
