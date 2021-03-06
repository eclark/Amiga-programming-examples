*************************************************
* Raw picture viewer in 320x256x4 (16 col.)	*
* Example written by Flops 08.01.2016		*
* It can be freely use (if is not used	to harm	*
* anybody).					*
*************************************************

	Section code,code_p	; Dajemy znac systemowi ze to bedzie kod programu, umieszamy w pamieci typu Public (obojetnie czy system da nam
				; CHIP czy SLOW, czy moze FAST
Zab_sys:
	move.w $dff01c,d0
	ori.w #$8000,d0
	move.w d0,Old_INT
	move.w #$7fff,$dff09a
	move.w $dff002,d0
	ori.w #$8000,d0
	move.w d0,Old_DMA
	move.w #$7fff,$dff096
	move.w #$83c0,$dff096
	move.l 4.w,a6
	move.l 156(a6),a1
	move.l 38(a1),Old_COPPER
	move.l a7,Old_STACK
Wstep:
	move.l #COPPER,$dff080
	move.l #0,$dff088
	move.l #3,d0		; liczba bitplanow -1
	move.l #40,d1		; szerokosc obrazka (w pixelach/8)
	move.l #256,d2		; wysokosc obrazka (w pixelach)
	mulu.w d2,d1		; mnozymy wysokosc razy szerokosc, zeby wiedziec jaka wielkosc posiada kazy bitplane
	move.l #Image,d2
	lea Registers,a1
Init:
	swap d2
	move.w d2,2(a1)
	swap d2
	move.w d2,6(a1)
	addq.l #8,a1
	add.l d1,d2
	dbf d0,Init

; PalletInit
;	move.w #0,$dff0106	; bank 0, ustawienie banku nr 0 dla AGA
	lea PalleteRegisters,A1
	movea.l #ImagePallete-32,a0 ; Przykladowy raw zostal przekonwertowany z paleta ustawiona na koncu pliku
				; a wiec pobieramy adres jeden po pliku raw (gdzie jest obraz + na koncu paleta)
				; odejmujemy 32 (gdyz 16 kolory, ale kazdy element jest slowem - czyli dwa bajty,
				; co daje 32 bajty)
	moveq.l #15,d0
	move.l #$00000180,D1
PalleteLoop:
	move.w D1,(A1)+
	addq.w #2,D1
	move.w (A0)+,(A1)+	; kopiujemy 16 kolory do rejestrow kolorow
	dbf d0,PalleteLoop
	
Stop:				; Petla oczekujaca na lewy przycisk myszy
	btst #6,$bfe001
	bne Stop
ExitProc:			; Procedura przywracajace wczesniejesz parametry systemu, zeby wyjsc bez bolu spowrotem do AOS
	move.l Old_STACK,a7	; Jeszcze powinno sie przywrocic wartosci dla wszystkich rejestrow, ale tutaj jest to pominiete
	move.l Old_COPPER,$dff080
	move.w Old_DMA,$dff096
	move.w Old_INT,$dff09a
	move.l #0,D0	; Co podac na wyjsciu do CLI. Liczba rozna od zera oznacza, ze aplikacja zakoczyla sie z bledem.
	rts

Old_INT:
	dc.w 0
Old_DMA:
	dc.w 0
Old_COPPER:
	dc.l 0
Old_STACK:
	dc.l 0

	Section data,data_c		; Informujemy system, ze ten fragment musi znajdowac sie w pamieci CHIP
					; Copperlista jest odtwarzana przez chipset, a chipsety maja dostep tylko do pamieci tego typu
COPPER:	; Instrukcja move coppera sklada sie z dwoch czesci, pierwsze dwa bajty np. ponizsze 01fc oznaczaja adres rejestru (ktory automatycznie jest
	DC.L $01fc0000	; tak jakby rozszerzony do $DFF1FC, a nastepne dwa bajty to wartosc jaka wpisujemy pod podany adres
	DC.L $01004200,$01020000	; Pod adresem DFF100 znajduje sie rejestr BPLCON0
	DC.L $01040000,$01060000	; 4 oznacza ze bedziemy uzywac 4 bitplanow 2^4 = 16 col.
	DC.L $008e2c81,$00902cc1	; tutaj ustawiane jest okno wyswietlania
	DC.L $00920038,$009400d0	; tutaj pobierania danych (wiecej info. w ksiazce Adam Doligalski Kurs Asemblera na stronach 60-63)
	DC.L $01fc0000
	DC.L $01080000,$010a0000
Registers:				; Rejestry wskazujace adresy bitplanow obrazka
	DC.L $00e00000,$00e20000
	DC.L $00e40000,$00e60000
	DC.L $00e80000,$00ea0000
	DC.L $00ec0000,$00ee0000
	DC.L $00f00000,$00f20000
	DC.L $00f40000,$00f60000
	DC.L $00f80000,$00fa0000
	DC.L $00fc0000,$00fe0000

PalleteRegisters:
	DC.L $01800fff,$0182000f
	DC.L $01840000,$018600f0
	DC.L $01880000,$018A0f00
	DC.L $018c0000,$018e0f00
	DC.L $01900000,$019200f0
	DC.L $01940000,$019600f0
	DC.L $01980000,$018A000f
	DC.L $019C0fff,$019E0000
	DC.L $01A00000,$01A20000
	DC.L $01A40000,$01A60000
	DC.L $01A80000,$01AA0000
	DC.L $01AC0000,$01AE0000
	DC.L $01B00000,$01B20000
	DC.L $01B40000,$01B60000
	DC.L $01B80000,$01BA0000
	DC.L $01BC0000,$01BE0000

	DC.L $FFFFFFFE			; Koniec copperlisty

Image:
	incbin "ram:raw/kubus16.raw"	; Plik raw z paleta. Skonwertowany przy uzyciu Alcatraz&Kefrens-IFFCon135 z opcja dodania palety na koniec
ImagePallete:
