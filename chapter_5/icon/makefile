EXE = icon.exe
OBJ = icon.obj
RES = icon.res
ICO	= Big.ico Small.ico
CUR = 2.cur

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(EXE): $(OBJ) $(RES)
	link $(LINK_FLAG) /out:$(EXE) $(OBJ) $(RES)

$(RES): $(ICO) $(CUR)

.asm.obj:
	ml $(ML_FLAG) $<

.rc.res:
	rc $<

clean:
	del *.obj
	del *.res