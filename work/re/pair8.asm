
loc_8000:  ; 0 xrefs: 
8000  4C 15 8E JMP loc_8E15            

loc_8003:  ; 0 xrefs: 
8003  05 80    ORA $80                 
8005  00 20    BRK #$20                

; ==== data $8007..$8008  (2 bytes) ====
8007  21 00                                            |!.

loc_8009:  ; 0 xrefs: 
8009  81 0D    STA ($0D,X)             
800B  15 F5    ORA $F5,X               
800D  82 FA    NOP #$FA                
800F  F5 05    SBC $05,X               
8011  FA       NOP                     

loc_8012:  ; 0 xrefs: 
8012  81 F9    STA ($F9,X)             

; ==== data $8014..$8014  (1 bytes) ====
8014  02                                               |.

loc_8015:  ; 0 xrefs: 
8015  00 8A    BRK #$8A                

; ==== data $8017..$8017  (1 bytes) ====
8017  F7                                               |.

loc_8018:  ; 0 xrefs: 
8018  F1 F2    SBC ($F2),Y             
801A  00 97    BRK #$97                

; ==== data $801C..$801C  (1 bytes) ====
801C  98                                               |.
801D  99 9A 9B STA $9B9A,Y             

; ==== data $8020..$8020  (1 bytes) ====
8020  9C                                               |.

loc_8021:  ; 0 xrefs: 
8021  11 00    ORA ($00),Y             
8023  83 F1    SAX ($F1,X)             

; ==== data $8025..$8025  (1 bytes) ====
8025  F2                                               |.
8026  FB 02 00 ISC $0002,Y             
8029  85 F7    STA $F7                 
802B  F3 F4    ISC ($F4),Y             

loc_802D:  ; 0 xrefs: 
802D  00 9D    BRK #$9D                

loc_802F:  ; 0 xrefs: 
802F  04 00    NOP $00                 
8031  82 A0    NOP #$A0                
8033  A1 02    LDA ($02,X)             

loc_8035:  ; 0 xrefs: 
8035  00 8C    BRK #$8C                

; ==== data $8037..$8037  (1 bytes) ====
8037  30                                               |0

loc_8038:  ; 0 xrefs: 
8038  31 32    AND ($32),Y             
803A  33 34    RLA ($34),Y             
803C  35 36    AND $36,X               
803E  37 38    RLA $38,X               

loc_8040:  ; 0 xrefs: 
8040  39 3A 3B AND $3B3A,Y             

; ==== data $8043..$80A8  (102 bytes) ====
8043  02 00 83 F3 F4 FB 02 00 81 F7 02 00 81 A2 04 00  |................
8053  83 A3 A4 A5 02 00 8C 40 41 42 43 44 45 46 47 48  |.......@ABCDEFGH
8063  49 4A 4B 04 00 81 FB 02 00 81 F7 02 00 81 A6 03  |IJK.............
8073  00 84 A7 A8 A9 AA 02 00 8C 50 51 52 53 54 55 56  |.........PQRSTUV
8083  57 58 59 5A 5B 04 00 81 F8 02 00 81 F7 05 00 86  |WXYZ[...........
8093  AB AC AD AE 9E 60 02 61 84 63 64 00 66 02 61 81  |.....`.a.cd.f.a.
80A3  69 02 61 81 6C 02                                |i.a.l.

loc_80A9:  ; 0 xrefs: 
80A9  61 81    ADC ($81,X)             
80AB  6F 02 00 RRA $0002               
80AE  81 FB    STA ($FB,X)             

; ==== data $80B0..$81A4  (245 bytes) ====
80B0  02 00 81 F7 05 00 95 AF B0 B1 B2 9F 70 71 72 73  |............pqrs
80C0  74 00 76 77 78 79 7A 7B 7C 7D 7E 92 02 00 81 F8  |t.vwxyz{|}~.....
80D0  02 00 81 F7 06 00 94 B3 B4 B5 00 80 81 82 83 84  |................
80E0  85 86 87 88 89 8A 8B 8C 8D 8E 8F 02 00 81 F8 02  |................
80F0  00 81 F7 06 00 94 B6 B7 B8 00 5E 62 65 67 68 65  |..........^beghe
8100  6A 6B 6D 6E 62 65 75 90 65 91 02 00 81 F8 02 00  |jkmnbeu.e.......
8110  81 F7 07 00 82 B9 BA 07 00 81 2C 02 2D 81 2F 08  |..........,.-./.
8120  00 81 F8 02 00 81 F7 02 00 81 BB 04 00 81 BC 08  |................
8130  00 84 3C 3D 3E 3F 08 00 81 F8 02 00 81 F7 06 00  |..<=>?..........
8140  82 BD BE 08 00 84 4C 4D 4E 4F 08 00 81 F8 02 00  |......LMNO......
8150  88 F7 00 BF C0 00 C1 C2 C3 09 00 84 5C 5D F0 5F  |............\]._
8160  08 00 81 F8 02 00 81 F7 04 00 84 C4 C5 C6 C7 08  |................
8170  00 81 93 02 2B 81 2E 08 00 81 F8 02 00 81 F7 05  |....+...........
8180  00 83 C8 C9 CA 07 00 85 13 14 01 12 14 08 00 81  |................
8190  F8 02 00 81 F7 05 00 84 CB CC CD CE 06 00 88 03  |................
81A0  0F 0E 14 09 0E                                   |.....

loc_81A5:  ; 0 xrefs: 
81A5  15 05    ORA $05,X               
81A7  05 00    ORA $00                 
81A9  81 F8    STA ($F8,X)             

; ==== data $81AB..$83A4  (506 bytes) ====
81AB  02 00 81 F7 05 00 84 CF D0 D1 D2 13 00 81 F8 02  |................
81BB  00 81 F7 05 00 92 D3 D4 D5 D6 D7 10 15 13 08 00  |................
81CB  13 14 01 12 14 00 02 15 02 14 84 0F 0E 00 F8 02  |................
81DB  00 81 F7 05 00 85 D8 D9 00 DA DB 06 00 83 94 95  |................
81EB  96 09 00 81 F8 02 00 81 F7 05 00 85 DC DD 00 DE  |................
81FB  DF 03 00 8A 07 0B 11 16 17 18 1A 1B 1C 1D 05 00  |................
820B  81 F8 02 00 81 F7 06 00 81 E0 02 00 81 E1 04 00  |................
821B  89 1E 1F 20 23 24 25 26 27 28 05 00 81 F8 02 00  |... #$%&'(......
822B  81 FD 06 00 81 E2 02 00 81 E3 12 00 81 F8 02 00  |................
823B  81 F7 06 00 81 E4 02 00 81 E5 03 00 88 0A 14 01  |................
824B  09 14 0F 00 21 02 29 81 22 04 00 81 F8 02 00 81  |....!.).".......
825B  FD 06 00 84 E6 EF 00 E7 12 00 81 F8 02 00 81 FD  |................
826B  06 00 85 E8 E9 EA EB EC 02 00 8B 0C 09 03 05 0E  |................
827B  13 05 04 00 02 19 04 00 81 F8 02 00 83 FD F1 F2  |................
828B  05 00 82 ED EE 04 00 88 0E 09 0E 14 05 0E 04 0F  |................
829B  05 00 83 F1 F2 F8 02 00 83 FD F3 F4 18 00 86 F3  |................
82AB  F4 F8 00 00 FC 03 FE 82 F6 FE 17 F6 81 2A 21 00  |.............*!.
82BB  7F C0 23 81 C4 02 05 03 55 82 15 75 03 00 03 55  |..#.....U..u...U
82CB  82 51 44 03 00 82 0A FA 83 3A 0A 44 04 00 84 5F  |.QD......:.D..._
82DB  53 10 44 03 00 05 55 03 00 04 F0 82 74 C0 02 00  |S.D...U.....t...
82EB  81 FC 03 FF 81 77 FF 00 20 59 00 86 0A 0D 10 1E  |.....w.. Y......
82FB  36 39 1C 00 81 03 19 00 81 2E 04 00 84 02 13 14  |69..............
830B  05 17 00 82 5F 5E 03 00 84 23 33 34 24 04 00 82  |...._^...#34$...
831B  28 69 07 00 81 2E 03 00 82 4B 69 04 00 82 63 64  |(i.......Ki...cd
832B  03 00 84 12 33 34 15 04 00 81 29 08 00 82 01 59  |....34....)....Y
833B  02 00 81 29 05 00 82 66 5E 03 00 84 12 33 34 15  |...)...f^....34.
834B  04 00 81 2D 08 00 85 29 00 F7 00 2D 03 00 8B 01  |...-...)...-....
835B  59 63 64 00 2E 00 12 33 34 15 04 00 82 2D 64 04  |Ycd....34....-d.
836B  00 81 2E 02 00 81 2D 03 00 8F 4B 64 F7 00 2D 00  |......-...Kd..-.
837B  66 5E 00 01 59 12 33 34 15 02 00 85 01 59 5F 62  |f^..Y.34.....Y_b
838B  59 02 00 97 63 64 00 4B 59 00 2E 00 29 5F 59 5F  |Y...cd.KY...)_Y_
839B  62 00 63 64 00 29 00 12 33 34                    |b.cd.)..34

loc_83A5:  ; 0 xrefs: 
83A5  15 02    ORA $02,X               
83A7  00 93    BRK #$93                

; ==== data $83A9..$87A5  (1021 bytes) ====
83A9  01 59 5F 62 28 01 59 66 62 00 29 28 59 4B 59 2D  |.Y_b(.Yfb.)(YKY-
83B9  63 00 63 02 00 93 66 28 59 2D 00 12 33 34 15 63  |c.c...f(Y-..34.c
83C9  64 28 59 28 59 00 28 59 4B 02 59 02 2D 8C 00 28  |d(Y(Y.(YK.Y.-..(
83D9  59 28 59 4B 62 59 5F 59 4B 59 02 00 87 22 33 34  |Y(YKbY_YKY..."34
83E9  25 63 62 2D 02 5F 85 62 00 2D 00 2D 02 00 8D 01  |%cb-._.b.-.-....
83F9  59 00 2D 4B 5F 62 29 62 00 28 59 2D 02 00 8E 31  |Y.-K_b)b.(Y-...1
8409  32 33 34 35 66 63 00 63 66 00 6F 00 F7 02 00 82  |2345fc.cf.o.....
8419  69 2D 03 00 82 4B 66 02 00 81 F7 02 00 81 6F 03  |i-...Kf.......o.
8429  00 86 41 42 43 44 45 46 02 00 81 69 05 00 81 6F  |..ABCDEF...i...o
8439  03 00 84 F7 6F 00 69 02 00 81 6F 02 00 8C 5E 00  |....o.i...o...^.
8449  6F 69 50 51 52 53 54 55 56 57 20 38 0F 20 82 30  |oiPQRSTUVW 8. .0
8459  07 0F 20 20 00 08 06 82 1A 1D 02 3F 08 00 02 40  |..  .......?...@
8469  82 90 C0 08 06 8B 16 17 16 17 16 17 16 17 2A 0E  |..............*.
8479  93 0A 00 95 94 A0 D0 16 17 16 17 16 17 16 17 26  |...............&
8489  27 26 27 26 27 26 27 0F 93 0C 00 8A 94 0F 26 27  |'&'&'&'.......&'
8499  26 27 26 27 26 27 08 06 81 1F 0E 00 81 1F 08 06  |&'&'&'..........
84A9  89 08 09 08 09 08 09 08 09 1F 0E 00 93 1F 08 09  |................
84B9  08 09 08 09 08 09 08 09 08 09 08 09 08 09 1F 37  |...............7
84C9  0C 38 94 58 1F 08 09 08 09 08 09 08 09 18 19 18  |.8.X............
84D9  19 18 19 18 19 2F 47 05 48 82 49 4A 05 48 8A 68  |...../G.H.IJ.H.h
84E9  2F 18 19 18 19 18 19 18 19 20 11 20 21 7F C0 23  |/........ . !..#
84F9  08 00 82 F0 00 84 C0 F0 30 FF 02 00 81 FF 81 FC  |........0.......
8509  04 FF 81 33 81 CC 06 FF 82 00 0C 08 AF 02 55 81  |...3..........U.
8519  EA 02 FF 81 BA 02 55 03 FA 81 F6 04 FA 7F 00 24  |......U........$
8529  59 00 86 0A 0D 10 1E 36 B0 02 00 86 0A 0D 10 1E  |Y......6........
8539  36 3A 12 00 86 D7 D8 D9 DA DB DC 05 00 81 61 15  |6:............a.
8549  00 84 DD DE DF E0 05 00 82 0B 0C 04 00 86 0A 0D  |................
8559  10 1E 36 4F 0B 00 84 DD DE DF E0 05 00 82 1B 1C  |..6O............
8569  06 00 81 61 02 65 0C 00 84 DD DE DF E0 05 00 82  |...a.e..........
8579  2B 2C 03 00 8F 70 71 72 73 74 75 76 77 00 0A 0D  |+,...pqrstuvw...
8589  10 1E 36 80 03 00 84 DD DE DF E0 02 00 81 3E 02  |..6...........>.
8599  3D 82 3B 3C 02 3D 88 3E 00 81 82 83 84 85 86 0B  |=.;<.=.>........
85A9  00 84 DD DE DF E0 05 00 83 1B 4C 4D 03 00 86 91  |..........LM....
85B9  92 A3 A4 92 96 03 00 82 BA BB 02 00 82 63 64 02  |.............cd.
85C9  00 84 DD DE DF E0 02 00 8F 01 59 5A 5B 5C 5D 63  |..........YZ[\]c
85D9  64 00 A1 A2 A3 A4 A5 A6 02 00 83 BC BE BD 02 00  |d...............
85E9  88 66 6F 63 64 E1 E2 E3 E4 02 00 8F 29 00 1B 5D  |.focd.......)..]
85F9  5C 5D 66 6F 00 91 A2 A3 A4 A5 A6 02 00 85 A8 BE  |\]fo............
8609  98 00 28 02 59 8F 63 62 E5 E6 E7 E8 63 64 2D 00  |..(.Y.cb....cd-.
8619  6A 6B 6C 6D 6E 02 00 86 B1 B2 B3 B4 B5 B6 02 00  |jklmn...........
8629  96 99 9A 9B 9C 9D 9E 9F 66 6F E9 EA EB EC 63 62  |........fo....cb
8639  64 00 7A 7B 7C 7D 7E 02 00 86 C1 C2 C3 C4 C5 C6  |d.z{|}~.........
8649  02 00 A1 A9 AA AB AC AD AE AF 00 ED EE EF F0 F1  |................
8659  66 6F 00 89 8A 8B 8C 8D 8E 8F 00 D1 D2 D3 D4 D5  |fo..............
8669  D6 00 B8 B9 05 BE A3 BF 00 F3 F4 F5 F6 00 F8 00  |................
8679  50 51 52 53 54 55 56 57 50 51 52 53 54 55 56 57  |PQRSTUVWPQRSTUVW
8689  C8 C9 CA CB CC CD CE CF 00 F9 02 FA 84 FC FD FE  |................
8699  00 20 38 20 20 20 00 20 06 C0 16 17 16 17 16 17  |. 8   . ........
86A9  16 17 16 17 16 17 16 17 16 17 16 17 16 17 16 17  |................
86B9  16 17 16 17 16 17 16 17 16 17 26 27 26 27 26 27  |..........&'&'&'
86C9  26 27 26 27 26 27 26 27 26 27 26 27 26 27 26 27  |&'&'&'&'&'&'&'&'
86D9  26 27 26 27 26 27 26 27 26 27 20 06 E0 08 09 08  |&'&'&'&'&' .....
86E9  09 08 09 08 09 08 09 08 09 08 09 08 09 08 09 08  |................
86F9  09 08 09 08 09 08 09 08 09 08 09 08 09 08 09 08  |................
8709  09 08 09 08 09 08 09 08 09 08 09 08 09 08 09 08  |................
8719  09 08 09 08 09 08 09 08 09 08 09 08 09 18 19 18  |................
8729  19 18 19 18 19 18 19 18 19 18 19 18 19 18 19 18  |................
8739  19 18 19 18 19 18 19 18 19 18 19 18 19 20 11 20  |............. . 
8749  21 7F C0 27 06 00 84 F0 F3 30 C0 04 00 81 FC 83  |!..'.....0......
8759  33 30 C0 03 00 81 FF 82 FC F3 81 03 05 00 02 FF  |30..............
8769  08 AF 08 55 08 FA FF 00 24 81 6B 1E 6C E1 6D 68  |...U....$.k.l.mh
8779  6F 01 6E 00 6F 01 6E 00 6F 01 6E 00 6F 01 6E 00  |o.n.o.n.o.n.o.n.
8789  6F 01 6E 00 6F 01 6E 00 6F 01 6E 00 6F 01 36 69  |o.n.o.n.o.n.o.6i
8799  01 6E 00 6F 01 6E 00 6F 01 6E 00 6F 01           |.n.o.n.o.n.o.

loc_87A6:  ; 0 xrefs: 
87A6  6E 00 6F ROR $6F00               
87A9  01 6E    ORA ($6E,X)             
87AB  00 6F    BRK #$6F                

; ==== data $87AD..$8C8C  (1248 bytes) ====
87AD  01 6E 00 6F 01 6E 00 6F 01 6E 37 6A 79 7E 7A 7B  |.n.o.n.o.n7jy~z{
87BD  7C 7B 7C 7B 7C 7B 7C 7B 7C 7B 7C 7B 7C 7B 7C 7B  ||{|{|{|{|{|{|{|{
87CD  7C 7B 7C 7B 7C 7B 7C 7B 7D 7E 38 20 00 7F C0 27  ||{|{|{|{}~8 ...'
87DD  10 00 FF 80 26 21 00 82 80 81 02 82 89 83 84 85  |....&!..........
87ED  86 30 31 32 33 34 08 00 85 37 87 88 89 8A 02 82  |.01234...7......
87FD  82 8B 8C 02 00 82 8D A0 06 00 81 40 03 41 81 44  |...........@.A.D
880D  08 41 81 47 07 00 81 8F 02 00 87 8E 10 0C 01 19  |.A.G............
881D  05 12 0E 00 89 42 43 00 3D 3E 00 3B 3C 90 02 00  |.....BC.=>.;<...
882D  87 8D 05 0E 05 12 07 19 0E 00 89 45 46 00 4D 4E  |...........EF.MN
883D  00 4B 4C 8F 02 00 81 8E 14 00 02 20 81 00 02 20  |.KL........ ... 
884D  81 00 02 20 81 90 02 00 85 91 92 93 94 95 02 96  |... ............
885D  90 97 98 99 9A 93 9B 9C 9D 9E 5F 6F 93 48 97 98  |.........._o.H..
886D  99 02 96 85 49 4A 93 3F 4F 7F E8 27 10 00 FF 80  |....IJ.?O..'....
887D  22 40 D9 40 D9 20 D9 20 D9 7F E8 23 08 00 FF 00  |"@.@. . ...#....
888D  24 20 5F 03 60 81 63 18 66 81 67 03 60 03 61 83  |$ _.`.c.f.g.`.a.
889D  64 DE E8 09 E6 82 E9 E8 09 E6 83 E9 DE 68 03 61  |d............h.a
88AD  03 62 9A 65 DE EA EB EC ED EB EC ED EB EC ED EE  |.b.e............
88BD  EA EB EC ED EB EC ED EB EC ED EE DE 69 03 62 20  |............i.b 
88CD  00 7F C0 27 81 FF 06 5F 81 FF 08 00 FF 00 24 9F  |...'..._......$.
88DD  54 56 A6 A7 A4 A5 A6 A7 A6 A7 A6 A7 A6 A7 A6 A7  |TV..............
88ED  A6 A7 A6 A7 A6 A7 A6 A7 A6 A7 A4 A5 A6 A7 57 02  |..............W.
88FD  54 81 56 1C 00 81 57 02 54 81 56 1C 00 81 57 02  |T.V...W.T.V...W.
890D  54 81 56 1C 00 81 57 02 54 81 56 1C 00 81 57 02  |T.V...W.T.V...W.
891D  54 81 56 1C 00 81 57 02 54 81 56 1C 00 81 57 02  |T.V...W.T.V...W.
892D  54 81 56 1C 00 81 57 02 54 81 56 1C 00 81 57 02  |T.V...W.T.V...W.
893D  54 81 56 1C 00 81 57 02 54 81 56 1C 00 81 57 02  |T.V...W.T.V...W.
894D  54 81 56 1C 00 81 57 02 54 81 56 1C 00 81 57 02  |T.V...W.T.V...W.
895D  54 81 56 1C 00 82 57 54 7F C0 27 81 DD 06 FF 81  |T.V...WT..'.....
896D  77 81 DD 06 FF 81 77 81 DD 06 FF 81 77 81 0D 06  |w.....w.....w...
897D  0F 81 07 FF 80 22 40 02 40 02 40 02 7F E8 23 08  |....."@.@.@...#.
898D  55 08 05 FF 00 20 4A 00 0C D8 13 00 82 DA D7 0A  |U.... J.........
899D  D9 82 D6 DB 12 00 85 DA DB 00 DC DD 02 DE 87 DF  |................
89AD  EE EF FE 00 DA DB 12 00 82 DA D5 0A D8 82 D4 DB  |................
89BD  13 00 0C D9 72 00 10 D8 0F 00 82 DA D7 02 D9 82  |....r...........
89CD  D6 D7 02 D9 82 D6 D7 02 D9 82 D6 D7 02 D9 82 D6  |................
89DD  DB 0E 00 82 DA DB 02 00 82 DA DB 02 00 82 DA DB  |................
89ED  02 00 82 DA DB 02 00 82 DA DB 0E 00 82 DA DB 02  |................
89FD  00 82 DA DB 02 00 82 DA DB 02 00 82 DA DB 02 00  |................
8A0D  82 DA DB 0E 00 82 DA D5 02 D8 82 D4 D5 02 D8 82  |................
8A1D  D4 D5 02 D8 82 D4 D5 02 D8 82 D4 DB 0E 00 82 DA  |................
8A2D  D7 02 D9 82 D6 D7 02 D9 82 D6 D7 02 D9 82 D6 D7  |................
8A3D  02 D9 82 D6 DB 0E 00 82 DA DB 02 00 82 DA DB 02  |................
8A4D  00 82 DA DB 02 00 82 DA DB 02 00 82 DA DB 0E 00  |................
8A5D  82 DA DB 02 00 82 DA DB 02 00 82 DA DB 02 00 82  |................
8A6D  DA DB 02 00 82 DA DB 0E 00 82 DA D5 02 D8 82 D4  |................
8A7D  D5 02 D8 82 D4 D5 02 D8 82 D4 D5 02 D8 82 D4 DB  |................
8A8D  0E 00 82 DA D7 02 D9 82 D6 D7 02 D9 82 D6 D7 02  |................
8A9D  D9 82 D6 D7 02 D9 82 D6 DB 0E 00 82 DA DB 02 00  |................
8AAD  82 DA DB 02 00 82 DA DB 02 00 82 DA DB 02 00 82  |................
8ABD  DA DB 0E 00 82 DA DB 02 00 82 DA DB 02 00 82 DA  |................
8ACD  DB 02 00 82 DA DB 02 00 82 DA DB 0E 00 82 DA D5  |................
8ADD  02 D8 82 D4 D5 02 D8 82 D4 D5 02 D8 82 D4 D5 02  |................
8AED  D8 82 D4 DB 0F 00 10 D9 7E 00 0A 00 7F C0 23 12  |........~.....#.
8AFD  00 04 50 04 00 04 55 04 00 04 55 04 00 04 55 0A  |..P...U...U...U.
8B0D  00 FF A0 20 20 FD 02 7A 02 00 06 7E 02 00 81 7E  |...  ..z...~...~
8B1D  09 FA 82 7E 00 02 76 06 78 82 FB 00 02 FC 08 02  |...~..v.x.......
8B2D  02 75 02 00 0C 7E 02 00 02 FB 03 01 0F 00 02 01  |.u...~..........
8B3D  0C 4B 02 FC 02 00 02 7B 0B 7F 03 FB 04 00 02 FC  |.K.....{........
8B4D  06 02 81 FB 09 00 0E 77 81 00 07 FB 82 77 00 02  |.......w.....w..
8B5D  7A 08 78 02 76 05 00 81 77 0C 79 08 FA 02 7E 81  |z.x.v...w.y...~.
8B6D  00 0D 01 06 00 82 7E FA 02 01 07 4B 02 01 03 00  |......~....K....
8B7D  02 76 0C 78 03 7A 0D 00 8A E0 E1 E2 E3 E4 E5 E6  |.v.x.z..........
8B8D  E7 E8 E9 14 00 8B EA EB EC ED EE EF F0 F1 F2 F3  |................
8B9D  F4 0B 00 20 FE 7F C8 23 08 50 08 55 82 05 85 81  |... ...#.P.U....
8BAD  25 05 05 7F A0 24 20 FD 06 78 02 7A 02 00 81 7E  |%....$ ..x.z...~
8BBD  0A FA 81 7E 02 00 02 76 06 78 09 7F 03 7B 02 00  |...~...v.x...{..
8BCD  02 75 0A 02 02 FC 81 00 03 FB 02 01 03 00 81 77  |.u.............w
8BDD  0B 79 81 77 02 00 0C 01 04 02 02 75 02 00 14 77  |.y.w.......u...w
8BED  02 00 02 FC 02 FB 02 00 0A 77 02 00 02 7B 0C 7F  |.........w...{..
8BFD  02 FB 02 79 81 77 02 00 81 01 0D 4B 82 01 00 05  |...y.w.....K....
8C0D  77 82 00 77 04 79 0A FA 81 7E 02 00 02 7A 0A 78  |w..w.y...~...z.x
8C1D  02 76 81 00 02 7E 02 FA 04 00 02 75 07 02 02 FC  |.v...~.....u....
8C2D  81 00 0A 77 46 00 20 FE 7F C8 27 08 50 10 55 FF  |...wF. ...'.P.U.
8C3D  A0 24 20 FD 06 78 02 7A 02 00 81 7E 0A FA 81 7E  |.$ ..x.z...~...~
8C4D  02 00 02 76 06 78 09 7F 03 7B 02 00 02 75 0A 02  |...v.x...{...u..
8C5D  02 FC 81 00 03 FB 02 01 03 00 81 77 0B 79 81 77  |...........w.y.w
8C6D  02 00 0C 01 04 02 02 75 02 00 14 77 02 00 02 FC  |.......u...w....
8C7D  02 FB 02 00 0A 77 02 00 02 7B 0C 7F 02 FB 02 79  |.....w...{.....y

loc_8C8D:  ; 0 xrefs: 
8C8D  81 77    STA ($77,X)             

; ==== data $8C8F..$8DFF  (369 bytes) ====
8C8F  02 00 81 01 0D 4B 82 01 00 05 77 82 00 77 04 79  |.....K....w..w.y
8C9F  0A FA 81 7E 02 00 02 7A 0A 78 02 76 81 00 02 7E  |...~...z.x.v...~
8CAF  02 FA 04 00 02 75 07 02 02 FC 81 00 0A 77 46 00  |.....u.......wF.
8CBF  20 FE 7F C8 27 08 50 10 55 FF A0 24 20 FD 0D 05  | ...'.P.U..$ ...
8CCF  86 81 04 82 83 84 85 19 05 88 90 91 04 92 93 94  |................
8CDF  95 96 18 05 88 A0 A1 04 A2 A3 A4 A5 A6 18 05 88  |................
8CEF  AC B0 B1 B2 B3 B4 B5 B6 18 05 89 AD C0 C1 C2 C3  |................
8CFF  C4 C5 C6 C7 17 05 8A 9C D0 D1 D2 D3 D4 D5 04 D7  |................
8D0F  D6 13 05 8D 86 87 88 89 8A 8B 8C 8D 8E 8F 04 AE  |................
8D1F  AF 12 05 82 97 98 03 04 89 99 9A 9B 9D 9E 9F BD  |................
8D2F  BE BF 12 05 81 A7 03 04 8A A8 A9 AA AB C8 C9 04  |................
8D3F  CA CB CC 12 05 86 B7 B8 B9 BA BB BC 02 04 86 D8  |................
8D4F  D9 04 CD CE CF 0A 05 20 FE 7F C8 27 08 F0 03 FF  |....... ...'....
8D5F  81 3B 81 CE 06 FF 81 F3 81 FC 03 FF FF FF FF FF  |.;..............
8D6F  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
8D7F  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
8D8F  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
8D9F  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
8DAF  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
8DBF  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
8DCF  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
8DDF  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
8DEF  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
8DFF  FF                                               |.

loc_8E00:  ; 0 xrefs: 
8E00  4C 44 BA JMP loc_BA44            

; ==== data $8E03..$8E0B  (9 bytes) ====
8E03  4C 28 B8 4C 0D B9 4C 1C B9                       |L(.L..L..

loc_8E0C:  ; 0 xrefs: 
8E0C  4C 28 BB JMP loc_BB28            

loc_8E0F:  ; 0 xrefs: 
8E0F  4C 07 BE JMP loc_BE07            

loc_8E12:  ; 0 xrefs: 
8E12  4C 45 A9 JMP sub_A945            

loc_8E15:  ; 1 xrefs: 8000
8E15  A9 05    LDA #$05                
8E17  8D 16 01 STA $0116               
8E1A  EE 10 01 INC $0110               
8E1D  20 16 B3 JSR sub_B316            
8E20  20 70 B5 JSR sub_B570            
8E23  20 7A A1 JSR sub_A17A            
8E26  20 63 A5 JSR sub_A563            
8E29  20 56 8E JSR sub_8E56            
8E2C  20 45 A9 JSR sub_A945            
8E2F  20 9E B6 JSR sub_B69E            
8E32  A9 00    LDA #$00                
8E34  8D CE 05 STA $05CE               
8E37  8D E4 05 STA $05E4               
8E3A  8D FA 05 STA $05FA               
8E3D  8D 10 06 STA $0610               
8E40  8D A2 05 STA $05A2               
8E43  8D 3C 06 STA $063C               
8E46  8D 52 06 STA $0652               
8E49  8D 68 06 STA $0668               
8E4C  8D 17 01 STA $0117               
8E4F  8D 18 01 STA $0118               
8E52  8D 1F 01 STA $011F               
8E55  60       RTS                     

sub_8E56:  ; 1 xrefs: 8E29
8E56  AC 8C 05 LDY $058C               
8E59  B9 66 8E LDA $8E66,Y             
8E5C  85 08    STA $08                 
8E5E  B9 89 8E LDA $8E89,Y             
8E61  85 09    STA $09                 
8E63  6C 08 00 JMP ($0008)             

; ==== data $8E66..$8EAC  (71 bytes) ====
8E66  AD AC AC AC C1 8C AC 36 B5 93 AC AC 0A AC EB AC  |.......6........
8E76  A9 5F 77 8B 97 AC 37 AC 37 97 55 C8 C5 AC AC AC  |._w...7.7.U.....
8E86  C3 0C 1C 8E 8E 8E 8E 8E 8F 8E 90 91 91 8E 8E 9B  |................
8E96  8E 9C 8E 94 94 94 94 97 8E 95 8E 99 9A 99 99 99  |................
8EA6  8E 8E 8E 9D 9E 9E 60                             |......`

loc_8EAD:  ; 0 xrefs: 
8EAD  4C B0 8E JMP loc_8EB0            

loc_8EB0:  ; 5 xrefs: 8EAD 9446 9AD6 9B2D 9DA8
8EB0  A9 11    LDA #$11                
8EB2  20 44 9E JSR sub_9E44            
8EB5  A9 00    LDA #$00                
8EB7  8D 11 01 STA $0111               
8EBA  A9 00    LDA #$00                
8EBC  A0 04    LDY #$04                
8EBE  4C 26 9E JMP sub_9E26            

; ==== data $8EC1..$8F01  (65 bytes) ====
8EC1  A0 08 20 36 A0 A0 18 20 26 A1 20 C2 A1 AD 16 04  |.. 6... &. .....
8ED1  10 08 A9 80 20 29 9E 4C 02 8F A5 4A 29 03 F0 07  |.... ).L...J)...
8EE1  A9 00 8D 11 01 F0 22 CE 11 01 AD 11 01 30 08 C9  |......"......0..
8EF1  70 90 04 A9 12 D0 02 A9 11 20 44 9E A9 00 20 29  |p........ D... )
8F01  9E                                               |.

loc_8F02:  ; 0 xrefs: 
8F02  A0 01    LDY #$01                
8F04  20 6D A0 JSR sub_A06D            
8F07  4C 2D 8F JMP loc_8F2D            

; ==== data $8F0A..$8F2C  (35 bytes) ====
8F0A  20 8D A0 90 08 A9 11 20 44 9E 4C 2D 8F AD 16 04  | ...... D.L-....
8F1A  29 02 D0 0A A9 02 20 29 9E A0 01 20 17 B0 A0 01  |)..... )... ....
8F2A  20 1F B0                                         | ..

loc_8F2D:  ; 1 xrefs: 8F07
8F2D  A5 4A    LDA $4A                 
8F2F  29 08    AND #$08                
8F31  F0 10    BEQ loc_8F43            
8F33  A0 00    LDY #$00                
8F35  20 8D AD JSR sub_AD8D            
8F38  F0 09    BEQ loc_8F43            
8F3A  A0 08    LDY #$08                
8F3C  20 19 AE JSR sub_AE19            
8F3F  D0 3E    BNE loc_8F7F            
8F41  F0 11    BEQ loc_8F54            

loc_8F43:  ; 2 xrefs: 8F31 8F38
8F43  20 29 9A JSR sub_9A29            
8F46  90 01    BCC loc_8F49            
8F48  60       RTS                     

loc_8F49:  ; 1 xrefs: 8F46
8F49  30 0C    BMI loc_8F57            
8F4B  F0 07    BEQ loc_8F54            
8F4D  A0 08    LDY #$08                
8F4F  20 19 AE JSR sub_AE19            
8F52  D0 03    BNE loc_8F57            

loc_8F54:  ; 2 xrefs: 8F41 8F4B
8F54  4C DB 9F JMP loc_9FDB            

loc_8F57:  ; 2 xrefs: 8F49 8F52
8F57  AD 16 04 LDA $0416               
8F5A  30 23    BMI loc_8F7F            
8F5C  A5 4A    LDA $4A                 
8F5E  29 08    AND #$08                
8F60  F0 07    BEQ loc_8F69            
8F62  A5 48    LDA $48                 
8F64  0A       ASL A                   
8F65  B0 07    BCS loc_8F6E            
8F67  90 16    BCC loc_8F7F            

loc_8F69:  ; 1 xrefs: 8F60
8F69  20 CB 9F JSR sub_9FCB            
8F6C  90 03    BCC loc_8F71            

loc_8F6E:  ; 1 xrefs: 8F65
8F6E  4C E2 9F JMP loc_9FE2            

loc_8F71:  ; 1 xrefs: 8F6C
8F71  A5 4A    LDA $4A                 
8F73  29 04    AND #$04                
8F75  F0 08    BEQ loc_8F7F            
8F77  20 03 A0 JSR sub_A003            
8F7A  B0 03    BCS loc_8F7F            
8F7C  20 80 8F JSR sub_8F80            

loc_8F7F:  ; 5 xrefs: 8F3F 8F5A 8F67 8F75 8F7A
8F7F  60       RTS                     

sub_8F80:  ; 1 xrefs: 8F7C
8F80  A9 09    LDA #$09                
8F82  8D 42 04 STA $0442               
8F85  A9 08    LDA #$08                
8F87  A0 05    LDY #$05                
8F89  4C 26 9E JMP sub_9E26            

; ==== data $8F8C..$8FBF  (52 bytes) ====
8F8C  A0 0A 20 36 A0 A0 1B 20 26 A1 A0 02 20 6D A0 A0  |.. 6... &... m..
8F9C  0A 20 19 AE F0 3F 20 C2 A1 AD 16 04 30 33 A5 4A  |. ...? .....03.J
8FAC  29 04 D0 0A A0 0B 20 8D AD D0 09 4C B0 8E 20 03  |)..... ....L.. .
8FBC  A0 90 01 60                                      |...`

loc_8FC0:  ; 0 xrefs: 
8FC0  A5 48    LDA $48                 
8FC2  0A       ASL A                   
8FC3  90 18    BCC loc_8FDD            
8FC5  AD A2 05 LDA $05A2               
8FC8  30 13    BMI loc_8FDD            
8FCA  A9 07    LDA #$07                
8FCC  A2 00    LDX #$00                
8FCE  2C 2C 04 BIT $042C               
8FD1  50 03    BVC loc_8FD6            
8FD3  A9 F8    LDA #$F8                
8FD5  CA       DEX                     

loc_8FD6:  ; 1 xrefs: 8FD1
8FD6  A0 04    LDY #$04                
8FD8  20 D5 AC JSR sub_ACD5            
8FDB  F0 0F    BEQ loc_8FEC            

loc_8FDD:  ; 2 xrefs: 8FC3 8FC8
8FDD  20 11 A1 JSR sub_A111            
8FE0  60       RTS                     

; ==== data $8FE1..$8FEB  (11 bytes) ====
8FE1  20 AA B1 01 00 A9 00 A8 4C E6 9F                 | .......L..

loc_8FEC:  ; 1 xrefs: 8FDB
8FEC  A9 0D    LDA #$0D                
8FEE  20 44 9E JSR sub_9E44            
8FF1  A9 10    LDA #$10                
8FF3  A0 07    LDY #$07                
8FF5  20 26 9E JSR sub_9E26            
8FF8  20 35 B6 JSR sub_B635            
8FFB  A0 00    LDY #$00                
8FFD  A2 00    LDX #$00                
8FFF  A5 9A    LDA $9A                 
9001  F0 04    BEQ loc_9007            
9003  A0 02    LDY #$02                
9005  A2 01    LDX #$01                

loc_9007:  ; 1 xrefs: 9001
9007  2C 2C 04 BIT $042C               
900A  50 01    BVC loc_900D            
900C  C8       INY                     

loc_900D:  ; 1 xrefs: 900A
900D  BD 2A 90 LDA $902A,X             
9010  8D 11 01 STA $0111               
9013  BD 2C 90 LDA $902C,X             
9016  8D 12 01 STA $0112               
9019  B9 2E 90 LDA $902E,Y             
901C  85 02    STA $02                 
901E  85 04    STA $04                 
9020  B9 32 90 LDA $9032,Y             
9023  85 03    STA $03                 
9025  85 05    STA $05                 
9027  4C 42 B2 JMP sub_B242            

; ==== data $902A..$905D  (52 bytes) ====
902A  00 00 3E 78 80 80 80 80 02 FD 03 FC A0 08 20 36  |..>x.......... 6
903A  A0 A0 21 20 26 A1 A0 0B 20 8D AD 8D 13 01 2C 2C  |..! &... .....,,
904A  04 70 0A 20 3A B2 02 00 FF FE 4C 5E 90 20 3A B2  |.p. :.....L^. :.
905A  FE 00 00 02                                      |....

loc_905E:  ; 0 xrefs: 
905E  2C 2C 04 BIT $042C               
9061  50 13    BVC loc_9076            
9063  AD 11 01 LDA $0111               
9066  18       CLC                     
9067  6D 76 05 ADC $0576               
906A  8D 11 01 STA $0111               
906D  AD 12 01 LDA $0112               
9070  6D 60 05 ADC $0560               
9073  4C 86 90 JMP loc_9086            

loc_9076:  ; 1 xrefs: 9061
9076  AD 11 01 LDA $0111               
9079  38       SEC                     
907A  ED 76 05 SBC $0576               
907D  8D 11 01 STA $0111               
9080  AD 12 01 LDA $0112               
9083  ED 60 05 SBC $0560               

loc_9086:  ; 1 xrefs: 9073
9086  8D 12 01 STA $0112               
9089  30 11    BMI loc_909C            
908B  A5 4A    LDA $4A                 
908D  29 04    AND #$04                
908F  F0 03    BEQ loc_9094            
9091  4C AB 90 JMP loc_90AB            

loc_9094:  ; 1 xrefs: 908F
9094  AD 13 01 LDA $0113               
9097  D0 12    BNE loc_90AB            

loc_9099:  ; 1 xrefs: 909F
9099  4C 2E 91 JMP loc_912E            

loc_909C:  ; 1 xrefs: 9089
909C  AD 13 01 LDA $0113               
909F  F0 F8    BEQ loc_9099            
90A1  A9 08    LDA #$08                
90A3  8D 12 01 STA $0112               
90A6  A9 00    LDA #$00                
90A8  8D 11 01 STA $0111               

loc_90AB:  ; 2 xrefs: 9091 9097
90AB  A5 4A    LDA $4A                 
90AD  29 03    AND #$03                
90AF  F0 1F    BEQ loc_90D0            
90B1  AD 13 01 LDA $0113               
90B4  F0 1A    BEQ loc_90D0            
90B6  A5 4A    LDA $4A                 
90B8  A0 00    LDY #$00                
90BA  4A       LSR A                   
90BB  B0 02    BCS loc_90BF            
90BD  A0 40    LDY #$40                

loc_90BF:  ; 1 xrefs: 90BB
90BF  84 00    STY $00                 
90C1  AD 2C 04 LDA $042C               
90C4  29 40    AND #$40                
90C6  C5 00    CMP $00                 
90C8  F0 06    BEQ loc_90D0            
90CA  20 03 B3 JSR sub_B303            
90CD  20 3B 9E JSR sub_9E3B            

loc_90D0:  ; 3 xrefs: 90AF 90B4 90C8
90D0  20 FA B1 JSR sub_B1FA            
90D3  A0 04    LDY #$04                
90D5  20 BA AC JSR sub_ACBA            
90D8  F0 1A    BEQ loc_90F4            
90DA  20 F1 B2 JSR sub_B2F1            
90DD  AD 13 01 LDA $0113               
90E0  F0 4C    BEQ loc_912E            
90E2  20 5A 91 JSR sub_915A            
90E5  20 29 9A JSR sub_9A29            
90E8  90 01    BCC loc_90EB            
90EA  60       RTS                     

loc_90EB:  ; 1 xrefs: 90E8
90EB  A0 08    LDY #$08                
90ED  20 19 AE JSR sub_AE19            
90F0  D0 3B    BNE loc_912D            
90F2  F0 13    BEQ loc_9107            

loc_90F4:  ; 1 xrefs: 90D8
90F4  20 5C B1 JSR sub_B15C            
90F7  20 5A 91 JSR sub_915A            
90FA  20 29 9A JSR sub_9A29            
90FD  90 01    BCC loc_9100            
90FF  60       RTS                     

loc_9100:  ; 1 xrefs: 90FD
9100  A0 05    LDY #$05                
9102  20 19 AE JSR sub_AE19            
9105  D0 26    BNE loc_912D            

loc_9107:  ; 1 xrefs: 90F2
9107  A0 0B    LDY #$0B                
9109  20 8D AD JSR sub_AD8D            
910C  F0 1C    BEQ loc_912A            
910E  48       PHA                     
910F  20 AA B1 JSR sub_B1AA            
9112  08       PHP                     
9113  00 68    BRK #$68                

; ==== data $9115..$9129  (21 bytes) ====
9115  C9 01 F0 0C C9 80 D0 0D A9 DC 20 8A 9F 4C DB 9F  |.......... ..L..
9125  A9 DC 20 23 9F                                   |.. #.

loc_912A:  ; 1 xrefs: 910C
912A  4C DB 9F JMP loc_9FDB            

loc_912D:  ; 2 xrefs: 90F0 9105
912D  60       RTS                     

loc_912E:  ; 2 xrefs: 9099 90E0
912E  20 5A 91 JSR sub_915A            
9131  20 29 9A JSR sub_9A29            
9134  90 01    BCC loc_9137            
9136  60       RTS                     

loc_9137:  ; 1 xrefs: 9134
9137  A0 05    LDY #$05                
9139  20 19 AE JSR sub_AE19            
913C  D0 03    BNE loc_9141            
913E  4C DB 9F JMP loc_9FDB            

loc_9141:  ; 1 xrefs: 913C
9141  AD 60 05 LDA $0560               
9144  30 0A    BMI loc_9150            
9146  20 3A B2 JSR sub_B23A            
9149  00 00    BRK #$00                

; ==== data $914B..$914F  (5 bytes) ====
914B  FF 40 4C 80 8F                                   |.@L..

loc_9150:  ; 1 xrefs: 9144
9150  20 3A B2 JSR sub_B23A            
9153  00 00    BRK #$00                

; ==== data $9155..$9159  (5 bytes) ====
9155  00 C0 4C 80 8F                                   |..L..

sub_915A:  ; 3 xrefs: 90E2 90F7 912E
915A  A5 4A    LDA $4A                 
915C  29 04    AND #$04                
915E  D0 32    BNE loc_9192            
9160  20 BD 9F JSR sub_9FBD            
9163  90 2D    BCC loc_9192            
9165  A0 0D    LDY #$0D                
9167  20 19 AE JSR sub_AE19            
916A  D0 26    BNE loc_9192            
916C  A0 0B    LDY #$0B                
916E  20 8D AD JSR sub_AD8D            
9171  D0 1F    BNE loc_9192            
9173  20 3B 9E JSR sub_9E3B            
9176  20 AA B1 JSR sub_B1AA            
9179  0A       ASL A                   
917A  00 20    BRK #$20                

; ==== data $917C..$9191  (22 bytes) ====
917C  4B 97 90 0A 68 68 A9 3A 20 1C C8 4C 7F 97 20 3B  |K...hh.: ..L.. ;
918C  9E 20 AA B1 F6 00                                |. ....

loc_9192:  ; 4 xrefs: 915E 9163 916A 9171
9192  60       RTS                     

; ==== data $9193..$91B4  (34 bytes) ====
9193  A0 0A 20 36 A0 A0 1B 20 26 A1 A0 02 20 6D A0 A0  |.. 6... &... m..
91A3  0A 20 19 AE D0 03 4C DB 9F CE 11 01 D0 03 4C 80  |. ....L.......L.
91B3  8F 60                                            |.`

loc_91B5:  ; 0 xrefs: 
91B5  A0 2B    LDY #$2B                
91B7  20 26 A1 JSR sub_A126            
91BA  20 C2 A1 JSR sub_A1C2            
91BD  AD 16 04 LDA $0416               
91C0  10 0B    BPL loc_91CD            
91C2  20 FA B1 JSR sub_B1FA            
91C5  A0 01    LDY #$01                
91C7  20 56 A0 JSR sub_A056            
91CA  4C D0 91 JMP loc_91D0            

loc_91CD:  ; 1 xrefs: 91C0
91CD  20 8D A0 JSR sub_A08D            

loc_91D0:  ; 1 xrefs: 91CA
91D0  A9 05    LDA #$05                
91D2  A0 F8    LDY #$F8                
91D4  20 35 AC JSR sub_AC35            
91D7  30 11    BMI loc_91EA            
91D9  A9 FA    LDA #$FA                
91DB  A0 F8    LDY #$F8                
91DD  20 35 AC JSR sub_AC35            
91E0  10 0D    BPL loc_91EF            
91E2  20 4F B1 JSR sub_B14F            
91E5  01 00    ORA ($00,X)             
91E7  4C EF 91 JMP loc_91EF            

loc_91EA:  ; 1 xrefs: 91D7
91EA  20 4F B1 JSR sub_B14F            
91ED  FF 00 AD ISC $AD00,X             
91F0  4A       LSR A                   
91F1  05 18    ORA $18                 
91F3  69 32    ADC #$32                
91F5  8D 4A 05 STA $054A               
91F8  AD 34 05 LDA $0534               
91FB  69 00    ADC #$00                
91FD  8D 34 05 STA $0534               
9200  10 19    BPL loc_921B            
9202  A5 4A    LDA $4A                 
9204  0A       ASL A                   
9205  B0 3D    BCS loc_9244            
9207  AD 4A 05 LDA $054A               
920A  18       CLC                     
920B  69 70    ADC #$70                
920D  8D 4A 05 STA $054A               
9210  AD 34 05 LDA $0534               
9213  69 00    ADC #$00                
9215  8D 34 05 STA $0534               
9218  4C 44 92 JMP loc_9244            

loc_921B:  ; 1 xrefs: 9200
921B  2C A2 05 BIT $05A2               
921E  50 16    BVC loc_9236            
9220  A4 9A    LDY $9A                 
9222  C0 02    CPY #$02                
9224  F0 10    BEQ loc_9236            
9226  C9 02    CMP #$02                
9228  90 1A    BCC loc_9244            
922A  A9 02    LDA #$02                
922C  8D 34 05 STA $0534               
922F  A9 00    LDA #$00                
9231  8D 4A 05 STA $054A               
9234  F0 0E    BEQ loc_9244            

loc_9236:  ; 2 xrefs: 921E 9224
9236  C9 05    CMP #$05                
9238  90 0A    BCC loc_9244            
923A  A9 05    LDA #$05                
923C  8D 34 05 STA $0534               
923F  A9 00    LDA #$00                
9241  8D 4A 05 STA $054A               

loc_9244:  ; 5 xrefs: 9205 9218 9228 9234 9238
9244  20 1A B2 JSR sub_B21A            
9247  AD 4A 05 LDA $054A               
924A  18       CLC                     
924B  6D 11 01 ADC $0111               
924E  8D 11 01 STA $0111               
9251  A0 00    LDY #$00                
9253  AD 34 05 LDA $0534               
9256  10 01    BPL loc_9259            
9258  88       DEY                     

loc_9259:  ; 1 xrefs: 9256
9259  6D 12 01 ADC $0112               
925C  8D 12 01 STA $0112               
925F  98       TYA                     
9260  6D 13 01 ADC $0113               
9263  8D 13 01 STA $0113               
9266  AD 10 06 LDA $0610               
9269  30 03    BMI loc_926E            
926B  4C FC 92 JMP loc_92FC            

loc_926E:  ; 1 xrefs: 9269
926E  AD 16 04 LDA $0416               
9271  30 43    BMI loc_92B6            
9273  AD C6 04 LDA $04C6               
9276  C9 28    CMP #$28                
9278  90 24    BCC loc_929E            
927A  20 BD 9F JSR sub_9FBD            
927D  90 1F    BCC loc_929E            
927F  A9 18    LDA #$18                
9281  20 44 9E JSR sub_9E44            
9284  A0 0D    LDY #$0D                
9286  20 19 AE JSR sub_AE19            
9289  F0 03    BEQ loc_928E            
928B  4C 1F 94 JMP loc_941F            

loc_928E:  ; 1 xrefs: 9289
928E  A0 0C    LDY #$0C                
9290  20 8D AD JSR sub_AD8D            
9293  F0 06    BEQ loc_929B            
9295  C9 81    CMP #$81                
9297  90 3A    BCC loc_92D3            
9299  B0 22    BCS loc_92BD            

loc_929B:  ; 1 xrefs: 9293
929B  4C 8D 93 JMP loc_938D            

loc_929E:  ; 2 xrefs: 9278 927D
929E  2C A2 05 BIT $05A2               
92A1  50 13    BVC loc_92B6            
92A3  A5 9A    LDA $9A                 
92A5  C9 02    CMP #$02                
92A7  D0 0D    BNE loc_92B6            
92A9  A0 0D    LDY #$0D                
92AB  20 19 AE JSR sub_AE19            
92AE  F0 03    BEQ loc_92B3            
92B0  4C 1F 94 JMP loc_941F            

loc_92B3:  ; 1 xrefs: 92AE
92B3  4C F3 92 JMP loc_92F3            

loc_92B6:  ; 3 xrefs: 9271 92A1 92A7
92B6  A0 03    LDY #$03                
92B8  20 9E AD JSR sub_AD9E            
92BB  F0 0E    BEQ loc_92CB            

loc_92BD:  ; 1 xrefs: 9299
92BD  20 FA B2 JSR sub_B2FA            
92C0  8D DC 04 STA $04DC               
92C3  A9 18    LDA #$18                
92C5  20 44 9E JSR sub_9E44            
92C8  4C 22 94 JMP loc_9422            

loc_92CB:  ; 1 xrefs: 92BB
92CB  A9 18    LDA #$18                
92CD  20 44 9E JSR sub_9E44            
92D0  4C B9 93 JMP loc_93B9            

loc_92D3:  ; 2 xrefs: 9297 932D
92D3  C9 01    CMP #$01                
92D5  F0 0C    BEQ loc_92E3            
92D7  C9 80    CMP #$80                
92D9  D0 0D    BNE loc_92E8            
92DB  A9 E0    LDA #$E0                
92DD  20 8A 9F JSR sub_9F8A            
92E0  4C E8 92 JMP loc_92E8            

loc_92E3:  ; 1 xrefs: 92D5
92E3  A9 E0    LDA #$E0                
92E5  20 23 9F JSR sub_9F23            

loc_92E8:  ; 2 xrefs: 92D9 92E0
92E8  A9 3A    LDA #$3A                
92EA  20 1C C8 JSR $C81C               
92ED  20 4D 9E JSR sub_9E4D            
92F0  4C 23 95 JMP sub_9523            

loc_92F3:  ; 2 xrefs: 92B3 935B
92F3  20 4D 9E JSR sub_9E4D            
92F6  20 8C 9E JSR sub_9E8C            
92F9  4C DF 9C JMP loc_9CDF            

loc_92FC:  ; 1 xrefs: 926B
92FC  A0 08    LDY #$08                
92FE  20 2A AE JSR sub_AE2A            
9301  F0 03    BEQ loc_9306            
9303  4C 23 94 JMP loc_9423            

loc_9306:  ; 1 xrefs: 9301
9306  AD 16 04 LDA $0416               
9309  10 03    BPL loc_930E            
930B  4C 1F 94 JMP loc_941F            

loc_930E:  ; 1 xrefs: 9309
930E  AD C6 04 LDA $04C6               
9311  C9 28    CMP #$28                
9313  90 67    BCC loc_937C            
9315  20 BD 9F JSR sub_9FBD            
9318  90 29    BCC loc_9343            
931A  A0 0D    LDY #$0D                
931C  20 19 AE JSR sub_AE19            
931F  F0 03    BEQ loc_9324            
9321  4C 1F 94 JMP loc_941F            

loc_9324:  ; 1 xrefs: 931F
9324  A0 0C    LDY #$0C                
9326  20 8D AD JSR sub_AD8D            
9329  F0 07    BEQ loc_9332            
932B  C9 81    CMP #$81                
932D  90 A4    BCC loc_92D3            
932F  4C 1F 94 JMP loc_941F            

loc_9332:  ; 1 xrefs: 9329
9332  A9 18    LDA #$18                
9334  AC 10 06 LDY $0610               
9337  C0 02    CPY #$02                
9339  90 02    BCC loc_933D            
933B  A9 19    LDA #$19                

loc_933D:  ; 1 xrefs: 9339
933D  20 44 9E JSR sub_9E44            
9340  4C 8D 93 JMP loc_938D            

loc_9343:  ; 1 xrefs: 9318
9343  AD A2 05 LDA $05A2               
9346  F0 16    BEQ loc_935E            
9348  0A       ASL A                   
9349  10 31    BPL loc_937C            
934B  A5 9A    LDA $9A                 
934D  C9 02    CMP #$02                
934F  D0 2B    BNE loc_937C            
9351  A0 0D    LDY #$0D                
9353  20 19 AE JSR sub_AE19            
9356  F0 03    BEQ loc_935B            
9358  4C 1F 94 JMP loc_941F            

loc_935B:  ; 1 xrefs: 9356
935B  4C F3 92 JMP loc_92F3            

loc_935E:  ; 1 xrefs: 9346
935E  AD 10 06 LDA $0610               
9361  F0 19    BEQ loc_937C            
9363  A5 9A    LDA $9A                 
9365  C9 03    CMP #$03                
9367  D0 13    BNE loc_937C            
9369  A0 0D    LDY #$0D                
936B  20 19 AE JSR sub_AE19            
936E  F0 03    BEQ loc_9373            
9370  4C 1F 94 JMP loc_941F            

loc_9373:  ; 1 xrefs: 936E
9373  20 4D 9E JSR sub_9E4D            
9376  20 8C 9E JSR sub_9E8C            
9379  4C F6 9A JMP loc_9AF6            

loc_937C:  ; 5 xrefs: 9313 9349 934F 9361 9367
937C  A9 18    LDA #$18                
937E  AC 10 06 LDY $0610               
9381  C0 02    CPY #$02                
9383  90 02    BCC loc_9387            
9385  A9 19    LDA #$19                

loc_9387:  ; 1 xrefs: 9383
9387  20 44 9E JSR sub_9E44            
938A  4C B9 93 JMP loc_93B9            

loc_938D:  ; 2 xrefs: 929B 9340
938D  A0 EA    LDY #$EA                
938F  A9 00    LDA #$00                
9391  20 35 AC JSR sub_AC35            
9394  C9 01    CMP #$01                
9396  D0 09    BNE loc_93A1            
9398  A5 4A    LDA $4A                 
939A  29 08    AND #$08                
939C  F0 18    BEQ loc_93B6            
939E  4C 91 94 JMP loc_9491            

loc_93A1:  ; 1 xrefs: 9396
93A1  A5 4A    LDA $4A                 
93A3  29 03    AND #$03                
93A5  F0 0F    BEQ loc_93B6            
93A7  AD C6 04 LDA $04C6               
93AA  C9 C8    CMP #$C8                
93AC  B0 08    BCS loc_93B6            
93AE  20 4B 97 JSR sub_974B            
93B1  90 03    BCC loc_93B6            
93B3  4C 17 94 JMP loc_9417            

loc_93B6:  ; 4 xrefs: 939C 93A5 93AC 93B1
93B6  4C 1F 94 JMP loc_941F            

loc_93B9:  ; 2 xrefs: 92D0 938A
93B9  AD 16 04 LDA $0416               
93BC  10 03    BPL loc_93C1            
93BE  4C 1F 94 JMP loc_941F            

loc_93C1:  ; 1 xrefs: 93BC
93C1  A5 4A    LDA $4A                 
93C3  29 08    AND #$08                
93C5  F0 1C    BEQ loc_93E3            
93C7  A0 EA    LDY #$EA                
93C9  A9 00    LDA #$00                
93CB  20 35 AC JSR sub_AC35            
93CE  C9 01    CMP #$01                
93D0  D0 03    BNE loc_93D5            
93D2  4C 91 94 JMP loc_9491            

loc_93D5:  ; 1 xrefs: 93D0
93D5  20 BD 9F JSR sub_9FBD            
93D8  90 45    BCC loc_941F            
93DA  A5 4A    LDA $4A                 
93DC  29 03    AND #$03                
93DE  D0 19    BNE loc_93F9            
93E0  4C 1F 94 JMP loc_941F            

loc_93E3:  ; 1 xrefs: 93C5
93E3  20 BD 9F JSR sub_9FBD            
93E6  90 37    BCC loc_941F            
93E8  A5 4A    LDA $4A                 
93EA  29 03    AND #$03                
93EC  F0 31    BEQ loc_941F            
93EE  A0 EA    LDY #$EA                
93F0  A9 00    LDA #$00                
93F2  20 35 AC JSR sub_AC35            
93F5  C9 01    CMP #$01                
93F7  F0 26    BEQ loc_941F            

loc_93F9:  ; 1 xrefs: 93DE
93F9  AD C6 04 LDA $04C6               
93FC  C9 28    CMP #$28                
93FE  90 1F    BCC loc_941F            
9400  C9 C8    CMP #$C8                
9402  B0 1B    BCS loc_941F            
9404  A0 0C    LDY #$0C                
9406  20 8D AD JSR sub_AD8D            
9409  D0 14    BNE loc_941F            
940B  A0 0D    LDY #$0D                
940D  20 19 AE JSR sub_AE19            
9410  D0 0D    BNE loc_941F            
9412  20 4B 97 JSR sub_974B            
9415  90 08    BCC loc_941F            

loc_9417:  ; 1 xrefs: 93B3
9417  A9 3A    LDA #$3A                
9419  20 1C C8 JSR $C81C               
941C  4C 7F 97 JMP loc_977F            

loc_941F:  ; 19 xrefs: 928B 92B0 930B 9321 932F 9358 9370 93B6 93BE 93D8 ...
941F  4C B7 B1 JMP sub_B1B7            

loc_9422:  ; 1 xrefs: 92C8
9422  60       RTS                     

loc_9423:  ; 1 xrefs: 9303
9423  C9 01    CMP #$01                
9425  F0 0A    BEQ loc_9431            
9427  C9 80    CMP #$80                
9429  D0 09    BNE loc_9434            
942B  20 72 9F JSR sub_9F72            
942E  4C 34 94 JMP loc_9434            

loc_9431:  ; 1 xrefs: 9425
9431  20 D2 9E JSR sub_9ED2            

loc_9434:  ; 2 xrefs: 9429 942E
9434  20 FA B2 JSR sub_B2FA            
9437  8D DC 04 STA $04DC               
943A  AD 13 01 LDA $0113               
943D  30 07    BMI loc_9446            
943F  AD 12 01 LDA $0112               
9442  C9 40    CMP #$40                
9444  B0 03    BCS loc_9449            

loc_9446:  ; 1 xrefs: 943D
9446  4C B0 8E JMP loc_8EB0            

loc_9449:  ; 1 xrefs: 9444
9449  A9 09    LDA #$09                
944B  20 44 9E JSR sub_9E44            
944E  A9 0C    LDA #$0C                
9450  8D 11 01 STA $0111               
9453  A9 19    LDA #$19                
9455  20 1C C8 JSR $C81C               
9458  A9 08    LDA #$08                
945A  A0 09    LDY #$09                
945C  4C 26 9E JMP sub_9E26            

; ==== data $945F..$9490  (50 bytes) ====
945F  20 9C 9F CE 11 01 D0 0F 20 AA B1 10 00 A0 02 20  | ....... ...... 
946F  17 B0 A9 10 8D 8C 05 60 20 9C 9F CE 11 01 D0 0B  |.......` .......
947F  20 AA B1 F6 00 20 D2 9E 4C B0 8E 60 20 9C 9F 90  | .... ..L..` ...
948F  01 60                                            |.`

loc_9491:  ; 2 xrefs: 939E 93D2
9491  20 EE B2 JSR sub_B2EE            
9494  A0 02    LDY #$02                
9496  20 17 B0 JSR sub_B017            
9499  A5 9A    LDA $9A                 
949B  F0 05    BEQ loc_94A2            
949D  A9 3A    LDA #$3A                
949F  20 1C C8 JSR $C81C               

loc_94A2:  ; 1 xrefs: 949B
94A2  A9 04    LDA #$04                
94A4  A0 10    LDY #$10                
94A6  4C 26 9E JMP sub_9E26            

; ==== data $94A9..$94D0  (40 bytes) ====
94A9  20 9C 9F 20 C2 A1 AD 16 04 30 34 A5 4A 29 04 D0  | .. .....04.J)..
94B9  10 A5 4A 29 08 F0 19 20 94 B2 FF 00 FE 00 4C D1  |..J)... ......L.
94C9  94 20 94 B2 01 00 02 00                          |. ......

loc_94D1:  ; 0 xrefs: 
94D1  A0 02    LDY #$02                
94D3  20 1F B0 JSR sub_B01F            
94D6  4C EB 94 JMP loc_94EB            

; ==== data $94D9..$94EA  (18 bytes) ====
94D9  A5 48 0A 90 07 A9 78 A0 FE 4C E6 9F 20 11 A1 20  |.H....x..L.. .. 
94E9  FA B2                                            |..

loc_94EB:  ; 1 xrefs: 94D6
94EB  20 1A B2 JSR sub_B21A            
94EE  20 B7 B1 JSR sub_B1B7            
94F1  A0 EC    LDY #$EC                
94F3  A9 00    LDA #$00                
94F5  20 35 AC JSR sub_AC35            
94F8  C9 01    CMP #$01                
94FA  F0 03    BEQ loc_94FF            
94FC  4C DB 9F JMP loc_9FDB            

loc_94FF:  ; 1 xrefs: 94FA
94FF  A0 E8    LDY #$E8                
9501  A9 00    LDA #$00                
9503  20 35 AC JSR sub_AC35            
9506  C9 01    CMP #$01                
9508  F0 18    BEQ loc_9522            
950A  20 FA B2 JSR sub_B2FA            
950D  20 AA B1 JSR sub_B1AA            
9510  F6 00    INC $00,X               
9512  A9 08    LDA #$08                
9514  8D 11 01 STA $0111               
9517  A9 1E    LDA #$1E                
9519  8D 42 04 STA $0442               
951C  A9 12    LDA #$12                
951E  8D 8C 05 STA $058C               
9521  60       RTS                     

loc_9522:  ; 1 xrefs: 9508
9522  60       RTS                     

sub_9523:  ; 3 xrefs: 92F0 9875 9991
9523  20 EE B2 JSR sub_B2EE            
9526  A0 00    LDY #$00                
9528  20 17 B0 JSR sub_B017            
952B  A9 0A    LDA #$0A                
952D  8D 6E 04 STA $046E               
9530  A9 40    LDA #$40                
9532  A0 16    LDY #$16                
9534  4C 26 9E JMP sub_9E26            

; ==== data $9537..$9591  (91 bytes) ====
9537  A0 1E 20 26 A1 A5 9A C9 01 F0 03 4C DB 9F A5 97  |.. &.......L....
9547  D0 05 A9 01 8D 16 01 A0 0C 20 9E AD C9 82 D0 03  |......... ......
9557  4C 04 97 C9 00 D0 52 A0 EA A9 00 20 35 AC C9 01  |L.....R.... 5...
9567  F0 3D A2 00 2C 2C 04 70 01 CA A9 00 A0 10 20 D5  |.=..,,.p...... .
9577  AC D0 03 4C 04 97 C9 80 F0 0C C9 01 D0 0D A9 00  |...L............
9587  20 FE 9E 4C 92 95 A9 00 20 39 9F                 | ..L.... 9.

loc_9592:  ; 0 xrefs: 
9592  20 AA B1 JSR sub_B1AA            
9595  F8       SED                     
9596  00 20    BRK #$20                

; ==== data $9598..$9660  (201 bytes) ====
9598  EE B2 A0 04 20 17 B0 A9 20 A0 18 4C 26 9E A9 13  |.... ... ..L&...
95A8  8D 8C 05 A9 18 4C 44 9E 20 C2 A1 AD 16 04 10 03  |.....LD. .......
95B8  4C F2 96 20 11 A1 A5 4A 29 03 D0 41 AD A2 05 F0  |L.. ...J)..A....
95C8  06 AD 10 01 4A B0 2E AD 42 04 C9 26 F0 22 CE 6E  |....J...B..&.".n
95D8  04 D0 22 AD 84 04 85 00 A0 00 20 17 B0 A4 00 BE  |.."....... .....
95E8  17 97 F0 0C A9 0A 8D 6E 04 2C 2C 04 50 66 70 56  |.......n.,,.PfpV
95F8  A9 0A 8D 6E 04 A0 0E 20 56 A0 4C F2 96 AD A2 05  |...n... V.L.....
9608  F0 09 AD 10 01 4A B0 03 4C F2 96 A0 00 20 36 B0  |.....J..L.... 6.
9618  AD 6E 04 C9 07 F0 06 C9 06 F0 09 D0 0F CE 6E 04  |.n............n.
9628  A2 01 D0 1D AC 84 04 BE 0F 97 D0 15 A2 00 A0 01  |................
9638  2C 2C 04 50 03 CA A0 FF 98 A0 0E 20 D5 AC 4C 6B  |,,.P....... ..Lk
9648  96 A5 4A 4A B0 0E 8A 49 FF 69 01 AA A9 40 20 34  |..JJ...I.i...@ 4
9658  9E 4C 61 96 A9 BF 20 2D 9E                       |.La... -.

loc_9661:  ; 0 xrefs: 
9661  A9 00    LDA #$00                
9663  20 0B B2 JSR sub_B20B            
9666  A0 0E    LDY #$0E                
9668  20 BA AC JSR sub_ACBA            

loc_966B:  ; 0 xrefs: 
966B  D0 03    BNE loc_9670            
966D  4C EF 96 JMP loc_96EF            

loc_9670:  ; 1 xrefs: 966B
9670  C9 01    CMP #$01                
9672  F0 0C    BEQ loc_9680            
9674  C9 80    CMP #$80                
9676  D0 0D    BNE loc_9685            
9678  A9 05    LDA #$05                
967A  20 43 9F JSR sub_9F43            
967D  4C 85 96 JMP loc_9685            

loc_9680:  ; 1 xrefs: 9672
9680  A9 05    LDA #$05                
9682  20 08 9F JSR sub_9F08            

loc_9685:  ; 2 xrefs: 9676 967D
9685  A5 4A    LDA $4A                 
9687  29 08    AND #$08                
9689  D0 4D    BNE loc_96D8            
968B  20 20 97 JSR sub_9720            
968E  F0 0F    BEQ loc_969F            
9690  C9 82    CMP #$82                
9692  F0 44    BEQ loc_96D8            
9694  A5 0C    LDA $0C                 
9696  F0 40    BEQ loc_96D8            
9698  C9 82    CMP #$82                
969A  F0 3C    BEQ loc_96D8            
969C  4C 7F 97 JMP loc_977F            

loc_969F:  ; 1 xrefs: 968E
969F  A5 4A    LDA $4A                 
96A1  29 04    AND #$04                
96A3  F0 33    BEQ loc_96D8            
96A5  20 BD 9F JSR sub_9FBD            
96A8  90 2E    BCC loc_96D8            
96AA  A6 0B    LDX $0B                 
96AC  A9 00    LDA #$00                
96AE  A0 24    LDY #$24                
96B0  20 D5 AC JSR sub_ACD5            
96B3  D0 23    BNE loc_96D8            
96B5  A6 0B    LDX $0B                 
96B7  A9 00    LDA #$00                
96B9  A0 14    LDY #$14                
96BB  20 D5 AC JSR sub_ACD5            
96BE  F0 18    BEQ loc_96D8            
96C0  C9 82    CMP #$82                
96C2  F0 14    BEQ loc_96D8            
96C4  C9 80    CMP #$80                
96C6  D0 08    BNE loc_96D0            
96C8  A9 F0    LDA #$F0                
96CA  20 74 9F JSR sub_9F74            
96CD  4C A4 99 JMP loc_99A4            

loc_96D0:  ; 1 xrefs: 96C6
96D0  A9 F0    LDA #$F0                
96D2  20 C8 9E JSR sub_9EC8            
96D5  4C A8 99 JMP loc_99A8            

loc_96D8:  ; 9 xrefs: 9689 9692 9696 969A 96A3 96A8 96B3 96BE 96C2
96D8  AD 42 04 LDA $0442               
96DB  C9 25    CMP #$25                
96DD  D0 04    BNE loc_96E3            
96DF  A9 02    LDA #$02                
96E1  D0 06    BNE loc_96E9            

loc_96E3:  ; 1 xrefs: 96DD
96E3  C9 27    CMP #$27                
96E5  D0 0B    BNE loc_96F2            
96E7  A9 06    LDA #$06                

loc_96E9:  ; 1 xrefs: 96E1
96E9  8D 84 04 STA $0484               
96EC  4C F2 96 JMP loc_96F2            

loc_96EF:  ; 1 xrefs: 966D
96EF  20 5C B1 JSR sub_B15C            

loc_96F2:  ; 2 xrefs: 96E5 96EC
96F2  A0 29    LDY #$29                
96F4  20 19 AE JSR sub_AE19            
96F7  D0 0B    BNE loc_9704            
96F9  AD 16 04 LDA $0416               
96FC  30 05    BMI loc_9703            
96FE  A5 48    LDA $48                 
9700  0A       ASL A                   
9701  B0 01    BCS loc_9704            

loc_9703:  ; 1 xrefs: 96FC
9703  60       RTS                     

loc_9704:  ; 2 xrefs: 96F7 9701
9704  20 AA B1 JSR sub_B1AA            
9707  04 00    NOP $00                 
9709  A9 00    LDA #$00                
970B  A0 01    LDY #$01                
970D  4C E6 9F JMP loc_9FE6            

; ==== data $9710..$971F  (16 bytes) ====
9710  0A 06 00 00 0A 06 00 00 00 06 06 06 00 06 06 06  |................

sub_9720:  ; 2 xrefs: 968B 974B
9720  A2 00    LDX #$00                
9722  2C 2C 04 BIT $042C               
9725  50 01    BVC loc_9728            
9727  CA       DEX                     

loc_9728:  ; 1 xrefs: 9725
9728  86 0B    STX $0B                 
972A  A9 00    LDA #$00                
972C  A0 10    LDY #$10                
972E  20 D5 AC JSR sub_ACD5            
9731  85 0C    STA $0C                 
9733  AC 15 01 LDY $0115               
9736  84 0E    STY $0E                 
9738  A6 0B    LDX $0B                 
973A  A9 00    LDA #$00                
973C  A0 11    LDY #$11                
973E  20 D5 AC JSR sub_ACD5            
9741  85 0D    STA $0D                 
9743  AC 15 01 LDY $0115               
9746  84 0F    STY $0F                 
9748  09 00    ORA #$00                
974A  60       RTS                     

sub_974B:  ; 2 xrefs: 93AE 9412
974B  20 20 97 JSR sub_9720            
974E  F0 2D    BEQ loc_977D            
9750  C9 81    CMP #$81                
9752  B0 29    BCS loc_977D            
9754  A5 0C    LDA $0C                 
9756  F0 25    BEQ loc_977D            
9758  C9 81    CMP #$81                
975A  B0 21    BCS loc_977D            
975C  A5 0C    LDA $0C                 
975E  A4 0E    LDY $0E                 
9760  C9 80    CMP #$80                
9762  F0 0F    BEQ loc_9773            
9764  A5 0D    LDA $0D                 
9766  A4 0F    LDY $0F                 
9768  C9 80    CMP #$80                
976A  F0 07    BEQ loc_9773            
976C  A9 05    LDA #$05                
976E  20 DF 9E JSR sub_9EDF            
9771  38       SEC                     
9772  60       RTS                     

loc_9773:  ; 2 xrefs: 9762 976A
9773  8C 15 01 STY $0115               
9776  A9 05    LDA #$05                
9778  20 43 9F JSR sub_9F43            
977B  38       SEC                     
977C  60       RTS                     

loc_977D:  ; 4 xrefs: 974E 9752 9756 975A
977D  18       CLC                     
977E  60       RTS                     

loc_977F:  ; 3 xrefs: 941C 969C 9AF2
977F  20 8C 97 JSR sub_978C            

loc_9782:  ; 0 xrefs: 
9782  20 EE B2 JSR sub_B2EE            
9785  A9 20    LDA #$20                
9787  A0 14    LDY #$14                
9789  4C 26 9E JMP sub_9E26            

sub_978C:  ; 2 xrefs: 977F 98A9
978C  A0 03    LDY #$03                
978E  20 17 B0 JSR sub_B017            
9791  A9 2F    LDA #$2F                
9793  8D 42 04 STA $0442               
9796  60       RTS                     

; ==== data $9797..$97D7  (65 bytes) ====
9797  A0 26 20 26 A1 A5 9A C9 01 F0 03 4C DB 9F AD C6  |.& &.......L....
97A7  04 C9 D8 B0 2B 20 20 97 F0 22 A5 0C D0 60 AD C6  |....+  .."...`..
97B7  04 C9 40 90 03 4C 21 99 20 C2 A1 AD 16 04 10 03  |..@..L!. .......
97C7  4C B4 98 A5 4A 29 04 D0 5C 4C A2 98 A5 0C D0 03  |L...J)..\L......
97D7  4C                                               |L

