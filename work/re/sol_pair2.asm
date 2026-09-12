; ==== PRG bank pair 2/3 @ $8000/$A000 ====

; ---- data $8000-$800F (16 bytes) ----
8000  02 00 00 00 4C 9D 81 4C 00 00 4C E9 B2 4C C2 AA  |....L..L..L..L..

sub_8010:  ; xrefs(11): $8AE4 $90CD $915E $924B $968B $99AA $9B1F $9DEF $9E1A $A130
8010  84 2C    STY $2C                   
8012  0A       ASL A                     
8013  A8       TAY                       
8014  68       PLA                       
8015  85 29    STA $29                   
8017  68       PLA                       
8018  85 2A    STA $2A                   
801A  C8       INY                       
801B  B1 29    LDA ($29),Y               
801D  48       PHA                       
801E  C8       INY                       
801F  B1 29    LDA ($29),Y               
8021  A4 2C    LDY $2C                   
8023  85 2C    STA $2C                   
8025  68       PLA                       
8026  85 2B    STA $2B                   
8028  6C 2B 00 JMP ($002B)               

sub_802B:  ; xrefs(3): $862F $8A6A $8D7A
802B  20 43 80 JSR $8043                 
802E  38       SEC                       
802F  FD 10 06 SBC $0610,X               
8032  29 3F    AND #$3F                  
8034  C9 20    CMP #$20                  
8036  A9 00    LDA #$00                  
8038  B0 02    BCS $803C                 
803A  A9 FF    LDA #$FF                  

loc_803C:  ; xrefs(1): $8038
803C  7D 10 06 ADC $0610,X               
803F  9D 10 06 STA $0610,X               
8042  60       RTS                       

sub_8043:  ; xrefs(2): $802B $84E4
8043  A5 82    LDA $82                   
8045  85 92    STA $92                   
8047  A5 83    LDA $83                   
8049  85 93    STA $93                   
804B  A5 80    LDA $80                   
804D  85 90    STA $90                   
804F  A5 81    LDA $81                   
8051  85 91    STA $91                   
8053  B5 A0    LDA $A0,X                 
8055  85 94    STA $94                   
8057  B5 B0    LDA $B0,X                 
8059  85 95    STA $95                   
805B  B5 C0    LDA $C0,X                 
805D  85 96    STA $96                   
805F  B5 D0    LDA $D0,X                 
8061  85 97    STA $97                   
8063  4C 51 C0 JMP $C051                 

sub_8066:  ; xrefs(4): $8632 $8A6D $8A7B $8D7D
8066  A9 00    LDA #$00                  
8068  85 90    STA $90                   
806A  BD 10 06 LDA $0610,X               
806D  20 78 C0 JSR $C078                 
8070  A5 90    LDA $90                   
8072  85 50    STA $50                   
8074  A5 91    LDA $91                   
8076  85 51    STA $51                   
8078  A5 92    LDA $92                   
807A  85 52    STA $52                   
807C  A5 93    LDA $93                   
807E  85 53    STA $53                   
8080  60       RTS                       

loc_8081:  ; xrefs(2): $9237 $9668
8081  A0 80    LDY #$80                  
8083  85 90    STA $90                   
8085  84 91    STY $91                   
8087  4C 81 C0 JMP $C081                 

sub_808A:  ; xrefs(4): $927E $A3BC $A3DE $A42A
808A  A9 0F    LDA #$0F                  
808C  D0 02    BNE $8090                 

sub_808E:  ; xrefs(3): $9287 $A45E $A472
808E  A9 30    LDA #$30                  

loc_8090:  ; xrefs(1): $808C
8090  A0 1C    LDY #$1C                  

loc_8092:  ; xrefs(1): $8099
8092  99 00 01 STA $0100,Y               
8095  88       DEY                       
8096  88       DEY                       
8097  88       DEY                       
8098  88       DEY                       
8099  10 F7    BPL $8092                 
809B  60       RTS                       

; ---- data $809C-$809D (2 bytes) ----
809C  A0 00                                            |..

loc_809E:  ; xrefs(1): $A467
809E  A9 00    LDA #$00                  

loc_80A0:  ; xrefs(1): $80A6
80A0  99 00 06 STA $0600,Y               
80A3  C8       INY                       
80A4  C0 0C    CPY #$0C                  
80A6  D0 F8    BNE $80A0                 
80A8  60       RTS                       

loc_80A9:  ; xrefs(2): $A0E7 $A403
80A9  85 26    STA $26                   
80AB  84 27    STY $27                   
80AD  60       RTS                       

; ---- data $80AE-$80B2 (5 bytes) ----
80AE  85 20 84 21 60                                   |. .!`

sub_80B3:  ; xrefs(10): $8763 $8D29 $8D49 $8DE5 $8E82 $90A3 $A148 $AFF9 $B02C $B070
80B3  A9 00    LDA #$00                  
80B5  9D 90 06 STA $0690,X               
80B8  60       RTS                       

sub_80B9:  ; xrefs(14): $8304 $87BD $959A $9DA5 $9DB5 $A043 $A04E $A3E1 $A435 $A97B
80B9  A9 00    LDA #$00                  
80BB  9D 00 06 STA $0600,X               
80BE  60       RTS                       

sub_80BF:  ; xrefs(3): $84D0 $ADA9 $B10B
80BF  BD 50 06 LDA $0650,X               
80C2  09 80    ORA #$80                  
80C4  9D 50 06 STA $0650,X               
80C7  60       RTS                       

; ---- data $80C8-$80D3 (12 bytes) ----
80C8  A5 00 85 90 A5 00 45 90 6A 90 F9 60              |......E.j..`

sub_80D4:  ; xrefs(4): $A077 $A8AA $A907 $AB74
80D4  A9 FF    LDA #$FF                  
80D6  9D E0 06 STA $06E0,X               
80D9  60       RTS                       

sub_80DA:  ; xrefs(6): $8A45 $8AB1 $8F92 $9032 $AF32 $AF6B
80DA  BD E0 06 LDA $06E0,X               
80DD  C9 01    CMP #$01                  
80DF  60       RTS                       

sub_80E0:  ; xrefs(21): $8653 $86AC $875E $87B8 $8D24 $8E7D $8EB3 $8F35 $909E $99DE
80E0  BD C0 06 LDA $06C0,X               
80E3  C9 FF    CMP #$FF                  
80E5  60       RTS                       

sub_80E6:  ; xrefs(11): $8577 $86CE $872E $8BBF $8CD9 $8D10 $8E4D $8EA4 $9089 $AA82
80E6  BD D0 06 LDA $06D0,X               
80E9  C9 02    CMP #$02                  
80EB  60       RTS                       

sub_80EC:  ; xrefs(3): $8C66 $8C9E $8FFB
80EC  BD D0 06 LDA $06D0,X               
80EF  C9 03    CMP #$03                  
80F1  60       RTS                       

sub_80F2:  ; xrefs(2): $857C $8F2D
80F2  A5 0C    LDA $0C                   
80F4  6A       ROR A                     
80F5  A9 0F    LDA #$0F                  
80F7  69 00    ADC #$00                  
80F9  9D E0 06 STA $06E0,X               
80FC  60       RTS                       

sub_80FD:  ; xrefs(1): $8E73
80FD  BD 80 06 LDA $0680,X               
8100  0A       ASL A                     
8101  A5 9F    LDA $9F                   
8103  B0 04    BCS $8109                 
8105  A9 01    LDA #$01                  
8107  E5 9F    SBC $9F                   

loc_8109:  ; xrefs(1): $8103
8109  99 D0 07 STA $07D0,Y               
810C  60       RTS                       

sub_810D:  ; xrefs(2): $8CAD $8FA3
810D  20 30 AE JSR $AE30                 
8110  A5 91    LDA $91                   
8112  D0 07    BNE $811B                 
8114  BD 80 06 LDA $0680,X               
8117  60       RTS                       

sub_8118:  ; xrefs(17): $86A9 $8A3D $8AB9 $8B00 $8B55 $8DC2 $8DDC $8E36 $8E91 $8FDE
8118  20 30 AE JSR $AE30                 

loc_811B:  ; xrefs(1): $8112
811B  A5 94    LDA $94                   
811D  9D 80 06 STA $0680,X               
8120  60       RTS                       

sub_8121:  ; xrefs(16): $8702 $8741 $8C10 $8C93 $8CF1 $8D80 $8D98 $8ECB $9008 $928E
8121  A9 00    LDA #$00                  
8123  85 90    STA $90                   
8125  85 91    STA $91                   
8127  85 92    STA $92                   
8129  85 93    STA $93                   
812B  60       RTS                       

sub_812C:  ; xrefs(9): $81B7 $8A7E $8B1A $9D3D $A6F2 $AE16 $B00D $B021 $B06A
812C  A9 00    LDA #$00                  
812E  85 50    STA $50                   
8130  85 51    STA $51                   
8132  60       RTS                       

sub_8133:  ; xrefs(5): $81BA $863F $8D95 $A820 $A866
8133  A9 00    LDA #$00                  
8135  85 52    STA $52                   
8137  85 53    STA $53                   
8139  60       RTS                       

sub_813A:  ; xrefs(2): $B113 $B13C
813A  A5 51    LDA $51                   
813C  9D 80 06 STA $0680,X               

sub_813F:  ; xrefs(46): $8314 $8443 $84D3 $853C $864B $87CA $89C9 $8A70 $8A81 $8A9F
813F  18       CLC                       
8140  B5 A0    LDA $A0,X                 
8142  65 50    ADC $50                   
8144  95 A0    STA $A0,X                 
8146  A5 51    LDA $51                   
8148  75 B0    ADC $B0,X                 
814A  95 B0    STA $B0,X                 
814C  18       CLC                       
814D  B5 C0    LDA $C0,X                 
814F  65 52    ADC $52                   
8151  95 C0    STA $C0,X                 
8153  B5 D0    LDA $D0,X                 
8155  65 53    ADC $53                   
8157  95 D0    STA $D0,X                 
8159  60       RTS                       

sub_815A:  ; xrefs(3): $A591 $B057 $B086
815A  20 1C B2 JSR $B21C                 
815D  A9 80    LDA #$80                  
815F  D0 0A    BNE $816B                 

sub_8161:  ; xrefs(1): $B035
8161  A9 D0    LDA #$D0                  

sub_8163:  ; xrefs(4): $8171 $90E8 $AF7D $AFD0
8163  9D 30 06 STA $0630,X               
8166  A9 FF    LDA #$FF                  
8168  9D 40 06 STA $0640,X               

loc_816B:  ; xrefs(1): $815F
816B  9D 20 06 STA $0620,X               
816E  60       RTS                       

loc_816F:  ; xrefs(2): $B125 $B22D
816F  A9 C0    LDA #$C0                  
8171  D0 F0    BNE $8163                 

sub_8173:  ; xrefs(3): $8A40 $8AAC $A9AB
8173  BD 50 06 LDA $0650,X               
8176  29 40    AND #$40                  
8178  60       RTS                       

sub_8179:  ; xrefs(1): $8A9C
8179  85 50    STA $50                   
817B  BD 80 06 LDA $0680,X               
817E  30 01    BMI $8181                 
8180  60       RTS                       

sub_8181:  ; xrefs(6): $817E $9D21 $9D6B $A6EA $AF1D $B0A4
8181  38       SEC                       
8182  A9 00    LDA #$00                  
8184  E5 50    SBC $50                   
8186  85 50    STA $50                   
8188  A9 00    LDA #$00                  
818A  E5 51    SBC $51                   
818C  85 51    STA $51                   
818E  60       RTS                       

sub_818F:  ; xrefs(2): $AD43 $AEC0
818F  38       SEC                       
8190  A9 00    LDA #$00                  
8192  E5 52    SBC $52                   
8194  85 52    STA $52                   
8196  A9 00    LDA #$00                  
8198  E5 53    SBC $53                   
819A  85 53    STA $53                   
819C  60       RTS                       

loc_819D:  ; xrefs(0): 
819D  AD C3 05 LDA $05C3                 
81A0  F0 04    BEQ $81A6                 
81A2  C9 30    CMP #$30                  
81A4  90 10    BCC $81B6                 

loc_81A6:  ; xrefs(1): $81A0
81A6  20 B7 81 JSR $81B7                 
81A9  BD 50 06 LDA $0650,X               
81AC  30 08    BMI $81B6                 
81AE  20 2A C0 JSR $C02A                 
81B1  F0 03    BEQ $81B6                 
81B3  4C 2D C0 JMP $C02D                 

loc_81B6:  ; xrefs(4): $81A4 $81AC $81B1 $81D4
81B6  60       RTS                       

sub_81B7:  ; xrefs(1): $81A6
81B7  20 2C 81 JSR $812C                 
81BA  20 33 81 JSR $8133                 
81BD  BD 50 06 LDA $0650,X               
81C0  10 03    BPL $81C5                 
81C2  4C 6A 82 JMP $826A                 

loc_81C5:  ; xrefs(1): $81C0
81C5  0A       ASL A                     
81C6  30 0E    BMI $81D6                 
81C8  BD 00 06 LDA $0600,X               
81CB  29 40    AND #$40                  
81CD  D0 07    BNE $81D6                 
81CF  BD E0 06 LDA $06E0,X               
81D2  C9 08    CMP #$08                  
81D4  90 E0    BCC $81B6                 

loc_81D6:  ; xrefs(2): $81C6 $81CD
81D6  BD 50 06 LDA $0650,X               
81D9  0A       ASL A                     
81DA  29 7E    AND #$7E                  
81DC  A8       TAY                       
81DD  B9 EA 81 LDA $81EA,Y               
81E0  85 90    STA $90                   
81E2  B9 EB 81 LDA $81EB,Y               
81E5  85 91    STA $91                   
81E7  6C 90 00 JMP ($0090)               

; ---- jump table $81EA (64 entries) ----
81EA  .word $B0CC   ; [00] 
81EC  .word $B0CC   ; [01] 
81EE  .word $B0CC   ; [02] 
81F0  .word $B0DC   ; [03] 
81F2  .word $B11D   ; [04] 
81F4  .word $B225   ; [05] 
81F6  .word $B255   ; [06] 
81F8  .word $B26B   ; [07] 
81FA  .word $B2AA   ; [08] 
81FC  .word $B2AE   ; [09] 
81FE  .word $B0EC   ; [0A] 
8200  .word $AFBA   ; [0B] 
8202  .word $AE7B   ; [0C] 
8204  .word $AA51   ; [0D] 
8206  .word $AC73   ; [0E] 
8208  .word $ACB9   ; [0F] 
820A  .word $8BBA   ; [10] 
820C  .word $ACB5   ; [11] 
820E  .word $ADC5   ; [12] 
8210  .word $B0BB   ; [13] 
8212  .word $B0CD   ; [14] 
8214  .word $AA41   ; [15] 
8216  .word $A7F0   ; [16] 
8218  .word $A836   ; [17] 
821A  .word $8802   ; [18] 
821C  .word $82FB   ; [19] 
821E  .word $A511   ; [1A] 
8220  .word $A53D   ; [1B] 
8222  .word $A3A8   ; [1C] 
8224  .word $A3B1   ; [1D] 
8226  .word $A10B   ; [1E] 
8228  .word $A047   ; [1F] 
822A  .word $A031   ; [20] 
822C  .word $9E12   ; [21] 
822E  .word $9D71   ; [22] 
8230  .word $9DAB   ; [23] 
8232  .word $9D41   ; [24] 
8234  .word $9B05   ; [25] 
8236  .word $9B05   ; [26] 
8238  .word $9B05   ; [27] 
823A  .word $8AA2   ; [28] 
823C  .word $9975   ; [29] 
823E  .word $99A2   ; [2A] 
8240  .word $962E   ; [2B] 
8242  .word $9683   ; [2C] 
8244  .word $9DE7   ; [2D] 
8246  .word $A82B   ; [2E] 
8248  .word $915B   ; [2F] 
824A  .word $923B   ; [30] 
824C  .word $9588   ; [31] 
824E  .word $921C   ; [32] 
8250  .word $9127   ; [33] 
8252  .word $90CA   ; [34] 
8254  .word $902D   ; [35] 
8256  .word $B0CC   ; [36] 
8258  .word $B0CC   ; [37] 
825A  .word $8F8D   ; [38] 
825C  .word $8E86   ; [39] 
825E  .word $8DEB   ; [3A] 
8260  .word $8CC9   ; [3B] 
8262  .word $8A33   ; [3C] 
8264  .word $8CA8   ; [3D] 
8266  .word $8C40   ; [3E] 
8268  .word $8398   ; [3F] 

loc_826A:  ; xrefs(1): $81C2
826A  29 3F    AND #$3F                  
826C  0A       ASL A                     
826D  A8       TAY                       
826E  B9 7B 82 LDA $827B,Y               
8271  85 90    STA $90                   
8273  B9 7C 82 LDA $827C,Y               
8276  85 91    STA $91                   
8278  6C 90 00 JMP ($0090)               

; ---- jump table $827B (64 entries) ----
827B  .word $A883   ; [00] 
827D  .word $A883   ; [01] 
827F  .word $A8ED   ; [02] 
8281  .word $B0DC   ; [03] 
8283  .word $A96C   ; [04] 
8285  .word $A96C   ; [05] 
8287  .word $B255   ; [06] 
8289  .word $B26B   ; [07] 
828B  .word $A9F6   ; [08] 
828D  .word $A9F6   ; [09] 
828F  .word $A96C   ; [0A] 
8291  .word $AF63   ; [0B] 
8293  .word $AF23   ; [0C] 
8295  .word $AF2B   ; [0D] 
8297  .word $AF23   ; [0E] 
8299  .word $AF27   ; [0F] 
829B  .word $8993   ; [10] 
829D  .word $AF27   ; [11] 
829F  .word $AF2F   ; [12] 
82A1  .word $A904   ; [13] 
82A3  .word $B0CD   ; [14] 
82A5  .word $AA41   ; [15] 
82A7  .word $A7F0   ; [16] 
82A9  .word $A836   ; [17] 
82AB  .word $897E   ; [18] 
82AD  .word $82FB   ; [19] 
82AF  .word $A43C   ; [1A] 
82B1  .word $A43C   ; [1B] 
82B3  .word $A987   ; [1C] 
82B5  .word $A3B1   ; [1D] 
82B7  .word $A484   ; [1E] 
82B9  .word $A047   ; [1F] 
82BB  .word $A031   ; [20] 
82BD  .word $A406   ; [21] 
82BF  .word $9D71   ; [22] 
82C1  .word $9DAB   ; [23] 
82C3  .word $9D41   ; [24] 
82C5  .word $A3BC   ; [25] 
82C7  .word $A3FB   ; [26] 
82C9  .word $9B05   ; [27] 
82CB  .word $8996   ; [28] 
82CD  .word $9975   ; [29] 
82CF  .word $A4A0   ; [2A] 
82D1  .word $962E   ; [2B] 
82D3  .word $A4BD   ; [2C] 
82D5  .word $A406   ; [2D] 
82D7  .word $A82B   ; [2E] 
82D9  .word $915B   ; [2F] 
82DB  .word $923B   ; [30] 
82DD  .word $9588   ; [31] 
82DF  .word $921C   ; [32] 
82E1  .word $9127   ; [33] 
82E3  .word $90CA   ; [34] 
82E5  .word $899C   ; [35] 
82E7  .word $A8B8   ; [36] 
82E9  .word $A8D3   ; [37] 
82EB  .word $8F72   ; [38] 
82ED  .word $8F72   ; [39] 
82EF  .word $8F72   ; [3A] 
82F1  .word $8F72   ; [3B] 
82F3  .word $8F7B   ; [3C] 
82F5  .word $8F1C   ; [3D] 
82F7  .word $8F7F   ; [3E] 
82F9  .word $8359   ; [3F] 

sub_82FB:  ; xrefs(2): $81EA $827B
82FB  A9 08    LDA #$08                  
82FD  A0 03    LDY #$03                  
82FF  20 DB 99 JSR $99DB                 
8302  D0 03    BNE $8307                 
8304  20 B9 80 JSR $80B9                 

loc_8307:  ; xrefs(1): $8302
8307  BD 10 06 LDA $0610,X               
830A  85 52    STA $52                   
830C  BD 20 06 LDA $0620,X               
830F  85 53    STA $53                   
8311  20 8A 8B JSR $8B8A                 
8314  4C 3F 81 JMP $813F                 

loc_8317:  ; xrefs(2): $A455 $A45B
8317  A9 07    LDA #$07                  

sub_8319:  ; xrefs(1): $89B1
8319  85 9F    STA $9F                   

loc_831B:  ; xrefs(1): $834E
831B  A0 09    LDY #$09                  
831D  20 F1 AA JSR $AAF1                 
8320  30 2E    BMI $8350                 
8322  8A       TXA                       
8323  48       PHA                       
8324  98       TYA                       
8325  AA       TAX                       
8326  A4 9F    LDY $9F                   
8328  B9 51 83 LDA $8351,Y               
832B  9D 30 06 STA $0630,X               
832E  10 03    BPL $8333                 
8330  DE 40 06 DEC $0640,X               

loc_8333:  ; xrefs(1): $832E
8333  18       CLC                       
8334  98       TYA                       
8335  69 06    ADC #$06                  
8337  29 07    AND #$07                  
8339  A8       TAY                       
833A  B9 51 83 LDA $8351,Y               
833D  9D 10 06 STA $0610,X               
8340  10 03    BPL $8345                 
8342  DE 20 06 DEC $0620,X               

loc_8345:  ; xrefs(1): $8340
8345  A9 99    LDA #$99                  
8347  9D 50 06 STA $0650,X               
834A  68       PLA                       
834B  AA       TAX                       
834C  C6 9F    DEC $9F                   
834E  10 CB    BPL $831B                 

loc_8350:  ; xrefs(1): $8320
8350  60       RTS                       

; ---- data $8351-$8358 (8 bytes) ----
8351  D2 00 2D 40 2D 00 D2 C0                          |..-@-...

sub_8359:  ; xrefs(1): $827B
8359  BD 90 06 LDA $0690,X               
835C  A8       TAY                       
835D  B9 6A 83 LDA $836A,Y               
8360  85 90    STA $90                   
8362  B9 6B 83 LDA $836B,Y               
8365  85 91    STA $91                   
8367  6C 90 00 JMP ($0090)               

; ---- jump table $836A (22 entries) ----
836A  .word $8F83   ; [00] 
836C  .word $8F83   ; [01] 
836E  .word $8F83   ; [02] 
8370  .word $8767   ; [03] 
8372  .word $87AB   ; [04] 
8374  .word $8F68   ; [05] 
8376  .word $8F7B   ; [06] 
8378  .word $8F83   ; [07] 
837A  .word $8F83   ; [08] 
837C  .word $8F72   ; [09] 
837E  .word $8F72   ; [0A] 
8380  .word $8545   ; [0B] 
8382  .word $8F65   ; [0C] 
8384  .word $8F76   ; [0D] 
8386  .word $8EE6   ; [0E] 
8388  .word $84AA   ; [0F] 
838A  .word $849C   ; [10] 
838C  .word $84A0   ; [11] 
838E  .word $83EF   ; [12] 
8390  .word $842F   ; [13] 
8392  .word $8457   ; [14] 
8394  .word $83D7   ; [15] 

; ---- data $8396-$8397 (2 bytes) ----
8396  76 8F                                            |v.

sub_8398:  ; xrefs(1): $81EA
8398  BD 90 06 LDA $0690,X               
839B  A8       TAY                       
839C  B9 A9 83 LDA $83A9,Y               
839F  85 90    STA $90                   
83A1  B9 AA 83 LDA $83AA,Y               
83A4  85 91    STA $91                   
83A6  6C 90 00 JMP ($0090)               

; ---- jump table $83A9 (22 entries) ----
83A9  .word $86A1   ; [00] 
83AB  .word $86C9   ; [01] 
83AD  .word $8729   ; [02] 
83AF  .word $8767   ; [03] 
83B1  .word $87AB   ; [04] 
83B3  .word $86A1   ; [05] 
83B5  .word $861C   ; [06] 
83B7  .word $85EA   ; [07] 
83B9  .word $85EE   ; [08] 
83BB  .word $856C   ; [09] 
83BD  .word $8566   ; [0A] 
83BF  .word $8545   ; [0B] 
83C1  .word $84FB   ; [0C] 
83C3  .word $84EF   ; [0D] 
83C5  .word $84D6   ; [0E] 
83C7  .word $84BA   ; [0F] 
83C9  .word $849C   ; [10] 
83CB  .word $84A0   ; [11] 
83CD  .word $83EF   ; [12] 
83CF  .word $842F   ; [13] 
83D1  .word $8457   ; [14] 
83D3  .word $83D7   ; [15] 

; ---- data $83D5-$83D6 (2 bytes) ----
83D5  5C 86                                            |\.

sub_83D7:  ; xrefs(2): $836A $83A9
83D7  8A       TXA                       
83D8  45 0C    EOR $0C                   
83DA  D0 12    BNE $83EE                 
83DC  20 30 AE JSR $AE30                 
83DF  A5 91    LDA $91                   
83E1  C9 05    CMP #$05                  
83E3  90 04    BCC $83E9                 
83E5  A5 94    LDA $94                   
83E7  30 05    BMI $83EE                 

loc_83E9:  ; xrefs(1): $83E3
83E9  A0 F3    LDY #$F3                  
83EB  4C F1 AA JMP $AAF1                 

loc_83EE:  ; xrefs(2): $83DA $83E7
83EE  60       RTS                       

sub_83EF:  ; xrefs(2): $836A $83A9
83EF  20 46 84 JSR $8446                 
83F2  A9 0C    LDA #$0C                  
83F4  20 85 89 JSR $8985                 
83F7  AD A2 05 LDA $05A2                 
83FA  C9 13    CMP #$13                  
83FC  D0 19    BNE $8417                 
83FE  A0 48    LDY #$48                  
8400  20 18 84 JSR $8418                 
8403  A0 51    LDY #$51                  
8405  20 18 84 JSR $8418                 
8408  A0 5A    LDY #$5A                  
840A  20 18 84 JSR $8418                 
840D  A0 63    LDY #$63                  
840F  20 18 84 JSR $8418                 
8412  A9 00    LDA #$00                  
8414  20 89 A9 JSR $A989                 

loc_8417:  ; xrefs(1): $83FC
8417  60       RTS                       

sub_8418:  ; xrefs(4): $8400 $8405 $840A $840F
8418  A5 82    LDA $82                   
841A  85 92    STA $92                   
841C  A5 83    LDA $83                   
841E  85 93    STA $93                   
8420  A5 80    LDA $80                   
8422  85 90    STA $90                   
8424  A5 81    LDA $81                   
8426  85 91    STA $91                   
8428  8A       TXA                       
8429  48       PHA                       
842A  A2 07    LDX #$07                  
842C  4C FA AA JMP $AAFA                 

sub_842F:  ; xrefs(2): $836A $83A9
842F  BD 10 06 LDA $0610,X               
8432  85 50    STA $50                   
8434  BD 20 06 LDA $0620,X               
8437  85 51    STA $51                   
8439  BD 30 06 LDA $0630,X               
843C  85 52    STA $52                   
843E  BD 40 06 LDA $0640,X               
8441  85 53    STA $53                   
8443  4C 3F 81 JMP $813F                 

sub_8446:  ; xrefs(2): $83EF $845F
8446  A5 80    LDA $80                   
8448  95 A0    STA $A0,X                 
844A  A5 81    LDA $81                   
844C  95 B0    STA $B0,X                 
844E  A5 82    LDA $82                   
8450  95 C0    STA $C0,X                 
8452  A5 83    LDA $83                   
8454  95 D0    STA $D0,X                 
8456  60       RTS                       

sub_8457:  ; xrefs(2): $836A $83A9
8457  AD A6 05 LDA $05A6                 
845A  0D A7 05 ORA $05A7                 
845D  F0 3C    BEQ $849B                 
845F  20 46 84 JSR $8446                 
8462  20 A2 87 JSR $87A2                 
8465  9D 80 06 STA $0680,X               
8468  AD B5 05 LDA $05B5                 
846B  C9 0E    CMP #$0E                  
846D  D0 07    BNE $8476                 
846F  AD A4 05 LDA $05A4                 
8472  C9 FF    CMP #$FF                  
8474  D0 25    BNE $849B                 

loc_8476:  ; xrefs(1): $846D
8476  DE 10 06 DEC $0610,X               
8479  BD 10 06 LDA $0610,X               
847C  D0 08    BNE $8486                 
847E  A9 00    LDA #$00                  
8480  8D AF 05 STA $05AF                 
8483  4C 89 A9 JMP $A989                 

loc_8486:  ; xrefs(1): $847C
8486  C9 20    CMP #$20                  
8488  A0 E8    LDY #$E8                  
848A  90 06    BCC $8492                 
848C  29 08    AND #$08                  
848E  D0 0B    BNE $849B                 
8490  A0 E6    LDY #$E6                  

loc_8492:  ; xrefs(1): $848A
8492  98       TYA                       
8493  9D 60 06 STA $0660,X               
8496  A9 02    LDA #$02                  
8498  9D 70 06 STA $0670,X               

loc_849B:  ; xrefs(3): $845D $8474 $848E
849B  60       RTS                       

sub_849C:  ; xrefs(2): $836A $83A9
849C  A9 00    LDA #$00                  
849E  F0 02    BEQ $84A2                 

sub_84A0:  ; xrefs(2): $836A $83A9
84A0  A9 FF    LDA #$FF                  

loc_84A2:  ; xrefs(1): $849E
84A2  9D 80 06 STA $0680,X               
84A5  A9 79    LDA #$79                  
84A7  4C 4B 90 JMP $904B                 

sub_84AA:  ; xrefs(1): $836A
84AA  A9 02    LDA #$02                  
84AC  9D E0 06 STA $06E0,X               
84AF  DE 40 06 DEC $0640,X               
84B2  D0 05    BNE $84B9                 
84B4  A0 BD    LDY #$BD                  
84B6  4C 6A 8F JMP $8F6A                 

loc_84B9:  ; xrefs(1): $84B2
84B9  60       RTS                       

sub_84BA:  ; xrefs(1): $83A9
84BA  A5 0C    LDA $0C                   
84BC  29 0F    AND #$0F                  
84BE  D0 06    BNE $84C6                 
84C0  FE 10 06 INC $0610,X               
84C3  20 6D 8A JSR $8A6D                 

loc_84C6:  ; xrefs(1): $84BE
84C6  20 30 AE JSR $AE30                 
84C9  D0 08    BNE $84D3                 
84CB  20 5E AE JSR $AE5E                 
84CE  D0 03    BNE $84D3                 
84D0  20 BF 80 JSR $80BF                 

loc_84D3:  ; xrefs(2): $84C9 $84CE
84D3  4C 3F 81 JMP $813F                 

sub_84D6:  ; xrefs(1): $83A9
84D6  20 30 AE JSR $AE30                 
84D9  C9 04    CMP #$04                  
84DB  90 01    BCC $84DE                 

loc_84DD:  ; xrefs(1): $84E2
84DD  60       RTS                       

loc_84DE:  ; xrefs(1): $84DB
84DE  8A       TXA                       
84DF  45 0C    EOR $0C                   
84E1  6A       ROR A                     
84E2  90 F9    BCC $84DD                 
84E4  20 43 80 JSR $8043                 
84E7  49 20    EOR #$20                  
84E9  9D 10 06 STA $0610,X               
84EC  4C 6D 8A JMP $8A6D                 

sub_84EF:  ; xrefs(1): $83A9
84EF  8A       TXA                       
84F0  45 0C    EOR $0C                   
84F2  6A       ROR A                     
84F3  B0 05    BCS $84FA                 
84F5  A9 78    LDA #$78                  
84F7  4C 4B 90 JMP $904B                 

loc_84FA:  ; xrefs(1): $84F3
84FA  60       RTS                       

sub_84FB:  ; xrefs(1): $83A9
84FB  BD 20 06 LDA $0620,X               
84FE  D0 14    BNE $8514                 
8500  20 30 AE JSR $AE30                 
8503  C9 03    CMP #$03                  
8505  B0 07    BCS $850E                 
8507  A9 3C    LDA #$3C                  
8509  85 F1    STA $F1                   
850B  DE 20 06 DEC $0620,X               

loc_850E:  ; xrefs(3): $8505 $8536 $8542
850E  A9 0F    LDA #$0F                  
8510  9D E0 06 STA $06E0,X               
8513  60       RTS                       

loc_8514:  ; xrefs(1): $84FE
8514  10 29    BPL $853F                 
8516  20 AA B0 JSR $B0AA                 
8519  20 CD 87 JSR $87CD                 
851C  10 1A    BPL $8538                 
851E  A9 07    LDA #$07                  
8520  8D F7 05 STA $05F7                 
8523  95 C0    STA $C0,X                 
8525  20 37 A9 JSR $A937                 
8528  A0 BD    LDY #$BD                  
852A  20 F1 AA JSR $AAF1                 
852D  A5 33    LDA $33                   
852F  95 D0    STA $D0,X                 
8531  A9 70    LDA #$70                  
8533  9D 20 06 STA $0620,X               
8536  D0 D6    BNE $850E                 

loc_8538:  ; xrefs(1): $851C
8538  A9 40    LDA #$40                  
853A  85 52    STA $52                   
853C  4C 3F 81 JMP $813F                 

loc_853F:  ; xrefs(1): $8514
853F  DE 20 06 DEC $0620,X               
8542  4C 0E 85 JMP $850E                 

sub_8545:  ; xrefs(2): $836A $83A9
8545  A9 77    LDA #$77                  
8547  20 4B 90 JSR $904B                 
854A  BD D0 06 LDA $06D0,X               
854D  6A       ROR A                     
854E  B0 15    BCS $8565                 
8550  20 BA AD JSR $ADBA                 
8553  30 10    BMI $8565                 
8555  A9 AC    LDA #$AC                  
8557  20 7B 90 JSR $907B                 
855A  99 D0 07 STA $07D0,Y               
855D  A9 04    LDA #$04                  
855F  99 E0 07 STA $07E0,Y               
8562  4C C2 A1 JMP $A1C2                 

loc_8565:  ; xrefs(2): $854E $8553
8565  60       RTS                       

sub_8566:  ; xrefs(1): $83A9
8566  A0 76    LDY #$76                  
8568  A9 FF    LDA #$FF                  
856A  D0 04    BNE $8570                 

sub_856C:  ; xrefs(1): $83A9
856C  A0 75    LDY #$75                  
856E  A9 00    LDA #$00                  

