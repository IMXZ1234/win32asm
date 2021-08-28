EXE = bmp_clock.exe
OBJ = bmp_clock.obj
RES = bmp_clock.res
ICO = Main.ico
CUR = Main.cur Move.cur
BMP = Back1.bmp Back1.bmp Circle1.bmp Circle2.bmp Mask1.bmp Mask2.bmp

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(EXE): $(OBJ) $(RES)
	link $(LINK_FLAG) /out:$(EXE) $(OBJ) $(RES)

$(RES): $(ICO) $(CUR) $(BMP)

.asm.obj:
	ml $(ML_FLAG) $<

.rc.res:
	rc $<

clean:
	del *.obj