loc_97D8:  ; 0 xrefs: 
97D8  DB 9F 10 DCP $109F,Y             
97DB  11 A2    ORA ($A2),Y             
97DD  00 2C    BRK #$2C                

; ==== data $97DF..$9874  (150 bytes) ====
97DF  2C 04 50 01 CA A9 00 A0 2E 20 D5 AC D0 14 A2 00  |,.P...... ......
97EF  2C 2C 04 50 01 CA A9 00 A0 0F 20 D5 AC D0 03 4C  |,,.P...... ....L
97FF  F2 98 20 C2 A1 AD 16 04 10 03 4C B4 98 A5 4A 29  |.. .......L...J)
980F  08 D0 1E 4C A2 98 20 C2 A1 AD 16 04 10 03 4C B4  |...L.. .......L.
981F  98 A5 4A 29 0C F0 7C A5 4A 29 04 F0 04 A2 01 D0  |..J)..|.J)......
982F  02 A2 FF A9 00 20 2B B2 AD 10 06 30 0A A0 27 20  |..... +....0..' 
983F  2A AE F0 48 4C DB 9F A0 28 20 8D AD D0 09 AD C6  |*..HL...( ......
984F  04 C9 2C B0 37 90 0C C9 01 F0 16 C9 80 F0 0A C9  |..,.7...........
985F  82 D0 13 20 8C 97 4C B4 98 A9 E0 20 8A 9F 4C 75  |... ..L.... ..Lu
986F  98 A9 E0 20 23 9F                                |... #.

loc_9875:  ; 0 xrefs: 
9875  20 23 95 JSR sub_9523            
9878  20 3B 9E JSR sub_9E3B            
987B  A9 25    LDA #$25                
987D  8D 42 04 STA $0442               
9880  A9 10    LDA #$10                
9882  8D 6E 04 STA $046E               
9885  A9 04    LDA #$04                
9887  8D 84 04 STA $0484               
988A  60       RTS                     

; ==== data $988B..$98A1  (23 bytes) ====
988B  20 B7 B1 AD 6E 04 C9 09 90 05 E9 08 8D 6E 04 A0  | ...n........n..
989B  03 20 1F B0 4C B4 98                             |. ..L..

loc_98A2:  ; 0 xrefs: 
98A2  CE 6E 04 DEC $046E               
98A5  F0 02    BEQ loc_98A9            
98A7  10 08    BPL loc_98B1            

loc_98A9:  ; 1 xrefs: 98A5
98A9  20 8C 97 JSR sub_978C            
98AC  A9 02    LDA #$02                
98AE  8D 6E 04 STA $046E               

loc_98B1:  ; 1 xrefs: 98A7
98B1  20 36 A0 JSR sub_A036            

loc_98B4:  ; 0 xrefs: 
98B4  A0 29    LDY #$29                
98B6  20 19 AE JSR sub_AE19            
98B9  F0 03    BEQ loc_98BE            
98BB  4C DB 9F JMP loc_9FDB            

loc_98BE:  ; 1 xrefs: 98B9
98BE  AD 16 04 LDA $0416               
98C1  30 1A    BMI loc_98DD            
98C3  A5 48    LDA $48                 
98C5  0A       ASL A                   
98C6  90 15    BCC loc_98DD            
98C8  A5 4A    LDA $4A                 
98CA  29 03    AND #$03                
98CC  F0 10    BEQ loc_98DE            
98CE  A0 01    LDY #$01                
98D0  2C 2C 04 BIT $042C               
98D3  50 02    BVC loc_98D7            
98D5  A0 02    LDY #$02                

loc_98D7:  ; 1 xrefs: 98D3
98D7  84 00    STY $00                 
98D9  C5 00    CMP $00                 
98DB  D0 01    BNE loc_98DE            

loc_98DD:  ; 2 xrefs: 98C1 98C6
98DD  60       RTS                     

loc_98DE:  ; 2 xrefs: 98CC 98DB
98DE  20 3B 9E JSR sub_9E3B            
98E1  A5 4A    LDA $4A                 
98E3  29 08    AND #$08                
98E5  F0 08    BEQ loc_98EF            
98E7  20 CB 9F JSR sub_9FCB            
98EA  90 03    BCC loc_98EF            
98EC  4C E2 9F JMP loc_9FE2            

loc_98EF:  ; 2 xrefs: 98E5 98EA
98EF  4C DB 9F JMP loc_9FDB            

loc_98F2:  ; 0 xrefs: 
98F2  20 3B 9E JSR sub_9E3B            
98F5  A5 0C    LDA $0C                 
98F7  C9 80    CMP #$80                
98F9  F0 08    BEQ loc_9903            
98FB  A9 FC    LDA #$FC                
98FD  20 FE 9E JSR sub_9EFE            
9900  4C 0D 99 JMP loc_990D            

loc_9903:  ; 1 xrefs: 98F9
9903  A5 0E    LDA $0E                 
9905  8D 15 01 STA $0115               
9908  A9 FC    LDA #$FC                
990A  20 39 9F JSR sub_9F39            

loc_990D:  ; 1 xrefs: 9900
990D  20 AA B1 JSR sub_B1AA            
9910  04 00    NOP $00                 
9912  20 EE B2 JSR sub_B2EE            
9915  A0 05    LDY #$05                
9917  20 17 B0 JSR sub_B017            
991A  A9 40    LDA #$40                
991C  A0 1A    LDY #$1A                
991E  4C 26 9E JMP sub_9E26            

loc_9921:  ; 0 xrefs: 
9921  20 AA B1 JSR sub_B1AA            
9924  EC 00 A5 CPX $A500               
9927  0D C9 80 ORA $80C9               
992A  D0 03    BNE loc_992F            
992C  4C A4 99 JMP loc_99A4            

loc_992F:  ; 1 xrefs: 992A
992F  A9 F0    LDA #$F0                
9931  20 C8 9E JSR sub_9EC8            
9934  4C A8 99 JMP loc_99A8            

; ==== data $9937..$9990  (90 bytes) ====
9937  20 66 A1 A0 04 20 1F B0 90 13 A9 10 8D 6E 04 A9  | f... .......n..
9947  04 8D 84 04 20 3B 9E 20 4B 97 4C 82 97 60 20 66  |.... ;. K.L..` f
9957  A1 A0 05 20 1F B0 90 44 20 3B 9E A0 FA 2C 2C 04  |... ...D ;...,,.
9967  70 02 A0 06 84 00 A9 00 20 8E B1 20 AA B1 F8 00  |p....... .. ....
9977  A0 0C 20 8D AD C9 01 F0 0C C9 80 D0 0D A9 E1 20  |.. ............ 
9987  8A 9F 4C 91 99 A9 E1 20 BE 9E                    |..L.... ..

loc_9991:  ; 0 xrefs: 
9991  20 23 95 JSR sub_9523            
9994  A9 25    LDA #$25                
9996  8D 42 04 STA $0442               
9999  A9 10    LDA #$10                
999B  8D 6E 04 STA $046E               
999E  A9 04    LDA #$04                
99A0  8D 84 04 STA $0484               
99A3  60       RTS                     

loc_99A4:  ; 2 xrefs: 96CD 992C
99A4  A9 1C    LDA #$1C                
99A6  D0 02    BNE loc_99AA            

loc_99A8:  ; 2 xrefs: 96D5 9934
99A8  A9 1B    LDA #$1B                

loc_99AA:  ; 1 xrefs: 99A6
99AA  8D 8C 05 STA $058C               
99AD  A9 3D    LDA #$3D                
99AF  8D 42 04 STA $0442               
99B2  A9 01    LDA #$01                
99B4  8D 16 01 STA $0116               
99B7  A9 0C    LDA #$0C                
99B9  8D 11 01 STA $0111               
99BC  AD 16 04 LDA $0416               
99BF  29 7F    AND #$7F                
99C1  8D 16 04 STA $0416               
99C4  60       RTS                     

; ==== data $99C5..$99FD  (57 bytes) ====
99C5  20 66 A1 A9 01 8D 16 01 CE 11 01 D0 2B A2 00 2C  | f..........+..,
99D5  2C 04 50 01 CA A9 00 A0 12 20 D5 AC F0 06 20 FE  |,.P...... .... .
99E5  99 4C EC 8F 20 FE 99 A9 09 20 44 9E A9 0C 8D 11  |.L.. .... D.....
99F5  01 A9 08 A0 09 4C 26 9E 60                       |.....L&.`

loc_99FE:  ; 0 xrefs: 
99FE  A0 F0    LDY #$F0                
9A00  2C 2C 04 BIT $042C               
9A03  70 02    BVS loc_9A07            
9A05  A0 10    LDY #$10                

loc_9A07:  ; 1 xrefs: 9A03
9A07  84 00    STY $00                 
9A09  A9 00    LDA #$00                
9A0B  20 8E B1 JSR sub_B18E            
9A0E  20 AA B1 JSR sub_B1AA            
9A11  F4 00    NOP $00,X               
9A13  A0 08    LDY #$08                
9A15  20 2A AE JSR sub_AE2A            
9A18  F0 0E    BEQ loc_9A28            
9A1A  C9 01    CMP #$01                
9A1C  F0 07    BEQ loc_9A25            
9A1E  C9 80    CMP #$80                
9A20  D0 06    BNE loc_9A28            
9A22  4C 72 9F JMP sub_9F72            

loc_9A25:  ; 1 xrefs: 9A1C
9A25  4C D2 9E JMP sub_9ED2            

loc_9A28:  ; 2 xrefs: 9A18 9A20
9A28  60       RTS                     

sub_9A29:  ; 4 xrefs: 8F43 90E5 90FA 9131
9A29  20 BD 9F JSR sub_9FBD            
9A2C  90 5D    BCC loc_9A8B            
9A2E  A0 08    LDY #$08                
9A30  20 19 AE JSR sub_AE19            
9A33  D0 5A    BNE loc_9A8F            
9A35  A0 25    LDY #$25                
9A37  20 19 AE JSR sub_AE19            
9A3A  D0 57    BNE loc_9A93            
9A3C  A2 00    LDX #$00                
9A3E  2C 2C 04 BIT $042C               
9A41  70 01    BVS loc_9A44            
9A43  CA       DEX                     

loc_9A44:  ; 1 xrefs: 9A41
9A44  A9 00    LDA #$00                
9A46  A0 13    LDY #$13                
9A48  20 D5 AC JSR sub_ACD5            
9A4B  F0 46    BEQ loc_9A93            
9A4D  C9 01    CMP #$01                
9A4F  F0 04    BEQ loc_9A55            
9A51  C9 80    CMP #$80                
9A53  D0 3E    BNE loc_9A93            

loc_9A55:  ; 1 xrefs: 9A4F
9A55  85 10    STA $10                 
9A57  20 AA B1 JSR sub_B1AA            
9A5A  10 00    BPL loc_9A5C            

loc_9A5C:  ; 1 xrefs: 9A5A
9A5C  20 3B 9E JSR sub_9E3B            
9A5F  A9 05    LDA #$05                
9A61  A4 10    LDY $10                 
9A63  10 06    BPL loc_9A6B            
9A65  20 43 9F JSR sub_9F43            
9A68  4C 6E 9A JMP loc_9A6E            

loc_9A6B:  ; 1 xrefs: 9A63
9A6B  20 DF 9E JSR sub_9EDF            

loc_9A6E:  ; 1 xrefs: 9A68
9A6E  20 EE B2 JSR sub_B2EE            
9A71  A9 3D    LDA #$3D                
9A73  8D 42 04 STA $0442               
9A76  A9 01    LDA #$01                
9A78  8D 16 01 STA $0116               
9A7B  A9 0C    LDA #$0C                
9A7D  8D 11 01 STA $0111               
9A80  A9 20    LDA #$20                
9A82  A0 19    LDY #$19                
9A84  20 26 9E JSR sub_9E26            
9A87  38       SEC                     
9A88  A9 00    LDA #$00                
9A8A  60       RTS                     

loc_9A8B:  ; 1 xrefs: 9A2C
9A8B  18       CLC                     
9A8C  A9 01    LDA #$01                
9A8E  60       RTS                     

loc_9A8F:  ; 1 xrefs: 9A33
9A8F  18       CLC                     
9A90  A9 80    LDA #$80                
9A92  60       RTS                     

loc_9A93:  ; 3 xrefs: 9A3A 9A4B 9A53
9A93  18       CLC                     
9A94  A9 00    LDA #$00                
9A96  60       RTS                     

; ==== data $9A97..$9ABD  (39 bytes) ====
9A97  20 66 A1 A9 01 8D 16 01 A9 05 A0 00 20 35 AC 10  | f.......... 5..
9AA7  08 A9 05 20 F0 9E 4C BE 9A A9 FA A0 00 20 35 AC  |... ..L...... 5.
9AB7  10 05 A9 FA 20 E6 9E                             |.... ..

loc_9ABE:  ; 0 xrefs: 
9ABE  A0 08    LDY #$08                
9AC0  20 19 AE JSR sub_AE19            
9AC3  F0 14    BEQ loc_9AD9            
9AC5  C9 01    CMP #$01                
9AC7  F0 0A    BEQ loc_9AD3            
9AC9  C9 80    CMP #$80                
9ACB  D0 09    BNE loc_9AD6            
9ACD  20 72 9F JSR sub_9F72            
9AD0  4C D6 9A JMP loc_9AD6            

loc_9AD3:  ; 1 xrefs: 9AC7
9AD3  20 D2 9E JSR sub_9ED2            

loc_9AD6:  ; 2 xrefs: 9ACB 9AD0
9AD6  4C B0 8E JMP loc_8EB0            

loc_9AD9:  ; 1 xrefs: 9AC3
9AD9  CE 11 01 DEC $0111               
9ADC  D0 17    BNE loc_9AF5            
9ADE  20 AA B1 JSR sub_B1AA            
9AE1  16 00    ASL $00,X               
9AE3  A0 08    LDY #$08                
9AE5  20 19 AE JSR sub_AE19            
9AE8  F0 08    BEQ loc_9AF2            
9AEA  20 AA B1 JSR sub_B1AA            
9AED  EA       NOP                     
9AEE  00 4C    BRK #$4C                

; ==== data $9AF0..$9AF1  (2 bytes) ====
9AF0  DB 9F                                            |..

loc_9AF2:  ; 1 xrefs: 9AE8
9AF2  4C 7F 97 JMP loc_977F            

loc_9AF5:  ; 1 xrefs: 9ADC
9AF5  60       RTS                     

loc_9AF6:  ; 1 xrefs: 9379
9AF6  A9 00    LDA #$00                
9AF8  8D 11 01 STA $0111               
9AFB  8D 12 01 STA $0112               
9AFE  A0 06    LDY #$06                
9B00  20 17 B0 JSR sub_B017            
9B03  A9 01    LDA #$01                
9B05  A0 0C    LDY #$0C                
9B07  4C 26 9E JMP sub_9E26            

; ==== data $9B0A..$9B26  (29 bytes) ====
9B0A  A0 2B 20 26 A1 A0 17 20 19 AE F0 1A C9 01 F0 0A  |.+ &... ........
9B1A  C9 80 D0 09 20 72 9F 4C 27 9B 20 D2 9E           |.... r.L'. ..

loc_9B27:  ; 0 xrefs: 
9B27  20 FA B2 JSR sub_B2FA            
9B2A  8D DC 04 STA $04DC               
9B2D  4C B0 8E JMP loc_8EB0            

; ==== data $9B30..$9B6F  (64 bytes) ====
9B30  A5 9A C9 03 F0 03 4C DB 9F AD A2 05 F0 03 4C DB  |......L.......L.
9B40  9F AD 16 04 30 4C A5 4A 29 40 F0 06 20 11 A1 4C  |....0L.J)@.. ..L
9B50  70 9B 29 03 F0 1A 4A 90 0D AD 60 05 30 12 A9 BF  |p.)...J...`.0...
9B60  20 2D 9E 4C 70 9B AD 60 05 10 05 A9 40 20 34 9E  | -.Lp..`....@ 4.

loc_9B70:  ; 0 xrefs: 
9B70  A0 06    LDY #$06                
9B72  AD 60 05 LDA $0560               
9B75  F0 18    BEQ loc_9B8F            
9B77  C9 FF    CMP #$FF                
9B79  F0 14    BEQ loc_9B8F            
9B7B  C8       INY                     
9B7C  2C 2C 04 BIT $042C               
9B7F  70 08    BVS loc_9B89            
9B81  AD 60 05 LDA $0560               
9B84  10 09    BPL loc_9B8F            
9B86  C8       INY                     
9B87  D0 06    BNE loc_9B8F            

loc_9B89:  ; 1 xrefs: 9B7F
9B89  AD 60 05 LDA $0560               
9B8C  30 01    BMI loc_9B8F            
9B8E  C8       INY                     

loc_9B8F:  ; 5 xrefs: 9B75 9B79 9B84 9B87 9B8C
9B8F  20 1F B0 JSR sub_B01F            
9B92  20 C2 A1 JSR sub_A1C2            
9B95  EE 12 01 INC $0112               
9B98  AD 12 01 LDA $0112               
9B9B  C9 14    CMP #$14                
9B9D  90 0A    BCC loc_9BA9            
9B9F  A9 00    LDA #$00                
9BA1  8D 12 01 STA $0112               
9BA4  A9 16    LDA #$16                
9BA6  20 1C C8 JSR $C81C               

loc_9BA9:  ; 1 xrefs: 9B9D
9BA9  A5 4A    LDA $4A                 
9BAB  0A       ASL A                   
9BAC  90 08    BCC loc_9BB6            
9BAE  A5 4A    LDA $4A                 
9BB0  4A       LSR A                   
9BB1  B0 17    BCS loc_9BCA            
9BB3  4A       LSR A                   
9BB4  B0 1F    BCS loc_9BD5            

loc_9BB6:  ; 1 xrefs: 9BAC
9BB6  AD 60 05 LDA $0560               
9BB9  30 0B    BMI loc_9BC6            
9BBB  D0 05    BNE loc_9BC2            
9BBD  0D 76 05 ORA $0576               
9BC0  F0 2D    BEQ loc_9BEF            

loc_9BC2:  ; 1 xrefs: 9BBB
9BC2  A0 0B    LDY #$0B                
9BC4  D0 18    BNE loc_9BDE            

loc_9BC6:  ; 1 xrefs: 9BB9
9BC6  A0 0F    LDY #$0F                
9BC8  D0 14    BNE loc_9BDE            

loc_9BCA:  ; 1 xrefs: 9BB1
9BCA  A0 03    LDY #$03                
9BCC  AD 60 05 LDA $0560               
9BCF  10 0D    BPL loc_9BDE            
9BD1  A0 13    LDY #$13                
9BD3  D0 09    BNE loc_9BDE            

loc_9BD5:  ; 1 xrefs: 9BB4
9BD5  A0 07    LDY #$07                
9BD7  AD 60 05 LDA $0560               
9BDA  30 02    BMI loc_9BDE            
9BDC  A0 17    LDY #$17                

loc_9BDE:  ; 5 xrefs: 9BC4 9BC8 9BCF 9BD3 9BDA
9BDE  A2 03    LDX #$03                

loc_9BE0:  ; 1 xrefs: 9BE7
9BE0  B9 A7 9C LDA $9CA7,Y             
9BE3  95 02    STA $02,X               
9BE5  88       DEY                     
9BE6  CA       DEX                     
9BE7  10 F7    BPL loc_9BE0            
9BE9  20 42 B2 JSR sub_B242            
9BEC  20 FA B1 JSR sub_B1FA            

loc_9BEF:  ; 1 xrefs: 9BC0
9BEF  A0 2A    LDY #$2A                
9BF1  20 56 A0 JSR sub_A056            
9BF4  A5 4A    LDA $4A                 
9BF6  0A       ASL A                   
9BF7  B0 0A    BCS loc_9C03            
9BF9  A5 4A    LDA $4A                 
9BFB  29 04    AND #$04                
9BFD  F0 69    BEQ loc_9C68            
9BFF  A0 03    LDY #$03                
9C01  D0 62    BNE loc_9C65            

loc_9C03:  ; 1 xrefs: 9BF7
9C03  30 0C    BMI loc_9C11            
9C05  A5 4A    LDA $4A                 
9C07  29 08    AND #$08                
9C09  D0 43    BNE loc_9C4E            
9C0B  A5 4A    LDA $4A                 
9C0D  29 04    AND #$04                
9C0F  D0 39    BNE loc_9C4A            

loc_9C11:  ; 1 xrefs: 9C03
9C11  AD 34 05 LDA $0534               
9C14  30 19    BMI loc_9C2F            
9C16  F0 04    BEQ loc_9C1C            
9C18  A0 07    LDY #$07                
9C1A  D0 43    BNE loc_9C5F            

loc_9C1C:  ; 1 xrefs: 9C16
9C1C  EE 11 01 INC $0111               
9C1F  AD 11 01 LDA $0111               
9C22  29 0F    AND #$0F                
9C24  C9 08    CMP #$08                
9C26  F0 03    BEQ loc_9C2B            
9C28  4C 6B 9C JMP loc_9C6B            

loc_9C2B:  ; 1 xrefs: 9C26
9C2B  A0 0B    LDY #$0B                
9C2D  D0 30    BNE loc_9C5F            

loc_9C2F:  ; 1 xrefs: 9C14
9C2F  C9 FF    CMP #$FF                
9C31  F0 04    BEQ loc_9C37            
9C33  A0 0F    LDY #$0F                
9C35  D0 28    BNE loc_9C5F            

loc_9C37:  ; 1 xrefs: 9C31
9C37  EE 11 01 INC $0111               
9C3A  AD 11 01 LDA $0111               
9C3D  29 0F    AND #$0F                
9C3F  C9 08    CMP #$08                
9C41  F0 03    BEQ loc_9C46            
9C43  4C 6B 9C JMP loc_9C6B            

loc_9C46:  ; 1 xrefs: 9C41
9C46  A0 13    LDY #$13                
9C48  D0 15    BNE loc_9C5F            

loc_9C4A:  ; 1 xrefs: 9C0F
9C4A  A0 17    LDY #$17                
9C4C  D0 17    BNE loc_9C65            

loc_9C4E:  ; 1 xrefs: 9C09
9C4E  AD 34 05 LDA $0534               
9C51  30 08    BMI loc_9C5B            
9C53  C9 02    CMP #$02                
9C55  90 04    BCC loc_9C5B            
9C57  A0 1B    LDY #$1B                
9C59  D0 0A    BNE loc_9C65            

loc_9C5B:  ; 2 xrefs: 9C51 9C55
9C5B  A0 1F    LDY #$1F                
9C5D  D0 06    BNE loc_9C65            

loc_9C5F:  ; 4 xrefs: 9C1A 9C2D 9C35 9C48
9C5F  20 87 9C JSR sub_9C87            
9C62  4C 6B 9C JMP loc_9C6B            

loc_9C65:  ; 4 xrefs: 9C01 9C4C 9C59 9C5D
9C65  20 87 9C JSR sub_9C87            

loc_9C68:  ; 1 xrefs: 9BFD
9C68  20 95 9C JSR sub_9C95            

loc_9C6B:  ; 3 xrefs: 9C28 9C43 9C62
9C6B  AD 34 05 LDA $0534               
9C6E  30 0E    BMI loc_9C7E            
9C70  C9 05    CMP #$05                
9C72  90 0A    BCC loc_9C7E            
9C74  A9 00    LDA #$00                
9C76  8D 4A 05 STA $054A               
9C79  A9 05    LDA #$05                
9C7B  8D 34 05 STA $0534               

loc_9C7E:  ; 2 xrefs: 9C6E 9C72
9C7E  20 1A B2 JSR sub_B21A            
9C81  A0 15    LDY #$15                
9C83  20 36 A0 JSR sub_A036            
9C86  60       RTS                     

sub_9C87:  ; 2 xrefs: 9C5F 9C65
9C87  A2 03    LDX #$03                

loc_9C89:  ; 1 xrefs: 9C90
9C89  B9 BF 9C LDA $9CBF,Y             
9C8C  95 02    STA $02,X               
9C8E  88       DEY                     
9C8F  CA       DEX                     
9C90  10 F7    BPL loc_9C89            
9C92  4C 9C B2 JMP loc_B29C            

sub_9C95:  ; 1 xrefs: 9C68
9C95  AD 4A 05 LDA $054A               
9C98  18       CLC                     
9C99  69 08    ADC #$08                
9C9B  8D 4A 05 STA $054A               
9C9E  AD 34 05 LDA $0534               
9CA1  69 00    ADC #$00                
9CA3  8D 34 05 STA $0534               
9CA6  60       RTS                     

; ==== data $9CA7..$9CDE  (56 bytes) ====
9CA7  80 02 0C 00 80 FD F4 FF 40 00 F0 FF C0 FF 10 00  |........@.......
9CB7  80 02 40 00 80 FD C0 FF 00 05 30 00 00 FE C0 FF  |..@.......0.....
9CC7  C0 FF 00 FE 00 02 40 00 40 00 00 02 00 05 08 00  |......@.@.......
9CD7  00 FE 00 FF 00 FE E8 FF                          |........

loc_9CDF:  ; 1 xrefs: 92F9
9CDF  A0 0A    LDY #$0A                
9CE1  20 17 B0 JSR sub_B017            
9CE4  A9 01    LDA #$01                
9CE6  A0 0E    LDY #$0E                
9CE8  4C 26 9E JMP sub_9E26            

; ==== data $9CEB..$9D3B  (81 bytes) ====
9CEB  A0 2B 20 26 A1 A5 9A C9 02 F0 03 4C DB 9F 2C A2  |.+ &.......L..,.
9CFB  05 70 03 4C E2 9F 20 C2 A1 AD 16 04 10 08 A0 01  |.p.L.. .........
9D0B  20 6D A0 4C 50 9D A5 4A 4A B0 0B 4A B0 17 A0 01  | m.LP..JJ..J....
9D1B  20 6D A0 4C 44 9D A9 BF 20 2D 9E 20 3A B2 01 80  | m.LD... -. :...
9D2B  00 80 4C 3C 9D A9 40 20 34 9E 20 3A B2 FE 80 FF  |..L<..@ 4. :....
9D3B  80                                               |.

loc_9D3C:  ; 0 xrefs: 
9D3C  20 FA B1 JSR sub_B1FA            
9D3F  A0 2A    LDY #$2A                
9D41  20 56 A0 JSR sub_A056            

loc_9D44:  ; 0 xrefs: 
9D44  A5 4A    LDA $4A                 
9D46  29 08    AND #$08                
9D48  D0 1F    BNE loc_9D69            
9D4A  A5 4A    LDA $4A                 
9D4C  29 04    AND #$04                
9D4E  D0 23    BNE loc_9D73            

loc_9D50:  ; 0 xrefs: 
9D50  AD 34 05 LDA $0534               
9D53  30 0A    BMI loc_9D5F            
9D55  20 94 B2 JSR sub_B294            
9D58  00 00    BRK #$00                

; ==== data $9D5A..$9D5E  (5 bytes) ====
9D5A  FF 80 4C 7A 9D                                   |..Lz.

loc_9D5F:  ; 1 xrefs: 9D53
9D5F  20 94 B2 JSR sub_B294            
9D62  00 00    BRK #$00                

; ==== data $9D64..$9D68  (5 bytes) ====
9D64  00 80 4C 7A 9D                                   |..Lz.

loc_9D69:  ; 1 xrefs: 9D48
9D69  20 94 B2 JSR sub_B294            
9D6C  FD 00 FF SBC $FF00,X             
9D6F  80 4C    NOP #$4C                
9D71  7A       NOP                     
9D72  9D 20 94 STA $9420,X             

; ==== data $9D75..$9D75  (1 bytes) ====
9D75  B2                                               |.
9D76  03 00    SLO ($00,X)             
9D78  00 80    BRK #$80                

loc_9D7A:  ; 0 xrefs: 
9D7A  20 1A B2 JSR sub_B21A            
9D7D  AD 10 06 LDA $0610               
9D80  10 08    BPL loc_9D8A            
9D82  A0 15    LDY #$15                
9D84  20 36 A0 JSR sub_A036            
9D87  4C AE 9D JMP loc_9DAE            

loc_9D8A:  ; 1 xrefs: 9D80
9D8A  A0 08    LDY #$08                
9D8C  20 2A AE JSR sub_AE2A            
9D8F  F0 1A    BEQ loc_9DAB            
9D91  C9 01    CMP #$01                
9D93  F0 0A    BEQ loc_9D9F            
9D95  C9 80    CMP #$80                
9D97  D0 09    BNE loc_9DA2            
9D99  20 72 9F JSR sub_9F72            
9D9C  4C A2 9D JMP loc_9DA2            

loc_9D9F:  ; 1 xrefs: 9D93
9D9F  20 D2 9E JSR sub_9ED2            

loc_9DA2:  ; 2 xrefs: 9D97 9D9C
9DA2  20 FA B2 JSR sub_B2FA            
9DA5  8D DC 04 STA $04DC               
9DA8  4C B0 8E JMP loc_8EB0            

loc_9DAB:  ; 1 xrefs: 9D8F
9DAB  20 B7 B1 JSR sub_B1B7            

loc_9DAE:  ; 1 xrefs: 9D87
9DAE  AD 16 04 LDA $0416               
9DB1  30 0F    BMI loc_9DC2            
9DB3  A0 0A    LDY #$0A                
9DB5  AD 60 05 LDA $0560               
9DB8  F0 05    BEQ loc_9DBF            
9DBA  C9 FF    CMP #$FF                
9DBC  F0 01    BEQ loc_9DBF            
9DBE  88       DEY                     

loc_9DBF:  ; 2 xrefs: 9DB8 9DBC
9DBF  20 36 B0 JSR sub_B036            

loc_9DC2:  ; 1 xrefs: 9DB1
9DC2  60       RTS                     

; ==== data $9DC3..$9E03  (65 bytes) ====
9DC3  AD 4A 05 18 69 32 8D 4A 05 AD 34 05 69 00 C9 05  |.J..i2.J..4.i...
9DD3  90 07 A9 00 8D 4A 05 A9 05 8D 34 05 A0 08 20 2A  |.....J....4... *
9DE3  AE D0 0D AD B0 04 F0 02 10 17 20 1A B2 4C B7 B1  |.......... ..L..
9DF3  C9 01 F0 0A C9 80 D0 09 20 72 9F 4C 04 9E 20 D2  |........ r.L.. .
9E03  9E                                               |.

loc_9E04:  ; 0 xrefs: 
9E04  EE 8C 05 INC $058C               
9E07  A0 17    LDY #$17                
9E09  4C 17 B0 JMP sub_B017            

; ==== data $9E0C..$9E25  (26 bytes) ====
9E0C  A0 17 20 36 B0 90 08 A9 C0 8D 11 01 EE 8C 05 60  |.. 6...........`
9E1C  CE 11 01 D0 04 A9 0A 85 1A 60                    |.........`

sub_9E26:  ; 12 xrefs: 8EBE 8F89 8FF5 945C 94A6 9534 9789 991E 9A84 9B07 ...
9E26  8C 8C 05 STY $058C               

loc_9E29:  ; 0 xrefs: 
9E29  8D 16 04 STA $0416               
9E2C  60       RTS                     

sub_9E2D:  ; 2 xrefs: A0A4 A11C
9E2D  2D 2C 04 AND $042C               
9E30  8D 2C 04 STA $042C               
9E33  60       RTS                     

sub_9E34:  ; 2 xrefs: A0D6 A122
9E34  0D 2C 04 ORA $042C               
9E37  8D 2C 04 STA $042C               
9E3A  60       RTS                     

sub_9E3B:  ; 6 xrefs: 90CD 9173 9878 98DE 98F2 9A5C
9E3B  AD 2C 04 LDA $042C               
9E3E  49 40    EOR #$40                
9E40  8D 2C 04 STA $042C               
9E43  60       RTS                     

sub_9E44:  ; 9 xrefs: 8EB2 8FEE 9281 92C5 92CD 933D 9387 944B 9FEE
9E44  2C 16 04 BIT $0416               
9E47  30 03    BMI loc_9E4C            
9E49  8D 42 04 STA $0442               

loc_9E4C:  ; 1 xrefs: 9E47
9E4C  60       RTS                     

sub_9E4D:  ; 3 xrefs: 92ED 92F3 9373
9E4D  A9 05    LDA #$05                
9E4F  A0 F0    LDY #$F0                
9E51  20 35 AC JSR sub_AC35            
9E54  10 05    BPL loc_9E5B            
9E56  A9 05    LDA #$05                
9E58  4C F0 9E JMP loc_9EF0            

loc_9E5B:  ; 1 xrefs: 9E54
9E5B  A9 FA    LDA #$FA                
9E5D  A0 F0    LDY #$F0                
9E5F  20 35 AC JSR sub_AC35            
9E62  10 05    BPL loc_9E69            
9E64  A9 FA    LDA #$FA                
9E66  4C E6 9E JMP loc_9EE6            

loc_9E69:  ; 1 xrefs: 9E62
9E69  A0 05    LDY #$05                
9E6B  A9 F0    LDA #$F0                
9E6D  20 57 AC JSR sub_AC57            
9E70  90 08    BCC loc_9E7A            
9E72  8C 15 01 STY $0115               
9E75  A9 05    LDA #$05                
9E77  4C 5C 9F JMP loc_9F5C            

loc_9E7A:  ; 1 xrefs: 9E70
9E7A  A0 FA    LDY #$FA                
9E7C  A9 F0    LDA #$F0                
9E7E  20 57 AC JSR sub_AC57            
9E81  90 08    BCC loc_9E8B            
9E83  8C 15 01 STY $0115               
9E86  A9 FA    LDA #$FA                
9E88  4C 4A 9F JMP loc_9F4A            

loc_9E8B:  ; 1 xrefs: 9E81
9E8B  60       RTS                     

sub_9E8C:  ; 2 xrefs: 92F6 9376
9E8C  A9 05    LDA #$05                
9E8E  A0 E4    LDY #$E4                
9E90  20 35 AC JSR sub_AC35            
9E93  30 1C    BMI loc_9EB1            
9E95  A9 FA    LDA #$FA                
9E97  A0 E4    LDY #$E4                
9E99  20 35 AC JSR sub_AC35            
9E9C  30 13    BMI loc_9EB1            
9E9E  A0 05    LDY #$05                
9EA0  A9 E4    LDA #$E4                
9EA2  20 57 AC JSR sub_AC57            
9EA5  B0 0F    BCS loc_9EB6            
9EA7  A0 FA    LDY #$FA                
9EA9  A9 E4    LDA #$E4                
9EAB  20 57 AC JSR sub_AC57            
9EAE  B0 06    BCS loc_9EB6            
9EB0  60       RTS                     

loc_9EB1:  ; 2 xrefs: 9E93 9E9C
9EB1  A9 E4    LDA #$E4                
9EB3  4C 23 9F JMP sub_9F23            

loc_9EB6:  ; 2 xrefs: 9EA5 9EAE
9EB6  8C 15 01 STY $0115               
9EB9  A9 E4    LDA #$E4                
9EBB  4C 8A 9F JMP sub_9F8A            

loc_9EBE:  ; 0 xrefs: 
9EBE  18       CLC                     
9EBF  6D C6 04 ADC $04C6               
9EC2  20 89 AF JSR sub_AF89            
9EC5  4C D8 9E JMP loc_9ED8            

sub_9EC8:  ; 2 xrefs: 96D2 9931
9EC8  18       CLC                     
9EC9  6D C6 04 ADC $04C6               
9ECC  20 81 AF JSR sub_AF81            
9ECF  4C D8 9E JMP loc_9ED8            

sub_9ED2:  ; 4 xrefs: 9431 9A25 9AD3 9D9F
9ED2  AD C6 04 LDA $04C6               
9ED5  20 81 AF JSR sub_AF81            

loc_9ED8:  ; 3 xrefs: 9EC5 9ECF 9F2A
9ED8  84 00    STY $00                 
9EDA  A9 00    LDA #$00                
9EDC  4C DE B1 JMP loc_B1DE            

sub_9EDF:  ; 2 xrefs: 976E 9A6B
9EDF  2C 2C 04 BIT $042C               
9EE2  50 0C    BVC loc_9EF0            
9EE4  49 FF    EOR #$FF                

loc_9EE6:  ; 1 xrefs: 9E66
9EE6  18       CLC                     
9EE7  6D 08 05 ADC $0508               
9EEA  20 99 AF JSR sub_AF99            
9EED  4C F7 9E JMP loc_9EF7            

loc_9EF0:  ; 2 xrefs: 9E58 9EE2
9EF0  18       CLC                     
9EF1  6D 08 05 ADC $0508               
9EF4  20 91 AF JSR sub_AF91            

loc_9EF7:  ; 3 xrefs: 9EED 9F16 9F20
9EF7  84 00    STY $00                 
9EF9  A9 00    LDA #$00                
9EFB  4C 8E B1 JMP sub_B18E            

sub_9EFE:  ; 1 xrefs: 98FD
9EFE  2C 2C 04 BIT $042C               
9F01  70 16    BVS loc_9F19            
9F03  49 FF    EOR #$FF                
9F05  4C 0F 9F JMP loc_9F0F            

sub_9F08:  ; 1 xrefs: 9682
9F08  2C 2C 04 BIT $042C               
9F0B  50 0C    BVC loc_9F19            
9F0D  49 FF    EOR #$FF                

loc_9F0F:  ; 1 xrefs: 9F05
9F0F  18       CLC                     
9F10  6D 08 05 ADC $0508               
9F13  20 A9 AF JSR sub_AFA9            
9F16  4C F7 9E JMP loc_9EF7            

loc_9F19:  ; 2 xrefs: 9F01 9F0B
9F19  18       CLC                     
9F1A  6D 08 05 ADC $0508               
9F1D  20 A1 AF JSR sub_AFA1            
9F20  4C F7 9E JMP loc_9EF7            

sub_9F23:  ; 2 xrefs: 92E5 9EB3
9F23  18       CLC                     
9F24  6D C6 04 ADC $04C6               
9F27  20 B9 AF JSR sub_AFB9            
9F2A  4C D8 9E JMP loc_9ED8            

; ==== data $9F2D..$9F38  (12 bytes) ====
9F2D  A9 00 18 6D C6 04 20 B1 AF 4C D8 9E              |...m.. ..L..

sub_9F39:  ; 1 xrefs: 990A
9F39  2C 2C 04 BIT $042C               
9F3C  70 1E    BVS loc_9F5C            
9F3E  49 FF    EOR #$FF                
9F40  4C 4A 9F JMP loc_9F4A            

sub_9F43:  ; 3 xrefs: 967A 9778 9A65
9F43  2C 2C 04 BIT $042C               
9F46  50 14    BVC loc_9F5C            
9F48  49 FF    EOR #$FF                

loc_9F4A:  ; 2 xrefs: 9E88 9F40
9F4A  18       CLC                     
9F4B  6D 08 05 ADC $0508               
9F4E  85 00    STA $00                 
9F50  AC 15 01 LDY $0115               
9F53  B9 2F 01 LDA $012F,Y             
9F56  38       SEC                     
9F57  E5 00    SBC $00                 
9F59  4C 6B 9F JMP loc_9F6B            

loc_9F5C:  ; 3 xrefs: 9E77 9F3C 9F46
9F5C  18       CLC                     
9F5D  6D 08 05 ADC $0508               
9F60  85 00    STA $00                 
9F62  AC 15 01 LDY $0115               
9F65  B9 1F 01 LDA $011F,Y             
9F68  38       SEC                     
9F69  E5 00    SBC $00                 

loc_9F6B:  ; 1 xrefs: 9F59
9F6B  85 00    STA $00                 
9F6D  A9 00    LDA #$00                
9F6F  4C 8E B1 JMP sub_B18E            

sub_9F72:  ; 4 xrefs: 942B 9A22 9ACD 9D99
9F72  A9 01    LDA #$01                

sub_9F74:  ; 1 xrefs: 96CA
9F74  18       CLC                     
9F75  6D C6 04 ADC $04C6               
9F78  85 00    STA $00                 
9F7A  AC 15 01 LDY $0115               
9F7D  B9 3F 01 LDA $013F,Y             
9F80  38       SEC                     
9F81  E5 00    SBC $00                 

loc_9F83:  ; 1 xrefs: 9F99
9F83  85 00    STA $00                 
9F85  A9 00    LDA #$00                
9F87  4C DE B1 JMP loc_B1DE            

sub_9F8A:  ; 2 xrefs: 92DD 9EBB
9F8A  18       CLC                     
9F8B  6D C6 04 ADC $04C6               
9F8E  85 00    STA $00                 
9F90  AC 15 01 LDY $0115               
9F93  B9 4F 01 LDA $014F,Y             
9F96  38       SEC                     
9F97  E5 00    SBC $00                 
9F99  4C 83 9F JMP loc_9F83            

loc_9F9C:  ; 0 xrefs: 
9F9C  AD 08 05 LDA $0508               
9F9F  A4 97    LDY $97                 
9FA1  D0 03    BNE loc_9FA6            
9FA3  18       CLC                     
9FA4  65 67    ADC $67                 

loc_9FA6:  ; 1 xrefs: 9FA1
9FA6  29 0F    AND #$0F                
9FA8  C9 08    CMP #$08                
9FAA  F0 0F    BEQ loc_9FBB            
9FAC  A0 01    LDY #$01                
9FAE  90 02    BCC loc_9FB2            
9FB0  A0 FF    LDY #$FF                

loc_9FB2:  ; 1 xrefs: 9FAE
9FB2  84 00    STY $00                 
9FB4  A9 00    LDA #$00                
9FB6  20 8E B1 JSR sub_B18E            
9FB9  38       SEC                     
9FBA  60       RTS                     

loc_9FBB:  ; 1 xrefs: 9FAA
9FBB  18       CLC                     
9FBC  60       RTS                     

sub_9FBD:  ; 7 xrefs: 9160 927A 9315 93D5 93E3 96A5 9A29
9FBD  A5 9A    LDA $9A                 
9FBF  C9 01    CMP #$01                
9FC1  D0 06    BNE loc_9FC9            
9FC3  A5 4A    LDA $4A                 
9FC5  0A       ASL A                   
9FC6  90 01    BCC loc_9FC9            
9FC8  60       RTS                     

loc_9FC9:  ; 2 xrefs: 9FC1 9FC6
9FC9  18       CLC                     
9FCA  60       RTS                     

sub_9FCB:  ; 2 xrefs: 8F69 98E7
9FCB  A5 48    LDA $48                 
9FCD  0A       ASL A                   
9FCE  90 09    BCC loc_9FD9            
9FD0  A0 00    LDY #$00                
9FD2  20 8D AD JSR sub_AD8D            
9FD5  D0 02    BNE loc_9FD9            
9FD7  38       SEC                     
9FD8  60       RTS                     

loc_9FD9:  ; 2 xrefs: 9FCE 9FD5
9FD9  18       CLC                     
9FDA  60       RTS                     

loc_9FDB:  ; 6 xrefs: 8F54 912A 913E 94FC 98BB 98EF
9FDB  A9 CE    LDA #$CE                
9FDD  A0 FF    LDY #$FF                
9FDF  4C E6 9F JMP loc_9FE6            

loc_9FE2:  ; 2 xrefs: 8F6E 98EC
9FE2  A9 00    LDA #$00                
9FE4  A0 FB    LDY #$FB                

loc_9FE6:  ; 2 xrefs: 970D 9FDF
9FE6  8D 4A 05 STA $054A               
9FE9  8C 34 05 STY $0534               
9FEC  A9 18    LDA #$18                
9FEE  20 44 9E JSR sub_9E44            
9FF1  A9 00    LDA #$00                
9FF3  8D 11 01 STA $0111               
9FF6  8D 12 01 STA $0112               
9FF9  8D 13 01 STA $0113               
9FFC  A9 01    LDA #$01                
9FFE  A0 08    LDY #$08                
A000  4C 26 9E JMP sub_9E26            

sub_A003:  ; 1 xrefs: 8F77
A003  A0 01    LDY #$01                
A005  A9 03    LDA #$03                
A007  20 35 AC JSR sub_AC35            
A00A  C9 01    CMP #$01                
A00C  D0 26    BNE loc_A034            
A00E  A0 01    LDY #$01                
A010  A9 FC    LDA #$FC                
A012  20 35 AC JSR sub_AC35            
A015  C9 01    CMP #$01                
A017  D0 1B    BNE loc_A034            
A019  20 EE B2 JSR sub_B2EE            
A01C  20 AA B1 JSR sub_B1AA            
A01F  0A       ASL A                   
A020  00 A9    BRK #$A9                

; ==== data $A022..$A033  (18 bytes) ====
A022  08 8D 11 01 A9 1E 8D 42 04 A9 04 A0 11 20 26 9E  |.......B..... &.
A032  38 60                                            |8`

loc_A034:  ; 2 xrefs: A00C A017
A034  18       CLC                     
A035  60       RTS                     

sub_A036:  ; 3 xrefs: 98B1 9C83 9D84
A036  AD 10 06 LDA $0610               
A039  0D FA 05 ORA $05FA               
A03C  F0 15    BEQ loc_A053            
A03E  AD 10 06 LDA $0610               
A041  30 07    BMI loc_A04A            
A043  20 2A AE JSR sub_AE2A            
A046  F0 08    BEQ loc_A050            
A048  D0 09    BNE loc_A053            

loc_A04A:  ; 1 xrefs: A041
A04A  C8       INY                     
A04B  20 9E AD JSR sub_AD9E            
A04E  D0 03    BNE loc_A053            

loc_A050:  ; 1 xrefs: A046
A050  4C B7 B1 JMP sub_B1B7            

loc_A053:  ; 3 xrefs: A03C A048 A04E
A053  4C FA B2 JMP sub_B2FA            

sub_A056:  ; 5 xrefs: 91C7 9BF1 9D41 A08A A10E
A056  AD E4 05 LDA $05E4               
A059  0D CE 05 ORA $05CE               
A05C  F0 08    BEQ loc_A066            
A05E  20 BA AC JSR sub_ACBA            
A061  D0 05    BNE loc_A068            
A063  20 5C B1 JSR sub_B15C            

loc_A066:  ; 1 xrefs: A05C
A066  18       CLC                     
A067  60       RTS                     

loc_A068:  ; 1 xrefs: A061
A068  20 F1 B2 JSR sub_B2F1            
A06B  38       SEC                     
A06C  60       RTS                     

sub_A06D:  ; 2 xrefs: 8F04 A09F
A06D  84 07    STY $07                 
A06F  AD 60 05 LDA $0560               
A072  30 0A    BMI loc_A07E            
A074  20 3A B2 JSR sub_B23A            
A077  00 00    BRK #$00                

; ==== data $A079..$A07A  (2 bytes) ====
A079  FF 80                                            |..

loc_A07B:  ; 0 xrefs: 
A07B  4C 85 A0 JMP loc_A085            

loc_A07E:  ; 1 xrefs: A072
A07E  20 3A B2 JSR sub_B23A            
A081  00 00    BRK #$00                

; ==== data $A083..$A084  (2 bytes) ====
A083  00 80                                            |..

loc_A085:  ; 1 xrefs: A07B
A085  20 FA B1 JSR sub_B1FA            
A088  A4 07    LDY $07                 
A08A  4C 56 A0 JMP sub_A056            

sub_A08D:  ; 1 xrefs: 91CD
A08D  A5 4A    LDA $4A                 
A08F  4A       LSR A                   
A090  B0 10    BCS loc_A0A2            
A092  4A       LSR A                   
A093  B0 3F    BCS loc_A0D4            
A095  A0 01    LDY #$01                
A097  AD 16 04 LDA $0416               
A09A  6A       ROR A                   
A09B  90 02    BCC loc_A09F            
A09D  A0 2A    LDY #$2A                

loc_A09F:  ; 1 xrefs: A09B
A09F  4C 6D A0 JMP sub_A06D            

loc_A0A2:  ; 1 xrefs: A090
A0A2  A9 BF    LDA #$BF                
A0A4  20 2D 9E JSR sub_9E2D            
A0A7  AD 60 05 LDA $0560               
A0AA  F0 1E    BEQ loc_A0CA            
A0AC  30 1C    BMI loc_A0CA            
A0AE  C9 01    CMP #$01                
A0B0  F0 18    BEQ loc_A0CA            
A0B2  C9 04    CMP #$04                
A0B4  90 0A    BCC loc_A0C0            
A0B6  20 3A B2 JSR sub_B23A            
A0B9  01 00    ORA ($00,X)             
A0BB  FF E0 4C ISC $4CE0,X             
A0BE  01 A1    ORA ($A1,X)             

loc_A0C0:  ; 1 xrefs: A0B4
A0C0  20 3A B2 JSR sub_B23A            
A0C3  01 00    ORA ($00,X)             
A0C5  FF FC 4C ISC $4CFC,X             
A0C8  01 A1    ORA ($A1,X)             

loc_A0CA:  ; 3 xrefs: A0AA A0AC A0B0
A0CA  20 3A B2 JSR sub_B23A            
A0CD  01 00    ORA ($00,X)             
A0CF  00 80    BRK #$80                

loc_A0D1:  ; 0 xrefs: 
A0D1  4C 01 A1 JMP loc_A101            

loc_A0D4:  ; 1 xrefs: A093
A0D4  A9 40    LDA #$40                
A0D6  20 34 9E JSR sub_9E34            
A0D9  AD 60 05 LDA $0560               
A0DC  10 1C    BPL loc_A0FA            
A0DE  C9 FF    CMP #$FF                
A0E0  F0 18    BEQ loc_A0FA            
A0E2  C9 FC    CMP #$FC                
A0E4  B0 0A    BCS loc_A0F0            
A0E6  20 3A B2 JSR sub_B23A            
A0E9  FF 00 00 ISC $0000,X             
A0EC  20 4C 01 JSR $014C               
A0EF  A1 20    LDA ($20,X)             
A0F1  3A       NOP                     

; ==== data $A0F2..$A0F2  (1 bytes) ====
A0F2  B2                                               |.
A0F3  FF 00 00 ISC $0000,X             
A0F6  04 4C    NOP $4C                 
A0F8  01 A1    ORA ($A1,X)             

loc_A0FA:  ; 2 xrefs: A0DC A0E0
A0FA  20 3A B2 JSR sub_B23A            
A0FD  FF 00 FF ISC $FF00,X             
A100  80 20    NOP #$20                
A102  FA       NOP                     
A103  B1 A0    LDA ($A0),Y             
A105  01 AD    ORA ($AD,X)             
A107  16 04    ASL $04,X               
A109  6A       ROR A                   
A10A  90 02    BCC loc_A10E            
A10C  A0 2A    LDY #$2A                

loc_A10E:  ; 1 xrefs: A10A
A10E  4C 56 A0 JMP sub_A056            

sub_A111:  ; 1 xrefs: 8FDD
A111  A5 4A    LDA $4A                 
A113  29 03    AND #$03                
A115  F0 0E    BEQ loc_A125            
A117  4A       LSR A                   
A118  90 06    BCC loc_A120            
A11A  A9 BF    LDA #$BF                
A11C  20 2D 9E JSR sub_9E2D            
A11F  60       RTS                     

loc_A120:  ; 1 xrefs: A118
A120  A9 40    LDA #$40                
A122  20 34 9E JSR sub_9E34            

loc_A125:  ; 1 xrefs: A115
A125  60       RTS                     

sub_A126:  ; 1 xrefs: 91B7
A126  84 0B    STY $0B                 
A128  AD 3C 06 LDA $063C               
A12B  F0 13    BEQ loc_A140            
A12D  85 00    STA $00                 
A12F  AA       TAX                     
A130  20 D5 AC JSR sub_ACD5            
A133  F0 04    BEQ loc_A139            
A135  C9 80    CMP #$80                
A137  D0 05    BNE loc_A13E            

loc_A139:  ; 1 xrefs: A133
A139  A9 00    LDA #$00                
A13B  20 8E B1 JSR sub_B18E            

loc_A13E:  ; 1 xrefs: A137
A13E  A4 0B    LDY $0B                 

loc_A140:  ; 1 xrefs: A12B
A140  AD 52 06 LDA $0652               
A143  F0 20    BEQ loc_A165            
A145  85 00    STA $00                 
A147  30 0C    BMI loc_A155            
A149  C8       INY                     
A14A  20 36 AE JSR sub_AE36            
A14D  F0 11    BEQ loc_A160            
A14F  C9 80    CMP #$80                
A151  F0 0D    BEQ loc_A160            
A153  D0 10    BNE loc_A165            

loc_A155:  ; 1 xrefs: A147
A155  C8       INY                     
A156  C8       INY                     
A157  20 AA AD JSR sub_ADAA            
A15A  F0 04    BEQ loc_A160            
A15C  C9 80    CMP #$80                
A15E  D0 05    BNE loc_A165            

loc_A160:  ; 3 xrefs: A14D A151 A15A
A160  A9 00    LDA #$00                
A162  4C DE B1 JMP loc_B1DE            

loc_A165:  ; 3 xrefs: A143 A153 A15E
A165  60       RTS                     

loc_A166:  ; 0 xrefs: 
A166  AD 3C 06 LDA $063C               
A169  85 00    STA $00                 
A16B  A9 00    LDA #$00                
A16D  20 8E B1 JSR sub_B18E            
A170  AD 52 06 LDA $0652               
A173  85 00    STA $00                 
A175  A9 00    LDA #$00                
A177  4C DE B1 JMP loc_B1DE            

sub_A17A:  ; 1 xrefs: 8E23
A17A  AD 9A 04 LDA $049A               
A17D  F0 15    BEQ loc_A194            
A17F  A5 95    LDA $95                 
A181  05 96    ORA $96                 
A183  F0 0F    BEQ loc_A194            
A185  AD B0 04 LDA $04B0               
A188  F0 02    BEQ loc_A18C            
A18A  10 08    BPL loc_A194            

loc_A18C:  ; 1 xrefs: A188
A18C  AD C6 04 LDA $04C6               
A18F  C9 C7    CMP #$C7                
A191  B0 01    BCS loc_A194            

loc_A193:  ; 1 xrefs: A199
A193  60       RTS                     

loc_A194:  ; 4 xrefs: A17D A183 A18A A191
A194  AD 8C 05 LDA $058C               
A197  C9 20    CMP #$20                
A199  B0 F8    BCS loc_A193            
A19B  A9 00    LDA #$00                
A19D  8D 9A 04 STA $049A               
A1A0  8D B8 05 STA $05B8               
A1A3  8D 4A 05 STA $054A               
A1A6  8D 34 05 STA $0534               
A1A9  A9 20    LDA #$20                
A1AB  8D 8C 05 STA $058C               
A1AE  A9 16    LDA #$16                
A1B0  8D 42 04 STA $0442               
A1B3  AD 2C 04 LDA $042C               
A1B6  29 7F    AND #$7F                
A1B8  8D 2C 04 STA $042C               
A1BB  A9 08    LDA #$08                
A1BD  85 1A    STA $1A                 
A1BF  4C 22 C8 JMP $C822               

sub_A1C2:  ; 2 xrefs: 91BA 9B92
A1C2  AD 16 04 LDA $0416               
A1C5  10 31    BPL loc_A1F8            
A1C7  AC 58 04 LDY $0458               
A1CA  B9 EE A4 LDA $A4EE,Y             
A1CD  A8       TAY                     
A1CE  2C A2 05 BIT $05A2               
A1D1  30 08    BMI loc_A1DB            
A1D3  50 0C    BVC loc_A1E1            
A1D5  A5 9A    LDA $9A                 
A1D7  C9 02    CMP #$02                
A1D9  D0 06    BNE loc_A1E1            

loc_A1DB:  ; 1 xrefs: A1D1
A1DB  20 36 B0 JSR sub_B036            
A1DE  B0 07    BCS loc_A1E7            
A1E0  60       RTS                     

loc_A1E1:  ; 2 xrefs: A1D3 A1D9
A1E1  20 1F B0 JSR sub_B01F            
A1E4  B0 01    BCS loc_A1E7            
A1E6  60       RTS                     

loc_A1E7:  ; 2 xrefs: A1DE A1E4
A1E7  AD 16 04 LDA $0416               
A1EA  29 7F    AND #$7F                
A1EC  8D 16 04 STA $0416               
A1EF  A9 01    LDA #$01                
A1F1  8D 6E 04 STA $046E               
A1F4  8D 84 04 STA $0484               
A1F7  60       RTS                     

loc_A1F8:  ; 1 xrefs: A1C5
A1F8  A5 48    LDA $48                 
A1FA  29 40    AND #$40                
A1FC  F0 27    BEQ loc_A225            
A1FE  20 D9 A3 JSR sub_A3D9            
A201  B0 22    BCS loc_A225            
A203  86 25    STX $25                 
A205  20 03 A4 JSR sub_A403            
A208  98       TYA                     
A209  30 1A    BMI loc_A225            
A20B  8C 58 04 STY $0458               
A20E  B9 EE A4 LDA $A4EE,Y             
A211  A8       TAY                     
A212  20 17 B0 JSR sub_B017            
A215  AD 16 04 LDA $0416               
A218  09 80    ORA #$80                
A21A  8D 16 04 STA $0416               
A21D  A9 00    LDA #$00                
A21F  8D 00 04 STA $0400               
A222  4C 26 A2 JMP loc_A226            

loc_A225:  ; 3 xrefs: A1FC A201 A209
A225  60       RTS                     

loc_A226:  ; 1 xrefs: A222
A226  8A       TXA                     
A227  A6 25    LDX $25                 
A229  9D CE 05 STA $05CE,X             
A22C  AD 2C 04 LDA $042C               
A22F  29 60    AND #$60                
A231  9D 2C 04 STA $042C,X             
A234  A8       TAY                     
A235  AD 16 04 LDA $0416               
A238  29 20    AND #$20                
A23A  F0 06    BEQ loc_A242            
A23C  98       TYA                     
A23D  49 40    EOR #$40                
A23F  9D 2C 04 STA $042C,X             

loc_A242:  ; 1 xrefs: A23A
A242  20 FD A4 JSR sub_A4FD            
A245  A0 00    LDY #$00                
A247  A5 54    LDA $54                 
A249  C5 8D    CMP $8D                 
A24B  90 0B    BCC loc_A258            
A24D  C8       INY                     
A24E  C5 8E    CMP $8E                 
A250  90 06    BCC loc_A258            
A252  C8       INY                     
A253  C5 8F    CMP $8F                 
A255  90 01    BCC loc_A258            
A257  C8       INY                     

loc_A258:  ; 3 xrefs: A24B A250 A255
A258  84 08    STY $08                 
A25A  A9 00    LDA #$00                
A25C  85 54    STA $54                 
A25E  AD 58 04 LDA $0458               
A261  C9 01    CMP #$01                
A263  D0 2C    BNE loc_A291            
A265  BC CE 05 LDY $05CE,X             
A268  C0 06    CPY #$06                
A26A  90 25    BCC loc_A291            
A26C  A9 06    LDA #$06                
A26E  C0 06    CPY #$06                
A270  F0 02    BEQ loc_A274            
A272  A9 FA    LDA #$FA                

loc_A274:  ; 1 xrefs: A270
A274  85 00    STA $00                 
A276  A0 0C    LDY #$0C                
A278  20 88 C8 JSR $C888               
A27B  30 0B    BMI loc_A288            
A27D  A4 00    LDY $00                 
A27F  A9 0C    LDA #$0C                
A281  20 57 AC JSR sub_AC57            
A284  A6 25    LDX $25                 
A286  90 09    BCC loc_A291            

loc_A288:  ; 1 xrefs: A27B
A288  BD CE 05 LDA $05CE,X             
A28B  38       SEC                     
A28C  E9 06    SBC #$06                
A28E  9D CE 05 STA $05CE,X             

loc_A291:  ; 3 xrefs: A263 A26A A286
A291  A5 9A    LDA $9A                 
A293  F0 03    BEQ loc_A298            
A295  4C 7F A3 JMP loc_A37F            

loc_A298:  ; 1 xrefs: A293
A298  A4 A2    LDY $A2                 
A29A  F0 08    BEQ loc_A2A4            
A29C  BD 2C 04 LDA $042C,X             
A29F  09 02    ORA #$02                
A2A1  9D 2C 04 STA $042C,X             

loc_A2A4:  ; 1 xrefs: A29A
A2A4  C8       INY                     
A2A5  98       TYA                     
A2A6  9D 00 04 STA $0400,X             
A2A9  A9 08    LDA #$08                
A2AB  20 3A C8 JSR $C83A               
A2AE  BD 00 04 LDA $0400,X             
A2B1  0A       ASL A                   
A2B2  0A       ASL A                   
A2B3  0A       ASL A                   
A2B4  85 00    STA $00                 
A2B6  A5 55    LDA $55                 
A2B8  0A       ASL A                   
A2B9  18       CLC                     
A2BA  65 00    ADC $00                 
A2BC  A8       TAY                     
A2BD  B9 4D A8 LDA $A84D,Y             
A2C0  85 00    STA $00                 
A2C2  B9 4E A8 LDA $A84E,Y             
A2C5  85 01    STA $01                 
A2C7  A5 08    LDA $08                 
A2C9  0A       ASL A                   
A2CA  A8       TAY                     
A2CB  B1 00    LDA ($00),Y             
A2CD  85 11    STA $11                 
A2CF  C8       INY                     
A2D0  B1 00    LDA ($00),Y             
A2D2  85 10    STA $10                 
A2D4  A9 00    LDA #$00                
A2D6  38       SEC                     
A2D7  E5 11    SBC $11                 
A2D9  85 13    STA $13                 
A2DB  A9 00    LDA #$00                
A2DD  E5 10    SBC $10                 
A2DF  85 12    STA $12                 
A2E1  BD CE 05 LDA $05CE,X             
A2E4  C9 02    CMP #$02                
A2E6  F0 15    BEQ loc_A2FD            
A2E8  C9 03    CMP #$03                
A2EA  F0 11    BEQ loc_A2FD            
A2EC  4A       LSR A                   
A2ED  90 07    BCC loc_A2F6            
A2EF  A5 12    LDA $12                 
A2F1  A4 13    LDY $13                 
A2F3  4C 00 A3 JMP loc_A300            

loc_A2F6:  ; 1 xrefs: A2ED
A2F6  A5 10    LDA $10                 
A2F8  A4 11    LDY $11                 
A2FA  4C 00 A3 JMP loc_A300            

loc_A2FD:  ; 2 xrefs: A2E6 A2EA
A2FD  A9 00    LDA #$00                
A2FF  A8       TAY                     

loc_A300:  ; 2 xrefs: A2F3 A2FA
A300  9D 60 05 STA $0560,X             
A303  98       TYA                     
A304  9D 76 05 STA $0576,X             
A307  BD CE 05 LDA $05CE,X             
A30A  C9 02    CMP #$02                
A30C  90 16    BCC loc_A324            
A30E  C9 06    CMP #$06                
A310  B0 0B    BCS loc_A31D            
A312  C9 03    CMP #$03                
A314  F0 07    BEQ loc_A31D            
A316  A5 12    LDA $12                 
A318  A4 13    LDY $13                 
A31A  4C 27 A3 JMP loc_A327            

loc_A31D:  ; 2 xrefs: A310 A314
A31D  A5 10    LDA $10                 
A31F  A4 11    LDY $11                 
A321  4C 27 A3 JMP loc_A327            

loc_A324:  ; 1 xrefs: A30C
A324  A9 00    LDA #$00                
A326  A8       TAY                     

loc_A327:  ; 2 xrefs: A31A A321
A327  9D 34 05 STA $0534,X             
A32A  98       TYA                     
A32B  9D 4A 05 STA $054A,X             
A32E  20 58 A3 JSR sub_A358            
A331  BD CE 05 LDA $05CE,X             
A334  C9 02    CMP #$02                
A336  F0 06    BEQ loc_A33E            

loc_A338:  ; 3 xrefs: A341 A34A A355
A338  A9 1A    LDA #$1A                
A33A  20 1C C8 JSR $C81C               
A33D  60       RTS                     

loc_A33E:  ; 1 xrefs: A336
A33E  2C A2 05 BIT $05A2               
A341  70 F5    BVS loc_A338            
A343  A0 E3    LDY #$E3                
A345  A9 00    LDA #$00                
A347  20 88 C8 JSR $C888               
A34A  10 EC    BPL loc_A338            
A34C  AD C6 04 LDA $04C6               
A34F  18       CLC                     
A350  69 E3    ADC #$E3                
A352  9D C6 04 STA $04C6,X             
A355  4C 38 A3 JMP loc_A338            

sub_A358:  ; 2 xrefs: A32E A3AA
A358  2C A2 05 BIT $05A2               
A35B  50 21    BVC loc_A37E            
A35D  A5 9A    LDA $9A                 
A35F  C9 02    CMP #$02                
A361  F0 1B    BEQ loc_A37E            
A363  A9 01    LDA #$01                
A365  9D FA 05 STA $05FA,X             
A368  BD 34 05 LDA $0534,X             
A36B  C9 80    CMP #$80                
A36D  7E 34 05 ROR $0534,X             
A370  7E 4A 05 ROR $054A,X             
A373  BD 60 05 LDA $0560,X             
A376  C9 80    CMP #$80                
A378  7E 60 05 ROR $0560,X             
A37B  7E 76 05 ROR $0576,X             

loc_A37E:  ; 2 xrefs: A35B A361
A37E  60       RTS                     

loc_A37F:  ; 1 xrefs: A295
A37F  A9 03    LDA #$03                
A381  9D 00 04 STA $0400,X             
A384  A9 00    LDA #$00                
A386  9D E4 05 STA $05E4,X             
A389  BC CE 05 LDY $05CE,X             
A38C  B9 E5 A8 LDA $A8E5,Y             
A38F  9D 42 04 STA $0442,X             
A392  B9 05 A9 LDA $A905,Y             
A395  9D 76 05 STA $0576,X             
A398  B9 0D A9 LDA $A90D,Y             
A39B  9D 60 05 STA $0560,X             
A39E  B9 15 A9 LDA $A915,Y             
A3A1  9D 4A 05 STA $054A,X             
A3A4  B9 1D A9 LDA $A91D,Y             
A3A7  9D 34 05 STA $0534,X             
A3AA  20 58 A3 JSR sub_A358            
A3AD  A5 55    LDA $55                 
A3AF  0A       ASL A                   
A3B0  A8       TAY                     
A3B1  B9 ED A8 LDA $A8ED,Y             
A3B4  85 00    STA $00                 
A3B6  B9 EE A8 LDA $A8EE,Y             
A3B9  85 01    STA $01                 
A3BB  A4 08    LDY $08                 
A3BD  B1 00    LDA ($00),Y             
A3BF  9D A2 05 STA $05A2,X             
A3C2  2C A2 05 BIT $05A2               
A3C5  50 0C    BVC loc_A3D3            
A3C7  A5 9A    LDA $9A                 
A3C9  C9 02    CMP #$02                
A3CB  F0 06    BEQ loc_A3D3            
A3CD  DE A2 05 DEC $05A2,X             
A3D0  DE A2 05 DEC $05A2,X             

loc_A3D3:  ; 2 xrefs: A3C5 A3CB
A3D3  A9 22    LDA #$22                
A3D5  20 1C C8 JSR $C81C               
A3D8  60       RTS                     

sub_A3D9:  ; 1 xrefs: A1FE
A3D9  A4 99    LDY $99                 
A3DB  C8       INY                     
A3DC  84 10    STY $10                 
A3DE  A0 00    LDY #$00                
A3E0  AD 01 04 LDA $0401               
A3E3  F0 01    BEQ loc_A3E6            
A3E5  C8       INY                     

loc_A3E6:  ; 1 xrefs: A3E3
A3E6  AD 02 04 LDA $0402               
A3E9  F0 01    BEQ loc_A3EC            
A3EB  C8       INY                     

loc_A3EC:  ; 1 xrefs: A3E9
A3EC  AD 03 04 LDA $0403               
A3EF  F0 01    BEQ loc_A3F2            
A3F1  C8       INY                     

loc_A3F2:  ; 1 xrefs: A3EF
A3F2  C4 10    CPY $10                 
A3F4  B0 0C    BCS loc_A402            
A3F6  A2 01    LDX #$01                

loc_A3F8:  ; 1 xrefs: A3FE
A3F8  BD 00 04 LDA $0400,X             
A3FB  F0 03    BEQ loc_A400            
A3FD  E8       INX                     
A3FE  D0 F8    BNE loc_A3F8            

loc_A400:  ; 1 xrefs: A3FB
A400  18       CLC                     
A401  60       RTS                     

loc_A402:  ; 1 xrefs: A3F4
A402  60       RTS                     

sub_A403:  ; 1 xrefs: A205
A403  AD 16 04 LDA $0416               
A406  4A       LSR A                   
A407  B0 3F    BCS loc_A448            
A409  4A       LSR A                   
A40A  B0 15    BCS loc_A421            
A40C  4A       LSR A                   
A40D  B0 59    BCS loc_A468            
A40F  4A       LSR A                   
A410  B0 5A    BCS loc_A46C            
A412  4A       LSR A                   
A413  90 03    BCC loc_A418            
A415  4C EB A4 JMP loc_A4EB            

loc_A418:  ; 1 xrefs: A413
A418  4A       LSR A                   
A419  B0 5B    BCS loc_A476            
A41B  4A       LSR A                   
A41C  90 03    BCC loc_A421            
A41E  4C D0 A4 JMP loc_A4D0            

loc_A421:  ; 2 xrefs: A40A A41C
A421  A5 4A    LDA $4A                 
A423  29 08    AND #$08                
A425  F0 16    BEQ loc_A43D            

loc_A427:  ; 1 xrefs: A450
A427  A5 4A    LDA $4A                 
A429  29 03    AND #$03                
A42B  F0 0B    BEQ loc_A438            
A42D  A0 05    LDY #$05                
A42F  A2 04    LDX #$04                
A431  2C 2C 04 BIT $042C               
A434  50 01    BVC loc_A437            
A436  E8       INX                     

loc_A437:  ; 1 xrefs: A434
A437  60       RTS                     

loc_A438:  ; 1 xrefs: A42B
A438  A0 03    LDY #$03                
A43A  A2 02    LDX #$02                
A43C  60       RTS                     

loc_A43D:  ; 2 xrefs: A425 A44C
A43D  A0 00    LDY #$00                

loc_A43F:  ; 3 xrefs: A46A A474 A4E8
A43F  A2 00    LDX #$00                
A441  2C 2C 04 BIT $042C               
A444  50 01    BVC loc_A447            
A446  E8       INX                     

loc_A447:  ; 1 xrefs: A444
A447  60       RTS                     

loc_A448:  ; 1 xrefs: A407
A448  A5 4A    LDA $4A                 
A44A  29 0C    AND #$0C                
A44C  F0 EF    BEQ loc_A43D            
A44E  29 08    AND #$08                
A450  D0 D5    BNE loc_A427            
A452  A5 4A    LDA $4A                 
A454  29 03    AND #$03                
A456  D0 05    BNE loc_A45D            

loc_A458:  ; 0 xrefs: 
A458  A0 04    LDY #$04                
A45A  A2 03    LDX #$03                
A45C  60       RTS                     

loc_A45D:  ; 1 xrefs: A456
A45D  A0 06    LDY #$06                

loc_A45F:  ; 2 xrefs: A472 A4E3
A45F  A2 06    LDX #$06                
A461  2C 2C 04 BIT $042C               
A464  50 01    BVC loc_A467            
A466  E8       INX                     

loc_A467:  ; 1 xrefs: A464
A467  60       RTS                     

loc_A468:  ; 1 xrefs: A40D
A468  A0 02    LDY #$02                
A46A  D0 D3    BNE loc_A43F            

loc_A46C:  ; 1 xrefs: A410
A46C  A0 01    LDY #$01                
A46E  A5 4A    LDA $4A                 
A470  29 03    AND #$03                
A472  D0 EB    BNE loc_A45F            
A474  F0 C9    BEQ loc_A43F            

loc_A476:  ; 1 xrefs: A419
A476  A5 4A    LDA $4A                 
A478  29 0C    AND #$0C                
A47A  F0 48    BEQ loc_A4C4            
A47C  29 04    AND #$04                
A47E  D0 22    BNE loc_A4A2            
A480  A5 4A    LDA $4A                 
A482  29 03    AND #$03                
A484  F0 17    BEQ loc_A49D            
A486  4A       LSR A                   
A487  B0 0A    BCS loc_A493            
A489  2C 2C 04 BIT $042C               
A48C  70 0F    BVS loc_A49D            
A48E  A0 0D    LDY #$0D                
A490  A2 05    LDX #$05                
A492  60       RTS                     

loc_A493:  ; 1 xrefs: A487
A493  2C 2C 04 BIT $042C               
A496  50 05    BVC loc_A49D            
A498  A0 0D    LDY #$0D                
A49A  A2 04    LDX #$04                
A49C  60       RTS                     

loc_A49D:  ; 3 xrefs: A484 A48C A496
A49D  A0 0A    LDY #$0A                
A49F  A2 02    LDX #$02                
A4A1  60       RTS                     

loc_A4A2:  ; 1 xrefs: A47E
A4A2  A5 4A    LDA $4A                 
A4A4  29 03    AND #$03                
A4A6  F0 17    BEQ loc_A4BF            
A4A8  4A       LSR A                   
A4A9  B0 0A    BCS loc_A4B5            
A4AB  2C 2C 04 BIT $042C               
A4AE  70 0F    BVS loc_A4BF            
A4B0  A0 0E    LDY #$0E                
A4B2  A2 07    LDX #$07                
A4B4  60       RTS                     

loc_A4B5:  ; 1 xrefs: A4A9
A4B5  2C 2C 04 BIT $042C               
A4B8  50 05    BVC loc_A4BF            
A4BA  A0 0E    LDY #$0E                
A4BC  A2 06    LDX #$06                
A4BE  60       RTS                     

loc_A4BF:  ; 3 xrefs: A4A6 A4AE A4B8
A4BF  A0 0B    LDY #$0B                
A4C1  A2 03    LDX #$03                
A4C3  60       RTS                     

loc_A4C4:  ; 1 xrefs: A47A
A4C4  A0 09    LDY #$09                
A4C6  A2 00    LDX #$00                
A4C8  2C 2C 04 BIT $042C               
A4CB  70 02    BVS loc_A4CF            
A4CD  A2 01    LDX #$01                

loc_A4CF:  ; 1 xrefs: A4CB
A4CF  60       RTS                     

loc_A4D0:  ; 1 xrefs: A41E
A4D0  A5 4A    LDA $4A                 
A4D2  29 04    AND #$04                
A4D4  F0 10    BEQ loc_A4E6            
A4D6  A5 4A    LDA $4A                 
A4D8  29 03    AND #$03                
A4DA  D0 05    BNE loc_A4E1            
A4DC  A0 08    LDY #$08                
A4DE  A2 03    LDX #$03                
A4E0  60       RTS                     

loc_A4E1:  ; 1 xrefs: A4DA
A4E1  A0 0C    LDY #$0C                
A4E3  4C 5F A4 JMP loc_A45F            

loc_A4E6:  ; 1 xrefs: A4D4
A4E6  A0 07    LDY #$07                
A4E8  4C 3F A4 JMP loc_A43F            

loc_A4EB:  ; 1 xrefs: A415
A4EB  A0 FF    LDY #$FF                
A4ED  60       RTS                     

; ==== data $A4EE..$A4FC  (15 bytes) ====
A4EE  0B 0C 0D 0E 0F 10 11 12 13 14 15 16 12 14 14     |...............

sub_A4FD:  ; 1 xrefs: A242
A4FD  AC 58 04 LDY $0458               
A500  A9 00    LDA #$00                
A502  85 00    STA $00                 
A504  B9 45 A5 LDA $A545,Y             
A507  10 02    BPL loc_A50B            
A509  C6 00    DEC $00                 

loc_A50B:  ; 1 xrefs: A507
A50B  18       CLC                     
A50C  6D C6 04 ADC $04C6               
A50F  9D C6 04 STA $04C6,X             
A512  A5 00    LDA $00                 
A514  6D B0 04 ADC $04B0               
A517  9D B0 04 STA $04B0,X             
A51A  BD 2C 04 LDA $042C,X             
A51D  85 01    STA $01                 
A51F  A9 00    LDA #$00                
A521  85 00    STA $00                 
A523  B9 54 A5 LDA $A554,Y             
A526  24 01    BIT $01                 
A528  50 05    BVC loc_A52F            
A52A  49 FF    EOR #$FF                
A52C  18       CLC                     
A52D  69 01    ADC #$01                

loc_A52F:  ; 1 xrefs: A528
A52F  09 00    ORA #$00                
A531  10 02    BPL loc_A535            
A533  C6 00    DEC $00                 

loc_A535:  ; 1 xrefs: A531
A535  18       CLC                     
A536  6D 08 05 ADC $0508               
A539  9D 08 05 STA $0508,X             
A53C  A5 00    LDA $00                 
A53E  6D F2 04 ADC $04F2               
A541  9D F2 04 STA $04F2,X             
A544  60       RTS                     

; ==== data $A545..$A55F  (27 bytes) ====
A545  F0 F8 F0 DA 06 E8 F8 F0 00 F0 DA 06 F8 E8 F8 08  |................
A555  08 08 00 00 08 08 08 F8 08 00 00                 |...........

loc_A560:  ; 0 xrefs: 
A560  08       PHP                     
A561  08       PHP                     
A562  08       PHP                     

sub_A563:  ; 1 xrefs: 8E26
A563  A2 01    LDX #$01                

loc_A565:  ; 1 xrefs: A570
A565  BD 00 04 LDA $0400,X             
A568  F0 03    BEQ loc_A56D            
A56A  20 73 A5 JSR sub_A573            

loc_A56D:  ; 1 xrefs: A568
A56D  E8       INX                     
A56E  E0 06    CPX #$06                
A570  D0 F3    BNE loc_A565            
A572  60       RTS                     

sub_A573:  ; 1 xrefs: A56A
A573  C9 03    CMP #$03                
A575  D0 03    BNE loc_A57A            
A577  4C FB A7 JMP loc_A7FB            

loc_A57A:  ; 1 xrefs: A575
A57A  20 37 C8 JSR $C837               
A57D  EE 00 04 INC $0400               
A580  AD 00 04 LDA $0400               
A583  C9 0A    CMP #$0A                
A585  D0 0A    BNE loc_A591            
A587  A9 00    LDA #$00                
A589  8D 00 04 STA $0400               
A58C  A9 1A    LDA #$1A                
A58E  20 1C C8 JSR $C81C               

loc_A591:  ; 1 xrefs: A585
A591  A9 00    LDA #$00                
A593  A8       TAY                     
A594  20 88 C8 JSR $C888               
A597  10 03    BPL loc_A59C            
A599  4C 10 C8 JMP $C810               

loc_A59C:  ; 1 xrefs: A597
A59C  20 B9 A7 JSR sub_A7B9            
A59F  BD 00 04 LDA $0400,X             
A5A2  0A       ASL A                   
A5A3  0A       ASL A                   
A5A4  0A       ASL A                   
A5A5  85 00    STA $00                 
A5A7  BD CE 05 LDA $05CE,X             
A5AA  10 06    BPL loc_A5B2            
A5AC  A0 10    LDY #$10                
A5AE  84 00    STY $00                 
A5B0  29 7F    AND #$7F                

loc_A5B2:  ; 1 xrefs: A5AA
A5B2  18       CLC                     
A5B3  65 00    ADC $00                 
A5B5  A8       TAY                     
A5B6  B9 BD A8 LDA $A8BD,Y             
A5B9  85 00    STA $00                 
A5BB  B9 CD A8 LDA $A8CD,Y             
A5BE  85 01    STA $01                 
A5C0  B9 9D A8 LDA $A89D,Y             
A5C3  85 02    STA $02                 
A5C5  B9 AD A8 LDA $A8AD,Y             
A5C8  85 03    STA $03                 
A5CA  BD FA 05 LDA $05FA,X             
A5CD  F0 10    BEQ loc_A5DF            
A5CF  A5 01    LDA $01                 
A5D1  C9 80    CMP #$80                
A5D3  66 01    ROR $01                 
A5D5  66 00    ROR $00                 
A5D7  A5 03    LDA $03                 
A5D9  C9 80    CMP #$80                
A5DB  66 03    ROR $03                 
A5DD  66 02    ROR $02                 

loc_A5DF:  ; 1 xrefs: A5CD
A5DF  BD 76 05 LDA $0576,X             
A5E2  18       CLC                     
A5E3  65 00    ADC $00                 
A5E5  9D 76 05 STA $0576,X             
A5E8  BD 60 05 LDA $0560,X             
A5EB  65 01    ADC $01                 
A5ED  9D 60 05 STA $0560,X             
A5F0  BD 4A 05 LDA $054A,X             
A5F3  18       CLC                     
A5F4  65 02    ADC $02                 
A5F6  9D 4A 05 STA $054A,X             
A5F9  BD 34 05 LDA $0534,X             
A5FC  65 03    ADC $03                 
A5FE  9D 34 05 STA $0534,X             
A601  BD CE 05 LDA $05CE,X             
A604  29 7F    AND #$7F                
A606  20 4F C8 JSR $C84F               
A609  19 A6 46 ORA $46A6,Y             
A60C  A6 91    LDX $91                 
A60E  A6 71    LDX $71                 
A610  A6 9A    LDX $9A                 
A612  A6 B0    LDX $B0                 
A614  A6 C4    LDX $C4                 
A616  A6 D9    LDX $D9                 
A618  A6 BD    LDX $BD                 
A61A  CE 05 30 DEC $3005               
A61D  05 BD    ORA $BD                 
A61F  60       RTS                     

; ==== data $A620..$A6EB  (204 bytes) ====
A620  05 10 22 20 64 A7 BD CE 05 30 05 BD 60 05 10 15  |.." d....0..`...
A630  20 01 A7 BD 60 05 10 0D A5 02 F0 09 30 07 A0 81  | ...`.......0...
A640  A9 FC 4C EC A6 60 BD CE 05 30 05 BD 60 05 30 20  |..L..`...0..`.0 
A650  20 64 A7 BD CE 05 30 05 BD 60 05 30 13 20 01 A7  | d....0..`.0. ..
A660  BD 60 05 30 0B A5 02 10 07 A0 80 A9 04 4C EC A6  |.`.0.........L..
A670  60 AD 16 04 29 01 F0 19 AD 34 05 30 14 A8 AD 4A  |`...)....4.0...J
A680  05 18 7D DC 04 9D DC 04 98 7D C6 04 9D C6 04 B0  |..}......}......
A690  06 20 64 A7 4C 4D A7 4C 10 C8 BD 60 05 10 10 20  |. d.LM.L...`... 
A6A0  64 A7 A5 02 F0 09 30 07 A0 81 A9 FC 4C EC A6 60  |d.....0.....L..`
A6B0  BD 60 05 30 0E 20 64 A7 A5 02 10 07 A0 80 A9 04  |.`.0. d.........
A6C0  4C EC A6 60 BD 60 05 10 0F 20 64 A7 A5 02 F0 08  |L..`.`... d.....
A6D0  30 06 A0 81 A9 FC D0 14 60 BD 60 05 30 0D 20 64  |0.......`.`.0. d
A6E0  A7 A5 02 10 06 A0 80 A9 04 D0 01 60              |...........`