loc_8570:  ; xrefs(1): $856A
8570  9D 80 06 STA $0680,X               
8573  98       TYA                       
8574  20 4B 90 JSR $904B                 
8577  20 E6 80 JSR $80E6                 
857A  D0 03    BNE $857F                 
857C  4C F2 80 JMP $80F2                 

loc_857F:  ; xrefs(1): $857A
857F  C9 03    CMP #$03                  
8581  D0 66    BNE $85E9                 
8583  FE 40 06 INC $0640,X               
8586  BD 40 06 LDA $0640,X               
8589  6A       ROR A                     
858A  B0 13    BCS $859F                 
858C  A0 00    LDY #$00                  
858E  20 AB 85 JSR $85AB                 
8591  A0 01    LDY #$01                  
8593  20 AB 85 JSR $85AB                 
8596  A0 02    LDY #$02                  
8598  20 AB 85 JSR $85AB                 
859B  A0 03    LDY #$03                  
859D  D0 0C    BNE $85AB                 

loc_859F:  ; xrefs(1): $858A
859F  A0 04    LDY #$04                  
85A1  20 AB 85 JSR $85AB                 
85A4  A0 05    LDY #$05                  
85A6  20 AB 85 JSR $85AB                 
85A9  A0 06    LDY #$06                  

sub_85AB:  ; xrefs(6): $858E $8593 $8598 $859D $85A1 $85A6
85AB  B9 BD 85 LDA $85BD,Y               
85AE  85 94    STA $94                   
85B0  B9 B8 85 LDA $85B8,Y               
85B3  85 95    STA $95                   
85B5  4C C4 85 JMP $85C4                 

; ---- data $85B8-$85C3 (12 bytes) ----
85B8  00 E4 E4 00 EF E0 F0 10 20 E4 00 1B              |........ ...

loc_85C4:  ; xrefs(2): $85B5 $8F0F
85C4  A9 2C    LDA #$2C                  
85C6  85 F1    STA $F1                   
85C8  20 BA AD JSR $ADBA                 
85CB  30 1C    BMI $85E9                 
85CD  A9 AB    LDA #$AB                  
85CF  20 7B 90 JSR $907B                 
85D2  A5 94    LDA $94                   
85D4  99 D0 07 STA $07D0,Y               
85D7  BD 80 06 LDA $0680,X               
85DA  0A       ASL A                     
85DB  A5 95    LDA $95                   
85DD  90 04    BCC $85E3                 
85DF  49 FF    EOR #$FF                  
85E1  69 00    ADC #$00                  

loc_85E3:  ; xrefs(1): $85DD
85E3  99 E0 07 STA $07E0,Y               
85E6  4C C2 A1 JMP $A1C2                 

loc_85E9:  ; xrefs(2): $8581 $85CB
85E9  60       RTS                       

sub_85EA:  ; xrefs(1): $83A9
85EA  A9 00    LDA #$00                  
85EC  F0 02    BEQ $85F0                 

sub_85EE:  ; xrefs(1): $83A9
85EE  A9 FF    LDA #$FF                  

loc_85F0:  ; xrefs(1): $85EC
85F0  9D 80 06 STA $0680,X               
85F3  A9 74    LDA #$74                  
85F5  20 4B 90 JSR $904B                 
85F8  20 2D AE JSR $AE2D                 
85FB  A5 93    LDA $93                   
85FD  C9 02    CMP #$02                  
85FF  B0 1A    BCS $861B                 
8601  A5 94    LDA $94                   
8603  5D 80 06 EOR $0680,X               
8606  30 13    BMI $861B                 
8608  BD 80 06 LDA $0680,X               
860B  0A       ASL A                     
860C  A0 00    LDY #$00                  
860E  A9 10    LDA #$10                  
8610  B0 03    BCS $8615                 
8612  A9 F0    LDA #$F0                  
8614  88       DEY                       

loc_8615:  ; xrefs(1): $8610
8615  8D A8 05 STA $05A8                 
8618  8C A9 05 STY $05A9                 

loc_861B:  ; xrefs(2): $85FF $8606
861B  60       RTS                       

sub_861C:  ; xrefs(1): $83A9
861C  BD 40 06 LDA $0640,X               
861F  F0 2D    BEQ $864E                 
8621  A9 73    LDA #$73                  
8623  20 4B 90 JSR $904B                 
8626  A5 0C    LDA $0C                   
8628  6A       ROR A                     
8629  90 30    BCC $865B                 
862B  29 03    AND #$03                  
862D  D0 03    BNE $8632                 
862F  20 2B 80 JSR $802B                 

loc_8632:  ; xrefs(1): $862D
8632  20 66 80 JSR $8066                 
8635  B5 D0    LDA $D0,X                 
8637  C9 6B    CMP #$6B                  
8639  B0 09    BCS $8644                 
863B  A5 53    LDA $53                   
863D  10 05    BPL $8644                 
863F  20 33 81 JSR $8133                 
8642  F0 07    BEQ $864B                 

loc_8644:  ; xrefs(2): $8639 $863D
8644  A5 53    LDA $53                   
8646  0A       ASL A                     
8647  66 53    ROR $53                   
8649  66 52    ROR $52                   

loc_864B:  ; xrefs(1): $8642
864B  4C 3F 81 JMP $813F                 

loc_864E:  ; xrefs(1): $861F
864E  A9 72    LDA #$72                  
8650  20 4B 90 JSR $904B                 
8653  20 E0 80 JSR $80E0                 
8656  D0 03    BNE $865B                 
8658  FE 40 06 INC $0640,X               

loc_865B:  ; xrefs(2): $8629 $8656
865B  60       RTS                       

