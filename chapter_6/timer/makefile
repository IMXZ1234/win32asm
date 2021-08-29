EXE = timer.exe
OBJ = timer.obj
RES = timer.res
ICO = 1.ico 2.ico

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(EXE): $(OBJ) $(RES)
	link $(LINK_FLAG) /out:$(EXE) $(OBJ) $(RES)

$(RES): $(ICO)

.asm.obj:
	ml $(ML_FLAG) $<

.rc.res:
	rc $<

clean:
	del *.obj
	del	*.res