loc_A6EC:  ; 0 xrefs: 
A6EC  9D 60 05 STA $0560,X             
A6EF  98       TYA                     
A6F0  9D CE 05 STA $05CE,X             
A6F3  A9 00    LDA #$00                
A6F5  9D 34 05 STA $0534,X             
A6F8  A9 80    LDA #$80                
A6FA  9D 76 05 STA $0576,X             
A6FD  9D 4A 05 STA $054A,X             
A700  60       RTS                     

loc_A701:  ; 0 xrefs: 
A701  A0 00    LDY #$00                
A703  A5 01    LDA $01                 
A705  10 01    BPL loc_A708            
A707  88       DEY                     

loc_A708:  ; 1 xrefs: A705
A708  18       CLC                     
A709  7D C6 04 ADC $04C6,X             
A70C  9D C6 04 STA $04C6,X             
A70F  98       TYA                     
A710  7D F2 04 ADC $04F2,X             
A713  D0 33    BNE loc_A748            
A715  AD 16 04 LDA $0416               
A718  29 01    AND #$01                
A71A  F0 2B    BEQ loc_A747            
A71C  A0 00    LDY #$00                
A71E  AD 34 05 LDA $0534               
A721  85 11    STA $11                 
A723  10 01    BPL loc_A726            
A725  88       DEY                     

loc_A726:  ; 1 xrefs: A723
A726  84 10    STY $10                 
A728  AD 4A 05 LDA $054A               
A72B  66 10    ROR $10                 
A72D  66 11    ROR $11                 
A72F  6A       ROR A                   
A730  66 10    ROR $10                 
A732  66 11    ROR $11                 
A734  6A       ROR A                   
A735  18       CLC                     
A736  7D DC 04 ADC $04DC,X             
A739  A5 11    LDA $11                 
A73B  7D C6 04 ADC $04C6,X             
A73E  9D C6 04 STA $04C6,X             
A741  98       TYA                     
A742  7D B0 04 ADC $04B0,X             
A745  D0 01    BNE loc_A748            

loc_A747:  ; 1 xrefs: A71A
A747  60       RTS                     

loc_A748:  ; 3 xrefs: A713 A745 A761
A748  68       PLA                     
A749  68       PLA                     
A74A  4C 10 C8 JMP $C810               

loc_A74D:  ; 0 xrefs: 
A74D  A0 00    LDY #$00                
A74F  85 10    STA $10                 
A751  A5 02    LDA $02                 
A753  10 01    BPL loc_A756            
A755  88       DEY                     

loc_A756:  ; 1 xrefs: A753
A756  18       CLC                     
A757  7D 08 05 ADC $0508,X             
A75A  9D 08 05 STA $0508,X             
A75D  98       TYA                     
A75E  7D F2 04 ADC $04F2,X             
A761  D0 E5    BNE loc_A748            
A763  60       RTS                     

loc_A764:  ; 0 xrefs: 
A764  A9 00    LDA #$00                
A766  85 10    STA $10                 
A768  85 01    STA $01                 
A76A  85 02    STA $02                 
A76C  AD C6 04 LDA $04C6               
A76F  38       SEC                     
A770  E9 10    SBC #$10                
A772  38       SEC                     
A773  FD C6 04 SBC $04C6,X             
A776  F0 09    BEQ loc_A781            
A778  18       CLC                     
A779  69 10    ADC #$10                
A77B  C9 21    CMP #$21                
A77D  90 02    BCC loc_A781            
A77F  E6 10    INC $10                 

loc_A781:  ; 2 xrefs: A776 A77D
A781  AD C6 04 LDA $04C6               
A784  38       SEC                     
A785  E9 1C    SBC #$1C                
A787  38       SEC                     
A788  FD C6 04 SBC $04C6,X             
A78B  F0 08    BEQ loc_A795            
A78D  A0 02    LDY #$02                
A78F  B0 02    BCS loc_A793            
A791  A0 FE    LDY #$FE                

loc_A793:  ; 1 xrefs: A78F
A793  84 01    STY $01                 

loc_A795:  ; 1 xrefs: A78B
A795  AD 08 05 LDA $0508               
A798  38       SEC                     
A799  FD 08 05 SBC $0508,X             
A79C  F0 11    BEQ loc_A7AF            
A79E  A0 02    LDY #$02                
A7A0  B0 02    BCS loc_A7A4            
A7A2  A0 FE    LDY #$FE                

loc_A7A4:  ; 1 xrefs: A7A0
A7A4  84 02    STY $02                 
A7A6  18       CLC                     
A7A7  69 0A    ADC #$0A                
A7A9  C9 15    CMP #$15                
A7AB  90 02    BCC loc_A7AF            
A7AD  E6 10    INC $10                 

loc_A7AF:  ; 2 xrefs: A79C A7AB
A7AF  A5 10    LDA $10                 
A7B1  D0 05    BNE loc_A7B8            
A7B3  68       PLA                     
A7B4  68       PLA                     
A7B5  4C 10 C8 JMP $C810               

loc_A7B8:  ; 1 xrefs: A7B1
A7B8  60       RTS                     

sub_A7B9:  ; 1 xrefs: A59C
A7B9  BD 4A 05 LDA $054A,X             
A7BC  18       CLC                     
A7BD  7D DC 04 ADC $04DC,X             
A7C0  9D DC 04 STA $04DC,X             
A7C3  A0 00    LDY #$00                
A7C5  BD 34 05 LDA $0534,X             
A7C8  10 01    BPL loc_A7CB            
A7CA  88       DEY                     

loc_A7CB:  ; 1 xrefs: A7C8
A7CB  7D C6 04 ADC $04C6,X             
A7CE  9D C6 04 STA $04C6,X             
A7D1  98       TYA                     
A7D2  7D B0 04 ADC $04B0,X             
A7D5  D0 1F    BNE loc_A7F6            
A7D7  BD 76 05 LDA $0576,X             
A7DA  18       CLC                     
A7DB  7D 1E 05 ADC $051E,X             
A7DE  9D 1E 05 STA $051E,X             
A7E1  A0 00    LDY #$00                
A7E3  BD 60 05 LDA $0560,X             
A7E6  10 01    BPL loc_A7E9            
A7E8  88       DEY                     

loc_A7E9:  ; 1 xrefs: A7E6
A7E9  7D 08 05 ADC $0508,X             
A7EC  9D 08 05 STA $0508,X             
A7EF  98       TYA                     
A7F0  7D F2 04 ADC $04F2,X             
A7F3  D0 01    BNE loc_A7F6            
A7F5  60       RTS                     

loc_A7F6:  ; 2 xrefs: A7D5 A7F3
A7F6  68       PLA                     
A7F7  68       PLA                     
A7F8  4C 10 C8 JMP $C810               

loc_A7FB:  ; 1 xrefs: A577
A7FB  BC CE 05 LDY $05CE,X             
A7FE  B9 25 A9 LDA $A925,Y             
A801  85 00    STA $00                 
A803  B9 2D A9 LDA $A92D,Y             
A806  85 01    STA $01                 
A808  B9 35 A9 LDA $A935,Y             
A80B  85 02    STA $02                 
A80D  B9 3D A9 LDA $A93D,Y             
A810  85 03    STA $03                 
A812  BD FA 05 LDA $05FA,X             
A815  F0 10    BEQ loc_A827            
A817  A5 01    LDA $01                 
A819  C9 80    CMP #$80                
A81B  66 01    ROR $01                 
A81D  66 00    ROR $00                 
A81F  A5 03    LDA $03                 
A821  C9 80    CMP #$80                
A823  66 03    ROR $03                 
A825  66 02    ROR $02                 

loc_A827:  ; 1 xrefs: A815
A827  BD 76 05 LDA $0576,X             
A82A  18       CLC                     
A82B  65 00    ADC $00                 
A82D  9D 76 05 STA $0576,X             
A830  BD 60 05 LDA $0560,X             
A833  65 01    ADC $01                 
A835  9D 60 05 STA $0560,X             
A838  BD 4A 05 LDA $054A,X             
A83B  18       CLC                     
A83C  65 02    ADC $02                 
A83E  9D 4A 05 STA $054A,X             
A841  BD 34 05 LDA $0534,X             
A844  65 03    ADC $03                 
A846  9D 34 05 STA $0534,X             
A849  20 E8 C8 JSR $C8E8               
A84C  DE A2 05 DEC $05A2,X             
A84F  F0 01    BEQ loc_A852            
A851  60       RTS                     

loc_A852:  ; 1 xrefs: A84F
A852  4C 10 C8 JMP $C810               

; ==== data $A855..$A8A8  (84 bytes) ====
A855  65 A8 6D A8 75 A8 7D A8 85 A8 8D A8 95 A8 9D A8  |e.m.u.}.........
A865  00 03 80 03 00 04 80 04 80 03 00 04 80 04 00 05  |................
A875  00 04 80 04 80 05 80 06 80 04 80 05 80 06 80 07  |................
A885  99 03 33 04 CC 04 66 05 33 04 CC 04 66 05 00 06  |..3...f.3...f...
A895  CC 04 66 05 99 06 CC 07 66 05 99 06 CC 07 00 09  |..f.....f.......
A8A5  00 00 40 C0                                      |..@.

loc_A8A9:  ; 0 xrefs: 
A8A9  48       PHA                     
A8AA  48       PHA                     
A8AB  B8       CLV                     
A8AC  B8       CLV                     
A8AD  00 00    BRK #$00                

; ==== data $A8AF..$A900  (82 bytes) ====
A8AF  60 A0 6A 6A 96 96 00 00 00 FF 00 00 FF FF 00 00  |`.jj............
A8BF  00 FF 00 00 FF FF C0 40 00 00 B8 48 B8 48 A0 60  |.......@...H.H.`
A8CF  00 00 96 6A 96 6A FF 00 00 00 FF 00 FF 00 FF 00  |...j.j..........
A8DF  00 00 FF 00 FF 00 3E 3E 40 42 3F 3F 41 41 F5 A8  |......>>@B??AA..
A8EF  F9 A8 FD A8 01 A9 06 07 08 09 09 0A 0B 0C 0C 0D  |................
A8FF  0E 0F                                            |..

loc_A901:  ; 0 xrefs: 
A901  0F 10 11 SLO $1110               

; ==== data $A904..$A944  (65 bytes) ====
A904  12 40 C0 00 00 2D D3 2D D3 00 FF 00 00 00 FF 00  |.@...-.-........
A914  FF 00 00 C0 00 D3 D3 2D 2D 00 00 FF 03 FF FF 00  |.......--.......
A924  00 C0 40 00 00 87 79 87 79 00 FF 00 00 00 FF 00  |..@...y.y.......
A934  FF 00 00 00 00 79 79 87 87 00 00 FF 01 FF FF 00  |.....yy.........
A944  00                                               |.

sub_A945:  ; 2 xrefs: 8E12 8E2C
A945  A5 9A    LDA $9A                 
A947  C9 04    CMP #$04                
A949  F0 0F    BEQ loc_A95A            
A94B  AD 46 04 LDA $0446               
A94E  D0 01    BNE loc_A951            
A950  60       RTS                     

loc_A951:  ; 1 xrefs: A94E
A951  A2 04    LDX #$04                
A953  20 10 C8 JSR $C810               
A956  E8       INX                     
A957  4C 10 C8 JMP $C810               

loc_A95A:  ; 1 xrefs: A949
A95A  AD 46 04 LDA $0446               
A95D  D0 03    BNE loc_A962            
A95F  20 86 AA JSR sub_AA86            

loc_A962:  ; 1 xrefs: A95D
A962  A2 04    LDX #$04                
A964  20 68 A9 JSR sub_A968            
A967  E8       INX                     

sub_A968:  ; 1 xrefs: A964
A968  FE E4 05 INC $05E4,X             
A96B  20 ED AA JSR sub_AAED            
A96E  A9 09    LDA #$09                
A970  20 8E C8 JSR $C88E               
A973  BC 8C 05 LDY $058C,X             
A976  B9 83 A9 LDA $A983,Y             
A979  85 08    STA $08                 
A97B  B9 87 A9 LDA $A987,Y             
A97E  85 09    STA $09                 
A980  6C 08 00 JMP ($0008)             

; ==== data $A983..$A9A8  (38 bytes) ====
A983  8B B6 FB 12 A9 A9 A9 AA 20 4D AB D0 18 20 B3 AA  |........ M... ..
A993  A5 08 9D 08 05 A5 09 9D F2 04 A5 0A 9D C6 04 A5  |................
A9A3  0B 9D B0 04 60 A9                                |....`.

loc_A9A9:  ; 0 xrefs: 
A9A9  01 9D    ORA ($9D,X)             
A9AB  8C 05 A9 STY $A905               
A9AE  00 A8    BRK #$A8                
A9B0  20 06 C9 JSR $C906               
A9B3  4C 09 C9 JMP $C909               

; ==== data $A9B6..$AA85  (208 bytes) ====
A9B6  BD 26 06 2D 17 01 9D 26 06 BD 3C 06 2D 18 01 9D  |.&.-...&..<.-...
A9C6  3C 06 1D 26 06 F0 25 8A 4D 10 01 29 01 D0 1A 20  |<..&..%.M..)... 
A9D6  89 AB B9 08 05 85 02 B9 C6 04 85 03 B9 F2 04 85  |................
A9E6  06 B9 B0 04 85 07 20 6C AB 4C F1 C8 FE 8C 05 A9  |...... l.L......
A9F6  20 9D CE 05 60 20 4D AB D0 A8 DE CE 05 F0 01 60  | ...` M........`
AA06  FE 8C 05 A9 00 A8 20 06 C9 4C 09 C9 20 4D AB D0  |...... ..L.. M..
AA16  91 20 B3 AA A5 08 85 02 A5 09 85 06 A5 0A 85 03  |. ..............
AA26  A5 0B 85 07 A5 08 38 FD 08 05 85 24 A5 09 FD F2  |......8....$....
AA36  04 B0 0D 85 26 A9 00 38 E5 24 85 24 A9 00 E5 26  |....&..8.$.$...&
AA46  D0 30 A5 24 C9 18 B0 2A A5 0A 38 FD C6 04 85 24  |.0.$...*..8....$
AA56  A5 0B FD B0 04 B0 0D 85 26 A9 00 38 E5 24 85 24  |........&..8.$.$
AA66  A9 00 E5 26 D0 0C A5 24 C9 18 B0 06 A9 00 9D 8C  |...&...$........
AA76  05 60 8A 4D 10 01 29 01 D0 03 20 6C AB 4C F1 C8  |.`.M..)... l.L..

sub_AA86:  ; 1 xrefs: A95F
AA86  A2 04    LDX #$04                
AA88  A9 18    LDA #$18                
AA8A  20 94 AA JSR sub_AA94            
AA8D  E8       INX                     
AA8E  A9 E8    LDA #$E8                
AA90  20 94 AA JSR sub_AA94            
AA93  60       RTS                     

sub_AA94:  ; 2 xrefs: AA8A AA90
AA94  9D FA 05 STA $05FA,X             
AA97  20 B3 AA JSR sub_AAB3            
AA9A  A5 08    LDA $08                 
AA9C  9D 08 05 STA $0508,X             
AA9F  A5 09    LDA $09                 
AAA1  9D F2 04 STA $04F2,X             
AAA4  A5 0A    LDA $0A                 
AAA6  9D C6 04 STA $04C6,X             
AAA9  A5 0B    LDA $0B                 
AAAB  9D B0 04 STA $04B0,X             
AAAE  A9 09    LDA #$09                
AAB0  4C 91 C8 JMP $C891               

sub_AAB3:  ; 1 xrefs: AA97
AAB3  BD FA 05 LDA $05FA,X             
AAB6  85 08    STA $08                 
AAB8  BD 10 06 LDA $0610,X             
AABB  85 09    STA $09                 
AABD  BD E4 05 LDA $05E4,X             
AAC0  20 8B C8 JSR $C88B               
AAC3  A0 00    LDY #$00                
AAC5  A5 0B    LDA $0B                 
AAC7  10 01    BPL loc_AACA            
AAC9  88       DEY                     

loc_AACA:  ; 1 xrefs: AAC7
AACA  18       CLC                     
AACB  6D 08 05 ADC $0508               
AACE  85 08    STA $08                 
AAD0  98       TYA                     
AAD1  6D F2 04 ADC $04F2               
AAD4  85 09    STA $09                 
AAD6  A0 00    LDY #$00                
AAD8  A5 0C    LDA $0C                 
AADA  38       SEC                     
AADB  E9 10    SBC #$10                
AADD  10 01    BPL loc_AAE0            
AADF  88       DEY                     

loc_AAE0:  ; 1 xrefs: AADD
AAE0  18       CLC                     
AAE1  6D C6 04 ADC $04C6               
AAE4  85 0A    STA $0A                 
AAE6  98       TYA                     
AAE7  6D B0 04 ADC $04B0               
AAEA  85 0B    STA $0B                 
AAEC  60       RTS                     

sub_AAED:  ; 1 xrefs: A96B
AAED  BD F2 04 LDA $04F2,X             
AAF0  1D B0 04 ORA $04B0,X             
AAF3  D0 1C    BNE loc_AB11            
AAF5  BD 08 05 LDA $0508,X             
AAF8  85 08    STA $08                 
AAFA  BD C6 04 LDA $04C6,X             
AAFD  85 09    STA $09                 
AAFF  8A       TXA                     
AB00  48       PHA                     
AB01  A2 06    LDX #$06                
AB03  AD 17 01 LDA $0117               
AB06  20 12 AB JSR sub_AB12            
AB09  AD 18 01 LDA $0118               
AB0C  20 12 AB JSR sub_AB12            
AB0F  68       PLA                     
AB10  AA       TAX                     

loc_AB11:  ; 1 xrefs: AAF3
AB11  60       RTS                     

sub_AB12:  ; 2 xrefs: AB06 AB0C
AB12  85 00    STA $00                 
AB14  A9 08    LDA #$08                
AB16  85 01    STA $01                 

loc_AB18:  ; 1 xrefs: AB4A
AB18  66 00    ROR $00                 
AB1A  90 2B    BCC loc_AB47            
AB1C  BD F2 04 LDA $04F2,X             
AB1F  1D B0 04 ORA $04B0,X             
AB22  D0 23    BNE loc_AB47            
AB24  BD 08 05 LDA $0508,X             
AB27  38       SEC                     
AB28  E5 08    SBC $08                 
AB2A  B0 04    BCS loc_AB30            
AB2C  49 FF    EOR #$FF                
AB2E  69 01    ADC #$01                

loc_AB30:  ; 1 xrefs: AB2A
AB30  C9 0D    CMP #$0D                
AB32  B0 13    BCS loc_AB47            
AB34  BD C6 04 LDA $04C6,X             
AB37  38       SEC                     
AB38  E5 09    SBC $09                 
AB3A  B0 04    BCS loc_AB40            
AB3C  49 FF    EOR #$FF                
AB3E  69 01    ADC #$01                

loc_AB40:  ; 1 xrefs: AB3A
AB40  C9 0D    CMP #$0D                
AB42  B0 03    BCS loc_AB47            
AB44  20 10 C8 JSR $C810               

loc_AB47:  ; 4 xrefs: AB1A AB22 AB32 AB42
AB47  E8       INX                     
AB48  C6 01    DEC $01                 
AB4A  D0 CC    BNE loc_AB18            
AB4C  60       RTS                     