; ---- data $865C-$86A0 (69 bytes) ----
865C  A5 33 95 D0 18 A5 0E 29 0F 65 31 95 B0 8A 45 0C  |.3.....).e1...E.
866C  29 3F D0 30 48 A5 55 C9 01 D0 06 A5 31 C9 70 B0  |)?.0H.U.....1.p.
867C  0C A5 55 C9 02 D0 0A A5 33 C9 90 B0 04 68 4C B9  |..U.....3....hL.
868C  80 20 BA AD 30 0E A9 AF 20 7B 90 20 C2 A1 A9 40  |. ..0... {. ...@
869C  99 D0 07 68 60                                   |...h`

sub_86A1:  ; xrefs(1): $83A9
86A1  A9 6C    LDA #$6C                  
86A3  20 4B 90 JSR $904B                 
86A6  20 5E AE JSR $AE5E                 
86A9  20 18 81 JSR $8118                 
86AC  20 E0 80 JSR $80E0                 
86AF  D0 17    BNE $86C8                 
86B1  A5 91    LDA $91                   
86B3  C9 08    CMP #$08                  
86B5  B0 11    BCS $86C8                 
86B7  A5 95    LDA $95                   
86B9  30 08    BMI $86C3                 
86BB  A5 93    LDA $93                   
86BD  C9 02    CMP #$02                  
86BF  A9 02    LDA #$02                  
86C1  B0 02    BCS $86C5                 

loc_86C3:  ; xrefs(1): $86B9
86C3  A9 04    LDA #$04                  

loc_86C5:  ; xrefs(1): $86C1
86C5  9D 90 06 STA $0690,X               

loc_86C8:  ; xrefs(2): $86AF $86B5
86C8  60       RTS                       

sub_86C9:  ; xrefs(1): $83A9
86C9  A9 6D    LDA #$6D                  
86CB  20 4B 90 JSR $904B                 
86CE  20 E6 80 JSR $80E6                 
86D1  D0 4B    BNE $871E                 
86D3  A0 00    LDY #$00                  
86D5  20 EA 86 JSR $86EA                 
86D8  A0 01    LDY #$01                  
86DA  20 EA 86 JSR $86EA                 
86DD  A0 02    LDY #$02                  
86DF  20 EA 86 JSR $86EA                 
86E2  A0 03    LDY #$03                  
86E4  20 EA 86 JSR $86EA                 
86E7  4C 1E 87 JMP $871E                 

sub_86EA:  ; xrefs(4): $86D5 $86DA $86DF $86E4
86EA  B9 21 87 LDA $8721,Y               
86ED  85 94    STA $94                   
86EF  B9 25 87 LDA $8725,Y               
86F2  85 95    STA $95                   
86F4  20 BA AD JSR $ADBA                 
86F7  30 25    BMI $871E                 
86F9  A9 2C    LDA #$2C                  
86FB  85 F1    STA $F1                   
86FD  A9 AA    LDA #$AA                  
86FF  20 7B 90 JSR $907B                 
8702  20 21 81 JSR $8121                 
8705  C6 93    DEC $93                   
8707  BD 80 06 LDA $0680,X               
870A  0A       ASL A                     
870B  A5 94    LDA $94                   
870D  B0 04    BCS $8713                 
870F  49 FF    EOR #$FF                  
8711  69 01    ADC #$01                  

loc_8713:  ; xrefs(1): $870D
8713  99 D0 07 STA $07D0,Y               
8716  A5 95    LDA $95                   
8718  99 E0 07 STA $07E0,Y               
871B  4C D7 A1 JMP $A1D7                 

loc_871E:  ; xrefs(3): $86D1 $86E7 $86F7
871E  4C 5E 87 JMP $875E                 

; ---- data $8721-$8728 (8 bytes) ----
8721  1E 1A 13 09 F6 ED E6 E2                          |........

sub_8729:  ; xrefs(1): $83A9
8729  A9 6E    LDA #$6E                  
872B  20 4B 90 JSR $904B                 
872E  20 E6 80 JSR $80E6                 
8731  D0 2B    BNE $875E                 
8733  20 BA AD JSR $ADBA                 
8736  30 26    BMI $875E                 
8738  A9 28    LDA #$28                  
873A  85 F1    STA $F1                   
873C  A9 A9    LDA #$A9                  
873E  20 7B 90 JSR $907B                 
8741  20 21 81 JSR $8121                 
8744  C6 93    DEC $93                   
8746  A9 80    LDA #$80                  
8748  85 92    STA $92                   
874A  BD 80 06 LDA $0680,X               
874D  0A       ASL A                     
874E  E6 91    INC $91                   
8750  A9 10    LDA #$10                  
8752  B0 04    BCS $8758                 
8754  C6 91    DEC $91                   
8756  A9 F0    LDA #$F0                  

loc_8758:  ; xrefs(1): $8752
8758  99 D0 07 STA $07D0,Y               
875B  20 D7 A1 JSR $A1D7                 

loc_875E:  ; xrefs(3): $871E $8731 $8736
875E  20 E0 80 JSR $80E0                 
8761  D0 03    BNE $8766                 
8763  4C B3 80 JMP $80B3                 

loc_8766:  ; xrefs(1): $8761
8766  60       RTS                       

sub_8767:  ; xrefs(2): $836A $83A9
8767  DE 40 06 DEC $0640,X               
876A  D0 27    BNE $8793                 
876C  8A       TXA                       
876D  45 0C    EOR $0C                   
876F  A8       TAY                       
8770  29 03    AND #$03                  
8772  D0 1A    BNE $878E                 
8774  A9 2F    LDA #$2F                  
8776  85 F1    STA $F1                   
8778  98       TYA                       
8779  29 07    AND #$07                  
877B  D0 11    BNE $878E                 
877D  A0 EA    LDY #$EA                  
877F  20 F1 AA JSR $AAF1                 
8782  DE 30 06 DEC $0630,X               
8785  D0 07    BNE $878E                 
8787  A9 07    LDA #$07                  
8789  9D 30 06 STA $0630,X               
878C  D0 0C    BNE $879A                 

loc_878E:  ; xrefs(3): $8772 $877B $8785
878E  FE 40 06 INC $0640,X               
8791  D0 07    BNE $879A                 

loc_8793:  ; xrefs(1): $876A
8793  BD 40 06 LDA $0640,X               
8796  C9 30    CMP #$30                  
8798  90 03    BCC $879D                 

loc_879A:  ; xrefs(2): $878C $8791
879A  4C A2 87 JMP $87A2                 

loc_879D:  ; xrefs(1): $8798
879D  A9 6F    LDA #$6F                  
879F  4C 4B 90 JMP $904B                 

sub_87A2:  ; xrefs(2): $8462 $879A
87A2  A9 00    LDA #$00                  
87A4  9D 60 06 STA $0660,X               
87A7  9D 70 06 STA $0670,X               
87AA  60       RTS                       

sub_87AB:  ; xrefs(2): $836A $83A9
87AB  A9 70    LDA #$70                  
87AD  20 4B 90 JSR $904B                 
87B0  BD D0 06 LDA $06D0,X               
87B3  C9 01    CMP #$01                  
87B5  D0 01    BNE $87B8                 
87B7  60       RTS                       

loc_87B8:  ; xrefs(1): $87B5
87B8  20 E0 80 JSR $80E0                 
87BB  D0 03    BNE $87C0                 
87BD  20 B9 80 JSR $80B9                 

loc_87C0:  ; xrefs(1): $87BB
87C0  A9 C0    LDA #$C0                  
87C2  85 50    STA $50                   
87C4  C6 51    DEC $51                   
87C6  A9 40    LDA #$40                  
87C8  85 52    STA $52                   
87CA  4C 3F 81 JMP $813F                 

sub_87CD:  ; xrefs(1): $8519
87CD  BC 10 06 LDY $0610,X               
87D0  9D 10 06 STA $0610,X               
87D3  30 28    BMI $87FD                 
87D5  98       TYA                       
87D6  DD 10 06 CMP $0610,X               
87D9  F0 22    BEQ $87FD                 
87DB  29 78    AND #$78                  
87DD  C9 60    CMP #$60                  
87DF  90 1C    BCC $87FD                 
87E1  29 18    AND #$18                  
87E3  F0 04    BEQ $87E9                 
87E5  C9 10    CMP #$10                  
87E7  90 14    BCC $87FD                 

loc_87E9:  ; xrefs(1): $87E3
87E9  A5 55    LDA $55                   
87EB  C9 09    CMP #$09                  
87ED  F0 0E    BEQ $87FD                 
87EF  A9 00    LDA #$00                  
87F1  20 E2 AA JSR $AAE2                 
87F4  A0 36    LDY #$36                  
87F6  20 C2 AA JSR $AAC2                 
87F9  A9 09    LDA #$09                  
87FB  85 F1    STA $F1                   

loc_87FD:  ; xrefs(5): $87D3 $87D9 $87DF $87E7 $87ED
87FD  BC 10 06 LDY $0610,X               
8800  98       TYA                       
8801  60       RTS                       

sub_8802:  ; xrefs(1): $81EA
8802  8A       TXA                       
8803  45 0C    EOR $0C                   
8805  6A       ROR A                     
8806  B0 01    BCS $8809                 
8808  60       RTS                       

loc_8809:  ; xrefs(1): $8806
8809  BC 90 06 LDY $0690,X               
880C  B9 19 88 LDA $8819,Y               
880F  85 90    STA $90                   
8811  B9 1A 88 LDA $881A,Y               
8814  85 91    STA $91                   
8816  6C 90 00 JMP ($0090)               

; ---- data $8819-$897D (357 bytes) ----
8819  82 88 26 89 18 89 46 89 F3 88 72 88 2D 88 29 88  |..&...F...r.-.).
8829  A9 13 D0 02 A9 12 20 85 89 20 8A 89 C9 05 B0 33  |...... .. .....3
8839  C9 03 B0 0B BD 90 06 C9 0E F0 04 A9 0A D0 26 20  |..............& 
8849  E6 80 D0 24 20 BA AD 30 1F 20 24 AE A9 AD 20 7B  |...$ ..0. $... {
8859  90 20 CB 8E 20 21 81 C6 93 A9 C0 85 92 20 D7 A1  |. .. !....... ..
8869  4C 24 AE A9 00 9D 90 06 60 20 18 81 A5 91 C9 06  |L$......` ......
8879  90 14 20 24 AE 4C B3 80 60 20 8A 89 C9 05 B0 06  |.. $.L..` ......
8889  A9 08 9D 90 06 60 A9 0D 20 85 89 20 AA B0 20 CD  |.....`.. .. .. .
8899  87 30 11 A9 00 20 AC B0 30 0A A9 06 9D 90 06 A9  |.0... ..0.......
88A9  FF 4C 63 81 20 33 81 A9 10 95 C0 A9 20 85 50 20  |.Lc. 3...... .P 
88B9  8F B0 10 33 20 2C 81 A9 80 85 92 A9 FF 85 93 A9  |...3 ,..........
88C9  20 85 50 20 97 B0 30 0D A9 02 9D 90 06 A9 B0 20  | .P ..0........ 
88D9  63 81 4C 3F 81 BD 90 06 C9 0A D0 08 20 9D BD A9  |c.L?........ ...
88E9  0E 9D 90 06 20 2C 81 4C 3F 81 20 30 AE C9 04 B0  |.... ,.L?. 0....
88F9  06 A9 0C 9D 90 06 60 C9 08 90 03 20 B3 80 A9 0E  |......`.... ....
8909  20 85 89 20 8A 89 20 E6 80 D0 03 20 94 88 60 A9  | .. .. .... ..`.
8919  0F 20 85 89 20 E0 80 D0 03 4C B3 80 60 A9 0C 85  |. .. ....L..`...
8929  50 20 8F B0 30 14 20 2C 81 A9 80 85 92 A9 FF 85  |P ..0. ,........
8939  93 A9 0C 85 50 20 97 B0 10 03 20 2C 81 A9 10 20  |....P .... ,... 
8949  85 89 A9 04 20 BB B2 BD 40 06 10 12 20 21 81 A9  |.... ...@... !..
8959  80 85 92 20 51 B1 20 CD 87 10 17 4C 5A 81 20 AA  |... Q. ....LZ. .
8969  B0 20 CD 87 10 0C 20 33 81 A9 10 95 C0 A9 04 9D  |. .... 3........
8979  90 06 4C 3F 81                                   |..L?.

sub_897E:  ; xrefs(1): $827B
897E  A9 11    LDA #$11                  
8980  A0 03    LDY #$03                  
8982  4C 67 AF JMP $AF67                 

sub_8985:  ; xrefs(12): $83F4 $9155 $A8AF $A90C $A973 $AA43 $B119 $B12D $B236 $B264
8985  A0 03    LDY #$03                  
8987  4C AB BD JMP $BDAB                 

; ---- data $898A-$8992 (9 bytes) ----
898A  20 18 81 20 24 AE A5 91 60                       | .. $...`

sub_8993:  ; xrefs(1): $827B
8993  20 1B 8C JSR $8C1B                 

sub_8996:  ; xrefs(1): $827B
8996  A9 08    LDA #$08                  
8998  85 52    STA $52                   
899A  D0 05    BNE $89A1                 

sub_899C:  ; xrefs(1): $827B
899C  A9 07    LDA #$07                  
899E  20 4B 90 JSR $904B                 

loc_89A1:  ; xrefs(1): $899A
89A1  FE 10 06 INC $0610,X               
89A4  BD 10 06 LDA $0610,X               
89A7  C9 50    CMP #$50                  
89A9  90 1E    BCC $89C9                 
89AB  C9 64    CMP #$64                  
89AD  90 26    BCC $89D5                 
89AF  A9 02    LDA #$02                  
89B1  20 19 83 JSR $8319                 
89B4  BD 50 06 LDA $0650,X               
89B7  29 3F    AND #$3F                  
89B9  C9 10    CMP #$10                  
89BB  F0 03    BEQ $89C0                 
89BD  20 6C 90 JSR $906C                 

loc_89C0:  ; xrefs(1): $89BB
89C0  A9 21    LDA #$21                  
89C2  85 F1    STA $F1                   
89C4  A9 32    LDA #$32                  
89C6  4C 89 A9 JMP $A989                 

loc_89C9:  ; xrefs(1): $89A9
89C9  20 3F 81 JSR $813F                 
89CC  A5 0C    LDA $0C                   
89CE  29 07    AND #$07                  
89D0  D0 03    BNE $89D5                 
89D2  4C 8A 92 JMP $928A                 

loc_89D5:  ; xrefs(2): $89AD $89D0
89D5  60       RTS                       

; ---- data $89D6-$8A28 (83 bytes) ----
89D6  20 18 81 DE 20 06 D0 03 FE 90 06 BD 20 06 C9 40  | ... ....... ..@
89E6  D0 26 20 BA AD 30 39 A9 AE 20 7B 90 20 CB 8E E6  |.& ..09.. {. ...
89F6  93 20 D7 A1 BD 80 06 0A A9 20 A0 00 90 03 A9 E0  |. ....... ......
8A06  88 9D 30 06 98 9D 40 06 20 95 8B 20 8A 8B A5 0C  |..0...@. .. ....
8A16  6A 90 0D BD 10 06 29 FE 69 01 9D 10 06 4C 7B 8A  |j.....).i....L{.
8A26  4C 3F 81                                         |L?.

loc_8A29:  ; xrefs(1): $8A3B
8A29  A9 80    LDA #$80                  
8A2B  20 9C 8A JSR $8A9C                 

loc_8A2E:  ; xrefs(1): $8A52
8A2E  A9 05    LDA #$05                  
8A30  4C 28 90 JMP $9028                 

sub_8A33:  ; xrefs(1): $81EA
8A33  A0 40    LDY #$40                  
8A35  20 6E 90 JSR $906E                 
8A38  BD A0 06 LDA $06A0,X               
8A3B  D0 EC    BNE $8A29                 
8A3D  20 18 81 JSR $8118                 
8A40  20 73 81 JSR $8173                 
8A43  D0 10    BNE $8A55                 
8A45  20 DA 80 JSR $80DA                 
8A48  D0 0B    BNE $8A55                 
8A4A  BD 10 06 LDA $0610,X               
8A4D  49 20    EOR #$20                  
8A4F  9D 10 06 STA $0610,X               
8A52  4C 2E 8A JMP $8A2E                 

loc_8A55:  ; xrefs(2): $8A43 $8A48
8A55  A9 67    LDA #$67                  
8A57  20 4B 90 JSR $904B                 
8A5A  BD 40 06 LDA $0640,X               
8A5D  F0 06    BEQ $8A65                 
8A5F  DE 40 06 DEC $0640,X               
8A62  4C 73 8A JMP $8A73                 

loc_8A65:  ; xrefs(1): $8A5D
8A65  A5 0C    LDA $0C                   
8A67  6A       ROR A                     
8A68  90 03    BCC $8A6D                 
8A6A  20 2B 80 JSR $802B                 

sub_8A6D:  ; xrefs(3): $84C3 $84EC $8A68
8A6D  20 66 80 JSR $8066                 
8A70  4C 3F 81 JMP $813F                 

loc_8A73:  ; xrefs(1): $8A62
8A73  A5 0C    LDA $0C                   
8A75  6A       ROR A                     
8A76  90 09    BCC $8A81                 
8A78  FE 10 06 INC $0610,X               
8A7B  20 66 80 JSR $8066                 
8A7E  20 2C 81 JSR $812C                 

loc_8A81:  ; xrefs(1): $8A76
8A81  4C 3F 81 JMP $813F                 

loc_8A84:  ; xrefs(1): $8AAA
8A84  A9 7B    LDA #$7B                  
8A86  20 28 90 JSR $9028                 
8A89  BD A0 06 LDA $06A0,X               
8A8C  D0 0C    BNE $8A9A                 
8A8E  A5 0E    LDA $0E                   
8A90  6A       ROR A                     
8A91  A9 02    LDA #$02                  
8A93  90 02    BCC $8A97                 
8A95  A9 05    LDA #$05                  

loc_8A97:  ; xrefs(1): $8A93
8A97  9D 90 06 STA $0690,X               

loc_8A9A:  ; xrefs(1): $8A8C
8A9A  A9 40    LDA #$40                  

sub_8A9C:  ; xrefs(1): $8A2B
8A9C  20 79 81 JSR $8179                 
8A9F  4C 3F 81 JMP $813F                 

sub_8AA2:  ; xrefs(1): $81EA
8AA2  A0 40    LDY #$40                  
8AA4  20 6E 90 JSR $906E                 
8AA7  BD A0 06 LDA $06A0,X               
8AAA  D0 D8    BNE $8A84                 
8AAC  20 73 81 JSR $8173                 
8AAF  D0 10    BNE $8AC1                 
8AB1  20 DA 80 JSR $80DA                 
8AB4  D0 0B    BNE $8AC1                 
8AB6  20 1C B2 JSR $B21C                 
8AB9  20 18 81 JSR $8118                 
8ABC  A9 7B    LDA #$7B                  
8ABE  4C 28 90 JMP $9028                 

loc_8AC1:  ; xrefs(2): $8AAF $8AB4
8AC1  A9 7A    LDA #$7A                  
8AC3  20 4B 90 JSR $904B                 
8AC6  20 30 AE JSR $AE30                 
8AC9  C9 0E    CMP #$0E                  
8ACB  90 03    BCC $8AD0                 
8ACD  20 6C 90 JSR $906C                 

loc_8AD0:  ; xrefs(1): $8ACB
8AD0  20 E1 8A JSR $8AE1                 
8AD3  38       SEC                       
8AD4  A5 52    LDA $52                   
8AD6  E5 34    SBC $34                   
8AD8  85 52    STA $52                   
8ADA  B0 02    BCS $8ADE                 
8ADC  C6 53    DEC $53                   

loc_8ADE:  ; xrefs(1): $8ADA
8ADE  4C 3F 81 JMP $813F                 

sub_8AE1:  ; xrefs(1): $8AD0
8AE1  BD 90 06 LDA $0690,X               
8AE4  20 10 80 JSR $8010                 
8AE7  20 8B D6 JSR $D68B                 
8AEA  89 F9    NOP #$F9                  
8AEC  8A       TXA                       
8AED  20 8B D6 JSR $D68B                 
8AF0  89 F5    NOP #$F5                  
8AF2  8A       TXA                       
8AF3  B3 80    LAX ($80),Y               
8AF5  A9 F0    LDA #$F0                  
8AF7  D0 02    BNE $8AFB                 
8AF9  A9 10    LDA #$10                  

loc_8AFB:  ; xrefs(1): $8AF7
8AFB  85 52    STA $52                   
8AFD  20 4D 8B JSR $8B4D                 
8B00  20 18 81 JSR $8118                 
8B03  A5 52    LDA $52                   
8B05  10 02    BPL $8B09                 
8B07  C6 53    DEC $53                   

loc_8B09:  ; xrefs(1): $8B05
8B09  20 5E AE JSR $AE5E                 
8B0C  C9 08    CMP #$08                  
8B0E  B0 04    BCS $8B14                 
8B10  C9 03    CMP #$03                  
8B12  90 06    BCC $8B1A                 

loc_8B14:  ; xrefs(1): $8B0E
8B14  9D 20 06 STA $0620,X               
8B17  FE 90 06 INC $0690,X               

loc_8B1A:  ; xrefs(1): $8B12
8B1A  20 2C 81 JSR $812C                 
8B1D  4C 3F 81 JMP $813F                 

; ---- data $8B20-$8B4C (45 bytes) ----
8B20  20 4D 8B A9 08 85 52 20 5E AE A5 95 30 03 20 8F  | M....R ^...0. .
8B30  81 A5 95 10 17 A5 93 C9 01 D0 11 38 A5 5D E9 01  |...........8.]..
8B40  C9 0E B0 08 A9 80 9D 20 06 FE 90 06 60           |....... ....`

sub_8B4D:  ; xrefs(1): $8AFD
8B4D  A9 00    LDA #$00                  
8B4F  9D 20 06 STA $0620,X               
8B52  4C 55 8B JMP $8B55                 

loc_8B55:  ; xrefs(1): $8B52
8B55  20 18 81 JSR $8118                 
8B58  BD 80 06 LDA $0680,X               
8B5B  5D 40 06 EOR $0640,X               
8B5E  10 15    BPL $8B75                 
8B60  BD 20 06 LDA $0620,X               
8B63  6A       ROR A                     
8B64  B0 23    BCS $8B89                 
8B66  A0 01    LDY #$01                  
8B68  BD 40 06 LDA $0640,X               
8B6B  10 02    BPL $8B6F                 
8B6D  A0 FF    LDY #$FF                  

loc_8B6F:  ; xrefs(1): $8B6B
8B6F  20 9E 8B JSR $8B9E                 
8B72  4C 85 8B JMP $8B85                 

loc_8B75:  ; xrefs(1): $8B5E
8B75  BD 20 06 LDA $0620,X               
8B78  6A       ROR A                     
8B79  6A       ROR A                     
8B7A  B0 0D    BCS $8B89                 
8B7C  A5 94    LDA $94                   
8B7E  C9 02    CMP #$02                  
8B80  90 03    BCC $8B85                 
8B82  20 95 8B JSR $8B95                 

loc_8B85:  ; xrefs(2): $8B72 $8B80
8B85  20 8A 8B JSR $8B8A                 
8B88  18       CLC                       

loc_8B89:  ; xrefs(2): $8B64 $8B7A
8B89  60       RTS                       

sub_8B8A:  ; xrefs(2): $8311 $8B85
8B8A  BD 30 06 LDA $0630,X               
8B8D  85 50    STA $50                   
8B8F  BD 40 06 LDA $0640,X               
8B92  85 51    STA $51                   
8B94  60       RTS                       

sub_8B95:  ; xrefs(1): $8B82
8B95  A0 FE    LDY #$FE                  
8B97  BD 40 06 LDA $0640,X               
8B9A  10 02    BPL $8B9E                 
8B9C  A0 02    LDY #$02                  

sub_8B9E:  ; xrefs(2): $8B6F $8B9A
8B9E  84 96    STY $96                   
8BA0  A9 00    LDA #$00                  
8BA2  85 97    STA $97                   
8BA4  A5 96    LDA $96                   
8BA6  10 02    BPL $8BAA                 
8BA8  C6 97    DEC $97                   

loc_8BAA:  ; xrefs(1): $8BA6
8BAA  18       CLC                       
8BAB  7D 30 06 ADC $0630,X               
8BAE  9D 30 06 STA $0630,X               
8BB1  BD 40 06 LDA $0640,X               
8BB4  65 97    ADC $97                   
8BB6  9D 40 06 STA $0640,X               
8BB9  60       RTS                       

sub_8BBA:  ; xrefs(1): $81EA
8BBA  A9 6B    LDA #$6B                  
8BBC  20 4B 90 JSR $904B                 
8BBF  20 E6 80 JSR $80E6                 
8BC2  D0 06    BNE $8BCA                 
8BC4  A9 32    LDA #$32                  
8BC6  85 F1    STA $F1                   
8BC8  D0 0C    BNE $8BD6                 

loc_8BCA:  ; xrefs(1): $8BC2
8BCA  A0 08    LDY #$08                  
8BCC  C9 05    CMP #$05                  
8BCE  F0 2A    BEQ $8BFA                 
8BD0  A0 F8    LDY #$F8                  
8BD2  C9 07    CMP #$07                  
8BD4  F0 24    BEQ $8BFA                 

loc_8BD6:  ; xrefs(3): $8BC8 $8BFF $8C18
8BD6  BD 40 06 LDA $0640,X               
8BD9  6A       ROR A                     
8BDA  B0 0C    BCS $8BE8                 
8BDC  A9 08    LDA #$08                  
8BDE  85 50    STA $50                   
8BE0  B5 B0    LDA $B0,X                 
8BE2  C9 3F    CMP #$3F                  
8BE4  B0 0E    BCS $8BF4                 
8BE6  90 0F    BCC $8BF7                 

loc_8BE8:  ; xrefs(1): $8BDA
8BE8  A9 F8    LDA #$F8                  
8BEA  85 50    STA $50                   
8BEC  C6 51    DEC $51                   
8BEE  B5 B0    LDA $B0,X                 
8BF0  C9 31    CMP #$31                  
8BF2  B0 03    BCS $8BF7                 

loc_8BF4:  ; xrefs(1): $8BE4
8BF4  FE 40 06 INC $0640,X               

loc_8BF7:  ; xrefs(2): $8BE6 $8BF2
8BF7  4C 1B 8C JMP $8C1B                 

loc_8BFA:  ; xrefs(2): $8BCE $8BD4
8BFA  84 94    STY $94                   
8BFC  20 BA AD JSR $ADBA                 
8BFF  30 D5    BMI $8BD6                 
8C01  A5 94    LDA $94                   
8C03  99 E0 07 STA $07E0,Y               
8C06  A9 20    LDA #$20                  
8C08  99 D0 07 STA $07D0,Y               
8C0B  A9 A8    LDA #$A8                  
8C0D  20 7B 90 JSR $907B                 
8C10  20 21 81 JSR $8121                 
8C13  E6 93    INC $93                   
8C15  20 D7 A1 JSR $A1D7                 
8C18  4C D6 8B JMP $8BD6                 

sub_8C1B:  ; xrefs(2): $8993 $8BF7
8C1B  A9 00    LDA #$00                  
8C1D  85 90    STA $90                   
8C1F  A5 75    LDA $75                   
8C21  69 18    ADC #$18                  
8C23  0A       ASL A                     
8C24  26 90    ROL $90                   
8C26  0A       ASL A                     
8C27  26 90    ROL $90                   
8C29  0A       ASL A                     
8C2A  26 90    ROL $90                   
8C2C  0A       ASL A                     
8C2D  26 90    ROL $90                   
8C2F  65 32    ADC $32                   
8C31  95 C0    STA $C0,X                 
8C33  A5 90    LDA $90                   
8C35  65 33    ADC $33                   
8C37  95 D0    STA $D0,X                 
8C39  A5 34    LDA $34                   
8C3B  85 52    STA $52                   
8C3D  4C 3F 81 JMP $813F                 

sub_8C40:  ; xrefs(1): $81EA
8C40  A9 6A    LDA #$6A                  
8C42  20 4B 90 JSR $904B                 
8C45  BD 40 06 LDA $0640,X               
8C48  6A       ROR A                     
8C49  B0 0C    BCS $8C57                 
8C4B  A9 04    LDA #$04                  
8C4D  85 50    STA $50                   
8C4F  B5 B0    LDA $B0,X                 
8C51  C9 4B    CMP #$4B                  
8C53  B0 0E    BCS $8C63                 
8C55  90 0F    BCC $8C66                 

loc_8C57:  ; xrefs(1): $8C49
8C57  A9 FC    LDA #$FC                  
8C59  85 50    STA $50                   
8C5B  C6 51    DEC $51                   
8C5D  B5 B0    LDA $B0,X                 
8C5F  C9 47    CMP #$47                  
8C61  B0 03    BCS $8C66                 

loc_8C63:  ; xrefs(1): $8C53
8C63  FE 40 06 INC $0640,X               

loc_8C66:  ; xrefs(2): $8C55 $8C61
8C66  20 EC 80 JSR $80EC                 
8C69  F0 11    BEQ $8C7C                 
8C6B  C9 01    CMP #$01                  
8C6D  F0 0D    BEQ $8C7C                 

loc_8C6F:  ; xrefs(1): $8C7F
8C6F  A5 50    LDA $50                   
8C71  9D 10 06 STA $0610,X               
8C74  A5 51    LDA $51                   
8C76  9D 20 06 STA $0620,X               
8C79  4C 3F 81 JMP $813F                 

loc_8C7C:  ; xrefs(2): $8C69 $8C6D
8C7C  20 BA AD JSR $ADBA                 
8C7F  30 EE    BMI $8C6F                 
8C81  8A       TXA                       
8C82  99 D0 07 STA $07D0,Y               
8C85  A9 04    LDA #$04                  
8C87  99 E0 07 STA $07E0,Y               
8C8A  A9 A7    LDA #$A7                  
8C8C  20 7B 90 JSR $907B                 
8C8F  A9 12    LDA #$12                  
8C91  85 F1    STA $F1                   
8C93  20 21 81 JSR $8121                 
8C96  A9 80    LDA #$80                  
8C98  85 90    STA $90                   
8C9A  A9 C0    LDA #$C0                  
8C9C  85 92    STA $92                   
8C9E  20 EC 80 JSR $80EC                 
8CA1  B0 02    BCS $8CA5                 
8CA3  C6 91    DEC $91                   

loc_8CA5:  ; xrefs(1): $8CA1
8CA5  4C D7 A1 JMP $A1D7                 

sub_8CA8:  ; xrefs(1): $81EA
8CA8  A9 68    LDA #$68                  
8CAA  20 4B 90 JSR $904B                 
8CAD  20 0D 81 JSR $810D                 
8CB0  49 FF    EOR #$FF                  
8CB2  9D 10 06 STA $0610,X               
8CB5  20 AA B0 JSR $B0AA                 
8CB8  10 08    BPL $8CC2                 
8CBA  A9 04    LDA #$04                  
8CBC  20 0A 9D JSR $9D0A                 
8CBF  4C 3F 81 JMP $813F                 

loc_8CC2:  ; xrefs(1): $8CB8
8CC2  A9 80    LDA #$80                  
8CC4  85 52    STA $52                   
8CC6  4C 3F 81 JMP $813F                 

sub_8CC9:  ; xrefs(1): $81EA
8CC9  BD 90 06 LDA $0690,X               
8CCC  F0 5F    BEQ $8D2D                 
8CCE  C9 02    CMP #$02                  
8CD0  90 72    BCC $8D44                 
8CD2  F0 37    BEQ $8D0B                 
8CD4  A9 66    LDA #$66                  
8CD6  20 4B 90 JSR $904B                 
8CD9  20 E6 80 JSR $80E6                 
8CDC  D0 46    BNE $8D24                 
8CDE  20 BA AD JSR $ADBA                 
8CE1  30 41    BMI $8D24                 
8CE3  A9 04    LDA #$04                  
8CE5  99 E0 07 STA $07E0,Y               
8CE8  A9 A4    LDA #$A4                  
8CEA  20 7B 90 JSR $907B                 
8CED  A9 13    LDA #$13                  
8CEF  85 F1    STA $F1                   
8CF1  20 21 81 JSR $8121                 
8CF4  C6 93    DEC $93                   
8CF6  C6 93    DEC $93                   
8CF8  A9 80    LDA #$80                  
8CFA  85 90    STA $90                   
8CFC  BD 80 06 LDA $0680,X               
8CFF  30 02    BMI $8D03                 
8D01  C6 91    DEC $91                   

loc_8D03:  ; xrefs(1): $8CFF
8D03  A9 D0    LDA #$D0                  
8D05  99 D0 07 STA $07D0,Y               
8D08  4C D7 A1 JMP $A1D7                 

loc_8D0B:  ; xrefs(1): $8CD2
8D0B  A9 65    LDA #$65                  
8D0D  20 4B 90 JSR $904B                 
8D10  20 E6 80 JSR $80E6                 
8D13  D0 0F    BNE $8D24                 
8D15  20 BA AD JSR $ADBA                 
8D18  30 0A    BMI $8D24                 
8D1A  A9 04    LDA #$04                  
8D1C  99 E0 07 STA $07E0,Y               
8D1F  A9 A5    LDA #$A5                  
8D21  4C BC 8E JMP $8EBC                 

loc_8D24:  ; xrefs(4): $8CDC $8CE1 $8D13 $8D18
8D24  20 E0 80 JSR $80E0                 
8D27  D0 03    BNE $8D2C                 
8D29  4C B3 80 JMP $80B3                 

loc_8D2C:  ; xrefs(1): $8D27
8D2C  60       RTS                       

loc_8D2D:  ; xrefs(1): $8CCC
8D2D  A9 64    LDA #$64                  
8D2F  9D 40 06 STA $0640,X               
8D32  20 4B 90 JSR $904B                 
8D35  86 90    STX $90                   
8D37  A5 0C    LDA $0C                   
8D39  2A       ROL A                     
8D3A  2A       ROL A                     
8D3B  45 90    EOR $90                   
8D3D  6A       ROR A                     
8D3E  90 03    BCC $8D43                 
8D40  4C B3 8E JMP $8EB3                 

loc_8D43:  ; xrefs(1): $8D3E
8D43  60       RTS                       

loc_8D44:  ; xrefs(1): $8CD0
8D44  DE 40 06 DEC $0640,X               
8D47  D0 03    BNE $8D4C                 
8D49  4C B3 80 JMP $80B3                 

loc_8D4C:  ; xrefs(1): $8D47
8D4C  A9 63    LDA #$63                  
8D4E  20 4B 90 JSR $904B                 
8D51  BD D0 06 LDA $06D0,X               
8D54  C9 03    CMP #$03                  
8D56  A9 00    LDA #$00                  
8D58  90 02    BCC $8D5C                 
8D5A  A9 FF    LDA #$FF                  

loc_8D5C:  ; xrefs(1): $8D58
8D5C  9D 80 06 STA $0680,X               
8D5F  20 2D AE JSR $AE2D                 
8D62  A5 92    LDA $92                   
8D64  C9 40    CMP #$40                  
8D66  B0 04    BCS $8D6C                 
8D68  A5 93    LDA $93                   
8D6A  F0 51    BEQ $8DBD                 

loc_8D6C:  ; xrefs(1): $8D66
8D6C  A5 95    LDA $95                   
8D6E  30 0A    BMI $8D7A                 
8D70  A5 90    LDA $90                   
8D72  C9 40    CMP #$40                  
8D74  B0 04    BCS $8D7A                 
8D76  A5 91    LDA $91                   
8D78  F0 3F    BEQ $8DB9                 

loc_8D7A:  ; xrefs(2): $8D6E $8D74
8D7A  20 2B 80 JSR $802B                 
8D7D  20 66 80 JSR $8066                 
8D80  20 21 81 JSR $8121                 
8D83  E6 93    INC $93                   
8D85  A5 53    LDA $53                   
8D87  30 04    BMI $8D8D                 
8D89  A9 FF    LDA #$FF                  
8D8B  85 93    STA $93                   

loc_8D8D:  ; xrefs(1): $8D87
8D8D  20 51 B1 JSR $B151                 
8D90  20 C5 8D JSR $8DC5                 
8D93  10 03    BPL $8D98                 
8D95  20 33 81 JSR $8133                 

loc_8D98:  ; xrefs(1): $8D93
8D98  20 21 81 JSR $8121                 
8D9B  E6 91    INC $91                   
8D9D  8A       TXA                       
8D9E  48       PHA                       
8D9F  A5 51    LDA $51                   
8DA1  20 89 B1 JSR $B189                 
8DA4  20 0C C0 JSR $C00C                 
8DA7  A8       TAY                       
8DA8  68       PLA                       
8DA9  AA       TAX                       
8DAA  98       TYA                       
8DAB  20 C5 8D JSR $8DC5                 
8DAE  10 06    BPL $8DB6                 
8DB0  A9 00    LDA #$00                  
8DB2  85 50    STA $50                   
8DB4  85 51    STA $51                   

loc_8DB6:  ; xrefs(1): $8DAE
8DB6  4C 3F 81 JMP $813F                 

loc_8DB9:  ; xrefs(1): $8D78
8DB9  A9 03    LDA #$03                  
8DBB  D0 02    BNE $8DBF                 

loc_8DBD:  ; xrefs(1): $8D6A
8DBD  A9 02    LDA #$02                  

loc_8DBF:  ; xrefs(1): $8DBB
8DBF  9D 90 06 STA $0690,X               
8DC2  4C 18 81 JMP $8118                 

sub_8DC5:  ; xrefs(2): $8D90 $8DAB
8DC5  30 0F    BMI $8DD6                 
8DC7  29 E0    AND #$E0                  
8DC9  C9 60    CMP #$60                  
8DCB  F0 07    BEQ $8DD4                 
8DCD  29 20    AND #$20                  
8DCF  F0 03    BEQ $8DD4                 
8DD1  A9 00    LDA #$00                  
8DD3  60       RTS                       

loc_8DD4:  ; xrefs(2): $8DCB $8DCF
8DD4  A9 FF    LDA #$FF                  

loc_8DD6:  ; xrefs(1): $8DC5
8DD6  60       RTS                       

loc_8DD7:  ; xrefs(1): $8DF4
8DD7  A9 60    LDA #$60                  
8DD9  20 4B 90 JSR $904B                 
8DDC  20 18 81 JSR $8118                 
8DDF  A5 91    LDA $91                   
8DE1  C9 05    CMP #$05                  
8DE3  90 03    BCC $8DE8                 
8DE5  4C B3 80 JMP $80B3                 

loc_8DE8:  ; xrefs(1): $8DE3
8DE8  4C B3 8E JMP $8EB3                 

sub_8DEB:  ; xrefs(1): $81EA
8DEB  BD 90 06 LDA $0690,X               
8DEE  F0 41    BEQ $8E31                 
8DF0  C9 02    CMP #$02                  
8DF2  90 54    BCC $8E48                 
8DF4  F0 E1    BEQ $8DD7                 
8DF6  A9 62    LDA #$62                  
8DF8  20 4B 90 JSR $904B                 
8DFB  BD C0 06 LDA $06C0,X               
8DFE  C9 01    CMP #$01                  
8E00  D0 25    BNE $8E27                 
8E02  20 DE 8F JSR $8FDE                 
8E05  20 6C 90 JSR $906C                 
8E08  BD D0 06 LDA $06D0,X               
8E0B  6A       ROR A                     
8E0C  90 16    BCC $8E24                 
8E0E  20 BA AD JSR $ADBA                 
8E11  30 11    BMI $8E24                 
8E13  A9 A2    LDA #$A2                  
8E15  20 7B 90 JSR $907B                 
8E18  20 CB 8E JSR $8ECB                 
8E1B  A9 90    LDA #$90                  
8E1D  85 92    STA $92                   
8E1F  C6 93    DEC $93                   
8E21  20 D7 A1 JSR $A1D7                 

loc_8E24:  ; xrefs(2): $8E0C $8E11
8E24  BD C0 06 LDA $06C0,X               

loc_8E27:  ; xrefs(1): $8E00
8E27  C9 FF    CMP #$FF                  
8E29  D0 05    BNE $8E30                 
8E2B  A9 02    LDA #$02                  
8E2D  9D 90 06 STA $0690,X               

loc_8E30:  ; xrefs(1): $8E29
8E30  60       RTS                       

loc_8E31:  ; xrefs(1): $8DEE
8E31  A9 60    LDA #$60                  
8E33  20 4B 90 JSR $904B                 
8E36  20 18 81 JSR $8118                 
8E39  A5 91    LDA $91                   
8E3B  C9 05    CMP #$05                  
8E3D  B0 06    BCS $8E45                 
8E3F  A9 02    LDA #$02                  
8E41  9D 90 06 STA $0690,X               
8E44  60       RTS                       

loc_8E45:  ; xrefs(1): $8E3D
8E45  4C B3 8E JMP $8EB3                 

loc_8E48:  ; xrefs(1): $8DF2
8E48  A9 61    LDA #$61                  
8E4A  20 4B 90 JSR $904B                 
8E4D  20 E6 80 JSR $80E6                 
8E50  D0 2B    BNE $8E7D                 
8E52  20 BA AD JSR $ADBA                 
8E55  30 26    BMI $8E7D                 
8E57  A9 A3    LDA #$A3                  
8E59  20 7B 90 JSR $907B                 
8E5C  A9 B0    LDA #$B0                  
8E5E  99 E0 07 STA $07E0,Y               
8E61  A9 FE    LDA #$FE                  
8E63  85 93    STA $93                   
8E65  A9 80    LDA #$80                  
8E67  85 90    STA $90                   
8E69  85 92    STA $92                   
8E6B  A9 00    LDA #$00                  
8E6D  85 91    STA $91                   
8E6F  A9 12    LDA #$12                  
8E71  85 9F    STA $9F                   
8E73  20 FD 80 JSR $80FD                 
8E76  10 02    BPL $8E7A                 
8E78  C6 91    DEC $91                   

loc_8E7A:  ; xrefs(1): $8E76
8E7A  4C D7 A1 JMP $A1D7                 

loc_8E7D:  ; xrefs(2): $8E50 $8E55
8E7D  20 E0 80 JSR $80E0                 
8E80  D0 03    BNE $8E85                 
8E82  4C B3 80 JMP $80B3                 

loc_8E85:  ; xrefs(1): $8E80
8E85  60       RTS                       

sub_8E86:  ; xrefs(1): $81EA
8E86  BD 90 06 LDA $0690,X               
8E89  6A       ROR A                     
8E8A  B0 13    BCS $8E9F                 
8E8C  A9 5E    LDA #$5E                  
8E8E  20 4B 90 JSR $904B                 
8E91  20 18 81 JSR $8118                 
8E94  20 5E AE JSR $AE5E                 
8E97  C9 02    CMP #$02                  
8E99  90 01    BCC $8E9C                 
8E9B  60       RTS                       

loc_8E9C:  ; xrefs(1): $8E99
8E9C  4C B3 8E JMP $8EB3                 

loc_8E9F:  ; xrefs(1): $8E8A
8E9F  A9 5F    LDA #$5F                  
8EA1  20 4B 90 JSR $904B                 
8EA4  20 E6 80 JSR $80E6                 
8EA7  D0 0A    BNE $8EB3                 
8EA9  20 BA AD JSR $ADBA                 
8EAC  30 05    BMI $8EB3                 
8EAE  A9 A1    LDA #$A1                  
8EB0  4C BC 8E JMP $8EBC                 

loc_8EB3:  ; xrefs(6): $8D40 $8DE8 $8E45 $8E9C $8EA7 $8EAC
8EB3  20 E0 80 JSR $80E0                 
8EB6  D0 03    BNE $8EBB                 
8EB8  FE 90 06 INC $0690,X               

loc_8EBB:  ; xrefs(1): $8EB6
8EBB  60       RTS                       

loc_8EBC:  ; xrefs(2): $8D21 $8EB0
8EBC  20 7B 90 JSR $907B                 
8EBF  20 CB 8E JSR $8ECB                 
8EC2  A9 80    LDA #$80                  
8EC4  85 92    STA $92                   
8EC6  C6 93    DEC $93                   
8EC8  4C D7 A1 JMP $A1D7                 

sub_8ECB:  ; xrefs(2): $8E18 $8EBF
8ECB  20 21 81 JSR $8121                 
8ECE  E6 91    INC $91                   
8ED0  BD 80 06 LDA $0680,X               
8ED3  0A       ASL A                     
8ED4  A9 30    LDA #$30                  
8ED6  B0 06    BCS $8EDE                 
8ED8  A9 FF    LDA #$FF                  
8EDA  85 91    STA $91                   
8EDC  A9 D0    LDA #$D0                  

loc_8EDE:  ; xrefs(1): $8ED6
8EDE  99 D0 07 STA $07D0,Y               
8EE1  A9 13    LDA #$13                  
8EE3  85 F1    STA $F1                   
8EE5  60       RTS                       

sub_8EE6:  ; xrefs(1): $836A
8EE6  20 30 AE JSR $AE30                 
8EE9  C9 03    CMP #$03                  
8EEB  90 0C    BCC $8EF9                 
8EED  A0 07    LDY #$07                  

loc_8EEF:  ; xrefs(1): $8EF7
8EEF  98       TYA                       
8EF0  48       PHA                       
8EF1  20 05 8F JSR $8F05                 
8EF4  68       PLA                       
8EF5  A8       TAY                       
8EF6  88       DEY                       
8EF7  10 F6    BPL $8EEF                 

loc_8EF9:  ; xrefs(1): $8EEB
8EF9  A9 21    LDA #$21                  
8EFB  85 F1    STA $F1                   
8EFD  20 68 8F JSR $8F68                 
8F00  A9 14    LDA #$14                  
8F02  4C E1 A9 JMP $A9E1                 

sub_8F05:  ; xrefs(1): $8EF1
8F05  B9 14 8F LDA $8F14,Y               
8F08  85 94    STA $94                   
8F0A  B9 12 8F LDA $8F12,Y               
8F0D  85 95    STA $95                   
8F0F  4C C4 85 JMP $85C4                 

; ---- data $8F12-$8F1B (10 bytes) ----
8F12  00 22 30 22 00 DE D0 DE 00 22                    |."0"....."

sub_8F1C:  ; xrefs(1): $827B
8F1C  BD 10 06 LDA $0610,X               
8F1F  C9 02    CMP #$02                  
8F21  F0 58    BEQ $8F7B                 
8F23  A8       TAY                       
8F24  D0 07    BNE $8F2D                 
8F26  A9 2B    LDA #$2B                  
8F28  85 F1    STA $F1                   
8F2A  FE 10 06 INC $0610,X               

loc_8F2D:  ; xrefs(1): $8F24
8F2D  20 F2 80 JSR $80F2                 
8F30  A9 69    LDA #$69                  
8F32  20 4B 90 JSR $904B                 
8F35  20 E0 80 JSR $80E0                 
8F38  D0 2A    BNE $8F64                 
8F3A  FE 10 06 INC $0610,X               
8F3D  A9 00    LDA #$00                  
8F3F  85 94    STA $94                   
8F41  A9 A0    LDA #$A0                  
8F43  20 53 8F JSR $8F53                 
8F46  A9 04    LDA #$04                  
8F48  85 94    STA $94                   
8F4A  20 51 8F JSR $8F51                 
8F4D  A9 FC    LDA #$FC                  
8F4F  85 94    STA $94                   

sub_8F51:  ; xrefs(1): $8F4A
8F51  A9 A8    LDA #$A8                  

sub_8F53:  ; xrefs(1): $8F43
8F53  85 90    STA $90                   
8F55  20 BA AD JSR $ADBA                 
8F58  30 0A    BMI $8F64                 
8F5A  A5 90    LDA $90                   
8F5C  20 A9 90 JSR $90A9                 
8F5F  A9 A6    LDA #$A6                  
8F61  4C 7B 90 JMP $907B                 

loc_8F64:  ; xrefs(2): $8F38 $8F58
8F64  60       RTS                       

sub_8F65:  ; xrefs(1): $836A
8F65  20 37 A9 JSR $A937                 

sub_8F68:  ; xrefs(2): $836A $8EFD
8F68  A0 BD    LDY #$BD                  

loc_8F6A:  ; xrefs(1): $84B6
8F6A  20 F1 AA JSR $AAF1                 
8F6D  A9 00    LDA #$00                  
8F6F  4C 89 A9 JMP $A989                 

sub_8F72:  ; xrefs(2): $827B $836A
8F72  A9 14    LDA #$14                  
8F74  D0 0F    BNE $8F85                 

sub_8F76:  ; xrefs(1): $836A
8F76  A9 00    LDA #$00                  
8F78  4C 89 A9 JMP $A989                 

sub_8F7B:  ; xrefs(3): $827B $836A $8F21
8F7B  A9 0A    LDA #$0A                  
8F7D  D0 06    BNE $8F85                 

sub_8F7F:  ; xrefs(1): $827B
8F7F  A9 64    LDA #$64                  
8F81  D0 02    BNE $8F85                 

sub_8F83:  ; xrefs(1): $836A
8F83  A9 32    LDA #$32                  

loc_8F85:  ; xrefs(3): $8F74 $8F7D $8F81
8F85  48       PHA                       
8F86  20 6C 90 JSR $906C                 
8F89  68       PLA                       
8F8A  4C 31 AF JMP $AF31                 

sub_8F8D:  ; xrefs(1): $81EA
8F8D  BD A0 06 LDA $06A0,X               
8F90  D0 47    BNE $8FD9                 
8F92  20 DA 80 JSR $80DA                 
8F95  D0 05    BNE $8F9C                 
8F97  A9 5D    LDA #$5D                  
8F99  4C 28 90 JMP $9028                 

loc_8F9C:  ; xrefs(1): $8F95
8F9C  8A       TXA                       
8F9D  45 0C    EOR $0C                   
8F9F  6A       ROR A                     
8FA0  90 01    BCC $8FA3                 
8FA2  60       RTS                       

loc_8FA3:  ; xrefs(1): $8FA0
8FA3  20 0D 81 JSR $810D                 
8FA6  49 FF    EOR #$FF                  
8FA8  20 53 90 JSR $9053                 
8FAB  20 AA B0 JSR $B0AA                 
8FAE  10 24    BPL $8FD4                 
8FB0  BD 80 06 LDA $0680,X               
8FB3  4D B2 05 EOR $05B2                 
8FB6  48       PHA                       
8FB7  0A       ASL A                     
8FB8  A9 10    LDA #$10                  
8FBA  90 01    BCC $8FBD                 
8FBC  0A       ASL A                     

loc_8FBD:  ; xrefs(1): $8FBA
8FBD  20 0A 9D JSR $9D0A                 
8FC0  68       PLA                       
8FC1  85 90    STA $90                   
8FC3  98       TYA                       
8FC4  30 0E    BMI $8FD4                 
8FC6  06 90    ASL $90                   
8FC8  A9 5B    LDA #$5B                  
8FCA  90 02    BCC $8FCE                 
8FCC  A9 08    LDA #$08                  

loc_8FCE:  ; xrefs(1): $8FCA
8FCE  20 4B 90 JSR $904B                 
8FD1  4C 3F 81 JMP $813F                 

loc_8FD4:  ; xrefs(2): $8FAE $8FC4
8FD4  A9 5C    LDA #$5C                  
8FD6  4C 4B 90 JMP $904B                 

loc_8FD9:  ; xrefs(1): $8F90
8FD9  A9 5D    LDA #$5D                  
8FDB  20 28 90 JSR $9028                 

sub_8FDE:  ; xrefs(1): $8E02
8FDE  20 18 81 JSR $8118                 
8FE1  20 53 90 JSR $9053                 
8FE4  20 24 AE JSR $AE24                 
8FE7  20 AA B0 JSR $B0AA                 
8FEA  20 24 AE JSR $AE24                 
8FED  98       TYA                       
8FEE  10 05    BPL $8FF5                 
8FF0  A9 40    LDA #$40                  
8FF2  20 0A 9D JSR $9D0A                 

loc_8FF5:  ; xrefs(1): $8FEE
8FF5  4C 3F 81 JMP $813F                 

loc_8FF8:  ; xrefs(1): $9030
8FF8  20 26 90 JSR $9026                 
8FFB  20 EC 80 JSR $80EC                 
8FFE  D0 04    BNE $9004                 
9000  A0 29    LDY #$29                  
9002  84 F1    STY $F1                   

loc_9004:  ; xrefs(1): $8FFE
9004  C9 01    CMP #$01                  
9006  D0 13    BNE $901B                 
9008  20 21 81 JSR $8121                 
900B  A9 80    LDA #$80                  
900D  85 90    STA $90                   
900F  E6 93    INC $93                   
9011  20 70 B1 JSR $B170                 
9014  10 05    BPL $901B                 
9016  A9 20    LDA #$20                  
9018  20 0A 9D JSR $9D0A                 

loc_901B:  ; xrefs(2): $9006 $9014
901B  BD A0 06 LDA $06A0,X               
901E  D0 03    BNE $9023                 
9020  9D 90 06 STA $0690,X               

loc_9023:  ; xrefs(1): $901E
9023  4C 3F 81 JMP $813F                 

sub_9026:  ; xrefs(2): $8FF8 $903E
9026  A9 58    LDA #$58                  

sub_9028:  ; xrefs(7): $8A30 $8A86 $8ABE $8F99 $8FDB $A16C $A3D3
9028  A0 04    LDY #$04                  
902A  4C 80 BD JMP $BD80                 

sub_902D:  ; xrefs(1): $81EA
902D  BD A0 06 LDA $06A0,X               
9030  D0 C6    BNE $8FF8                 
9032  20 DA 80 JSR $80DA                 
9035  D0 0A    BNE $9041                 
9037  BD 50 06 LDA $0650,X               
903A  29 40    AND #$40                  
903C  D0 03    BNE $9041                 
903E  4C 26 90 JMP $9026                 

loc_9041:  ; xrefs(2): $9035 $903C
9041  BD 90 06 LDA $0690,X               
9044  D0 3E    BNE $9084                 
9046  20 50 90 JSR $9050                 
9049  A9 56    LDA #$56                  

sub_904B:  ; xrefs(38): $84A7 $84F7 $8547 $8574 $85F5 $8623 $8650 $86A3 $86CB $872B
904B  A0 04    LDY #$04                  
904D  4C AB BD JMP $BDAB                 

sub_9050:  ; xrefs(1): $9046
9050  20 18 81 JSR $8118                 

sub_9053:  ; xrefs(2): $8FA8 $8FE1
9053  9D 10 06 STA $0610,X               
9056  A5 91    LDA $91                   
9058  C9 07    CMP #$07                  
905A  A0 00    LDY #$00                  
905C  B0 0B    BCS $9069                 
905E  A0 40    LDY #$40                  
9060  A5 0E    LDA $0E                   
9062  29 3F    AND #$3F                  
9064  D0 03    BNE $9069                 
9066  FE 90 06 INC $0690,X               

loc_9069:  ; xrefs(2): $905C $9064
9069  4C 6E 90 JMP $906E                 

sub_906C:  ; xrefs(4): $89BD $8ACD $8E05 $8F86
906C  A0 00    LDY #$00                  

sub_906E:  ; xrefs(3): $8A35 $8AA4 $9069
906E  84 90    STY $90                   
9070  BD 00 06 LDA $0600,X               
9073  29 BF    AND #$BF                  
9075  05 90    ORA $90                   
9077  9D 00 06 STA $0600,X               
907A  60       RTS                       

sub_907B:  ; xrefs(13): $8557 $85CF $86FF $873E $8C0D $8C8C $8CEA $8E15 $8E59 $8EBC
907B  99 80 07 STA $0780,Y               

loc_907E:  ; xrefs(1): $90D7
907E  A9 01    LDA #$01                  
9080  99 F0 07 STA $07F0,Y               
9083  60       RTS                       

loc_9084:  ; xrefs(1): $9044
9084  A9 57    LDA #$57                  
9086  20 4B 90 JSR $904B                 
9089  20 E6 80 JSR $80E6                 
908C  D0 10    BNE $909E                 
908E  20 18 81 JSR $8118                 
9091  20 BA AD JSR $ADBA                 
9094  30 08    BMI $909E                 
9096  A9 A0    LDA #$A0                  
9098  20 7B 90 JSR $907B                 
909B  20 A7 90 JSR $90A7                 

loc_909E:  ; xrefs(2): $908C $9094
909E  20 E0 80 JSR $80E0                 
90A1  D0 03    BNE $90A6                 
90A3  4C B3 80 JMP $80B3                 

loc_90A6:  ; xrefs(1): $90A1
90A6  60       RTS                       

sub_90A7:  ; xrefs(1): $909B
90A7  A9 A8    LDA #$A8                  

sub_90A9:  ; xrefs(1): $8F5C
90A9  99 E0 07 STA $07E0,Y               
90AC  A9 FE    LDA #$FE                  
90AE  85 93    STA $93                   
90B0  A9 80    LDA #$80                  
90B2  85 90    STA $90                   
90B4  85 92    STA $92                   
90B6  38       SEC                       
90B7  A9 00    LDA #$00                  
90B9  85 91    STA $91                   
90BB  E5 94    SBC $94                   
90BD  0A       ASL A                     
90BE  0A       ASL A                     
90BF  99 D0 07 STA $07D0,Y               
90C2  10 02    BPL $90C6                 
90C4  C6 91    DEC $91                   

loc_90C6:  ; xrefs(1): $90C2
90C6  4C D7 A1 JMP $A1D7                 

; ---- data $90C9-$90C9 (1 bytes) ----
90C9  60                                               |`

sub_90CA:  ; xrefs(2): $81EA $827B
90CA  BD 90 06 LDA $0690,X               
90CD  20 10 80 JSR $8010                 
90D0  D8       CLD                       
90D1  90 F5    BCC $90C8                 
90D3  90 16    BCC $90EB                 
90D5  91 FF    STA ($FF),Y               
90D7  90 A5    BCC $907E                 
90D9  0E 29 03 ASL $0329                 
90DC  D0 13    BNE $90F1                 
90DE  A5 0E    LDA $0E                   
90E0  29 1F    AND #$1F                  
90E2  69 20    ADC #$20                  
90E4  95 D0    STA $D0,X                 
90E6  A9 B8    LDA #$B8                  
90E8  20 63 81 JSR $8163                 

loc_90EB:  ; xrefs(1): $90D3
90EB  A9 33    LDA #$33                  
90ED  9D 50 06 STA $0650,X               
90F0  60       RTS                       

loc_90F1:  ; xrefs(1): $90DC
90F1  9D 90 06 STA $0690,X               
90F4  60       RTS                       

; ---- data $90F5-$9126 (50 bytes) ----
90F5  20 BA AD 10 01 60 A9 9E D0 08 20 BA AD 10 01 60  | ....`.... ....`
9105  A9 9F 99 80 07 99 F0 07 20 21 81 9D 00 06 4C D7  |........ !....L.
9115  A1 A0 80 A9 34 9D 60 06 A9 03 9D 70 06 84 52 4C  |....4.`....p..RL
9125  3F 81                                            |?.

sub_9127:  ; xrefs(2): $81EA $827B
9127  BD 90 06 LDA $0690,X               
912A  D0 19    BNE $9145                 
912C  FE 90 06 INC $0690,X               
912F  A5 0E    LDA $0E                   
9131  29 3F    AND #$3F                  
9133  85 90    STA $90                   
9135  BD 30 06 LDA $0630,X               
9138  E5 90    SBC $90                   
913A  9D 30 06 STA $0630,X               
913D  A5 0E    LDA $0E                   
913F  4A       LSR A                     
9140  E9 40    SBC #$40                  
9142  9D 10 06 STA $0610,X               

loc_9145:  ; xrefs(1): $912A
9145  BD 10 06 LDA $0610,X               
9148  85 50    STA $50                   
914A  10 02    BPL $914E                 
914C  C6 51    DEC $51                   

loc_914E:  ; xrefs(1): $914A
914E  A9 04    LDA #$04                  
9150  20 BB B2 JSR $B2BB                 
9153  A9 08    LDA #$08                  
9155  20 85 89 JSR $8985                 
9158  4C 3F 81 JMP $813F                 

sub_915B:  ; xrefs(2): $81EA $827B
915B  BD 90 06 LDA $0690,X               
915E  20 10 80 JSR $8010                 
9161  6F 91 95 RRA $9591                 
9164  91 C0    STA ($C0),Y               
9166  91 CD    STA ($CD),Y               
9168  91 F1    STA ($F1),Y               
916A  91 FF    STA ($FF),Y               
916C  91 08    STA ($08),Y               

; ---- data $916E-$921B (174 bytes) ----
916E  92 20 18 81 A9 49 20 4B 90 A5 58 C9 03 D0 17 20  |. ...I K..X.... 
917E  E0 80 D0 12 20 FF A3 A9 39 85 F1 A9 E0 9D 10 06  |.... ...9.......
918E  FE 90 06 EE 9B 06 60 38 BD 10 06 E9 04 9D 10 06  |......`8........
919E  B0 1F 69 04 9D 10 06 A4 26 D0 16 A9 A0 A0 83 20  |..i.....&...... 
91AE  AE 80 A9 06 A0 80 20 A9 80 A9 00 8D 0B 06 FE 90  |...... .........
91BE  06 60 A9 4E 20 4B 90 A5 26 D0 03 FE 90 06 60 A9  |.`.N K..&.....`.
91CE  4A 20 4B 90 20 E0 80 D0 19 A9 20 9D 10 06 A9 08  |J K. ..... .....
91DE  8D C1 05 A9 FF A8 20 A9 80 A9 02 85 28 85 25 FE  |...... .....(.%.
91EE  90 06 60 FE 90 06 A9 40 85 F1 A9 06 A0 FF 4C A9  |..`....@......L.
91FE  80 DE 10 06 D0 03 FE 90 06 60 A9 4D 20 D9 99 D0  |.........`.M ...
920E  0C A5 58 C9 03 90 06 FE 50 06 4C B3 80 60        |..X.....P.L..`

sub_921C:  ; xrefs(2): $81EA $827B
921C  4C 7E C0 JMP $C07E                 

sub_921F:  ; xrefs(7): $9247 $9685 $99A4 $9B17 $9DE9 $9E14 $A53F
921F  BD F0 06 LDA $06F0,X               
9222  C9 10    CMP #$10                  
9224  B0 14    BCS $923A                 
9226  A5 26    LDA $26                   
9228  D0 10    BNE $923A                 
922A  A5 0C    LDA $0C                   
922C  29 04    AND #$04                  
922E  F0 03    BEQ $9233                 
9230  C8       INY                       
9231  C8       INY                       
9232  C8       INY                       

sub_9233:  ; xrefs(2): $922E $A46F
9233  84 92    STY $92                   
9235  A9 8E    LDA #$8E                  
9237  4C 81 80 JMP $8081                 

loc_923A:  ; xrefs(2): $9224 $9228
923A  60       RTS                       

sub_923B:  ; xrefs(2): $81EA $827B
923B  BD 90 06 LDA $0690,X               
923E  29 7F    AND #$7F                  
9240  48       PHA                       
9241  C9 0F    CMP #$0F                  
9243  B0 05    BCS $924A                 
9245  A0 00    LDY #$00                  
9247  20 1F 92 JSR $921F                 

loc_924A:  ; xrefs(1): $9243
924A  68       PLA                       
924B  20 10 80 JSR $8010                 
924E  B9 93 97 LDA $9793,Y               

; ---- data $9251-$927D (45 bytes) ----
9251  93 13 94 72 94 8A 94 B8 94 F2 94 0C 95 23 95 4B  |...r.........#.K
9261  95 A2 95 B9 95 DC 95 B9 93 2B 96 B5 92 E9 92 79  |.........+.....y
9271  93 94 93 5C 93 4A 93 2B 93 94 93 10 93           |...\.J.+.....

sub_927E:  ; xrefs(3): $A3DB $A46A $A4E3
927E  20 8A 80 JSR $808A                 
9281  A5 0C    LDA $0C                   
9283  29 07    AND #$07                  
9285  D0 29    BNE $92B0                 
9287  20 8E 80 JSR $808E                 

loc_928A:  ; xrefs(1): $89D2
928A  A9 3E    LDA #$3E                  
928C  85 F1    STA $F1                   
928E  20 21 81 JSR $8121                 
9291  A5 0E    LDA $0E                   
9293  29 03    AND #$03                  
9295  A8       TAY                       
9296  B9 B1 92 LDA $92B1,Y               
9299  75 D0    ADC $D0,X                 
929B  85 93    STA $93                   
929D  A5 0E    LDA $0E                   
929F  6A       ROR A                     
92A0  6A       ROR A                     
92A1  29 03    AND #$03                  
92A3  A8       TAY                       
92A4  B9 B1 92 LDA $92B1,Y               
92A7  75 B0    ADC $B0,X                 
92A9  85 91    STA $91                   
92AB  A0 7E    LDY #$7E                  
92AD  4C C2 AA JMP $AAC2                 

loc_92B0:  ; xrefs(1): $9285
92B0  60       RTS                       

; ---- data $92B1-$9587 (727 bytes) ----
92B1  00 FF 00 01 20 18 81 A9 2A 95 D0 95 C0 A9 59 20  |.... ...*.....Y 
92C1  8B 93 BD C0 06 C9 80 D0 03 4C FF A3 C9 FF D0 15  |.........L......
92D1  A9 E0 A0 84 20 AE 80 9D F0 06 BD 50 06 29 3F 9D  |.... ......P.)?.
92E1  50 06 FE 90 06 4C 7E 92 A9 5A 20 8B 93 BD C0 06  |P....L~..Z .....
92F1  C9 10 D0 07 A9 06 A0 80 4C A9 80 C9 FF D0 0D A0  |........L.......
9301  06 A9 19 20 E1 A9 88 D0 F8 FE 90 06 4C 7E 92 A5  |... ........L~..
9311  33 95 D0 A5 32 95 C0 A5 0E 29 1F 85 90 A5 31 29  |3...2....)....1)
9321  F0 65 90 95 B0 A0 CF 4C F1 AA 20 8A 80 20 A2 87  |.e.....L.. .. ..
9331  A5 0C 29 07 D0 12 A5 0C 29 0F D0 04 A9 20 85 F1  |..).....).... ..
9341  20 8E 80 A0 C6 4C F1 AA 60 20 C8 80 A9 10 20 79  | ....L..` .... y
9351  81 A9 02 20 BB B2 A9 54 4C 8B 93 20 6F 81 BD A0  |... ...TL.. o...
9361  06 D0 0A 20 DA 80 F0 05 A9 55 4C 8B 93 A9 53 9D  |... .....UL...S.
9371  E0 06 9D F0 06 4C 28 90 BD 80 06 9D 10 06 20 E6  |.....L(....... .
9381  80 D0 05 A9 10 20 0A 9D A9 52 20 D9 99 20 3F 81  |..... ...R .. ?.
9391  20 E0 80 4C 8A 80 20 30 AE C9 07 B0 04 FE 90 06  | ..L.. 0........
93A1  60 A5 94 9D 80 06 49 FF 9D 10 06 A9 10 20 0A 9D  |`.....I...... ..
93B1  A9 3F 20 D9 99 4C 3F 81 BD A0 06 D0 29 20 18 81  |.? ..L?.....) ..
93C1  A9 3E 20 D9 99 D0 04 FE 90 06 60 4C CF 93 BD 50  |.> .......`L...P
93D1  06 29 40 D0 10 20 DA 80 D0 0B BD 80 06 9D 10 06  |.)@.. ..........
93E1  A9 48 4C 28 90 60 A9 48 20 28 90 BD E0 06 C9 09  |.HL(.`.H (......
93F1  A9 40 90 02 A9 10 20 0A 9D BD A0 06 D0 11 98 30  |.@.... ........0
9401  04 A9 04 D0 02 A9 FF 9D C0 06 A9 02 9D E0 06 4C  |...............L
9411  3F 81 BD A0 06 D0 CF 20 18 81 A9 3E 20 D9 99 D0  |?...... ...> ...
9421  3D 20 18 81 A5 06 29 03 F0 0B 6A 6A 6A 45 94 10  |= ....)...jjjE..
9431  04 A0 08 D0 18 A0 0C BD F0 06 C9 08 90 0F AD A2  |................
9441  05 C9 07 F0 08 A0 04 C9 03 F0 02 A0 00 84 90 A5  |................
9451  0E 29 03 18 65 90 A8 B9 62 94 9D 90 06 60 4C CF  |.)..e...b....`L.
9461  93 0A 0A 0A 07 0A 0A 07 03 0A 07 07 03 07 03 03  |................
9471  03 20 18 81 49 FF 9D 10 06 A9 40 20 D9 99 D0 08  |. ..I.....@ ....
9481  A9 78 20 63 81 FE 90 06 60 A9 04 20 BB B2 20 18  |.x c....`.. .. .
9491  81 BD 40 06 30 14 A5 91 C9 10 90 02 A9 0F A8 B9  |..@.0...........
94A1  5A 9F 0A 0A 8D 11 06 FE 90 06 A9 10 20 0A 9D A9  |Z........... ...
94B1  41 20 D9 99 4C 3F 81 A9 1C 20 BB B2 A9 00 85 90  |A ..L?... ......
94C1  20 AE B0 10 1E 20 33 81 95 C0 9D 10 06 A0 24 20  | .... 3.......$ 
94D1  9E AA A0 24 20 A9 AA A9 07 8D F7 05 A9 30 85 F1  |...$ ........0..
94E1  FE 90 06 AD 11 06 20 0A 9D A9 42 20 D9 99 4C 3F  |...... ...B ..L?
94F1  81 A9 44 20 D9 99 20 05 95 F0 08 20 E0 80 D0 03  |..D .. .... ....
9501  4C 2B 96 60 A9 01 20 3C A9 3D BF 20 18 81 49 FF  |L+.`.. <.=. ..I.
9511  9D 10 06 A9 45 20 D9 99 D0 07 A9 3B 85 F1 FE 90  |....E .....;....
9521  06 60 20 30 AE A5 94 5D 10 06 30 09 A9 70 8D 11  |.` 0...]..0..p..
9531  06 FE 90 06 60 A9 80 20 0A 9D BD 90 06 30 ED A9  |....`.. .....0..
9541  46 20 D9 99 20 74 95 4C 3F 81 38 AD 11 06 E9 04  |F .. t.L?.8.....
9551  B0 03 20 2B 96 8D 11 06 20 0A 9D AD 11 06 C9 50  |.. +.... ......P
9561  B0 0B 20 18 81 A9 47 20 D9 99 4C 3F 81 20 74 95  |.. ...G ..L?. t.
9571  4C 3F 81 A5 0C 29 03 20 56 A0 D0 0A A9 07 99 10  |L?...). V.......
9581  06 A9 31 99 50 06 60                             |..1.P.`

sub_9588:  ; xrefs(2): $81EA $827B
9588  BD 10 06 LDA $0610,X               
958B  4A       LSR A                     
958C  29 03    AND #$03                  
958E  A8       TAY                       
958F  B9 9E 95 LDA $959E,Y               
9592  9D E0 06 STA $06E0,X               
9595  DE 10 06 DEC $0610,X               
9598  D0 03    BNE $959D                 
959A  20 B9 80 JSR $80B9                 

loc_959D:  ; xrefs(1): $9598
959D  60       RTS                       

; ---- data $959E-$962D (144 bytes) ----
959E  01 01 02 00 20 18 81 A9 4A 20 D9 99 D0 0C A9 2B  |.... ...J .....+
95AE  85 F1 A9 20 9D 20 06 FE 90 06 60 20 18 81 DE 20  |... . ....` ... 
95BE  06 D0 0D A9 2E 85 F1 20 E7 95 FE 90 06 4C D4 80  |....... .....L..
95CE  A5 0C 6A 6A A9 03 90 02 A9 01 9D E0 06 60 A9 43  |..jj.........`.C
95DE  20 D9 99 D0 03 20 2B 96 60 20 21 81 C6 93 E6 91  | .... +.` !.....
95EE  BD 80 06 0A A9 40 B0 06 A9 C0 C6 91 C6 91 A0 08  |.....@..........
95FE  48 B9 19 96 99 80 07 99 F0 07 B9 22 96 99 E0 07  |H.........."....
960E  20 D7 A1 68 99 D0 07 88 10 E6 60 8D 8E 8F 92 93  | ..h......`.....
961E  94 97 98 99 00 03 05 00 03 05 00 03 05 4C B3 80  |.............L..

sub_962E:  ; xrefs(2): $81EA $827B
962E  20 6B 96 JSR $966B                 
9631  B5 D0    LDA $D0,X                 
9633  C9 61    CMP #$61                  
9635  D0 03    BNE $963A                 
9637  20 52 96 JSR $9652                 

loc_963A:  ; xrefs(1): $9635
963A  BD 20 06 LDA $0620,X               
963D  10 10    BPL $964F                 
963F  B5 D0    LDA $D0,X                 
9641  C9 64    CMP #$64                  
9643  B0 0A    BCS $964F                 
9645  BD 20 06 LDA $0620,X               
9648  4A       LSR A                     
9649  9D 20 06 STA $0620,X               
964C  FE 50 06 INC $0650,X               

loc_964F:  ; xrefs(2): $963D $9643
964F  4C 66 96 JMP $9666                 

sub_9652:  ; xrefs(1): $9637
9652  A9 09    LDA #$09                  
9654  85 F1    STA $F1                   
9656  20 21 81 JSR $8121                 
9659  A9 62    LDA #$62                  
965B  85 93    STA $93                   
965D  B5 B0    LDA $B0,X                 
965F  85 91    STA $91                   
9661  A0 36    LDY #$36                  
9663  4C C2 AA JMP $AAC2                 

loc_9666:  ; xrefs(1): $964F
9666  A9 7F    LDA #$7F                  
9668  4C 81 80 JMP $8081                 

sub_966B:  ; xrefs(1): $962E
966B  38       SEC                       
966C  BD 10 06 LDA $0610,X               
966F  E9 01    SBC #$01                  
9671  9D 10 06 STA $0610,X               
9674  85 52    STA $52                   
9676  BD 20 06 LDA $0620,X               
9679  E9 00    SBC #$00                  
967B  9D 20 06 STA $0620,X               
967E  85 53    STA $53                   
9680  4C 3F 81 JMP $813F                 

sub_9683:  ; xrefs(1): $81EA
9683  A0 21    LDY #$21                  
9685  20 1F 92 JSR $921F                 
9688  BD 90 06 LDA $0690,X               
968B  20 10 80 JSR $8010                 
968E  C8       INY                       
968F  97 79    SAX $79,Y                 
9691  98       TYA                       
9692  11 98    ORA ($98),Y               
9694  94 98    STY $98,X                 
9696  C8       INY                       
9697  97 79    SAX $79,Y                 
9699  98       TYA                       
969A  11 98    ORA ($98),Y               
969C  94 98    STY $98,X                 
969E  BA       TSX                       
969F  96 B2    STX $B2,Y                 
96A1  97 76    SAX $76,Y                 
96A3  98       TYA                       
96A4  D7 96    DCP $96,X                 
96A6  C8       INY                       
96A7  97 79    SAX $79,Y                 
96A9  98       TYA                       
96AA  01 98    ORA ($98,X)               
96AC  91 98    STA ($98),Y               
96AE  70 97    BVS $9647                 
96B0  4F 97 5F SRE $5F97                 
96B3  97 FC    SAX $FC,Y                 
96B5  96 E1    STX $E1,Y                 
96B7  96 86    STX $86,Y                 
96B9  97 A9    SAX $A9,Y                 
96BB  07 9D    SLO $9D                   
96BD  20 06 A9 JSR $A906                 
96C0  03 9D    SLO ($9D,X)               
96C2  40       RTI                       

; ---- data $96C3-$9974 (690 bytes) ----
96C3  06 FE 90 06 A5 0E 29 02 F0 09 18 BD 90 06 69 03  |......).......i.
96D3  9D 90 06 60 18 BD 90 06 69 05 9D 90 06 60 A9 51  |...`....i....`.Q
96E3  20 D9 99 D0 03 FE 90 06 20 E0 98 4C 3F 81 A5 0C  | ....... ..L?...
96F3  29 03 D0 04 A9 19 85 F1 60 20 F1 96 A9 4F 20 D9  |).......` ...O .
9703  99 A0 D8 20 F1 AA BD 80 06 49 FF 9D 10 06 18 BD  |... .....I......
9713  40 06 69 01 C9 41 90 02 A9 40 9D 40 06 20 0A 9D  |@.i..A...@.@. ..
9723  38 A9 00 FD 40 06 C9 D0 90 04 38 6A 38 6A 85 52  |8...@.....8j8j.R
9733  C6 53 A9 03 20 F2 98 A5 53 D0 0E 20 52 96 20 24  |.S.. ...S.. R. $
9743  AE A9 08 9D 30 06 FE 90 06 4C 3F 81 A9 3B 20 D9  |....0....L?..; .
9753  99 D0 08 A9 20 9D 40 06 FE 90 06 60 A9 50 20 D9  |.... .@....`.P .
9763  99 DE 40 06 D0 06 FE 40 06 FE 90 06 60 A9 3A 20  |..@....@....`.: 
9773  D9 99 B5 D0 C9 6B 90 04 FE 90 06 60 A9 18 85 52  |.....k.....`...R
9783  4C 3F 81 4C B3 80 BD 40 06 F0 23 DE 20 06 D0 1E  |L?.L...@..#. ...
9793  A5 0E 29 0F 69 18 9D 20 06 DE 40 06 20 BA AD 30  |..).i.. ..@. ..0
97A3  0D A9 9D 20 7B 90 20 21 81 C6 93 4C D7 A1 60 BD  |... {. !...L..`.
97B3  A0 06 D0 65 20 61 99 D0 01 60 A9 37 20 54 99 20  |...e a...`.7 T. 
97C3  89 97 4C D0 97 BD A0 06 D0 4F 20 05 99 38 BD 10  |..L......O ..8..
97D3  06 E9 01 C9 E8 B0 02 A9 E8 9D 10 06 9D 80 06 49  |...............I
97E3  FF 18 69 01 20 0A 9D B5 A0 C5 30 B5 B0 E5 31 90  |..i. .....0...1.
97F3  04 C9 07 B0 03 FE 90 06 20 E0 98 4C 3F 81 BD A0  |........ ..L?...
9803  06 D0 16 A9 37 20 54 99 20 89 97 4C 4A 98 BD A0  |....7 T. ..LJ...
9813  06 D0 06 20 05 99 4C 4A 98 A9 3C 20 28 90 20 40  |... ..LJ..< (. @
9823  98 A9 40 20 0A 9D 20 40 98 BD A0 06 D0 0C A0 00  |..@ .. @........
9833  BD 80 06 10 01 88 98 9D 10 06 4C 3F 81 38 A9 00  |..........L?.8..
9843  FD 10 06 9D 10 06 60 18 BD 10 06 69 01 C9 18 90  |......`....i....
9853  02 A9 18 9D 10 06 9D 80 06 20 0A 9D B5 A0 C5 30  |......... .....0
9863  B5 B0 E5 31 90 04 C9 09 90 03 FE 90 06 20 E0 98  |...1......... ..
9873  4C 3F 81 20 89 97 BD A0 06 D0 9E A5 0C 29 03 C9  |L?. .........)..
9883  03 BD 10 06 69 00 30 03 4C D0 98 4C AC 98 20 89  |....i.0.L..L.. .
9893  97 BD A0 06 F0 03 4C 1C 98 A5 0C 29 03 C9 01 BD  |......L....)....
98A3  10 06 E9 00 10 03 4C D0 98 9D 10 06 10 05 49 FF  |......L.......I.
98B3  18 69 01 20 0A 9D 98 10 03 20 D0 98 20 61 99 D0  |.i. ..... .. a..
98C3  01 60 A9 38 20 54 99 20 E0 98 4C 3F 81 FE 90 06  |.`.8 T. ..L?....
98D3  A0 00 BD 10 06 30 01 88 98 9D 10 06 60 A5 0C 29  |.....0......`..)
98E3  03 D0 0A A9 00 85 90 FE 30 06 20 93 A2 A9 04 85  |........0. .....
98F3  90 A5 53 10 0C 38 B5 D0 E5 33 C5 90 B0 03 4C 33  |..S..8...3....L3
9903  81 60 20 61 99 D0 01 60 20 30 AE C9 04 A9 37 B0  |.` a...` 0....7.
9913  40 BD E0 06 C9 40 A9 37 90 37 BD D0 06 C9 01 D0  |@....@.7.7......
9923  2B 20 BA AD 30 26 A9 28 85 F1 A9 9C 20 7B 90 A9  |+ ..0&.(.... {..
9933  00 85 91 BD 10 06 0A A9 A0 90 04 C6 91 A9 60 85  |..............`.
9943  90 A9 01 85 93 A9 60 85 92 20 D7 A1 A9 39 4C D9  |......`.. ...9L.
9953  99 48 20 E0 80 F0 03 20 F1 96 68 4C D9 99 20 DA  |.H .... ..hL.. .
9963  80 D0 0E BD 50 06 29 40 D0 07 A9 3C 20 28 90 A9  |....P.)@...< (..
9973  00 60                                            |.`

sub_9975:  ; xrefs(2): $81EA $827B
9975  A9 01    LDA #$01                  
9977  85 51    STA $51                   
9979  B5 B0    LDA $B0,X                 
997B  C9 4E    CMP #$4E                  
997D  D0 20    BNE $999F                 
997F  BD 40 06 LDA $0640,X               
9982  D0 07    BNE $998B                 
9984  A9 36    LDA #$36                  
9986  85 F1    STA $F1                   
9988  FE 40 06 INC $0640,X               

loc_998B:  ; xrefs(1): $9982
998B  20 D6 A6 JSR $A6D6                 
998E  20 18 81 JSR $8118                 
9991  A9 35    LDA #$35                  
9993  20 D9 99 JSR $99D9                 
9996  D0 06    BNE $999E                 
9998  FE 50 06 INC $0650,X               
999B  20 73 9A JSR $9A73                 

loc_999E:  ; xrefs(1): $9996
999E  60       RTS                       

loc_999F:  ; xrefs(1): $997D
999F  4C 3F 81 JMP $813F                 

sub_99A2:  ; xrefs(1): $81EA
99A2  A0 06    LDY #$06                  
99A4  20 1F 92 JSR $921F                 
99A7  BD 90 06 LDA $0690,X               
99AA  20 10 80 JSR $8010                 
99AD  64 9A    NOP $9A                   
99AF  C6 9A    DEC $9A                   
99B1  C7 99    DCP $99                   
99B3  7C 9A E7 NOP $E79A,X               
99B6  9A       TXS                       
99B7  8D 9A B8 STA $B89A                 
99BA  9A       TXS                       
99BB  C6 9A    DEC $9A                   
99BD  E1 99    SBC ($99,X)               
99BF  C6 9A    DEC $9A                   
99C1  01 9A    ORA ($9A,X)               
99C3  09 9A    ORA #$9A                  

; ---- data $99C5-$99D8 (20 bytes) ----
99C5  42 9A 20 D6 A6 20 5E AE D0 06 A9 08 9D 90 06 60  |B. .. ^........`
99D5  FE 90 06 60                                      |...`

sub_99D9:  ; xrefs(12): $9993 $9D7B $9DB0 $A049 $A164 $A3B3 $A427 $A523 $A537 $AA6F
99D9  A0 04    LDY #$04                  

sub_99DB:  ; xrefs(3): $82FF $B0D1 $B0E6
99DB  20 AB BD JSR $BDAB                 
99DE  4C E0 80 JMP $80E0                 

; ---- data $99E1-$9A72 (146 bytes) ----
99E1  A9 33 20 D9 99 20 E6 80 D0 03 20 FC 99 20 E0 80  |.3 .. .... .. ..
99F1  D0 08 A9 40 9D 10 06 FE 90 06 60 A9 0A 4C 81 80  |...@......`..L..
9A01  A9 2B 85 F1 FE 90 06 60 20 38 9A BD D0 06 C9 01  |.+.....` 8......
9A11  D0 0F A5 0C 29 04 F0 09 A5 26 D0 05 A0 12 20 33  |....)....&.... 3
9A21  92 A9 34 20 D9 99 D0 18 BD 80 06 49 FF 9D 80 06  |..4 .......I....
9A31  A9 38 85 F1 FE 90 06 A5 26 D0 05 A0 06 20 33 92  |.8......&.... 3.
9A41  60 A9 A0 20 D8 A6 98 10 17 A9 36 85 F1 20 3F 81  |`.. ......6.. ?.
9A51  B5 A0 69 80 20 B3 80 95 A0 75 B0 29 FE 95 B0 60  |..i. ....u.)...`
9A61  4C 3F 81 20 30 AE A5 94 9D 10 06 A9 35 20 D9 99  |L?. 0.......5 ..
9A71  D0 08                                            |..

sub_9A73:  ; xrefs(1): $999B
9A73  A9 40    LDA #$40                  
9A75  9D 10 06 STA $0610,X               
9A78  FE 90 06 INC $0690,X               
9A7B  60       RTS                       

; ---- data $9A7C-$9B04 (137 bytes) ----
9A7C  20 30 AE A5 94 9D 10 06 A9 3D 20 D9 99 F0 11 D0  | 0.......= .....
9A8C  1A 20 30 AE A5 94 9D 10 06 A9 35 20 D9 99 D0 0B  |. 0.......5 ....
9A9C  9D 20 06 A9 10 9D 10 06 FE 90 06 60 A9 36 20 28  |. .........`.6 (
9AAC  90 BD A0 06 D0 05 A9 02 9D E0 06 60 A5 0E 6A 90  |...........`..j.
9ABC  05 A9 08 9D 90 06 FE 90 06 60 BD A0 06 D0 DD DE  |.........`......
9ACC  10 06 D0 03 FE 90 06 A9 31 20 D9 99 20 DA 80 D0  |........1 .. ...
9ADC  09 A9 3A 85 F1 A9 36 4C 28 90 60 20 D6 A6 20 5E  |..:...6L(.` .. ^
9AEC  AE D0 03 FE 90 06 A9 10 85 52 A5 95 30 03 20 8F  |.........R..0. .
9AFC  81 A9 32 20 D9 99 4C 3F 81                       |..2 ..L?.

sub_9B05:  ; xrefs(2): $81EA $827B
9B05  8A       TXA                       
9B06  49 01    EOR #$01                  
9B08  A8       TAY                       
9B09  B9 00 06 LDA $0600,Y               
9B0C  F0 07    BEQ $9B15                 
9B0E  B9 F0 06 LDA $06F0,Y               
9B11  C9 10    CMP #$10                  
9B13  B0 05    BCS $9B1A                 

loc_9B15:  ; xrefs(1): $9B0C
9B15  A0 1B    LDY #$1B                  
9B17  20 1F 92 JSR $921F                 

loc_9B1A:  ; xrefs(1): $9B13
9B1A  BD 90 06 LDA $0690,X               
9B1D  29 7F    AND #$7F                  
9B1F  20 10 80 JSR $8010                 
9B22  3C 9C 0F NOP $0F9C,X               

; ---- data $9B25-$9D09 (485 bytes) ----
9B25  9C 83 9C 9C 9C 06 9C 71 9C 3C 9B 61 9B 9F 9B AA  |.......q.<.a....
9B35  9B BD 9B CF 9B F7 9B A9 68 20 D9 99 D0 1B 8A 6A  |........h .....j
9B45  6A 9D 10 06 49 FF 9D 80 06 A9 80 20 63 81 BD 90  |j...I...... c...
9B55  06 29 7F 9D 90 06 FE 90 06 4C 69 9C A9 06 20 BB  |.).......Li... .
9B65  B2 BD 40 06 30 27 A9 00 85 90 20 AE B0 10 1E A9  |..@.0'.... .....
9B75  07 85 F1 20 33 81 95 C0 A9 40 20 DD 9C BD 90 06  |... 3....@ .....
9B85  10 05 A9 89 9D 90 06 DE 90 06 4C 97 9B A9 40 20  |..........L...@ 
9B95  DD 9C A9 2D 20 D9 99 4C 3F 81 20 18 81 20 24 AE  |...- ..L?. .. $.
9BA5  A9 2E 4C D9 99 B5 D0 C9 3F D0 03 FE 90 06 A9 2D  |..L.....?......-
9BB5  20 D9 99 C6 53 4C 3F 81 20 9D BD 9D 60 06 9D 70  | ...SL?. ...`..p
9BC5  06 A5 80 95 A0 A5 81 95 B0 60 A9 2D 20 D9 99 20  |.........`.- .. 
9BD5  AE B0 10 17 A9 28 85 F1 20 30 AE A5 94 49 FF 9D  |.....(.. 0...I..
9BE5  80 06 20 33 81 95 C0 FE 90 06 60 A9 01 85 53 4C  |.. 3......`...SL
9BF5  3F 81 A9 2E 20 D9 99 D0 05 A9 04 9D 90 06 4C 50  |?... .........LP
9C05  9C BD 90 06 29 80 9D 90 06 60 A9 2F 20 D9 99 BD  |....)....`./ ...
9C15  D0 06 C9 01 D0 04 A9 82 D0 0A C9 02 D0 0E A9 2C  |...............,
9C25  85 F1 A9 91 48 20 50 9C 68 4C 81 80 20 E0 80 D0  |....H P.hL.. ...
9C35  03 FE 90 06 4C 50 9C A9 2C 20 D9 99 D0 0D 20 30  |....LP.., .... 0
9C45  AE C9 03 90 03 FE 90 06 FE 90 06 A5 7F C9 03 D0  |................
9C55  06 A9 06 9D 90 06 60 20 DA 80 D0 08 A9 05 9D 90  |......` ........
9C65  06 20 8A 89 A9 00 20 DD 9C 4C 3F 81 A9 30 20 28  |. .... ..L?..0 (
9C75  90 BD A0 06 D0 05 A9 04 9D 90 06 4C 69 9C 20 30  |...........Li. 0
9C85  AE 38 A9 00 E5 94 9D 80 06 9D 10 06 A9 80 20 63  |.8............ c
9C95  81 FE 90 06 4C 50 9C A9 04 20 BB B2 BD 40 06 30  |....LP... ...@.0
9CA5  2A A9 00 85 90 20 AE B0 10 21 A9 07 85 F1 20 30  |*.... ...!.... 0
9CB5  AE A5 94 49 FF 9D 80 06 20 33 81 95 C0 A5 7F C9  |...I.... 3......
9CC5  02 D0 05 A9 05 9D 90 06 FE 90 06 A9 10 20 DD 9C  |............. ..
9CD5  A9 2D 20 D9 99 4C 3F 81 85 90 BD E0 06 C9 08 B0  |.- ..L?.........
9CE5  1A 20 73 81 D0 15 20 DA 80 D0 08 20 30 AE A5 94  |. s... .... 0...
9CF5  9D 10 06 A9 40 20 0A 9D 4C 07 9D A5 90 F0 03 20  |....@ ..L...... 
9D05  0A 9D 60 A9 10                                   |..`..

sub_9D0A:  ; xrefs(4): $8CBC $8FBD $8FF2 $9018
9D0A  85 50    STA $50                   
9D0C  A9 40    LDA #$40                  
9D0E  85 92    STA $92                   
9D10  A9 00    LDA #$00                  
9D12  85 93    STA $93                   
9D14  A9 80    LDA #$80                  
9D16  85 90    STA $90                   
9D18  A9 00    LDA #$00                  
9D1A  85 91    STA $91                   
9D1C  BD 10 06 LDA $0610,X               
9D1F  10 03    BPL $9D24                 
9D21  20 81 81 JSR $8181                 

loc_9D24:  ; xrefs(1): $9D1F
9D24  8A       TXA                       
9D25  48       PHA                       
9D26  BD 10 06 LDA $0610,X               
9D29  20 89 B1 JSR $B189                 
9D2C  20 0F C0 JSR $C00F                 
9D2F  A8       TAY                       
9D30  68       PLA                       
9D31  AA       TAX                       
9D32  98       TYA                       
9D33  10 0B    BPL $9D40                 
9D35  BD 90 06 LDA $0690,X               
9D38  09 80    ORA #$80                  
9D3A  9D 90 06 STA $0690,X               
9D3D  20 2C 81 JSR $812C                 

loc_9D40:  ; xrefs(1): $9D33
9D40  60       RTS                       

sub_9D41:  ; xrefs(2): $81EA $827B
9D41  20 FA 9F JSR $9FFA                 
9D44  BD 90 06 LDA $0690,X               
9D47  D0 13    BNE $9D5C                 
9D49  DE 90 06 DEC $0690,X               
9D4C  AD 80 06 LDA $0680                 
9D4F  9D 80 06 STA $0680,X               
9D52  A9 02    LDA #$02                  
9D54  9D 70 06 STA $0670,X               
9D57  A9 92    LDA #$92                  
9D59  9D 60 06 STA $0660,X               

loc_9D5C:  ; xrefs(1): $9D47
9D5C  BD 10 06 LDA $0610,X               
9D5F  85 50    STA $50                   
9D61  BD 20 06 LDA $0620,X               
9D64  85 51    STA $51                   
9D66  BD 80 06 LDA $0680,X               
9D69  30 03    BMI $9D6E                 
9D6B  20 81 81 JSR $8181                 

loc_9D6E:  ; xrefs(1): $9D69
9D6E  4C 3F 81 JMP $813F                 

sub_9D71:  ; xrefs(2): $81EA $827B
9D71  A9 00    LDA #$00                  
9D73  9D 80 06 STA $0680,X               
9D76  20 BB 9D JSR $9DBB                 
9D79  A9 22    LDA #$22                  
9D7B  20 D9 99 JSR $99D9                 
9D7E  BD 60 06 LDA $0660,X               
9D81  1D 70 06 ORA $0670,X               
9D84  D0 1A    BNE $9DA0                 
9D86  BD D0 06 LDA $06D0,X               
9D89  DD 30 06 CMP $0630,X               
9D8C  F0 12    BEQ $9DA0                 
9D8E  9D 30 06 STA $0630,X               
9D91  A0 A2    LDY #$A2                  
9D93  20 F1 AA JSR $AAF1                 
9D96  BD 10 06 LDA $0610,X               
9D99  85 50    STA $50                   
9D9B  BD 20 06 LDA $0620,X               
9D9E  85 51    STA $51                   

loc_9DA0:  ; xrefs(2): $9D84 $9D8C
9DA0  20 E0 80 JSR $80E0                 
9DA3  D0 03    BNE $9DA8                 
9DA5  20 B9 80 JSR $80B9                 

loc_9DA8:  ; xrefs(1): $9DA3
9DA8  4C 3F 81 JMP $813F                 

sub_9DAB:  ; xrefs(2): $81EA $827B
9DAB  20 BB 9D JSR $9DBB                 
9DAE  A9 23    LDA #$23                  
9DB0  20 D9 99 JSR $99D9                 
9DB3  D0 03    BNE $9DB8                 
9DB5  20 B9 80 JSR $80B9                 

loc_9DB8:  ; xrefs(1): $9DB3
9DB8  4C 3F 81 JMP $813F                 

sub_9DBB:  ; xrefs(3): $9D76 $9DAB $9FFA
9DBB  A5 75    LDA $75                   
9DBD  85 90    STA $90                   
9DBF  A9 00    LDA #$00                  
9DC1  06 90    ASL $90                   
9DC3  2A       ROL A                     
9DC4  06 90    ASL $90                   
9DC6  2A       ROL A                     
9DC7  06 90    ASL $90                   
9DC9  2A       ROL A                     
9DCA  06 90    ASL $90                   
9DCC  2A       ROL A                     
9DCD  85 91    STA $91                   
9DCF  A5 90    LDA $90                   
9DD1  65 34    ADC $34                   
9DD3  85 90    STA $90                   
9DD5  90 03    BCC $9DDA                 
9DD7  E6 91    INC $91                   
9DD9  18       CLC                       

loc_9DDA:  ; xrefs(1): $9DD5
9DDA  A5 32    LDA $32                   
9DDC  65 90    ADC $90                   
9DDE  95 C0    STA $C0,X                 
9DE0  A5 91    LDA $91                   
9DE2  65 33    ADC $33                   
9DE4  95 D0    STA $D0,X                 
9DE6  60       RTS                       

sub_9DE7:  ; xrefs(1): $81EA
9DE7  A0 15    LDY #$15                  
9DE9  20 1F 92 JSR $921F                 
9DEC  BD 90 06 LDA $0690,X               
9DEF  20 10 80 JSR $8010                 
9DF2  B1 9F    LDA ($9F),Y               
9DF4  6A       ROR A                     

; ---- data $9DF5-$9E11 (29 bytes) ----
9DF5  9F B1 9F 6A 9F A0 9F 6A 9F 98 9F 1B 9F 78 9E C0  |...j...j.....x..
9E05  9E 78 9E AF 9E 98 9F 52 9E B1 9F 3D 9E           |.x.....R...=.

sub_9E12:  ; xrefs(1): $81EA
9E12  A0 15    LDY #$15                  
9E14  20 1F 92 JSR $921F                 
9E17  BD 90 06 LDA $0690,X               
9E1A  20 10 80 JSR $8010                 
9E1D  B1 9F    LDA ($9F),Y               
9E1F  6A       ROR A                     

; ---- data $9E20-$9FF9 (474 bytes) ----
9E20  9F B1 9F 6A 9F A0 9F 6A 9F 98 9F 1B 9F 78 9E C0  |...j...j.....x..
9E30  9E 78 9E AF 9E 98 9F 52 9E B1 9F 3D 9E 20 FA 9F  |.x.....R...=. ..
9E40  A5 0E 29 03 D0 04 A9 07 D0 02 A9 00 9D 90 06 4C  |..)............L
9E50  3F 81 20 FA 9F A9 25 20 D9 99 20 E6 80 D0 0E A0  |?. ...% .. .....
9E60  90 20 9E AA A0 99 20 A9 AA A9 2E 85 F1 20 E0 80  |. .... ...... ..
9E70  D0 03 FE 90 06 4C 3F 81 E6 58 BD 10 06 85 50 10  |.....L?..X....P.
9E80  02 C6 51 A9 04 20 BB B2 BD 40 06 30 1A 20 00 A0  |..Q.. ...@.0. ..
9E90  90 15 BD 50 06 29 3F C9 2D D0 05 A9 07 8D F7 05  |...P.)?.-.......
9EA0  A9 14 85 F1 FE 90 06 A9 27 20 D9 99 4C 3F 81 20  |........' ..L?. 
9EB0  FA 9F A9 28 20 D9 99 D0 04 FE 90 06 60 20 FC 9E  |...( .......` ..
9EC0  20 FA 9F A9 28 20 D9 99 D0 32 20 30 AE C9 04 B0  | ...( ...2 0....
9ED0  06 A9 0B 9D 90 06 60 A5 06 29 03 F0 0B AD B2 05  |......`..)......
9EE0  0A A9 04 90 03 18 A9 FC 65 81 85 91 A5 80 85 90  |........e.......
9EF0  20 18 81 20 34 9F FE 90 06 4C 3F 81 BD 50 06 29  | .. 4....L?..P.)
9F00  3F C9 2D F0 0B BD C0 06 29 07 A8 B9 13 9F 85 75  |?.-.....)......u
9F10  4C 3F 81 A1 A1 A2 A3 A4 A5 A6 A7 20 FA 9F A9 28  |L?......... ...(
9F20  20 D9 99 D0 03 FE 90 06 20 3F 81 20 E0 80 F0 01  | ....... ?. ....
9F30  60 20 30 AE A5 91 C9 10 90 02 A9 0F A8 B9 5A 9F  |` 0...........Z.
9F40  9D 10 06 A5 94 30 09 38 A9 00 FD 10 06 9D 10 06  |.....0.8........
9F50  A9 00 85 58 A9 80 4C 63 81 60 02 04 08 0C 11 15  |...X..Lc.`......
9F60  19 1D 22 26 2A 2E 33 37 3B 3F 20 FA 9F A9 26 20  |.."&*.37;? ...& 
9F70  D9 99 20 EC 80 D0 16 A9 2D 85 F1 BD 80 06 10 08  |.. .....-.......
9F80  A0 AB 20 9E AA 4C 8D 9F A0 AB 20 A9 AA 20 E0 80  |.. ..L.... .. ..
9F90  D0 03 FE 90 06 4C 3F 81 A9 2B D0 17 A9 2A D0 13  |.....L?..+...*..
9FA0  A5 0E 29 7E D0 0B 20 FA 9F A9 06 9D 90 06 4C 3F  |..)~.. .......L?
9FB0  81 A9 24 20 D9 99 D0 03 FE 90 06 20 FA 9F 20 18  |..$ ....... .. .
9FC0  81 4C 3F 81 A5 0C D0 0A A0 90 20 A9 AA A0 99 20  |.L?....... .... 
9FD0  A9 AA BD 20 06 30 0B 20 FA 9F 30 16 20 5A 81 4C  |... .0. ..0. Z.L
9FE0  F2 9F 20 B9 B2 BD 40 06 30 08 20 AA B0 10 03 20  |.. ...@.0. .... 
9FF0  61 81 A9 24 20 D9 99 4C 3F 81                    |a..$ ..L?.

sub_9FFA:  ; xrefs(2): $9D41 $A40B
9FFA  20 BB 9D JSR $9DBB                 
9FFD  D6 D0    DEC $D0,X                 
9FFF  60       RTS                       

; ---- data $A000-$A030 (49 bytes) ----
A000  A5 75 85 90 A9 00 06 90 2A 06 90 2A 06 90 2A 06  |.u......*..*..*.
A010  90 2A 85 91 C6 91 18 A5 32 65 90 85 90 A5 33 65  |.*......2e....3e
A020  91 85 91 38 B5 C0 E5 90 85 90 B5 D0 E5 91 85 91  |...8............
A030  60                                               |`

sub_A031:  ; xrefs(2): $81EA $827B
A031  8A       TXA                       
A032  45 0C    EOR $0C                   
A034  6A       ROR A                     
A035  A9 0F    LDA #$0F                  
A037  90 02    BCC $A03B                 
A039  A9 FE    LDA #$FE                  

loc_A03B:  ; xrefs(1): $A037
A03B  9D E0 06 STA $06E0,X               
A03E  DE 10 06 DEC $0610,X               
A041  D0 03    BNE $A046                 
A043  4C B9 80 JMP $80B9                 

loc_A046:  ; xrefs(1): $A041
A046  60       RTS                       

sub_A047:  ; xrefs(2): $81EA $827B
A047  A9 20    LDA #$20                  
A049  20 D9 99 JSR $99D9                 
A04C  D0 03    BNE $A051                 
A04E  4C B9 80 JMP $80B9                 

loc_A051:  ; xrefs(1): $A04C
A051  60       RTS                       

sub_A052:  ; xrefs(1): $A167
A052  A5 0C    LDA $0C                   
A054  29 07    AND #$07                  
A056  D0 0A    BNE $A062                 
A058  A0 0B    LDY #$0B                  

loc_A05A:  ; xrefs(1): $A060
A05A  B9 00 06 LDA $0600,Y               
A05D  F0 04    BEQ $A063                 
A05F  88       DEY                       
A060  10 F8    BPL $A05A                 

loc_A062:  ; xrefs(1): $A056
A062  60       RTS                       

loc_A063:  ; xrefs(1): $A05D
A063  A5 A0    LDA $A0                   
A065  99 A0 00 STA $00A0,Y               
A068  A5 B0    LDA $B0                   
A06A  99 B0 00 STA $00B0,Y               
A06D  A5 C0    LDA $C0                   
A06F  99 C0 00 STA $00C0,Y               
A072  A5 D0    LDA $D0                   
A074  99 D0 00 STA $00D0,Y               
A077  20 D4 80 JSR $80D4                 
A07A  99 00 06 STA $0600,Y               
A07D  A9 A0    LDA #$A0                  
A07F  99 50 06 STA $0650,Y               
A082  99 F0 06 STA $06F0,Y               
A085  AD 60 06 LDA $0660                 
A088  99 60 06 STA $0660,Y               
A08B  AD 70 06 LDA $0670                 
A08E  99 70 06 STA $0670,Y               
A091  AD 80 06 LDA $0680                 
A094  99 80 06 STA $0680,Y               
A097  A9 20    LDA #$20                  
A099  99 10 06 STA $0610,Y               
A09C  A9 00    LDA #$00                  
A09E  99 D0 06 STA $06D0,Y               
A0A1  99 C0 06 STA $06C0,Y               
A0A4  99 A0 06 STA $06A0,Y               
A0A7  99 B0 06 STA $06B0,Y               
A0AA  60       RTS                       

sub_A0AB:  ; xrefs(2): $A10B $A4E6
A0AB  A5 0C    LDA $0C                   
A0AD  29 03    AND #$03                  
A0AF  D0 39    BNE $A0EA                 
A0B1  BD F0 06 LDA $06F0,X               
A0B4  C9 10    CMP #$10                  
A0B6  B0 09    BCS $A0C1                 
A0B8  A5 0C    LDA $0C                   
A0BA  29 0C    AND #$0C                  
A0BC  18       CLC                       
A0BD  69 10    ADC #$10                  
A0BF  D0 04    BNE $A0C5                 

loc_A0C1:  ; xrefs(1): $A0B6
A0C1  A5 0C    LDA $0C                   
A0C3  29 0C    AND #$0C                  

loc_A0C5:  ; xrefs(1): $A0BF
A0C5  A8       TAY                       
A0C6  B9 EC A0 LDA $A0EC,Y               
A0C9  8D AD 03 STA $03AD                 
A0CC  B9 ED A0 LDA $A0ED,Y               
A0CF  8D AE 03 STA $03AE                 
A0D2  B9 EE A0 LDA $A0EE,Y               
A0D5  8D AF 03 STA $03AF                 
A0D8  A5 26    LDA $26                   
A0DA  F0 04    BEQ $A0E0                 
A0DC  C9 06    CMP #$06                  
A0DE  D0 0A    BNE $A0EA                 

loc_A0E0:  ; xrefs(1): $A0DA
A0E0  A5 27    LDA $27                   
A0E2  09 94    ORA #$94                  
A0E4  A8       TAY                       
A0E5  A9 06    LDA #$06                  
A0E7  4C A9 80 JMP $80A9                 

loc_A0EA:  ; xrefs(2): $A0AF $A0DE
A0EA  60       RTS                       

; ---- data $A0EB-$A10A (32 bytes) ----
A0EB  0F 13 21 30 0F 0F 12 30 0F 0F 0F 23 0F 0F 12 30  |..!0...0...#...0
A0FB  0F 12 22 30 0F 0F 16 26 0F 0F 0F 21 0F 0F 16 26  |.."0...&...!...&

sub_A10B:  ; xrefs(1): $81EA
A10B  20 AB A0 JSR $A0AB                 
A10E  20 30 AE JSR $AE30                 
A111  C9 18    CMP #$18                  
A113  B0 07    BCS $A11C                 
A115  20 5E AE JSR $AE5E                 
A118  C9 18    CMP #$18                  
A11A  90 0C    BCC $A128                 

loc_A11C:  ; xrefs(1): $A113
A11C  A5 33    LDA $33                   
A11E  E9 01    SBC #$01                  
A120  95 D0    STA $D0,X                 
A122  A5 31    LDA $31                   
A124  69 08    ADC #$08                  
A126  95 B0    STA $B0,X                 

loc_A128:  ; xrefs(1): $A11A
A128  BD A0 06 LDA $06A0,X               
A12B  D0 3A    BNE $A167                 
A12D  BD 90 06 LDA $0690,X               
A130  20 10 80 JSR $8010                 
A133  DB A2 62 DCP $62A2,Y               
A136  A2 F4    LDX #$F4                  
A138  A1 3D    LDA ($3D,X)               
A13A  A1 A7    LDA ($A7,X)               
A13C  A2 38    LDX #$38                  
A13E  B5 D0    LDA $D0,X                 
A140  E5 33    SBC $33                   
A142  90 07    BCC $A14B                 
A144  C9 08    CMP #$08                  
A146  D0 03    BNE $A14B                 
A148  4C B3 80 JMP $80B3                 

loc_A14B:  ; xrefs(2): $A142 $A146
A14B  C9 04    CMP #$04                  
A14D  A9 6E    LDA #$6E                  
A14F  90 02    BCC $A153                 
A151  A9 66    LDA #$66                  

loc_A153:  ; xrefs(1): $A14F
A153  8D 60 06 STA $0660                 
A156  A9 02    LDA #$02                  
A158  8D 70 06 STA $0670                 
A15B  A9 20    LDA #$20                  
A15D  85 52    STA $52                   
A15F  20 3F 81 JSR $813F                 
A162  A9 1C    LDA #$1C                  
A164  4C D9 99 JMP $99D9                 

loc_A167:  ; xrefs(1): $A12B
A167  20 52 A0 JSR $A052                 
A16A  A9 1F    LDA #$1F                  
A16C  20 28 90 JSR $9028                 
A16F  BD A0 06 LDA $06A0,X               
A172  D0 15    BNE $A189                 
A174  38       SEC                       
A175  B5 B0    LDA $B0,X                 
A177  E5 31    SBC $31                   
A179  90 08    BCC $A183                 
A17B  C9 11    CMP #$11                  
A17D  90 0A    BCC $A189                 
A17F  A9 FF    LDA #$FF                  
A181  D0 02    BNE $A185                 

loc_A183:  ; xrefs(1): $A179
A183  A9 11    LDA #$11                  

loc_A185:  ; xrefs(1): $A181
A185  65 31    ADC $31                   
A187  95 B0    STA $B0,X                 

loc_A189:  ; xrefs(2): $A172 $A17D
A189  BD C0 06 LDA $06C0,X               
A18C  C9 10    CMP #$10                  
A18E  90 1A    BCC $A1AA                 
A190  C9 1C    CMP #$1C                  
A192  A9 20    LDA #$20                  
A194  90 01    BCC $A197                 
A196  0A       ASL A                     

loc_A197:  ; xrefs(1): $A194
A197  85 90    STA $90                   
A199  BD 80 06 LDA $0680,X               
A19C  0A       ASL A                     
A19D  A5 90    LDA $90                   
A19F  90 07    BCC $A1A8                 
A1A1  C6 51    DEC $51                   
A1A3  38       SEC                       
A1A4  A9 00    LDA #$00                  
A1A6  E5 90    SBC $90                   

loc_A1A8:  ; xrefs(1): $A19F
A1A8  85 50    STA $50                   

loc_A1AA:  ; xrefs(1): $A18E
A1AA  4C 3F 81 JMP $813F                 

; ---- data $A1AD-$A1C1 (21 bytes) ----
A1AD  A0 0B B9 00 06 F0 05 68 68 68 68 60 88 D0 F3 60  |.......hhhh`...`
A1BD  A9 07 4C 81 80                                   |..L..

loc_A1C2:  ; xrefs(2): $8562 $85E6
A1C2  B5 A0    LDA $A0,X                 
A1C4  99 90 07 STA $0790,Y               
A1C7  B5 B0    LDA $B0,X                 
A1C9  99 A0 07 STA $07A0,Y               
A1CC  B5 C0    LDA $C0,X                 
A1CE  99 B0 07 STA $07B0,Y               
A1D1  B5 D0    LDA $D0,X                 
A1D3  99 C0 07 STA $07C0,Y               
A1D6  60       RTS                       

sub_A1D7:  ; xrefs(9): $871B $875B $8C15 $8CA5 $8D08 $8E21 $8E7A $8EC8 $90C6
A1D7  B5 A0    LDA $A0,X                 
A1D9  65 90    ADC $90                   
A1DB  99 90 07 STA $0790,Y               
A1DE  B5 B0    LDA $B0,X                 
A1E0  65 91    ADC $91                   
A1E2  99 A0 07 STA $07A0,Y               
A1E5  B5 C0    LDA $C0,X                 
A1E7  65 92    ADC $92                   
A1E9  99 B0 07 STA $07B0,Y               
A1EC  B5 D0    LDA $D0,X                 
A1EE  65 93    ADC $93                   
A1F0  99 C0 07 STA $07C0,Y               
A1F3  60       RTS                       

; ---- data $A1F4-$A3A7 (436 bytes) ----
A1F4  A9 00 85 90 A5 0C 29 03 D0 03 FE 30 06 20 93 A2  |......)....0. ..
A204  20 3F 81 20 AD A1 A5 55 C9 0F F0 03 20 5D A2 A9  | ?. ...U.... ]..
A214  1E 20 D9 99 20 E6 80 D0 2F 20 BA AD 30 2A AD CB  |. .. .../ ..0*..
A224  05 0A A9 40 B0 02 A9 C0 99 E0 07 20 21 81 BD 80  |...@....... !...
A234  06 0A A9 01 B0 02 A9 FF 85 91 A9 80 85 92 C6 93  |................
A244  20 D7 A1 A9 88 4C 7B 90 20 E0 80 D0 06 20 D4 A2  | ....L{. .... ..
A254  4C 58 A2 60 A9 00 85 7D 60 A9 39 85 7D 60 20 52  |LX.`...}`.9.}` R
A264  A0 A5 55 C9 0F F0 03 20 5D A2 A9 21 20 D9 99 D0  |..U.... ]..! ...
A274  08 A9 04 9D 90 06 4C 58 A2 A9 10 85 90 A5 0C 29  |......LX.......)
A284  03 D0 06 FE 30 06 FE 30 06 20 93 A2 4C 3F 81 BD  |....0..0. ..L?..
A294  30 06 20 78 C0 18 A5 52 65 92 85 52 A5 53 65 93  |0. x...Re..R.Se.
A2A4  85 53 60 20 AD A1 A9 1D 20 D9 99 BD D0 06 C9 01  |.S` .... .......
A2B4  D0 0E BD C0 06 C9 20 D0 07 A9 2B 85 F1 20 BD A1  |...... ...+.. ..
A2C4  20 EC 80 D0 05 A9 2C 85 F1 60 20 E0 80 F0 01 60  | .....,..` ....`
A2D4  A9 38 85 F1 4C B3 80 A5 0C 6A 90 2A A5 0E 29 7E  |.8..L....j.*..)~
A2E4  D0 24 38 A5 B0 E5 31 E9 02 C9 0C B0 19 A5 D0 E5  |.$8...1.........
A2F4  33 E9 02 C9 0C B0 0F AD C5 05 F0 02 A5 0E 6A A9  |3.............j.
A304  01 69 00 9D 90 06 20 52 A0 BD 80 06 48 20 18 81  |.i.... R....H ..
A314  68 45 94 10 05 A9 05 9D 40 06 20 73 81 D0 15 20  |hE......@. s... 
A324  DA 80 D0 10 20 18 81 BD 20 06 69 10 9D 20 06 A9  |.... ... .i.. ..
A334  1F 4C 28 90 A5 0C 29 07 D0 23 A5 82 85 92 A5 83  |.L(...)..#......
A344  85 93 C6 93 AD CB 05 10 04 E6 93 E6 93 20 4B 80  |............. K.
A354  20 2E 80 A9 00 85 90 BD 10 06 20 6D 80 A9 10 85  | ......... m....
A364  90 A5 0C 29 07 D0 06 FE 20 06 FE 20 06 BD 20 06  |...).... .. .. .
A374  20 78 C0 18 A5 50 65 90 85 50 A5 51 65 91 85 51  | x...Pe..P.Qe..Q
A384  A9 00 85 90 A5 0C 29 03 D0 03 FE 30 06 20 93 A2  |......)....0. ..
A394  BD 40 06 F0 07 DE 40 06 A9 21 D0 02 A9 1C 20 D9  |.@....@..!.... .
A3A4  99 4C 3F 81                                      |.L?.

sub_A3A8:  ; xrefs(1): $81EA
A3A8  DE 90 06 DEC $0690,X               
A3AB  D0 03    BNE $A3B0                 
A3AD  4C 87 A9 JMP $A987                 

loc_A3B0:  ; xrefs(1): $A3AB
A3B0  60       RTS                       

sub_A3B1:  ; xrefs(2): $81EA $827B
A3B1  A9 04    LDA #$04                  
A3B3  20 D9 99 JSR $99D9                 
A3B6  D0 03    BNE $A3BB                 
A3B8  4C 87 A9 JMP $A987                 

loc_A3BB:  ; xrefs(1): $A3B6
A3BB  60       RTS                       

sub_A3BC:  ; xrefs(1): $827B
A3BC  20 8A 80 JSR $808A                 
A3BF  8A       TXA                       
A3C0  49 01    EOR #$01                  
A3C2  A8       TAY                       
A3C3  B9 00 06 LDA $0600,Y               
A3C6  F0 1D    BEQ $A3E5                 
A3C8  B9 50 06 LDA $0650,Y               
A3CB  29 3F    AND #$3F                  
A3CD  C9 19    CMP #$19                  
A3CF  F0 14    BEQ $A3E5                 
A3D1  A9 30    LDA #$30                  
A3D3  20 28 90 JSR $9028                 
A3D6  DE 10 06 DEC $0610,X               
A3D9  F0 06    BEQ $A3E1                 
A3DB  20 7E 92 JSR $927E                 
A3DE  4C 8A 80 JMP $808A                 

