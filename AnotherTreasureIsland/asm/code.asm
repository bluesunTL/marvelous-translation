//Code ASM Hacks

//Relocate Script to 0x300000 / $F0:0000
seekFile($7C82)
asm_relocate_script:
	lda.w #text_script			//Address
	sta $40DBE0
	sta $08
	lda.w #(text_script >> 16)	//Bank

//ASM Hack to disable paging on the Team naming screen
seekFile($2C0FB1)
asm_disable_paging:
	lda.b #0

//Fix for Save & Quit Journal Menu ($2C1EE2)
seekFile($2C1ED2)
asm_menu_fix:
	lda $9AAD,x
	sta $7F009A,x
	lda $9ACB,x
	sta $7F00DA,x
	inx
	inx
	cpx.b #$1E
	bne asm_menu_fix //$EC
	
	fill 36,$EA	//Fill NOPs
	
	lda $75E8
	asl
	clc
	adc.w #$30A0
	sta $7F009A

//Easier Team Naming Controls
//B = Backspace
//A = Enter Char
//START = Begin
//Odd = BYETUDLR, Even = AXLR...

//$2C0F75 - $988F75 - START Button (don't touch)
//$2C0FB1 - $988FB1 - L/R Buttons
//$2C0FFE - $988FFE - Left/Right D-Pad (don't touch)
//$2C1032 - $989032 - Up/Down D-Pad (don't touch)
//$2C10A3 - $9890A3 - B Button
//$2C10A9 - $9890A9 - X Button
//$2C10B2 - $9890B2 - Y Button
//$2C10C1 - $9890C1 - A Button (don't touch)
//$7614 - Current Team Name Char
//$9890E6 - Delete Current Char
//$989157 - Go Back one char
seekFile($2C10A3)
	lda $F3
	bit.b #$80
	beq +
	jsr $9157
	jmp $90E6
+;	jmp $90C1

//Chore List Tilemap Edit Check ($2BB5F5 / $97B5F5)
//7EE000 - 16-bit VRAM Upload Pointer / End Address (uses this to figure out when it ends)
//Repeats:
//0x00 - VRAM Word Address
//0x02 - VRAM Address Increment Mode
//0x03 - DMA Parameters
//0x04 - VRAM Write Address for DMA (0x18)
//0x05 - Full Address for DMA
//0x08 - Size (bytes)
//0x0A - Address to next VRAM upload batch
//0x0C - Data

//Little Endian:
//Header 12 bytes
//4E5E 81 01 18 0EE07E 1400 22E0 <Data, 14 bytes>
//VRAM Addr Mode: After accessing high byte, and increment by 32 word address (64 bytes)
//DMA Param: Transfer 2 bytes (16 bit) for VRAM
//Top Left, Bottom Left, Top Right, Bottom Right

//Is only called when a chore is done.
seekAddr($A88000)

enqueue pc
seekAddr($97B5F5)
	jml asm_chore_list_check
dequeue pc
asm_chore_list_check:
	txa
	lsr
	sec
	sbc.w #$00FF
	//Value:
	//00 = X1  2  3
	//01 =  1 X2  3
	//02 =  1 X2 X3
	//03 =  1 X2  3
	//04 = X1 X2  3
	cmp.w #$0005
	bcc +

	jml $97B5FB
+;	asl
	tay

	phb
	sep #$20
	lda.b #(tbl_chore_list_maps >> 16)
	pha
	plb
	rep #$20
	//Get DMA Table Addr
	lda tbl_chore_list_maps,y
	sta $04
	//Get DMA Table End Addr (Size)
	lda ($04)
	and.w #$0FFF
	dec
	ldx $04
	ldy.w #$E000
	mvn $7E=(tbl_chore_list_maps >> 16)
	plb
	jml $97B6CC
	rts

//Management Office Tilemap Full ($97B6DD)
//Same as Chore List
enqueue pc
seekAddr($97B6DD)
	jml asm_mgmt_office_remap
dequeue pc
asm_mgmt_office_remap:
	txa
	lsr
	sec
	sbc.w #$00A4
	//Value:
	//00 = Full Sign
	//01 = 231 Sign (do not touch)
	beq +
	jml $97B6E3
+;	asl
	tay

	phb
	sep #$20
	lda.b #(tbl_mgmt_office_maps >> 16)
	pha
	plb
	rep #$20
	//Get DMA Table Addr
	lda tbl_mgmt_office_maps,y
	sta $04
	//Get DMA Table End Addr (Size)
	lda ($04)
	and.w #$0FFF
	dec
	ldx $04
	ldy.w #$E000
	mvn $7E=(tbl_mgmt_office_maps >> 16)
	plb
	jml $97B781
	rts