loc_AB4D:  ; 0 xrefs: 
AB4D  8A       TXA                     
AB4E  29 01    AND #$01                
AB50  A8       TAY                     
AB51  AD 17 01 LDA $0117               
AB54  39 6A AB AND $AB6A,Y             
AB57  D0 09    BNE loc_AB62            
AB59  AD 18 01 LDA $0118               
AB5C  39 6A AB AND $AB6A,Y             
AB5F  D0 05    BNE loc_AB66            
AB61  60       RTS                     

loc_AB62:  ; 1 xrefs: AB57
AB62  9D 26 06 STA $0626,X             
AB65  60       RTS                     

loc_AB66:  ; 1 xrefs: AB5F
AB66  9D 3C 06 STA $063C,X             
AB69  60       RTS                     

; ==== data $AB6A..$AB6B  (2 bytes) ====
AB6A  55 AA                                            |U.

loc_AB6C:  ; 0 xrefs: 
AB6C  BD 08 05 LDA $0508,X             
AB6F  85 00    STA $00                 
AB71  BD C6 04 LDA $04C6,X             
AB74  85 01    STA $01                 
AB76  BD F2 04 LDA $04F2,X             
AB79  85 04    STA $04                 
AB7B  BD B0 04 LDA $04B0,X             
AB7E  85 05    STA $05                 
AB80  20 B5 C8 JSR $C8B5               
AB83  A8       TAY                     
AB84  A9 3F    LDA #$3F                
AB86  4C AF C8 JMP $C8AF               

loc_AB89:  ; 0 xrefs: 
AB89  A0 06    LDY #$06                
AB8B  BD 26 06 LDA $0626,X             
AB8E  F0 09    BEQ loc_AB99            
AB90  85 00    STA $00                 

loc_AB92:  ; 1 xrefs: AB97
AB92  66 00    ROR $00                 
AB94  B0 0F    BCS loc_ABA5            
AB96  C8       INY                     
AB97  D0 F9    BNE loc_AB92            

loc_AB99:  ; 1 xrefs: AB8E
AB99  BD 3C 06 LDA $063C,X             
AB9C  85 00    STA $00                 

loc_AB9E:  ; 1 xrefs: ABA3
AB9E  66 00    ROR $00                 
ABA0  B0 03    BCS loc_ABA5            
ABA2  C8       INY                     
ABA3  D0 F9    BNE loc_AB9E            

loc_ABA5:  ; 2 xrefs: AB94 ABA0
ABA5  60       RTS                     

sub_ABA6:  ; 4 xrefs: AC35 B345 B648 B72D
ABA6  84 17    STY $17                 
ABA8  A0 00    LDY #$00                
ABAA  09 00    ORA #$00                
ABAC  10 01    BPL loc_ABAF            
ABAE  88       DEY                     

loc_ABAF:  ; 1 xrefs: ABAC
ABAF  18       CLC                     
ABB0  6D 08 05 ADC $0508               
ABB3  85 13    STA $13                 
ABB5  98       TYA                     
ABB6  6D F2 04 ADC $04F2               
ABB9  85 12    STA $12                 
ABBB  A0 00    LDY #$00                
ABBD  A5 17    LDA $17                 
ABBF  10 01    BPL loc_ABC2            
ABC1  88       DEY                     

loc_ABC2:  ; 1 xrefs: ABBF
ABC2  18       CLC                     
ABC3  6D C6 04 ADC $04C6               
ABC6  85 11    STA $11                 
ABC8  98       TYA                     
ABC9  6D B0 04 ADC $04B0               
ABCC  85 10    STA $10                 
ABCE  A4 97    LDY $97                 
ABD0  D0 1B    BNE loc_ABED            
ABD2  A8       TAY                     
ABD3  F0 0E    BEQ loc_ABE3            
ABD5  30 06    BMI loc_ABDD            

loc_ABD7:  ; 1 xrefs: ABE7
ABD7  A9 AF    LDA #$AF                
ABD9  85 11    STA $11                 
ABDB  D0 10    BNE loc_ABED            

loc_ABDD:  ; 2 xrefs: ABD5 ABEB
ABDD  A9 10    LDA #$10                
ABDF  85 11    STA $11                 
ABE1  D0 0A    BNE loc_ABED            

loc_ABE3:  ; 1 xrefs: ABD3
ABE3  A5 11    LDA $11                 
ABE5  C9 B0    CMP #$B0                
ABE7  B0 EE    BCS loc_ABD7            
ABE9  C9 10    CMP #$10                
ABEB  90 F0    BCC loc_ABDD            

loc_ABED:  ; 3 xrefs: ABD0 ABDB ABE1
ABED  A4 87    LDY $87                 
ABEF  B9 FC AB LDA $ABFC,Y             
ABF2  85 14    STA $14                 
ABF4  B9 0C AC LDA $AC0C,Y             
ABF7  85 15    STA $15                 
ABF9  6C 14 00 JMP ($0014)             

; ==== data $ABFC..$AC1B  (32 bytes) ====
ABFC  1C 1C 1C 1C 1D 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C  |................
AC0C  AC AC AC AC AC AC AC AC AC AC AC AC AC AC AC AC  |................

loc_AC1C:  ; 0 xrefs: 
AC1C  60       RTS                     

; ==== data $AC1D..$AC34  (24 bytes) ====
AC1D  A5 11 C9 80 B0 F9 C5 29 B0 09 38 E5 29 18 69 80  |.......)..8.).i.
AC2D  85 11 60 A9 80 85 11 60                          |..`....`

sub_AC35:  ; 21 xrefs: 91D4 91DD 9391 93CB 93F2 94F5 9503 9E51 9E5F 9E90 ...
AC35  20 A6 AB JSR sub_ABA6            
AC38  A5 10    LDA $10                 
AC3A  05 12    ORA $12                 
AC3C  D0 16    BNE loc_AC54            
AC3E  A4 11    LDY $11                 
AC40  C0 B0    CPY #$B0                
AC42  B0 10    BCS loc_AC54            
AC44  A5 97    LDA $97                 
AC46  F0 07    BEQ loc_AC4F            
AC48  A5 67    LDA $67                 
AC4A  18       CLC                     
AC4B  65 11    ADC $11                 
AC4D  85 11    STA $11                 

loc_AC4F:  ; 1 xrefs: AC46
AC4F  A5 13    LDA $13                 
AC51  4C A0 C8 JMP $C8A0               

loc_AC54:  ; 2 xrefs: AC3C AC42
AC54  4C 85 C8 JMP $C885               

sub_AC57:  ; 5 xrefs: 9E6D 9E7E 9EA2 9EAB A281
AC57  AE 1F 01 LDX $011F               
AC5A  F0 5B    BEQ loc_ACB7            

sub_AC5C:  ; 7 xrefs: AD64 AD71 AD7C ADF3 ADFF AEA0 AEAC
AC5C  85 11    STA $11                 
AC5E  A2 00    LDX #$00                
AC60  98       TYA                     
AC61  10 01    BPL loc_AC64            
AC63  CA       DEX                     

loc_AC64:  ; 1 xrefs: AC61
AC64  18       CLC                     
AC65  6D 08 05 ADC $0508               
AC68  A8       TAY                     
AC69  8A       TXA                     
AC6A  6D F2 04 ADC $04F2               
AC6D  F0 08    BEQ loc_AC77            
AC6F  30 04    BMI loc_AC75            
AC71  A0 FF    LDY #$FF                
AC73  D0 02    BNE loc_AC77            

loc_AC75:  ; 1 xrefs: AC6F
AC75  A0 00    LDY #$00                

loc_AC77:  ; 2 xrefs: AC6D AC73
AC77  84 10    STY $10                 
AC79  A2 00    LDX #$00                
AC7B  A5 11    LDA $11                 
AC7D  10 01    BPL loc_AC80            
AC7F  CA       DEX                     

loc_AC80:  ; 1 xrefs: AC7D
AC80  18       CLC                     
AC81  6D C6 04 ADC $04C6               
AC84  A8       TAY                     
AC85  8A       TXA                     
AC86  6D B0 04 ADC $04B0               
AC89  F0 08    BEQ loc_AC93            
AC8B  30 04    BMI loc_AC91            
AC8D  A0 FF    LDY #$FF                
AC8F  D0 02    BNE loc_AC93            

loc_AC91:  ; 1 xrefs: AC8B
AC91  A0 00    LDY #$00                

loc_AC93:  ; 2 xrefs: AC89 AC8F
AC93  84 11    STY $11                 
AC95  AC 1F 01 LDY $011F               

loc_AC98:  ; 1 xrefs: ACB5
AC98  B9 2F 01 LDA $012F,Y             
AC9B  C5 10    CMP $10                 
AC9D  90 15    BCC loc_ACB4            
AC9F  A5 10    LDA $10                 
ACA1  D9 1F 01 CMP $011F,Y             
ACA4  90 0E    BCC loc_ACB4            
ACA6  B9 4F 01 LDA $014F,Y             
ACA9  C5 11    CMP $11                 
ACAB  90 07    BCC loc_ACB4            
ACAD  A5 11    LDA $11                 
ACAF  D9 3F 01 CMP $013F,Y             
ACB2  B0 05    BCS loc_ACB9            

loc_ACB4:  ; 3 xrefs: AC9D ACA4 ACAB
ACB4  88       DEY                     
ACB5  D0 E1    BNE loc_AC98            

loc_ACB7:  ; 1 xrefs: AC5A
ACB7  18       CLC                     
ACB8  60       RTS                     

loc_ACB9:  ; 1 xrefs: ACB2
ACB9  60       RTS                     

sub_ACBA:  ; 3 xrefs: 90D5 9668 A05E
ACBA  AD CE 05 LDA $05CE               
ACBD  18       CLC                     
ACBE  6D 1E 05 ADC $051E               
ACC1  AD E4 05 LDA $05E4               
ACC4  AA       TAX                     
ACC5  69 00    ADC #$00                
ACC7  4C D5 AC JMP sub_ACD5            

; ==== data $ACCA..$ACD4  (11 bytes) ====
ACCA  A5 04 18 6D 1E 05 A5 05 AA 69 00                 |...m.....i.

sub_ACD5:  ; 8 xrefs: 8FD8 96B0 96BB 972E 973E 9A48 A130 ACC7
ACD5  85 0A    STA $0A                 
ACD7  8A       TXA                     
ACD8  10 31    BPL loc_AD0B            
ACDA  AD 68 06 LDA $0668               
ACDD  29 20    AND #$20                
ACDF  D0 24    BNE loc_AD05            
ACE1  AD F2 04 LDA $04F2               
ACE4  30 22    BMI loc_AD08            
ACE6  D0 07    BNE loc_ACEF            
ACE8  AD 08 05 LDA $0508               
ACEB  C9 10    CMP #$10                
ACED  90 19    BCC loc_AD08            

loc_ACEF:  ; 1 xrefs: ACE6
ACEF  B9 BD AE LDA $AEBD,Y             
ACF2  85 08    STA $08                 
ACF4  B9 EC AE LDA $AEEC,Y             
ACF7  85 09    STA $09                 
ACF9  A0 00    LDY #$00                
ACFB  B1 08    LDA ($08),Y             
ACFD  49 FF    EOR #$FF                
ACFF  18       CLC                     
AD00  65 0A    ADC $0A                 
AD02  4C 30 AD JMP loc_AD30            

loc_AD05:  ; 2 xrefs: ACDF AD10
AD05  A9 81    LDA #$81                
AD07  60       RTS                     

loc_AD08:  ; 4 xrefs: ACE4 ACED AD17 AD1E
AD08  A9 82    LDA #$82                
AD0A  60       RTS                     

loc_AD0B:  ; 1 xrefs: ACD8
AD0B  AD 68 06 LDA $0668               
AD0E  29 10    AND #$10                
AD10  D0 F3    BNE loc_AD05            
AD12  AD F2 04 LDA $04F2               
AD15  30 09    BMI loc_AD20            
AD17  D0 EF    BNE loc_AD08            
AD19  AD 08 05 LDA $0508               
AD1C  C9 F1    CMP #$F1                
AD1E  B0 E8    BCS loc_AD08            

loc_AD20:  ; 1 xrefs: AD15
AD20  B9 BD AE LDA $AEBD,Y             
AD23  85 08    STA $08                 
AD25  B9 EC AE LDA $AEEC,Y             
AD28  85 09    STA $09                 
AD2A  A0 00    LDY #$00                
AD2C  B1 08    LDA ($08),Y             
AD2E  65 0A    ADC $0A                 

loc_AD30:  ; 1 xrefs: AD02
AD30  85 0A    STA $0A                 
AD32  C8       INY                     
AD33  B1 08    LDA ($08),Y             
AD35  A8       TAY                     
AD36  A5 0A    LDA $0A                 
AD38  20 35 AC JSR sub_AC35            
AD3B  30 47    BMI loc_AD84            
AD3D  A0 02    LDY #$02                
AD3F  B1 08    LDA ($08),Y             
AD41  F0 16    BEQ loc_AD59            
AD43  A8       TAY                     
AD44  A5 0A    LDA $0A                 
AD46  20 35 AC JSR sub_AC35            
AD49  30 39    BMI loc_AD84            
AD4B  A0 03    LDY #$03                
AD4D  B1 08    LDA ($08),Y             
AD4F  F0 08    BEQ loc_AD59            
AD51  A8       TAY                     
AD52  A5 0A    LDA $0A                 
AD54  20 35 AC JSR sub_AC35            
AD57  30 2B    BMI loc_AD84            

loc_AD59:  ; 2 xrefs: AD41 AD4F
AD59  AD 1F 01 LDA $011F               
AD5C  F0 23    BEQ loc_AD81            
AD5E  A0 01    LDY #$01                
AD60  B1 08    LDA ($08),Y             
AD62  A4 0A    LDY $0A                 
AD64  20 5C AC JSR sub_AC5C            
AD67  B0 1E    BCS loc_AD87            
AD69  A0 02    LDY #$02                
AD6B  B1 08    LDA ($08),Y             
AD6D  F0 12    BEQ loc_AD81            
AD6F  A4 0A    LDY $0A                 
AD71  20 5C AC JSR sub_AC5C            
AD74  B0 11    BCS loc_AD87            
AD76  A0 03    LDY #$03                
AD78  B1 08    LDA ($08),Y             
AD7A  A4 0A    LDY $0A                 
AD7C  20 5C AC JSR sub_AC5C            
AD7F  B0 06    BCS loc_AD87            

loc_AD81:  ; 2 xrefs: AD5C AD6D
AD81  A9 00    LDA #$00                
AD83  60       RTS                     

loc_AD84:  ; 3 xrefs: AD3B AD49 AD57
AD84  A9 01    LDA #$01                
AD86  60       RTS                     

loc_AD87:  ; 3 xrefs: AD67 AD74 AD7F
AD87  A9 80    LDA #$80                
AD89  8C 15 01 STY $0115               
AD8C  60       RTS                     

sub_AD8D:  ; 7 xrefs: 8F35 9109 916E 9290 9326 9406 9FD2
AD8D  A9 00    LDA #$00                
AD8F  F0 19    BEQ loc_ADAA            
AD91  A5 04    LDA $04                 
AD93  18       CLC                     
AD94  6D DC 04 ADC $04DC               
AD97  A5 05    LDA $05                 
AD99  69 00    ADC #$00                
AD9B  4C AA AD JMP sub_ADAA            

sub_AD9E:  ; 2 xrefs: 92B8 A04B
AD9E  AD FA 05 LDA $05FA               
ADA1  18       CLC                     
ADA2  6D DC 04 ADC $04DC               
ADA5  AD 10 06 LDA $0610               
ADA8  69 00    ADC #$00                

sub_ADAA:  ; 3 xrefs: A157 AD8F AD9B
ADAA  85 0A    STA $0A                 
ADAC  AD 68 06 LDA $0668               
ADAF  30 5F    BMI loc_AE10            
ADB1  B9 BD AE LDA $AEBD,Y             
ADB4  85 08    STA $08                 
ADB6  B9 EC AE LDA $AEEC,Y             
ADB9  85 09    STA $09                 
ADBB  A0 00    LDY #$00                
ADBD  B1 08    LDA ($08),Y             
ADBF  18       CLC                     
ADC0  65 0A    ADC $0A                 
ADC2  85 0A    STA $0A                 
ADC4  10 01    BPL loc_ADC7            
ADC6  88       DEY                     

loc_ADC7:  ; 1 xrefs: ADC4
ADC7  18       CLC                     

loc_ADC8:  ; 0 xrefs: 
ADC8  6D C6 04 ADC $04C6               
ADCB  98       TYA                     
ADCC  6D B0 04 ADC $04B0               
ADCF  30 42    BMI loc_AE13            
ADD1  A0 01    LDY #$01                
ADD3  B1 08    LDA ($08),Y             
ADD5  A4 0A    LDY $0A                 
ADD7  20 35 AC JSR sub_AC35            
ADDA  30 31    BMI loc_AE0D            
ADDC  A0 02    LDY #$02                
ADDE  B1 08    LDA ($08),Y             
ADE0  A4 0A    LDY $0A                 
ADE2  20 35 AC JSR sub_AC35            
ADE5  30 26    BMI loc_AE0D            
ADE7  AD 1F 01 LDA $011F               
ADEA  F0 18    BEQ loc_AE04            
ADEC  A0 01    LDY #$01                
ADEE  B1 08    LDA ($08),Y             
ADF0  A8       TAY                     
ADF1  A5 0A    LDA $0A                 
ADF3  20 5C AC JSR sub_AC5C            
ADF6  B0 0F    BCS loc_AE07            
ADF8  A0 02    LDY #$02                
ADFA  B1 08    LDA ($08),Y             
ADFC  A8       TAY                     
ADFD  A5 0A    LDA $0A                 
ADFF  20 5C AC JSR sub_AC5C            
AE02  B0 03    BCS loc_AE07            

loc_AE04:  ; 1 xrefs: ADEA
AE04  A9 00    LDA #$00                
AE06  60       RTS                     

loc_AE07:  ; 2 xrefs: ADF6 AE02
AE07  A9 80    LDA #$80                
AE09  8C 15 01 STY $0115               
AE0C  60       RTS                     

loc_AE0D:  ; 2 xrefs: ADDA ADE5
AE0D  A9 01    LDA #$01                
AE0F  60       RTS                     

loc_AE10:  ; 1 xrefs: ADAF
AE10  A9 81    LDA #$81                
AE12  60       RTS                     

loc_AE13:  ; 1 xrefs: ADCF
AE13  A9 82    LDA #$82                
AE15  60       RTS                     

loc_AE16:  ; 1 xrefs: AE3B
AE16  A9 81    LDA #$81                
AE18  60       RTS                     

sub_AE19:  ; 18 xrefs: 8F3C 8F4F 90ED 9102 9139 9167 9286 92AB 931C 9353 ...
AE19  A9 00    LDA #$00                
AE1B  F0 19    BEQ loc_AE36            
AE1D  A5 04    LDA $04                 
AE1F  18       CLC                     
AE20  6D DC 04 ADC $04DC               
AE23  A5 05    LDA $05                 
AE25  69 00    ADC #$00                
AE27  4C 36 AE JMP sub_AE36            

sub_AE2A:  ; 4 xrefs: 92FE 9A15 9D8C A043
AE2A  AD FA 05 LDA $05FA               
AE2D  18       CLC                     
AE2E  6D DC 04 ADC $04DC               
AE31  AD 10 06 LDA $0610               
AE34  69 00    ADC #$00                

sub_AE36:  ; 3 xrefs: A14A AE1B AE27
AE36  85 0A    STA $0A                 
AE38  2C 68 06 BIT $0668               
AE3B  70 D9    BVS loc_AE16            
AE3D  B9 BD AE LDA $AEBD,Y             
AE40  85 08    STA $08                 
AE42  B9 EC AE LDA $AEEC,Y             
AE45  85 09    STA $09                 
AE47  A0 00    LDY #$00                
AE49  B1 08    LDA ($08),Y             
AE4B  18       CLC                     
AE4C  65 0A    ADC $0A                 
AE4E  85 0A    STA $0A                 
AE50  C8       INY                     
AE51  B1 08    LDA ($08),Y             
AE53  A4 0A    LDY $0A                 
AE55  20 35 AC JSR sub_AC35            
AE58  30 5A    BMI loc_AEB4            
AE5A  85 0C    STA $0C                 
AE5C  A0 02    LDY #$02                
AE5E  B1 08    LDA ($08),Y             
AE60  A4 0A    LDY $0A                 
AE62  20 35 AC JSR sub_AC35            
AE65  30 4D    BMI loc_AEB4            
AE67  85 0D    STA $0D                 
AE69  A5 0C    LDA $0C                 
AE6B  C9 01    CMP #$01                
AE6D  D0 04    BNE loc_AE73            
AE6F  A0 01    LDY #$01                
AE71  D0 08    BNE loc_AE7B            

loc_AE73:  ; 1 xrefs: AE6D
AE73  A5 0D    LDA $0D                 
AE75  C9 01    CMP #$01                
AE77  D0 1B    BNE loc_AE94            
AE79  A0 02    LDY #$02                

loc_AE7B:  ; 1 xrefs: AE71
AE7B  A5 11    LDA $11                 
AE7D  29 0F    AND #$0F                
AE7F  C9 08    CMP #$08                
AE81  B0 11    BCS loc_AE94            
AE83  B1 08    LDA ($08),Y             
AE85  85 0B    STA $0B                 
AE87  A5 0A    LDA $0A                 
AE89  38       SEC                     
AE8A  E9 10    SBC #$10                
AE8C  A8       TAY                     
AE8D  A5 0B    LDA $0B                 
AE8F  20 35 AC JSR sub_AC35            
AE92  F0 20    BEQ loc_AEB4            

loc_AE94:  ; 2 xrefs: AE77 AE81
AE94  AD 1F 01 LDA $011F               
AE97  F0 18    BEQ loc_AEB1            
AE99  A0 01    LDY #$01                
AE9B  B1 08    LDA ($08),Y             
AE9D  A8       TAY                     
AE9E  A5 0A    LDA $0A                 
AEA0  20 5C AC JSR sub_AC5C            
AEA3  B0 12    BCS loc_AEB7            
AEA5  A0 02    LDY #$02                
AEA7  B1 08    LDA ($08),Y             
AEA9  A8       TAY                     
AEAA  A5 0A    LDA $0A                 
AEAC  20 5C AC JSR sub_AC5C            
AEAF  B0 06    BCS loc_AEB7            

loc_AEB1:  ; 1 xrefs: AE97
AEB1  A9 00    LDA #$00                
AEB3  60       RTS                     

loc_AEB4:  ; 3 xrefs: AE58 AE65 AE92
AEB4  A9 01    LDA #$01                
AEB6  60       RTS                     

loc_AEB7:  ; 2 xrefs: AEA3 AEAF
AEB7  A9 80    LDA #$80                
AEB9  8C 15 01 STY $0115               
AEBC  60       RTS                     