loc_A3E1:  ; xrefs(1): $A3D9
A3E1  20 B9 80 JSR $80B9                 
A3E4  60       RTS                       

loc_A3E5:  ; xrefs(2): $A3C6 $A3CF
A3E5  A9 7D    LDA #$7D                  
A3E7  20 27 A4 JSR $A427                 
A3EA  C9 01    CMP #$01                  
A3EC  F0 7F    BEQ $A46D                 
A3EE  C9 02    CMP #$02                  
A3F0  F0 78    BEQ $A46A                 
A3F2  C9 03    CMP #$03                  
A3F4  F0 05    BEQ $A3FB                 
A3F6  C9 05    CMP #$05                  
A3F8  F0 58    BEQ $A452                 
A3FA  60       RTS                       

sub_A3FB:  ; xrefs(2): $827B $A3F4
A3FB  A9 06    LDA #$06                  
A3FD  85 7F    STA $7F                   

loc_A3FF:  ; xrefs(4): $A420 $A44B $A49C $A4BA
A3FF  A9 04    LDA #$04                  
A401  A0 80    LDY #$80                  
A403  4C A9 80 JMP $80A9                 

sub_A406:  ; xrefs(1): $827B
A406  A9 1F    LDA #$1F                  
A408  8D A3 05 STA $05A3                 
A40B  20 FA 9F JSR $9FFA                 
A40E  20 3F 81 JSR $813F                 
A411  A9 7C    LDA #$7C                  
A413  20 27 A4 JSR $A427                 
A416  C9 01    CMP #$01                  
A418  F0 53    BEQ $A46D                 
A41A  C9 03    CMP #$03                  
A41C  F0 4C    BEQ $A46A                 
A41E  C9 04    CMP #$04                  
A420  F0 DD    BEQ $A3FF                 
A422  C9 06    CMP #$06                  
A424  F0 32    BEQ $A458                 
A426  60       RTS                       

sub_A427:  ; xrefs(6): $A3E7 $A413 $A43E $A489 $A4A2 $A4C2
A427  20 D9 99 JSR $99D9                 
A42A  20 8A 80 JSR $808A                 
A42D  20 E0 80 JSR $80E0                 
A430  D0 06    BNE $A438                 
A432  20 FA A4 JSR $A4FA                 
A435  4C B9 80 JMP $80B9                 

loc_A438:  ; xrefs(1): $A430
A438  BD D0 06 LDA $06D0,X               
A43B  60       RTS                       

sub_A43C:  ; xrefs(1): $827B
A43C  A9 15    LDA #$15                  
A43E  20 27 A4 JSR $A427                 
A441  C9 01    CMP #$01                  
A443  F0 2D    BEQ $A472                 
A445  C9 03    CMP #$03                  
A447  F0 21    BEQ $A46A                 
A449  C9 04    CMP #$04                  
A44B  F0 B2    BEQ $A3FF                 
A44D  C9 06    CMP #$06                  
A44F  F0 07    BEQ $A458                 
A451  60       RTS                       

loc_A452:  ; xrefs(1): $A3F8
A452  20 61 A4 JSR $A461                 
A455  4C 17 83 JMP $8317                 

loc_A458:  ; xrefs(5): $A424 $A44F $A496 $A4B3 $A4CF
A458  20 5E A4 JSR $A45E                 
A45B  4C 17 83 JMP $8317                 

sub_A45E:  ; xrefs(1): $A458
A45E  20 8E 80 JSR $808E                 

sub_A461:  ; xrefs(1): $A452
A461  A9 20    LDA #$20                  
A463  85 F1    STA $F1                   
A465  A0 01    LDY #$01                  
A467  4C 9E 80 JMP $809E                 

loc_A46A:  ; xrefs(5): $A3F0 $A41C $A447 $A4AB $A4CB
A46A  4C 7E 92 JMP $927E                 

loc_A46D:  ; xrefs(2): $A3EC $A418
A46D  A0 18    LDY #$18                  
A46F  20 33 92 JSR $9233                 

loc_A472:  ; xrefs(1): $A443
A472  20 8E 80 JSR $808E                 

loc_A475:  ; xrefs(3): $A48E $A4A7 $A4C7
A475  A5 55    LDA $55                   
A477  C9 0F    CMP #$0F                  
A479  F0 08    BEQ $A483                 
A47B  C9 10    CMP #$10                  
A47D  F0 04    BEQ $A483                 
A47F  A9 0F    LDA #$0F                  
A481  85 F8    STA $F8                   

loc_A483:  ; xrefs(2): $A479 $A47D
A483  60       RTS                       

sub_A484:  ; xrefs(1): $827B
A484  20 E9 A4 JSR $A4E9                 
A487  A9 7E    LDA #$7E                  
A489  20 27 A4 JSR $A427                 
A48C  C9 01    CMP #$01                  
A48E  F0 E5    BEQ $A475                 
A490  C9 02    CMP #$02                  
A492  F0 45    BEQ $A4D9                 
A494  C9 06    CMP #$06                  
A496  F0 C0    BEQ $A458                 
A498  C9 04    CMP #$04                  
A49A  D0 03    BNE $A49F                 
A49C  4C FF A3 JMP $A3FF                 

loc_A49F:  ; xrefs(1): $A49A
A49F  60       RTS                       

sub_A4A0:  ; xrefs(1): $827B
A4A0  A9 7F    LDA #$7F                  
A4A2  20 27 A4 JSR $A427                 
A4A5  C9 01    CMP #$01                  
A4A7  F0 CC    BEQ $A475                 
A4A9  C9 02    CMP #$02                  
A4AB  F0 BD    BEQ $A46A                 
A4AD  C9 03    CMP #$03                  
A4AF  F0 05    BEQ $A4B6                 
A4B1  C9 05    CMP #$05                  
A4B3  F0 A3    BEQ $A458                 
A4B5  60       RTS                       

loc_A4B6:  ; xrefs(1): $A4AF
A4B6  A9 3A    LDA #$3A                  
A4B8  85 F1    STA $F1                   

loc_A4BA:  ; xrefs(1): $A4D5
A4BA  4C FF A3 JMP $A3FF                 

sub_A4BD:  ; xrefs(1): $827B
A4BD  20 E9 A4 JSR $A4E9                 
A4C0  A9 0B    LDA #$0B                  
A4C2  20 27 A4 JSR $A427                 
A4C5  C9 01    CMP #$01                  
A4C7  F0 AC    BEQ $A475                 
A4C9  C9 02    CMP #$02                  
A4CB  F0 9D    BEQ $A46A                 
A4CD  C9 06    CMP #$06                  
A4CF  F0 87    BEQ $A458                 
A4D1  C9 04    CMP #$04                  
A4D3  D0 03    BNE $A4D8                 
A4D5  4C BA A4 JMP $A4BA                 

loc_A4D8:  ; xrefs(1): $A4D3
A4D8  60       RTS                       

loc_A4D9:  ; xrefs(1): $A492
A4D9  A9 00    LDA #$00                  
A4DB  A0 0F    LDY #$0F                  

loc_A4DD:  ; xrefs(1): $A4E1
A4DD  99 80 07 STA $0780,Y               
A4E0  88       DEY                       
A4E1  10 FA    BPL $A4DD                 
A4E3  20 7E 92 JSR $927E                 
A4E6  4C AB A0 JMP $A0AB                 

sub_A4E9:  ; xrefs(2): $A484 $A4BD
A4E9  38       SEC                       
A4EA  A5 D0    LDA $D0                   
A4EC  E5 33    SBC $33                   
A4EE  C9 0C    CMP #$0C                  
A4F0  B0 07    BCS $A4F9                 
A4F2  A9 04    LDA #$04                  
A4F4  85 52    STA $52                   
A4F6  4C 3F 81 JMP $813F                 

loc_A4F9:  ; xrefs(1): $A4F0
A4F9  60       RTS                       

sub_A4FA:  ; xrefs(1): $A432
A4FA  18       CLC                       
A4FB  A9 E8    LDA #$E8                  
A4FD  6D FF 05 ADC $05FF                 
A500  8D FF 05 STA $05FF                 
A503  AD FE 05 LDA $05FE                 
A506  69 03    ADC #$03                  
A508  8D FE 05 STA $05FE                 
A50B  90 03    BCC $A510                 
A50D  EE FD 05 INC $05FD                 

loc_A510:  ; xrefs(1): $A50B
A510  60       RTS                       

sub_A511:  ; xrefs(1): $81EA
A511  20 18 81 JSR $8118                 
A514  A9 01    LDA #$01                  
A516  85 53    STA $53                   
A518  18       CLC                       
A519  A5 33    LDA $33                   
A51B  69 0B    ADC #$0B                  
A51D  D5 D0    CMP $D0,X                 
A51F  D0 14    BNE $A535                 
A521  A9 14    LDA #$14                  
A523  20 D9 99 JSR $99D9                 
A526  D0 0C    BNE $A534                 
A528  A9 07    LDA #$07                  
A52A  85 F1    STA $F1                   
A52C  FE 50 06 INC $0650,X               
A52F  A9 01    LDA #$01                  
A531  9D 90 06 STA $0690,X               

loc_A534:  ; xrefs(1): $A526
A534  60       RTS                       

loc_A535:  ; xrefs(1): $A51F
A535  A9 0F    LDA #$0F                  
A537  20 D9 99 JSR $99D9                 
A53A  4C 3F 81 JMP $813F                 

sub_A53D:  ; xrefs(1): $81EA
A53D  A0 0C    LDY #$0C                  
A53F  20 1F 92 JSR $921F                 
A542  BD 90 06 LDA $0690,X               
A545  20 10 80 JSR $8010                 
A548  E2 A7    NOP #$A7                  
A54A  27 A7    RLA $A7                   
A54C  F6 A6    INC $A6,X                 
A54E  DD A5 FB CMP $FBA5,X               
A551  A5 E2    LDA $E2                   
A553  A7 27    LAX $27                   
A555  A7 F6    LAX $F6                   
A557  A6 DD    LDX $DD                   
A559  A5 24    LDA $24                   
A55B  A6 E2    LDX $E2                   
A55D  A7 27    LAX $27                   
A55F  A7 F6    LAX $F6                   
A561  A6 10    LDX $10                   
A563  A7 C9    LAX $C9                   
A565  A7 1C    LAX $1C                   
A567  A7 EB    LAX $EB                   
A569  A5 81    LDA $81                   
A56B  A6 C0    LDX $C0                   
A56D  A7 AB    LAX $AB                   
A56F  A6 B2    LDX $B2                   
A571  A5 D2    LDA $D2                   
A573  A5 98    LDA $98                   
A575  A5 D2    LDA $D2                   
A577  A5 C2    LDA $C2                   
A579  A5 53    LDA $53                   
A57B  A6 D3    LDX $D3                   
A57D  A6 C0    LDX $C0                   
A57F  A7 AB    LAX $AB                   
A581  A6 8A    LDX $8A                   
A583  A5 53    LDA $53                   
A585  A6 E2    LDX $E2                   
A587  A7 16    LAX $16                   
A589  A7 A9    LAX $A9                   
A58B  1B 20 D9 SLO $D920,Y               
A58E  99 D0 06 STA $06D0,Y               
A591  20 5A 81 JSR $815A                 
A594  FE 90 06 INC $0690,X               
A597  60       RTS                       