//Ship Notes - Numbers ($97B9F6)
//Same as Chore List
enqueue pc
seekAddr($97B9F6)	//Which note
	jml asm_shipnote_remap
dequeue pc
asm_shipnote_remap:
	txa
	lsr
	sec
	sbc.w #$0104
	//Value:
	//0 = 8+8-3=?
	//1 = Sike!
	//2 = 12358
	//3 = Upside Down 1436
	//4 = 7654321 (UNUSED? We won't do anything to it just in case)
	cmp.w #$0004
	bcc _asm_shipnote_remap_do
	jml $97B9FC
_asm_shipnote_remap_do:
	asl
	tay

	phb
	sep #$20
	lda.b #(tbl_ship_notes_maps >> 16)
	pha
	plb
	rep #$20
	//Get DMA Table Addr
	lda tbl_ship_notes_maps,y
	sta $04
	//Get DMA Table End Addr (Size)
	lda ($04)
	and.w #$0FFF
	dec
	ldx $04
	ldy.w #$E000
	mvn $7E=(tbl_ship_notes_maps >> 16)
	plb
	jml $97BAC5
	rts

//Ship Notes - Letters ($97BB02)
//Same as Chore List
enqueue pc
seekAddr($97BB02)
	//No Values, just one
	lda.w #$0005
	jml _asm_shipnote_remap_do
dequeue pc

//Chapter Screen ($8DF1EC - SNES CPU)
asm_set_chapter_tilemap:
	ldx.b #0
	lda.w #$30E0
-;	sta $7F0198,x
	inc; inc; inx; inx
	cpx.b #16
	bne -
	rtl

//$2F - do +2 when changing Gameplay mode?
//$E6 - Current Char (*2)
//$FE - Timing (From 0xC0)
//$3100 - Chapter ID (*2)
//JSL $00FC35 (Play SFX, use 0x2C)

//Notes:
//$33C8 - VRAM Address (Word)
//$33CA - Full Address to DMA From
//$33CD - Size (bytes)
enqueue pc
seekAddr($8DF1E0)
	lda.b #$FF
seekAddr($8DF1EC)
	jsl asm_chapter_screen_loop
	rts
dequeue pc
asm_chapter_screen_loop:
	ldx $3100
	lda $E6
	cmp ani_chapter_frames,x
	beq +
	lda $FE
	cmp.b #(0xFF-0x30)
	bcs +
	and.b #$07
	bne +
	//VRAM DMA Setup
	rep #$20
	lda.w #$0E00/2
	sta $33C8
	lda ani_chapter_addr,x
	adc $e5
	sta $33CA
	lda ani_chapter_bank,x
	sta $33CC
	lda.w #$0200
	sta $33CD
	//Play SFX
	sep #$20
	lda.b #$2C
	jsl $00fC35

	inc $E6
	inc $E6
+;	dec $FE
	bne +
	inc $2F
	inc $2F
+;	clc; rtl

enqueue pc
seekFile($3F0000)

	insert gfx_chapter1_ani,"../text/en_new/chapter1.bin"
	insert gfx_chapter2_ani,"../text/en_new/chapter2.bin"
	insert gfx_chapter3_ani,"../text/en_new/chapter3.bin"
	insert gfx_chapter4_ani,"../text/en_new/chapter4.bin"
	insert gfx_chapter5_ani,"../text/en_new/chapter5.bin"

constant gfx_chapter1_ani_frames = gfx_chapter1_ani.size / 0x200
constant gfx_chapter2_ani_frames = gfx_chapter2_ani.size / 0x200
constant gfx_chapter3_ani_frames = gfx_chapter3_ani.size / 0x200
constant gfx_chapter4_ani_frames = gfx_chapter4_ani.size / 0x200
constant gfx_chapter5_ani_frames = gfx_chapter5_ani.size / 0x200

ani_chapter_frames:
	dw gfx_chapter1_ani_frames*2
	dw gfx_chapter2_ani_frames*2
	dw gfx_chapter3_ani_frames*2
	dw gfx_chapter4_ani_frames*2
	dw gfx_chapter5_ani_frames*2
ani_chapter_addr:
	dw gfx_chapter1_ani
	dw gfx_chapter2_ani
	dw gfx_chapter3_ani
	dw gfx_chapter4_ani
	dw gfx_chapter5_ani
ani_chapter_bank:
	dw gfx_chapter1_ani>>16
	dw gfx_chapter2_ani>>16
	dw gfx_chapter3_ani>>16
	dw gfx_chapter4_ani>>16
	dw gfx_chapter5_ani>>16
dequeue pc