; ==== data $AEBD..$AF80  (196 bytes) ====
AEBD  1B 1E 26 2A 2D 31 34 37 34 3A 34 3D 1B 40 43 47  |..&*-1474:4=.@CG
AECD  4A 4D 50 53 56 34 5D 60 1E 69 6C 26 69 6F 43 69  |JMPSV4]`.il&ioCi
AEDD  72 2D 69 75 59 63 22 78 7B 66 1E 1E 69 6C 7E AF  |r-iuYc"x{f..il~.
AEED  AF AF AF AF AF AF AF AF AF AF AF AF AF AF AF AF  |................
AEFD  AF AF AF AF AF AF AF AF AF AF AF AF AF AF AF AF  |................
AF0D  AF AF AF AF AF AF AF AF AF AF AF AF AF AF E0 FF  |................
AF1D  00 05 00 F2 E5 05 00 F6 EC 05 00 F4 E8 E5 FF 00  |................
AF2D  05 00 F3 00 01 F8 08 01 FA 05 F0 FA 05 E0 FA 05  |................
AF3D  E4 FA 05 0A FA 05 05 00 F6 E4 0A F4 00 0A DC 00  |................
AF4D  0A E4 00 10 D8 00 0C 08 00 0D F1 00 0D F0 E4 00  |................
AF5D  E5 FA 05 02 FA 05 14 FA 05 04 FA 05 00 FA 05 E1  |................
AF6D  FA 05 E9 FA 05 E1 FF 00 F1 FA 05 00 FB 04 E1 FB  |................
AF7D  04 16 F4 00                                      |....

sub_AF81:  ; 2 xrefs: 9ECC 9ED5
AF81  20 C1 AF JSR sub_AFC1            
AF84  B9 D7 AF LDA $AFD7,Y             
AF87  A8       TAY                     
AF88  60       RTS                     

sub_AF89:  ; 1 xrefs: 9EC2
AF89  20 C1 AF JSR sub_AFC1            
AF8C  B9 E7 AF LDA $AFE7,Y             
AF8F  A8       TAY                     
AF90  60       RTS                     

sub_AF91:  ; 1 xrefs: 9EF4
AF91  20 CC AF JSR sub_AFCC            
AF94  B9 D7 AF LDA $AFD7,Y             
AF97  A8       TAY                     
AF98  60       RTS                     

sub_AF99:  ; 1 xrefs: 9EEA
AF99  20 CC AF JSR sub_AFCC            
AF9C  B9 E7 AF LDA $AFE7,Y             
AF9F  A8       TAY                     
AFA0  60       RTS                     

sub_AFA1:  ; 1 xrefs: 9F1D
AFA1  20 CC AF JSR sub_AFCC            
AFA4  B9 F7 AF LDA $AFF7,Y             
AFA7  A8       TAY                     
AFA8  60       RTS                     

sub_AFA9:  ; 1 xrefs: 9F13
AFA9  20 CC AF JSR sub_AFCC            
AFAC  B9 07 B0 LDA $B007,Y             
AFAF  A8       TAY                     
AFB0  60       RTS                     

loc_AFB1:  ; 0 xrefs: 
AFB1  20 C1 AF JSR sub_AFC1            
AFB4  B9 07 B0 LDA $B007,Y             
AFB7  A8       TAY                     
AFB8  60       RTS                     

sub_AFB9:  ; 1 xrefs: 9F27
AFB9  20 C1 AF JSR sub_AFC1            
AFBC  B9 F7 AF LDA $AFF7,Y             
AFBF  A8       TAY                     
AFC0  60       RTS                     

sub_AFC1:  ; 4 xrefs: AF81 AF89 AFB1 AFB9
AFC1  A4 97    LDY $97                 
AFC3  F0 03    BEQ loc_AFC8            
AFC5  18       CLC                     
AFC6  65 67    ADC $67                 

loc_AFC8:  ; 1 xrefs: AFC3
AFC8  29 0F    AND #$0F                
AFCA  A8       TAY                     
AFCB  60       RTS                     

sub_AFCC:  ; 4 xrefs: AF91 AF99 AFA1 AFA9
AFCC  A4 97    LDY $97                 
AFCE  D0 03    BNE loc_AFD3            
AFD0  18       CLC                     
AFD1  65 67    ADC $67                 

loc_AFD3:  ; 1 xrefs: AFCE
AFD3  29 0F    AND #$0F                
AFD5  A8       TAY                     
AFD6  60       RTS                     

; ==== data $AFD7..$B016  (64 bytes) ====
AFD7  FF FE FD FC FB FA F9 F8 07 06 05 04 03 02 01 00  |................
AFE7  00 FF FE FD FC FB FA F9 08 07 06 05 04 03 02 01  |................
AFF7  0F 0E 0D 0C 0B 0A 09 08 07 06 05 04 03 02 01 00  |................
B007  00 FF FE FD FC FB FA F9 F8 F7 F6 F5 F4 F3 F2 F1  |................

sub_B017:  ; 8 xrefs: 9496 9528 978E 9917 9B00 9CE1 9E09 A212
B017  A9 00    LDA #$00                
B019  8D 84 04 STA $0484               
B01C  4C 3B B0 JMP loc_B03B            

sub_B01F:  ; 3 xrefs: 94D3 9B8F A1E1
B01F  AD A2 05 LDA $05A2               
B022  F0 12    BEQ loc_B036            
B024  A5 9A    LDA $9A                 
B026  C9 02    CMP #$02                
B028  D0 05    BNE loc_B02F            
B02A  2C A2 05 BIT $05A2               
B02D  70 07    BVS loc_B036            

loc_B02F:  ; 1 xrefs: B028
B02F  AD 10 01 LDA $0110               
B032  4A       LSR A                   
B033  B0 01    BCS loc_B036            
B035  60       RTS                     

sub_B036:  ; 5 xrefs: 9DBF A1DB B022 B02D B033
B036  CE 6E 04 DEC $046E               
B039  D0 35    BNE loc_B070            

loc_B03B:  ; 1 xrefs: B01C
B03B  B9 72 B0 LDA $B072,Y             
B03E  85 08    STA $08                 
B040  B9 8A B0 LDA $B08A,Y             
B043  85 09    STA $09                 
B045  AC 84 04 LDY $0484               
B048  C8       INY                     
B049  B1 08    LDA ($08),Y             
B04B  C9 FD    CMP #$FD                
B04D  90 14    BCC loc_B063            
B04F  F0 06    BEQ loc_B057            
B051  C9 FE    CMP #$FE                
B053  F0 08    BEQ loc_B05D            
B055  D0 08    BNE loc_B05F            

loc_B057:  ; 1 xrefs: B04F
B057  C8       INY                     
B058  B1 08    LDA ($08),Y             
B05A  8D 42 04 STA $0442               

loc_B05D:  ; 1 xrefs: B053
B05D  38       SEC                     
B05E  60       RTS                     

loc_B05F:  ; 1 xrefs: B055
B05F  A0 01    LDY #$01                
B061  B1 08    LDA ($08),Y             

loc_B063:  ; 1 xrefs: B04D
B063  8D 42 04 STA $0442               
B066  8C 84 04 STY $0484               
B069  A0 00    LDY #$00                
B06B  B1 08    LDA ($08),Y             
B06D  8D 6E 04 STA $046E               

loc_B070:  ; 1 xrefs: B039
B070  18       CLC                     
B071  60       RTS                     

; ==== data $B072..$B115  (164 bytes) ====
B072  A2 AC B2 B6 BC C0 C4 C8 CC D0 D6 DC E2 E8 ED F3  |................
B082  DC DC F9 FE 03 08 0D 12 B0 B0 B0 B0 B0 B0 B0 B0  |................
B092  B0 B0 B0 B0 B0 B0 B0 B0 B0 B0 B0 B0 B1 B1 B1 B1  |................
B0A2  06 26 25 25 25 26 27 27 27 FF 0A 06 07 08 05 FF  |.&%%%&'''.......
B0B2  08 1A 1B FF 08 2C 2D 2E 2D FF 0C 3C FD 2E 0C 3C  |.....,-.-..<...<
B0C2  FD 25 04 1F 20 FF 04 21 22 FF 04 23 24 FF 08 36  |.%.. ..!"..#$..6
B0D2  37 38 37 FF 08 39 3A 3B 3A FF 04 01 02 03 FD 11  |787..9:;:.......
B0E2  04 0A 0B 0C FD 09 06 1C 1D FD 1A 04 0E 0F 10 FD  |................
B0F2  11 04 13 14 15 FD 11 06 28 29 FD 26 06 2A 2B FD  |........().&.*+.
B102  26 06 30 31 FD 2F 06 32 33 FD 2F 06 34 35 FD 2F  |&.01./.23./.45./
B112  08 09 FD 17                                      |....

sub_B116:  ; 5 xrefs: B151 B1AC B205 B23C B296
B116  BA       TSX                     
B117  BD 03 01 LDA $0103,X             
B11A  85 00    STA $00                 
B11C  BD 04 01 LDA $0104,X             
B11F  85 01    STA $01                 
B121  98       TYA                     
B122  18       CLC                     
B123  65 00    ADC $00                 
B125  9D 03 01 STA $0103,X             
B128  A9 00    LDA #$00                
B12A  65 01    ADC $01                 
B12C  9D 04 01 STA $0104,X             
B12F  60       RTS                     

sub_B130:  ; 3 xrefs: B154 B1AF B208
B130  A0 01    LDY #$01                
B132  B1 00    LDA ($00),Y             
B134  AA       TAX                     
B135  C8       INY                     
B136  B1 00    LDA ($00),Y             
B138  60       RTS                     

sub_B139:  ; 2 xrefs: B23F B299
B139  A0 01    LDY #$01                
B13B  B1 00    LDA ($00),Y             
B13D  85 03    STA $03                 
B13F  C8       INY                     
B140  B1 00    LDA ($00),Y             
B142  85 02    STA $02                 
B144  C8       INY                     
B145  B1 00    LDA ($00),Y             
B147  85 05    STA $05                 
B149  C8       INY                     
B14A  B1 00    LDA ($00),Y             
B14C  85 04    STA $04                 
B14E  60       RTS                     

sub_B14F:  ; 2 xrefs: 91E2 91EA
B14F  A0 02    LDY #$02                
B151  20 16 B1 JSR sub_B116            
B154  20 30 B1 JSR sub_B130            
B157  86 00    STX $00                 
B159  4C 8E B1 JMP sub_B18E            

sub_B15C:  ; 3 xrefs: 90F4 96EF A063
B15C  AD CE 05 LDA $05CE               
B15F  AE E4 05 LDX $05E4               
B162  4C 6D B1 JMP loc_B16D            

; ==== data $B165..$B16C  (8 bytes) ====
B165  A0 02 20 16 B1 20 30 B1                          |.. .. 0.

loc_B16D:  ; 1 xrefs: B162
B16D  86 00    STX $00                 
B16F  AC A2 05 LDY $05A2               
B172  F0 1A    BEQ loc_B18E            
B174  A4 9A    LDY $9A                 
B176  C0 02    CPY #$02                
B178  D0 05    BNE loc_B17F            
B17A  2C A2 05 BIT $05A2               
B17D  70 0F    BVS loc_B18E            

loc_B17F:  ; 1 xrefs: B178
B17F  E0 80    CPX #$80                
B181  66 00    ROR $00                 
B183  6A       ROR A                   
B184  2C A2 05 BIT $05A2               
B187  10 05    BPL loc_B18E            
B189  E0 80    CPX #$80                
B18B  66 00    ROR $00                 
B18D  6A       ROR A                   

sub_B18E:  ; 10 xrefs: 9A0B 9EFB 9F6F 9FB6 A13B A16D B159 B172 B17D B187
B18E  18       CLC                     
B18F  6D 1E 05 ADC $051E               
B192  8D 1E 05 STA $051E               
B195  A0 00    LDY #$00                
B197  A5 00    LDA $00                 
B199  10 01    BPL loc_B19C            
B19B  88       DEY                     

loc_B19C:  ; 1 xrefs: B199
B19C  6D 08 05 ADC $0508               
B19F  8D 08 05 STA $0508               
B1A2  98       TYA                     
B1A3  6D F2 04 ADC $04F2               
B1A6  8D F2 04 STA $04F2               
B1A9  60       RTS                     

sub_B1AA:  ; 13 xrefs: 910F 9176 950D 9592 9704 990D 9921 9A0E 9A57 9ADE ...
B1AA  A0 02    LDY #$02                
B1AC  20 16 B1 JSR sub_B116            
B1AF  20 30 B1 JSR sub_B130            
B1B2  86 00    STX $00                 
B1B4  4C DE B1 JMP loc_B1DE            

sub_B1B7:  ; 4 xrefs: 941F 94EE 9DAB A050
B1B7  AD FA 05 LDA $05FA               
B1BA  AE 10 06 LDX $0610               
B1BD  4C C8 B1 JMP loc_B1C8            

; ==== data $B1C0..$B1C7  (8 bytes) ====
B1C0  A0 02 20 16 B1 20 30 B1                          |.. .. 0.

loc_B1C8:  ; 1 xrefs: B1BD
B1C8  86 00    STX $00                 
B1CA  AC A2 05 LDY $05A2               
B1CD  F0 0F    BEQ loc_B1DE            
B1CF  E0 80    CPX #$80                
B1D1  66 00    ROR $00                 
B1D3  6A       ROR A                   
B1D4  2C A2 05 BIT $05A2               
B1D7  10 05    BPL loc_B1DE            
B1D9  E0 80    CPX #$80                
B1DB  66 00    ROR $00                 
B1DD  6A       ROR A                   

loc_B1DE:  ; 7 xrefs: 9EDC 9F87 A162 A177 B1B4 B1CD B1D7
B1DE  18       CLC                     
B1DF  6D DC 04 ADC $04DC               
B1E2  8D DC 04 STA $04DC               
B1E5  A0 00    LDY #$00                
B1E7  A5 00    LDA $00                 
B1E9  10 01    BPL loc_B1EC            
B1EB  88       DEY                     

loc_B1EC:  ; 1 xrefs: B1E9
B1EC  6D C6 04 ADC $04C6               
B1EF  8D C6 04 STA $04C6               
B1F2  98       TYA                     
B1F3  6D B0 04 ADC $04B0               
B1F6  8D B0 04 STA $04B0               
B1F9  60       RTS                     

sub_B1FA:  ; 6 xrefs: 90D0 91C2 9BEC 9D3C A085 A101
B1FA  AD 76 05 LDA $0576               
B1FD  AE 60 05 LDX $0560               
B200  4C 0B B2 JMP sub_B20B            

sub_B203:  ; 4 xrefs: B47C B488 B48E B49A
B203  A0 02    LDY #$02                
B205  20 16 B1 JSR sub_B116            
B208  20 30 B1 JSR sub_B130            

sub_B20B:  ; 2 xrefs: 9663 B200
B20B  18       CLC                     
B20C  6D CE 05 ADC $05CE               
B20F  8D CE 05 STA $05CE               
B212  8A       TXA                     
B213  6D E4 05 ADC $05E4               
B216  8D E4 05 STA $05E4               
B219  60       RTS                     

sub_B21A:  ; 4 xrefs: 9244 94EB 9C7E 9D7A
B21A  AD 4A 05 LDA $054A               
B21D  AE 34 05 LDX $0534               
B220  4C 2B B2 JMP loc_B22B            

; ==== data $B223..$B22A  (8 bytes) ====
B223  A0 02 20 16 B1 20 30 B1                          |.. .. 0.

loc_B22B:  ; 1 xrefs: B220
B22B  18       CLC                     
B22C  6D FA 05 ADC $05FA               
B22F  8D FA 05 STA $05FA               
B232  8A       TXA                     
B233  6D 10 06 ADC $0610               
B236  8D 10 06 STA $0610               
B239  60       RTS                     

sub_B23A:  ; 10 xrefs: 9146 9150 A074 A07E A0B6 A0C0 A0CA A0E6 A0F0 A0FA
B23A  A0 04    LDY #$04                
B23C  20 16 B1 JSR sub_B116            
B23F  20 39 B1 JSR sub_B139            

sub_B242:  ; 2 xrefs: 9027 9BE9
B242  A5 04    LDA $04                 
B244  18       CLC                     
B245  6D 76 05 ADC $0576               
B248  8D 76 05 STA $0576               
B24B  A5 05    LDA $05                 
B24D  6D 60 05 ADC $0560               
B250  8D 60 05 STA $0560               
B253  30 1A    BMI loc_B26F            
B255  24 05    BIT $05                 
B257  30 11    BMI loc_B26A            
B259  24 03    BIT $03                 
B25B  30 2C    BMI loc_B289            

loc_B25D:  ; 1 xrefs: B286
B25D  A5 02    LDA $02                 
B25F  CD 76 05 CMP $0576               
B262  A5 03    LDA $03                 
B264  ED 60 05 SBC $0560               
B267  90 20    BCC loc_B289            
B269  60       RTS                     

loc_B26A:  ; 1 xrefs: B257
B26A  24 03    BIT $03                 
B26C  10 09    BPL loc_B277            
B26E  60       RTS                     

loc_B26F:  ; 1 xrefs: B253
B26F  24 05    BIT $05                 
B271  10 11    BPL loc_B284            
B273  24 03    BIT $03                 
B275  10 12    BPL loc_B289            

loc_B277:  ; 1 xrefs: B26C
B277  AD 76 05 LDA $0576               
B27A  C5 02    CMP $02                 
B27C  AD 60 05 LDA $0560               
B27F  E5 03    SBC $03                 
B281  90 06    BCC loc_B289            
B283  60       RTS                     

loc_B284:  ; 1 xrefs: B271
B284  24 03    BIT $03                 
B286  30 D5    BMI loc_B25D            
B288  60       RTS                     

loc_B289:  ; 4 xrefs: B25B B267 B275 B281
B289  A5 02    LDA $02                 
B28B  8D 76 05 STA $0576               
B28E  A5 03    LDA $03                 
B290  8D 60 05 STA $0560               
B293  60       RTS                     

sub_B294:  ; 6 xrefs: 9D55 9D5F 9D69 9D73 B4C6 B4CE
B294  A0 04    LDY #$04                
B296  20 16 B1 JSR sub_B116            
B299  20 39 B1 JSR sub_B139            

loc_B29C:  ; 1 xrefs: 9C92
B29C  A5 04    LDA $04                 
B29E  18       CLC                     
B29F  6D 4A 05 ADC $054A               
B2A2  8D 4A 05 STA $054A               
B2A5  A5 05    LDA $05                 
B2A7  6D 34 05 ADC $0534               
B2AA  8D 34 05 STA $0534               
B2AD  30 1A    BMI loc_B2C9            
B2AF  24 05    BIT $05                 
B2B1  30 11    BMI loc_B2C4            
B2B3  24 03    BIT $03                 
B2B5  30 2C    BMI loc_B2E3            

loc_B2B7:  ; 1 xrefs: B2E0
B2B7  A5 02    LDA $02                 
B2B9  CD 4A 05 CMP $054A               
B2BC  A5 03    LDA $03                 
B2BE  ED 34 05 SBC $0534               
B2C1  90 20    BCC loc_B2E3            
B2C3  60       RTS                     

loc_B2C4:  ; 1 xrefs: B2B1
B2C4  24 03    BIT $03                 
B2C6  10 09    BPL loc_B2D1            
B2C8  60       RTS                     

loc_B2C9:  ; 1 xrefs: B2AD
B2C9  24 05    BIT $05                 
B2CB  10 11    BPL loc_B2DE            
B2CD  24 03    BIT $03                 
B2CF  10 12    BPL loc_B2E3            

loc_B2D1:  ; 1 xrefs: B2C6
B2D1  AD 4A 05 LDA $054A               
B2D4  C5 02    CMP $02                 
B2D6  AD 34 05 LDA $0534               
B2D9  E5 03    SBC $03                 
B2DB  90 06    BCC loc_B2E3            
B2DD  60       RTS                     

loc_B2DE:  ; 1 xrefs: B2CB
B2DE  24 03    BIT $03                 
B2E0  30 D5    BMI loc_B2B7            
B2E2  60       RTS                     

loc_B2E3:  ; 4 xrefs: B2B5 B2C1 B2CF B2DB
B2E3  A5 02    LDA $02                 
B2E5  8D 4A 05 STA $054A               
B2E8  A5 03    LDA $03                 
B2EA  8D 34 05 STA $0534               
B2ED  60       RTS                     

sub_B2EE:  ; 6 xrefs: 9491 9523 9782 9912 9A6E A019
B2EE  20 FA B2 JSR sub_B2FA            

sub_B2F1:  ; 2 xrefs: 90DA A068
B2F1  A9 00    LDA #$00                
B2F3  8D 60 05 STA $0560               
B2F6  8D 76 05 STA $0576               
B2F9  60       RTS                     

sub_B2FA:  ; 7 xrefs: 92BD 9434 950A 9B27 9DA2 A053 B2EE
B2FA  A9 00    LDA #$00                
B2FC  8D 34 05 STA $0534               
B2FF  8D 4A 05 STA $054A               
B302  60       RTS                     

sub_B303:  ; 1 xrefs: 90CA
B303  A9 00    LDA #$00                
B305  38       SEC                     
B306  ED 4A 05 SBC $054A               
B309  8D 4A 05 STA $054A               
B30C  A9 00    LDA #$00                
B30E  ED 34 05 SBC $0534               
B311  8D 34 05 STA $0534               
B314  60       RTS                     

loc_B315:  ; 2 xrefs: B31B B323
B315  60       RTS                     

sub_B316:  ; 1 xrefs: 8E1D
B316  AD 8C 05 LDA $058C               
B319  C9 04    CMP #$04                
B31B  90 F8    BCC loc_B315            
B31D  AC 42 04 LDY $0442               
B320  B9 D6 B4 LDA $B4D6,Y             
B323  F0 F0    BEQ loc_B315            
B325  A8       TAY                     
B326  B9 14 B5 LDA $B514,Y             
B329  85 08    STA $08                 
B32B  B9 1A B5 LDA $B51A,Y             
B32E  85 09    STA $09                 
B330  A9 00    LDA #$00                
B332  85 0A    STA $0A                 
B334  A9 07    LDA #$07                
B336  85 0B    STA $0B                 

loc_B338:  ; 1 xrefs: B388
B338  A4 0A    LDY $0A                 
B33A  B1 08    LDA ($08),Y             
B33C  AA       TAX                     
B33D  C8       INY                     
B33E  B1 08    LDA ($08),Y             
B340  C8       INY                     
B341  84 0A    STY $0A                 
B343  A8       TAY                     
B344  8A       TXA                     
B345  20 A6 AB JSR sub_ABA6            
B348  A5 87    LDA $87                 
B34A  C9 08    CMP #$08                
B34C  F0 15    BEQ loc_B363            
B34E  C9 0A    CMP #$0A                
B350  F0 1E    BEQ loc_B370            
B352  C9 06    CMP #$06                
B354  D0 28    BNE loc_B37E            
B356  A5 11    LDA $11                 
B358  38       SEC                     
B359  E9 04    SBC #$04                
B35B  C5 29    CMP $29                 
B35D  90 1F    BCC loc_B37E            
B35F  A9 02    LDA #$02                
B361  D0 1E    BNE loc_B381            

loc_B363:  ; 1 xrefs: B34C
B363  A5 29    LDA $29                 
B365  18       CLC                     
B366  69 1F    ADC #$1F                
B368  C5 11    CMP $11                 
B36A  90 12    BCC loc_B37E            
B36C  A9 02    LDA #$02                
B36E  D0 11    BNE loc_B381            

loc_B370:  ; 1 xrefs: B350
B370  A5 11    LDA $11                 
B372  C9 98    CMP #$98                
B374  B0 08    BCS loc_B37E            
B376  C5 29    CMP $29                 
B378  90 04    BCC loc_B37E            
B37A  A9 04    LDA #$04                
B37C  D0 03    BNE loc_B381            

loc_B37E:  ; 5 xrefs: B354 B35D B36A B374 B378
B37E  20 85 C8 JSR $C885               

loc_B381:  ; 3 xrefs: B361 B36E B37C
B381  A4 0B    LDY $0B                 
B383  99 00 00 STA $0000,Y             
B386  C6 0B    DEC $0B                 
B388  10 AE    BPL loc_B338            
B38A  A5 00    LDA $00                 
B38C  C9 02    CMP #$02                
B38E  F0 65    BEQ loc_B3F5            
B390  C9 04    CMP #$04                
B392  D0 08    BNE loc_B39C            
B394  A9 40    LDA #$40                
B396  8D A2 05 STA $05A2               
B399  20 75 B6 JSR sub_B675            

loc_B39C:  ; 1 xrefs: B392
B39C  A5 01    LDA $01                 
B39E  C9 02    CMP #$02                
B3A0  F0 53    BEQ loc_B3F5            
B3A2  A5 02    LDA $02                 
B3A4  C9 04    CMP #$04                
B3A6  F0 53    BEQ loc_B3FB            
B3A8  C9 02    CMP #$02                
B3AA  F0 49    BEQ loc_B3F5            
B3AC  A5 03    LDA $03                 
B3AE  C9 04    CMP #$04                
B3B0  F0 49    BEQ loc_B3FB            
B3B2  C9 02    CMP #$02                
B3B4  F0 3F    BEQ loc_B3F5            

loc_B3B6:  ; 1 xrefs: B3FE
B3B6  A5 04    LDA $04                 
B3B8  C9 05    CMP #$05                
B3BA  F0 45    BEQ loc_B401            
B3BC  C9 06    CMP #$06                
B3BE  F0 5C    BEQ loc_B41C            
B3C0  C9 02    CMP #$02                
B3C2  F0 31    BEQ loc_B3F5            
B3C4  A5 05    LDA $05                 
B3C6  C9 05    CMP #$05                
B3C8  F0 4C    BEQ loc_B416            
B3CA  C9 06    CMP #$06                
B3CC  F0 42    BEQ loc_B410            
B3CE  C9 02    CMP #$02                
B3D0  F0 23    BEQ loc_B3F5            

loc_B3D2:  ; 2 xrefs: B413 B419
B3D2  A5 06    LDA $06                 
B3D4  C9 87    CMP #$87                
B3D6  F0 55    BEQ loc_B42D            
B3D8  C9 88    CMP #$88                
B3DA  F0 5E    BEQ loc_B43A            
B3DC  C9 03    CMP #$03                
B3DE  F0 67    BEQ loc_B447            
B3E0  A5 07    LDA $07                 
B3E2  C9 88    CMP #$88                
B3E4  D0 03    BNE loc_B3E9            
B3E6  4C 7C B4 JMP loc_B47C            

loc_B3E9:  ; 1 xrefs: B3E4
B3E9  C9 87    CMP #$87                
B3EB  D0 03    BNE loc_B3F0            
B3ED  4C 8E B4 JMP loc_B48E            

loc_B3F0:  ; 1 xrefs: B3EB
B3F0  C9 03    CMP #$03                
B3F2  F0 58    BEQ loc_B44C            
B3F4  60       RTS                     

loc_B3F5:  ; 8 xrefs: B38E B3A0 B3AA B3B4 B3C2 B3D0 B405 B420
B3F5  A9 00    LDA #$00                
B3F7  8D 9A 04 STA $049A               
B3FA  60       RTS                     

loc_B3FB:  ; 2 xrefs: B3A6 B3B0
B3FB  20 AF B4 JSR sub_B4AF            
B3FE  4C B6 B3 JMP loc_B3B6            

loc_B401:  ; 1 xrefs: B3BA
B401  A5 05    LDA $05                 
B403  C9 02    CMP #$02                
B405  F0 EE    BEQ loc_B3F5            
B407  C9 06    CMP #$06                
B409  D0 0B    BNE loc_B416            
B40B  20 A0 B4 JSR sub_B4A0            
B40E  90 06    BCC loc_B416            

loc_B410:  ; 3 xrefs: B3CC B424 B429
B410  20 82 B4 JSR sub_B482            
B413  4C D2 B3 JMP loc_B3D2            

loc_B416:  ; 4 xrefs: B3C8 B409 B40E B42B
B416  20 94 B4 JSR sub_B494            
B419  4C D2 B3 JMP loc_B3D2            

loc_B41C:  ; 1 xrefs: B3BE
B41C  A5 05    LDA $05                 
B41E  C9 02    CMP #$02                
B420  F0 D3    BEQ loc_B3F5            
B422  C9 05    CMP #$05                
B424  D0 EA    BNE loc_B410            
B426  20 A0 B4 JSR sub_B4A0            
B429  90 E5    BCC loc_B410            
B42B  B0 E9    BCS loc_B416            

loc_B42D:  ; 1 xrefs: B3D6
B42D  A5 07    LDA $07                 
B42F  C9 88    CMP #$88                
B431  D0 5B    BNE loc_B48E            
B433  20 A0 B4 JSR sub_B4A0            
B436  90 56    BCC loc_B48E            
B438  B0 42    BCS loc_B47C            

loc_B43A:  ; 1 xrefs: B3DA
B43A  A5 07    LDA $07                 
B43C  C9 87    CMP #$87                
B43E  D0 3C    BNE loc_B47C            
B440  20 A0 B4 JSR sub_B4A0            
B443  90 37    BCC loc_B47C            
B445  B0 47    BCS loc_B48E            

loc_B447:  ; 1 xrefs: B3DE
B447  A4 07    LDY $07                 
B449  4C 4E B4 JMP loc_B44E            

loc_B44C:  ; 1 xrefs: B3F2
B44C  A4 06    LDY $06                 

loc_B44E:  ; 1 xrefs: B449
B44E  A9 80    LDA #$80                
B450  8D A2 05 STA $05A2               
B453  AD 16 04 LDA $0416               
B456  29 60    AND #$60                
B458  D0 21    BNE loc_B47B            
B45A  98       TYA                     
B45B  30 16    BMI loc_B473            
B45D  2C 68 06 BIT $0668               
B460  70 05    BVS loc_B467            
B462  20 AA B1 JSR sub_B1AA            
B465  00 20    BRK #$20                

loc_B467:  ; 1 xrefs: B460
B467  AD C6 04 LDA $04C6               
B46A  C9 D0    CMP #$D0                
B46C  90 05    BCC loc_B473            
B46E  A9 00    LDA #$00                
B470  8D 9A 04 STA $049A               

loc_B473:  ; 2 xrefs: B45B B46C
B473  A9 40    LDA #$40                
B475  0D 68 06 ORA $0668               
B478  8D 68 06 STA $0668               

loc_B47B:  ; 1 xrefs: B458
B47B  60       RTS                     

loc_B47C:  ; 4 xrefs: B3E6 B438 B43E B443
B47C  20 03 B2 JSR sub_B203            
B47F  FF 80 60 ISC $6080,X             

sub_B482:  ; 1 xrefs: B410
B482  A4 9A    LDY $9A                 
B484  C0 02    CPY #$02                
B486  F0 05    BEQ loc_B48D            
B488  20 03 B2 JSR sub_B203            
B48B  FF 40 60 ISC $6040,X             

loc_B48E:  ; 4 xrefs: B3ED B431 B436 B445
B48E  20 03 B2 JSR sub_B203            
B491  00 80    BRK #$80                

; ==== data $B493..$B493  (1 bytes) ====
B493  60                                               |`

sub_B494:  ; 1 xrefs: B416
B494  A4 9A    LDY $9A                 
B496  C0 02    CPY #$02                
B498  F0 05    BEQ loc_B49F            
B49A  20 03 B2 JSR sub_B203            
B49D  00 C0    BRK #$C0                

loc_B49F:  ; 1 xrefs: B498
B49F  60       RTS                     

sub_B4A0:  ; 4 xrefs: B40B B426 B433 B440
B4A0  AD 08 05 LDA $0508               
B4A3  A4 97    LDY $97                 
B4A5  D0 03    BNE loc_B4AA            
B4A7  18       CLC                     
B4A8  65 67    ADC $67                 

loc_B4AA:  ; 1 xrefs: B4A5
B4AA  29 0F    AND #$0F                
B4AC  C9 08    CMP #$08                
B4AE  60       RTS                     

sub_B4AF:  ; 1 xrefs: B3FB
B4AF  A9 40    LDA #$40                
B4B1  8D A2 05 STA $05A2               
B4B4  AD 16 04 LDA $0416               
B4B7  4A       LSR A                   
B4B8  90 1B    BCC loc_B4D5            
B4BA  AD 8C 05 LDA $058C               
B4BD  C9 0E    CMP #$0E                
B4BF  F0 14    BEQ loc_B4D5            
B4C1  AD 34 05 LDA $0534               
B4C4  10 08    BPL loc_B4CE            
B4C6  20 94 B2 JSR sub_B294            
B4C9  FB 00 FF ISC $FF00,Y             
B4CC  D8       CLD                     
B4CD  60       RTS                     

loc_B4CE:  ; 1 xrefs: B4C4
B4CE  20 94 B2 JSR sub_B294            
B4D1  FB 00 FF ISC $FF00,Y             
B4D4  D6 60    DEC $60,X               
B4D6  00 01    BRK #$01                