; ---- data $A598-$A6D5 (318 bytes) ----
A598  A9 18 20 C6 A5 BD 90 06 C9 17 D0 0D A5 0C 6A 90  |.. ...........j.
A5A8  03 4C BD A5 A9 19 9D 90 06 60 A9 11 20 C6 A5 20  |.L.......`.. .. 
A5B8  E0 80 F0 01 60 A9 79 4C 81 80 A9 18 D0 00 20 D9  |....`.yL...... .
A5C8  99 D0 06 20 5A 81 FE 90 06 60 A9 12 20 D9 99 D0  |... Z....`.. ...
A5D8  03 FE 90 06 60 A9 14 20 D9 99 D0 06 20 61 81 FE  |....`.. .... a..
A5E8  90 06 60 A9 14 20 D9 99 D0 08 A9 F0 20 63 81 FE  |..`.. ...... c..
A5F8  90 06 60 A9 0F 20 D9 99 A9 02 20 BB B2 20 D6 A6  |..`.. .... .. ..
A608  BD 40 06 30 14 20 AA B0 10 0F 20 33 81 95 C0 A9  |.@.0. .... 3....
A618  07 85 F1 20 6F 81 FE 90 06 4C 3F 81 A9 0F 20 D9  |... o....L?... .
A628  99 A9 02 20 BB B2 20 24 AE 20 D6 A6 20 24 AE BD  |... .. $. .. $..
A638  40 06 30 14 20 AA B0 10 0F 20 33 81 95 C0 A9 07  |@.0. .... 3.....
A648  85 F1 20 61 81 FE 90 06 4C 3F 81 A9 0F 20 D9 99  |.. a....L?... ..
A658  A9 02 20 BB B2 20 24 AE A9 20 20 D8 A6 20 24 AE  |.. .. $..  .. $.
A668  BD 40 06 30 11 20 AA B0 10 0C 20 33 81 95 C0 A9  |.@.0. .... 3....
A678  07 85 F1 FE 90 06 4C 3F 81 A9 0F 20 D9 99 A9 02  |......L?... ....
A688  20 BB B2 A9 28 20 D8 A6 BD 40 06 30 13 20 AA B0  | ...( ...@.0. ..
A698  10 0E 20 33 81 95 C0 A9 07 85 F1 A9 0E 9D 90 06  |.. 3............
A6A8  4C 3F 81 A9 0F 20 D9 99 A9 05 20 BB B2 BD 40 06  |L?... .... ...@.
A6B8  30 16 18 A5 33 69 03 D5 D0 B0 0D 69 01 D5 D0 90  |0...3i.....i....
A6C8  07 A9 08 85 F1 FE 90 06 4C 3F 81 4C B3 80        |........L?.L..

sub_A6D6:  ; xrefs(1): $998B
A6D6  A9 10    LDA #$10                  
A6D8  85 50    STA $50                   
A6DA  20 21 81 JSR $8121                 
A6DD  A9 40    LDA #$40                  
A6DF  85 92    STA $92                   
A6E1  A9 80    LDA #$80                  
A6E3  85 90    STA $90                   
A6E5  BD 80 06 LDA $0680,X               
A6E8  10 03    BPL $A6ED                 
A6EA  20 81 81 JSR $8181                 

loc_A6ED:  ; xrefs(1): $A6E8
A6ED  20 79 B1 JSR $B179                 
A6F0  10 03    BPL $A6F5                 
A6F2  4C 2C 81 JMP $812C                 

loc_A6F5:  ; xrefs(1): $A6F0
A6F5  60       RTS                       

; ---- data $A6F6-$A71F (42 bytes) ----
A6F6  A9 10 20 D9 99 BD D0 06 C9 04 F0 09 20 E0 80 D0  |.. ......... ...
A706  03 FE 90 06 60 A9 7C 4C 81 80 A9 0F 9D 90 06 60  |....`.|L.......`
A716  A9 02 9D 90 06 60 A9 16 20 D9                    |.....`.. .

sub_A720:  ; xrefs(1): $A8CB
A720  99 D0 03 STA $03D0,Y               
A723  FE 90 06 INC $0690,X               
A726  60       RTS                       

; ---- data $A727-$A7EF (201 bytes) ----
A727  BD A0 06 D0 24 A9 0E 20 D9 99 D0 04 FE 90 06 60  |....$.. .......`
A737  20 18 81 20 73 81 D0 0A 20 DA 80 D0 05 A9 13 4C  | .. s... ......L
A747  28 90 BD F0 06 9D 10 06 60 A9 13 20 28 90 BD A0  |(.......`.. (...
A757  06 D0 0B A9 0E 20 D9 99 A9 08 9D C0 06 60 BD D0  |..... .......`..
A767  06 C9 01 D0 2D 38 BD 10 06 FD F0 06 C9 02 A9 12  |....-8..........
A777  90 02 A9 20 20 D8 A6 98 10 15 20 30 AE C9 05 B0  |...  ..... 0....
A787  09 A5 0E 6A 90 04 A9 1B D0 02 A9 12 9D 90 06 4C  |...j...........L
A797  3F 81 C9 03 F0 17 C9 04 D0 1E BD C0 06 C9 01 D0  |?...............
A7A7  17 A0 6C BD 80 06 30 02 A0 75 4C F1 AA BD C0 06  |..l...0..uL.....
A7B7  C9 01 D0 04 A9 29 85 F1 60 A9 74 20 63 81 A9 17  |.....)..`.t c...
A7C7  D0 1E 20 D6 A6 98 0A A9 1A 90 15 A5 0E 29 03 D0  |.. ..........)..
A7D7  04 A9 1B D0 02 A9 12 9D 90 06 60 20 18 81 A9 14  |..........` ....
A7E7  20 D9 99 D0 03 FE 90 06 60                       | .......`

sub_A7F0:  ; xrefs(2): $81EA $827B
A7F0  A9 40    LDA #$40                  
A7F2  85 52    STA $52                   
A7F4  A5 26    LDA $26                   
A7F6  D0 28    BNE $A820                 
A7F8  B5 D0    LDA $D0,X                 
A7FA  DD 20 06 CMP $0620,X               
A7FD  F0 29    BEQ $A828                 
A7FF  A5 36    LDA $36                   
A801  05 37    ORA $37                   
A803  D0 1B    BNE $A820                 
A805  20 71 A8 JSR $A871                 
A808  F0 19    BEQ $A823                 
A80A  FE 30 06 INC $0630,X               
A80D  BD 30 06 LDA $0630,X               
A810  DD 40 06 CMP $0640,X               
A813  D0 0E    BNE $A823                 
A815  A9 14    LDA #$14                  
A817  85 F1    STA $F1                   
A819  A9 00    LDA #$00                  
A81B  20 89 A9 JSR $A989                 
A81E  E6 7F    INC $7F                   

loc_A820:  ; xrefs(2): $A7F6 $A803
A820  4C 33 81 JMP $8133                 

loc_A823:  ; xrefs(2): $A808 $A813
A823  B5 D0    LDA $D0,X                 
A825  9D 20 06 STA $0620,X               

loc_A828:  ; xrefs(1): $A7FD
A828  4C 3F 81 JMP $813F                 

sub_A82B:  ; xrefs(2): $81EA $827B
A82B  20 36 A8 JSR $A836                 
A82E  BD 00 06 LDA $0600,X               
A831  D0 02    BNE $A835                 
A833  E6 7F    INC $7F                   

loc_A835:  ; xrefs(1): $A831
A835  60       RTS                       

sub_A836:  ; xrefs(3): $81EA $827B $A82B
A836  A9 C0    LDA #$C0                  
A838  85 52    STA $52                   
A83A  C6 53    DEC $53                   
A83C  A5 26    LDA $26                   
A83E  D0 26    BNE $A866                 
A840  B5 D0    LDA $D0,X                 
A842  DD 20 06 CMP $0620,X               
A845  F0 27    BEQ $A86E                 
A847  A5 36    LDA $36                   
A849  05 37    ORA $37                   
A84B  D0 19    BNE $A866                 
A84D  20 71 A8 JSR $A871                 
A850  F0 17    BEQ $A869                 
A852  FE 30 06 INC $0630,X               
A855  BD 30 06 LDA $0630,X               
A858  DD 40 06 CMP $0640,X               
A85B  D0 0C    BNE $A869                 
A85D  A9 14    LDA #$14                  
A85F  85 F1    STA $F1                   
A861  A9 00    LDA #$00                  
A863  20 89 A9 JSR $A989                 

loc_A866:  ; xrefs(2): $A83E $A84B
A866  4C 33 81 JMP $8133                 

loc_A869:  ; xrefs(2): $A850 $A85B
A869  B5 D0    LDA $D0,X                 
A86B  9D 20 06 STA $0620,X               

loc_A86E:  ; xrefs(1): $A845
A86E  4C 3F 81 JMP $813F                 

sub_A871:  ; xrefs(2): $A805 $A84D
A871  8A       TXA                       
A872  48       PHA                       
A873  B5 B0    LDA $B0,X                 
A875  85 91    STA $91                   
A877  B5 D0    LDA $D0,X                 
A879  85 93    STA $93                   
A87B  20 0F BE JSR $BE0F                 
A87E  A8       TAY                       
A87F  68       PLA                       
A880  AA       TAX                       
A881  98       TYA                       
A882  60       RTS                       

sub_A883:  ; xrefs(1): $827B
A883  20 A7 A8 JSR $A8A7                 
A886  90 08    BCC $A890                 
A888  20 91 A8 JSR $A891                 
A88B  F0 03    BEQ $A890                 
A88D  20 9C A8 JSR $A89C                 

loc_A890:  ; xrefs(2): $A886 $A88B
A890  60       RTS                       

sub_A891:  ; xrefs(2): $A888 $A8D8
A891  A9 03    LDA #$03                  
A893  20 3C A9 JSR $A93C                 

; ---- jump table $A896 (3 entries) ----
A896  .word $BF46   ; [00] 
A898  .word $BF4F   ; [01] 
A89A  .word $BF58   ; [02] 

sub_A89C:  ; xrefs(2): $A88D $A8F7
A89C  20 E0 80 JSR $80E0                 
A89F  D0 05    BNE $A8A6                 
A8A1  A9 64    LDA #$64                  
A8A3  4C 89 A9 JMP $A989                 

loc_A8A6:  ; xrefs(1): $A89F
A8A6  60       RTS                       

sub_A8A7:  ; xrefs(4): $A883 $A8B8 $A8D3 $A8ED
A8A7  20 31 A9 JSR $A931                 
A8AA  20 D4 80 JSR $80D4                 
A8AD  A9 00    LDA #$00                  
A8AF  20 85 89 JSR $8985                 
A8B2  BD D0 06 LDA $06D0,X               
A8B5  C9 08    CMP #$08                  
A8B7  60       RTS                       

sub_A8B8:  ; xrefs(1): $827B
A8B8  20 A7 A8 JSR $A8A7                 
A8BB  90 08    BCC $A8C5                 
A8BD  20 C6 A8 JSR $A8C6                 
A8C0  F0 03    BEQ $A8C5                 
A8C2  20 26 A9 JSR $A926                 

loc_A8C5:  ; xrefs(2): $A8BB $A8C0
A8C5  60       RTS                       

sub_A8C6:  ; xrefs(1): $A8BD
A8C6  A9 04    LDA #$04                  
A8C8  20 3C A9 JSR $A93C                 

; ---- jump table $A8CB (6 entries) ----
A8CB  .word $BF46   ; [00] 
A8CD  .word $BF4F   ; [01] 
A8CF  .word $BF58   ; [02] 
A8D1  .word $BF61   ; [03] 
A8D3  .word $A720   ; [04] 
A8D5  .word $90A8   ; [05] 

; ---- data $A8D7-$A8D7 (1 bytes) ----
A8D7  14                                               |.
A8D8  20 91 A8 JSR $A891                 
A8DB  F0 0F    BEQ $A8EC                 
A8DD  20 E0 80 JSR $80E0                 
A8E0  D0 0A    BNE $A8EC                 
A8E2  A0 E1    LDY #$E1                  
A8E4  20 F1 AA JSR $AAF1                 
A8E7  A9 32    LDA #$32                  
A8E9  4C 89 A9 JMP $A989                 

loc_A8EC:  ; xrefs(3): $A8D6 $A8DB $A8E0
A8EC  60       RTS                       

sub_A8ED:  ; xrefs(1): $827B
A8ED  20 A7 A8 JSR $A8A7                 
A8F0  90 08    BCC $A8FA                 
A8F2  20 FB A8 JSR $A8FB                 
A8F5  F0 03    BEQ $A8FA                 
A8F7  20 9C A8 JSR $A89C                 

loc_A8FA:  ; xrefs(2): $A8F0 $A8F5
A8FA  60       RTS                       

sub_A8FB:  ; xrefs(1): $A8F2
A8FB  A9 02    LDA #$02                  
A8FD  20 3C A9 JSR $A93C                 

; ---- jump table $A900 (2 entries) ----
A900  .word $BF4F   ; [00] 
A902  .word $BF5C   ; [01] 

sub_A904:  ; xrefs(1): $827B
A904  20 31 A9 JSR $A931                 
A907  20 D4 80 JSR $80D4                 
A90A  A9 00    LDA #$00                  
A90C  20 85 89 JSR $8985                 
A90F  BD D0 06 LDA $06D0,X               
A912  C9 08    CMP #$08                  
A914  90 08    BCC $A91E                 
A916  20 1F A9 JSR $A91F                 
A919  F0 03    BEQ $A91E                 
A91B  20 26 A9 JSR $A926                 

loc_A91E:  ; xrefs(2): $A914 $A919
A91E  60       RTS                       

sub_A91F:  ; xrefs(1): $A916
A91F  A9 01    LDA #$01                  
A921  20 3C A9 JSR $A93C                 

; ---- jump table $A924 (1 entries) ----
A924  .word $BF4F   ; [00] 

sub_A926:  ; xrefs(2): $A8C2 $A91B
A926  20 E0 80 JSR $80E0                 
A929  D0 05    BNE $A930                 
A92B  A9 32    LDA #$32                  
A92D  4C 89 A9 JMP $A989                 

loc_A930:  ; xrefs(1): $A929
A930  60       RTS                       

sub_A931:  ; xrefs(2): $A8A7 $A904
A931  A5 0C    LDA $0C                   
A933  29 03    AND #$03                  
A935  D0 04    BNE $A93B                 

sub_A937:  ; xrefs(2): $8525 $8F65
A937  A9 3F    LDA #$3F                  
A939  85 F1    STA $F1                   

loc_A93B:  ; xrefs(1): $A935
A93B  60       RTS                       

sub_A93C:  ; xrefs(4): $A893 $A8C8 $A8FD $A921
A93C  85 4E    STA $4E                   
A93E  68       PLA                       
A93F  85 29    STA $29                   
A941  68       PLA                       
A942  85 2A    STA $2A                   
A944  BD 10 06 LDA $0610,X               
A947  C5 4E    CMP $4E                   
A949  F0 1B    BEQ $A966                 
A94B  38       SEC                       
A94C  2A       ROL A                     
A94D  A8       TAY                       
A94E  B1 29    LDA ($29),Y               
A950  85 4C    STA $4C                   
A952  C8       INY                       
A953  B1 29    LDA ($29),Y               
A955  85 4D    STA $4D                   
A957  20 0B BF JSR $BF0B                 
A95A  F0 0D    BEQ $A969                 
A95C  FE 10 06 INC $0610,X               
A95F  BD 10 06 LDA $0610,X               
A962  C5 4E    CMP $4E                   
A964  D0 03    BNE $A969                 

loc_A966:  ; xrefs(1): $A949
A966  A9 FF    LDA #$FF                  
A968  60       RTS                       

loc_A969:  ; xrefs(2): $A95A $A964
A969  A9 00    LDA #$00                  
A96B  60       RTS                       

sub_A96C:  ; xrefs(1): $827B
A96C  AD C2 05 LDA $05C2                 
A96F  D0 0A    BNE $A97B                 
A971  A9 09    LDA #$09                  
A973  20 85 89 JSR $8985                 
A976  20 E0 80 JSR $80E0                 
A979  D0 03    BNE $A97E                 

loc_A97B:  ; xrefs(1): $A96F
A97B  4C B9 80 JMP $80B9                 

loc_A97E:  ; xrefs(1): $A979
A97E  A9 C0    LDA #$C0                  

loc_A980:  ; xrefs(1): $AA14
A980  85 52    STA $52                   
A982  C6 53    DEC $53                   
A984  4C 3F 81 JMP $813F                 

sub_A987:  ; xrefs(3): $827B $A3AD $A3B8
A987  A9 00    LDA #$00                  

sub_A989:  ; xrefs(15): $8414 $8483 $89C6 $8F6F $8F78 $A81B $A863 $A8A3 $A8E9 $A92D
A989  48       PHA                       
A98A  BD 00 06 LDA $0600,X               
A98D  29 C0    AND #$C0                  
A98F  D0 49    BNE $A9DA                 
A991  BD 00 06 LDA $0600,X               
A994  29 3F    AND #$3F                  
A996  A8       TAY                       
A997  0A       ASL A                     
A998  B0 40    BCS $A9DA                 
A99A  B9 60 05 LDA $0560,Y               
A99D  10 3E    BPL $A9DD                 
A99F  29 7F    AND #$7F                  
A9A1  38       SEC                       
A9A2  E9 01    SBC #$01                  
A9A4  B0 02    BCS $A9A8                 
A9A6  A9 00    LDA #$00                  

loc_A9A8:  ; xrefs(1): $A9A4
A9A8  99 60 05 STA $0560,Y               
A9AB  20 73 81 JSR $8173                 
A9AE  D0 2A    BNE $A9DA                 
A9B0  BD 50 06 LDA $0650,X               
A9B3  29 3F    AND #$3F                  
A9B5  C9 08    CMP #$08                  
A9B7  90 21    BCC $A9DA                 
A9B9  20 30 AE JSR $AE30                 
A9BC  C9 05    CMP #$05                  
A9BE  B0 1A    BCS $A9DA                 
A9C0  20 21 81 JSR $8121                 
A9C3  20 51 B1 JSR $B151                 
A9C6  30 12    BMI $A9DA                 
A9C8  68       PLA                       
A9C9  48       PHA                       
A9CA  C9 32    CMP #$32                  
A9CC  A0 12    LDY #$12                  
A9CE  90 07    BCC $A9D7                 
A9D0  A5 0E    LDA $0E                   
A9D2  6A       ROR A                     
A9D3  90 02    BCC $A9D7                 
A9D5  A0 1B    LDY #$1B                  

loc_A9D7:  ; xrefs(2): $A9CE $A9D3
A9D7  20 F1 AA JSR $AAF1                 

loc_A9DA:  ; xrefs(6): $A98F $A998 $A9AE $A9B7 $A9BE $A9C6
A9DA  20 B9 80 JSR $80B9                 

loc_A9DD:  ; xrefs(1): $A99D
A9DD  68       PLA                       
A9DE  D0 01    BNE $A9E1                 
A9E0  60       RTS                       

loc_A9E1:  ; xrefs(3): $8F02 $A9DE $AA05
A9E1  18       CLC                       
A9E2  6D FF 05 ADC $05FF                 
A9E5  8D FF 05 STA $05FF                 
A9E8  AD FE 05 LDA $05FE                 
A9EB  69 00    ADC #$00                  
A9ED  8D FE 05 STA $05FE                 
A9F0  90 03    BCC $A9F5                 
A9F2  EE FD 05 INC $05FD                 

loc_A9F5:  ; xrefs(1): $A9F0
A9F5  60       RTS                       

sub_A9F6:  ; xrefs(1): $827B
A9F6  BD 10 06 LDA $0610,X               
A9F9  D0 0C    BNE $AA07                 
A9FB  A0 1B    LDY #$1B                  
A9FD  20 F1 AA JSR $AAF1                 
AA00  20 B9 80 JSR $80B9                 
AA03  A9 0A    LDA #$0A                  
AA05  D0 DA    BNE $A9E1                 

loc_AA07:  ; xrefs(1): $A9F9
AA07  38       SEC                       
AA08  B5 D0    LDA $D0,X                 
AA0A  E5 33    SBC $33                   
AA0C  90 09    BCC $AA17                 
AA0E  C9 03    CMP #$03                  
AA10  90 05    BCC $AA17                 
AA12  A9 80    LDA #$80                  
AA14  4C 80 A9 JMP $A980                 

loc_AA17:  ; xrefs(2): $AA0C $AA10
AA17  18       CLC                       
AA18  A5 33    LDA $33                   
AA1A  69 02    ADC #$02                  
AA1C  95 D0    STA $D0,X                 
AA1E  A9 00    LDA #$00                  
AA20  95 C0    STA $C0,X                 
AA22  38       SEC                       
AA23  B5 B0    LDA $B0,X                 
AA25  E5 31    SBC $31                   
AA27  C9 07    CMP #$07                  
AA29  90 0F    BCC $AA3A                 
AA2B  C9 0A    CMP #$0A                  
AA2D  B0 09    BCS $AA38                 
AA2F  BD 20 06 LDA $0620,X               
AA32  8D C4 05 STA $05C4                 
AA35  4C B9 80 JMP $80B9                 

loc_AA38:  ; xrefs(1): $AA2D
AA38  C6 51    DEC $51                   

loc_AA3A:  ; xrefs(1): $AA29
AA3A  A9 80    LDA #$80                  
AA3C  85 50    STA $50                   
AA3E  4C 3F 81 JMP $813F                 

sub_AA41:  ; xrefs(2): $81EA $827B
AA41  A9 0B    LDA #$0B                  
AA43  20 85 89 JSR $8985                 
AA46  20 E0 80 JSR $80E0                 
AA49  D0 05    BNE $AA50                 
AA4B  A9 00    LDA #$00                  
AA4D  4C 89 A9 JMP $A989                 

loc_AA50:  ; xrefs(1): $AA49
AA50  60       RTS                       

sub_AA51:  ; xrefs(1): $81EA
AA51  8A       TXA                       
AA52  45 0C    EOR $0C                   
AA54  29 03    AND #$03                  
AA56  D0 45    BNE $AA9D                 
AA58  38       SEC                       
AA59  B5 B0    LDA $B0,X                 
AA5B  E5 31    SBC $31                   
AA5D  C9 10    CMP #$10                  
AA5F  B0 07    BCS $AA68                 
AA61  20 5E AE JSR $AE5E                 
AA64  A5 95    LDA $95                   
AA66  30 0D    BMI $AA75                 

loc_AA68:  ; xrefs(1): $AA5F
AA68  BD 10 06 LDA $0610,X               
AA6B  30 30    BMI $AA9D                 
AA6D  A9 06    LDA #$06                  
AA6F  20 D9 99 JSR $99D9                 
AA72  D0 0E    BNE $AA82                 
AA74  60       RTS                       

loc_AA75:  ; xrefs(1): $AA66
AA75  A9 06    LDA #$06                  
AA77  9D 10 06 STA $0610,X               
AA7A  20 D9 99 JSR $99D9                 
AA7D  D0 03    BNE $AA82                 
AA7F  4C 9D BD JMP $BD9D                 

loc_AA82:  ; xrefs(2): $AA72 $AA7D
AA82  20 E6 80 JSR $80E6                 
AA85  D0 05    BNE $AA8C                 
AA87  A9 32    LDA #$32                  
AA89  85 F1    STA $F1                   
AA8B  60       RTS                       

loc_AA8C:  ; xrefs(1): $AA85
AA8C  C9 05    CMP #$05                  
AA8E  F0 08    BEQ $AA98                 
AA90  C9 07    CMP #$07                  
AA92  D0 09    BNE $AA9D                 
AA94  A5 55    LDA $55                   
AA96  F0 05    BEQ $AA9D                 

loc_AA98:  ; xrefs(1): $AA8E
AA98  A0 00    LDY #$00                  
AA9A  4C F1 AA JMP $AAF1                 

loc_AA9D:  ; xrefs(4): $AA56 $AA6B $AA92 $AA96
AA9D  60       RTS                       

; ---- data $AA9E-$AAC1 (36 bytes) ----
AA9E  8A 48 B5 B0 85 91 E6 91 4C B1 AA 8A 48 B5 B0 85  |.H......L...H...
AAAE  91 C6 91 B5 A0 85 90 B5 C0 85 92 B5 D0 85 93 E6  |................
AABE  93 4C F8 AA                                      |.L..

sub_AAC2:  ; xrefs(3): $87F6 $92AD $9663
AAC2  8A       TXA                       
AAC3  48       PHA                       
AAC4  4C F8 AA JMP $AAF8                 

; ---- data $AAC7-$AAE1 (27 bytes) ----
AAC7  8A 48 A9 00 85 92 A5 D0 85 93 E6 93 A5 A0 65 0E  |.H............e.
AAD7  85 90 A5 B0 69 00 85 91 4C F8 AA                 |....i...L..

sub_AAE2:  ; xrefs(2): $87F1 $AAF5
AAE2  85 92    STA $92                   
AAE4  B5 D0    LDA $D0,X                 
AAE6  85 93    STA $93                   
AAE8  B5 A0    LDA $A0,X                 
AAEA  85 90    STA $90                   
AAEC  B5 B0    LDA $B0,X                 
AAEE  85 91    STA $91                   
AAF0  60       RTS                       

sub_AAF1:  ; xrefs(10): $831D $83EB $852A $877F $8F6A $9D93 $A8E4 $A9D7 $A9FD $AA9A
AAF1  8A       TXA                       
AAF2  48       PHA                       
AAF3  B5 C0    LDA $C0,X                 
AAF5  20 E2 AA JSR $AAE2                 

loc_AAF8:  ; xrefs(1): $AAC4
AAF8  A2 0B    LDX #$0B                  

loc_AAFA:  ; xrefs(2): $842C $AB00
AAFA  BD 00 06 LDA $0600,X               
AAFD  F0 08    BEQ $AB07                 
AAFF  CA       DEX                       
AB00  10 F8    BPL $AAFA                 
AB02  68       PLA                       
AB03  AA       TAX                       
AB04  A0 FF    LDY #$FF                  
AB06  60       RTS                       

loc_AB07:  ; xrefs(1): $AAFD
AB07  20 10 AB JSR $AB10                 
AB0A  8A       TXA                       
AB0B  A8       TAY                       
AB0C  68       PLA                       
AB0D  AA       TAX                       
AB0E  98       TYA                       
AB0F  60       RTS                       

sub_AB10:  ; xrefs(1): $AB07
AB10  A5 90    LDA $90                   
AB12  95 A0    STA $A0,X                 
AB14  A5 91    LDA $91                   
AB16  95 B0    STA $B0,X                 
AB18  A5 92    LDA $92                   
AB1A  95 C0    STA $C0,X                 
AB1C  A5 93    LDA $93                   
AB1E  95 D0    STA $D0,X                 
AB20  A9 80    LDA #$80                  
AB22  9D 00 06 STA $0600,X               
AB25  B9 77 AB LDA $AB77,Y               
AB28  9D 50 06 STA $0650,X               
AB2B  B9 78 AB LDA $AB78,Y               
AB2E  9D 60 06 STA $0660,X               
AB31  B9 79 AB LDA $AB79,Y               
AB34  9D 70 06 STA $0670,X               
AB37  B9 7A AB LDA $AB7A,Y               
AB3A  9D 10 06 STA $0610,X               
AB3D  B9 7B AB LDA $AB7B,Y               
AB40  9D 20 06 STA $0620,X               
AB43  B9 7C AB LDA $AB7C,Y               
AB46  9D 30 06 STA $0630,X               
AB49  B9 7D AB LDA $AB7D,Y               
AB4C  9D 40 06 STA $0640,X               
AB4F  B9 7E AB LDA $AB7E,Y               
AB52  9D 90 06 STA $0690,X               
AB55  B9 7F AB LDA $AB7F,Y               
AB58  9D F0 06 STA $06F0,X               
AB5B  A5 80    LDA $80                   
AB5D  D5 A0    CMP $A0,X                 
AB5F  A5 81    LDA $81                   
AB61  F5 B0    SBC $B0,X                 
AB63  9D 80 06 STA $0680,X               
AB66  A9 00    LDA #$00                  
AB68  9D D0 06 STA $06D0,X               
AB6B  9D C0 06 STA $06C0,X               
AB6E  9D A0 06 STA $06A0,X               
AB71  9D B0 06 STA $06B0,X               
AB74  4C D4 80 JMP $80D4                 

; ---- data $AB77-$AC72 (252 bytes) ----
AB77  0E B2 01 00 00 00 00 00 01 19 00 00 00 00 00 00  |................
AB87  00 7F 04 00 00 00 FF C0 FF 32 10 05 00 00 00 FF  |.........2......
AB97  C0 FF 32 10 03 00 00 00 00 00 00 00 10 14 00 00  |..2.............
ABA7  00 00 00 00 00 10 15 00 00 00 00 00 00 00 10 3F  |...............?
ABB7  00 00 00 00 00 00 24 10 3F 2F 02 00 00 80 FF 26  |......$.?/.....&
ABC7  10 3F 2E 02 00 00 80 FF 26 10 3F 31 02 00 00 80  |.?......&.?1....
ABD7  00 26 10 3F 30 02 00 00 80 00 26 10 5C 5A 02 00  |.&.?0.....&.\Z..
ABE7  00 00 00 02 90 5C 58 02 00 00 00 00 02 90 5D 00  |.....\X.......].
ABF7  00 00 00 00 00 00 90 1F 00 00 00 00 00 00 00 90  |................
AC07  22 00 00 80 00 00 00 08 90 22 00 00 80 FF 00 00  |"........"......
AC17  08 90 23 00 00 00 00 00 00 00 90 24 00 00 60 00  |..#........$..`.
AC27  00 00 00 90 3F 00 00 50 00 00 00 28 10 07 00 00  |....?..P...(....
AC37  00 00 00 00 02 7F 33 00 00 00 FF B8 FF 00 7F 34  |......3........4
AC47  00 00 00 00 00 00 00 7F 5C 44 03 00 00 00 00 02  |........\D......
AC57  7F 3D 00 00 00 00 00 00 00 10 3F 00 00 00 00 00  |.=........?.....
AC67  00 08 10 0B 00 00 00 00 00 00 00 01              |............

sub_AC73:  ; xrefs(1): $81EA
AC73  A0 FF    LDY #$FF                  
AC75  20 D9 AE JSR $AED9                 
AC78  BD 10 06 LDA $0610,X               
AC7B  C9 20    CMP #$20                  
AC7D  B0 18    BCS $AC97                 
AC7F  7D 20 06 ADC $0620,X               
AC82  9D 10 06 STA $0610,X               
AC85  48       PHA                       
AC86  A5 0C    LDA $0C                   
AC88  29 07    AND #$07                  
AC8A  D0 0A    BNE $AC96                 
AC8C  BD 20 06 LDA $0620,X               
AC8F  C9 02    CMP #$02                  
AC91  B0 03    BCS $AC96                 
AC93  FE 20 06 INC $0620,X               

loc_AC96:  ; xrefs(2): $AC8A $AC91
AC96  68       PLA                       

loc_AC97:  ; xrefs(1): $AC7D
AC97  85 52    STA $52                   
AC99  90 17    BCC $ACB2                 
AC9B  A5 82    LDA $82                   
AC9D  D5 C0    CMP $C0,X                 
AC9F  A5 83    LDA $83                   
ACA1  F5 D0    SBC $D0,X                 
ACA3  B0 0D    BCS $ACB2                 
ACA5  A9 0C    LDA #$0C                  
ACA7  9D 50 06 STA $0650,X               
ACAA  A9 00    LDA #$00                  
ACAC  9D 10 06 STA $0610,X               
ACAF  9D 20 06 STA $0620,X               

loc_ACB2:  ; xrefs(2): $AC99 $ACA3
ACB2  4C 3F 81 JMP $813F                 

sub_ACB5:  ; xrefs(1): $81EA
ACB5  A9 00    LDA #$00                  
ACB7  F0 02    BEQ $ACBB                 

sub_ACB9:  ; xrefs(1): $81EA
ACB9  A9 FF    LDA #$FF                  

loc_ACBB:  ; xrefs(1): $ACB7
ACBB  9D 80 06 STA $0680,X               
ACBE  8A       TXA                       
ACBF  45 0C    EOR $0C                   
ACC1  6A       ROR A                     
ACC2  90 01    BCC $ACC5                 
ACC4  60       RTS                       

loc_ACC5:  ; xrefs(1): $ACC2
ACC5  AD 0C 06 LDA $060C                 
ACC8  F0 3E    BEQ $AD08                 
ACCA  A5 0C    LDA $0C                   
ACCC  29 7E    AND #$7E                  
ACCE  D0 38    BNE $AD08                 
ACD0  20 BA AD JSR $ADBA                 
ACD3  30 33    BMI $AD08                 
ACD5  BD 80 06 LDA $0680,X               
ACD8  0A       ASL A                     
ACD9  A9 22    LDA #$22                  
ACDB  90 02    BCC $ACDF                 
ACDD  A9 E2    LDA #$E2                  

loc_ACDF:  ; xrefs(1): $ACDB
ACDF  99 D0 07 STA $07D0,Y               
ACE2  A9 08    LDA #$08                  
ACE4  99 E0 07 STA $07E0,Y               
ACE7  A9 81    LDA #$81                  
ACE9  20 7B 90 JSR $907B                 
ACEC  B5 A0    LDA $A0,X                 
ACEE  99 90 07 STA $0790,Y               
ACF1  B5 B0    LDA $B0,X                 
ACF3  99 A0 07 STA $07A0,Y               
ACF6  B5 C0    LDA $C0,X                 
ACF8  69 80    ADC #$80                  
ACFA  99 B0 07 STA $07B0,Y               
ACFD  B5 D0    LDA $D0,X                 
ACFF  69 00    ADC #$00                  
AD01  99 C0 07 STA $07C0,Y               
AD04  A9 12    LDA #$12                  
AD06  85 F1    STA $F1                   

loc_AD08:  ; xrefs(3): $ACC8 $ACCE $ACD3
AD08  BD 40 06 LDA $0640,X               
AD0B  F0 03    BEQ $AD10                 
AD0D  DE 40 06 DEC $0640,X               

loc_AD10:  ; xrefs(1): $AD0B
AD10  A9 10    LDA #$10                  
AD12  85 52    STA $52                   
AD14  BD E0 06 LDA $06E0,X               
AD17  C9 20    CMP #$20                  
AD19  90 1C    BCC $AD37                 
AD1B  B5 A0    LDA $A0,X                 
AD1D  C5 80    CMP $80                   
AD1F  B5 B0    LDA $B0,X                 
AD21  E5 81    SBC $81                   
AD23  18       CLC                       
AD24  69 01    ADC #$01                  
AD26  C9 02    CMP #$02                  
AD28  B0 11    BCS $AD3B                 
AD2A  B5 C0    LDA $C0,X                 
AD2C  C5 82    CMP $82                   
AD2E  B5 D0    LDA $D0,X                 
AD30  E5 83    SBC $83                   
AD32  5D 90 06 EOR $0690,X               
AD35  10 04    BPL $AD3B                 

loc_AD37:  ; xrefs(1): $AD19
AD37  A9 30    LDA #$30                  
AD39  85 52    STA $52                   

loc_AD3B:  ; xrefs(2): $AD28 $AD35
AD3B  A0 0A    LDY #$0A                  
AD3D  BD 90 06 LDA $0690,X               
AD40  10 04    BPL $AD46                 
AD42  88       DEY                       
AD43  20 8F 81 JSR $818F                 

loc_AD46:  ; xrefs(1): $AD40
AD46  98       TYA                       
AD47  20 4B 90 JSR $904B                 
AD4A  20 50 AD JSR $AD50                 
AD4D  4C 3F 81 JMP $813F                 

sub_AD50:  ; xrefs(1): $AD4A
AD50  A5 0C    LDA $0C                   
AD52  29 02    AND #$02                  
AD54  F0 39    BEQ $AD8F                 
AD56  A9 01    LDA #$01                  
AD58  85 91    STA $91                   
AD5A  85 93    STA $93                   
AD5C  A5 53    LDA $53                   
AD5E  10 04    BPL $AD64                 
AD60  A9 FF    LDA #$FF                  
AD62  85 93    STA $93                   

loc_AD64:  ; xrefs(1): $AD5E
AD64  BD 80 06 LDA $0680,X               
AD67  30 04    BMI $AD6D                 
AD69  A9 FF    LDA #$FF                  
AD6B  85 91    STA $91                   

loc_AD6D:  ; xrefs(1): $AD67
AD6D  8A       TXA                       
AD6E  48       PHA                       
AD6F  18       CLC                       
AD70  B5 A0    LDA $A0,X                 
AD72  85 90    STA $90                   
AD74  B5 B0    LDA $B0,X                 
AD76  65 91    ADC $91                   
AD78  85 91    STA $91                   
AD7A  18       CLC                       
AD7B  B5 C0    LDA $C0,X                 
AD7D  85 92    STA $92                   
AD7F  B5 D0    LDA $D0,X                 
AD81  65 93    ADC $93                   
AD83  85 93    STA $93                   
AD85  20 0C C0 JSR $C00C                 
AD88  A8       TAY                       
AD89  68       PLA                       
AD8A  AA       TAX                       
AD8B  98       TYA                       
AD8C  10 16    BPL $ADA4                 
AD8E  60       RTS                       

loc_AD8F:  ; xrefs(1): $AD54
AD8F  A9 00    LDA #$00                  
AD91  85 92    STA $92                   
AD93  A9 FF    LDA #$FF                  
AD95  85 93    STA $93                   
AD97  A5 53    LDA $53                   
AD99  10 04    BPL $AD9F                 
AD9B  A9 01    LDA #$01                  
AD9D  85 93    STA $93                   

loc_AD9F:  ; xrefs(1): $AD99
AD9F  20 51 B1 JSR $B151                 
ADA2  10 15    BPL $ADB9                 

loc_ADA4:  ; xrefs(1): $AD8C
ADA4  BD 40 06 LDA $0640,X               
ADA7  F0 03    BEQ $ADAC                 
ADA9  20 BF 80 JSR $80BF                 

loc_ADAC:  ; xrefs(1): $ADA7
ADAC  A9 03    LDA #$03                  
ADAE  9D 40 06 STA $0640,X               
ADB1  BD 90 06 LDA $0690,X               
ADB4  49 80    EOR #$80                  
ADB6  9D 90 06 STA $0690,X               

loc_ADB9:  ; xrefs(1): $ADA2
ADB9  60       RTS                       

sub_ADBA:  ; xrefs(14): $8550 $85C8 $86F4 $8733 $8BFC $8C7C $8CDE $8D15 $8E0E $8E52
ADBA  A0 0F    LDY #$0F                  

loc_ADBC:  ; xrefs(1): $ADC2
ADBC  B9 80 07 LDA $0780,Y               
ADBF  F0 03    BEQ $ADC4                 
ADC1  88       DEY                       
ADC2  10 F8    BPL $ADBC                 

loc_ADC4:  ; xrefs(1): $ADBF
ADC4  60       RTS                       

sub_ADC5:  ; xrefs(1): $81EA
ADC5  8A       TXA                       
ADC6  45 0C    EOR $0C                   
ADC8  6A       ROR A                     
ADC9  B0 01    BCS $ADCC                 
ADCB  60       RTS                       

loc_ADCC:  ; xrefs(1): $ADC9
ADCC  29 07    AND #$07                  
ADCE  D0 0F    BNE $ADDF                 
ADD0  20 5E AE JSR $AE5E                 
ADD3  C9 02    CMP #$02                  
ADD5  B0 08    BCS $ADDF                 
ADD7  20 30 AE JSR $AE30                 
ADDA  A5 94    LDA $94                   
ADDC  20 27 AE JSR $AE27                 

loc_ADDF:  ; xrefs(2): $ADCE $ADD5
ADDF  A5 0C    LDA $0C                   
ADE1  29 02    AND #$02                  
ADE3  D0 22    BNE $AE07                 
ADE5  20 21 81 JSR $8121                 
ADE8  A9 80    LDA #$80                  
ADEA  85 90    STA $90                   
ADEC  E6 93    INC $93                   
ADEE  8A       TXA                       
ADEF  48       PHA                       
ADF0  20 86 B1 JSR $B186                 
ADF3  20 0C C0 JSR $C00C                 
ADF6  A8       TAY                       
ADF7  68       PLA                       
ADF8  AA       TAX                       
ADF9  98       TYA                       
ADFA  10 1D    BPL $AE19                 
ADFC  38       SEC                       
ADFD  A5 52    LDA $52                   
ADFF  E5 9D    SBC $9D                   
AE01  85 52    STA $52                   
AE03  B0 02    BCS $AE07                 
AE05  C6 53    DEC $53                   

loc_AE07:  ; xrefs(2): $ADE3 $AE03
AE07  A5 0C    LDA $0C                   
AE09  29 02    AND #$02                  
AE0B  F0 0F    BEQ $AE1C                 
AE0D  A9 08    LDA #$08                  
AE0F  85 50    STA $50                   
AE11  20 8F B0 JSR $B08F                 
AE14  10 06    BPL $AE1C                 
AE16  20 2C 81 JSR $812C                 

loc_AE19:  ; xrefs(1): $ADFA
AE19  20 24 AE JSR $AE24                 

loc_AE1C:  ; xrefs(2): $AE0B $AE14
AE1C  20 3F 81 JSR $813F                 
AE1F  A9 0D    LDA #$0D                  
AE21  4C 4B 90 JMP $904B                 

sub_AE24:  ; xrefs(7): $8FE4 $8FEA $AE19 $AF3C $AF75 $AFF6 $B029
AE24  BD 80 06 LDA $0680,X               

sub_AE27:  ; xrefs(1): $ADDC
AE27  49 FF    EOR #$FF                  
AE29  9D 80 06 STA $0680,X               
AE2C  60       RTS                       

sub_AE2D:  ; xrefs(2): $85F8 $8D5F
AE2D  20 5E AE JSR $AE5E                 

sub_AE30:  ; xrefs(11): $810D $8118 $83DC $84C6 $84D6 $8500 $8AC6 $8EE6 $A10E $A9B9
AE30  B5 A0    LDA $A0,X                 
AE32  E5 80    SBC $80                   
AE34  85 90    STA $90                   
AE36  B5 B0    LDA $B0,X                 
AE38  E5 81    SBC $81                   
AE3A  85 91    STA $91                   
AE3C  85 94    STA $94                   
AE3E  30 11    BMI $AE51                 
AE40  60       RTS                       

; ---- data $AE41-$AE50 (16 bytes) ----
AE41  B5 A0 E5 90 85 90 B5 B0 E5 91 85 91 85 94 10 0C  |................

loc_AE51:  ; xrefs(1): $AE3E
AE51  A9 00    LDA #$00                  
AE53  E5 90    SBC $90                   
AE55  85 90    STA $90                   
AE57  A9 00    LDA #$00                  
AE59  E5 91    SBC $91                   
AE5B  85 91    STA $91                   
AE5D  60       RTS                       

sub_AE5E:  ; xrefs(8): $84CB $86A6 $8B09 $8E94 $A115 $AA61 $ADD0 $AE2D
AE5E  B5 C0    LDA $C0,X                 
AE60  E5 82    SBC $82                   
AE62  85 92    STA $92                   
AE64  B5 D0    LDA $D0,X                 
AE66  E5 83    SBC $83                   
AE68  85 93    STA $93                   
AE6A  85 95    STA $95                   
AE6C  10 0C    BPL $AE7A                 
AE6E  A9 00    LDA #$00                  
AE70  E5 92    SBC $92                   
AE72  85 92    STA $92                   
AE74  A9 00    LDA #$00                  
AE76  E5 93    SBC $93                   
AE78  85 93    STA $93                   

loc_AE7A:  ; xrefs(1): $AE6C
AE7A  60       RTS                       

sub_AE7B:  ; xrefs(1): $81EA
AE7B  20 D7 AE JSR $AED7                 
AE7E  BD 90 06 LDA $0690,X               
AE81  D0 11    BNE $AE94                 
AE83  1D 40 06 ORA $0640,X               
AE86  D0 0C    BNE $AE94                 
AE88  B5 C0    LDA $C0,X                 
AE8A  9D 40 06 STA $0640,X               
AE8D  B5 D0    LDA $D0,X                 
AE8F  9D 90 06 STA $0690,X               
AE92  D0 0E    BNE $AEA2                 

loc_AE94:  ; xrefs(2): $AE81 $AE86
AE94  B5 C0    LDA $C0,X                 
AE96  DD 40 06 CMP $0640,X               
AE99  D0 14    BNE $AEAF                 
AE9B  B5 D0    LDA $D0,X                 
AE9D  FD 90 06 SBC $0690,X               
AEA0  D0 0D    BNE $AEAF                 

loc_AEA2:  ; xrefs(1): $AE92
AEA2  A9 F0    LDA #$F0                  
AEA4  9D 10 06 STA $0610,X               
AEA7  BD 20 06 LDA $0620,X               
AEAA  49 80    EOR #$80                  
AEAC  9D 20 06 STA $0620,X               

loc_AEAF:  ; xrefs(2): $AE99 $AEA0
AEAF  FE 10 06 INC $0610,X               
AEB2  BD 10 06 LDA $0610,X               
AEB5  85 52    STA $52                   
AEB7  10 02    BPL $AEBB                 
AEB9  C6 53    DEC $53                   

loc_AEBB:  ; xrefs(1): $AEB7
AEBB  BD 20 06 LDA $0620,X               
AEBE  10 03    BPL $AEC3                 
AEC0  20 8F 81 JSR $818F                 

loc_AEC3:  ; xrefs(1): $AEBE
AEC3  A9 EC    LDA #$EC                  
AEC5  85 50    STA $50                   
AEC7  C6 51    DEC $51                   
AEC9  BD 80 06 LDA $0680,X               
AECC  30 06    BMI $AED4                 
AECE  A9 14    LDA #$14                  
AED0  85 50    STA $50                   
AED2  E6 51    INC $51                   

loc_AED4:  ; xrefs(1): $AECC
AED4  4C 3F 81 JMP $813F                 

sub_AED7:  ; xrefs(1): $AE7B
AED7  A4 0C    LDY $0C                   

sub_AED9:  ; xrefs(1): $AC75
AED9  8A       TXA                       
AEDA  48       PHA                       
AEDB  A5 5C    LDA $5C                   
AEDD  85 90    STA $90                   
AEDF  A5 5D    LDA $5D                   
AEE1  C9 10    CMP #$10                  
AEE3  B0 2C    BCS $AF11                 
AEE5  85 91    STA $91                   
AEE7  A5 5E    LDA $5E                   
AEE9  85 92    STA $92                   
AEEB  A5 5F    LDA $5F                   
AEED  85 93    STA $93                   
AEEF  A9 B1    LDA #$B1                  
AEF1  85 9E    STA $9E                   
AEF3  18       CLC                       
AEF4  98       TYA                       
AEF5  29 02    AND #$02                  
AEF7  69 B3    ADC #$B3                  
AEF9  85 9F    STA $9F                   
AEFB  BD 80 06 LDA $0680,X               
AEFE  0A       ASL A                     
AEFF  A9 02    LDA #$02                  
AF01  B0 0A    BCS $AF0D                 
AF03  A4 9E    LDY $9E                   
AF05  A5 9F    LDA $9F                   
AF07  85 9E    STA $9E                   
AF09  84 9F    STY $9F                   
AF0B  A9 42    LDA #$42                  

loc_AF0D:  ; xrefs(1): $AF01
AF0D  A8       TAY                       
AF0E  20 1B C0 JSR $C01B                 

loc_AF11:  ; xrefs(1): $AEE3
AF11  68       PLA                       
AF12  AA       TAX                       
AF13  60       RTS                       

sub_AF14:  ; xrefs(2): $AF3F $AF85
AF14  A9 20    LDA #$20                  
AF16  85 50    STA $50                   
AF18  BD 80 06 LDA $0680,X               
AF1B  30 03    BMI $AF20                 
AF1D  20 81 81 JSR $8181                 

loc_AF20:  ; xrefs(1): $AF1B
AF20  4C 3F 81 JMP $813F                 

sub_AF23:  ; xrefs(1): $827B
AF23  A9 00    LDA #$00                  
AF25  F0 0A    BEQ $AF31                 

sub_AF27:  ; xrefs(1): $827B
AF27  A9 0A    LDA #$0A                  
AF29  D0 06    BNE $AF31                 

sub_AF2B:  ; xrefs(1): $827B
AF2B  A9 14    LDA #$14                  
AF2D  D0 02    BNE $AF31                 

sub_AF2F:  ; xrefs(1): $827B
AF2F  A9 32    LDA #$32                  

loc_AF31:  ; xrefs(4): $8F8A $AF25 $AF29 $AF2D
AF31  48       PHA                       
AF32  20 DA 80 JSR $80DA                 
AF35  F0 02    BEQ $AF39                 
AF37  B0 06    BCS $AF3F                 

loc_AF39:  ; xrefs(1): $AF35
AF39  20 18 81 JSR $8118                 
AF3C  20 24 AE JSR $AE24                 

loc_AF3F:  ; xrefs(1): $AF37
AF3F  20 14 AF JSR $AF14                 
AF42  68       PLA                       
AF43  85 4C    STA $4C                   
AF45  A9 04    LDA #$04                  
AF47  20 4B 90 JSR $904B                 
AF4A  BD C0 06 LDA $06C0,X               
AF4D  1D D0 06 ORA $06D0,X               
AF50  C9 01    CMP #$01                  
AF52  D0 04    BNE $AF58                 
AF54  A9 21    LDA #$21                  
AF56  85 F1    STA $F1                   

loc_AF58:  ; xrefs(1): $AF52
AF58  20 E0 80 JSR $80E0                 
AF5B  D0 05    BNE $AF62                 
AF5D  A5 4C    LDA $4C                   
AF5F  4C 89 A9 JMP $A989                 

loc_AF62:  ; xrefs(1): $AF5B
AF62  60       RTS                       

sub_AF63:  ; xrefs(1): $827B
AF63  A9 03    LDA #$03                  
AF65  A0 04    LDY #$04                  

loc_AF67:  ; xrefs(1): $8982
AF67  85 98    STA $98                   
AF69  84 99    STY $99                   
AF6B  20 DA 80 JSR $80DA                 
AF6E  F0 02    BEQ $AF72                 
AF70  B0 0E    BCS $AF80                 

loc_AF72:  ; xrefs(1): $AF6E
AF72  20 18 81 JSR $8118                 
AF75  20 24 AE JSR $AE24                 
AF78  A9 D0    LDA #$D0                  
AF7A  9D E0 06 STA $06E0,X               
AF7D  20 63 81 JSR $8163                 

loc_AF80:  ; xrefs(1): $AF70
AF80  A9 02    LDA #$02                  
AF82  20 BB B2 JSR $B2BB                 
AF85  20 14 AF JSR $AF14                 
AF88  BD 10 06 LDA $0610,X               
AF8B  F0 1D    BEQ $AFAA                 
AF8D  A9 04    LDA #$04                  
AF8F  20 4B 90 JSR $904B                 
AF92  BD C0 06 LDA $06C0,X               
AF95  1D D0 06 ORA $06D0,X               
AF98  C9 01    CMP #$01                  
AF9A  D0 04    BNE $AFA0                 
AF9C  A9 21    LDA #$21                  
AF9E  85 F1    STA $F1                   

loc_AFA0:  ; xrefs(1): $AF9A
AFA0  20 E0 80 JSR $80E0                 
AFA3  D0 14    BNE $AFB9                 
AFA5  A9 0A    LDA #$0A                  
AFA7  4C 89 A9 JMP $A989                 

loc_AFAA:  ; xrefs(1): $AF8B
AFAA  A5 98    LDA $98                   
AFAC  A4 99    LDY $99                   
AFAE  20 AB BD JSR $BDAB                 
AFB1  20 E0 80 JSR $80E0                 
AFB4  D0 03    BNE $AFB9                 
AFB6  FE 10 06 INC $0610,X               

loc_AFB9:  ; xrefs(2): $AFA3 $AFB4
AFB9  60       RTS                       

sub_AFBA:  ; xrefs(1): $81EA
AFBA  BD 20 06 LDA $0620,X               
AFBD  C9 FF    CMP #$FF                  
AFBF  D0 03    BNE $AFC4                 
AFC1  4C 3B B0 JMP $B03B                 

loc_AFC4:  ; xrefs(1): $AFBF
AFC4  20 AA B0 JSR $B0AA                 
AFC7  30 0D    BMI $AFD6                 
AFC9  A9 08    LDA #$08                  
AFCB  9D 90 06 STA $0690,X               
AFCE  A9 FF    LDA #$FF                  
AFD0  20 63 81 JSR $8163                 
AFD3  4C 3F 81 JMP $813F                 

loc_AFD6:  ; xrefs(1): $AFC7
AFD6  38       SEC                       
AFD7  A5 52    LDA $52                   
AFD9  E5 9D    SBC $9D                   
AFDB  85 52    STA $52                   
AFDD  B0 02    BCS $AFE1                 
AFDF  C6 53    DEC $53                   

loc_AFE1:  ; xrefs(1): $AFDD
AFE1  BD 90 06 LDA $0690,X               
AFE4  C9 02    CMP #$02                  
AFE6  90 17    BCC $AFFF                 
AFE8  A9 02    LDA #$02                  
AFEA  20 D9 99 JSR $99D9                 
AFED  F0 0A    BEQ $AFF9                 
AFEF  C9 08    CMP #$08                  
AFF1  D0 09    BNE $AFFC                 
AFF3  20 18 81 JSR $8118                 
AFF6  20 24 AE JSR $AE24                 

loc_AFF9:  ; xrefs(1): $AFED
AFF9  20 B3 80 JSR $80B3                 

loc_AFFC:  ; xrefs(1): $AFF1
AFFC  4C 3F 81 JMP $813F                 

loc_AFFF:  ; xrefs(1): $AFE6
AFFF  A9 00    LDA #$00                  
B001  20 4B 90 JSR $904B                 
B004  A9 10    LDA #$10                  
B006  85 50    STA $50                   
B008  20 8F B0 JSR $B08F                 
B00B  10 1F    BPL $B02C                 
B00D  20 2C 81 JSR $812C                 
B010  A9 80    LDA #$80                  
B012  85 92    STA $92                   
B014  A9 FF    LDA #$FF                  
B016  85 93    STA $93                   
B018  A9 18    LDA #$18                  
B01A  85 50    STA $50                   
B01C  20 97 B0 JSR $B097                 
B01F  30 08    BMI $B029                 
B021  20 2C 81 JSR $812C                 
B024  BD 90 06 LDA $0690,X               
B027  F0 09    BEQ $B032                 

loc_B029:  ; xrefs(1): $B01F
B029  20 24 AE JSR $AE24                 

loc_B02C:  ; xrefs(1): $B00B
B02C  20 B3 80 JSR $80B3                 
B02F  4C 3F 81 JMP $813F                 

loc_B032:  ; xrefs(1): $B027
B032  FE 90 06 INC $0690,X               
B035  20 61 81 JSR $8161                 
B038  4C 3F 81 JMP $813F                 

loc_B03B:  ; xrefs(1): $AFC1
B03B  A9 01    LDA #$01                  
B03D  20 4B 90 JSR $904B                 
B040  A9 02    LDA #$02                  
B042  20 BB B2 JSR $B2BB                 
B045  BD 40 06 LDA $0640,X               
B048  10 2C    BPL $B076                 
B04A  A9 00    LDA #$00                  
B04C  85 92    STA $92                   
B04E  A9 01    LDA #$01                  
B050  85 93    STA $93                   
B052  20 51 B1 JSR $B151                 
B055  10 03    BPL $B05A                 
B057  20 5A 81 JSR $815A                 

loc_B05A:  ; xrefs(2): $B055 $B079
B05A  BD 90 06 LDA $0690,X               
B05D  C9 02    CMP #$02                  
B05F  B0 2B    BCS $B08C                 
B061  A9 10    LDA #$10                  
B063  85 50    STA $50                   
B065  20 8F B0 JSR $B08F                 
B068  10 06    BPL $B070                 
B06A  20 2C 81 JSR $812C                 
B06D  4C 8C B0 JMP $B08C                 

loc_B070:  ; xrefs(1): $B068
B070  20 B3 80 JSR $80B3                 
B073  4C 8C B0 JMP $B08C                 

loc_B076:  ; xrefs(1): $B048
B076  20 AA B0 JSR $B0AA                 
B079  10 DF    BPL $B05A                 
B07B  38       SEC                       
B07C  A5 52    LDA $52                   
B07E  E5 9D    SBC $9D                   
B080  85 52    STA $52                   
B082  B0 02    BCS $B086                 
B084  C6 53    DEC $53                   

loc_B086:  ; xrefs(1): $B082
B086  20 5A 81 JSR $815A                 
B089  4C 3F 81 JMP $813F                 

loc_B08C:  ; xrefs(3): $B05F $B06D $B073
B08C  4C 3F 81 JMP $813F                 

sub_B08F:  ; xrefs(3): $AE11 $B008 $B065
B08F  A9 40    LDA #$40                  
B091  85 92    STA $92                   
B093  A9 00    LDA #$00                  
B095  85 93    STA $93                   

sub_B097:  ; xrefs(1): $B01C
B097  A9 80    LDA #$80                  
B099  85 90    STA $90                   
B09B  A9 00    LDA #$00                  
B09D  85 91    STA $91                   
B09F  BD 80 06 LDA $0680,X               
B0A2  10 03    BPL $B0A7                 
B0A4  20 81 81 JSR $8181                 

loc_B0A7:  ; xrefs(1): $B0A2
B0A7  4C 70 B1 JMP $B170                 

sub_B0AA:  ; xrefs(6): $8516 $8CB5 $8FAB $8FE7 $AFC4 $B076
B0AA  A9 80    LDA #$80                  
B0AC  85 90    STA $90                   
B0AE  A9 00    LDA #$00                  
B0B0  85 91    STA $91                   
B0B2  85 92    STA $92                   
B0B4  A9 01    LDA #$01                  
B0B6  85 93    STA $93                   
B0B8  4C 3F B1 JMP $B13F                 

sub_B0BB:  ; xrefs(1): $81EA
B0BB  BD E0 06 LDA $06E0,X               
B0BE  C9 09    CMP #$09                  
B0C0  D0 0A    BNE $B0CC                 
B0C2  AD F7 05 LDA $05F7                 
B0C5  D0 05    BNE $B0CC                 
B0C7  A9 04    LDA #$04                  
B0C9  8D F7 05 STA $05F7                 

sub_B0CC:  ; xrefs(3): $81EA $B0C0 $B0C5
B0CC  60       RTS                       

sub_B0CD:  ; xrefs(2): $81EA $827B
B0CD  A0 03    LDY #$03                  
B0CF  A9 0A    LDA #$0A                  
B0D1  20 DB 99 JSR $99DB                 
B0D4  F0 01    BEQ $B0D7                 
B0D6  60       RTS                       

loc_B0D7:  ; xrefs(2): $B0D4 $B0E9
B0D7  A9 05    LDA #$05                  
B0D9  4C 89 A9 JMP $A989                 

sub_B0DC:  ; xrefs(2): $81EA $827B
B0DC  8A       TXA                       
B0DD  45 0C    EOR $0C                   
B0DF  6A       ROR A                     
B0E0  90 09    BCC $B0EB                 
B0E2  A9 07    LDA #$07                  
B0E4  A0 03    LDY #$03                  
B0E6  20 DB 99 JSR $99DB                 
B0E9  F0 EC    BEQ $B0D7                 

loc_B0EB:  ; xrefs(1): $B0E0
B0EB  60       RTS                       

sub_B0EC:  ; xrefs(1): $81EA
B0EC  DE 90 06 DEC $0690,X               
B0EF  D0 1D    BNE $B10E                 
B0F1  BD 10 06 LDA $0610,X               
B0F4  C9 02    CMP #$02                  
B0F6  A9 05    LDA #$05                  
B0F8  90 02    BCC $B0FC                 
B0FA  A9 13    LDA #$13                  

loc_B0FC:  ; xrefs(1): $B0F8
B0FC  6D C6 05 ADC $05C6                 
B0FF  8D C6 05 STA $05C6                 
B102  90 03    BCC $B107                 
B104  EE C7 05 INC $05C7                 

loc_B107:  ; xrefs(1): $B102
B107  A9 0F    LDA #$0F                  
B109  85 F1    STA $F1                   
B10B  20 BF 80 JSR $80BF                 

loc_B10E:  ; xrefs(1): $B0EF
B10E  A9 03    LDA #$03                  
B110  20 BB B2 JSR $B2BB                 
B113  20 3A 81 JSR $813A                 
B116  BD 10 06 LDA $0610,X               
B119  4C 85 89 JMP $8985                 

; ---- data $B11C-$B11C (1 bytes) ----
B11C  60                                               |`

sub_B11D:  ; xrefs(1): $81EA
B11D  BD 90 06 LDA $0690,X               
B120  D0 06    BNE $B128                 
B122  FE 90 06 INC $0690,X               
B125  4C 6F 81 JMP $816F                 

loc_B128:  ; xrefs(1): $B120
B128  20 34 B1 JSR $B134                 
B12B  A9 01    LDA #$01                  
B12D  20 85 89 JSR $8985                 
B130  4C 39 B2 JMP $B239                 

; ---- data $B133-$B133 (1 bytes) ----
B133  60                                               |`

sub_B134:  ; xrefs(2): $B128 $B231
B134  20 B5 B1 JSR $B1B5                 
B137  A9 02    LDA #$02                  
B139  20 BB B2 JSR $B2BB                 
B13C  4C 3A 81 JMP $813A                 

sub_B13F:  ; xrefs(2): $B0B8 $B1C1
B13F  8A       TXA                       
B140  48       PHA                       
B141  BD 80 06 LDA $0680,X               
B144  49 FF    EOR #$FF                  
B146  20 89 B1 JSR $B189                 
B149  20 0C C0 JSR $C00C                 
B14C  A8       TAY                       
B14D  68       PLA                       
B14E  AA       TAX                       
B14F  98       TYA                       
B150  60       RTS                       

sub_B151:  ; xrefs(5): $8D8D $A9C3 $AD9F $B052 $B20D
B151  8A       TXA                       
B152  48       PHA                       
B153  B5 A0    LDA $A0,X                 
B155  85 90    STA $90                   
B157  B5 B0    LDA $B0,X                 
B159  85 91    STA $91                   
B15B  38       SEC                       
B15C  B5 C0    LDA $C0,X                 
B15E  E5 92    SBC $92                   
B160  85 92    STA $92                   
B162  B5 D0    LDA $D0,X                 
B164  E5 93    SBC $93                   
B166  85 93    STA $93                   
B168  20 0C C0 JSR $C00C                 
B16B  A8       TAY                       
B16C  68       PLA                       
B16D  AA       TAX                       
B16E  98       TYA                       
B16F  60       RTS                       

sub_B170:  ; xrefs(2): $9011 $B0A7
B170  8A       TXA                       
B171  45 0C    EOR $0C                   
B173  6A       ROR A                     
B174  B0 03    BCS $B179                 
B176  A9 00    LDA #$00                  
B178  60       RTS                       

sub_B179:  ; xrefs(2): $A6ED $B174
B179  8A       TXA                       
B17A  48       PHA                       
B17B  20 86 B1 JSR $B186                 
B17E  20 0F C0 JSR $C00F                 
B181  A8       TAY                       
B182  68       PLA                       
B183  AA       TAX                       
B184  98       TYA                       
B185  60       RTS                       

sub_B186:  ; xrefs(2): $ADF0 $B17B
B186  BD 80 06 LDA $0680,X               

sub_B189:  ; xrefs(3): $8DA1 $9D29 $B146
B189  10 10    BPL $B19B                 
B18B  38       SEC                       
B18C  B5 A0    LDA $A0,X                 
B18E  E5 90    SBC $90                   
B190  85 90    STA $90                   
B192  B5 B0    LDA $B0,X                 
B194  E5 91    SBC $91                   
B196  85 91    STA $91                   
B198  4C A7 B1 JMP $B1A7                 

loc_B19B:  ; xrefs(1): $B189
B19B  B5 A0    LDA $A0,X                 
B19D  65 90    ADC $90                   
B19F  85 90    STA $90                   
B1A1  B5 B0    LDA $B0,X                 
B1A3  65 91    ADC $91                   
B1A5  85 91    STA $91                   

loc_B1A7:  ; xrefs(1): $B198
B1A7  18       CLC                       
B1A8  B5 C0    LDA $C0,X                 
B1AA  65 92    ADC $92                   
B1AC  85 92    STA $92                   
B1AE  B5 D0    LDA $D0,X                 
B1B0  65 93    ADC $93                   
B1B2  85 93    STA $93                   
B1B4  60       RTS                       

sub_B1B5:  ; xrefs(1): $B134
B1B5  BD 40 06 LDA $0640,X               
B1B8  30 4C    BMI $B206                 
B1BA  20 21 81 JSR $8121                 
B1BD  A9 80    LDA #$80                  
B1BF  85 92    STA $92                   
B1C1  20 3F B1 JSR $B13F                 
B1C4  10 55    BPL $B21B                 
B1C6  A9 80    LDA #$80                  
B1C8  95 C0    STA $C0,X                 
B1CA  9D 20 06 STA $0620,X               
B1CD  5E 40 06 LSR $0640,X               
B1D0  7E 30 06 ROR $0630,X               
B1D3  BD 40 06 LDA $0640,X               
B1D6  85 91    STA $91                   
B1D8  BD 30 06 LDA $0630,X               
B1DB  85 90    STA $90                   
B1DD  46 91    LSR $91                   
B1DF  66 90    ROR $90                   
B1E1  18       CLC                       
B1E2  A5 90    LDA $90                   
B1E4  7D 30 06 ADC $0630,X               
B1E7  9D 30 06 STA $0630,X               
B1EA  A5 91    LDA $91                   
B1EC  7D 40 06 ADC $0640,X               
B1EF  9D 40 06 STA $0640,X               
B1F2  38       SEC                       
B1F3  A9 00    LDA #$00                  
B1F5  FD 30 06 SBC $0630,X               
B1F8  9D 30 06 STA $0630,X               
B1FB  A9 00    LDA #$00                  
B1FD  FD 40 06 SBC $0640,X               
B200  9D 40 06 STA $0640,X               
B203  4C 1B B2 JMP $B21B                 

loc_B206:  ; xrefs(1): $B1B8
B206  20 21 81 JSR $8121                 
B209  A9 80    LDA #$80                  
B20B  85 92    STA $92                   
B20D  20 51 B1 JSR $B151                 
B210  10 09    BPL $B21B                 
B212  A9 80    LDA #$80                  
B214  95 C0    STA $C0,X                 
B216  9D 20 06 STA $0620,X               
B219  D0 01    BNE $B21C                 

loc_B21B:  ; xrefs(3): $B1C4 $B203 $B210
B21B  60       RTS                       

sub_B21C:  ; xrefs(3): $815A $8AB6 $B219
B21C  A9 00    LDA #$00                  
B21E  9D 30 06 STA $0630,X               
B221  9D 40 06 STA $0640,X               
B224  60       RTS                       

sub_B225:  ; xrefs(1): $81EA
B225  BD 90 06 LDA $0690,X               
B228  D0 07    BNE $B231                 
B22A  FE 90 06 INC $0690,X               
B22D  4C 6F 81 JMP $816F                 

; ---- data $B230-$B230 (1 bytes) ----
B230  60                                               |`

loc_B231:  ; xrefs(1): $B228
B231  20 34 B1 JSR $B134                 
B234  A9 02    LDA #$02                  
B236  20 85 89 JSR $8985                 

loc_B239:  ; xrefs(2): $B130 $B267
B239  DE 10 06 DEC $0610,X               
B23C  F0 08    BEQ $B246                 
B23E  BD 10 06 LDA $0610,X               
B241  C9 40    CMP #$40                  
B243  90 04    BCC $B249                 
B245  60       RTS                       

loc_B246:  ; xrefs(1): $B23C
B246  20 B9 80 JSR $80B9                 

loc_B249:  ; xrefs(1): $B243
B249  A5 0C    LDA $0C                   
B24B  29 02    AND #$02                  
B24D  D0 05    BNE $B254                 
B24F  A9 0F    LDA #$0F                  
B251  9D E0 06 STA $06E0,X               

loc_B254:  ; xrefs(1): $B24D
B254  60       RTS                       

sub_B255:  ; xrefs(2): $81EA $827B
B255  BD 90 06 LDA $0690,X               
B258  D0 08    BNE $B262                 
B25A  FE 90 06 INC $0690,X               
B25D  A9 80    LDA #$80                  
B25F  9D 10 06 STA $0610,X               

loc_B262:  ; xrefs(1): $B258
B262  A9 03    LDA #$03                  
B264  20 85 89 JSR $8985                 
B267  4C 39 B2 JMP $B239                 

; ---- data $B26A-$B26A (1 bytes) ----
B26A  60                                               |`

sub_B26B:  ; xrefs(2): $81EA $827B
B26B  BD 90 06 LDA $0690,X               
B26E  D0 09    BNE $B279                 
B270  FE 90 06 INC $0690,X               
B273  A9 E0    LDA #$E0                  
B275  9D 10 06 STA $0610,X               
B278  60       RTS                       

loc_B279:  ; xrefs(1): $B26E
B279  C9 01    CMP #$01                  
B27B  F0 1F    BEQ $B29C                 
B27D  A9 08    LDA #$08                  
B27F  20 85 89 JSR $8985                 
B282  20 E6 80 JSR $80E6                 
B285  D0 0B    BNE $B292                 
B287  BD C0 06 LDA $06C0,X               
B28A  C9 01    CMP #$01                  
B28C  D0 04    BNE $B292                 
B28E  A9 21    LDA #$21                  
B290  85 F1    STA $F1                   

loc_B292:  ; xrefs(2): $B285 $B28C
B292  20 E0 80 JSR $80E0                 
B295  D0 12    BNE $B2A9                 
B297  A9 00    LDA #$00                  
B299  4C 89 A9 JMP $A989                 

loc_B29C:  ; xrefs(1): $B27B
B29C  FE 10 06 INC $0610,X               
B29F  D0 03    BNE $B2A4                 
B2A1  FE 90 06 INC $0690,X               

loc_B2A4:  ; xrefs(1): $B29F
B2A4  A9 04    LDA #$04                  
B2A6  4C 85 89 JMP $8985                 

loc_B2A9:  ; xrefs(1): $B295
B2A9  60       RTS                       

sub_B2AA:  ; xrefs(1): $81EA
B2AA  A9 44    LDA #$44                  
B2AC  D0 02    BNE $B2B0                 

sub_B2AE:  ; xrefs(1): $81EA
B2AE  A9 46    LDA #$46                  

loc_B2B0:  ; xrefs(1): $B2AC
B2B0  9D 60 06 STA $0660,X               
B2B3  A9 00    LDA #$00                  
B2B5  9D 70 06 STA $0670,X               
B2B8  60       RTS                       

; ---- data $B2B9-$B2BA (2 bytes) ----
B2B9  A9 04                                            |..

sub_B2BB:  ; xrefs(5): $9150 $AF82 $B042 $B110 $B139
B2BB  18       CLC                       
B2BC  7D 30 06 ADC $0630,X               
B2BF  A8       TAY                       
B2C0  BD 40 06 LDA $0640,X               
B2C3  69 00    ADC #$00                  
B2C5  9D 40 06 STA $0640,X               
B2C8  30 0B    BMI $B2D5                 
B2CA  A9 00    LDA #$00                  
B2CC  9D 40 06 STA $0640,X               
B2CF  C0 80    CPY #$80                  
B2D1  90 02    BCC $B2D5                 
B2D3  A0 80    LDY #$80                  

loc_B2D5:  ; xrefs(2): $B2C8 $B2D1
B2D5  98       TYA                       
B2D6  9D 30 06 STA $0630,X               
B2D9  18       CLC                       
B2DA  BD 30 06 LDA $0630,X               
B2DD  65 52    ADC $52                   
B2DF  85 52    STA $52                   
B2E1  BD 40 06 LDA $0640,X               
B2E4  65 53    ADC $53                   
B2E6  85 53    STA $53                   
B2E8  60       RTS                       

loc_B2E9:  ; xrefs(0): 
B2E9  AD C3 05 LDA $05C3                 
B2EC  F0 04    BEQ $B2F2                 
B2EE  C9 30    CMP #$30                  
B2F0  90 11    BCC $B303                 

loc_B2F2:  ; xrefs(1): $B2EC
B2F2  A2 0F    LDX #$0F                  

loc_B2F4:  ; xrefs(1): $B301
B2F4  8A       TXA                       
B2F5  48       PHA                       
B2F6  BD 80 07 LDA $0780,X               
B2F9  F0 03    BEQ $B2FE                 
B2FB  20 04 B3 JSR $B304                 

loc_B2FE:  ; xrefs(1): $B2F9
B2FE  68       PLA                       
B2FF  AA       TAX                       
B300  CA       DEX                       
B301  10 F1    BPL $B2F4                 

loc_B303:  ; xrefs(1): $B2F0
B303  60       RTS                       

sub_B304:  ; xrefs(1): $B2FB
B304  10 71    BPL $B377                 
B306  29 7F    AND #$7F                  
B308  0A       ASL A                     
B309  A8       TAY                       
B30A  B9 17 B3 LDA $B317,Y               
B30D  85 90    STA $90                   
B30F  B9 18 B3 LDA $B318,Y               
B312  85 91    STA $91                   
B314  6C 90 00 JMP ($0090)               

; ---- data $B317-$B376 (96 bytes) ----
B317  17 BC 17 BC 2C BC A1 B8 9E BB 5B BB 5C BA 22 BA  |....,.....[.\.".
B327  53 B9 53 B9 F5 B8 18 B9 96 B8 F2 B7 59 B8 64 B8  |S.S.........Y.d.
B337  6F B8 7A B8 88 B7 93 B7 9E B7 A9 B7 B4 B7 BD B7  |o.z.............
B347  C8 B7 D3 B7 DE B7 E9 B7 38 B6 60 B7 C3 B5 18 B6  |........8.`.....
B357  40 B7 21 B7 0F B7 5B B6 CB B6 F0 B6 47 BC 64 B5  |@.!...[.....G.d.
B367  06 B5 CC B4 BC B4 AF B4 0E BD A2 B4 51 B4 E6 B3  |............Q...

loc_B377:  ; xrefs(1): $B304
B377  0A       ASL A                     
B378  A8       TAY                       
B379  B9 86 B3 LDA $B386,Y               
B37C  85 90    STA $90                   
B37E  B9 87 B3 LDA $B387,Y               
B381  85 91    STA $91                   
B383  6C 90 00 JMP ($0090)               

; ---- data $B386-$BD7F (2554 bytes) ----
B386  4F BD 4F BD 4F BD A1 B8 7B BB 4F BD 4F BD 4F BD  |O.O.O...{.O.O.O.
B396  4F BD 53 B9 F5 B8 4F BD 4F BD F2 B7 59 B8 64 B8  |O.S...O.O...Y.d.
B3A6  6F B8 7A B8 88 B7 93 B7 9E B7 A9 B7 B4 B7 BD B7  |o.z.............
B3B6  C8 B7 D3 B7 DE B7 E9 B7 4F BD 52 B7 C3 B5 18 B6  |........O.R.....
B3C6  52 B7 4F BD 4F BD 52 B7 4F BD 4F BD 4F BD 4F BD  |R.O.O.R.O.O.O.O.
B3D6  4F BD 4F BD 4F BD 4F BD 4F BD 4F BD 4F BD 52 B7  |O.O.O.O.O.O.O.R.
B3E6  8A 45 0C 6A 90 08 20 E5 B8 10 03 4C 52 B7 20 21  |.E.j.. ....LR. !
B3F6  81 A9 08 85 90 A9 10 85 92 BC D0 07 F0 09 DE D0  |................
B406  07 A9 04 85 90 85 92 BD D0 07 F0 0D BD 90 07 C5  |................
B416  80 BD A0 07 E5 81 9D E0 07 BC E0 07 30 09 38 A9  |............0.8.
B426  00 E5 90 85 90 C6 91 A5 55 C9 02 D0 06 A9 00 85  |........U.......
B436  90 85 91 20 7A BC 20 DF BC A5 0C 29 02 18 69 F7  |... z. ....)..i.
B446  85 9E 85 9F A9 03 A0 43 4C 1B C0 20 21 81 20 C3  |.......CL.. !. .
B456  BC A5 34 F0 06 A9 F8 85 92 C6 93 20 7A BC 20 F7  |..4........ z. .
B466  BC A0 00 BD D0 07 30 02 A0 08 84 94 A5 0C 29 04  |......0.......).
B476  18 65 94 A8 B9 92 B4 85 9E B9 93 B4 85 9F B9 94  |.e..............
B486  B4 85 9D B9 95 B4 A8 A5 9D 4C 1B C0 ED FF 01 02  |.........L......
B496  ED EF 01 02 FF ED 42 41 EF ED 42 41 20 C3 BC 20  |......BA..BA .. 
B4A6  8F BC 20 F7 BC A0 FF D0 08 20 77 BC 20 F7 BC A0  |.. ...... w. ...
B4B6  DF A9 02 4C 30 C0 20 77 BC 20 F7 BC A5 0C 29 06  |...L0. w. ....).
B4C6  18 69 E7 4C 93 BB 20 C3 BC 20 8F BC 20 F7 BC A0  |.i.L.. .. .. ...
B4D6  00 BD D0 07 30 02 A0 04 84 94 A5 0C 29 02 18 65  |....0.......)..e
B4E6  94 A8 B9 FE B4 85 9E B9 FF B4 85 9F A0 03 A5 94  |................
B4F6  F0 02 A0 43 98 4C 1B C0 E1 E5 E1 E3 E5 E1 E3 E1  |...C.L..........
B506  BD D0 07 F0 23 DE D0 07 D0 07 A9 08 9D E0 07 D0  |....#...........
B516  17 BD E0 07 20 D1 BC A5 93 85 91 A5 92 85 90 20  |.... .......... 
B526  8F BC 20 F7 BC 4C 57 B5 38 BD E0 07 10 08 E9 02  |.. ..LW.8.......
B536  C9 80 B0 04 A9 83 E9 02 9D E0 07 20 D1 BC 20 7D  |........... .. }
B546  BC 20 F7 BC BD 80 07 D0 01 60 A5 0C 6A A9 D1 B0  |. .......`..j...
B556  02 A9 CF 85 9E 85 9F A9 01 A0 41 4C 1B C0 20 F7  |..........AL.. .
B566  BC BD 80 07 D0 01 60 A0 EB BD E0 07 F0 0E DE E0  |......`.........
B576  07 A0 ED 20 9E B5 20 21 81 4C 8D B5 20 9E B5 A9  |... .. !.L.. ...
B586  00 85 93 A9 80 85 92 BD D0 07 A8 B9 10 06 85 90  |................
B596  B9 20 06 85 91 4C 7A BC 8A 48 20 33 B7 68 AA 60  |. ...Lz..H 3.h.`
B5A6  18 BD E0 07 30 08 69 04 10 06 A9 7F D0 02 69 04  |....0.i.......i.
B5B6  9D E0 07 20 77 BC 20 DF BC BD 80 07 60 20 F7 BC  |... w. .....` ..
B5C6  8A 48 A9 D3 85 9E A9 D5 85 9F A9 01 A8 20 1B C0  |.H........... ..
B5D6  68 AA 20 E5 B8 10 05 A0 24 4C 0D B6 A9 60 85 92  |h. .....$L...`..
B5E6  A9 00 85 93 20 7D BC BD A0 07 85 BD BD C0 07 85  |.... }..........
B5F6  DD A9 00 8D 1D 06 8A 48 A2 0D 20 06 B6 68 AA 60  |.......H.. ..h.`
B606  A9 01 20 3C A9 43 BF A9 00 9D 80 07 20 3E B9 4C  |.. <.C...... >.L
B616  C2 AA 20 F7 BC 8A 48 A9 FB 85 9E A9 FD 85 9F A9  |.. ...H.........
B626  02 A8 20 1B C0 68 AA A9 00 85 92 A9 01 85 93 4C  |.. ..h.........L
B636  7D BC 20 F7 BC 8A 48 A9 02 A0 FD 20 30 C0 68 AA  |}. ...H.... 0.h.
B646  20 E5 B8 10 06 A9 00 9D 80 07 60 20 21 81 A9 80  | .........` !...
B656  85 92 4C 7D BC 20 F7 BC 8A 48 A0 E7 20 33 B7 68  |..L}. ...H.. 3.h
B666  AA BD E0 07 10 0C 20 21 81 A9 A0 85 92 C6 93 4C  |...... !.......L
B676  7F B6 20 21 81 A9 60 85 92 20 E8 B8 10 0B 20 B1  |.. !..`.. .... .
B686  B6 B0 03 4C 52 B7 4C A6 B5 20 21 81 BD D0 07 10  |...LR.L.. !.....
B696  09 A9 C0 85 90 C6 91 4C A4 B6 A9 40 85 90 20 E8  |.......L...@.. .
B6A6  B8 10 05 A9 00 9D D0 07 4C A6 B5 BD E0 07 0A 7E  |........L......~
B6B6  E0 07 38 A9 00 FD E0 07 9D E0 07 10 05 18 49 FF  |..8...........I.
B6C6  69 01 C9 04 60 20 F7 BC BD E0 07 D0 34 8A 48 A0  |i...` ......4.H.
B6D6  DF 20 33 B7 68 AA 20 C3 BC A5 90 85 92 A5 91 85  |. 3.h. .........
B6E6  93 A9 00 85 90 85 91 4C 7D BC 20 F7 BC BD E0 07  |.......L}. .....
B6F6  D0 0F 8A 48 A0 DF 20 33 B7 68 AA 20 C3 BC 4C 8F  |...H.. 3.h. ..L.
B706  BC DE E0 07 A9 E1 4C 88 BB 20 F7 BC 8A 48 A0 E9  |......L.. ...H..
B716  20 33 B7 68 AA 20 C3 BC 4C 8F BC 20 F7 BC 8A 48  | 3.h. ..L.. ...H
B726  20 31 B7 68 AA 20 C3 BC 4C 8F BC A0 BF BD D0 07  | 1.h. ..L.......
B736  0A A9 42 90 02 A9 02 4C 30 C0 20 E5 B8 30 0D 20  |..B....L0. ..0. 
B746  A6 B5 D0 01 60 A9 01 A0 FD 4C 30 C0 20 3E B9 A0  |....`....L0. >..
B756  BD 20 C2 AA A9 00 9D 80 07 60 20 E5 B8 30 ED 20  |. .......` ..0. 
B766  21 81 A9 10 85 92 20 7D BC 20 F7 BC A9 FF 85 9E  |!..... }. ......
B776  85 9F A5 0C 29 02 F0 03 4C 8C BB A9 03 A0 C3 4C  |....)...L......L
B786  1B C0 20 FD B7 D0 01 60 A9 BB 4C 42 B8 DE E0 07  |.. ....`..LB....
B796  D0 05 A9 95 9D 80 07 60 DE E0 07 D0 05 A9 96 9D  |.......`........
B7A6  80 07 60 20 FD B7 D0 01 60 A9 BD 4C 42 B8 20 FD  |..` ....`..LB. .
B7B6  B7 D0 01 60 4C 80 B8 20 0E B8 D0 01 60 A9 BB 4C  |...`L.. ....`..L
B7C6  42 B8 DE E0 07 D0 05 A9 9A 9D 80 07 60 DE E0 07  |B...........`...
B7D6  D0 05 A9 9B 9D 80 07 60 20 0E B8 D0 01 60 A9 BD  |.......` ....`..
B7E6  4C 42 B8 20 0E B8 D0 01 60 4C 80 B8 20 1F B8 D0  |LB. ....`L.. ...
B7F6  01 60 A9 BB 4C 42 B8 20 32 B8 38 A5 92 E9 18 85  |.`..LB. 2.8.....
B806  92 B0 02 C6 93 4C 22 B8 20 32 B8 18 A5 92 69 18  |.....L". 2....i.
B816  85 92 90 02 E6 93 4C 22 B8 20 32 B8 20 C3 BC 20  |......L". 2. .. 
B826  7A BC 20 55 BD 20 69 BD BD 80 07 60 A9 00 85 90  |z. U. i....`....
B836  18 BD E0 07 69 02 9D E0 07 4C 78 C0 85 9E 85 9F  |....i....Lx.....
B846  A5 91 C9 0F B0 0C A5 0C 29 02 F0 03 4C 8C BB 4C  |........)...L..L
B856  97 BB 60 DE E0 07 D0 05 A9 90 9D 80 07 60 DE E0  |..`..........`..
B866  07 D0 05 A9 91 9D 80 07 60 20 1F B8 D0 01 60 A9  |........` ....`.
B876  BD 4C 42 B8 20 1F B8 D0 01 60 A5 91 C9 0F B0 0F  |.LB. ....`......
B886  A5 0C 6A 6A A9 02 B0 02 A9 01 A0 BF 4C 30 C0 60  |..jj........L0.`
B896  20 A6 B5 D0 01 60 A9 FF 4C 93 BB 8A 45 0C 29 03  | ....`..L...E.).
B8A6  D0 17 20 E5 B8 30 0C 29 78 C9 60 90 06 29 18 C9  |.. ..0.)x.`..)..
B8B6  08 F0 06 A9 00 9D 80 07 60 A9 00 85 90 18 BD D0  |........`.......
B8C6  07 69 04 9D D0 07 20 78 C0 BD E0 07 85 92 A9 FF  |.i.... x........
B8D6  85 93 20 7A BC 20 F7 BC A9 01 A0 BF 4C 30 C0 20  |.. z. ......L0. 
B8E6  21 81 20 A1 BC 8A 48 20 0C C0 A8 68 AA 98 60 20  |!. ...H ...h..` 
B8F6  F7 BC DE E0 07 D0 03 4C 4F BD A5 0C 29 04 D0 08  |.......LO...)...
B906  A9 FB 85 9E 85 9F D0 06 A9 F9 85 9E 85 9F 4C 97  |..............L.
B916  BB 60 20 77 BC 20 F7 BC BD D0 07 30 0C A9 FF 85  |.` w. .....0....
B926  9E A9 FD 85 9F A9 41 D0 0A A9 FD 85 9E A9 FF 85  |......A.........
B936  9F A9 01 A8 4C 1B C0 60 BD 90 07 85 90 BD A0 07  |....L..`........
B946  85 91 BD B0 07 85 92 BD C0 07 85 93 60 20 21 81  |............` !.
B956  20 E8 B8 10 6E A5 26 F0 04 C9 06 D0 4A AD 99 03  | ...n.&.....J...
B966  C9 05 F0 0A A5 0E 29 03 D0 04 A0 08 D0 1A BD E0  |......).........
B976  07 4D CB 05 10 31 29 80 4D CB 05 20 0A BA 8D CB  |.M...1).M.. ....
B986  05 2A 2A 2A 2A 29 04 A8 B9 EA B9 8D 99 03 B9 EB  |.****)..........
B996  B9 8D 9A 03 B9 EC B9 8D 9B 03 A5 27 09 04 85 27  |...........'...'
B9A6  A9 14 85 F1 20 F5 B9 BD 90 07 85 90 BD A0 07 85  |.... ...........
B9B6  91 BD B0 07 85 92 BD C0 07 85 93 A0 87 20 C2 AA  |............. ..
B9C6  4C 4F BD 20 D1 BC 20 7D BC 20 F7 BC A9 BD 85 9E  |LO. .. }. ......
B9D6  85 9F BD E0 07 0A A9 03 A0 43 B0 04 A9 83 A0 C3  |.........C......
B9E6  4C 1B C0 0F 0A 09 27 0F 02 12 27 0F 05 16 27 A9  |L.....'...'...'.
B9F6  00 8D CD 05 A9 B8 8D E8 05 A9 04 8D E9 05 A9 06  |................
BA06  8D EA 05 60 48 4D CB 05 10 10 A9 00 ED AD 05 8D  |...`HM..........
BA16  AD 05 A9 00 ED AE 05 8D AE 05 68 60 AD 90 06 C9  |..........h`....
BA26  04 D0 26 AD D0 06 C9 03 B0 1F 20 F7 BC AD D0 06  |..&....... .....
BA36  C9 01 D0 04 A9 03 D0 0B A5 0C 6A 85 94 18 8A 65  |..........j....e
BA46  94 29 03 A0 B1 4C 30 C0 60 20 77 BC 20 F7 BC A9  |.)...L0.` w. ...
BA56  03 A0 B1 4C 30 C0 A5 0C 29 07 D0 04 A9 27 85 F1  |...L0...)....'..
BA66  DE E0 07 D0 03 4C 4F BD 20 F8 BA BD D0 07 F0 1B  |.....LO. .......
BA76  C9 02 90 2C F0 3F 20 3A BB 10 0D 20 10 BB 10 08  |...,.? :... ....
BA86  20 FB BA 10 03 20 25 BB 4C CD BA 20 FB BA 10 0D  | .... %.L.. ....
BA96  20 3A BB 10 08 20 25 BB 10 03 20 10 BB 4C CD BA  | :... %... ..L..
BAA6  20 10 BB 10 0D 20 25 BB 10 08 20 3A BB 10 03 20  | .... %... :... 
BAB6  FB BA 4C CD BA 20 25 BB 10 0D 20 FB BA 10 08 20  |..L.. %... .... 
BAC6  10 BB 10 03 20 10 BB BD D0 07 A8 B9 4F BB 85 90  |.... .......O...
BAD6  B9 55 BB 85 91 B9 51 BB 85 92 B9 57 BB 85 93 20  |.U....Q....W... 
BAE6  7A BC 20 F7 BC A5 0C 6A 6A A9 B7 B0 02 A9 B9 4C  |z. ....jj......L
BAF6  88 BB 4C 21 81 20 F8 BA C6 93 20 E8 B8 30 0A A9  |..L!. .... ..0..
BB06  80 9D 90 07 A9 00 9D D0 07 60 20 F8 BA E6 93 20  |.........` .... 
BB16  E8 B8 30 0A A9 80 9D 90 07 A9 01 9D D0 07 60 20  |..0...........` 
BB26  F8 BA C6 91 20 E8 B8 30 0A A9 80 9D B0 07 A9 02  |.... ..0........
BB36  9D D0 07 60 20 F8 BA E6 91 20 E8 B8 30 0A A9 80  |...` .... ..0...
BB46  9D B0 07 A9 03 9D D0 07 60 00 00 C0 40 00 00 00  |........`...@...
BB56  00 FF 00 00 00 18 BD E0 07 69 02 10 02 A5 7F 9D  |.........i......
BB66  E0 07 20 77 BC 20 F7 BC BD 80 07 D0 01 60 A9 01  |.. w. .......`..
BB76  A0 B5 4C 30 C0 DE E0 07 D0 03 4C 4F BD 20 F7 BC  |..L0......LO. ..
BB86  A9 B9 85 9E 85 9F A9 02 A0 C2 4C 1B C0 85 9E 85  |..........L.....
BB96  9F A9 01 A0 C1 4C 1B C0 20 E5 B8 10 21 A9 28 85  |.....L.. ...!.(.
BBA6  F1 A9 EE 20 E6 BB A9 F9 20 E6 BB A9 07 20 E6 BB  |... .... .... ..
BBB6  A9 12 20 E6 BB BD 80 07 29 7F 9D 80 07 60 20 54  |.. .....)....` T
BBC6  BC A9 B3 85 9E A9 B1 85 9F BD D0 07 30 04 A9 42  |............0..B
BBD6  D0 0A A9 B1 85 9E A9 B3 85 9F A9 02 A8 4C 1B C0  |.............L..
BBE6  85 90 20 BA AD 30 10 A5 90 99 D0 07 20 FE BB A9  |.. ..0...... ...
BBF6  85 20 7B 90 99 E0 07 60 BD 90 07 99 90 07 BD A0  |. {....`........
BC06  07 99 A0 07 BD B0 07 99 B0 07 BD C0 07 99 C0 07  |................
BC16  60 DE E0 07 D0 08 FE E0 07 A9 82 9D 80 07 20 F7  |`............. .
BC26  BC A9 FF 4C 93 BB 20 54 BC A9 FD 85 9E 85 9F BD  |...L.. T........
BC36  D0 07 30 06 A9 42 A0 82 D0 04 A9 C2 A0 02 4C 1B  |..0..B........L.
BC46  C0 20 A6 B5 D0 01 60 A9 03 A0 FF 4C 30 C0 BD D0  |. ....`....L0...
BC56  07 A0 00 84 91 84 93 48 29 F0 85 90 10 02 C6 91  |.......H).......
BC66  68 0A 0A 0A 0A 85 92 10 02 C6 93 20 7A BC 4C F7  |h.......... z.L.
BC76  BC 20 C0 BC 20 8F BC 18 BD B0 07 65 92 9D B0 07  |. .. ......e....
BC86  BD C0 07 65 93 9D C0 07 60 18 BD 90 07 65 90 9D  |...e....`....e..
BC96  90 07 BD A0 07 65 91 9D A0 07 60 18 BD 90 07 65  |.....e....`....e
BCA6  90 85 90 BD A0 07 65 91 85 91 18 BD B0 07 65 92  |......e.......e.
BCB6  85 92 BD C0 07 65 93 85 93 60 20 D1 BC A9 00 85  |.....e...` .....
BCC6  91 BD D0 07 85 90 10 02 C6 91 60 A9 00 85 93 BD  |..........`.....
BCD6  E0 07 85 92 10 02 C6 93 60 38 BD B0 07 E5 32 85  |........`8....2.
BCE6  92 BD C0 07 E5 33 90 04 C9 10 B0 5D 85 93 4C FA  |.....3.....]..L.
BCF6  BC 20 55 BD 38 BD 90 07 E5 30 85 90 BD A0 07 E5  |. U.8....0......
BD06  31 C9 10 B0 44 85 91 60 8A 45 0C 29 03 D0 0A 20  |1...D..`.E.)... 
BD16  21 81 E6 93 20 E8 B8 30 30 A9 40 85 92 A9 00 85  |!... ..00.@.....
BD26  93 20 7D BC 20 F7 BC BD 80 07 D0 01 60 8A 45 0C  |. }. .......`.E.
BD36  29 03 D0 03 FE D0 07 BD D0 07 29 03 C9 03 F0 F4  |).........).....
BD46  0A 69 F1 A8 A9 02 4C 30 C0 A9 00 9D 80 07 60 38  |.i....L0......`8
BD56  BD B0 07 E5 32 85 92 BD C0 07 E5 33 C9 10 B0 E9  |....2......3....
BD66  85 93 60 38 BD 90 07 E5 30 85 90 BD A0 07 E5 31  |..`8....0......1
BD76  85 91 18 69 08 C9 20 B0 D0 60                    |...i.. ..`

loc_BD80:  ; xrefs(1): $902A
BD80  DD A0 06 CMP $06A0,X               
BD83  F0 09    BEQ $BD8E                 
BD85  9D A0 06 STA $06A0,X               
BD88  20 A2 BD JSR $BDA2                 
BD8B  BD A0 06 LDA $06A0,X               

loc_BD8E:  ; xrefs(1): $BD83
BD8E  85 9B    STA $9B                   
BD90  84 9A    STY $9A                   
BD92  20 BD BD JSR $BDBD                 
BD95  BD C0 06 LDA $06C0,X               
BD98  C9 FF    CMP #$FF                  
BD9A  F0 01    BEQ $BD9D                 
BD9C  60       RTS                       

loc_BD9D:  ; xrefs(2): $AA7F $BD9A
BD9D  A9 00    LDA #$00                  
BD9F  9D A0 06 STA $06A0,X               

sub_BDA2:  ; xrefs(2): $BD88 $BDB3
BDA2  A9 00    LDA #$00                  
BDA4  9D D0 06 STA $06D0,X               
BDA7  9D C0 06 STA $06C0,X               
BDAA  60       RTS                       

sub_BDAB:  ; xrefs(4): $8987 $904D $99DB $AFAE
BDAB  DD B0 06 CMP $06B0,X               
BDAE  F0 09    BEQ $BDB9                 
BDB0  9D B0 06 STA $06B0,X               
BDB3  20 A2 BD JSR $BDA2                 
BDB6  BD B0 06 LDA $06B0,X               

loc_BDB9:  ; xrefs(1): $BDAE
BDB9  85 9B    STA $9B                   
BDBB  84 9A    STY $9A                   

sub_BDBD:  ; xrefs(1): $BD92
BDBD  BD C0 06 LDA $06C0,X               
BDC0  F0 09    BEQ $BDCB                 
BDC2  C9 FF    CMP #$FF                  
BDC4  F0 08    BEQ $BDCE                 
BDC6  DE C0 06 DEC $06C0,X               
BDC9  D0 03    BNE $BDCE                 

loc_BDCB:  ; xrefs(1): $BDC0
BDCB  4C 72 C0 JMP $C072                 

loc_BDCE:  ; xrefs(2): $BDC4 $BDC9
BDCE  60       RTS                       

; ---- data $BDCF-$BE0E (64 bytes) ----
BDCF  A5 36 05 37 F0 03 A9 00 60 A9 00 85 90 85 92 20  |.6.7....`...... 
BDDF  1E C0 48 29 C0 85 2C 84 2B 68 29 0F C9 0C B0 E6  |..H)..,.+h).....
BDEF  29 03 85 60 C9 02 90 DE 98 20 ED BE F0 D8 B9 03  |)..`..... ......
BDFF  BF 49 FF 85 29 8A 25 29 A4 2A 99 40 05 4C 49 BE  |.I..).%).*.@.LI.

sub_BE0F:  ; xrefs(2): $A87B $BF2B
BE0F  A5 36    LDA $36                   
BE11  05 37    ORA $37                   
BE13  F0 06    BEQ $BE1B                 
BE15  A9 00    LDA #$00                  
BE17  60       RTS                       

loc_BE18:  ; xrefs(1): $BE34
BE18  A9 FF    LDA #$FF                  
BE1A  60       RTS                       

loc_BE1B:  ; xrefs(1): $BE13
BE1B  A9 00    LDA #$00                  
BE1D  85 90    STA $90                   
BE1F  85 92    STA $92                   
BE21  20 1E C0 JSR $C01E                 
BE24  48       PHA                       
BE25  29 C0    AND #$C0                  
BE27  85 2C    STA $2C                   
BE29  84 2B    STY $2B                   
BE2B  68       PLA                       
BE2C  29 0F    AND #$0F                  
BE2E  C9 0C    CMP #$0C                  
BE30  B0 04    BCS $BE36                 
BE32  29 03    AND #$03                  
BE34  F0 E2    BEQ $BE18                 

loc_BE36:  ; xrefs(1): $BE30
BE36  98       TYA                       
BE37  20 ED BE JSR $BEED                 
BE3A  B9 03 BF LDA $BF03,Y               
BE3D  49 FF    EOR #$FF                  
BE3F  85 29    STA $29                   
BE41  8A       TXA                       
BE42  25 29    AND $29                   
BE44  A4 2A    LDY $2A                   
BE46  99 40 05 STA $0540,Y               
BE49  A4 2B    LDY $2B                   
BE4B  20 24 C0 JSR $C024                 
BE4E  20 27 C0 JSR $C027                 
BE51  A9 3F    LDA #$3F                  
BE53  A6 9E    LDX $9E                   
BE55  F0 0B    BEQ $BE62                 

loc_BE57:  ; xrefs(1): $BE60
BE57  38       SEC                       
BE58  6A       ROR A                     
BE59  38       SEC                       
BE5A  6A       ROR A                     
BE5B  46 2C    LSR $2C                   
BE5D  46 2C    LSR $2C                   
BE5F  CA       DEX                       
BE60  D0 F5    BNE $BE57                 

loc_BE62:  ; xrefs(1): $BE55
BE62  A4 9F    LDY $9F                   
BE64  39 20 01 AND $0120,Y               
BE67  05 2C    ORA $2C                   
BE69  99 20 01 STA $0120,Y               
BE6C  85 2C    STA $2C                   
BE6E  98       TYA                       
BE6F  4A       LSR A                     
BE70  4A       LSR A                     
BE71  4A       LSR A                     
BE72  4A       LSR A                     
BE73  29 04    AND #$04                  
BE75  18       CLC                       
BE76  69 23    ADC #$23                  
BE78  85 9A    STA $9A                   
BE7A  98       TYA                       
BE7B  29 3F    AND #$3F                  
BE7D  18       CLC                       
BE7E  69 C0    ADC #$C0                  
BE80  85 99    STA $99                   
BE82  20 21 C0 JSR $C021                 
BE85  AE 00 03 LDX $0300                 
BE88  A9 81    LDA #$81                  
BE8A  9D 01 03 STA $0301,X               
BE8D  A5 9A    LDA $9A                   
BE8F  9D 02 03 STA $0302,X               
BE92  A5 99    LDA $99                   
BE94  9D 03 03 STA $0303,X               
BE97  A5 2C    LDA $2C                   
BE99  9D 04 03 STA $0304,X               
BE9C  A9 82    LDA #$82                  
BE9E  9D 05 03 STA $0305,X               
BEA1  A5 9F    LDA $9F                   
BEA3  9D 06 03 STA $0306,X               
BEA6  A5 9E    LDA $9E                   
BEA8  9D 07 03 STA $0307,X               
BEAB  A5 94    LDA $94                   
BEAD  9D 08 03 STA $0308,X               
BEB0  A5 96    LDA $96                   
BEB2  9D 09 03 STA $0309,X               
BEB5  18       CLC                       
BEB6  A5 9E    LDA $9E                   
BEB8  69 20    ADC #$20                  
BEBA  85 9E    STA $9E                   
BEBC  A5 9F    LDA $9F                   
BEBE  69 00    ADC #$00                  
BEC0  85 9F    STA $9F                   
BEC2  A9 82    LDA #$82                  
BEC4  9D 0A 03 STA $030A,X               
BEC7  A5 9F    LDA $9F                   
BEC9  9D 0B 03 STA $030B,X               
BECC  A5 9E    LDA $9E                   
BECE  9D 0C 03 STA $030C,X               
BED1  A5 95    LDA $95                   
BED3  9D 0D 03 STA $030D,X               
BED6  A5 97    LDA $97                   
BED8  9D 0E 03 STA $030E,X               
BEDB  A9 00    LDA #$00                  
BEDD  9D 0F 03 STA $030F,X               
BEE0  18       CLC                       
BEE1  8A       TXA                       
BEE2  69 0E    ADC #$0E                  
BEE4  8D 00 03 STA $0300                 
BEE7  A9 FF    LDA #$FF                  
BEE9  8D F0 05 STA $05F0                 
BEEC  60       RTS                       

sub_BEED:  ; xrefs(1): $BE37
BEED  84 2B    STY $2B                   
BEEF  48       PHA                       
BEF0  4A       LSR A                     
BEF1  4A       LSR A                     
BEF2  4A       LSR A                     
BEF3  AA       TAX                       
BEF4  85 2A    STA $2A                   
BEF6  BD 40 05 LDA $0540,X               
BEF9  AA       TAX                       
BEFA  68       PLA                       
BEFB  29 07    AND #$07                  
BEFD  A8       TAY                       
BEFE  8A       TXA                       
BEFF  39 03 BF AND $BF03,Y               
BF02  60       RTS                       

; ---- data $BF03-$BF0A (8 bytes) ----
BF03  80 40 20 10 08 04 02 01                          |.@ .....

sub_BF0B:  ; xrefs(1): $A957
BF0B  A5 36    LDA $36                   
BF0D  05 37    ORA $37                   
BF0F  D0 29    BNE $BF3A                 
BF11  A0 00    LDY #$00                  

loc_BF13:  ; xrefs(1): $BF32
BF13  8A       TXA                       
BF14  48       PHA                       
BF15  B1 4C    LDA ($4C),Y               
BF17  C9 80    CMP #$80                  
BF19  F0 1A    BEQ $BF35                 
BF1B  18       CLC                       
BF1C  75 B0    ADC $B0,X                 
BF1E  85 91    STA $91                   
BF20  C8       INY                       
BF21  18       CLC                       
BF22  B1 4C    LDA ($4C),Y               
BF24  75 D0    ADC $D0,X                 
BF26  85 93    STA $93                   
BF28  C8       INY                       
BF29  98       TYA                       
BF2A  48       PHA                       
BF2B  20 0F BE JSR $BE0F                 
BF2E  68       PLA                       
BF2F  A8       TAY                       
BF30  68       PLA                       
BF31  AA       TAX                       
BF32  4C 13 BF JMP $BF13                 

loc_BF35:  ; xrefs(1): $BF19
BF35  68       PLA                       
BF36  AA       TAX                       
BF37  A9 FF    LDA #$FF                  
BF39  60       RTS                       

loc_BF3A:  ; xrefs(1): $BF0F
BF3A  A9 00    LDA #$00                  
BF3C  60       RTS                       

; ---- data $BF3D-$BF45 (9 bytes) ----
BF3D  FF 01 FF 00 00 01 00 00 80                       |.........

sub_BF46:  ; xrefs(2): $A896 $A8CB
BF46  FF FD FF ISC $FFFD,X               
BF49  FE 00 FD INC $FD00,X               
BF4C  00 FE    BRK #$FE                  

; ---- data $BF4E-$BF4E (1 bytes) ----
BF4E  80                                               |.

sub_BF4F:  ; xrefs(4): $A896 $A8CB $A900 $A924
BF4F  FF FF FF ISC $FFFF,X               
BF52  00 00    BRK #$00                  

; ---- data $BF54-$BF57 (4 bytes) ----
BF54  FF 00 00 80                                      |....

sub_BF58:  ; xrefs(2): $A896 $A8CB
BF58  FF 01 00 ISC $0001,X               

; ---- data $BF5B-$BF5B (1 bytes) ----
BF5B  02                                               |.

sub_BF5C:  ; xrefs(1): $A900
BF5C  FF 02 00 ISC $0002,X               
BF5F  01 80    ORA ($80,X)               

sub_BF61:  ; xrefs(1): $A8CB
BF61  FF 03 FF ISC $FF03,X               
BF64  FC 00 03 NOP $0300,X               
BF67  00 FC    BRK #$FC                  

; ---- data $BF69-$BFFF (151 bytes) ----
BF69  80 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF79  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF89  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BF99  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFA9  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFB9  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFC9  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFD9  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFE9  FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  |................
BFF9  FF FF FF FF FF FF 00                             |.......