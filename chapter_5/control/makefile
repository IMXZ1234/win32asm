EXE = control.exe
OBJ = control.obj
RES = control.res
ICO = Main.ico
BMP = Picture1.bmp Picture2.bmp

LINK_FLAG = /subsystem:windows
ML_FLAG = /coff /c

$(EXE): $(OBJ) $(RES)
	link $(LINK_FLAG) /out:$(EXE) $(OBJ) $(RES)

$(RES): $(ICO) $(BMP)

.asm.obj:
	ml $(ML_FLAG) $<

.rc.res:
	rc $<

clean:
	del *.obj
	del *.res