; ==== data $B4D8..$B56F  (152 bytes) ====
B4D8  01 01 00 01 01 01 01 02 02 02 02 03 01 01 01 01  |................
B4E8  01 01 01 01 00 00 01 01 00 00 00 00 00 01 01 01  |................
B4F8  01 01 01 05 04 05 05 05 05 05 01 01 01 01 01 01  |................
B508  01 01 01 01 01 01 01 01 01 01 00 00 20 20 30 40  |............  0@
B518  50 60 B5 B5 B5 B5 B5 B5 FA 01 05 01 FA FC 05 FC  |P`..............
B528  FA F2 05 F2 FA E2 05 E2 FA 01 05 01 FA FC 05 FC  |................
B538  FA F5 05 F5 FA EA 05 EA FA 01 05 01 FA FC 05 FC  |................
B548  FA F9 05 F9 FA F2 05 F2 FD FF 02 FF FD FC 02 FC  |................
B558  FD F2 02 F2 FD E2 02 E2 FA FE 05 FE FA FC 05 FC  |................
B568  FA F2 05 F2 FA E2 05 E2                          |........

sub_B570:  ; 1 xrefs: 8E20
B570  A4 87    LDY $87                 
B572  B9 7F B5 LDA $B57F,Y             
B575  85 08    STA $08                 
B577  B9 8F B5 LDA $B58F,Y             
B57A  85 09    STA $09                 
B57C  6C 08 00 JMP ($0008)             

; ==== data $B57F..$B59E  (32 bytes) ====
B57F  9F 9F 9F 9F 9F E7 9F E6 9F E7 9F 9F 9F 9F 9F 9F  |................
B58F  B5 B5 B5 B5 B5 B5 B5 B5 B5 B5 B5 B5 B5 B5 B5 B5  |................

loc_B59F:  ; 0 xrefs: 
B59F  A5 2E    LDA $2E                 
B5A1  C9 03    CMP #$03                
B5A3  F0 21    BEQ loc_B5C6            
B5A5  C9 04    CMP #$04                
B5A7  D0 3D    BNE loc_B5E6            
B5A9  AD 08 05 LDA $0508               
B5AC  C9 12    CMP #$12                
B5AE  B0 36    BCS loc_B5E6            
B5B0  AD 68 06 LDA $0668               
B5B3  09 20    ORA #$20                
B5B5  8D 68 06 STA $0668               
B5B8  A9 01    LDA #$01                
B5BA  8D 3C 06 STA $063C               
B5BD  AD 08 05 LDA $0508               
B5C0  C9 0A    CMP #$0A                
B5C2  B0 22    BCS loc_B5E6            
B5C4  90 1B    BCC loc_B5E1            

loc_B5C6:  ; 1 xrefs: B5A3
B5C6  AD 08 05 LDA $0508               
B5C9  C9 EF    CMP #$EF                
B5CB  90 19    BCC loc_B5E6            
B5CD  AD 68 06 LDA $0668               
B5D0  09 10    ORA #$10                
B5D2  8D 68 06 STA $0668               
B5D5  A9 FF    LDA #$FF                
B5D7  8D 3C 06 STA $063C               
B5DA  AD 08 05 LDA $0508               
B5DD  C9 F7    CMP #$F7                
B5DF  90 05    BCC loc_B5E6            

loc_B5E1:  ; 1 xrefs: B5C4
B5E1  A9 00    LDA #$00                
B5E3  8D 9A 04 STA $049A               

loc_B5E6:  ; 5 xrefs: B5A7 B5AE B5C2 B5CB B5DF
B5E6  60       RTS                     

; ==== data $B5E7..$B634  (78 bytes) ====
B5E7  A5 29 38 E9 01 85 08 18 69 02 85 09 AC 1F 01 EE  |.)8.....i.......
B5F7  1F 01 A9 00 99 20 01 A9 FF 99 30 01 A5 09 99 40  |..... ....0....@
B607  01 18 69 28 99 50 01 AD C6 04 C5 08 90 1F AD 16  |..i(.P..........
B617  04 29 60 D0 18 AD C6 04 38 E5 09 49 FF 8D 52 06  |.)`.....8..I..R.
B627  09 00 10 09 C9 FA B0 05 A9 00 8D 9A 04 60        |.............`

sub_B635:  ; 1 xrefs: 8FF8
B635  20 67 B6 JSR sub_B667            
B638  30 2C    BMI loc_B666            
B63A  A0 FC    LDY #$FC                
B63C  AD 2C 04 LDA $042C               
B63F  29 40    AND #$40                
B641  F0 02    BEQ loc_B645            
B643  A0 04    LDY #$04                

loc_B645:  ; 1 xrefs: B641
B645  98       TYA                     
B646  A0 FC    LDY #$FC                
B648  20 A6 AB JSR sub_ABA6            
B64B  A5 11    LDA $11                 
B64D  9D C7 04 STA $04C7,X             
B650  A5 13    LDA $13                 
B652  9D 09 05 STA $0509,X             
B655  20 85 C8 JSR $C885               
B658  09 00    ORA #$00                
B65A  D0 0A    BNE loc_B666            
B65C  A9 4D    LDA #$4D                
B65E  9D 43 04 STA $0443,X             
B661  A9 08    LDA #$08                
B663  9D CF 05 STA $05CF,X             

loc_B666:  ; 2 xrefs: B638 B65A
B666  60       RTS                     

sub_B667:  ; 2 xrefs: B635 B67A
B667  A2 02    LDX #$02                

loc_B669:  ; 1 xrefs: B672
B669  BD 43 04 LDA $0443,X             
B66C  1D 01 04 ORA $0401,X             
B66F  F0 03    BEQ loc_B674            
B671  CA       DEX                     
B672  10 F5    BPL loc_B669            

loc_B674:  ; 1 xrefs: B66F
B674  60       RTS                     

sub_B675:  ; 1 xrefs: B399
B675  AD 10 01 LDA $0110               
B678  D0 23    BNE loc_B69D            
B67A  20 67 B6 JSR sub_B667            
B67D  30 1E    BMI loc_B69D            
B67F  A9 4F    LDA #$4F                
B681  9D 43 04 STA $0443,X             
B684  AD 08 05 LDA $0508               
B687  9D 09 05 STA $0509,X             
B68A  AD C6 04 LDA $04C6               
B68D  A0 0D    LDY #$0D                
B68F  18       CLC                     
B690  71 08    ADC ($08),Y             
B692  9D C7 04 STA $04C7,X             
B695  AD B0 04 LDA $04B0               
B698  69 FF    ADC #$FF                
B69A  9D B1 04 STA $04B1,X             

loc_B69D:  ; 2 xrefs: B678 B67D
B69D  60       RTS                     

sub_B69E:  ; 1 xrefs: 8E2F
B69E  A2 01    LDX #$01                

loc_B6A0:  ; 1 xrefs: B6B7
B6A0  BD 00 04 LDA $0400,X             
B6A3  D0 0F    BNE loc_B6B4            
B6A5  BD 42 04 LDA $0442,X             
B6A8  C9 4D    CMP #$4D                
B6AA  F0 0E    BEQ loc_B6BA            
B6AC  C9 4E    CMP #$4E                
B6AE  F0 24    BEQ loc_B6D4            
B6B0  C9 4F    CMP #$4F                
B6B2  F0 35    BEQ loc_B6E9            

loc_B6B4:  ; 8 xrefs: B6A3 B6C7 B6D1 B6E1 B6E6 B701 B759 B75F
B6B4  E8       INX                     
B6B5  E0 06    CPX #$06                
B6B7  D0 E7    BNE loc_B6A0            
B6B9  60       RTS                     

loc_B6BA:  ; 1 xrefs: B6AA
B6BA  AD 16 04 LDA $0416               
B6BD  29 10    AND #$10                
B6BF  F0 22    BEQ loc_B6E3            
B6C1  20 62 B7 JSR sub_B762            
B6C4  DE CE 05 DEC $05CE,X             
B6C7  D0 EB    BNE loc_B6B4            
B6C9  FE 42 04 INC $0442,X             
B6CC  A9 08    LDA #$08                
B6CE  9D CE 05 STA $05CE,X             
B6D1  4C B4 B6 JMP loc_B6B4            

loc_B6D4:  ; 1 xrefs: B6AE
B6D4  AD 16 04 LDA $0416               
B6D7  29 10    AND #$10                
B6D9  F0 08    BEQ loc_B6E3            
B6DB  20 62 B7 JSR sub_B762            
B6DE  DE CE 05 DEC $05CE,X             
B6E1  D0 D1    BNE loc_B6B4            

loc_B6E3:  ; 2 xrefs: B6BF B6D9
B6E3  20 10 C8 JSR $C810               
B6E6  4C B4 B6 JMP loc_B6B4            

loc_B6E9:  ; 1 xrefs: B6B2
B6E9  20 62 B7 JSR sub_B762            
B6EC  A9 C0    LDA #$C0                
B6EE  A0 FF    LDY #$FF                
B6F0  20 2D C9 JSR $C92D               
B6F3  BD F2 04 LDA $04F2,X             
B6F6  1D B0 04 ORA $04B0,X             
B6F9  D0 61    BNE loc_B75C            
B6FB  8A       TXA                     
B6FC  4D 10 01 EOR $0110               
B6FF  29 0F    AND #$0F                
B701  D0 B1    BNE loc_B6B4            
B703  AD F2 04 LDA $04F2               
B706  85 08    STA $08                 
B708  AD 08 05 LDA $0508               
B70B  85 09    STA $09                 
B70D  AD B0 04 LDA $04B0               
B710  85 0A    STA $0A                 
B712  AD C6 04 LDA $04C6               
B715  85 0B    STA $0B                 
B717  BD 08 05 LDA $0508,X             
B71A  8D 08 05 STA $0508               
B71D  BD C6 04 LDA $04C6,X             
B720  8D C6 04 STA $04C6               
B723  A9 00    LDA #$00                
B725  8D B0 04 STA $04B0               
B728  8D F2 04 STA $04F2               
B72B  A0 FC    LDY #$FC                
B72D  20 A6 AB JSR sub_ABA6            
B730  A5 08    LDA $08                 
B732  8D F2 04 STA $04F2               
B735  A5 09    LDA $09                 
B737  8D 08 05 STA $0508               
B73A  A5 0A    LDA $0A                 
B73C  8D B0 04 STA $04B0               
B73F  A5 0B    LDA $0B                 
B741  8D C6 04 STA $04C6               
B744  A5 87    LDA $87                 
B746  C9 0A    CMP #$0A                
B748  D0 08    BNE loc_B752            
B74A  A5 11    LDA $11                 
B74C  C5 29    CMP $29                 
B74E  B0 09    BCS loc_B759            
B750  90 0A    BCC loc_B75C            

loc_B752:  ; 1 xrefs: B748
B752  20 85 C8 JSR $C885               
B755  C9 04    CMP #$04                
B757  D0 03    BNE loc_B75C            

loc_B759:  ; 1 xrefs: B74E
B759  4C B4 B6 JMP loc_B6B4            

loc_B75C:  ; 3 xrefs: B6F9 B750 B757
B75C  20 10 C8 JSR $C810               
B75F  4C B4 B6 JMP loc_B6B4            

sub_B762:  ; 3 xrefs: B6C1 B6DB B6E9
B762  A0 00    LDY #$00                
B764  A5 94    LDA $94                 
B766  10 01    BPL loc_B769            
B768  88       DEY                     

loc_B769:  ; 1 xrefs: B766
B769  84 00    STY $00                 
B76B  A5 97    LDA $97                 
B76D  F0 12    BEQ loc_B781            
B76F  BD C6 04 LDA $04C6,X             
B772  38       SEC                     
B773  E5 94    SBC $94                 
B775  9D C6 04 STA $04C6,X             
B778  BD B0 04 LDA $04B0,X             
B77B  E5 00    SBC $00                 
B77D  9D B0 04 STA $04B0,X             
B780  60       RTS                     

loc_B781:  ; 1 xrefs: B76D
B781  BD 08 05 LDA $0508,X             
B784  38       SEC                     
B785  E5 94    SBC $94                 
B787  9D 08 05 STA $0508,X             
B78A  BD F2 04 LDA $04F2,X             
B78D  E5 00    SBC $00                 
B78F  9D F2 04 STA $04F2,X             
B792  60       RTS                     

sub_B793:  ; 2 xrefs: B90D B91C
B793  85 08    STA $08                 
B795  84 09    STY $09                 
B797  18       CLC                     
B798  7D 08 05 ADC $0508,X             
B79B  85 11    STA $11                 
B79D  A9 00    LDA #$00                
B79F  7D F2 04 ADC $04F2,X             
B7A2  F0 06    BEQ loc_B7AA            
B7A4  30 41    BMI loc_B7E7            
B7A6  A9 FF    LDA #$FF                
B7A8  85 11    STA $11                 

loc_B7AA:  ; 1 xrefs: B7A2
B7AA  BD 08 05 LDA $0508,X             
B7AD  18       CLC                     
B7AE  E5 08    SBC $08                 
B7B0  85 10    STA $10                 
B7B2  BD F2 04 LDA $04F2,X             
B7B5  E9 00    SBC #$00                
B7B7  F0 06    BEQ loc_B7BF            
B7B9  10 2C    BPL loc_B7E7            
B7BB  A9 00    LDA #$00                
B7BD  85 10    STA $10                 

loc_B7BF:  ; 1 xrefs: B7B7
B7BF  BD C6 04 LDA $04C6,X             
B7C2  85 13    STA $13                 
B7C4  BD B0 04 LDA $04B0,X             
B7C7  F0 06    BEQ loc_B7CF            
B7C9  30 1C    BMI loc_B7E7            
B7CB  A9 FF    LDA #$FF                
B7CD  85 13    STA $13                 

loc_B7CF:  ; 1 xrefs: B7C7
B7CF  BD C6 04 LDA $04C6,X             
B7D2  18       CLC                     
B7D3  65 09    ADC $09                 
B7D5  85 12    STA $12                 
B7D7  BD B0 04 LDA $04B0,X             
B7DA  69 FF    ADC #$FF                
B7DC  F0 06    BEQ loc_B7E4            
B7DE  10 07    BPL loc_B7E7            
B7E0  A9 00    LDA #$00                
B7E2  85 12    STA $12                 

loc_B7E4:  ; 1 xrefs: B7DC
B7E4  A9 01    LDA #$01                
B7E6  60       RTS                     

loc_B7E7:  ; 4 xrefs: B7A4 B7B9 B7C9 B7DE
B7E7  A9 00    LDA #$00                
B7E9  60       RTS                     

loc_B7EA:  ; 1 xrefs: B987
B7EA  AC 1F 01 LDY $011F               
B7ED  A5 10    LDA $10                 
B7EF  99 20 01 STA $0120,Y             
B7F2  A5 11    LDA $11                 
B7F4  99 30 01 STA $0130,Y             
B7F7  A5 12    LDA $12                 
B7F9  99 40 01 STA $0140,Y             
B7FC  A5 13    LDA $13                 
B7FE  99 50 01 STA $0150,Y             
B801  EE 1F 01 INC $011F               
B804  60       RTS                     

; ==== data $B805..$B807  (3 bytes) ====
B805  20 2D B8                                         | -.

loc_B808:  ; 0 xrefs: 
B808  A9 01    LDA #$01                
B80A  8D 67 01 STA $0167               
B80D  AD 1C 01 LDA $011C               
B810  C5 09    CMP $09                 
B812  D0 0A    BNE loc_B81E            
B814  A5 08    LDA $08                 
B816  38       SEC                     
B817  ED 1C 01 SBC $011C               
B81A  8D 3C 06 STA $063C               
B81D  60       RTS                     

loc_B81E:  ; 1 xrefs: B812
B81E  A5 09    LDA $09                 
B820  38       SEC                     
B821  ED 1B 01 SBC $011B               
B824  8D 3C 06 STA $063C               
B827  60       RTS                     

loc_B828:  ; 0 xrefs: 
B828  A9 01    LDA #$01                
B82A  8D 67 01 STA $0167               

loc_B82D:  ; 0 xrefs: 
B82D  AD 1E 01 LDA $011E               
B830  C5 0B    CMP $0B                 
B832  D0 0A    BNE loc_B83E            
B834  A5 0A    LDA $0A                 
B836  38       SEC                     
B837  ED 1E 01 SBC $011E               
B83A  8D 52 06 STA $0652               
B83D  60       RTS                     

loc_B83E:  ; 1 xrefs: B832
B83E  A5 0B    LDA $0B                 
B840  38       SEC                     
B841  ED 1D 01 SBC $011D               
B844  8D 52 06 STA $0652               
B847  60       RTS                     

loc_B848:  ; 0 xrefs: 
B848  BD 08 05 LDA $0508,X             
B84B  38       SEC                     
B84C  ED 60 01 SBC $0160               
B84F  8D 3C 06 STA $063C               
B852  BD C6 04 LDA $04C6,X             
B855  38       SEC                     
B856  ED 61 01 SBC $0161               
B859  8D 52 06 STA $0652               
B85C  A9 01    LDA #$01                
B85E  8D 67 01 STA $0167               
B861  60       RTS                     

loc_B862:  ; 4 xrefs: B86C B87D B890 B8A1
B862  A9 00    LDA #$00                
B864  85 14    STA $14                 
B866  60       RTS                     

sub_B867:  ; 2 xrefs: B912 B932
B867  A5 11    LDA $11                 
B869  CD 1B 01 CMP $011B               
B86C  90 F4    BCC loc_B862            
B86E  CD 1C 01 CMP $011C               
B871  90 03    BCC loc_B876            
B873  AD 1C 01 LDA $011C               

loc_B876:  ; 1 xrefs: B871
B876  85 09    STA $09                 
B878  AD 1C 01 LDA $011C               
B87B  C5 10    CMP $10                 
B87D  90 E3    BCC loc_B862            
B87F  A5 10    LDA $10                 
B881  CD 1B 01 CMP $011B               
B884  B0 03    BCS loc_B889            
B886  AD 1B 01 LDA $011B               

loc_B889:  ; 1 xrefs: B884
B889  85 08    STA $08                 
B88B  A5 13    LDA $13                 
B88D  CD 1D 01 CMP $011D               
B890  90 D0    BCC loc_B862            
B892  CD 1E 01 CMP $011E               
B895  90 03    BCC loc_B89A            
B897  AD 1E 01 LDA $011E               

loc_B89A:  ; 1 xrefs: B895
B89A  85 0B    STA $0B                 
B89C  AD 1E 01 LDA $011E               
B89F  C5 12    CMP $12                 
B8A1  90 BF    BCC loc_B862            
B8A3  A5 12    LDA $12                 
B8A5  CD 1D 01 CMP $011D               
B8A8  B0 03    BCS loc_B8AD            
B8AA  AD 1D 01 LDA $011D               

loc_B8AD:  ; 1 xrefs: B8A8
B8AD  85 0A    STA $0A                 
B8AF  A5 0B    LDA $0B                 
B8B1  38       SEC                     
B8B2  E5 0A    SBC $0A                 
B8B4  85 0C    STA $0C                 
B8B6  A5 09    LDA $09                 
B8B8  38       SEC                     
B8B9  E5 08    SBC $08                 
B8BB  C5 0C    CMP $0C                 
B8BD  90 1E    BCC loc_B8DD            
B8BF  AD 1E 01 LDA $011E               
B8C2  C5 0B    CMP $0B                 
B8C4  D0 0C    BNE loc_B8D2            
B8C6  AD 1D 01 LDA $011D               
B8C9  C5 0A    CMP $0A                 
B8CB  F0 2E    BEQ loc_B8FB            
B8CD  A9 01    LDA #$01                
B8CF  85 14    STA $14                 
B8D1  60       RTS                     

loc_B8D2:  ; 1 xrefs: B8C4
B8D2  A5 12    LDA $12                 
B8D4  C5 0A    CMP $0A                 
B8D6  F0 23    BEQ loc_B8FB            
B8D8  A9 02    LDA #$02                
B8DA  85 14    STA $14                 
B8DC  60       RTS                     

loc_B8DD:  ; 1 xrefs: B8BD
B8DD  AD 1C 01 LDA $011C               
B8E0  C5 09    CMP $09                 
B8E2  D0 0C    BNE loc_B8F0            
B8E4  AD 1B 01 LDA $011B               
B8E7  C5 08    CMP $08                 
B8E9  F0 10    BEQ loc_B8FB            
B8EB  A9 03    LDA #$03                
B8ED  85 14    STA $14                 
B8EF  60       RTS                     

loc_B8F0:  ; 1 xrefs: B8E2
B8F0  A5 10    LDA $10                 
B8F2  C5 08    CMP $08                 
B8F4  F0 05    BEQ loc_B8FB            
B8F6  A9 04    LDA #$04                
B8F8  85 14    STA $14                 
B8FA  60       RTS                     

loc_B8FB:  ; 4 xrefs: B8CB B8D6 B8E9 B8F4
B8FB  A9 05    LDA #$05                
B8FD  85 14    STA $14                 
B8FF  60       RTS                     

loc_B900:  ; 1 xrefs: B918
B900  BD 08 05 LDA $0508,X             
B903  8D 60 01 STA $0160               
B906  BD C6 04 LDA $04C6,X             
B909  8D 61 01 STA $0161               
B90C  60       RTS                     

loc_B90D:  ; 0 xrefs: 
B90D  20 93 B7 JSR sub_B793            
B910  F0 03    BEQ loc_B915            
B912  20 67 B8 JSR sub_B867            

loc_B915:  ; 1 xrefs: B910
B915  8D 64 01 STA $0164               
B918  4C 00 B9 JMP loc_B900            

loc_B91B:  ; 1 xrefs: B91F
B91B  60       RTS                     

loc_B91C:  ; 0 xrefs: 
B91C  20 93 B7 JSR sub_B793            
B91F  F0 FA    BEQ loc_B91B            
B921  AD 67 01 LDA $0167               
B924  D0 61    BNE loc_B987            
B926  AD 1A 01 LDA $011A               
B929  AC 64 01 LDY $0164               
B92C  18       CLC                     
B92D  79 8A B9 ADC $B98A,Y             
B930  85 00    STA $00                 
B932  20 67 B8 JSR sub_B867            
B935  18       CLC                     
B936  65 00    ADC $00                 
B938  A8       TAY                     
B939  B9 90 B9 LDA $B990,Y             
B93C  A8       TAY                     
B93D  B9 4A B9 LDA $B94A,Y             
B940  85 00    STA $00                 
B942  B9 51 B9 LDA $B951,Y             
B945  85 01    STA $01                 
B947  6C 00 00 JMP ($0000)             

; ==== data $B94A..$B986  (61 bytes) ====
B94A  1B 87 84 7E 78 68 58 B9 B9 B9 B9 B9 B9 B9 20 08  |...~xhX....... .
B95A  B8 BD C6 04 38 ED 61 01 8D 52 06 4C EA B7 20 28  |....8.a..R.L.. (
B96A  B8 BD 08 05 38 ED 60 01 8D 3C 06 4C EA B7 20 08  |....8.`..<.L.. .
B97A  B8 4C EA B7 20 28 B8 4C EA B7 20 48 B8           |.L.. (.L.. H.

loc_B987:  ; 1 xrefs: B924
B987  4C EA B7 JMP loc_B7EA            

; ==== data $B98A..$BA43  (186 bytes) ====
B98A  00 06 0C 12 18 1E 01 03 03 04 04 00 01 03 03 04  |................
B99A  04 00 01 03 03 04 04 00 01 03 03 04 04 00 01 03  |................
B9AA  03 04 04 00 01 03 03 04 04 00 01 03 01 04 04 00  |................
B9BA  02 05 01 03 03 00 01 03 01 01 01 00 01 03 01 04  |................
B9CA  01 00 01 03 01 01 04 00 01 03 01 04 04 00 01 01  |................
B9DA  03 04 04 00 01 01 03 01 01 00 02 01 05 01 01 00  |................
B9EA  01 01 03 04 01 00 01 01 03 01 04 00 01 01 03 04  |................
B9FA  04 00 01 03 03 04 01 00 01 03 03 04 01 00 01 03  |................
BA0A  03 04 01 00 02 04 04 06 01 00 01 01 01 04 01 00  |................
BA1A  01 03 03 04 01 00 01 03 03 01 04 00 01 03 03 01  |................
BA2A  04 00 01 03 03 01 04 00 01 01 01 01 04 00 02 04  |................
BA3A  04 01 06 00 01 03 03 01 04 00                    |..........

loc_BA44:  ; 1 xrefs: 8E00
BA44  AD 16 04 LDA $0416               
BA47  A2 07    LDX #$07                
BA49  A0 00    LDY #$00                

loc_BA4B:  ; 1 xrefs: BA50
BA4B  4A       LSR A                   
BA4C  B0 04    BCS loc_BA52            
BA4E  C8       INY                     
BA4F  CA       DEX                     
BA50  D0 F9    BNE loc_BA4B            

loc_BA52:  ; 1 xrefs: BA4C
BA52  B9 E6 BA LDA $BAE6,Y             
BA55  C9 6C    CMP #$6C                
BA57  D0 17    BNE loc_BA70            
BA59  AE 8C 05 LDX $058C               
BA5C  E0 18    CPX #$18                
BA5E  D0 09    BNE loc_BA69            
BA60  2C 2C 04 BIT $042C               
BA63  70 0B    BVS loc_BA70            
BA65  A9 90    LDA #$90                
BA67  D0 07    BNE loc_BA70            

loc_BA69:  ; 1 xrefs: BA5E
BA69  2C 2C 04 BIT $042C               
BA6C  50 02    BVC loc_BA70            
BA6E  A9 90    LDA #$90                

loc_BA70:  ; 4 xrefs: BA57 BA63 BA67 BA6C
BA70  8D 1A 01 STA $011A               
BA73  AD 8C 05 LDA $058C               
BA76  C9 18    CMP #$18                
BA78  F0 08    BEQ loc_BA82            
BA7A  C9 1A    CMP #$1A                
BA7C  D0 0C    BNE loc_BA8A            
BA7E  A0 08    LDY #$08                
BA80  D0 08    BNE loc_BA8A            

loc_BA82:  ; 1 xrefs: BA78
BA82  A0 09    LDY #$09                
BA84  2C 2C 04 BIT $042C               
BA87  50 01    BVC loc_BA8A            
BA89  C8       INY                     

loc_BA8A:  ; 3 xrefs: BA7C BA80 BA87
BA8A  B9 EE BA LDA $BAEE,Y             
BA8D  85 08    STA $08                 
BA8F  B9 F9 BA LDA $BAF9,Y             
BA92  85 09    STA $09                 
BA94  A0 00    LDY #$00                
BA96  B1 08    LDA ($08),Y             
BA98  18       CLC                     
BA99  6D 08 05 ADC $0508               
BA9C  AA       TAX                     
BA9D  A9 FF    LDA #$FF                
BA9F  6D F2 04 ADC $04F2               
BAA2  F0 02    BEQ loc_BAA6            
BAA4  A2 00    LDX #$00                

loc_BAA6:  ; 1 xrefs: BAA2
BAA6  8E 1B 01 STX $011B               
BAA9  C8       INY                     
BAAA  B1 08    LDA ($08),Y             
BAAC  18       CLC                     
BAAD  6D 08 05 ADC $0508               
BAB0  AA       TAX                     
BAB1  A9 00    LDA #$00                
BAB3  6D F2 04 ADC $04F2               
BAB6  F0 02    BEQ loc_BABA            
BAB8  A2 FF    LDX #$FF                

loc_BABA:  ; 1 xrefs: BAB6
BABA  8E 1C 01 STX $011C               
BABD  C8       INY                     
BABE  B1 08    LDA ($08),Y             
BAC0  18       CLC                     
BAC1  6D C6 04 ADC $04C6               
BAC4  AA       TAX                     
BAC5  A9 FF    LDA #$FF                
BAC7  6D B0 04 ADC $04B0               
BACA  F0 02    BEQ loc_BACE            
BACC  A2 00    LDX #$00                

loc_BACE:  ; 1 xrefs: BACA
BACE  8E 1D 01 STX $011D               
BAD1  C8       INY                     
BAD2  B1 08    LDA ($08),Y             
BAD4  18       CLC                     
BAD5  6D C6 04 ADC $04C6               
BAD8  AA       TAX                     
BAD9  A9 00    LDA #$00                
BADB  6D B0 04 ADC $04B0               
BADE  F0 02    BEQ loc_BAE2            
BAE0  A2 FF    LDX #$FF                

loc_BAE2:  ; 1 xrefs: BADE
BAE2  8E 1E 01 STX $011E               
BAE5  60       RTS                     

; ==== data $BAE6..$BB23  (62 bytes) ====
BAE6  00 24 00 24 24 6C 48 24 10 04 04 08 0C 18 14 04  |.$.$$lH$........
BAF6  1C 20 24 BB BB BB BB BB BB BB BB BB BB BB FA 05  |. $.............
BB06  E0 01 FA 05 EA 01 F8 07 F2 01 F9 06 E0 01 FA 05  |................
BB16  E0 01 F9 06 DC 01 FA 05 DF 01 FF 05 DC 01        |..............

loc_BB24:  ; 0 xrefs: 
BB24  FA       NOP                     
BB25  01 DC    ORA ($DC,X)             
BB27  01 BC    ORA ($BC,X)             
BB29  CE 05 B9 DEC $B905               
BB2C  38       SEC                     

; ==== data $BB2D..$BB2D  (1 bytes) ====
BB2D  BB                                               |.
BB2E  85 00    STA $00                 
BB30  B9 45 BB LDA $BB45,Y             
BB33  85 01    STA $01                 
BB35  6C 00 00 JMP ($0000)             

; ==== data $BB38..$BB51  (26 bytes) ====
BB38  5A 7E 91 9F AB CE ED 00 1A 75 93 B7 C5 BB BB BB  |Z~.......u......
BB48  BB BB BB BB BC BC BC BC BC BC                    |..........

loc_BB52:  ; 0 xrefs: 
BB52  FE CE 05 INC $05CE,X             
BB55  60       RTS                     

loc_BB56:  ; 0 xrefs: 
BB56  9D CE 05 STA $05CE,X             
BB59  60       RTS                     

; ==== data $BB5A..$BB6F  (22 bytes) ====
BB5A  86 25 A9 E0 20 70 BB A9 60 20 70 BB A6 25 A9 20  |.%.. p..` p..%. 
BB6A  20 BF BD 4C 52 BB                                | ..LR.

loc_BB70:  ; 0 xrefs: 
BB70  48       PHA                     
BB71  20 6A C8 JSR $C86A               
BB74  A9 4F    LDA #$4F                
BB76  9D 00 04 STA $0400,X             
BB79  68       PLA                     
BB7A  9D CE 05 STA $05CE,X             
BB7D  60       RTS                     

; ==== data $BB7E..$BCEA  (365 bytes) ====
BB7E  DE E4 05 F0 01 60 A9 08 A0 20 20 DA BD 20 E7 BD  |.....`...  .. ..
BB8E  4C 52 BB 20 73 BD B0 01 60 A9 0C 20 BF BD 4C 52  |LR. s...`.. ..LR
BB9E  BB DE E4 05 F0 01 60 20 C8 BD 4C 52 BB 20 EE C8  |......` ..LR. ..
BBAE  A9 10 A0 1C 20 51 C9 10 01 60 A9 FF A0 A0 20 03  |.... Q...`.... .
BBBE  C9 A9 01 A0 80 20 09 C9 A9 C8 9D 42 04 4C 52 BB  |..... .....B.LR.
BBCE  A9 20 20 0C C9 20 F1 C8 A9 10 A0 1C 20 4E C9 30  |.  .. ...... N.0
BBDE  01 60 A9 18 20 84 C9 A9 18 20 BF BD 4C 52 BB DE  |.`.. .... ..LR..
BBEE  E4 05 F0 01 60 20 FD C8 A9 10 A0 40 20 DA BD 4C  |....` .....@ ..L
BBFE  52 BB BC FA 05 88 A8 29 07 D0 03 20 FD C8 20 73  |R......)... .. s
BC0E  BD B0 01 60 A9 08 20 BF BD 4C 52 BB DE E4 05 F0  |...`.. ..LR.....
BC1E  01 60 20 E7 BD 20 8D C9 B0 47 AD 08 05 49 80 29  |.` .. ...G...I.)
BC2E  80 85 00 BD 08 05 29 80 C5 00 D0 35 AD C6 04 C9  |......)....5....
BC3E  60 90 23 AD 08 05 C9 40 90 1C C9 C0 B0 18 A9 C8  |`.#....@........
BC4E  9D 42 04 A9 FF A0 00 20 03 C9 A9 FA A0 00 20 09  |.B..... ...... .
BC5E  C9 A9 0A 4C 56 BB 20 18 C9 20 F4 BD A9 0C 4C 56  |...LV. .. ....LV
BC6E  BB 20 C8 BD 4C 52 BB 20 EE C8 20 90 C9 BD 08 05  |. ..LR. .. .....
BC7E  B0 06 C9 4E 90 07 B0 04 C9 B3 B0 01 60 20 F4 BD  |...N........` ..
BC8E  A9 0C 4C 56 BB A9 36 20 0C C9 20 F1 C8 BD 34 05  |..LV..6 .. ...4.
BC9E  30 16 A9 10 A0 1C 20 4E C9 10 0D A9 18 20 84 C9  |0..... N..... ..
BCAE  A9 18 20 BF BD 4C 52 BB 60 DE E4 05 F0 01 60 20  |.. ..LR.`.....` 
BCBE  C8 BD A9 09 4C 56 BB A9 36 20 0C C9 20 F1 C8 BD  |....LV..6 .. ...
BCCE  34 05 30 18 A9 10 A0 1C 20 4E C9 10 0F A9 18 20  |4.0..... N..... 
BCDE  84 C9 A9 10 20 BF BD A9 01 4C 56 BB 60           |.... ....LV.`

sub_BCEB:  ; 1 xrefs: BD90
BCEB  20 8D C9 JSR $C98D               
BCEE  B0 70    BCS loc_BD60            
BCF0  BD 08 05 LDA $0508,X             
BCF3  85 00    STA $00                 
BCF5  BD C6 04 LDA $04C6,X             
BCF8  38       SEC                     
BCF9  E9 08    SBC #$08                
BCFB  85 01    STA $01                 
BCFD  AD 08 05 LDA $0508               
BD00  85 02    STA $02                 
BD02  AD C6 04 LDA $04C6               
BD05  38       SEC                     
BD06  E9 18    SBC #$18                
BD08  85 03    STA $03                 
BD0A  20 B2 C8 JSR $C8B2               
BD0D  18       CLC                     
BD0E  69 40    ADC #$40                
BD10  29 7F    AND #$7F                
BD12  85 09    STA $09                 
BD14  20 90 C9 JSR $C990               
BD17  90 09    BCC loc_BD22            
BD19  A5 09    LDA $09                 
BD1B  20 58 C8 JSR $C858               
BD1E  29 7F    AND #$7F                
BD20  85 09    STA $09                 

loc_BD22:  ; 1 xrefs: BD17
BD22  A5 09    LDA $09                 
BD24  A0 00    LDY #$00                
BD26  C9 38    CMP #$38                
BD28  90 06    BCC loc_BD30            
BD2A  C8       INY                     
BD2B  C9 48    CMP #$48                
BD2D  B0 01    BCS loc_BD30            
BD2F  C8       INY                     

loc_BD30:  ; 2 xrefs: BD28 BD2D
BD30  B9 67 BD LDA $BD67,Y             
BD33  9D 42 04 STA $0442,X             
BD36  B9 6A BD LDA $BD6A,Y             
BD39  85 10    STA $10                 
BD3B  B9 6D BD LDA $BD6D,Y             
BD3E  C5 09    CMP $09                 
BD40  B0 07    BCS loc_BD49            
BD42  B9 70 BD LDA $BD70,Y             
BD45  C5 09    CMP $09                 
BD47  B0 02    BCS loc_BD4B            

loc_BD49:  ; 1 xrefs: BD40
BD49  85 09    STA $09                 

loc_BD4B:  ; 1 xrefs: BD47
BD4B  A9 40    LDA #$40                
BD4D  18       CLC                     
BD4E  65 09    ADC $09                 
BD50  85 06    STA $06                 
BD52  20 90 C9 JSR $C990               
BD55  90 07    BCC loc_BD5E            
BD57  A9 80    LDA #$80                
BD59  38       SEC                     
BD5A  E5 06    SBC $06                 
BD5C  85 06    STA $06                 

loc_BD5E:  ; 1 xrefs: BD55
BD5E  18       CLC                     
BD5F  60       RTS                     

loc_BD60:  ; 1 xrefs: BCEE
BD60  A9 C0    LDA #$C0                
BD62  9D 42 04 STA $0442,X             
BD65  38       SEC                     
BD66  60       RTS                     

; ==== data $BD67..$BD72  (12 bytes) ====
BD67  C2 C3 C1 06 E8 FA 18 58 3C 28 68 44              |.......X<(hD

loc_BD73:  ; 0 xrefs: 
BD73  BD E4 05 LDA $05E4,X             
BD76  F0 0C    BEQ loc_BD84            
BD78  DE E4 05 DEC $05E4,X             
BD7B  A9 C0    LDA #$C0                
BD7D  9D 42 04 STA $0442,X             

loc_BD80:  ; 4 xrefs: BD8E BD93 BD98 BD9F
BD80  18       CLC                     
BD81  60       RTS                     

loc_BD82:  ; 1 xrefs: BD87
BD82  38       SEC                     
BD83  60       RTS                     

loc_BD84:  ; 1 xrefs: BD76
BD84  DE FA 05 DEC $05FA,X             
BD87  F0 F9    BEQ loc_BD82            
BD89  BD FA 05 LDA $05FA,X             
BD8C  29 07    AND #$07                
BD8E  D0 F0    BNE loc_BD80            
BD90  20 EB BC JSR sub_BCEB            
BD93  B0 EB    BCS loc_BD80            
BD95  BD 10 06 LDA $0610,X             
BD98  F0 E6    BEQ loc_BD80            
BD9A  BD FA 05 LDA $05FA,X             
BD9D  29 0F    AND #$0F                
BD9F  D0 DF    BNE loc_BD80            
BDA1  A9 48    LDA #$48                
BDA3  85 24    STA $24                 
BDA5  A9 12    LDA #$12                
BDA7  85 26    STA $26                 
BDA9  A0 EA    LDY #$EA                
BDAB  20 90 C9 JSR $C990               
BDAE  90 02    BCC loc_BDB2            
BDB0  A0 16    LDY #$16                

loc_BDB2:  ; 1 xrefs: BDAE
BDB2  98       TYA                     
BDB3  A4 10    LDY $10                 
BDB5  20 E5 C8 JSR $C8E5               
BDB8  B0 03    BCS loc_BDBD            
BDBA  DE 10 06 DEC $0610,X             

loc_BDBD:  ; 1 xrefs: BDB8
BDBD  18       CLC                     
BDBE  60       RTS                     

loc_BDBF:  ; 0 xrefs: 
BDBF  9D E4 05 STA $05E4,X             
BDC2  A9 BF    LDA #$BF                
BDC4  9D 42 04 STA $0442,X             
BDC7  60       RTS                     

loc_BDC8:  ; 0 xrefs: 
BDC8  A9 FE    LDA #$FE                
BDCA  A0 00    LDY #$00                
BDCC  20 03 C9 JSR $C903               
BDCF  A9 00    LDA #$00                
BDD1  A8       TAY                     
BDD2  20 09 C9 JSR $C909               
BDD5  A9 34    LDA #$34                
BDD7  4C 3A C8 JMP $C83A               

loc_BDDA:  ; 0 xrefs: 
BDDA  9D E4 05 STA $05E4,X             
BDDD  98       TYA                     
BDDE  9D FA 05 STA $05FA,X             
BDE1  A9 01    LDA #$01                
BDE3  9D 10 06 STA $0610,X             
BDE6  60       RTS                     

loc_BDE7:  ; 0 xrefs: 
BDE7  A9 00    LDA #$00                
BDE9  BC 08 05 LDY $0508,X             
BDEC  30 02    BMI loc_BDF0            
BDEE  A9 40    LDA #$40                

loc_BDF0:  ; 1 xrefs: BDEC
BDF0  9D 2C 04 STA $042C,X             
BDF3  60       RTS                     

loc_BDF4:  ; 0 xrefs: 
BDF4  A9 C8    LDA #$C8                
BDF6  9D 42 04 STA $0442,X             
BDF9  A9 FE    LDA #$FE                
BDFB  A0 E0    LDY #$E0                

loc_BDFD:  ; 0 xrefs: 
BDFD  20 03 C9 JSR $C903               
BE00  A9 FA    LDA #$FA                
BE02  A0 00    LDY #$00                
BE04  4C 09 C9 JMP $C909               

loc_BE07:  ; 1 xrefs: 8E0F
BE07  BC CE 05 LDY $05CE,X             
BE0A  D0 24    BNE loc_BE30            
BE0C  FE CE 05 INC $05CE,X             
BE0F  A9 80    LDA #$80                
BE11  9D E4 05 STA $05E4,X             
BE14  A9 36    LDA #$36                
BE16  20 3A C8 JSR $C83A               
BE19  86 25    STX $25                 
BE1B  20 27 BE JSR sub_BE27            
BE1E  20 27 BE JSR sub_BE27            
BE21  20 27 BE JSR sub_BE27            
BE24  A6 25    LDX $25                 
BE26  60       RTS                     

sub_BE27:  ; 3 xrefs: BE1B BE1E BE21
BE27  20 6A C8 JSR $C86A               
BE2A  A9 45    LDA #$45                
BE2C  9D 00 04 STA $0400,X             
BE2F  60       RTS                     

loc_BE30:  ; 1 xrefs: BE0A
BE30  20 9A BE JSR sub_BE9A            
BE33  20 F5 BE JSR sub_BEF5            
BE36  20 FD C8 JSR $C8FD               
BE39  20 37 C8 JSR $C837               
BE3C  BD 34 05 LDA $0534,X             
BE3F  30 0E    BMI loc_BE4F            
BE41  C9 02    CMP #$02                
BE43  90 0A    BCC loc_BE4F            
BE45  A9 A8    LDA #$A8                
BE47  9D 42 04 STA $0442,X             
BE4A  A9 10    LDA #$10                
BE4C  9D A2 05 STA $05A2,X             

loc_BE4F:  ; 2 xrefs: BE3F BE43
BE4F  BD 34 05 LDA $0534,X             
BE52  30 10    BMI loc_BE64            
BE54  A5 29    LDA $29                 
BE56  38       SEC                     
BE57  E9 10    SBC #$10                
BE59  DD C6 04 CMP $04C6,X             
BE5C  B0 0F    BCS loc_BE6D            
BE5E  A9 FF    LDA #$FF                
BE60  A0 80    LDY #$80                
BE62  D0 13    BNE loc_BE77            

loc_BE64:  ; 1 xrefs: BE52
BE64  A9 00    LDA #$00                
BE66  A0 F0    LDY #$F0                
BE68  20 88 C8 JSR $C888               
BE6B  30 06    BMI loc_BE73            

loc_BE6D:  ; 1 xrefs: BE5C
BE6D  20 F4 C8 JSR $C8F4               
BE70  4C 7A BE JMP loc_BE7A            

loc_BE73:  ; 1 xrefs: BE6B
BE73  A9 00    LDA #$00                
BE75  A0 80    LDY #$80                

loc_BE77:  ; 1 xrefs: BE62
BE77  20 09 C9 JSR $C909               

loc_BE7A:  ; 1 xrefs: BE70
BE7A  A9 18    LDA #$18                
BE7C  BC 60 05 LDY $0560,X             
BE7F  10 02    BPL loc_BE83            
BE81  A9 E8    LDA #$E8                

loc_BE83:  ; 1 xrefs: BE7F
BE83  A0 00    LDY #$00                
BE85  20 88 C8 JSR $C888               
BE88  30 06    BMI loc_BE90            
BE8A  20 F7 C8 JSR $C8F7               
BE8D  4C 96 BE JMP loc_BE96            

loc_BE90:  ; 1 xrefs: BE88
BE90  A9 00    LDA #$00                
BE92  A8       TAY                     
BE93  20 06 C9 JSR $C906               

loc_BE96:  ; 1 xrefs: BE8D
BE96  20 1F BF JSR sub_BF1F            
BE99  60       RTS                     

sub_BE9A:  ; 1 xrefs: BE30
BE9A  20 3C C9 JSR $C93C               
BE9D  08       PHP                     
BE9E  A0 03    LDY #$03                
BEA0  C9 80    CMP #$80                
BEA2  B0 13    BCS loc_BEB7            
BEA4  88       DEY                     
BEA5  C9 60    CMP #$60                
BEA7  B0 13    BCS loc_BEBC            
BEA9  88       DEY                     
BEAA  C9 30    CMP #$30                
BEAC  B0 13    BCS loc_BEC1            
BEAE  88       DEY                     
BEAF  28       PLP                     
BEB0  AD 08 05 LDA $0508               
BEB3  10 25    BPL loc_BEDA            
BEB5  30 10    BMI loc_BEC7            

loc_BEB7:  ; 1 xrefs: BEA2
BEB7  28       PLP                     
BEB8  90 20    BCC loc_BEDA            
BEBA  B0 0B    BCS loc_BEC7            

loc_BEBC:  ; 1 xrefs: BEA7
BEBC  28       PLP                     
BEBD  B0 1B    BCS loc_BEDA            
BEBF  90 06    BCC loc_BEC7            

loc_BEC1:  ; 1 xrefs: BEAC
BEC1  28       PLP                     
BEC2  BD 60 05 LDA $0560,X             
BEC5  10 13    BPL loc_BEDA            

loc_BEC7:  ; 3 xrefs: BEB5 BEBA BEBF
BEC7  B9 F1 BE LDA $BEF1,Y             
BECA  20 15 C9 JSR $C915               
BECD  BD 60 05 LDA $0560,X             
BED0  10 1E    BPL loc_BEF0            
BED2  C9 FF    CMP #$FF                
BED4  B0 1A    BCS loc_BEF0            
BED6  A9 FE    LDA #$FE                
BED8  D0 11    BNE loc_BEEB            

loc_BEDA:  ; 4 xrefs: BEB3 BEB8 BEBD BEC5
BEDA  B9 F1 BE LDA $BEF1,Y             
BEDD  20 12 C9 JSR $C912               
BEE0  BD 60 05 LDA $0560,X             
BEE3  30 0B    BMI loc_BEF0            
BEE5  C9 02    CMP #$02                
BEE7  90 07    BCC loc_BEF0            
BEE9  A9 02    LDA #$02                

loc_BEEB:  ; 1 xrefs: BED8
BEEB  A0 00    LDY #$00                
BEED  4C 06 C9 JMP $C906               

loc_BEF0:  ; 4 xrefs: BED0 BED4 BEE3 BEE7
BEF0  60       RTS                     

; ==== data $BEF1..$BEF4  (4 bytes) ====
BEF1  20 10 04 02                                      | ...

sub_BEF5:  ; 1 xrefs: BE33
BEF5  BD C6 04 LDA $04C6,X             
BEF8  85 10    STA $10                 
BEFA  A0 10    LDY #$10                
BEFC  20 30 C9 JSR $C930               
BEFF  20 3F C9 JSR $C93F               
BF02  08       PHP                     
BF03  A8       TAY                     
BF04  A5 10    LDA $10                 
BF06  9D C6 04 STA $04C6,X             
BF09  C0 40    CPY #$40                
BF0B  90 07    BCC loc_BF14            
BF0D  A9 04    LDA #$04                
BF0F  28       PLP                     
BF10  90 0A    BCC loc_BF1C            
BF12  B0 05    BCS loc_BF19            

loc_BF14:  ; 1 xrefs: BF0B
BF14  A9 10    LDA #$10                
BF16  28       PLP                     
BF17  B0 03    BCS loc_BF1C            

loc_BF19:  ; 1 xrefs: BF12
BF19  4C 0F C9 JMP $C90F               

loc_BF1C:  ; 2 xrefs: BF10 BF17
BF1C  4C 0C C9 JMP $C90C               

sub_BF1F:  ; 1 xrefs: BE96
BF1F  DE E4 05 DEC $05E4,X             
BF22  F0 01    BEQ loc_BF25            
BF24  60       RTS                     

loc_BF25:  ; 1 xrefs: BF22
BF25  A9 B4    LDA #$B4                
BF27  9D E4 05 STA $05E4,X             
BF2A  A9 A9    LDA #$A9                
BF2C  9D 42 04 STA $0442,X             
BF2F  A9 10    LDA #$10                
BF31  9D A2 05 STA $05A2,X             
BF34  A9 00    LDA #$00                
BF36  A8       TAY                     
BF37  20 06 C9 JSR $C906               
BF3A  20 09 C9 JSR $C909               
BF3D  A0 00    LDY #$00                
BF3F  84 09    STY $09                 
BF41  20 90 C9 JSR $C990               
BF44  90 02    BCC loc_BF48            
BF46  A0 04    LDY #$04                

loc_BF48:  ; 1 xrefs: BF44
BF48  84 0A    STY $0A                 
BF4A  BD C6 04 LDA $04C6,X             
BF4D  C9 60    CMP #$60                
BF4F  90 07    BCC loc_BF58            
BF51  A5 0A    LDA $0A                 
BF53  18       CLC                     
BF54  69 02    ADC #$02                
BF56  85 0A    STA $0A                 

loc_BF58:  ; 1 xrefs: BF4F
BF58  20 5F BF JSR sub_BF5F            
BF5B  C6 09    DEC $09                 
BF5D  E6 0A    INC $0A                 

sub_BF5F:  ; 1 xrefs: BF58
BF5F  A9 3B    LDA #$3B                
BF61  85 24    STA $24                 
BF63  A0 00    LDY #$00                
BF65  A9 00    LDA #$00                
BF67  20 DF C8 JSR $C8DF               
BF6A  B0 24    BCS loc_BF90            
BF6C  A6 12    LDX $12                 
BF6E  A9 08    LDA #$08                
BF70  24 09    BIT $09                 
BF72  10 02    BPL loc_BF76            
BF74  A9 F8    LDA #$F8                

loc_BF76:  ; 1 xrefs: BF72
BF76  9D 10 06 STA $0610,X             
BF79  A5 09    LDA $09                 
BF7B  4A       LSR A                   
BF7C  A9 00    LDA #$00                
BF7E  69 20    ADC #$20                
BF80  9D FA 05 STA $05FA,X             
BF83  A4 0A    LDY $0A                 
BF85  B9 91 BF LDA $BF91,Y             
BF88  9D E4 05 STA $05E4,X             
BF8B  9D CE 05 STA $05CE,X             
BF8E  A6 25    LDX $25                 

loc_BF90:  ; 1 xrefs: BF6A
BF90  60       RTS                     

; ==== data $BF91..$BFFF  (111 bytes) ====
BF91  70 50 B0 90 10 30 D0 F0 FF FF FF FF FF FF FF FF  |pP...0..........
BFA1  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFB1  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFC1  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFD1  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFE1  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFF1  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF     |...............