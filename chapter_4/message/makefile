EXE = message.exe
OBJ = message.obj

LINK_FLAG = /subsystem:windows
ML_FLAG = /c /coff

$(EXE): $(OBJ)
	link $(LINK_FLAG) /out:$(EXE) $(OBJ)

.asm.obj:
	ml $(ML_FLAG) $<

clean:
	del *.obj